/**
 * Schedulable class to schedule the CountryLayerSyncBatch.
 */
public class CountryLayerScheduler implements Schedulable 
{
    public void execute(SchedulableContext ctx) 
    {
        Database.executeBatch(new CountryLayerSyncBatch(), 50);
    }
}