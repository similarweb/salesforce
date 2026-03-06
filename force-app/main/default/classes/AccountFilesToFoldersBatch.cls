public class AccountFilesToFoldersBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    private String libraryName = 'Account Attachments';
    private String libraryId; 
    private String rootContentFolderId;
    private Integer counter = 1;
    private List<String> cwIds = new List<String>();
    private Integer limitNumber = 0;
    
    public AccountFilesToFoldersBatch(){         
    }
    
    public AccountFilesToFoldersBatch(String libraryName){
        this.libraryName = libraryName;
    }
    public AccountFilesToFoldersBatch(String libraryName,Integer limitNumber){
        this.libraryName = libraryName;
        this.limitNumber = limitNumber;
    }
    
    
    public Database.QueryLocator start (Database.BatchableContext BC){
        AggregateResult[] groupedResults = [SELECT COUNT(ID)cnt  FROM Account WHERE ARR__c>0];
        Integer accCount = limitNumber==0 ? (Integer)groupedResults[0].get('cnt') : limitNumber;
        Integer cwSize = accCount/500 + 1;
        System.debug('cwSize ' + cwSize);
        List<ContentWorkspace> newCwList = new List<ContentWorkspace>();
        for (Integer i = counter; i <= cwSize; i++) {
            ContentWorkspace newCw  = new ContentWorkspace(Name = libraryName + '('+i+')');
            newCwList.add(newCw);
        }            
        insert newCwList; 
        for(ContentWorkspace newCw : newCwList){
            cwIds.add(newCw.id);
        }
        String query = 'SELECT Id,Name FROM Account WHERE ARR__c>0';
        if(limitNumber!=0){
            query+=' LIMIT ' + limitNumber;
        }
        System.debug('query ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){      
        String lName = libraryName + '('+counter+')';
        System.debug([SELECT Name FROM ContentWorkspace]);
        ContentWorkspace newCw = [SELECT Id,RootContentFolderId FROM ContentWorkspace WHERE Name=:lName];              
        libraryId = newCw.Id;    
        rootContentFolderId = newCw.RootContentFolderId;
        
       
        Set<Id> relateObjIds = new Set<Id>();        
        Set<Id> accIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> quotesIds = new Set<Id>();
        Map<String,String> oppIdToAccId = new Map<String,String>();
        Map<String,String> quoteIdToAccId = new Map<String,String>();
        Set<Id> cdIds = new Set<Id>();
        
        Map<String,ContentFolder> accIdToFolder = new Map<String,ContentFolder>();
        List<ContentWorkspaceDoc> cdToLibraryJunctionList = new List<ContentWorkspaceDoc>();
        Map<String,String> cdIdToAccId = new Map<String,String>();        
        
        for (SObject sobj_i : scope) {            
            accIds.add(sobj_i.Id);
            accIdToFolder.put(sobj_i.Id, new ContentFolder(Name = ((String)sobj_i.get('Name')).replace('/',' ') + ' ' + sobj_i.Id,ParentContentFolderId = rootContentFolderId));            
        }
        
        for(Opportunity opp : [SELECT Id,AccountId FROM Opportunity WHERE AccountId IN :accIds]){
            oppIds.add(opp.Id);
            oppIdToAccId.put(opp.Id,opp.AccountId);
        }
        for(zqu__Quote__c quote : [SELECT Id,zqu__Account__c FROM zqu__Quote__c WHERE zqu__Account__c IN :accIds]){
            quotesIds.add(quote.Id);
            quoteIdToAccId.put(quote.Id,quote.zqu__Account__c);
        }
        relateObjIds.addAll(accIds);
        relateObjIds.addAll(oppIds);
        relateObjIds.addAll(quotesIds);
        List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :relateObjIds AND ContentDocument.FileExtension!='snote'];
        for(ContentDocumentLink cdl : cdlList){            
            cdIds.add(cdl.ContentDocumentId);
            if(accIds.contains(cdl.LinkedEntityId)){
                cdIdToAccId.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
            } else if(oppIds.contains(cdl.LinkedEntityId)){
                cdIdToAccId.put(cdl.ContentDocumentId,oppIdToAccId.get(cdl.LinkedEntityId));
            } else if(quotesIds.contains(cdl.LinkedEntityId)){
                cdIdToAccId.put(cdl.ContentDocumentId,quoteIdToAccId.get(cdl.LinkedEntityId));
            }
            
            ContentWorkspaceDoc docLink = new ContentWorkspaceDoc();
            docLink.ContentDocumentId = cdl.ContentDocumentId;
            docLink.ContentWorkspaceId = libraryId;
            cdToLibraryJunctionList.add(docLink);
        }
        insert cdToLibraryJunctionList;        
        /*Map<String,ContentFolder> filteredAccIdToFolder = new Map<String,ContentFolder>();
        for(String accId : cdIdToAccId.values()){
            
            if(accIdToFolder.containsKey(accId)){
                filteredAccIdToFolder.put(accId, accIdToFolder.get(accId));
                accIdToFolder.remove(accId);
            }
        }
        accIdToFolder = filteredAccIdToFolder;*/
        insert accIdToFolder.values();
        
        List<ContentFolderMember> contentFolderMemberList = [SELECT Id, ParentContentFolderId, ChildRecordId FROM ContentFolderMember WHERE ParentContentFolderId = :rootContentFolderId AND ChildRecordId IN :cdIds];
        for(ContentFolderMember cfm : contentFolderMemberList){
            cfm.ParentContentFolderId = accIdToFolder.get(cdIdToAccId.get(cfm.ChildRecordId)).Id;
        }
        update contentFolderMemberList;
        counter++;
    }
    
    public void finish(Database.BatchableContext BC){
        if(limitNumber!=0){
            Database.executeBatch(new AccountAttachmentsToFoldersBatch(cwIds,limitNumber),10);
        } else {
            Database.executeBatch(new AccountAttachmentsToFoldersBatch(cwIds),10);
        } 
    }
}