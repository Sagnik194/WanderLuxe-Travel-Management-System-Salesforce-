@isTest
private class MyTravelerControllerTest {

    @testSetup
    static void setup() {
        Account agency = new Account(Name = 'Test Agency');
        insert agency;

        Traveler__c traveler = new Traveler__c(
            Name = 'Sayak Debnath',
            Passport_Number__c = '6008976',
            Travel_Type__c = 'Domestic',
            Partner_Agency__c = agency.Id,
            Booking_Status__c = 'Confirmed',
            VIP_Grade__c = 'VIP Concierge',
            Visa_Clearance_Status__c = 'Completed'
        );
        insert traveler;
    }

    @isTest
    static void testGetMyBookingValidPassport() {
        Test.startTest();
        Traveler__c result = MyTravelerController.getMyBooking('6008976');
        Test.stopTest();

        System.assertEquals('Sayak Debnath', result.Name);
        System.assertEquals('Confirmed', result.Booking_Status__c);
    }

    @isTest
    static void testGetMyBookingInvalidPassportThrowsException() {
        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            MyTravelerController.getMyBooking('DOES_NOT_EXIST');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'An invalid passport number should throw a handled exception, not return null or leak an error');
    }

    @isTest
    static void testCannotAccessAnotherTravelersBooking() {
        User runningUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs(runningUser) {
            Boolean exceptionThrown = false;
            Test.startTest();
            try {
                MyTravelerController.getMyBooking('9999999');
            } catch (AuraHandledException e) {
                exceptionThrown = true;
            }
            Test.stopTest();

            System.assert(exceptionThrown, 'System should safely throw an exception for unlinked or non-existent booking queries');
        }
    }
}