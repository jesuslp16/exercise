/**
 * Lead Apex Trigger to execute functionalities depending the context
 */
trigger LeadTrigger on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    TriggerFactory.execute(new LeadTriggerHandler());
}