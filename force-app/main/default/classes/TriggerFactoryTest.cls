/**
 * Class to test TriggerFactory pattern
 */
@isTest
public class TriggerFactoryTest {

    @TestSetup
    static void setup() {
        insert new Country__c(
            Name          = 'Spain',
            Alpha2Code__c = 'ES',
            Alpha3Code__c = 'ESP'
        );
    }

    // ─── NO TRIGGER CONTEXT ────────────────────────────────────────────────────
    @isTest
    static void testNoTriggerContext()
    {
        Test.startTest();
        try 
        {
            TriggerFactory.execute(new LeadTriggerHandler());
        }
        catch(TriggerFactory.TriggerFactoryException ex)
        {
            System.debug('TriggerFactoryException message: ' + ex.getMessage());
        }
        Test.stopTest();
    }

    // ─── BEFORE INSERT ────────────────────────────────────────────────────
    @isTest
    static void testBeforeInsertAssignsCountry() {
        Test.startTest();
        Lead l = new Lead(LastName = 'Test', Company = 'Acme', CountryCode = 'ES');
        insert l;
        Test.stopTest();

        Lead result = [SELECT Country__c FROM Lead WHERE Id = :l.Id];
        Assert.isNotNull(result.Country__c, 'Country__c should be assigned in before insert');
    }

    @isTest
    static void testBeforeInsertNoCountryCode() {
        Test.startTest();
        Lead l = new Lead(LastName = 'Test', Company = 'Acme');
        insert l;
        Test.stopTest();

        Lead result = [SELECT Country__c FROM Lead WHERE Id = :l.Id];
        Assert.isNull(result.Country__c, 'Country__c should be null if has not CountryCode');
    }

    @isTest
    static void testBeforeInsertInvalidCountryCode() {
        Test.startTest();
        Lead l = new Lead(LastName = 'Test', Company = 'Acme', CountryCode = 'AR');
        insert l;
        Test.stopTest();

        Lead result = [SELECT Country__c FROM Lead WHERE Id = :l.Id];
        Assert.isNull(result.Country__c, 'Country__c should be null if CountryCode does not exist in Country__c');
    }

    // ─── BEFORE UPDATE ────────────────────────────────────────────────────
    @isTest
    static void testBeforeUpdateChangesCountry() {
        Lead l = new Lead(LastName = 'Test', Company = 'Acme', CountryCode = 'PT');
        insert l;

        Test.startTest();
        l.CountryCode = 'ES';
        update l;
        Test.stopTest();

        Lead result = [SELECT Country__c FROM Lead WHERE Id = :l.Id];
        Assert.isNotNull(result.Country__c, 'Country__c should have been assigned when CountryCode to a valid one');
    }

    @isTest
    static void testBeforeUpdateClearsCountryWhenCodeRemoved() {
        Country__c spain = [SELECT Id FROM Country__c WHERE Alpha2Code__c = 'ES'];
        Lead l = new Lead(LastName = 'Test', Company = 'Acme', CountryCode = 'ES', Country__c = spain.Id);
        insert l;

        Test.startTest();
        l.CountryCode = null;
        update l;
        Test.stopTest();

        Lead result = [SELECT Country__c FROM Lead WHERE Id = :l.Id];
        Assert.isNull(result.Country__c, 'Country__c should be removed if CountryCode is removed');
    }

    @isTest
    static void testBeforeUpdateSameCountryCodeNoChange() {
        Country__c spain = [SELECT Id FROM Country__c WHERE Alpha2Code__c = 'ES'];
        Lead l = new Lead(LastName = 'Test', Company = 'Acme', CountryCode = 'ES', Country__c = spain.Id);
        insert l;

        Test.startTest();
        l.LastName = 'Updated';  // Only change a field not relevant
        update l;
        Test.stopTest();

        Lead result = [SELECT Country__c FROM Lead WHERE Id = :l.Id];
        Assert.areEqual(spain.Id, result.Country__c, 'Country__c should have not been changed if CountryCode does not change');
    }

    @isTest
    static void testBeforeUpdateToInvalidCountryCode() {
        Country__c spain = [SELECT Id FROM Country__c WHERE Alpha2Code__c = 'ES'];
        Lead l = new Lead(LastName = 'Test', Company = 'Acme', CountryCode = 'ES', Country__c = spain.Id);
        insert l;

        Test.startTest();
        l.CountryCode = 'AR';
        update l;
        Test.stopTest();

        Lead result = [SELECT Country__c FROM Lead WHERE Id = :l.Id];
        Assert.isNull(result.Country__c, 'Country__c should be removed if the new CountryCode does not exist');
    }

    // ─── BEFORE DELETE ────────────────────────────────────────────────────
    @isTest
    static void testBeforeDelete() {
        Lead l = new Lead(LastName = 'Test', Company = 'Acme', CountryCode = 'ES');
        insert l;

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            delete l;
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Assert.isFalse(exceptionThrown, 'Before delete should not execute exception');
        List<Lead> deleted = [SELECT Id FROM Lead WHERE Id = :l.Id];
        Assert.areEqual(0, deleted.size(), 'Lead should have been deleted');
    }

    // ─── AFTER INSERT ─────────────────────────────────────────────────────
    @isTest
    static void testAfterInsert() {
        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            Lead l = new Lead(LastName = 'Test', Company = 'Acme', CountryCode = 'ES');
            insert l;
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Assert.isFalse(exceptionThrown, 'After insert should not execute exception');
    }

    // ─── AFTER UPDATE ─────────────────────────────────────────────────────
    @isTest
    static void testAfterUpdate() {
        Lead l = new Lead(LastName = 'Test', Company = 'Acme', CountryCode = 'ES');
        insert l;

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            l.LastName = 'Updated';
            update l;
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Assert.isFalse(exceptionThrown, 'After update should not execute exception');
    }

    // ─── AFTER DELETE ─────────────────────────────────────────────────────
    @isTest
    static void testAfterDelete() {
        Lead l = new Lead(LastName = 'Test', Company = 'Acme', CountryCode = 'ES');
        insert l;

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            delete l;
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Assert.isFalse(exceptionThrown, 'After delete should not execute exception');
    }

    // ─── AFTER UNDELETE ───────────────────────────────────────────────────
    @isTest
    static void testAfterUndelete() {
        Lead l = new Lead(LastName = 'Test', Company = 'Acme', CountryCode = 'ES');
        insert l;
        delete l;

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            undelete l;
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Assert.isFalse(exceptionThrown, 'After undelete should not execute the execption');
        List<Lead> undeleted = [SELECT Id FROM Lead WHERE Id = :l.Id];
        Assert.areEqual(1, undeleted.size(), 'Lead should have been restored');
    }

    // ─── BULK ─────────────────────────────────────────────────────────────
    @isTest
    static void testBulkInsert() {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
            leads.add(new Lead(
                LastName    = 'Test' + i,
                Company     = 'Acme',
                CountryCode = 'ES'
            ));
        }

        Test.startTest();
        insert leads;
        Test.stopTest();

        Integer matched = [SELECT COUNT() FROM Lead WHERE Country__c != null];
        Assert.areEqual(200, matched, 'Every Lead should have Country__c assigned');
    }

    @isTest
    static void testBulkUpdate() {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
            leads.add(new Lead(
                LastName    = 'Test' + i,
                Company     = 'Acme',
                CountryCode = 'PT'
            ));
        }
        insert leads;

        Test.startTest();
        for (Lead l : leads) {
            l.CountryCode = 'ES';
        }
        update leads;
        Test.stopTest();

        Integer matched = [SELECT COUNT() FROM Lead WHERE Country__c != null];
        Assert.areEqual(200, matched, 'Every Lead bulk should be updated with Country__c');
    }
}
