@isTest
private class TravelerConsoleControllerTest {

    @testSetup
    static void setup() {
        Account agency = new Account(Name = 'Test Agency');
        insert agency;

        List<Traveler__c> travelers = new List<Traveler__c>();
        travelers.add(new Traveler__c(
            Name = 'Pending Traveler',
            Passport_Number__c = 'PEND111',
            Travel_Type__c = 'Domestic',
            Partner_Agency__c = agency.Id,
            Booking_Status__c = 'Draft',
            Verification_Status__c = 'Pending'
        ));
        travelers.add(new Traveler__c(
            Name = 'Already Verified',
            Passport_Number__c = 'VER222',
            Travel_Type__c = 'Domestic',
            Partner_Agency__c = agency.Id,
            Booking_Status__c = 'Draft',
            Verification_Status__c = 'Verified'
        ));
        insert travelers;
    }

    @isTest
    static void testGetPendingVerificationsNoSearch() {
        Test.startTest();
        List<Traveler__c> results = TravelerConsoleController.getPendingVerifications(null);
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should only return the traveler still pending verification');
        System.assertEquals('Pending Traveler', results[0].Name);
    }

    @isTest
    static void testGetPendingVerificationsWithSearch() {
        Test.startTest();
        List<Traveler__c> results = TravelerConsoleController.getPendingVerifications('PEND111');
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Search by passport number should return the matching pending traveler');
        System.assertEquals('PEND111', results[0].Passport_Number__c);
    }

    @isTest
    static void testGetPendingVerificationsSearchNoMatch() {
        Test.startTest();
        List<Traveler__c> results = TravelerConsoleController.getPendingVerifications('NOMATCH999');
        Test.stopTest();

        System.assertEquals(0, results.size(), 'A search term with no match should return an empty list, not an error');
    }

    @isTest
    static void testMassApprove() {
        List<Traveler__c> pending = [SELECT Id FROM Traveler__c WHERE Verification_Status__c = 'Pending'];
        List<Id> ids = new List<Id>();
        for (Traveler__c t : pending) {
            ids.add(t.Id);
        }

        Test.startTest();
        TravelerConsoleController.massApprove(ids);
        Test.stopTest();

        Traveler__c updated = [SELECT Verification_Status__c FROM Traveler__c WHERE Id = :ids[0]];
        System.assertEquals('Verified', updated.Verification_Status__c, 'Mass approve should set status to Verified');
    }

    @isTest
    static void testUpdateBookingStatus() {
        Traveler__c t = [SELECT Id FROM Traveler__c WHERE Passport_Number__c = 'PEND111'];

        Test.startTest();
        TravelerConsoleController.updateBookingStatus(t.Id, 'Pending');
        Test.stopTest();

        Traveler__c updated = [SELECT Booking_Status__c FROM Traveler__c WHERE Id = :t.Id];
        System.assertEquals('Pending', updated.Booking_Status__c, 'Booking status should be updated to Pending');
    }
}