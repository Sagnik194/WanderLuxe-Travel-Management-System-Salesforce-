global class TravelerEscalationBatch implements Database.Batchable<SObject>, Database.Stateful {
    global List<Traveler__c> escalatedRecords = new List<Traveler__c>();
    global DateTime cutoff = DateTime.now().addHours(-48);

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Passport_Number__c, Verification_Status__c, CreatedDate, OwnerId
            FROM Traveler__c
            WHERE Verification_Status__c = 'Pending'
            AND CreatedDate <= :cutoff
            AND Escalated_To_Compliance__c = false
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Traveler__c> scope) {
        Id complianceQueueId = [
            SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Compliance_Team' LIMIT 1
        ].Id;

        List<Traveler__c> toUpdate = new List<Traveler__c>();
        for (Traveler__c t : scope) {
            t.OwnerId = complianceQueueId;
            t.Escalated_To_Compliance__c = true;
            toUpdate.add(t);
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
            escalatedRecords.addAll(toUpdate);
        }
    }

    global void finish(Database.BatchableContext bc) {
        if (escalatedRecords.isEmpty()) {
            return;
        }
        String body = 'The following travelers had pending verification for more than 48 hours ' + 
                      'and have been escalated to the Compliance Team:\n\n';
        for (Traveler__c t : escalatedRecords) {
            body += '- ' + t.Name + ' (Passport: ' + t.Passport_Number__c + 
                    ', Created: ' + t.CreatedDate.format() + ')\n';
        }
        List<String> recipients = new List<String>{ 'management@wanderluxe.example.com' };
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(recipients);
        email.setSubject('Nightly Exception Report: ' + escalatedRecords.size() + ' Traveler(s) Escalated to Compliance');
        email.setPlainTextBody(body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    }
}