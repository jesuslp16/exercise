/**
 * Class to implement the TriggerFactory pattern.
 */
public class TriggerFactory 
{
    /**
     * Main method that routes the trigger context to the corresponding handler
     */
    public static void execute(ITriggerHandler handler) 
    {
        if (!Trigger.isExecuting) 
        {
            throw new TriggerFactoryException('TriggerFactory must be called from a Trigger context');
        }

        if (Trigger.isBefore) 
        {
            if (Trigger.isInsert) handler.beforeInsert(Trigger.new);
            if (Trigger.isUpdate) handler.beforeUpdate(Trigger.new, Trigger.oldMap);
            if (Trigger.isDelete) handler.beforeDelete(Trigger.old);
        }

        if (Trigger.isAfter) 
        {
            if (Trigger.isInsert)   handler.afterInsert(Trigger.new);
            if (Trigger.isUpdate)   handler.afterUpdate(Trigger.new, Trigger.oldMap);
            if (Trigger.isDelete)   handler.afterDelete(Trigger.old);
            if (Trigger.isUndelete) handler.afterUndelete(Trigger.new);
        }
    }

    public class TriggerFactoryException extends Exception {}
}
