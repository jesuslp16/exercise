/**
 * Class to handle with the different context in the Lead Trigger
 */
public class LeadTriggerHandler implements ITriggerHandler 
{
    // ─── BEFORE ──────────────────────────────────────────────────────────
    public void beforeInsert(List<SObject> newRecords) 
    {
        LeadCountryLayerService.enrichLeadsWithCountry((List<Lead>) newRecords, null);
    }

    public void beforeUpdate(List<SObject> newRecords, Map<Id, SObject> oldMap) 
    {
        LeadCountryLayerService.enrichLeadsWithCountry((List<Lead>) newRecords, (Map<Id, Lead>) oldMap);
    }

    public void beforeDelete(List<SObject> oldRecords) {}

    // ─── AFTER ───────────────────────────────────────────────────────────
    public void afterInsert(List<SObject> newRecords) {}

    public void afterUpdate(List<SObject> newRecords, Map<Id, SObject> oldMap) {}

    public void afterDelete(List<SObject> oldRecords) {}

    public void afterUndelete(List<SObject> newRecords) {}
}
