global with sharing class CloudiusWS {
    global class Result {
        webservice Boolean success{get;set;}
        webservice String message{get;set;}
        webservice String page{get;set;} // page is either url or actaul html
    }
    public static Result success(String msg) {
        Result r = new Result(); 
        r.success=true;
        r.message=msg;
        return r;
    }
    public static Result fail(String msg) {
        Result r = new Result(); 
        r.success=false;
        r.message=msg;
        return r;
    }
    public static Result loadPage(String html) {
        Result r = success('html');
        r.page = html;
        return r;
    }
    
    public static Result loadURL(String urlStr) {
        Result r = success('url');
        r.page = urlStr;
        return r;
    }
    webservice static Result CheckBillingAccount(Id oppId) {
    	return CheckBillingAccountBasic(oppId,false);
    }
    public static Account getBillingAccountBasic(Id oppId) {
    	list<Opportunity> lo = [SELECT Id,AccountId FROM Opportunity WHERE Id=:oppId];
        if ( lo.size() == 0 || lo[0].AccountId==null ) return null;//fail('Opportunity not exists or missing account');
       list<Account> la = [SELECT Id,(SELECT Id,Zuora__DefaultPaymentMethod__c FROM R00N40000001kyLcEAI WHERE Zuora__DefaultPaymentMethod__c !=null ORDER BY lastModifiedDate DESC LIMIT 1) FROM Account WHERE Id=:lo[0].AccountId];
        return la.size()>0?la[0]:null;
    }
    webservice static Result CheckBillingAccountBasic(Id oppId,Boolean forcePositive) {
        //list<Opportunity> lo = [SELECT Id,AccountId FROM Opportunity WHERE Id=:oppId];
        //if ( lo.size() == 0 || lo[0].AccountId==null ) return fail('Opportunity not exists or missing account');
        //Account a = [SELECT Id,(SELECT Id,Zuora__DefaultPaymentMethod__c FROM R00N40000001kyLcEAI WHERE Zuora__DefaultPaymentMethod__c !=null ORDER BY lastModifiedDate DESC LIMIT 1) FROM Account WHERE Id=:lo[0].AccountId];
        Account a = getBillingAccountBasic(oppId);
        if ( a == null ) return fail('Opportunity not exists or missing account');
        System.debug('Account found: '+JSON.serializePretty(a));
        if(Test.isRunningTest() && !forcePositive){
            return loadPage('');
        }
        Organization org = [SELECT InstanceName from Organization LIMIT 1];
        String redirectUrl = (URL.getOrgDomainUrl().toExternalForm().split('\\.')[0] +'--zqu.'+ org.InstanceName +'.visual.force.com' + Label.autoRedirect).replace('[OppId]',String.valueof(oppId)).replace('[AccId]',string.valueof(a.id));
        if ( a.R00N40000001kyLcEAI__r.size() == 0 || forcePositive){
            return loadURL(redirectUrl);
        }
        PageReference pr = new PageReference('/apex/QuoteDialog?id='+String.valueof(a.R00N40000001kyLcEAI__r[0].Id));
        System.debug('prpr ' + pr);
        return loadPage(Test.isRunningTest()?'':fixRedirect(pr.getContent().toString(),redirectUrl));
    }
    
    private static String fixRedirect(String html, String redirectLink){
        String fixedHtml = html.replace('redirect()', 'redirect(\'' + redirectLink +'\')');
        return fixedHtml;
    } 
    
}