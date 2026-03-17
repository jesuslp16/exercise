/**
 * Service class to interact with the CountryLayer API.
 */
public class CountryLayerService 
{
    private static final String NAMED_CREDENTIAL = 'callout:CountryLayer_API';

    public static List<CountryWrapper> fetchAllCountries() 
    {
        String apiKey = CountrylayerConfig__mdt.getInstance('API_Settings').API_Key__c;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(NAMED_CREDENTIAL + '/all?access_key=' + apiKey);
        req.setMethod('GET');
        req.setTimeout(120000);

        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() != 200) 
        {
            throw new CountryLayerException(
                'API Error: ' + res.getStatusCode() + ' ' + res.getBody()
            );
        }
        return parseResponse(res.getBody());
    }

    @TestVisible
    public static List<CountryWrapper> parseResponse(String jsonBody) 
    {
        // ─── Check BEFORE parse ──────────────────────────────────────
        if (String.isBlank(jsonBody)) 
        {
            return new List<CountryWrapper>();
        }

        List<Object> rawList;
        try 
        {
            rawList = (List<Object>) JSON.deserializeUntyped(jsonBody);
        } catch (Exception e) 
        {
            System.debug('JSON parse error: ' + e.getMessage());
            return new List<CountryWrapper>();
        }

        if (rawList == null || rawList.isEmpty()) 
        {
            return new List<CountryWrapper>();
        }

        List<CountryWrapper> countries = new List<CountryWrapper>();
        for (Object item : rawList) 
        {
            Map<String, Object> c = (Map<String, Object>) item;
            CountryWrapper w = new CountryWrapper();

            // ─── Simple fields ───────────────────────────────────────────
            w.name          = (String)  c.get('name');
            w.alpha2Code    = (String)  c.get('alpha2Code');
            w.alpha3Code    = (String)  c.get('alpha3Code');
            w.capital       = (String)  c.get('capital');
            w.region        = (String)  c.get('region');
            w.subregion     = (String)  c.get('subregion');
            w.nativeName    = (String)  c.get('nativeName');
            w.numericCode   = (String)  c.get('numericCode');
            w.demonym       = (String)  c.get('demonym');
            w.flag          = (String)  c.get('flag');
            w.cioc          = (String)  c.get('cioc');
            w.population    = (Integer) c.get('population');
            w.area          = (c.get('area') != null) ? Double.valueOf(String.valueOf(c.get('area'))) : null;
            w.gini          = (c.get('gini') != null) ? Double.valueOf(String.valueOf(c.get('gini'))) : null;

            // ─── callingCodes: List<String> ───────────────────────────────
            List<String> callingCodes = new List<String>();
            if (c.get('callingCodes') != null) 
            {
                for (Object cc : (List<Object>) c.get('callingCodes')) 
                {
                    if (cc != null && String.isNotBlank((String) cc)) 
                    {
                        callingCodes.add((String) cc);
                    }
                }
            }
            w.callingCodes = String.join(callingCodes, ', ');

            // ─── topLevelDomain: List<String> ─────────────────────────────
            List<String> tlds = new List<String>();
            if (c.get('topLevelDomain') != null) 
            {
                for (Object tld : (List<Object>) c.get('topLevelDomain')) 
                {
                    tlds.add((String) tld);
                }
            }
            w.topLevelDomain = String.join(tlds, ', ');

            // ─── altSpellings: List<String> ───────────────────────────────
            List<String> spellings = new List<String>();
            if (c.get('altSpellings') != null) 
            {
                for (Object sp : (List<Object>) c.get('altSpellings')) 
                {
                    spellings.add((String) sp);
                }
            }
            w.altSpellings = String.join(spellings, ', ');

            // ─── borders: List<String> ────────────────────────────────────
            List<String> borders = new List<String>();
            if (c.get('borders') != null) {
                for (Object b : (List<Object>) c.get('borders'))
                 {
                    borders.add((String) b);
                }
            }
            w.borders = String.join(borders, ', ');

            // ─── timezones: List<String> ──────────────────────────────────
            List<String> timezones = new List<String>();
            if (c.get('timezones') != null) {
                for (Object tz : (List<Object>) c.get('timezones')) 
                {
                    timezones.add((String) tz);
                }
            }
            w.timezones = String.join(timezones, ', ');

            // ─── latlng: List<Double> ─────────────────────────────────────
            if (c.get('latlng') != null) {
                List<Object> latlng = (List<Object>) c.get('latlng');
                if (latlng.size() >= 2) {
                    w.latitude  = Double.valueOf(String.valueOf(latlng[0]));
                    w.longitude = Double.valueOf(String.valueOf(latlng[1]));
                }
            }

            // ─── currencies: List<{code, name, symbol}> ───────────────────
            List<String> currencies = new List<String>();
            if (c.get('currencies') != null) 
            {
                for (Object cur : (List<Object>) c.get('currencies')) 
                {
                    Map<String, Object> curMap = (Map<String, Object>) cur;
                    String code   = curMap.get('code')   != null ? (String) curMap.get('code')   : '';
                    String cname  = curMap.get('name')   != null ? (String) curMap.get('name')   : '';
                    String symbol = curMap.get('symbol') != null ? (String) curMap.get('symbol') : '';
                    currencies.add(code + ' - ' + cname + ' (' + symbol + ')');
                }
            }
            w.currencies = String.join(currencies, '; ');

            // ─── languages: List<{iso639_1, iso639_2, name, nativeName}> ──
            List<String> languages = new List<String>();
            if (c.get('languages') != null) 
            {
                for (Object lang : (List<Object>) c.get('languages')) 
                {
                    Map<String, Object> langMap = (Map<String, Object>) lang;
                    if (langMap.get('name') != null) 
                    {
                        languages.add((String) langMap.get('name'));
                    }
                }
            }
            w.languages = String.join(languages, ', ');

            // ─── regionalBlocs: List<{acronym, name, ...}> ────────────────
            List<String> blocs = new List<String>();
            if (c.get('regionalBlocs') != null) 
            {
                for (Object bloc : (List<Object>) c.get('regionalBlocs')) 
                {
                    Map<String, Object> blocMap = (Map<String, Object>) bloc;
                    if (blocMap.get('acronym') != null) 
                    {
                        blocs.add((String) blocMap.get('acronym'));
                    }
                }
            }
            w.regionalBlocs = String.join(blocs, ', ');

            countries.add(w);
        }
        return countries;
    }

    // ─── WRAPPER (All fields from API) ─────────────────────────────
    public class CountryWrapper 
    {
        // Simples
        public String  name;
        public String  alpha2Code;
        public String  alpha3Code;
        public String  capital;
        public String  region;
        public String  subregion;
        public String  nativeName;
        public String  numericCode;
        public String  demonym;
        public String  flag;
        public String  cioc;
        public Integer population;
        public Double  area;
        public Double  gini;
        public Double  latitude;
        public Double  longitude;
        // Concatenated
        public String  callingCodes;
        public String  topLevelDomain;
        public String  altSpellings;
        public String  borders;
        public String  timezones;
        public String  currencies;
        public String  languages;
        public String  regionalBlocs;
    }

    public class CountryLayerException extends Exception {}
}