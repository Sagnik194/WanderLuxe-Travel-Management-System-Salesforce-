public with sharing class TravelerConsoleController {

    @AuraEnabled(cacheable=true)
    public static List<Traveler__c> getPendingVerifications(String searchPassport) {
        String searchTerm = String.isBlank(searchPassport)
            ? '%'
            : '%' + String.escapeSingleQuotes(searchPassport) + '%';

        return [
            SELECT Id, Name, Passport_Number__c, Verification_Status__c,
                   Booking_Status__c, Travel_Type__c, VIP_Grade__c
            FROM Traveler__c
            WHERE Verification_Status__c != 'Verified'
            AND Passport_Number__c LIKE :searchTerm
            ORDER BY CreatedDate DESC
            LIMIT 200
        ];
    }

    @AuraEnabled
    public static void massApprove(List<Id> travelerIds) {
        List<Traveler__c> travelers = [
            SELECT Id, Verification_Status__c
            FROM Traveler__c
            WHERE Id IN :travelerIds
        ];
        for (Traveler__c t : travelers) {
            t.Verification_Status__c = 'Verified';
        }
        update travelers;
    }

    @AuraEnabled
    public static void updateBookingStatus(Id travelerId, String newStatus) {
        Traveler__c t = new Traveler__c(Id = travelerId, Booking_Status__c = newStatus);
        update t;
    }
}