/**
 * Batch class to sync countries from the CountryLayer API.
 */
public class CountryLayerSyncBatch implements Database.Batchable<CountrylayerService.CountryWrapper>, Database.AllowsCallouts, Database.Stateful 
{
    private List<CountrylayerService.CountryWrapper> apiCountries;
    private Boolean fetchError = false;
    private Integer upserted = 0;

    public Iterable<CountrylayerService.CountryWrapper> start(Database.BatchableContext bc) 
    {
        try 
        {
            apiCountries = CountrylayerService.fetchAllCountries();
        } catch (CountrylayerService.CountrylayerException e) 
        {
            System.debug('CountrySyncBatch fetch error: ' + e.getMessage());
            fetchError = true;
            apiCountries = new List<CountrylayerService.CountryWrapper>();
        }
        return apiCountries;
    }

    public void execute(Database.BatchableContext bc, List<CountrylayerService.CountryWrapper> scope) 
    {
        if (fetchError || scope.isEmpty()) return;

        List<Country__c> toUpsert = new List<Country__c>();
        for (CountrylayerService.CountryWrapper w : scope) 
        {
            if (String.isBlank(w.alpha2Code)) continue;

            toUpsert.add(new Country__c(
                Name                = w.name,
                Alpha2Code__c       = w.alpha2Code,
                Alpha3Code__c       = w.alpha3Code,
                Capital_City__c     = w.capital,
                Region__c           = w.region,
                Regional_Blocs__c   = w.regionalBlocs
            ));
        }
        if (!toUpsert.isEmpty()) 
        {
            List<Database.UpsertResult> results = Database.upsert(toUpsert, Country__c.Alpha2Code__c, false);
            for (Database.UpsertResult r : results) 
            {
                if (r.isSuccess()) upserted++;
            }
        }
    }

    public void finish(Database.BatchableContext bc) 
    {
        if (fetchError) 
        {
            System.debug('CountryLayerSyncBatch finished with fetch error.');
        } else 
        {
            System.debug('CountryLayerSyncBatch finished successfully. Records upserted/updated: ' + upserted);
        }
    }
}