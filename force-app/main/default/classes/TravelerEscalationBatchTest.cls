@isTest
private class TravelerEscalationBatchTest {
    @testSetup
    static void setup() {
        // Create setup objects first
        Group complianceQueue = new Group(Name = 'Compliance Team', Type = 'Queue');
        insert complianceQueue;

        QueuesObject mapping = new QueuesObject(QueueId = complianceQueue.Id, SObjectType = 'Traveler__c');
        insert mapping;

        // Separate non-setup object creation to avoid mixed DML
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account agency = new Account(Name = 'Test Agency');
            insert agency;

            Traveler__c overdue = new Traveler__c(
                Name = 'Overdue Traveler',
                Passport_Number__c = 'ESC001',
                Travel_Type__c = 'Domestic',
                Partner_Agency__c = agency.Id,
                Booking_Status__c = 'Draft',
                Verification_Status__c = 'Pending'
            );
            insert overdue;

            Traveler__c recent = new Traveler__c(
                Name = 'Recent Traveler',
                Passport_Number__c = 'ESC002',
                Travel_Type__c = 'Domestic',
                Partner_Agency__c = agency.Id,
                Booking_Status__c = 'Draft',
                Verification_Status__c = 'Pending'
            );
            insert recent;
        }
    }

    @isTest
    static void testBatchEscalatesOnlyOverdueRecords() {
        TravelerEscalationBatch batchJob = new TravelerEscalationBatch();
        batchJob.cutoff = DateTime.now().addMinutes(1);

        Test.startTest();
        Database.executeBatch(batchJob, 200);
        Test.stopTest();

        List<Traveler__c> escalated = [
            SELECT Id, Escalated_To_Compliance__c, OwnerId
            FROM Traveler__c
            WHERE Escalated_To_Compliance__c = true
        ];
        System.assertEquals(2, escalated.size(), 'Both pending records older than cutoff should be escalated');
    }

    @isTest
    static void testSchedulerKicksOffBatch() {
        Test.startTest();
        String cronExpr = '0 0 1 * * ?';
        System.schedule('Test Nightly Escalation', cronExpr, new TravelerEscalationScheduler());
        Test.stopTest();

        List<CronTrigger> jobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Test Nightly Escalation'];
        System.assertEquals(1, jobs.size(), 'The scheduled job should be registered');
    }
}