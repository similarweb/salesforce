public with sharing class AccountHierarchyDataCtrl {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getHierarchyData(String parentCompanyDomain,String websiteDomain, String accountId) {
        System.debug('started---' + parentCompanyDomain);
        Map<String, Object> hierarchyMap = new Map<String, Object>();
        handleSums(parentCompanyDomain,websiteDomain, hierarchyMap);

//        AccountHierarchy accountHierarchy = handleHierarchyAccounts(accountId);
//        System.debug('accountHierarchy--' + accountHierarchy);
        Map<Id,AccountMapObj> accountIdToRelationMap = new Map<Id, AccountHierarchyDataCtrl.AccountMapObj>();
        queryMainAccount(accountId,accountIdToRelationMap);
//        hierarchyMap.put('gridDataFromApex',convertToHierarchy(accountIdToRelationMap));
        hierarchyMap.put('gridDataFromApex',convertToHierarchy(accountIdToRelationMap));

//        hierarchyMap.put('gridData', transformToMap(accountHierarchy,new Set<Id>()));

        return hierarchyMap;
    }

    public static Map<String,Object> convertToHierarchy(Map<Id,AccountMapObj> accountIdToRelationMap){
        Map<String,Object> returnObj = new Map<String, Object>();
        for(AccountMapObj accountMapObj : accountIdToRelationMap.values()){
            if(accountMapObj.isTopParentAccount){
                returnObj = populateAll(accountMapObj,accountIdToRelationMap,true,true);
                break;
            }
        }
        return returnObj;
    }

    private static Map<String, Object> populateAll(AccountMapObj accountMapObj,Map<Id,AccountMapObj> accountIdToRelationMap,boolean isTopParent , boolean isExposed) {
        Map<String, Object> returnObj = new Map<String, Object>();
        returnObj.put('Id', accountMapObj.currentAccount.Id);
        returnObj.put('Name', accountMapObj.currentAccount.Name);
        returnObj.put('Status__c', accountMapObj.currentAccount.Status__c);
        returnObj.put('BillingCountry', accountMapObj.currentAccount.BillingCountry);
        returnObj.put('Number_of_Open_Opps__c', accountMapObj.currentAccount.Number_of_Open_Opps__c);
        returnObj.put('Website', accountMapObj.currentAccount.Website);
        returnObj.put('LastActivityDate', accountMapObj.currentAccount.LastActivityDate);
        returnObj.put('OwnerName', accountMapObj.currentAccount.Owner.Name); // Note: You may need to fetch the owner name separately
        returnObj.put('Base_Product__c', accountMapObj.currentAccount.Base_Product__c);
        returnObj.put('isExposed',isExposed);
        if(!accountMapObj.childAccounts.isEmpty()){
            isExposed = isTopParent;
            isTopParent = false;
            List<Map<String,Object>> children = new List<Map<String, Object>>();
            for(Account childAccount : accountMapObj.childAccounts){
                children.add(populateAll(accountIdToRelationMap.get(childAccount.Id),accountIdToRelationMap,isTopParent,isExposed));
            }
            returnObj.put('_children',children);
        }
        return returnObj;
    }


    public static void queryMainAccount(String accountId , Map<Id,AccountMapObj> accountIdToRelationMap){
        Account accountWithParentsAndChildren = [
                SELECT Id, Name, Status__c, Number_of_Open_Opps__c, Website, LastActivityDate, Owner.Name, Base_Product__c, BillingCountry, ParentId,
                (SELECT Id, Name, Status__c, Number_of_Open_Opps__c, Website, LastActivityDate, Owner.Name, Base_Product__c, BillingCountry, ParentId FROM ChildAccounts)
                FROM Account
                WHERE Id = :accountId
        ];
        AccountMapObj mainAccount =  new AccountMapObj();
        mainAccount.currentAccount = accountWithParentsAndChildren;
        accountIdToRelationMap.put(accountWithParentsAndChildren.Id , mainAccount);
        if(accountWithParentsAndChildren.ParentId != null){
            mainAccount.parentAccountId = accountWithParentsAndChildren.ParentId;
            queryMainAccount(mainAccount.parentAccountId , accountIdToRelationMap);
        }else{
            mainAccount.isTopParentAccount = true;
        }
        System.debug('accountWithParentsAndChildren.ChildAccounts---'+accountWithParentsAndChildren.ChildAccounts);
        if(!accountWithParentsAndChildren.ChildAccounts.isEmpty()){
            System.debug(' i am here');
            mainAccount.childAccounts = accountWithParentsAndChildren.ChildAccounts;
            queryChildAccounts(accountWithParentsAndChildren.ChildAccounts,accountIdToRelationMap);
        }else{
            mainAccount.isBottomAccount = true;
        }
    }

    private static void queryChildAccounts(List<Account> childAccounts , Map<Id,AccountMapObj> accountIdToRelationMap){

        List<Account> grandSonAccountList = new List<Account>();
        List<Account> childrenAccountWithGrandsonAccounts = [
                SELECT Id, Name, Status__c, Number_of_Open_Opps__c, Website, LastActivityDate, Owner.Name, Base_Product__c, BillingCountry, ParentId,
                (SELECT Id, Name, Status__c, Number_of_Open_Opps__c, Website, LastActivityDate, Owner.Name, Base_Product__c, BillingCountry, ParentId FROM ChildAccounts)
                FROM Account
                WHERE Id IN : childAccounts
        ];

        for (Account childAccount : childrenAccountWithGrandsonAccounts){
            AccountMapObj accountMapObj = new AccountMapObj();
            accountMapObj.parentAccountId = childAccount.ParentId;
            accountMapObj.currentAccount = childAccount;
            accountIdToRelationMap.put(childAccount.id ,accountMapObj);
            if(!childAccount.ChildAccounts.isEmpty()){
                accountMapObj.childAccounts = childAccount.ChildAccounts;
                grandSonAccountList.addAll(childAccount.ChildAccounts);
            }else{
                accountMapObj.isBottomAccount = true;
            }

        }
        if(!grandSonAccountList.isEmpty()){
            queryChildAccounts(grandSonAccountList,accountIdToRelationMap);
        }
    }

    public class AccountMapObj{
        @AuraEnabled
        public Account currentAccount;
        @AuraEnabled
        public Id parentAccountId;
        @AuraEnabled
        public List<Account> childAccounts;
        @AuraEnabled
        public Boolean isBottomAccount;
        @AuraEnabled
        public Boolean isTopParentAccount;

        public AccountMapObj(){
            this.isBottomAccount = false;
            this.childAccounts = new List<Account>();
            this.isTopParentAccount = false;
        }
    }
    private static void handleSums(String parentCompanyDomain,String websiteDomain, Map<String, Object> hierarchyMap) {
        Integer oppSum = 0;
        Integer subsSum = 0;
        Integer meetingsSum = 0;
        Integer contactsSum = 0;
        Integer contactsChampionsSum = 0;
        Integer payingAccountSum = 0;
        Integer noTouchAccountSum = 0;
        Integer activeOrAdminUserSum = 0;
        Decimal hierarchyTotalOpenOppsSum = 0;
        Integer hierarchyOwner = 0; // need to take from bi
        String allHierarchyBaseProductNames = ''; // need to take from bi
        Set<String> baseProductsSet = new Set<String>();
        String query = 'SELECT Id, Stage__c, No_Touch_Account__c,Hierarchy_Total_Open_Opps__c,Base_Product__c,Status__c,\n' +
                '                                        (SELECT Id,IsClosed FROM Opportunities),\n' +
                '                                        (SELECT Id FROM Meetings__r),\n' +
                '                                        (SELECT Id FROM Zuora__Subscriptions__r),\n' +
                '                                        (SELECT Id, Champion__c, Pro_User_Type__c FROM Contacts)\n' +
                '                                    FROM Account ' ;
        query += String.isNotBlank(parentCompanyDomain) ? 'WHERE Parent_Company_Domain__c = :parentCompanyDomain' : 'WHERE Parent_Company_Domain__c = null AND Website_Domain__c = :websiteDomain ';
        List<Account> accountList = Database.query(query);
//        List<Account> accountList = [SELECT Id, Stage__c, No_Touch_Account__c,Hierarchy_Total_Open_Opps__c,Base_Product__c,Status__c,
//                                        (SELECT Id FROM Opportunities),
//                                        (SELECT Id FROM Meetings__r),
//                                        (SELECT Id FROM Zuora__Subscriptions__r),
//                                        (SELECT Id, Champion__c, Pro_User_Type__c FROM Contacts)
//                                    FROM Account WHERE Parent_Company_Domain__c = :parentCompanyDomain];
        System.debug('accountList--'+accountList.size());
        for (Account acc : accountList) {
            if(String.isNotBlank(acc.Base_Product__c) &&  acc.Base_Product__c != 'NA'){
                System.debug('acc.asdasd -- '+acc.Base_Product__c);
                baseProductsSet.add(acc.Base_Product__c);
            }
            System.debug('baseProductsSet---'+baseProductsSet);
            for(Opportunity opp : acc.Opportunities){
                System.debug('baseProductsSet---'+baseProductsSet);
                if(opp.IsClosed == false){
                    hierarchyTotalOpenOppsSum ++;
                }
            }
            oppSum += acc.Opportunities.size();
            contactsSum += acc.Contacts.size();
            meetingsSum += acc.Meetings__r.size();
            subsSum += acc.Zuora__Subscriptions__r.size();
            for (Contact accountContact : acc.Contacts) {
                if (accountContact.Champion__c) {
                    contactsChampionsSum++;
                }
                if (accountContact.Pro_User_Type__c != null) {
                    if (accountContact.Pro_User_Type__c.containsIgnoreCase('User') || accountContact.Pro_User_Type__c.containsIgnoreCase('Admin')) {
                        activeOrAdminUserSum++;
                    }
                }
            }
            if (acc.Stage__c == 'Paying Account' && (acc.Status__c == 'Active' || acc.Status__c == 'Cancelled')) {
                payingAccountSum++;
            }
            if (acc.No_Touch_Account__c) {
                noTouchAccountSum++;
            }

        }
        System.debug('base product set ---- : '+baseProductsSet);
        System.debug('base product set -joined--- : '+String.join(new List<String>(baseProductsSet),','));
        hierarchyMap.put('totalAccounts', accountList.size());
        hierarchyMap.put('payingAccounts', payingAccountSum);
        hierarchyMap.put('noTouchAccounts', noTouchAccountSum);
        hierarchyMap.put('totalOpportunities', oppSum);
        hierarchyMap.put('totalSubscriptions', subsSum);
        hierarchyMap.put('totalMeetings', meetingsSum);
        hierarchyMap.put('totalContacts', contactsSum);
        hierarchyMap.put('totalChampions', contactsChampionsSum);
        hierarchyMap.put('totalAdmins', activeOrAdminUserSum);
        hierarchyMap.put('allHierarchyBaseProductUniqueNames',baseProductsSet.isEmpty() ?'N/A' : String.join(new List<String>(baseProductsSet),','));
        hierarchyMap.put('hierarchyTotalOpenOppsSum',hierarchyTotalOpenOppsSum);
//        hierarchyMap.put('hierarchyOwner', hierarchyOwner);
        System.debug('hierarchyMap--' + hierarchyMap);
        System.debug('world of account hierarchy --- ' + hierarchyMap.get('gridData'));
    }
}