@isTest
public class LeadCountryLayerServiceTest 
{
    // ─── TEST: INSERT Lead with valid CountryCode (match) ─────────────────────
    @isTest
    static void testInsertNewLeadWithValidCountryCode() {
        // Arrange: Create a Country__c with Alpha2Code = "ES"
        Country__c spain = new Country__c(
            Name = 'Spain',
            Alpha2Code__c = 'ES',
            Alpha3Code__c = 'ESP'
        );
        insert spain;

        Lead newLead = new Lead(
            LastName = 'Test',
            CountryCode = 'ES',  // Should assign spain.Id
            Company = 'Company'
        );

        // Act: execute assign Country method
        Test.startTest();
        LeadCountryLayerService.enrichLeadsWithCountry(new List<Lead>{newLead}, null);
        insert newLead;
        Test.stopTest();

        // Assert: verify Lead has filled loookup Country correctly
        Lead insertedLead = [SELECT Country__c, CountryCode FROM Lead WHERE Id = :newLead.Id];
        System.assertEquals(spain.Id, insertedLead.Country__c, 'Country__c lookup should be assigned correctly when a Lead is inserted with a valid CountryCode');
        System.assertEquals('ES', insertedLead.CountryCode, 'CountryCode has to be equal');
    }

    // ─── TEST: INSERT Lead without CountryCode (no lookup) ─────────────────────
    @isTest
    static void testInsertNewLeadWithoutCountryCode() {
        // Arrange: Create a Country__c with Alpha2Code = "ES"
        Country__c spain = new Country__c(
            Name = 'Spain',
            Alpha2Code__c = 'ES',
            Alpha3Code__c = 'ESP'
        );
        insert spain;

        Lead newLead = new Lead(
            LastName = 'Test',
            CountryCode = null,  // Should clean the lookup field
            Company = 'Company'
        );

        // Act: execute assign Country method
        Test.startTest();
        LeadCountryLayerService.enrichLeadsWithCountry(new List<Lead>{newLead}, null);
        insert newLead;
        Test.stopTest();

        // Assert: verifiy Lead has not lookup Country__c
        Lead insertedLead = [SELECT Country__c, CountryCode FROM Lead WHERE Id = :newLead.Id];
        System.assert(insertedLead.Country__c == null, 'Country__c lookup should not be assigned when Lead has not CountryCode');
        System.assert(insertedLead.CountryCode == null, 'CountryCode should be null');
    }

    // ─── TEST: UPDATE Lead with CountryCode changed (match) ─────────────────────
    @isTest
    static void testUpdateLeadCountryCodeToValid() {
        // Arrange: create a Country__c with Alpha2Code = "ES" y "FR"
        Country__c spain = new Country__c(
            Name = 'Spain',
            Alpha2Code__c = 'ES',
            Alpha3Code__c = 'ESP'
        );
        Country__c france = new Country__c(
            Name = 'France',
            Alpha2Code__c = 'FR',
            Alpha3Code__c = 'FRA'
        );
        insert new List<Country__c>{spain, france};

        Lead existingLead = new Lead(
            LastName = 'Test',
            CountryCode = 'ES',  // First value
            Company = 'Company', 
            Country__c = spain.Id
        );
        insert existingLead;

        // Change CountryCode to "FR"
        Lead updatedLead = [SELECT Id, CountryCode FROM Lead WHERE Id = :existingLead.Id][0];
        updatedLead.CountryCode = 'FR';

        // Act: execute assign Country method
        Test.startTest();
        LeadCountryLayerService.enrichLeadsWithCountry(new List<Lead>{updatedLead}, 
            new Map<Id, Lead>{existingLead.Id => existingLead});
        update updatedLead;
        Test.stopTest();

        // Assert: verify Lead has lookup Country__c from France
        Lead updatedResult = [SELECT Country__c, CountryCode FROM Lead WHERE Id = :updatedLead.Id];
        System.assertEquals(france.Id, updatedResult.Country__c, 'Country__c lookup should be updated when CountryCode is changed');
        System.assertEquals('FR', updatedResult.CountryCode, 'CountryCode should show the change');
    }

    // ─── TEST: UPDATE Lead without change CountryCode (should not process) ─────────────────────
    @isTest
    static void testUpdateLeadWithoutChangingCountryCode() {
        // Arrange: create a Country__c with Alpha2Code = "ES"
        Country__c spain = new Country__c(
            Name = 'Spain',
            Alpha2Code__c = 'ES',
            Alpha3Code__c = 'ESP'
        );
        insert spain;

        Lead existingLead = new Lead(
            LastName = 'Test',
            CountryCode = 'ES',
            Company = 'Company', 
            Country__c = spain.Id
        );
        insert existingLead;

        // Change only LastName
        Lead updatedLead = [SELECT Id, LastName, CountryCode FROM Lead WHERE Id = :existingLead.Id][0];
        updatedLead.LastName = 'Updated';

        // Act: execute assign Country method
        Test.startTest();
        LeadCountryLayerService.enrichLeadsWithCountry(new List<Lead>{updatedLead}, 
            new Map<Id, Lead>{existingLead.Id => existingLead});
        update updatedLead;
        Test.stopTest();

        // Assert: verify Lead keep the same Country__c
        Lead updatedResult = [SELECT Country__c, CountryCode FROM Lead WHERE Id = :updatedLead.Id];
        System.assertEquals(spain.Id, updatedResult.Country__c, 'Country__c lookup should not change if CountryCode does not change');
        System.assertEquals('ES', updatedResult.CountryCode, 'CountryCode should not change');
    }

    // ─── TEST: BULK INSERT with some Leads ─────────────────────
    @isTest
    static void testBulkInsertWithValidAndInvalidCountryCodes() {
        // Arrange: create multiple Country__c
        Country__c spain = new Country__c(Name = 'Spain', Alpha2Code__c = 'ES', Alpha3Code__c = 'ESP');
        Country__c germany = new Country__c(Name = 'Germany', Alpha2Code__c = 'DE', Alpha3Code__c = 'DEU');
        insert new List<Country__c>{spain, germany};

        List<Lead> newLeads = new List<Lead>{
            new Lead(LastName = 'Lead1', Company = 'Company1', CountryCode = 'ES'),
            new Lead(LastName = 'Lead2', Company = 'Company2', CountryCode = 'DE'),
            new Lead(LastName = 'Lead3', Company = 'Company4', CountryCode = null)
        };

        // Act: execute assign Country method
        Test.startTest();
        LeadCountryLayerService.enrichLeadsWithCountry(newLeads, null);
        insert newLeads;
        Test.stopTest();

        // Assert: verify every Ledas has correct Country
        List<Lead> insertedLeads = [SELECT Id, Country__c, CountryCode FROM Lead WHERE Id IN :newLeads];

        for (Lead l : insertedLeads) {
            if (l.CountryCode == 'ES') {
                System.assertEquals(spain.Id, l.Country__c, 'Lead1 Country__c is not correct');
            } else if (l.CountryCode == 'DE') {
                System.assertEquals(germany.Id, l.Country__c, 'Lead2 Country__c is not correct');
            } else if (l.CountryCode == null) {
                System.assert(l.Country__c == null, 'Lead3 Country__c should not be assigned');
            }
        }
    }

    // ─── TEST: BULK UPDATE with some Leads ─────────────────────
    @isTest
    static void testBulkUpdateWithCountryCodeChanges() {
        // Arrange: create multiple Country__c
        Country__c spain = new Country__c(Name = 'Spain', Alpha2Code__c = 'ES', Alpha3Code__c = 'ESP');
        Country__c germany = new Country__c(Name = 'Germany', Alpha2Code__c = 'DE', Alpha3Code__c = 'DEU');
        Country__c france = new Country__c(Name = 'France', Alpha2Code__c = 'FR', Alpha3Code__c = 'FRA');
        insert new List<Country__c>{spain, germany, france};

        // Create some Leads
        List<Lead> existingLeads = new List<Lead>{
            new Lead(LastName = 'Lead1', Company = 'Company1', CountryCode = 'ES', Country__c = spain.Id),
            new Lead(LastName = 'Lead2', Company = 'Company2', CountryCode = 'ES', Country__c = spain.Id),
            new Lead(LastName = 'Lead3', Company = 'Company3', CountryCode = 'DE', Country__c = germany.Id),
            new Lead(LastName = 'Lead4', Company = 'Company4', CountryCode = null, Country__c = null)
        };
        insert existingLeads;

        // Changes of CountryCode
        Map<Id, Lead> oldLeadMap = new Map<Id, Lead>();
        List<Lead> updatedLeads = new List<Lead>();
        for (Lead l : [SELECT Id, CountryCode FROM Lead WHERE Id IN :existingLeads]) {
            Lead newVersion = new Lead();
            newVersion.Id = l.Id;
            oldLeadMap.put(l.Id, l);
            updatedLeads.add(newVersion);
        }

        List<String> updates = new List<String>{'FR', 'FR', 'FR', null};
        for (Integer i = 0; i < updatedLeads.size(); i++) {
            updatedLeads.get(i).CountryCode = updates.get(i);
        }

        // Act: execute assign Country method
        Test.startTest();
        LeadCountryLayerService.enrichLeadsWithCountry(updatedLeads, oldLeadMap);
        update updatedLeads;
        Test.stopTest();

        // Assert: verify every Lead has correct Country__c
        List<Lead> updatedResults = [SELECT Id, Country__c, CountryCode FROM Lead WHERE Id IN :updatedLeads];

        for (Lead l : updatedResults) {
            if (l.CountryCode == 'ES') {
                System.assertEquals(spain.Id, l.Country__c, 'Lead1 Country__c is not correct');
            } else if (l.CountryCode == 'DE') {
                System.assertEquals(germany.Id, l.Country__c, 'Lead2 Country__c is not correct');
            } else if (l.CountryCode == 'FR') {
                System.assertEquals(france.Id, l.Country__c, 'Lead3 Country__c is not correct');
            } else if (l.CountryCode == null) {
                System.assert(l.Country__c == null, 'Lead4 Country__c should not be assigned');
            }
        }
    }
}