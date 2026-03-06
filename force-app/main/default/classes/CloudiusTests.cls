@isTest
private class CloudiusTests {
	
	
	/**
	 @isTest// (seealldata=false)      
    static void TestOne(){     	
    	LeadTriggerHelperTEMP.isTest = true;
		AccountTriggerHelperTEMP.isTest = true;
		AccountTriggerHelperTemp.codeoff=false;
		
		LeadTriggerHelperTemp.ValidBusinessUnit.add('SMB');//,'ENTERPRISCE') 
		LeadTriggerHelperTemp.ValidBusinessUnit.add('Enterprise');
		
	    CS_FreeEmailProvidersList__c FreeEmail =TestObjectCreator.CreateFreeEmailProvider('gmail.com');
        insert FreeEmail;
    	
    	TestObjectCreator.CreateCSBatch();
    	
    	CSSettings__c csset = TestObjectCreator.CreateCSSettings();
	    insert csset;
	    
	    CSTeam__c cs1=new CSTeam__c(Name='A',Bucket__c='SMB',Business_Unit__c='SMB',Lead_Routing_Group__c='',PayingAccount__c=false,Team__c='');
	    insert cs1;   
	    
	    List<Account> lAccs=new List<Account>();
	    insert lAccs;
	    
	    Account parentAccount=TestObjectCreator.CreateAccount();
	    parentAccount.recurly__Account_Code__c='parentTest@gmail.com';
        parentAccount.recurly__Last_Name__c='parentSokolov';  
        parentAccount.Type='Reseller';  
	    insert parentAccount;
	    system.debug('Inserted Account: '+ parentAccount);
	    
	    Account tempAccount1 = TestObjectCreator.CreateAccount();
	    tempAccount1.recurly__Account_Code__c='test@gmail.com';
        tempAccount1.recurly__Last_Name__c='Sokolov';
        tempAccount1.parent=parentAccount;  
        tempAccount1.Reseller__c=parentAccount.Id;  
        tempAccount1.Business_Unit__c='SMB';       
        insert tempAccount1;        
        system.debug('Inserted Account: '+ tempAccount1);
        lAccs.add(tempAccount1);
        update lAccs;
                
        tempAccount1.ShippingCountry='Albania';
        tempAccount1.BillingCountry='Algeria';
        update tempAccount1; 
        update lAccs;       
        system.debug('After updated Account: '+ tempAccount1);
        
        Contact tempContactZ=TestObjectCreator.CreateContact(tempAccount1,'z@gmail.com');
	    insert tempContactZ;    	    
        system.debug('Inserted Contact: '+ tempContactZ);
        
        tempAccount1.uid__c=tempContactZ.Id;	    
	    tempAccount1.email__c=tempContactZ.Email;
	    update tempAccount1;
	    update lAccs;	
	    
	    Account tempAccount2 = TestObjectCreator.CreateAccount();
	    tempAccount2.recurly__Account_Code__c='t@gmail.com';
        tempAccount2.recurly__Last_Name__c='Vokolosz';           
        insert tempAccount2;       
        lAccs.add(tempAccount2);
        //update lAccs; 
        system.debug('Inserted Account: '+ tempAccount2);
                
        tempAccount2.ShippingCountry='Algeria';
        update tempAccount2; 
        //update lAccs;       
        system.debug('After updated Account: '+ tempAccount2);
        	    
	    tempAccount2.email__c=tempContactZ.Email;
	    update tempAccount2; 
	    //update lAccs;
	    
	   // update csset;
	    //  l1.Reseller__c=parentAccount.Id;
	    //  update l1;	    
	  
	 //   AccountTriggerHelperTEMP.RecurlyAccountAllocation (lAccs);
   }    
     */   
}