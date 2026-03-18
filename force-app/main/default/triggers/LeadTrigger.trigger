/**
 * Lead Apex Trigger to execute functionalities depending the context
 */
trigger LeadTrigger on Lead (before insert, before update) 
{
    if (Trigger.isBefore)
    {
        if (Trigger.isInsert) LeadTriggerHandle.onBeforeInsert(Trigger.new);
        if (Trigger.isUpdate) LeadTriggerHandle.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
}