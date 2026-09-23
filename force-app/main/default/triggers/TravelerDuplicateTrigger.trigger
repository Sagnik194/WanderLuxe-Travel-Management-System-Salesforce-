trigger TravelerDuplicateTrigger on Traveler__c (before insert, before update) {
    Set<String> passportNumbers = new Set<String>();
    for (Traveler__c t : Trigger.new) {
        if (t.Passport_Number__c != null) {
            passportNumbers.add(t.Passport_Number__c);
        }
    }
    
    if (passportNumbers.isEmpty()) return;
    
    Date thirtyDaysAgo = Date.today().addDays(-30);
    List<Traveler__c> existingTravelers = [
        SELECT Id, Passport_Number__c, CreatedDate 
        FROM Traveler__c 
        WHERE Passport_Number__c IN :passportNumbers 
        AND CreatedDate >= :thirtyDaysAgo
    ];
    
    Map<String, Integer> passportCountMap = new Map<String, Integer>();
    for (Traveler__c existing : existingTravelers) {
        String pNum = existing.Passport_Number__c;
        Integer count = passportCountMap.containsKey(pNum) ? passportCountMap.get(pNum) : 0;
        passportCountMap.put(pNum, count + 1);
    }
    
    for (Traveler__c t : Trigger.new) {
        if (t.Passport_Number__c != null) {
            String pNum = t.Passport_Number__c;
            Integer currentCount = passportCountMap.containsKey(pNum) ? passportCountMap.get(pNum) : 0;
            
            if (currentCount >= 3) {
                t.addError('Error: Passport has already been used 3 times within the last 30 days.');
            } else {
                passportCountMap.put(pNum, currentCount + 1);
            }
        }
    }
}