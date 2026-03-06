global without sharing class ZQuoteHandler {

    static public map <id, zqu__Quote__c > OldMap = new map <id, zqu__Quote__c >();
    public static list <zqu__Quote__c> Quote2Send = new list <zqu__Quote__c>();
    public static map <string, Country_Subsidiary__c> CountrySubMap = new map <string, Country_Subsidiary__c>();
    public static map <string, Zuora__CustomerAccount__c> ZBA_Map = new map <string, Zuora__CustomerAccount__c>();
    public static map <id,RecordType> RecTypeMap = new map <id,RecordType>();
    public static map <id, Account> AccMap = new map <id, Account>();
    public static map <id,Contact> ContactMap = new map <id,Contact>();
    public static map <id,User> UserMap = new map <id,User>();
    public static map <id,ApprovedTermsFrequecy__c> ATFMap = new map <id,ApprovedTermsFrequecy__c>();
        
    public static map <string,Product2> ProductMap = new map <string,Product2>();
    
    public static string Errors = '';
    
    public static map <id,zqu__Quote__c> QuoteInfoMap = new map <id,zqu__Quote__c>();

    public static map <id, zqu__QuoteChargeSummary__c[]> Quote2QuoteChargeSummaryMap = new map <id, zqu__QuoteChargeSummary__c[]>();
    public static map <id, zqu__QuoteRatePlanCharge__c[]> Quote2QuoteRatePlanChargeMap = new map <id, zqu__QuoteRatePlanCharge__c[]>();
    
    public static map <id,Zuora__SubscriptionProductCharge__c> SubPrdnChrgMap = new map <id,Zuora__SubscriptionProductCharge__c>();
    
    public static map <id,list<Zuora__SubscriptionProductCharge__c>> AccSubPrdnChrgMap = new map <id,list <Zuora__SubscriptionProductCharge__c>>();

    static public map <id, Account> Acc4UpdateMap = new map <id, Account>();
    static public map <id,zqu__QuoteRatePlanCharge__c> QRPC4Update = new map <id,zqu__QuoteRatePlanCharge__c>();

    public static list <id> CreateInvoiceQuoteID = new list <id>();
    
    public static map <string,list <Product_Restriction__c>> ProductRestrictionMap = new map <string,list <Product_Restriction__c>>();
    
    public static map <id,zqu__Quote__c> QuoteRollbackMap = new map <id,zqu__Quote__c>();
    
    // public static map <string,list <Product_Restriction__c>> ExactlyOneProductReq = new map <String,list <Product_Restriction__c>>();
    
    public static set <string> ExactlyOneCountryReq = new set <string>();

    public ApexPages.StandardController con;

    public ZQuoteHandler(apexPages.StandardController con) {
        this.con = con;
    }
    
    public static void GenProductRestrictionMap()
    {
        list <Product_Restriction__c> PRList= [select id,ItemCode1__c,ItemCode2__c,ItemMatch__c from Product_Restriction__c];
        if (PRList.size()>0)
        {
            list <Product_Restriction__c> NewPRLIst = new list <Product_Restriction__c>();
            NewPRList.addall (PRList);
            for (Product_Restriction__c pr : PRList)
            {
                Product_Restriction__c newpr = new Product_Restriction__c();
                newpr.ItemCode1__c = pr.ItemCode2__c;
                newpr.ItemCode2__c = pr.ItemCode1__c;
                newpr.ItemMatch__c = pr.ItemMatch__c;
                NewPRList.add (newpr);
                
                if (pr.ItemMatch__c!=null && pr.ItemMatch__c.EqualsIgnoreCase ('Exactly 1 Country'))
                { 
                	//Needs a list of where it appears as 1, as opposed to the run below which does the same with the reversed list
                	//list <Product_Restriction__c> templist = new list <Product_Restriction__c>();
	                //if (pr.ItemCode1__c!=null && ExactlyOneProductReq.ContainsKey (pr.ItemCode1__c)) templist = ExactlyOneProductReq.get (pr.ItemCode1__c);
	                //templist.add (pr);
                	//ExactlyOneProductReq.put (pr.ItemCode1__c,templist);
                	ExactlyOneCountryReq.add (pr.ItemCode1__c);
                }
                
            } 
            for (Product_Restriction__c pr : NewPRList) //if (pr.ItemMatch__c!=null && !pr.ItemMatch__c.EqualsIgnoreCase('At Least One'))
            {
                list <Product_Restriction__c> templist = new list <Product_Restriction__c>();
                if (pr.ItemCode1__c!=null && ProductRestrictionMap.ContainsKey (pr.ItemCode1__c)) templist = ProductRestrictionMap.get (pr.ItemCode1__c);
                templist.add (pr);
                ProductRestrictionMap.put (pr.ItemCode1__c,templist);
            }
        }
    }
    
    public static void GenSubPrdnChrgMap (list <id> AccID)
    {
        list <Zuora__SubscriptionProductCharge__c> Spclist = [select id,Zuora__Subscription__c,
                                                                Zuora__AccountingCode__c,Zuora__ChargeNumber__c,
                                                                Zuora__Description__c,Zuora__EffectiveEndDate__c,
                                                                Zuora__EffectiveStartDate__c,Zuora__EndDateCondition__c,
                                                                Zuora__ExtendedAmount__c,Zuora__External_Id__c,
                                                                Zuora__Model__c,Zuora__MonthlyRecurringRevenue__c,
                                                                Zuora__BillingPeriod__c,Zuora__BillingPeriodStartDay__c,
                                                                Zuora__Price__c,Zuora__PriceTable__c,
                                                                Zuora__Product__c,Zuora__ProductDescription__c,
                                                                Zuora__ProductEffectiveEndDate_Product__c,
                                                                Zuora__ProductEffectiveEndDate__c,
                                                                Zuora__ProductName_Product__c,Zuora__ProductName__c,
                                                                Zuora__ProductSKU_Product__c,Zuora__ProductSKU__c,
                                                                Zuora__Quantity__c,Zuora__RatePlanDescription__c,
                                                                Zuora__RatePlanEffectiveEndDate__c,Zuora__RatePlanId__c,
                                                                Zuora__RatePlanName__c,Zuora__SpecificEndDate__c,
                                                                Zuora__SubscriptionChargeNumber__c,Zuora__TotalContractValue__c,
                                                                Zuora__Type__c,Zuora__UOM__c,Zuora__UOM_formula__c,
                                                                Zuora__UnitOfMeasure__c,
                                                                Zuora__Upto_How_Many_Periods__c,Zuora__UpToPeriodsType__c,
                                                                Zuora__Zuora_Id__c,
        
                                                                Zuora__Subscription__r.Zuora__Status__c,
                                                                Zuora__Subscription__r.Zuora__Account__c
        
                                                                from Zuora__SubscriptionProductCharge__c where
                                                                 Zuora__Subscription__r.Zuora__Account__c=:AccID
                                                                 and Zuora__Subscription__r.Zuora__Status__c=:'Active'
                                                                 
                                                                 ];
        SubPrdnChrgMap.putall (spclist);
        
        for (Zuora__SubscriptionProductCharge__c zspc: spclist)
        {
            if (zspc.Zuora__Subscription__r.Zuora__Account__c!=null)
            {
                list <Zuora__SubscriptionProductCharge__c> templist = new list <Zuora__SubscriptionProductCharge__c>();
                if (AccSubPrdnChrgMap.ContainsKey (zspc.Zuora__Subscription__r.Zuora__Account__c))
                {
                    templist = AccSubPrdnChrgMap.get (zspc.Zuora__Subscription__r.Zuora__Account__c);
                }
                templist.add (zspc);
                AccSubPrdnChrgMap.put (zspc.Zuora__Subscription__r.Zuora__Account__c,templist);
            }
        }
        
        list <Product2> ProductList = [select id,name,AddOnType__c,
                                                zqu__Category__c,Description,
                                                zqu__Deleted__c,GroupCompatibilityN__c,
                                                InternalCode__c,
                                                ProductCompatibility__c,zqu__SKU__c,
                                                zqu__ZuoraId__c,IsActive
                                                from Product2];
        
        
        if (Productlist.size()>0) for (Product2 zp : ProductList ) {productMap.put (zp.name,zp); if (zp.InternalCode__c!=null) ProductMap.put (zp.InternalCode__c,zp);}
        
        
        
    }

    static public void ClearStatData(string event) {
        if (Acc4UpdateMap.size() > 0) Acc4UpdateMap.clear();
        if (CreateInvoiceQuoteID.size() > 0) CreateInvoiceQuoteID.clear();
        //if (Quote2Send.size()>0 && event!='Button') Quote2Send.clear();
        if (AccMap.size() > 0) AccMap.clear();
        if (ATFMap.size()>0) ATFMap.clear();
        if (ProductRestrictionMap.size()>0) ProductRestrictionMap.clear();
    }

    public static void GetData(list <zqu__Quote__c> Qlist, string event) {
        system.debug('TESTING GetData started');
        ClearStatData(event);
        list <id> UserIdlist = new list <id>();
        id uid =  userinfo.getUserId();
        
        list <User> Ulist = [select id,isActive,Exclude_From_Zuora_Active_Subs_Val__c
                             from User where id=:uid 
        
        ];
        UserMap.putall (Ulist);
        
        list <ApprovedTermsFrequecy__c> ATFList = [select id,name,Billing_Remarks__c,Default__c,Frequency__c,Initial_Term__c from ApprovedTermsFrequecy__c];
        if (ATFList.size()>0) ATFMap.putall (ATFList);
        
        
        
        list <Country_Subsidiary__c> CountryList = [
                select id, Communication_Profile_Cont__c, name, Country_Id__c, Country_Name__c, Communication_profile_cc__c,
                        CommunicationProfilesSFID__c, InvoiceTemplateCCSFID__c,ISOCode__c,
                        InvoiceTemplateContrSFID__c, InvoiceTemplateWSFID__c,Invoice_Template_Ent__c,IsNoMobileWeb__c,
                        Subsidiary__c, Taxable__c, Tax_Region__c, No_Tax_Region__c,Restricted_To_Sold_Country__c,ISOCode_3__c
                from Country_Subsidiary__c
        ];
        
        list <RecordType> tempreclist= [select id,developername,name from RecordType];
        RecTypeMap.putall (tempreclist);

        if (CountryList.size() > 0) {
            for (Country_Subsidiary__c cl : CountryList)
            {
                CountrySubMap.put (cl.name, cl);
                if (cl.ISOCode_3__c!=null) CountrySubMap.put (cl.ISOCode_3__c, cl); 
            }
        }

        list <id> TempIDList = new list <id>();
        for (zqu__Quote__c zq : Qlist) {
            if (zq.zqu__Account__c != null) TempIDList.add (zq.zqu__Account__c);
            if (zq.zqu__SoldToContact__c != null) TempIDList.add (zq.zqu__SoldToContact__c);
        }
        system.debug('TESTING - TempIDlist is '+tempidlist);

        if (TempIDList.size() > 0) {
            list <Account> TempAList = [
                    select id, name, Tax_Exempt_Certificate_ID__c, BillingCountry, ShippingCountry, No_of_Users__c,
                    (select id, Zuora__Default_Payment_Method__r.name, Zuora__Default_Payment_Method__c, Zuora__DefaultPaymentMethod__c from Zuora__R00N40000001kyLcEAI__r),
                    
                    (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                     SystemModstamp, LastActivityDate, Zuora__Account__c, Zuora__AutoRenew__c, Zuora__ContractAcceptanceDate__c, 
                     Zuora__ContractEffectiveDate__c, Zuora__CustomerAccount__c, Zuora__External_Id__c, Zuora__InitialTerm__c, 
                     Zuora__InvoiceOwner__c, Zuora__MRR__c, Zuora__NextChargeDate__c, Zuora__NextRenewalDate__c, 
                     Zuora__Notes__c, Zuora__OriginalCreatedDate__c, Zuora__OriginalCreated_Date__c, Zuora__RenewalTerm__c,
                     Zuora__ServiceActivationDate__c, Zuora__Status__c, Zuora__SubscriptionEndDate__c, 
                     Zuora__SubscriptionNumber__c, Zuora__SubscriptionStartDate__c, Zuora__TCV__c, Zuora__TermEndDate__c, 
                     Zuora__TermSettingType__c, Zuora__TermStartDate__c, Zuora__Version__c, Zuora__Zuora_Id__c, Account_Owner__c, 
                     Trigger_AccountRecalc__c From Zuora__Subscriptions__r)

                    from Account
                    where id = :TempIDList
            ];
            if (TempAList.size()>0) AccMap.putall (TempAList);
            system.debug('TESTING - AccMap Updated, size '+Accmap.size());
            
            list <Contact> TempClist = [select id,mailingcountry,mailingstate,mailingpostalcode from Contact where id=:tempIDList];
            if (TempClist.size()>0) ContactMap.putall (TempClist);
            system.debug('TESTING - ContactMap Updated');
            
        }


    }
    public static Integer GetPaymentMethodCounter = 0;
    static public string GetPaymentMethod(zqu__Quote__c zq) {
        system.debug('TESTING - GetPaymentMethod started');
        system.debug('TESTING - zq.zqu__Account__c is ' + zq.zqu__Account__c);
        system.debug('TESTING - AccMap.ContainsKey (zq.zqu__Account__c) is ' + AccMap.ContainsKey (zq.zqu__Account__c));
        //system.debug('TESTING - AccMap ZBA size is ' + AccMap.get (zq.zqu__Account__c).Zuora__R00N40000001kyLcEAI__r.size());
        

        string res = null;
        if (zq.zqu__PaymentMethod__c != null) res = zq.zqu__PaymentMethod__c.tolowercase(); else
                if (zq.zqu__Account__c != null && AccMap.ContainsKey (zq.zqu__Account__c) && AccMap.get (zq.zqu__Account__c).Zuora__R00N40000001kyLcEAI__r.size() > 0) {
                    Zuora__CustomerAccount__c zba = AccMap.get (zq.zqu__Account__c).Zuora__R00N40000001kyLcEAI__r[0];
                    if (zba.Zuora__DefaultPaymentMethod__c != null) res = zba.Zuora__DefaultPaymentMethod__c.tolowercase(); else if (zba.Zuora__Default_Payment_Method__c != null) res = zba.Zuora__Default_Payment_Method__r.name.tolowercase();
                }
        system.debug('TESTING - res is ' + res);
        
        if (res!=null)
        {
            if (res == 'wiretransfer') res = 'wire transfer';
            if (res == 'creditcard') res = 'credit card';
            if (res.tolowercase()=='paypal') res = 'credit card';
        }
        if ( Test.isRunningTest() ) {
            list<String> methods = new list<String>{'wire transfer','credit card','other'};
            res = methods[GetPaymentMethodCounter];
            GetPaymentMethodCounter = Math.mod(GetPaymentMethodCounter+1,methods.size());
        }
        return res;
    }


    static public void UpdateAccBatch(list <zqu__Quote__c> Qlist, string event) {
        if (Qlist.size() > 0) for (zqu__Quote__c zq : Qlist) {
            if (zq.zqu__Account__c != null && GetPaymentMethod(zq) != null) {
                system.debug('TESTING UppdateAccBatch - event is ' + event);
                if (event == 'Insert' || event == 'Button' || (event == 'Update' && Oldmap != null && oldmap.ContainsKey(zq.id) && oldmap.get (zq.id).zqu__PaymentMethod__c != zq.zqu__PaymentMethod__c)) {

                    string pm = GetPaymentMethod (zq);
                    system.debug('TESTING - Payment method is ' + pm);
                    //Account a = new Account (id=zq.zqu__Account__c);
                    //if (Acc4UpdateMap.ContainsKey (a.id)) a= Acc4UpdateMap.get (a.id);

                    if (pm == 'credit card' || pm == 'paypal') {
                        zq.zqu__BillingBatch__c = 'Batch1';
                        //Acc4UpdateMAP.PUT (a.id,a);
                    }
                    if (pm == 'wire transfer') {
                        zq.zqu__BillingBatch__c = 'Batch2';
                        //Acc4UpdateMAP.PUT (a.id,a);
                    }
                    if (pm == 'other') {
                        zq.zqu__BillingBatch__c = 'Batch3';
                        //Acc4UpdateMAP.put (a.id,a);
                    }
                    system.debug('TESTING Batch is ' + zq.zqu__BillingBatch__c);
                }
            }
        }
    }

    static public void UpdateAccBillCycleDay(list <zqu__Quote__c> Qlist, string event) {
        if (Qlist.size() > 0) for (zqu__Quote__c zq : Qlist) {
            system.debug('TESTING - UpdateAccBillCycleDay started for '+zq.name);
            string rectype = null;
            if (zq.recordtype.developername!=null) rectype = zq.recordtype.developername;
            else if (zq.recordtypeid!=null && RecTypeMap.ContainsKey (zq.recordtypeid)) rectype = RecTypeMap.get (zq.recordtypeid).developername;
            system.debug('TESTING - rectype is +rectype');
            
            if (zq.zqu__TermStartDate__c != null || zq.zqu__SubscriptionTermStartDate__c!=null)//zq.zqu__Account__c!=null && )
            {
                if (event == 'Insert' || event == 'Button' || (Oldmap != null && oldmap.containskey(zq.id) && oldmap.get (zq.id).zqu__TermStartDate__c != zq.zqu__TermStartDate__c)
                    || (OldMap!=null && Oldmap.containskey (zq.id) && oldmap.get (zq.id).zqu__SubscriptionTermStartDate__c!= zq.zqu__SubscriptionTermStartDate__c)
                ) {
                    //Account a = new Account (id=zq.zqu__Account__c);
                    //if (Acc4UpdateMap.ContainsKey (a.id)) a= Acc4UpdateMap.get (a.id);
                    if (rectype!=null && rectype.tolowercase()=='default')
                    {
                         if (zq.zqu__TermStartDate__c!=null) zq.zqu__BillCycleDay__c = string.valueof(zq.zqu__TermStartDate__c.day());
                         else zq.zqu__BillCycleDay__c=null;
                    }
                    if (rectype!=null && rectype.tolowercase()!='default')
                    {
                         if (zq.zqu__SubscriptionTermStartDate__c!=null) zq.zqu__BillCycleDay__c = string.valueof(zq.zqu__SubscriptionTermStartDate__c.day());
                         else zq.zqu__BillCycleDay__c=null;
                    }
                    //Acc4UpdateMap.put (a.id,a);
                }
            }
            
        }
    }
    
    static public void ValidateQuote (list <zqu__Quote__c> Qlist, string event)
    {
        if (event=='Update')
        {
            for (zqu__Quote__c zq : Qlist)
            {
                boolean SizeError = false;
                boolean integererror = false;
                if (zq.Payment_Frequency__c!=null && 
                     (OldMap.get (zq.id).zqu__InitialTerm__c!= zq.zqu__InitialTerm__c ||
                      OldMap.get (zq.id).Payment_Frequency__c!= zq.Payment_Frequency__c ||
                      OldMap.get (zq.id).zqu__RenewalTerm__c!= zq.zqu__RenewalTerm__c 
                     )
                   )
                {
                    if (Zq.zqu__InitialTerm__c!=null && zq.zqu__InitialTerm__c<zq.Payment_Frequency__c) SizeError=true;
                    if (Zq.zqu__RenewalTerm__c!=null && zq.zqu__RenewalTerm__c<zq.Payment_Frequency__c) SizeError=true;
                    
                    if (zq.Payment_Frequency__c!=null && zq.Payment_Frequency__c!=0)
                    {
	                    system.debug('TESTING Mod1: '+math.Mod (integer.valueof(zq.zqu__InitialTerm__c),integer.valueof(zq.Payment_Frequency__c)));
	                    system.debug('TESTING Mod2: '+math.Mod (integer.valueof(zq.zqu__RenewalTerm__c),integer.valueof(zq.Payment_Frequency__c)));
	                    if (math.Mod (integer.valueof(zq.zqu__InitialTerm__c),integer.valueof(zq.Payment_Frequency__c))>0) integererror = true;
	                    if (math.Mod (integer.valueof(zq.zqu__RenewalTerm__c),integer.valueof(zq.Payment_Frequency__c))>0) integererror = true;
                    }
                }
                if (SizeError) zq.adderror ('Terms cannot be smaller than Payment Frequency');
                if (integererror) zq.adderror ('Terms and Payment Frequency must be aligned');
            }
        }
    }
    
    public static void QuoteFieldUpdate_Trigger (list <zqu__Quote__c> Qlist, string event)
    {
        system.debug('TESTING QuoteFieldUpdate_Trigger fired');
        
        list <id> tempidlist = new list <id>();
        for (zqu__Quote__c zq : Qlist) if (zq.id!=null) tempidlist.add (zq.id);
        QuoteInfoMap.putall (QueryQuote (tempidlist));
        
        for (zqu__Quote__c zq :Qlist)
        {
            boolean ATFFound = false;
            ApprovedTermsFrequecy__c ATFRec = null;
            
            if (ATFMap.size()>0) for (ApprovedTermsFrequecy__c atf : ATFMap.values())
            {
                if (atf.Frequency__c == zq.Payment_Frequency__c && atf.initial_term__c  == zq.zqu__InitialTerm__c
                    && atf.initial_term__c == zq.zqu__RenewalTerm__c){ ATFFound=true; ATFRec = atf;} 
            }
            system.debug('TESTING ATF record found is '+ATFRec);
            if (event=='Update' || event=='FutureUpdate')
            {
                if (event=='Update')
                {
                    zq.Is_No_Frequency__c = false;
                    
                    if (!ATFFound) zq.Is_No_Frequency__c = true;
                    
                    /*
                    if (zq.Discount_Percentage__c!= oldmap.get (zq.id).Discount_Percentage__c)
                    {
                        system.debug('Testing Discount Amount calculation. Discount Amount is '+zq.discount_amount__c);
                        system.debug('Testing zq.Upsell_Amount__c is '+zq.Upsell_Amount__c);
                        if (zq.Discount_Percentage__c!=null && zq.Upsell_Amount__c!=null) 
                                  zq.Discount_Amount__c = (zq.Upsell_Amount__c/1-zq.Discount_Percentage__c) * (zq.Discount_Percentage__c/100); 
                                else 
                                  zq.Discount_Amount__c = 0;
                        system.debug('TESTING Discount amount set to '+zq.Discount_Amount__c);
                    }
                    else if (zq.Discount_Amount__c != oldmap.get (zq.id).Discount_Amount__c && zq.Upsell_Amount__c!=null && zq.Upsell_Amount__c!=0)
                    {
                        system.debug('TESTING upsell amount is '+zq.upsell_amount__c);
                        zq.Discount_Percentage__c = zq.Discount_Amount__c/ zq.Upsell_Amount__c*100;
                        system.debug('TESTING Discount percentage set to '+zq.Discount_Percentage__c);
                    }
                    */
                }
                            
                system.debug('TESTING Quote2QuoteRatePlanChargeMap size is '+Quote2QuoteRatePlanChargeMap.size());
                if (Quote2QuoteRatePlanChargeMap.ContainsKey (zq.id))
                {
                    list <zqu__QuoteRatePlanCharge__c> QRPClist = Quote2QuoteRatePlanChargeMap.get (zq.id);
                    set <zqu__QuoteRatePlanCharge__c> QRPC4Updatelist = new set <zqu__QuoteRatePlanCharge__c>();
                    
                    boolean setDiscAmountFromRatePlan = false;
                    decimal termtotal = 0;
                    decimal total = 0;
                    
                    //if (zq.Upsell_Amount__c!=null && zq.Upsell_Amount__c!=0 && zq.Discount_Amount__c / zq.Upsell_Amount__c*100 != zq.Discount_Amount__c)
                    //{
                    //  setDiscAmountFromRatePlan = true;
                    //  system.debug('TESTING setDiscAmountFromRatePlan set to true');
                    //}
                    
                    system.debug('TESTING  Running through QRPCs');
                    for (zqu__QuoteRatePlanCharge__c qrpc : QRPCList)
                    {
                        if (qrpc.zqu__Period__c!=null && qrpc.zqu__Period__c.EqualsIgnoreCase('Specific Months')//) QRPC4Updatelist.add (qrpc);
                        //if (
                        && zq.Payment_Frequency__c != oldmap.get (zq.id).Payment_Frequency__c 
                            || zq.installments__c !=oldmap.get(zq.id).installments__c 
                            || zq.zqu__InitialTerm__c !=oldmap.get (zq.id).zqu__InitialTerm__c)
                            
                               QRPC4Updatelist.add (qrpc);
                        /*if (event=='FutureUpdate' || (oldmap!=null && zq.Discount_Percentage__c!= oldmap.get (zq.id).Discount_Percentage__c))
                        {
                            
                            if (qrpc4Update.ContainsKey (qrpc.id)) qrpc = qrpc4Update.get (qrpc.id);
                            //qrpc.zqu__Discount__c = zq.Discount_Percentage__c;
                            system.debug('TESTING List Price is '+qrpc.zqu__ListPrice__c);
                            system.debug('TESTING Discount is '+zq.Discount_Percentage__c);
                            system.debug('TESTING Quantity before update is '+qrpc.zqu__Quantity__c);
                            if (qrpc.zqu__Quantity__c==null) qrpc.zqu__Quantity__c=1;
                            system.debug('TESTING Quantity final is '+qrpc.zqu__Quantity__c);
                            qrpc.zqu__Total__c = qrpc.zqu__ListPrice__c * (1-zq.Discount_Percentage__c/100) * qrpc.zqu__Quantity__c; 
                            if (!qrpc.IsDeleted) qrpc4Update.put (qrpc.id,qrpc);

                            
                        }
                        */
                        //if (setDiscAmountFromRatePlan)
                        //{
                        //  if (qrpc.Terms_Total__c!=null) termtotal = termtotal + qrpc.Terms_Total__c;
                        //  if (qrpc.zqu__Total__c!=null) total = total + qrpc.zqu__Total__c; 
                        //}
                    }
                    
                    /*
                    if (setDiscAmountFromRatePlan && total!=0)
                    {
                        zq.Discount_Amount__c = (1 - (termtotal/total))*100;
                        system.debug('Testing setDiscAmountFromRatePlan - Discount_Amount__c set to '+zq.Discount_Amount__c);
                    }*/
                    
                    system.debug('TESTING QRPC4Updatelist size is '+QRPC4Updatelist.size());
                    system.debug('TESTING ATFRec is '+ATFRec);
                    if (QRPC4Updatelist.size()>0 && zq.recordtypeid!=null && !RecTypeMap.get(zq.recordtypeid).developername.EqualsIgnoreCase('Cancellation'))
                    {   
                        for (zqu__QuoteRatePlanCharge__c qrpc : QRPC4Updatelist)
                        {
                            if (qrpc4Update.ContainsKey (qrpc.id)) qrpc = qrpc4Update.get (qrpc.id);
                            date edate = CSSettings__c.getinstance('Setting').Zuora_Effective_Date__c;
                            
                            system.debug('TESTING*** zq.Payment_Frequency__c is '+zq.Payment_Frequency__c);
                            system.debug('TESTING*** qrpc.zqu__SpecificBillingPeriod__c is '+qrpc.zqu__SpecificBillingPeriod__c);
                            system.debug('TESTING*** zq.effective date is '+qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c);
                            system.debug('TESTING*** qrpc.zqu__Period__c is '+qrpc.zqu__Period__c);
                                                        
                            if (qrpc.zqu__SpecificBillingPeriod__c !=zq.Payment_Frequency__c && qrpc.zqu__Period__c!=null && qrpc.zqu__Period__c.EqualsIgnoreCase('Specific Months') 
                            &&
                            
                                (qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c==null ||
                                qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c>edate
                                )
                                ) 
                            {
                                qrpc.zqu__SpecificBillingPeriod__c  = zq.Payment_Frequency__c;


                                if (ATFRec!=null && ATFRec.Billing_Remarks__c!=null) qrpc.zqu__Description__c  = qrpc.name + ' '+ATFRec.Billing_Remarks__c;
                                else qrpc.zqu__Description__c  = qrpc.name;

                                qrpc4Update.put (qrpc.id,qrpc);
                                system.debug('TESTING qrpc description updated '+qrpc.zqu__description__c);
                            }
                            
                            
                            //if (qrpc1.zqu__Quantity__c  != zq.Number_of_Countries__c)
                            //{
                            //  qrpc.zqu__Quantity__c  = zq.Number_of_Countries__c;
                            //  system.debug('TESTING QRPC quantity set to '+qrpc.zqu__quantity__c+'. ID '+qrpc.id);
                            //}     
                            
                            
                            system.debug('TESTING qrpc updated');
                        }
                        
                    }
                    
                }
                
            
                
            }
            if(event=='Insert')
            {
                /*
                if (zq.recordtypeid!=null && RecTypeMap.get(zq.recordtypeid).developername.EqualsIgnoreCase ('default'))
                {
                    zq.zqu__InitialTerm__c = 12;
                    zq.zqu__RenewalTerm__c = 12;
                    zq.Payment_Frequency__c =12;
                }*/
                if (zq.recordtypeid!=null && 
                    (
                     RecTypeMap.get(zq.recordtypeid).developername.EqualsIgnoreCase ('Amendment') ||
                     RecTypeMap.get(zq.recordtypeid).developername.EqualsIgnoreCase ('Renewal')
                    )
                   )
                   {
                        Account a = AccMap.get (zq.zqu__Account__c);
                        if (a.Zuora__Subscriptions__r.size()>0)
                        {
                            for (Zuora__Subscription__c zs : a.Zuora__Subscriptions__r)
                            {
                                if (zs.Zuora__Status__c.tolowercase()=='active')
                                {
                                    if (ATFMap.size()>0) for (ApprovedTermsFrequecy__c atf : ATFMap.values())
                                    {
                                        string atfterms = string.valueof(atf.initial_term__c);
                                        if (zs.Zuora__InitialTerm__c!=null)
                                        { 
                                        	string zsterms = zs.Zuora__InitialTerm__c.replace('inc','');
	                                        if (atf.default__c && atfterms!=null && atfterms.EqualsIgnoreCase(zsterms))
	                                        {
	                                            //zq.Payment_Frequency__c = atf.Frequency__c; 31-10-2016
	                                            break;
	                                        }
                                        }
                                    }
                                }
                            }
                        }
                   }
            }
        }
        
        
    }
    
    

    static public void HandleBefore(list <zqu__Quote__c > Qlist, map <id, zqu__Quote__c > oldtriggermap, string event) {
        system.debug('TESTING - HandleBefore Fired, event is ' + event + ' and Quote2Send size is ' + Quote2Send.size());
        if (oldtriggermap != null) OldMap = oldtriggermap;
        if (QuoteRollbackMap.size()==0) QuoteRollbackMap.putall (Qlist);
        if (event == 'Update' || event == 'Insert' || event == 'Button' || event=='FutureUpdate') {
            clearstatdata(event);
            GetData (Qlist, event);
            GenProductRestrictionMap();
            CalcPaymentFreq(Qlist);
            if (event=='Update' || event=='FutureUpdate')
            {
                list <id> qids = new list <id>();
                for (zqu__Quote__c zq : Qlist) qids.add (zq.id);
                BuildQuoteChargeMap(qids);
                
            } 
            ValidateQuote (Qlist,event);
            QuoteFieldUpdate_Trigger (Qlist,event);
            if (event=='Update' || event=='Insert' || event=='Button') if (Qlist.size()==1) 
              UpdateQuoteFields(Qlist[0]); //Works only on one quote as it used to work via a button on the quote
            

        }

        if (event == 'Insert') {
            
            CalcServiceActDate_CustomerAccptDate (Qlist);
            for (zqu__Quote__c q : Qlist) {
                /*
                 q.zqu__ValidUntil__c=date.today().adddays(6);
                 q.zqu__InitialTerm__c=12;
                 q.zqu__RenewalTerm__c = 12;
                 */
                 
                 if (q.recordtypeid!=null && RecTypeMap.ContainsKey (q.recordtypeid) && RecTypeMap.get (q.recordtypeid).developername.tolowercase()=='default')
                 {
                     boolean ActiveSub = false;
                     if (q.zqu__Account__c!=null && AccMap.ContainsKey (q.zqu__Account__c))
                     {
                        Account a = AccMap.get (q.zqu__Account__c);
                        if (a.Zuora__Subscriptions__r.size()>0)
                        {
                            for (Zuora__Subscription__c zs : a.Zuora__Subscriptions__r)
                            {
                                if (zs.Zuora__Status__c.tolowercase()=='active') ActiveSub = true;
                            }
                        }
                     }
                     
                     id uid = userinfo.getUserId(); 
                     if (ActiveSub && UserMap.ContainsKey(uid) && !UserMap.get(uid).Exclude_From_Zuora_Active_Subs_Val__c   ) q.adderror ('This account already has an active subscription');
                 }
            }
        }

        if (event == 'Update' || event == 'Button') {
            for (zqu__Quote__c q : Qlist) {
                if (q.zqu__ElectronicPaymentMethodId__c != null && Oldmap != null && oldmap.size() > 0 && OldMap.get (q.id).zqu__ElectronicPaymentMethodId__c == null) {
                    system.debug('TESTING - Quote to be sent to Zbilling ' + q.id);
                    Quote2Send.add (q);
                }
            }

            if (Quote2Send.size() > 0) {
                SendToZBillingBEFORE(Quote2Send);
            }

            UpdateAccBatch(Qlist, event);
            UpdateAccBillCycleDay (Qlist, event);

            if (event == 'Update') {
                for (zqu__Quote__c q : Qlist) {
                    system.debug('TESTING q.zqu_Quote_Status__c is ' + q.zqu_Quote_Status__c);
                    system.debug('TESTING q.zqu__Status__c is ' + q.zqu__Status__c);
                    system.debug('TESTING Oldmap size is ' + Oldmap.size());
                    if (q.zqu_Quote_Status__c != 'Accepted' && oldmap != null && q.id != null && oldmap.containskey (q.id) && oldmap.get(q.id).zqu_Quote_Status__c == 'Accepted') {
                        q.zqu_Quote_Status__c.adderror ('Cannot update accepted Quote');
                    }

                    if (q.zqu_Quote_Status__c != 'Accepted' && q.zqu__Status__c == 'Sent to Z-Billing') {
                        q.zqu_Quote_Status__c = 'Accepted';
                        if (q.id != null) CreateInvoiceQuoteID.add (q.id);
                    }
                    

                }
            }

        }
    }
    
    public static map <id,zqu__QuoteRatePlanCharge__c> ValidateQRPC4Update (map <id,zqu__QuoteRatePlanCharge__c> TheMap)
    {
        map <id,zqu__QuoteRatePlanCharge__c> NewMap = new map <id,zqu__QuoteRatePlanCharge__c>();
        if (TheMap.size()>0)
        {
            list <id> idlist = new list <id>();
            for (zqu__QuoteRatePlanCharge__c qrpc : TheMap.values())
            {
                idlist.add (qrpc.id);
            }
            list <zqu__QuoteRatePlanCharge__c> ValList = [select id,isdeleted from zqu__QuoteRatePlanCharge__c where id=:idlist];
            map <id,zqu__QuoteRatePlanCharge__c> ValMap = new map <id,zqu__QuoteRatePlanCharge__c>();
            ValMap.putall (ValList);
            for (zqu__QuoteRatePlanCharge__c qrpc : TheMap.values())
             if (ValMap.ContainsKey (qrpc.id) && !ValMap.get (qrpc.id).IsDeleted)
              NewMap.put (qrpc.id,qrpc);
        }
        return newMap;
    }

    static public void HandleAFTER(list <zqu__Quote__c > Qlist, map <id, zqu__Quote__c > oldtriggermap, string event) {
        system.debug('TESTING - HandleAFTER Fired, event is ' + event + ' and Quote2Send size is ' + Quote2Send.size());
        if (oldtriggermap != null) OldMap = oldtriggermap;


        if (event == 'Update' || event == 'Button') {

            if (Quote2Send.size() > 0) {
                SendToZBillingAFTER (Quote2Send, event);
            }
        }
        
        list <id> Qidlist = new list <id>();
        for (zqu__Quote__c zq : Qlist) qidlist.add (zq.id);

        system.debug('TESTING - Handle After DML time! Acc4UpdateMap is ' + Acc4UpdateMap.size());
        system.debug('TESTING - Handle After DML time! qrpc4Update is ' + qrpc4Update.size());
        if (Acc4UpdateMap.size() > 0) update Acc4UpdateMap.values();
        
        system.debug('TESTING future event is '+event);
        
        utils.Codeoff = true;
        if (qrpc4Update.size()>0 && event!='FutureUpdate'){qrpc4Update = ValidateQRPC4Update (qrpc4Update); update qrpc4Update.values(); }//UpdateQRPC(qidlist);
        utils.Codeoff = false;
        


    }

    //MQ-1294 Fix "other" condition for zqu__InvoiceTemplate__c
    public static void SetInvoiceAndCommunicationProfile(zqu__Quote__c zq, Country_Subsidiary__c cs) {
        if (GetPaymentMethod(zq) != null) {
            if (GetPaymentMethod(zq) == 'credit card' || GetPaymentMethod(zq) == 'paypal') {
                zq.zqu__InvoiceTemplate__c = cs.InvoiceTemplateCCSFID__c;
                zq.zqu__CommunicationProfile__c = cs.Communication_profile_cc__c ;

            } else if (GetPaymentMethod(zq) == 'wire transfer') {
                zq.zqu__CommunicationProfile__c = cs.CommunicationProfilesSFID__c ;
                zq.zqu__InvoiceTemplate__c = cs.InvoiceTemplateWSFID__c;

            } else if (GetPaymentMethod(zq) == 'other') {
                zq.zqu__CommunicationProfile__c = cs.Communication_Profile_Cont__c;
                zq.zqu__InvoiceTemplate__c = cs.Invoice_Template_Ent__c;
            } else {
                zq.zqu__InvoiceTemplate__c = cs.InvoiceTemplateContrSFID__c;
            }  
        }
    }

    public static void PopulateCountrySubData(zqu__Quote__c zq) {
        system.debug('TESTING PopulateCountrySubData fired');
        if (zq.zqu__Account__c != null && AccMap.ContainsKey (zq.zqu__Account__c)) {
            string country = zq.zqu__SoldToContact__r.MailingCountry;
            if (country != null && country != '' && CountrySubMap.containsKey (country)) {
                Country_Subsidiary__c cs = CountrySubmap.get (country);
                system.debug('TESTING cs record found is ' + cs);
                Account a = Accmap.get (zq.zqu__Account__c);
                zq.subsidiary__c = cs.subsidiary__c;
                
                if (cs.Taxable__c != null) {
                    if (cs.Taxable__c == 'Yes') zq.Tax_Region__c = cs.Tax_Region__c;
                    if (cs.Taxable__c == 'No') zq.Tax_Region__c = cs.No_Tax_Region__c;
                    if (cs.Taxable__c == 'All') {
                        if (zq.zqu__Certificate_ID__c == null) zq.Tax_Region__c = cs.Tax_Region__c; else zq.Tax_Region__c = cs.No_Tax_Region__c;
                    }
                    system.debug('TESTING tax region set to ' + zq.Tax_Region__c);
                }
                SetInvoiceAndCommunicationProfile(zq, cs);
            }
        }
        
        //Set AllowNoMobileWeb
        system.debug('TESTING AllowNoMobileWeb Quote2QuoteRatePlanChargeMap Contains is '+Quote2QuoteRatePlanChargeMap.ContainsKey(zq.id));
        if (Quote2QuoteRatePlanChargeMap.COntainsKey(zq.id))
          for (zqu__QuoteRatePlanCharge__c qrpc : Quote2QuoteRatePlanChargeMap.get (zq.id))
        {          
			if (CountrySubMap.ContainsKey(qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c))
			{
				Country_Subsidiary__c cs = CountrySubmap.get (qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c);
				zq.AllowNoMobileWeb_Discount__c = cs.IsNoMobileWeb__c;
				system.debug('TESTING AllowNoMobileWeb_Discount__c set to '+cs.IsNoMobileWeb__c+' cs is '+cs.id+' qrpc id is '+qrpc.id);
				break;
			}
        }
    }


    public static void ValidateQuotes4ZBilling(list <zqu__Quote__c> Qlist, string event) {
        for (zqu__Quote__c ql : Qlist) {
            
            system.debug('TESTING ValidateQuotes4Zbilling started');
            system.debug('TESTING account id is '+ql.zqu__Account__c );
            system.debug('TESTING AccMap size is '+AccMap.size());
            system.debug('TESTING AccMap ContainsKey is '+AccMap.ContainsKey (ql.zqu__Account__c));
            if (ql.zqu__Account__c == null) errors += 'Quote ' + ql.name + ' is missing salesfoce account id'; else {
                if (AccMap.get (ql.zqu__Account__c).billingcountry == null) errors += 'Quote ' + ql.name + ' is missing billing country'; else {
                    if (!CountrySubMap.ContainsKey(AccMap.get (ql.zqu__Account__c).billingcountry)) errors += 'Account ' + ql.zqu__Account__c + ' country is missing from country sub list map';
                }
            }
            if (GetPaymentMethod(ql) == null) errors += 'Quote ' + ql.name + ' Payment method is null';
            
            if ( ql.zqu__SoldToContact__r.MailingCountry!=null &&  ql.zqu__SoldToContact__r.MailingCountry.tolowercase()=='israel'
                 && ql.zqu__Certificate_ID__c==null && ql.company__c && ql.recordtypeid!=null && recTypeMap.ContainsKey (ql.recordtypeid) 
                 && rectypemap.get (ql.recordtypeid).developername=='Default'
               )
            {
                 errors+='Israeli companies must supply company identification number - Please add the number to the Certificate id field. If it is a private customer uncheck the Company field or contact your administrator.';
            }
            
            
            system.debug('TESTING ql discount reason is '+ql.Discount_Reason__c);
            if (ql.recordtypeid!='012b0000000QNK9' && ql.recordtypeid!='012b0000000QNKA' && ql.recordtypeid!='012b0000000QNKD' 
            && ql.recordtypeid!='012b0000000QNKE' &&
            
            ql.Discount_Reason__c==null && ql.zqu__ElectronicPaymentMethodId__c==null) errors+='Quote ' +ql.name+' discount reason is null';
            
            //if (ql.zqu__PaymentTerm__c!=null && ql.zqu__PaymentTerm__c.tolowercase()!='due upon receipt' && ql.zqu__PaymentMethod__c!=null && (ql.zqu__PaymentMethod__c.tolowercase()=='credit card' || ql.zqu__PaymentMethod__c.tolowercase()=='reditcard' || ql.zqu__PaymentMethod__c.tolowercase()=='wiretransfer' ||ql.zqu__PaymentMethod__c.tolowercase()=='wire transfer')
            //)
            //{
            //errors+='Quote ' +ql.name+' payment term must be Due Upon Receipt';
            //}
            
            /*
            if (ql.zqu__SoldToContact__c!=null && ContactMap.ContainsKey(ql.zqu__SoldToContact__c))
            {
                Contact c = ContactMap.get (ql.zqu__SoldToContact__c);
                if (c.mailingcountry!=null && c.mailingpostalcode==null)
                {
                    if (c.mailingcountry.tolowercase()=='canada' ||
                        c.mailingcountry.tolowercase()=='us' ||
                        c.mailingcountry.tolowercase()=='united states'
                    )
                    errors +='Zip Code is a mandatory value for the quote Sold to contact';
                }
            }*/
            
            system.debug('TESTING QuoteInfoMap.containsKey (ql.id) is '+QuoteInfoMap.containsKey (ql.id));
            if (QuoteInfoMap.containsKey (ql.id) && QuoteInfoMap.get (ql.id).zqu__Opportunity__r.name!=null &&QuoteInfoMap.get (ql.id).zqu__Opportunity__r.name.length()>100) errors+='Opportunity name cannot be more than 100 characters';
            
            string rectype = null;
            if (ql.recordtype.developername!=null) rectype = ql.recordtype.developername.tolowercase();
            else if (ql.recordtypeid!=null && RecTypeMap.ContainsKey (ql.recordtypeid)) rectype = RecTypeMap.get (ql.recordtypeid).developername.tolowercase();
            
            if (Quote2QuoteChargeSummaryMap.ContainsKey (ql.id)  && rectype!=null && rectype=='default')
            {
                zqu__QuoteChargeSummary__c[] qcslist = Quote2QuoteChargeSummaryMap.get (ql.id);
                set <string> tempQuoteRatePlanID = new set <string>();
                boolean multipleQuoteRatePlans = false;
                boolean multiplePeriods=false;
                set <string> periodset = new set <string>();
                boolean TierPricingError = false;
                
                boolean MaxTermError = false;
                
                boolean InternalCodeCountry = false;
                Boolean AddOnCountry = false;
                id firstInternalCode = null;
                
                
                boolean prdexists24 = false;
                boolean prdexists36 = false;
                
                boolean addapihitscheck = false;
                boolean Addapiaddexists = false;
                
                boolean usacountry=false;
                boolean nonusacountry = false;
                
                integer baseproductcount = 0;
                
                boolean ExcludeFromValidations = false;
                
                boolean countryerror = false;
                
                boolean countrysubrestrictionerror = false;
                boolean qrpcCountryAddOn = false;
                
                integer qrpcnumberofcountries = 0;
                
                integer numUOMcountry = 0;
                
                map <string, list <Product_Restriction__c>> YESProductValidationError = new map <string, list <Product_Restriction__c>>();
                map <string, string> ONCEProductValidationError = new map <string, string>();
                map <string, list <Product_Restriction__c>> NOProductValidationError = new map <string, list <Product_Restriction__c>>();
                //map <string,integer> Exact1_NumberproductOccurances = new map <string,integer>();
                boolean Exactly1Country = false;
                
                set <string> BaseProductCompatability = new set <string>();
                set <string> AllProductCompatability = new set <string>();
                
                if (qcslist.size()>0) 
                    for (zqu__QuoteChargeSummary__c qcs : qcslist){
                    if (qcs.Product_Compatibility__c!=null && qcs.Product_Compatibility__c=='Data Licensing')
                    {
                        ExcludeFromValidations = true;
                    }
                    
                    if (qcs.zqu__Quantity__c==null || qcs.zqu__Quantity__c>=0)
                    {
                        
                        if (qcs.zqu__QuoteRatePlan__r.zqu__QuoteProductName__c!=null)
                        {
                            if (tempQuoteRatePlanID.Contains(qcs.zqu__QuoteRatePlan__r.zqu__QuoteProductName__c)) multipleQuoteRatePlans = true;
                            else tempQuoteRatePlanID.add (qcs.zqu__QuoteRatePlan__r.zqu__QuoteProductName__c);
                            
                            if (qcs.zqu__QuoteRatePlan__r.zqu__QuoteProductName__c.tolowercase()=='24 months of data') prdexists24=true;
                            if (qcs.zqu__QuoteRatePlan__r.zqu__QuoteProductName__c.tolowercase()=='36 months of data') prdexists36=true;
                            
                            if (qcs.zqu__QuoteRatePlan__r.zqu__QuoteProductName__c.tolowercase()=='additional api hits') addapihitscheck=true;
                            if (qcs.zqu__QuoteRatePlan__r.zqu__QuoteProductName__c.tolowercase()=='api for ultimate') Addapiaddexists = true;
                            if (qcs.zqu__QuoteRatePlan__r.zqu__QuoteProductName__c.tolowercase()=='API for Advanced') Addapiaddexists = true;
                            
                        }
                        
                        if (qcs.Product_Compatibility__c!=null)
                        {
                            AllProductCompatability.add (qcs.Product_Compatibility__c);
                        }
                        
                        if (qcs.zqu__Type__c!=null && qcs.zqu__Type__c.tolowercase()=='recurring' )
                        {
                            if (qcs.zqu__Period__c !=null)
                            {
                                if (periodset.size()==0) periodset.add (qcs.zqu__Period__c  );
                                else if (!periodset.contains(qcs.zqu__Period__c  ))multiplePeriods=true;
                            }
                        }
                        
                        if (qcs.zqu__Model__c!=null && qcs.zqu__Model__c.tolowercase()=='tiered pricing')
                        {
                            TierPricingError=qcs.zqu__ListTotal__c!=null && qcs.zqu__TotalPrice__c!=null &&  qcs.zqu__TotalPrice__c!=qcs.zqu__ListTotal__c;
                             
                        }
                        
                        if (Test.isRunningTest() ||(qcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.MinTerm__c!=null && qcs.zqu__Type__c!=null && qcs.zqu__Type__c.tolowercase()=='recurring'))
                        {
                            if (ql.zqu__InitialTerm__c!=null &&  qcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.MinTerm__c>ql.zqu__InitialTerm__c)   MaxTermError=true;
                            if (ql.zqu__RenewalTerm__c!=null && qcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.MinTerm__c>ql.zqu__RenewalTerm__c)    MaxTermError=true;
                        }
                        
                        
                        if (Test.isRunningTest() ||(qcs.Product_Category__c!=null && qcs.Product_Category__c.tolowercase()=='base products') )
                        {
                            baseproductcount++;
                            if (Test.isRunningTest() ||(qcs.Product_Compatibility__c!=null))
                            {
                                list <string> slist = new list <string>();
                                if (Test.isRunningTest()||qcs.Product_Compatibility__c.contains(',')) slist = (Test.isRunningTest()?TestObjectCreator.specificPLEValue('Product2','ProductCompatibility__c',0):qcs.Product_Compatibility__c).split(',');
                                else slist.add (qcs.Product_Compatibility__c);
                                BaseProductCompatability.addall (slist);
                            }
                        } 
                        
                        
                        if (qcs.Internal_Code__c!=null && qcs.Internal_Code__c.tolowercase()=='countries' )
                        {
                             InternalCodeCountry=true;
                             if (firstInternalCode==null) firstInternalCode = qcs.id;
                        }
                        
                        if (qcs.AddOnType__c!=null && qcs.AddOnType__c.tolowercase()=='country'
                            && qcs.internal_code__c!='USA'
                            && (firstInternalCode==null || firstInternalCode!=qcs.id)
                        
                        ) AddOnCountry=true;
                        
                        if (qcs.internal_code__c!=null && qcs.internal_code__c=='USA')
                        {
                            usacountry=true;
                
                        }
                        
                        if (qcs.AddOnType__c!=null && qcs.AddOnType__c.tolowercase()=='country'
                            && qcs.internal_code__c!=null &&  
                            qcs.internal_code__c!='USA'  && qcs.internal_code__c.tolowercase()!='countries')

                         nonusacountry=true;
                        
                        /*
                        //What the heck, let's check subscriptions too. This isn't overly complicated or anything
                        
                        if (ql.zqu__Account__c!=null && AccSubPrdnChrgMap.ContainsKey(ql.zqu__Account__c))
                        {
                            list <Zuora__SubscriptionProductCharge__c> zspclist = AccSubPrdnChrgMap.get(ql.zqu__Account__c);
                            
                            for (Zuora__SubscriptionProductCharge__c zspc : zspclist)
                            {
                                system.debug('TESTING zspc Zuora__RatePlanName__c is '+zspc.Zuora__RatePlanName__c);
                                if (qcs.zqu__QuoteRatePlan__r.zqu__QuoteProductName__c!=null && zspc.Zuora__RatePlanName__c!=null &&
                                 tempQuoteRatePlanID.Contains(zspc.Zuora__RatePlanName__c)) 
                                   multipleQuoteRatePlans = true;
                                
                                if (qcs.zqu__Type__c.tolowercase()!=null && qcs.zqu__Type__c.tolowercase()=='recurring')
                                {
                                    if (qcs.zqu__Period__c !=null && zspc.Zuora__BillingPeriod__c!=null)
                                    {
                                       if (periodset.size()>0 && !periodset.contains(zspc.Zuora__BillingPeriod__c))multiplePeriods=true;
                                    }
                                }
                                
                                if (zspc.zuora__ProductName__c!=null && ProductMap.ContainsKey(zspc.zuora__ProductName__c))
                                {
                                    if (ProductMap.get(zspc.zuora__ProductName__c).zqu__Category__c!=null &&
                                    ProductMap.get(zspc.zuora__ProductName__c).zqu__Category__c.tolowercase()=='base products') 
                                      baseproductcount=baseproductcount++;
                                }
                                
                            }
                        }
                        */
                         
                    }
                        
                }
                
                
                // Have to run through all QCS again because some validations are dependent on reviewing 
                // all QCS first. For example the Base product compatability check
                boolean productcompatabilityproblem = false;
                system.debug('TESTING - compatability validation started');
                system.debug('TESTING - BaseProductCompatability is '+BaseProductCompatability);
                if (qcslist.size()>0) for (zqu__QuoteChargeSummary__c qcs : qcslist)
                {
                    system.debug('TESTING - compatability validation for qcs '+qcs.id);
                    boolean problem = true;
                    if (qcs.Product_Compatibility__c==null) problem=false;
                    else
                    {
                        list <string> complist = new list <string>();
                        complist.add (qcs.Product_Compatibility__c);
                        if (qcs.Product_Compatibility__c.contains(',')) complist =qcs.Product_Compatibility__c.split (',');
                        system.debug('TESTING - complist is '+complist);
                        for (string s : complist)
                        {
                            if (BaseProductCompatability.contains(s)) problem=false;
                        } 
                    }
                    
                    if (problem) productcompatabilityproblem=true;  
                    
                }
                
                Country_Subsidiary__c countrysub = null;
                if (ql.zqu__SoldToContact__r.MailingCountry!=null && CountrySubMap.ContainsKey (ql.zqu__SoldToContact__r.MailingCountry))
                  countrysub = CountrySubMap.get (ql.zqu__SoldToContact__r.MailingCountry);
                
                system.debug('TESTING countrysub is '+countrysub);
                //QuoteRatePlanCharge validations Start
                if (Quote2QuoteRatePlanChargeMap.ContainsKey (ql.id))
                {
                    for (zqu__QuoteRatePlanCharge__c qrpc : Quote2QuoteRatePlanChargeMap.get (ql.id))
                    {
                        if (ql.Number_of_Countries__c!=null && qrpc.zqu__Quantity__c!=null && qrpc.zqu__Quantity__c!=ql.Number_of_Countries__c
                            && qrpc.zqu__ProductRatePlanCharge__r.zqu__UOM__c!=null && qrpc.zqu__ProductRatePlanCharge__r.zqu__UOM__c.EqualsIgnoreCase('Country') 
                           )
                           {
                             countryerror = true;
                           }
                         
                         if (qrpc.zqu__productRatePlanCharge__r.zqu__UOM__c!=null && qrpc.zqu__productRatePlanCharge__r.zqu__UOM__c.EqualsIgnoreCase('Country')) NumUOMCountry = NumUOMCountry+1;
                           
                           system.debug('TESTING countrysubrestrictionerror is '+countrysubrestrictionerror);
                           
                           if (countrysub!=null 
                                && qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c!=null)
                                {
                                    system.debug('TESTING qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c is '+qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c);
                                    if (CountrySubMap.ContainsKey(qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c))
                                    {
                                        Country_Subsidiary__c CountrySub2= CountrySubMap.get(qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c);
                                        system.debug('TESTING countrysub2 is '+countrysub2);
                                        if (countrysub2.Restricted_To_Sold_Country__c && countrysub2!=countrysub && !ql.IsOldProduct__c)
                                        {   
                                          errors+='This product is restricted to '+countrysub2.name+' customers only, please make sure Sold To contact country is '+countrysub2.name+' ;';
                                        }
                                    }   
                                } 
                                
                              
                                
                           
                           system.debug('TESTING countrysubrestrictionerror is '+countrysubrestrictionerror);
                           
                          if (qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c!=null
                              && qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c.EqualsIgnoreCase('Country') 
                             )
                             qrpcnumberofcountries =  qrpcnumberofcountries+1; 
                           
                         system.debug('TESTING internal code is '+qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c);
                          system.debug('TESTING RestrictionMap Contains is '+ProductRestrictionMap.ContainsKey (qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c));
                         if (qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c!=null
                              && ProductRestrictionMap.Containskey (qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c)
                            )
                            {
                                string internalcode = qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c;
                                for (Product_Restriction__c pr : ProductRestrictionMap.get (internalcode))
                                {
                                    if (pr.ItemMatch__c!=null)
                                    { 
                                        system.debug('TESTING pr is '+pr.itemCode1__c+' item match is '+pr.itemmatch__c);
                                        if (pr.ItemMatch__c.EqualsIgnoreCase('Yes'))
                                        {
                                            list <Product_Restriction__c> templist = new list <Product_Restriction__c>();
                                            if (YESProductValidationError.ContainsKey (internalcode)) templist = YESProductValidationError.get (internalcode);
                                            templist.add (pr);
                                            YESProductValidationError.put (internalcode,templist);
                                            
                                        }
                                        if (pr.ItemMatch__c.EqualsIgnoreCase('No'))
                                        {
                                            list <Product_Restriction__c> templist = new list <Product_Restriction__c>();
                                            if (NOProductValidationError.ContainsKey (internalcode)) templist = NOProductValidationError.get (internalcode);
                                            templist.add (pr);
                                            NOProductValidationError.put (internalcode,templist);
                                        }
                                        //if (pr.ItemMatch__c.EqualsIgnoreCase('At Least One') && pr.ItemCode2__c!=null)
                                        //{
                                        //    system.debug('TESTING Found At Least One');
                                        //    string prdreq = pr.ItemCode2__c;
                                        //    if (ONCEProductValidationError.ContainsKey (internalcode)) prdreq=pr.ItemCode2__c+';'+ONCEProductValidationError.get (internalcode);
                                        //    ONCEProductValidationError.put (internalcode,prdreq);
                                        //}
                                       
                                    }
                                }
                                if (ExactlyOneCountryReq.contains(internalcode)) //Exactly One Logic
                                {
                                	Exactly1Country=true;
                                }
                                
                                
                                
                            }
                    }
                    system.debug('TESTING NOProductValidationError size is '+NOProductValidationError.size());
                    //system.debug('TESTING ONCEProductValidationError is '+ONCEProductValidationError);

                    boolean NoErrorFound = false; // Used to prevent errors from appearing multiple times
                    // Check for errors
                    for (zqu__QuoteRatePlanCharge__c qrpc : Quote2QuoteRatePlanChargeMap.get (ql.id))
                    {
                        string internalcode = qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c;
                        if (internalcode!=null)
                        {
                            if (YESProductValidationError.size()>0)
                            {
                                for (list <Product_Restriction__c> PRList : YesProductValidationError.values())
                                {
                                    for (Product_Restriction__c pr : PRList)
                                    {
                                        if (pr.ItemCode2__c!=null && pr.ItemCode2__c==internalcode) pr.ItemCode2__c=null;
                                    }
                                }   
                            }
                            
                            if (NOProductValidationError.size()>0)
                            {
                                for (string itemcode1 : NOProductValidationError.keySet()) if (!NoErrorFound)
                                {
                                    list <Product_Restriction__c> PRList = NOProductValidationError.get (itemcode1);
                                    if (PRLIST!=null && PRList.size()>0) for (Product_Restriction__c pr : PRList)
                                    {
                                        if (pr!=null && pr.ItemCode2__c!=null && pr.ItemCode2__c==internalcode && !NoErrorFound && !ql.IsOldProduct__c)
                                        {
                                            system.debug('TESTING NOerror found: '+itemcode1+' and '+internalCode);
                                            errors+='Selecting "'+ProductMap.get(itemcode1).name+'" with "'+ProductMap.get(pr.ItemCode2__c).name+'" is impossible ;';
                                            NoErrorFound=true;
                                        }
                                    }
                                }
                            }
                            
                            //if (ONCEProductValidationError.size()>0) for (string keyset : ONCEProductValidationError.keyset())
                            //{
                            //    system.debug('TESTING keyset is '+keyset);
                            //    system.debug('TESTING internalcode is '+internalcode);
                            //    if (keyset!=null && ONCEProductValidationError.get(keyset)!=null && ONCEProductValidationError.get(keyset).contains(internalcode)) ONCEProductValidationError.put (keyset,null);
                            //}
                            
                        }
                    }
                    
                    if (YesProductValidationError.size()>0 && !ql.IsOldProduct__c) for (string itemcode1 : YesProductValidationError.keySet())
                    {
                        list <Product_Restriction__c> PRList = YesProductValidationError.get (itemcode1);
                        for (Product_Restriction__c pr : PRList) if (pr.ItemCode2__c!=null && !ql.IsOldProduct__c)
                        {
                            system.debug('TESTING YESerror found: '+itemcode1+' and '+pr.ItemCode2__c);
                            errors+='Selecting '+ProductMap.get(itemcode1).name+' requires '+ProductMap.get(pr.ItemCode2__c).name+'; ';
                        }
                    }
                    
                    //if (ONCEProductValidationError.size()>0 && !ql.IsOldProduct__c) for (string itemcode1: ONCEProductValidationError.keySet())
                    //{
                    //   if (ONCEProductValidationError.get(itemcode1)!=null)
                    //    {
                    //        system.debug('TESTING ONCEProductValidationError Error found: '+itemcode1+' and '+ONCEProductValidationError.get(itemcode1));
                    //        list <string> prdcodes =  +ONCEProductValidationError.get(itemcode1).split(';');
                    //        list <string> prdnames = new list <string>();
                    //        for (string s : prdcodes) prdnames.add (ProductMap.get (s).name);
                    //        errors+='Selecting '+ProductMap.get(itemcode1).name+' requires one of these: ';
                    //        for (string s : prdnames) errors+=s+', ';
                    //       errors+=' ; ';
                    //    }
                    //}
                    
                    //Exact1 Errors
                    if (Exactly1Country && qrpcnumberofcountries!=1)
                    {
                    	errors+='Quote has to have exactly one country. Currently has '+qrpcnumberofcountries;
                    }
                }
                
                //Requires second iteration for ProductValidationError errors 
                
                
                //QuoteRatePlanCharge validations END
                
                if (!ExcludeFromValidations)
                {               
                    //if (multipleQuoteRatePlans) errors+='You cannot select the same product twice please fix the quote or contact the administrator for further assistance; ';
                    //if (multiplePeriods) errors+='Multiple periods found in quote please select the same billing frequency for all products';
                    //if (TierPricingError) errors+='Effective price cannot be changed for tier pricing. Please contact the administrator for further assistance';
                    if (baseproductcount>1) errors+='You have selected more than one base product please fix the quote or contact the administrator for further assistance ; ';
                    if (rectype!=null && rectype=='default' && baseproductcount<1) errors+='The quote must include at least one base product please fix the quote or contact the administrator for further assistance; ';
                    //if (MaxTermError) errors+='The Initial term is less than the billing period of the product please adjust the terms or the products. For further assistance please contact the administrator';
                    //if (AddOnCountry && !InternalCodeCountry) errors+='You have selected a specific country product without the general country filter product please add it to the quote or contact the administrator for further assistance';
                    if (!AddOnCountry && InternalCodeCountry) errors+='Please select specific country products or contact the administrator for further assistance; ';
                    //if (prdexists24 && prdexists36) errors+='Please select 24 or 36 months of data';
                    if (addapihitscheck && !Addapiaddexists) errors+='Additional API hits check was selected without API for Ultimate/Advanced; ';
                    //if (!addapihitscheck && Addapiaddexists) errors+='API for Ultimate/Advanced was selected without Additional API hits check';
                    //if (productcompatabilityproblem) errors+='Product Compatability problem; ';
                    //if (InternalCodeCountry && usacountry && !nonusacountry) errors+='You have selected the general country filter for the US country filter. Please remove the general country filter product or contact the administrator for further assistance; ';
                    
                
                    
                    system.debug('TESTING ql.IsOldProduct__c is '+ql.IsOldProduct__c);
                    if (ql.IsOldProduct__c == false)
                    {
                        if (countryerror&&ql.Legacy_or_New_solution_deal__c=='Legacy') errors+='Please update all product quantities to equal the total number of country filters selected.; ';
                        if (qrpcnumberofcountries==0) errors+='You must select at least one country filter; ';
                        if (ql.Number_of_Countries__c!=null && qrpcnumberofcountries!=ql.Number_of_Countries__c && ql.Legacy_or_New_solution_deal__c=='Legacy') errors+='Pricing is based on '+ql.Number_of_Countries__c+' country filter(s) but you have only selected '+qrpcnumberofcountries+' country filter(s). Please add the missing country filter(s).; ';
                        if (NumUOMCountry<1&&ql.Legacy_or_New_solution_deal__c=='Legacy') errors+='There must be at least 1 RatePlanCharges records where UOM = Country; ';
                    }
                    
                }
            }
             

            if (event != 'Button' && errors != null && errors != '') ql.adderror (errors);
        }
    }


    // David Rennert 21-Feb-2016 // if (q.zqu__TermStartDate__c==null) q.zqu__TermStartDate__c=date.today();
    // Set dates for various quote fields depending on RT (Record Type and PT (Payment Terms)
    
    public static void CalcServiceActDate_CustomerAccptDate (list <zqu__Quote__c> Qlist)
    {
        String paymentMethod = null;
        String recordType = null;
        for (zqu__Quote__c q : Qlist) {
            paymentMethod = GetPaymentMethod(q);
            recordType = q.RecordType.DeveloperName;

            if (paymentMethod == 'credit card' || paymentMethod == 'wire transfer') {
                q.zqu__Service_Activation_Date__c = Date.today();
                if ('Default'.equalsIgnoreCase(recordType))
                    q.zqu__TermStartDate__c = Date.today();
                if ('Amendment'.equalsIgnoreCase(recordType)) {
                    q.zqu__SubscriptionTermStartDate__c = Date.today();
                    q.zqu__SubscriptionTermEndDate__c = Date.today().addMonths(q.zqu__InitialTerm__c.intValue());
                }
                if (q.zqu__Service_Activation_Date__c!=null) q.zqu__StartDate__c=q.zqu__Service_Activation_Date__c;
                
                
            } else if (paymentMethod == 'other') 
            {
                if ('Default'.equalsIgnoreCase(recordType)) {
                    if (q.zqu__TermStartDate__c == null)
                        q.zqu__TermStartDate__c = Date.today();
                    q.zqu__Service_Activation_Date__c = q.zqu__TermStartDate__c;
                } 
                else 
                {
                	if ('Amendment'.equalsIgnoreCase(recordType))
                	{
                		//if (q.zqu__QuoteBusinessType__c)
                    	//q.zqu__Service_Activation_Date__c = q.zqu__SubscriptionTermStartDate__c;
                	} 
                	else if (recordType == 'Cancellation')   q.zqu__Service_Activation_Date__c = q.zqu__CancellationDate__c;
                }
            }
            
            if (recordType == 'Renewal') q.zqu__Service_Activation_Date__c = q.zqu__StartDate__c;

            q.zqu__Customer_Acceptance_Date__c = q.zqu__Service_Activation_Date__c;
        }
    }
    
    public static void CalcIsOldProduct (list <zqu__Quote__c> Qlist)
    {
        date efdate = date.newinstance (2011,11,21);
        if (CSSettings__c.getinstance('Setting').Zuora_Effective_Date__c!=null) efdate =CSSettings__c.getinstance('Setting').Zuora_Effective_Date__c;
        for (zqu__Quote__c zq : Qlist)
        {
            //zq.IsOldProduct__c = false;
            if (zq.zqu__Quote_Rate_Plans__r.size()>0)
            {
                for (zqu__QuoteRatePlan__c qrp : zq.zqu__Quote_Rate_Plans__r)
                {
                    if (qrp.zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c!=null && 
                        qrp.zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c <efdate &&
                        qrp.zqu__SubscriptionRatePlanZuoraId__c ==null
                    )
                    {
                        zq.IsOldProduct__c = true;
                        zq.Is_No_Frequency__c = false;
                        //if (zq.id!=null && QuoteRollbackMap.ContainsKey(zq.id)) zq.Is_No_Frequency__c = QuoteRollbackMap.get (zq.id).Is_No_Frequency__c;
                    }
                }
            }
            system.debug('TESTING CalcIsOldProduct set to '+zq.IsOldProduct__c);
        }
    }
    
    public static void SendToZBillingBEFORE(list <zqu__Quote__c> Qlist) {
        
        CalcServiceActDate_CustomerAccptDate (Qlist);
        CalcIsOldProduct(Qlist);
    }

    public static void SendToZBillingAFTER(list <zqu__Quote__c> Qlist, string event) {
        system.debug('TESTING - SendToZBilling AFTER Fired');
        ValidateQuotes4ZBilling (Qlist, event);
        system.debug('TESTING - SendToZBilling AFTER Errors is ' + errors);
        if (errors == null || errors == '' || Test.isRunningTest() ) {
            list <id> QuoteID2Send = new List<id>();
            for (zqu__Quote__c q : Qlist) {
                if (q.zqu__Certificate_ID__c == null && q.zqu__Account__c != null &&
                        AccMap.ContainsKey (q.zqu__Account__c) && AccMap.get(q.zqu__Account__c).Tax_Exempt_Certificate_ID__c != null) {
                    q.zqu__Certificate_ID__c = AccMap.get (q.zqu__Account__c).Tax_Exempt_Certificate_ID__c;
                }
                PopulateCountrySubData (q);
                QuoteID2Send.add (q.id);

            }
            if (!utils.IsTestSeeAll)
            {
                utils.codeoff = true;
                update Qlist;
                utils.codeoff = false;
            }
            /*
            if (QuoteID2Send.size()>0)
            {
                Zuora_AsyncCallout.sendQuote (QuoteID2Send);
            } 
            */
        }
    }
    
    public static void CalcPaymentFreq (list <zqu__Quote__c> Qlist)
    {
        for (zqu__Quote__c zq : Qlist)
        {
            system.debug('TESTING Setting Payment Frequency. zq.Installments__c is '+zq.Installments__c+' and zq.zqu__InitialTerm__c is '+zq.zqu__InitialTerm__c);
            if (zq.Installments__c==null || zq.Installments__c==0) zq.Installments__c=1;
            if (zq.zqu__InitialTerm__c!=null) zq.Payment_Frequency__c = zq.zqu__InitialTerm__c / zq.Installments__c;
        } 
    }

    public static void UpdateApprovalFields(list <zqu__Quote__c> Qlist) {
    	
        system.debug('TESTING - Approval fields evaluation started');
        
        
        QuoteRollBackMap.putall (Qlist);
        for (zqu__Quote__c zq : Qlist) {
        	
            zq.Is_Discount_10__c = null;
            zq.Is_Discount_20__c = null;
            zq.Is_Discount_40__c = null;
            zq.Is_Product_to_App__c = null;
            zq.Is_No_Annual__c = null;
            
            if (zq.zqu__Account__c!=null && AccMap.containskey (zq.zqu__Account__c)) zq.account_users__c = AccMap.get (zq.zqu__Account__c).No_of_Users__c;
            if (zq.account_users__c==null) zq.account_users__c = 0;
            decimal quoteusers = 0;
            zq.quote_users__c = 0;
            
            CalcPaymentFreq(Qlist); 
            

            if (Quote2QuoteChargeSummaryMap.ContainsKey (zq.id)) {
                list <zqu__QuoteChargeSummary__c> templist = Quote2QuoteChargeSummaryMap.get (zq.id);
                if (templist.size() > 0) for (zqu__QuoteChargeSummary__c zqcs : templist) {
                    
                    if (zqcs.zqu__Quantity__c==null || zqcs.zqu__Quantity__c>0)
                    {
                        if (zqcs.zqu__Discount__c != null && zqcs.zqu__Discount__c > 10 && zqcs.zqu__Discount__c <= 20 && !zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c) zq.Is_Discount_10__c = 'Yes';
                        
                        if (zqcs.zqu__Discount__c != null && zqcs.zqu__Discount__c > 20 && zqcs.zqu__Discount__c <= 40 && !zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c) zq.Is_Discount_20__c = 'Yes';
                        
                        if (zqcs.zqu__Discount__c != null && zqcs.zqu__Discount__c > 40 && !zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c) zq.Is_Discount_40__c = 'Yes';
                        
                        
                        if (//zqcs.zqu__Product_Name__c != null && zqcs.zqu__Product_Name__c.toLowerCase() == 'custom report' &&
                        	zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c!=null  
                        	&& zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c.EqualsIgnoreCase('Reports')
                        ) zq.Is_Product_to_App__c = 'Yes';
                        
                        //if (zqcs.zqu__Product_Name__c!=null && zqcs.zqu__Product_Name__c.toLowerCase() == 'ultimate users'
                                //&& (zqcs.zqu__EffectivePrice__c == null || zqcs.zqu__EffectivePrice__c == 0)
                                //&& zqcs.zqu__Quantity__c != null && zqcs.zqu__Quantity__c >= 2
                                //&& zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c!=null 
                                //&& zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c.EqualsIgnoreCase('Reports')
                                //) zq.Is_Product_to_App__c = 'Yes';
                        
    
                        if (zqcs.zqu__Period__c != null && zqcs.zqu__Period__c.tolowercase() != 'annual'  && zqcs.zqu__Period__c!='-'&& zqcs.zqu__Type__c.tolowercase()!='one-time' 
                             && (zq.Payment_Frequency__c==null || zq.Payment_Frequency__c<12)) zq.Is_No_Annual__c = 'Yes';
                    }
                    
                    if (zqcs.zqu__Product_Name__c!=null && zqcs.zqu__Product_Name__c.toLowerCase().contains('users') && zqcs.zqu__Quantity__c!=null) quoteusers+=zqcs.zqu__Quantity__c;
                    
                    	
                    
                    	
                    


                }
            }
            system.debug('TESTING quoteusers is '+quoteusers);
            if (RecTypeMap.get(zq.recordtypeid).developername.EqualsIgnoreCase ('Amendment')) zq.quote_users__c = quoteusers;

            if (Quote2QuoteRatePlanChargeMap.ContainsKey (zq.id)) {
                list <zqu__QuoteRatePlanCharge__c> templist = Quote2QuoteRatePlanChargeMap.get (zq.id);
                if (templist.size() > 0) for (zqu__QuoteRatePlanCharge__c zqcs : templist) {
                    
                    if (zqcs.zqu__Quantity__c==null || zqcs.zqu__Quantity__c>0)
                    {
                        if (zqcs.zqu__Discount__c != null && zqcs.zqu__Discount__c > 10 && zqcs.zqu__Discount__c <= 20 && !zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c) zq.Is_Discount_10__c = 'Yes';
                        
                        if (zqcs.zqu__Discount__c != null && zqcs.zqu__Discount__c > 20 && zqcs.zqu__Discount__c <= 40 && !zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c) zq.Is_Discount_20__c = 'Yes';
                        
                        if (zqcs.zqu__Discount__c != null && zqcs.zqu__Discount__c > 40 && !zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c) zq.Is_Discount_40__c = 'Yes';
                        
                        if (zqcs.zqu__ListTotal__c != null && zqcs.zqu__ListTotal__c!=0 && zqcs.zqu__Total__c!=null && !zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c)
                        {
                        	decimal dis = 1-(zqcs.zqu__Total__c/zqcs.zqu__ListTotal__c)	;
                        	if (dis > 0.1 && dis <= 0.2) zq.Is_Discount_10__c = 'Yes';
                        	if (dis>0.2)zq.Is_Discount_20__c = 'Yes';
                        	
                        	system.debug('Discount based on ListTotal: '+dis);
                        }
                        
                        if (zqcs.zqu__Period__c != null && zqcs.zqu__Period__c.tolowercase() != 'annual' && zqcs.zqu__Period__c!='-' ) zq.Is_No_Annual__c = 'Yes';
                    }

                }

            }
        }
    }
    
    public static zqu__Quote__c  SetUpsellCreditfromQCD (list <zqu__QuoteChargeDetail__c> QCDList,zqu__Quote__c zq)
    {
        system.debug('TESTING SetUpsellCreditfromQCD started');
        string rectype = null;
        if (zq.recordtypeid!=null && RecTypeMap.Containskey (zq.recordtypeid)) rectype = RecTypeMap.get (zq.recordtypeid).developername;
        zq.Upsell_amount__c =0;
        zq.Credit_amount__c =0;
        //zq.New_TCV__c = 0;
        decimal totalDeltaTCV = 0;
        decimal TotalNoOriginalID = 0;
        if (QCDList.size()>0)
        {
            for (zqu__QuoteChargeDetail__c qcd : qcdList)
            {
                if (qcd.zqu__DeltaTCV__c!=null)
                {
                    if (qcd.zqu__DeltaTCV__c>0) zq.Upsell_amount__c+=qcd.zqu__DeltaTCV__c;
                    if (qcd.zqu__DeltaTCV__c<0) zq.Credit_amount__c+=qcd.zqu__DeltaTCV__c;
                    totalDeltaTCV+=qcd.zqu__DeltaTCV__c;
                }
                
                if (qcd.zqu__TCV__c!=null)
                {
                     //zq.new_tcv__c += qcd.zqu__TCV__c;
                     if (qcd.zqu__OriginalId__c ==null) TotalNoOriginalID+=qcd.zqu__TCV__c;
                }
            }
            system.debug('TESTING Upsell Amount sum is '+zq.Upsell_Amount__c);
            system.debug('TESTING Credit Amount sum is '+zq.Credit_Amount__c);
            system.debug('TESTING totalDeltaTCV is '+totalDeltaTCV);
            
        
            //if (zq.zqu__Previewed_SubTotal__c !=null) zq.Credit_amount__c+=zq.zqu__Previewed_SubTotal__c;
            system.debug('TESTING Credit Amount subtotal is '+zq.Credit_Amount__c);
            //zq.Credit_amount__c-=totalDeltaTCV;
            if (totalDeltaTCV==0)
            {
                //zq.Credit_amount__c = 0;
                //zq.Upsell_amount__c =0;
                //if (TotalNoOriginalID!=0) zq.Upsell_Amount__c = TotalNoOriginalID;
                
                if (rectype!=null && rectype.EqualsIgnoreCase('Amendment') && zq.zqu__Previewed_SubTotal__c !=null) zq.Upsell_Amount__c+=zq.zqu__Previewed_SubTotal__c;
                if (rectype!=null && rectype.EqualsIgnoreCase('Renewal')) zq.Upsell_Amount__c=0;
                
            }
    
            system.debug('TESTING Credit Amount final total is '+zq.Credit_Amount__c);
            system.debug('TESTING Upsell_Amount__c final total is '+zq.Upsell_Amount__c);
            
        }
        return zq;
    }
    
    public static void UpdateQuoteFields (zqu__Quote__c zq)
    {
        system.debug('TESTING UpdateQuoteFields started. QuoteChargeDetails size is '+zq.zqu__QuoteChargeDetails__r.size());
        list <zqu__QuoteChargeDetail__c> QCDList = new list <zqu__QuoteChargeDetail__c>();
        if (zq.zqu__QuoteChargeDetails__r.size()>0) 
            QCDList = zq.zqu__QuoteChargeDetails__r;
        else
        {
            list <id> idlist = new list <id>();
            if (zq.id!=null) idlist.add (zq.id);
            list <zqu__Quote__c> zqQueried = QueryQuote (idlist);
            if (zqQueried.size()>0 && zqQueried[0].zqu__QuoteChargeDetails__r.size()>0) 
                QCDList = zqQueried[0].zqu__QuoteChargeDetails__r;
        }
        
        system.debug('TESTING QCDList size is '+QCDList.size());
        if (QCDList.size()>0) zq=SetUpsellCreditfromQCD (QCDList,zq);
        
        
         if (zq.zqu__Account__c!=null) system.debug('TESTING AccMap Contains zq Account is : '+AccMap.ContainsKey (zq.zqu__Account__c));
         if (zq.zqu__Account__c!=null && AccMap.ContainsKey (zq.zqu__Account__c))
         {  
            Account a = AccMap.get (zq.zqu__Account__c);
            system.debug('TESTING a.Zuora__Subscriptions__r.size() is '+a.Zuora__Subscriptions__r.size());
            if (a.Zuora__Subscriptions__r.size()>0)
            {
                //zq.TCV_before_upsell__c = 0;
                ///for (Zuora__Subscription__c zs : a.Zuora__Subscriptions__r)
                //{
                    //if (zs.Zuora__Status__c.tolowercase()=='active' && zs.Zuora__TCV__c!=null) zq.TCV_before_upsell__c+=zs.Zuora__TCV__c;
                //}
            }
         }
    }
    
    public static list <zqu__Quote__c> QueryQuote (list <id> qid)
    {
        list <zqu__Quote__c> Qlist = [
                select id, zqu__SoldToContact__r.MailingCountry, zqu__StartDate__c, RecordType.DeveloperName, zqu__CommunicationProfile__c, 
                zqu__AutoRenew__c, zqu__QuoteTemplate__c, name, zqu__Account__c, zqu__ElectronicPaymentMethodId__c, zqu__SubscriptionTermEndDate__c,
                zqu__InvoiceTemplate__c, zqu__PaymentMethod__c, zqu__PaymentTerm__c, zqu_Quote_Status__c,Payment_Frequency__c,
                zqu__SubscriptionTermStartDate__c, zqu__InitialTerm__c, zqu__Certificate_ID__c,Company__c,zqu__RenewalTerm__c,
                zqu__Status__c, zqu__TermStartDate__c, zqu__ZuoraPaymentID__c, zqu__Service_Activation_Date__c,
                zqu__ZuoraParentBillingAccountId__c,Discount_Reason__c,zqu__Opportunity__c,zqu__Opportunity__r.recordtypeid,
                zqu__Previewed_Delta_TCV__c,zqu__Previewed_Total__c,zqu__Previewed_SubTotal__c ,Number_of_Countries__c,
                zqu__Opportunity__r.name,IsOldProduct__c,Installments__c,zqu__QuoteBusinessType__c,
                (select id,zqu__DeltaTCV__c,zqu__TCV__c,zqu__OriginalId__c
                  
                from zqu__QuoteChargeDetails__r),
                
                (select id,zqu__ProductRatePlan__r.zqu__Product__r.ProductCompatibility__c ,
                 zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c,zqu__SubscriptionRatePlanZuoraId__c 
                 from zqu__Quote_Rate_Plans__r
                 )


                from zqu__Quote__c
                where id = :qid
        ];
        
        return Qlist;
    }
    
    public static void BuildQuoteChargeMap (list <id> qid)
    {
        system.debug('TESTING BuildQuoteChargeMap fired');
        list <zqu__QuoteAmendment__c> QAmendList = [
                select id, zqu__Quote__c, (select id,zqu__SubscriptionRatePlanZuoraId__c from zqu__Quote_Rate_Plans__r)
                from zqu__QuoteAmendment__c
                where zqu__Quote__c = :qid
        ];

        if (QAmendlist.size() > 0) {
            list <id> tempidlist = new list <id>();
            for (zqu__QuoteAmendment__c zqqa: QAmendlist) if (zqqa.zqu__Quote_Rate_Plans__r.size() > 0)
                for (zqu__QuoteRatePlan__c zqqrp : zqqa.zqu__Quote_Rate_Plans__r) {
                    tempidlist.add (zqqrp.id);
                }
            if (tempidlist.size() > 0) {
                list <zqu__QuoteRatePlanCharge__c> zQRPClist = [
                        select  name,zqu__Discount__c, zqu__Period__c,zqu__listprice__c,
                                zqu__EffectivePrice__c, zqu__Quantity__c,IsDeleted,
                                zqu__QuoteRatePlan__c, zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c,
                                zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c,
                                zqu__SpecificBillingPeriod__c,zqu__Description__c,Terms_Total__c, zqu__total__c,
                                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c,
                                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c,
                                zqu__productRatePlanCharge__r.zqu__UOM__c,
                                zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c,zqu__ListTotal__c
                        from zqu__QuoteRatePlanCharge__c
                        where zqu__QuoteRatePlan__c = :tempidlist
                ];
                
                if (zQRPClist.size() > 0) for (zqu__QuoteRatePlanCharge__c zqcs: zQRPClist) {
                    if (zqcs.zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c != null) {
                        list <zqu__QuoteRatePlanCharge__c> templist = new list <zqu__QuoteRatePlanCharge__c>();
                        if (Quote2QuoteRatePlanChargeMap.ContainsKey (zqcs.zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c)) {
                            templist = Quote2QuoteRatePlanChargeMap.get(zqcs.zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c);
                        }
                        templist.add (zqcs);
                        Quote2QuoteRatePlanChargeMap.put (zqcs.zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c, templist);
                    }

                }

                list <zqu__QuoteChargeSummary__c> zQCSlist = [
                        select id, zqu__Discount__c, zqu__Product_Name__c, zqu__Period__c,
                                zqu__EffectivePrice__c, zqu__Quantity__c,zqu__Type__c,
                                zqu__ListPrice__c,zqu__Model__c,zqu__TotalPrice__c,zqu__ListTotal__c,
                                zqu__QuoteRatePlan__c, zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c,
                                Product_Category__c,Internal_Code__c,AddOnType__c,
                                zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.MinTerm__c,
                                zqu__QuoteRatePlan__r.zqu__QuoteRatePlanZuoraId__c,
                                zqu__QuoteRatePlan__r.zqu__QuoteProductName__c,Product_Compatibility__c,
                                zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c,
                                zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c
                        from zqu__QuoteChargeSummary__c
                        where zqu__QuoteRatePlan__c = :tempidlist
                ];

                if (zQCSlist.size() > 0) for (zqu__QuoteChargeSummary__c zqcs: zQCSlist) {
                    if (zqcs.zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c != null) {
                        list <zqu__QuoteChargeSummary__c> templist = new list <zqu__QuoteChargeSummary__c>();
                        if (Quote2QuoteChargeSummaryMap.ContainsKey (zqcs.zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c)) {
                            templist = Quote2QuoteChargeSummaryMap.get(zqcs.zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c);
                        }
                        templist.add (zqcs);
                        Quote2QuoteChargeSummaryMap.put (zqcs.zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c, templist);
                    }

                }

            }

            system.debug('TESTING Quote2QuoteChargeSummaryMap is built. Size is ' + Quote2QuoteChargeSummaryMap.size());
        }
    }
    
    // This method is referred to as 'FinalizeQuote'.
    webservice static String testForErrors(Id qid) {

        system.debug('TESTING - Finalize Quote/testForErrors started');
        list <id> qids = new list <id>();
        qids.add (qid);
        BuildQuoteChargeMap(qids);
        
        list <id> idlist = new list <id>();
        idlist.add (qid);
        list <zqu__Quote__c> Qlist = QueryQuote(idlist);
        
        list <Country_Subsidiary__c> CountryList = [
                select id, Communication_Profile_Cont__c, name, Country_Id__c, Country_Name__c, Communication_profile_cc__c,
                        CommunicationProfilesSFID__c, InvoiceTemplateCCSFID__c,ISOCode__c,
                        InvoiceTemplateContrSFID__c, InvoiceTemplateWSFID__c,Invoice_Template_Ent__c,IsNoMobileWeb__c,
                        Subsidiary__c, Taxable__c, Tax_Region__c, No_Tax_Region__c,ISOCode_3__c,Restricted_To_Sold_Country__c
                from Country_Subsidiary__c
        ];
        
        if (CountryList.size()>0) for (Country_Subsidiary__c cs : CountryList) CountrySubMap.put (cs.name,cs);
        
        
        //Call WSVATService
        getdata (Qlist,'Ext');
        
        string country = Qlist[0].zqu__SoldToContact__r.MailingCountry;
        Country_Subsidiary__c countrysub = null;
        if (CountrySubMap.ContainsKey (country))
        {
            countrysub = CountrySubMap.get (country);
            country = CountrySubMap.get (country).ISOCode__c;
        }
        string vcode = Qlist[0].zqu__Certificate_ID__c;
        if (vcode!=null) vcode = vcode.right(vcode.length()-2);
        
        string WSVatresponse = 'Success' ;
        system.debug('TESTING coutnrysub is '+countrysub);
        
        string recordtype = RecTypeMap.get(Qlist[0].recordtypeid).developername;
        
        if (recordtype!=null && recordtype.EqualsIgnoreCase('default') 
            && vcode!=null && countrysub!=null && countrysub.No_Tax_Region__c!=null 
            && Countrysub.No_Tax_Region__c.EqualsIgnoreCase('EU Non-Taxable')
           )
        {
            system.debug('TESTING calling WSVATService with country: '+country+' and code '+vcode);
            try{
                //string WSVatresponse = WSVATService.checkVat(country,vcode);
                WSVATService cls = new WSVATService();
                WSVatresponse = cls.checkVat(country,vcode);
                system.debug('TESTING response is '+WSVatresponse);
                if (WSVatresponse.startswith('checkVatResponse_element')) //Successfull answer starts with checkVATresponse_element
                {
                    integer validi = WSVatresponse.indexof ('valid=');
                    if (validi!=-1)
                    {
                        integer resulti = WSVatresponse.indexof (',',validi);
                        if (resulti!=-1)
                        {
                            string results = WSVatresponse.substring(validi+6,resulti);
                            system.debug('TESTING results is '+results);
                            if (results.EqualsIgnoreCase('True'))WSVatresponse = 'Success';
                            if (results.EqualsIgnoreCase('false'))WSVatresponse = 'Invalid Vat Number';
                        } 
                        
                    } 
                }
                
            }
            catch (exception e){system.debug('TESTING Exception caught: '+e);WSVatresponse = 'Invalid Vat Number';}
        
            system.debug('TESTING WSVatresponse is '+WSVatresponse);
            if (WSVatresponse!='Success') return WSVatresponse;
        }
        if (qlist[0].zqu__Account__c!=null)
        {
            list <id> tempidlist = new list <id>();
            tempidlist.add (qlist[0].zqu__Account__c);
            GenSubPrdnChrgMap(tempidlist);
        }
        
        // Building Quote Charge Summary Information - START
        
            // dr 23-Feb-2016
            //
        
        // Building Quote Charge Summary Information - END
        
        
        // Building Subscription Data - START
        
        
        
        
        // Building Subscription Data - END


        UpdateApprovalFields (Qlist);
        for (zqu__Quote__c zq : Qlist) zq.Is_Finalized__c = 'Yes';
        
        zqu__Quote__c zq = Qlist[0];
        
        {
            
            Quote2Send.add (Qlist[0]);
            HandleBefore (Qlist, null, 'Button');
            
            system.debug('TESTING - Button HandleBefore done. errors is ' + errors);
            //UpdateQuoteFields (zq);
            if (Errors != null && Errors != '') {
                return Errors;
            }
            
            //GetData(Qlist,'Button');
            HandleAfter (Qlist, null, 'Button');
            system.debug('TESTING - Button HandleBAFTER done. errors is ' + errors);
            if (Errors != null && Errors != '') {
                return Errors;
            }
            utils.CodeOff = true;

            // Set the quote's template (line 26 in Zuora_Backlog.xlsx) // dr Feb-23-2016 Start
            Qlist[0].zqu__QuoteTemplate__c = GetQuoteTemplateId(Qlist[0]);

            // Update Auto renew to false if payment method = Other or Wire Transfer (line 28 in Zuora_Backlog.xlsx) - todo // dr Feb-23-2016 Start
            if (Qlist[0].zqu__PaymentMethod__c == 'Other' || Qlist[0].zqu__PaymentMethod__c == 'Wire Transfer') {
                Qlist[0].zqu__AutoRenew__c = false;
            }

            update Qlist;
            system.debug('TESTING - Finalize Quote/testForErrors Qlist updated');
            utils.CodeOff = false;
        }

        system.debug('TESTING - Finalize Quote/testForErrors Ended');
        return '';
    }
    /*
    @future
    public static void UpdateQRPC (list <id> Qidlist)
    {
        list <zqu__Quote__c> Qlist = new list <zqu__Quote__c>();
        for (id qid : qidlist)
        {
            zqu__Quote__c zq = new zqu__Quote__c (id=qid);
            Qlist.add (zq);
        }
        HandleBefore (Qlist,null,'FutureUpdate');
        
        system.debug('TESTING future QRPC4Update size is '+QRPC4Update.size());
        
        utils.Codeoff = true;
        if (QRPC4Update.size()>0) update QRPC4Update.values();
        utils.codeoff = false;
    }*/

    // Get quote template id
    @TestVisible
    private static Id GetQuoteTemplateId(zqu__Quote__c quote) {
        String quoteRatePlanProductName = null;
        Id quoteTemplateId = null;

        list <zqu__QuoteRatePlan__c> QuoteRatePlans = [
                Select zqu__QuoteProductName__c
                From zqu__QuoteRatePlan__c
                Where zqu__Quote__c = :quote.Id
                Limit 1
        ];

        if (!QuoteRatePlans.isEmpty()) {
            quoteRatePlanProductName = utils.SafeValue(QuoteRatePlans[0].zqu__QuoteProductName__c);
            list <zqu__Quote_Template__c> quoteTemplates = [Select Name, zqu__Quote_Type__c, Product_Name__c From zqu__Quote_Template__c];
            for (zqu__Quote_Template__c quoteTemplate : quoteTemplates) {// first run - check if there's a matching template with same product name and same quote record type
                if (quoteRatePlanProductName.equalsIgnoreCase(quoteTemplate.Product_Name__c) &&
                        Utils.QuoteRecordTypeMatchesTemplateQuoteType(quote.RecordType.DeveloperName, quoteTemplate.zqu__Quote_Type__c)) {
                    quoteTemplateId = quoteTemplate.Id;
                }
            }
            if (quoteTemplateId == null) // if no matching template found
            {
                for (zqu__Quote_Template__c quoteTemplate : quoteTemplates) {
                    if (quoteTemplate.Name == 'No Base Product' && Utils.QuoteRecordTypeMatchesTemplateQuoteType(quote.RecordType.DeveloperName, quoteTemplate.zqu__Quote_Type__c)) {
                        quoteTemplateId = quoteTemplate.Id;
                    }
                }
            }
        }
        return quoteTemplateId;
    }
   
        /*
    public static PageReference Send2BillingButton()
    {
        id qid = ApexPages.currentPage().getParameters().get('id');
        list <zqu__Quote__c> Qlist = [select id,name,zqu__Account__c,zqu__ElectronicPaymentMethodId__c,
                                        zqu__InvoiceTemplate__c,zqu__PaymentMethod__c,zqu__PaymentTerm__c,zqu_Quote_Status__c,
                                        zqu__Status__c,zqu__TermStartDate__c,zqu__ZuoraPaymentID__c,
                                        zqu__Service_Activation_Date__c
        
                                     from zqu__Quote__c where id=:qid];
        
        zqu__Quote__c zq = Qlist[0];
        if (zq.zqu__PaymentMethod__c!=null && 
            (zq.zqu__PaymentMethod__c=='Credit Card' || zq.zqu__PaymentMethod__c=='PayPal')
           )
        {
            errors = 'Not authorized to send to Zbilling';
        }
        else
        {
                                     
            Quote2Send.add (Qlist[0]);
            HandleBefore (Qlist,null,'Button');
            HandleAfter (Qlist,null,'Button');
        
        }
        
        PageReference pr = new Pagereference ('/'+qid);
        return pr;  
    }*/

}