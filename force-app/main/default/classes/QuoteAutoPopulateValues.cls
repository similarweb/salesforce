/**
 * Description 		:	Autopopulates Quote Is_US_customer__c field based on zqu__SoldToContact__c
 * Usage			:	Set as custom Populate Value Plugin for Zuora's CreateQuote component.
 * Created By 		:	Victoria Khanchevskaya from Synebo Nov'18
 *
 */
global class QuoteAutoPopulateValues extends zqu.CreateQuoteController.PopulateDefaultFieldValuePlugin {
  global override void populateDefaultFieldValue(
    SObject record,
    zqu.PropertyComponentController.ParentController pcc
  ) {
    /* Id contactId; 
        if(!Test.isRunningTest()){
            super.populateDefaultFieldValue(record, pcc);
        }
        else{ 
            contactId = (Id)record.get('zqu__SoldToContact__c');
        }
        zqu.LookupComponentOptions soldToOptions  = super.getLookupOption('zqu__SoldToContact__c');    
        if(soldToOptions != null){
            contactId = soldToOptions.targetId;
        }
        if(contactId != null && String.isBlank(String.valueOf(record.get('Is_US_customer__c')))){
            List<Contact>contacts = [SELECT Id, Name, Country_registration__c, Country_Code__c,MailingCountry FROM Contact WHERE Id = :contactId]; 
            if(contacts[0].MailingCountry == 'United States'){
                record.put('Is_US_customer__c', 'United States');
            }
            else if(contacts[0].MailingCountry != null){
                record.put('Is_US_customer__c', 'ROW');
            }
        } */
  }
}
