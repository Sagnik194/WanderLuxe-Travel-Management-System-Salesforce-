@isTest
private class TravelerDuplicateTriggerTest {
    @isTest
    static void testBlocksFourthDuplicateWithin30Days() {
        Account agency = new Account(Name = 'Test Agency');
        insert agency;

        List<Traveler__c> travelers = new List<Traveler__c>();
        for (Integer i = 0; i < 3; i++) {
            travelers.add(new Traveler__c(
                Name = 'Traveler ' + i,
                Passport_Number__c = 'DUPTEST123',
                Travel_Type__c = 'Domestic',
                Partner_Agency__c = agency.Id,
                Booking_Status__c = 'Draft'
            ));
        }
        insert travelers;

        Traveler__c fourth = new Traveler__c(
            Name = 'Traveler 4th',
            Passport_Number__c = 'DUPTEST123',
            Travel_Type__c = 'Domestic',
            Partner_Agency__c = agency.Id,
            Booking_Status__c = 'Draft'
        );

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            insert fourth;
        } catch (DmlException e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('30'), 'Error message should reference the 30-day rule');
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'The 4th duplicate passport request should have been blocked');
    }

    @isTest
    static void testAllowsThreeRequestsWithinLimit() {
        Account agency = new Account(Name = 'Test Agency 2');
        insert agency;

        List<Traveler__c> travelers = new List<Traveler__c>();
        for (Integer i = 0; i < 3; i++) {
            travelers.add(new Traveler__c(
                Name = 'Traveler ' + i,
                Passport_Number__c = 'ALLOWTEST456',
                Travel_Type__c = 'Domestic',
                Partner_Agency__c = agency.Id,
                Booking_Status__c = 'Draft'
            ));
        }

        Test.startTest();
        insert travelers;
        Test.stopTest();

        List<Traveler__c> results = [SELECT Id FROM Traveler__c WHERE Passport_Number__c = 'ALLOWTEST456'];
        System.assertEquals(3, results.size(), 'All 3 requests within the limit should be allowed');
    }

    @isTest
    static void testBulkDataLoaderScenario() {
        Account agency1 = new Account(Name = 'Agency A');
        Account agency2 = new Account(Name = 'Agency B');
        insert new List<Account>{ agency1, agency2 };

        List<Traveler__c> bulkTravelers = new List<Traveler__c>();
        for (Integer i = 0; i < 200; i++) {
            bulkTravelers.add(new Traveler__c(
                Name = 'Bulk Traveler ' + i,
                Passport_Number__c = 'BULK' + i,
                Travel_Type__c = 'Domestic',
                Partner_Agency__c = (Math.mod(i, 2) == 0) ? agency1.Id : agency2.Id,
                Booking_Status__c = 'Draft'
            ));
        }

        Test.startTest();
        insert bulkTravelers;
        Test.stopTest();

        List<Traveler__c> results = [SELECT Id FROM Traveler__c WHERE Name LIKE 'Bulk Traveler%'];
        System.assertEquals(200, results.size(), 'Bulk insert of 200 unique-passport records should succeed without hitting limits');
    }
}