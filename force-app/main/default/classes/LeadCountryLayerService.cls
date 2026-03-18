/**
 * Class with the logic to assign the Country__c lookup value depending if the Country field is filled
 * in Insert or Update the Lead and match Alpha2Code from an existing Country__c record
 */
public class LeadCountryLayerService {

    /**
     * Method to fill the Country__c lookup field with the Country__c record in case the CountryCode
     * has been changed from insert or update the Lead, and also it is found as Alpha2Code in Country__c records
    */
    public static void enrichLeadsWithCountry(List<Lead> newLeads, Map<Id, Lead> oldMap) 
    {
        List<Lead> leadsToProcess = new List<Lead>();

        //Filter the Leads without CountryCode to remove the relationship to Country__c
        for (Lead l : newLeads)
        {
            if (l.CountryCode == null) 
            {
                l.Country__c = null;
            }
            else 
            {
                leadsToProcess.add(l);    
            }
        }

        Set<String> alpha2Codes = getChangedCountryCodes(leadsToProcess, oldMap);
        
        if (alpha2Codes.isEmpty()) return;

        Map<String, Country__c> countryByCode = getCountriesByCodes(alpha2Codes);

        for (Lead l : leadsToProcess) 
        {
            // Only process with matching if the CountryCode is new or changed
            Boolean isNew     = (oldMap == null);
            Boolean isChanged = (!isNew && l.CountryCode != oldMap.get(l.Id)?.CountryCode);
            if (!isNew && !isChanged) continue;

            Country__c match = countryByCode.get(l.CountryCode.toUpperCase());
            l.Country__c = (match != null) ? match.Id : null;
        }
    }

    /**
     * Auxiliar method to retrieve the CountryCodes to be searched as Alpha2Code in Country__c records
     */
    private static Set<String> getChangedCountryCodes(List<Lead> newLeads, Map<Id, Lead> oldMap) 
    {
        Set<String> codes = new Set<String>();

        for (Lead l : newLeads) 
        {
            Boolean isNew     = (oldMap == null);
            Boolean isChanged = (!isNew && l.CountryCode != oldMap.get(l.Id)?.CountryCode);

            if (isNew || isChanged && !String.isBlank(l.CountryCode)) 
            {
                codes.add(l.CountryCode.toUpperCase());
            }
        }
        return codes;
    }

    /**
     * Auxiliar method to retrieve Country__c records with Alpha2Code if matches with CountryCode from Leads
     */
    private static Map<String, Country__c> getCountriesByCodes(Set<String> codes) 
    {
        Map<String, Country__c> result = new Map<String, Country__c>();
        
        for (Country__c c : [SELECT Id, Alpha2Code__c FROM Country__c WHERE Alpha2Code__c IN :codes]) 
        {
            result.put(c.Alpha2Code__c.toUpperCase(), c);
        }
        return result;
    }
}