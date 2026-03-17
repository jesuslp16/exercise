/**
 * Test class for CountryLayerSyncBatch.
 */
@isTest
public class CountryLayerSyncBatchTest 
{
    @isTest
    static void testBatchUpsertNewCountries() 
    {
        Test.setMock(HttpCalloutMock.class, new CountryMockHttp(200, getTestJson()));
        
        Test.startTest();
        Database.executeBatch(new CountryLayerSyncBatch(), 50);
        Test.stopTest();
        
        List<Country__c> countries = [SELECT Alpha2Code__c, Name, Regional_Blocs__c FROM Country__c];
        Assert.areEqual(3, countries.size());
        Assert.areEqual('ES', countries[0].Alpha2Code__c);
        Assert.areEqual('Spain', countries[0].Name);
        Assert.areEqual('EU, USA', countries[0].Regional_Blocs__c);
    }

    @isTest
    static void testBatchUpdateExisting() 
    {
        // Create existing country
        insert new Country__c(Name = 'Spain', Alpha2Code__c = 'ES', Alpha3Code__c = 'ESP', Capital_City__c = 'Old');
        
        Test.setMock(HttpCalloutMock.class, new CountryMockHttp(200, getTestJson()));
        
        Test.startTest();
        Database.executeBatch(new CountryLayerSyncBatch(), 50);
        Test.stopTest();
        
        Country__c spain = [SELECT Capital_City__c FROM Country__c WHERE Alpha2Code__c = 'ES'];
        Assert.areEqual('Madrid', spain.Capital_City__c); // Updated
    }

    @isTest
    static void testBatchUpsertError() 
    {
        Test.setMock(HttpCalloutMock.class, new CountryMockHttp(500, 'Error'));
        
        Test.startTest();
        Database.executeBatch(new CountryLayerSyncBatch(), 50);
        Test.stopTest();
        
        List<Country__c> countries = [SELECT Alpha2Code__c FROM Country__c];
        Assert.areEqual(0, countries.size()); // Nothing was inserted
    }

    @isTest
    static void testBatchPartialUpsert() 
    {
        Test.setMock(HttpCalloutMock.class, new CountryMockHttp(200, getPartialJson()));
        
        Test.startTest();
        Database.executeBatch(new CountryLayerSyncBatch(), 50);
        Test.stopTest();
        
        List<Country__c> countries = [SELECT Alpha2Code__c FROM Country__c];
        Assert.areEqual(1, countries.size()); // Only the country with Alpha2Code
    }

    // ─── JSON helpers ───────────────────────────────────────────────────
    private static String getTestJson()
    {
        return '[{"name":"Spain","alpha2Code":"ES","alpha3Code":"ESP","capital":"Madrid","region":"Europe","regionalBlocs":[{"acronym":"EU"}, {"acronym":"USA"}]},{"name":"France","alpha2Code":"FR","alpha3Code":"FRA","capital":"Paris","region":"Europe","regionalBlocs":[{"acronym":"EU"}]},{"name":"Germany","alpha2Code":"DE","alpha3Code":"DEU","capital":"Berlin","region":"Europe","regionalBlocs":[{"acronym":"EU"}]}]';
    }

    private static String getPartialJson() 
    {
        return '[{"name":"Valid","alpha2Code":"VA","alpha3Code":"VAL","capital":"Valid","region":"Test","regionalBlocs":[]},{"name":"Invalid","alpha3Code":"INV","capital":"Invalid","region":"Test"}]';
    }

    private class CountryMockHttp implements HttpCalloutMock 
    {
        private Integer statusCode;
        private String body;
        public CountryMockHttp(Integer statusCode, String body) 
        {
            this.statusCode = statusCode;
            this.body = body;
        }
        public HttpResponse respond(HttpRequest req) 
        {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(body);
            return res;
        }
    }
}