/**
 * Test class for CountryLayerService.
 */
@isTest
public class CountryLayerServiceTest {

    // ─── FETCH: HTTP OK ───────────────────────────────────────────────────
    @isTest
    static void testFetchAllCountriesSuccess() {
        Test.setMock(HttpCalloutMock.class, new CountryMockHttp(200, getFullJson()));

        Test.startTest();
        List<CountryLayerService.CountryWrapper> result = 
            CountryLayerService.fetchAllCountries();
        Test.stopTest();

        Assert.areEqual(1, result.size());
        Assert.areEqual('Spain', result[0].name);
        Assert.areEqual('ES', result[0].alpha2Code);
        Assert.areEqual('EU', result[0].regionalBlocs);
    }

    // ─── FETCH: HTTP 401 ─────────────────────────────────────────────────
    @isTest
    static void testFetchAllCountriesHttp401() {
        Test.setMock(HttpCalloutMock.class, new CountryMockHttp(401, '{"message":"Invalid access key"}'));

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            CountryLayerService.fetchAllCountries();
            Assert.fail('Expected CountryLayerException');
        } catch (CountryLayerService.CountryLayerException e) {
            exceptionThrown = true;
            Assert.isTrue(e.getMessage().contains('401'));
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown);
    }

    // ─── FETCH: HTTP 500 ─────────────────────────────────────────────────
    @isTest
    static void testFetchAllCountriesHttp500() {
        Test.setMock(HttpCalloutMock.class, new CountryMockHttp(500, 'Server Error'));

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            CountryLayerService.fetchAllCountries();
            Assert.fail('Expected CountryLayerException');
        } catch (CountryLayerService.CountryLayerException e) {
            exceptionThrown = true;
            Assert.isTrue(e.getMessage().contains('500'));
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown);
    }

    // ─── PARSE: JSON completo con todos los campos ────────────────────────
    @isTest
    static void testParseResponseFullFields() {
        Test.startTest();
        List<CountryLayerService.CountryWrapper> result = 
            CountryLayerService.parseResponse(getFullJson());
        Test.stopTest();

        Assert.areEqual(1, result.size());
        CountryLayerService.CountryWrapper w = result[0];

        // Strings simples
        Assert.areEqual('Spain',           w.name);
        Assert.areEqual('ES',              w.alpha2Code);
        Assert.areEqual('ESP',             w.alpha3Code);
        Assert.areEqual('Madrid',          w.capital);
        Assert.areEqual('Europe',          w.region);
        Assert.areEqual('Southern Europe', w.subregion);
        Assert.areEqual('España',          w.nativeName);
        Assert.areEqual('724',             w.numericCode);
        Assert.areEqual('Spanish',         w.demonym);
        Assert.areEqual('ESP',             w.cioc);

        // Números
        Assert.areEqual(46736776,          w.population);
        Assert.areEqual(505992.0,          w.area);
        Assert.areEqual(35.9,              w.gini);

        // Lat/Lng
        Assert.areEqual(40.0,              w.latitude);
        Assert.areEqual(-4.0,              w.longitude);

        // Listas
        Assert.areEqual('34',             w.callingCodes);
        Assert.areEqual('.es',            w.topLevelDomain);
        Assert.areEqual('EU',             w.regionalBlocs);
        Assert.areEqual('EUR - Euro (€)', w.currencies);
        Assert.areEqual('Spanish',        w.languages);
    }

    // ─── PARSE: Campos null ───────────────────────────────────────────────
    @isTest
    static void testParseResponseNullSimpleFields() {
        String json = '[{"alpha2Code":"NI","name":"NullIsland",' +
            '"capital":null,"region":null,"subregion":null,' +
            '"nativeName":null,"numericCode":null,"demonym":null,' +
            '"flag":null,"cioc":null,"population":null,' +
            '"area":null,"gini":null,"latlng":null}]';

        Test.startTest();
        List<CountryLayerService.CountryWrapper> result = 
            CountryLayerService.parseResponse(json);
        Test.stopTest();

        Assert.areEqual(1, result.size());
        CountryLayerService.CountryWrapper w = result[0];
        Assert.isNull(w.capital);
        Assert.isNull(w.region);
        Assert.isNull(w.subregion);
        Assert.isNull(w.nativeName);
        Assert.isNull(w.numericCode);
        Assert.isNull(w.demonym);
        Assert.isNull(w.flag);
        Assert.isNull(w.cioc);
        Assert.isNull(w.population);
        Assert.isNull(w.area);
        Assert.isNull(w.gini);
        Assert.isNull(w.latitude);
        Assert.isNull(w.longitude);
    }

    // ─── PARSE: Listas null ───────────────────────────────────────────────
    @isTest
    static void testParseResponseNullLists() {
        String json = '[{"alpha2Code":"NL","name":"NullLists",' +
            '"callingCodes":null,"topLevelDomain":null,"altSpellings":null,' +
            '"borders":null,"timezones":null,"currencies":null,' +
            '"languages":null,"regionalBlocs":null}]';

        Test.startTest();
        List<CountryLayerService.CountryWrapper> result = 
            CountryLayerService.parseResponse(json);
        Test.stopTest();

        CountryLayerService.CountryWrapper w = result[0];
        Assert.areEqual('', w.callingCodes);
        Assert.areEqual('', w.topLevelDomain);
        Assert.areEqual('', w.altSpellings);
        Assert.areEqual('', w.borders);
        Assert.areEqual('', w.timezones);
        Assert.areEqual('', w.currencies);
        Assert.areEqual('', w.languages);
        Assert.areEqual('', w.regionalBlocs);
    }

    // ─── PARSE: Listas vacías [] ──────────────────────────────────────────
    @isTest
    static void testParseResponseEmptyLists() {
        String json = '[{"alpha2Code":"EL","name":"EmptyLists",' +
            '"callingCodes":[],"topLevelDomain":[],"altSpellings":[],' +
            '"borders":[],"timezones":[],"currencies":[],' +
            '"languages":[],"regionalBlocs":[]}]';

        Test.startTest();
        List<CountryLayerService.CountryWrapper> result = 
            CountryLayerService.parseResponse(json);
        Test.stopTest();

        CountryLayerService.CountryWrapper w = result[0];
        Assert.areEqual('', w.callingCodes);
        Assert.areEqual('', w.topLevelDomain);
        Assert.areEqual('', w.borders);
        Assert.areEqual('', w.regionalBlocs);
        Assert.areEqual('', w.currencies);
        Assert.areEqual('', w.languages);
    }

    // ─── PARSE: Campos faltantes en JSON (no existen en el Map) ──────────
    @isTest
    static void testParseResponseMissingFields() {
        String json = '[{"alpha2Code":"MF","name":"MissingFields"}]';

        Test.startTest();
        List<CountryLayerService.CountryWrapper> result = 
            CountryLayerService.parseResponse(json);
        Test.stopTest();

        Assert.areEqual(1, result.size());
        CountryLayerService.CountryWrapper w = result[0];
        Assert.areEqual('MF',            w.alpha2Code);
        Assert.areEqual('MissingFields', w.name);
        Assert.isNull(w.capital);
        Assert.isNull(w.region);
        Assert.isNull(w.population);
        Assert.isNull(w.area);
        Assert.isNull(w.latitude);
        Assert.areEqual('', w.callingCodes);
        Assert.areEqual('', w.regionalBlocs);
        Assert.areEqual('', w.currencies);
    }

    // ─── PARSE: Múltiples países ──────────────────────────────────────────
    @isTest
    static void testParseResponseMultipleCountries() {
        Test.startTest();
        List<CountryLayerService.CountryWrapper> result = 
            CountryLayerService.parseResponse(getMultipleJson());
        Test.stopTest();

        Assert.areEqual(3, result.size());
        Assert.areEqual('ES', result[0].alpha2Code);
        Assert.areEqual('FR', result[1].alpha2Code);
        Assert.areEqual('DE', result[2].alpha2Code);
    }

    // ─── PARSE: JSON vacío [] ─────────────────────────────────────────────
    @isTest
    static void testParseResponseEmptyArray() {
        Test.startTest();
        List<CountryLayerService.CountryWrapper> result = 
            CountryLayerService.parseResponse('[]');
        Test.stopTest();

        Assert.areEqual(0, result.size());
    }

    // ─── PARSE: JSON null ─────────────────────────────────────────────────
    @isTest
    static void testParseResponseNullBody() {
        Test.startTest();
        List<CountryLayerService.CountryWrapper> result = 
            CountryLayerService.parseResponse(null);
        Test.stopTest();

        Assert.areEqual(0, result.size());
    }

    // ─── PARSE: JSON inválido ─────────────────────────────────────────────
    @isTest
    static void testParseResponseInvalidJson() {
        Test.startTest();
        List<CountryLayerService.CountryWrapper> result = 
            CountryLayerService.parseResponse('{invalid}');
        Test.stopTest();

        Assert.areEqual(0, result.size());
    }

    // ─── PARSE: latlng con menos de 2 elementos ───────────────────────────
    @isTest
    static void testParseResponsePartialLatlng() {
        String json = '[{"alpha2Code":"PT","name":"Test","latlng":[39.5]}]';

        Test.startTest();
        List<CountryLayerService.CountryWrapper> result = 
            CountryLayerService.parseResponse(json);
        Test.stopTest();

        Assert.isNull(result[0].latitude);
        Assert.isNull(result[0].longitude);
    }

    // ─── JSON HELPERS ──────────────────────────────────────────────────────
    private static String getFullJson() {
        return '[{"name":"Spain","alpha2Code":"ES","alpha3Code":"ESP",' +
            '"capital":"Madrid","region":"Europe","subregion":"Southern Europe",' +
            '"nativeName":"España","numericCode":"724","demonym":"Spanish",' +
            '"cioc":"ESP","population":46736776,"area":505992.0,"gini":35.9,' +
            '"latlng":[40.0,-4.0],"callingCodes":["34"],"topLevelDomain":[".es"],' +
            '"altSpellings":["ES"],"borders":["AND","FRA"],"timezones":["UTC+01:00"],' +
            '"currencies":[{"code":"EUR","name":"Euro","symbol":"€"}],' +
            '"languages":[{"name":"Spanish"}],' +
            '"regionalBlocs":[{"acronym":"EU"}]}]';
    }

    private static String getMultipleJson() {
        return '[{"name":"Spain","alpha2Code":"ES","regionalBlocs":[{"acronym":"EU"}]},' +
            '{"name":"France","alpha2Code":"FR","regionalBlocs":[{"acronym":"EU"}]},' +
            '{"name":"Germany","alpha2Code":"DE","regionalBlocs":[{"acronym":"EU"}]}]';
    }

    // ─── MOCK HTTP ──────────────────────────────────────────────────────────
    private class CountryMockHttp implements HttpCalloutMock {
        private Integer statusCode;
        private String body;

        public CountryMockHttp(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.statusCode);
            res.setBody(this.body);
            return res;
        }
    }
}