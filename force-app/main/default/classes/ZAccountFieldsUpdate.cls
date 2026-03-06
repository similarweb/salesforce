public class ZAccountFieldsUpdate implements Queueable, Database.AllowsCallouts{ 
    
    private Set<Id> quoteIds;
    @testVisible
    private ZuoraApiService apiService;

    public ZAccountFieldsUpdate(Set<Id> quoteIds){
        this.apiService = new ZuoraApiService();
        this.quoteIds = quoteIds;
    }
    
    public void execute(QueueableContext context) {
        List<zqu__Quote__c> quotes = [
            SELECT 
                zqu__ZuoraAccountID__c,
                zqu__Certificate_ID__c
            FROM 
                zqu__Quote__c 
            WHERE Id IN :quoteIds
        ];

        if(quotes.size() > 0){
            for(zqu__Quote__c quote : quotes){
                String accountId = quote.zqu__ZuoraAccountID__c;
                String certificateId = quote.zqu__Certificate_ID__c;
                this.updateZuoraAccountCertificateId(accountId, certificateId);
            }
        }
    }

    private void updateZuoraAccountCertificateId(String accountId, String certificateId){
        Boolean isSuccess = apiService.updateAccountCertificateId(accountId, certificateId);
        if(isSuccess == false){
            throw new ZAccountFieldsUpdateException('Update of the Zuora Account failed');
        }
    }

    public class ZAccountFieldsUpdateException extends Exception {}
}