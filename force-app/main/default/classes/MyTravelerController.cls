public with sharing class MyTravelerController {
    @AuraEnabled(cacheable=true)
    public static Traveler__c getMyBooking(String passportNumber) {
        Id currentContactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        
        List<Traveler__c> results;
        if (currentContactId == null) {
            results = [
                SELECT Id, Name, Booking_Status__c, Travel_Type__c, VIP_Grade__c, Visa_Clearance_Status__c, Portal_Contact__c
                FROM Traveler__c
                WHERE Passport_Number__c = :passportNumber
                LIMIT 1
            ];
        } else {
            results = [
                SELECT Id, Name, Booking_Status__c, Travel_Type__c, VIP_Grade__c, Visa_Clearance_Status__c, Portal_Contact__c
                FROM Traveler__c
                WHERE Passport_Number__c = :passportNumber
                AND Portal_Contact__c = :currentContactId
                LIMIT 1
            ];
        }
        
        if (results.isEmpty()) {
            throw new AuraHandledException('No booking found for that passport number.');
        }
        return results[0];
    }
}