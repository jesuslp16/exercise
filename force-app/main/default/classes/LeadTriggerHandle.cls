/**
 * Class to handle with the different context in the Lead Trigger
 */
public class LeadTriggerHandle 
{
    public static void onBeforeInsert(List<Lead> newLeads)
    {
        LeadCountryLayerService.enrichLeadsWithCountry(newLeads, null);
    }

    public static void onBeforeUpdate(List<Lead> newLeads, Map<Id, Lead> oldMap) 
    {
        LeadCountryLayerService.enrichLeadsWithCountry(newLeads, oldMap);
    }
}