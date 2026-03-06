global without sharing class ProformaHandler {
    
    public static list <zqu__QuoteChargeSummary__c> zQCSlist = new list <   zqu__QuoteChargeSummary__c>();
    public static zqu__Quote__c zq = new zqu__Quote__c ();
    public static Country_Subsidiary__c countrysub = null;
    public static string profile  = '';
    public static map <id,User> UserMap = new map <id,User>();
    
    public static map <string,RecordType> RecTypeMap = new map <string,RecordType>();
    
    public static string rectype = 'Default'; //We're going to assume it's default unless we find it to be amendment or renewal
    
    
    // Trigger Variables
    
    public static map <id,Proforma_Invoice__c> PIMap = new map <id,Proforma_Invoice__c>();
    public static map <id,Proforma_Invoice__c> OldMap = new map <id,Proforma_Invoice__c>();
    public static map <id,Proforma_Invoice_Line__c> piLine4Update = new map <id,Proforma_Invoice_Line__c>();
    public static map <id,Zuora__CustomerAccount__c> BillingAccMap = new map <id,Zuora__CustomerAccount__c>();
    
    public static void GenRecTypeMap ()
    {
        list <RecordType> RecTypeList = [select id,SObjectType,name,developername from RecordType];
        if (RecTypeList.size()>0) for (RecordType r : RecTypeList)
        {
            if (r.SObjectType=='zqu__Quote__c' || r.SobjectType=='Proforma_Invoice__c')
            {
                RecTypemap.put (r.SobjectType+r.developername,r);
                RecTypemap.put (r.SobjectType+r.id,r);
            }
        }   
    }
    
    public static RecordType GetproformaRecType (zqu__Quote__c q)
    {
        map <string,CS_Quote2ProformarecType__c> CSTempMap = CS_Quote2ProformarecType__c.getall();
        RecordType rec = null;
        if (q.recordtypeid!=null)
        {
            string key = 'zqu__Quote__c'+q.recordtypeid;
            system.debug('TESTING GetproformaRecType - key is '+key);
            if (RecTypeMap.ContainsKey(key))
            {
                string dname = RecTypeMap.get(key).developername;
                if (CSTempMap.containskey (dname))
                {
                    string dname2 = CSTempMap.get (dname).Proforma_Record_Type_Dev_Name__c;
                    string key2 = 'Proforma_Invoice__c'+dname2;
                    system.debug('TESTING GetproformaRecType - key2 is '+key2);
                    if (RecTypeMap.ContainsKey(key2)) rec = RecTypeMap.get (key2);
                    system.debug('TESTING GetproformaRecType - found Rec is '+Rec);
                }
            }
        }
        
        return rec;
    }
    
    
    webservice static string CreateProformaButton (id qid)
    {
        string err = CreateProforma (qid);
        
        return err;
    }
    
    public static integer GetTermDay (string s)
    {
        system.debug('TESTING GetTermDay started, string is '+s);
        integer d = 0;
        if (s.contains('Net'))
        {
            d=integer.valueof(s.right(2));
        }
        system.debug('TESTING GetTermDay ended, result is '+d);
        return d;
    }
    
    public static void GenData (id qid)
    {
        GenRecTypeMap();
        id userid = userinfo.getUserId();
        User u = [select id,profileid,Issue_Proforma_Invoice__c from User where id=:userid];
        UserMap.put (u.id,u);
        
        
        id profileid = userinfo.getProfileId();
        profile = [select id,name from Profile where id=:profileid limit 1].name;
                         
                          
        zq = [select id,Is_Finalized__c,zqu__PaymentMethod__c,
              zqu__Currency__c,zqu__Opportunity__c,Subsidiary__c, 
                            zqu_Quote_Status__c,zqu__Account__c,
                            
                            zqu__BillToContact__r.FirstName,
                            zqu__BillToContact__r.LastName,
                            zqu__BillToContact__r.Email,
                            zqu__BillToContact__r.MailingStreet,
                            zqu__BillToContact__r.MailingCity,
                            zqu__BillToContact__r.MailingState,
                            zqu__BillToContact__r.MailingCountry,
                            zqu__BillToContact__r.MailingPostalCode,
                            
                            zqu__SoldToContact__r.FirstName,
                            zqu__SoldToContact__r.LastName,
                            zqu__SoldToContact__r.Email,
                            zqu__SoldToContact__r.MailingStreet,
                            zqu__SoldToContact__r.MailingCity,
                            zqu__SoldToContact__r.MailingState,
                            zqu__SoldToContact__r.MailingCountry,
                            zqu__SoldToContact__r.MailingPostalCode,
                            
                            zqu__SubscriptionTermStartDate__c, zqu__TermStartDate__c,
                            zqu__SubscriptionTermEndDate__c,
                            zqu__InitialTerm__c,
                            zqu__PaymentTerm__c,zqu__Previewed_Total__c,zqu__Previewed_SubTotal__c,
                            zqu__Certificate_ID__c,
                            
                            recordtype.name,recordtype.developername,recordtypeid,Tax_Region__c,
                            
                            (select id,Status__c from Proforma_Invoices__r),
                            (select id,name,zqu__DeltaTCV__c from zqu__QuoteChargeDetails__r)
        
                            from zqu__Quote__c where id=:qid limit 1];
        
        if (zq.recordtype.developername!=null && zq.recordtype.developername.Contains('Amendment')) rectype = 'Amendment';
        if (zq.recordtype.developername!=null && zq.recordtype.developername.Contains('Renewal')) rectype = 'Renewal';          
                            
        if (zq.zqu__SoldToContact__r!=null && zq.zqu__SoldToContact__r.mailingcountry!=null && rectype!='Default')
        {
            string country = zq.zqu__SoldToContact__r.mailingcountry;
            countrysub = [select id,Tax_Rate__c,Country_Name__c,Taxable__c from Country_Subsidiary__c where Country_Name__c=:country limit 1];
        }
        
        if (zq.zqu__billtocontact__c!=null && zq.zqu__billtocontact__r.mailingcountry!=null && rectype=='Default')
        {
            string country = zq.zqu__billtocontact__r.mailingcountry;
            countrysub = [select id,Tax_Rate__c,Country_Name__c,Taxable__c from Country_Subsidiary__c where Country_Name__c=:country limit 1];
        }
                            
         list <zqu__QuoteAmendment__c> QAmendList = [
                select id, zqu__Quote__c, (select id from zqu__Quote_Rate_Plans__r)
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
                        select zqu__Discount__c, zqu__Period__c,id,
                                zqu__EffectivePrice__c, zqu__Quantity__c,
                                zqu__QuoteRatePlan__c, zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c
                        from zqu__QuoteRatePlanCharge__c
                        where zqu__QuoteRatePlan__c = :tempidlist
                ];
                if (zQRPClist.size()>0 ) for (zqu__QuoteRatePlanCharge__c qrpc : zQRPClist) tempidlist.add (qrpc.id);
                
                  zQCSlist = [
                        select id, zqu__Discount__c, zqu__Product_Name__c, zqu__Period__c,zqu__TotalPrice__c,
                                zqu__EffectivePrice__c, zqu__Quantity__c,zqu__Product_Rate_Plan_Name__c,
                                zqu__QuoteRatePlan__c, zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c
                        from zqu__QuoteChargeSummary__c
                        where zqu__QuoteRatePlan__c = :tempidlist
                ];
                
                            
            }
        }
        
        if (zq.zqu__Account__c!=null)
        {
            list <Zuora__CustomerAccount__c> ZBillAccList = [select id,Zuora__TaxExemptCertificateID__c,
                                                             (select id,Zuora__ServiceActivationDate__c,Zuora__Status__c from Zuora__Subscriptions__r )
            
                                                            from Zuora__CustomerAccount__c Where Zuora__Account__c=:zq.zqu__Account__c
                                                            ];
                                                            
            if (ZBillAccList.size()>0) BillingAccMap.putall (ZBillAccList);
        }   
    }
    
    public static string CheckErrors ()
    {
        string err='';
        if (zq.zqu__PaymentMethod__c!=null && 
        zq.zqu__PaymentMethod__c.tolowercase()!='wiretransfer' 
        && zq.zqu__PaymentMethod__c.tolowercase()!='wire transfer')
        {
            err+='Payment method must be wire transfer ';
        }
        
        if (zq.Is_Finalized__c==null || zq.Is_Finalized__c!='Yes') err+='Quote is not finalized';
        /*
        if (profile.toLowerCase()!='system administrator' && profile.toLowerCase()!='sw billing')
        {
            err+='You are not allowed to issue a proforma invoice';
        }*/
        
        id userid = userinfo.getUserId();
        User u = UserMap.get (userid);
        if (!u.Issue_Proforma_Invoice__c)
        {
            err+='You are not autohrized to create proforma invoices';
        }
        
        if (Zq.Proforma_Invoices__r.size()>0)
        {
            boolean b = false;
            for (Proforma_Invoice__c pi : zq.Proforma_Invoices__r)
            {
                if (pi.status__c!=null && pi.status__c.tolowercase()!='cancelled') b=true;
            }
            if (b)
            {
                err+='A proforma record already exists for this quote';
            }
        }
        
        return err;
    }
    
    public static string CreateProforma (id qid)
    {
        string err = '';
        GenData (qid);          
        err = CheckErrors();                    
        
        if (err=='')
        {
            system.debug('TESTING - no error, process started');
            Proforma_Invoice__c pi =new Proforma_Invoice__c();
            RecordType rt = GetproformaRecType(zq);
            if (rt!=null) pi.recordtypeid = rt.id;
            pi.Billing_First_Name__c = zq.zqu__billtocontact__r.FirstName;
            pi.Billing_Last_Name__c =  zq.zqu__billtocontact__r.LastName;
            pi.Billing_Email__c =  zq.zqu__billtocontact__r.email;
            pi.Billing_Postal_Code__c = zq.zqu__billtocontact__r.mailingpostalcode;
            pi.Billing_Address1__c = zq.zqu__billtocontact__r.mailingstreet;
            pi.Billing_City__c = zq.zqu__billtocontact__r.mailingcity;
            pi.Billing_Country__c = zq.zqu__billtocontact__r.mailingcountry;
            pi.Billing_State__c = zq.zqu__billtocontact__r.mailingstate;
            pi.Invoice_Date__c = date.today();
            pi.Payment_Terms__c = zq.zqu__PaymentTerm__c;
            pi.Day_Payment_Terms__c = GetTermDay (zq.zqu__PaymentTerm__c);
            pi.currency__c = zq.zqu__Currency__c;
            pi.VAT_Number__c = zq.zqu__Certificate_ID__c;
            
            pi.opportunity__c = zq.zqu__Opportunity__c;
            pi.Subsidiary__c = zq.Subsidiary__c;
            date d = date.newinstance (pi.Invoice_Date__c.year(),pi.Invoice_Date__c.month(),date.daysInMonth(pi.Invoice_Date__c.year(),pi.Invoice_Date__c.month()));
            pi.Invoice_Due_Date__c = d.adddays (GetTermDay (zq.zqu__PaymentTerm__c)+1);
            pi.Status__c = 'Posted';
            pi.Sub_Total__c = zq.zqu__Previewed_SubTotal__c;
            pi.Quote__c = zq.id;
            pi.account__c = zq.zqu__Account__c;
            
            if (zq.zqu__SubscriptionTermStartDate__c!=null) pi.servicestartdate__c = zq.zqu__SubscriptionTermStartDate__c;
            else if (zq.zqu__TermStartDate__c!=null) pi.servicestartdate__c = zq.zqu__TermStartDate__c;
            
            if (pi.servicestartdate__c!=null && zq.zqu__InitialTerm__c!=null) pi.serviceenddate__c = pi.servicestartdate__c.addmonths(integer.valueof(zq.zqu__InitialTerm__c));
                            
            if (BillingAccMap.size()>0) for (Zuora__CustomerAccount__c zba : BillingAccMap.values())
            {
                if (zba.Zuora__Subscriptions__r.size()>0) for (Zuora__Subscription__c zs : zba.Zuora__Subscriptions__r)
                {
                    
                    if (zs.zuora__status__c=='Active' && zs.Zuora__ServiceActivationDate__c!=null) pi.Current_Terms__c = zs.Zuora__ServiceActivationDate__c;
                }
                if (rt!=null && (rt.developername.contains('Upsell')|| rt.developername.contains('Renewal ')))
                {
                    pi.VAT_Number__c = zba.Zuora__TaxExemptCertificateID__c ;
                }
            }
            
            insert pi;
            
            if (zQCSlist.size()>0 && rectype=='Default') 
            {
                list <Proforma_Invoice_Line__c> pil4insert = new list <Proforma_Invoice_Line__c>();
                for (zqu__QuoteChargeSummary__c qcs : zQCSlist)
                {
                    Proforma_Invoice_Line__c pli = new Proforma_Invoice_Line__c();
                    pli.Proforma_Invoice__c = pi.id;
                    pli.Rate_Plan__c = qcs.zqu__Product_Rate_Plan_Name__c;
                    pli.Sub_Total__c= qcs.zqu__TotalPrice__c;
                    pli.Tax__c = 0;
                    pli.status__c='Posted';
                    system.debug('TESTING countrysub is '+countrysub);
                    system.debug('TESTING Certificate iD is '+zq.zqu__certificate_ID__c);       
                    if (countrysub!=null)
                    {
                        if (zq.zqu__Certificate_ID__c!=null && countrysub.Taxable__c!=null && 
                            countrysub.Taxable__c=='All' && zq.Tax_Region__c!=null 
                            && zq.Tax_Region__c.EqualsIgnoreCase('EU Non-Taxable'))
                        {
                            pli.Tax__c = 0;     
                            system.debug('TESTING Tax set to 0');
                        }
                        else if (countrysub.Tax_Rate__c!=null) pli.tax__c = countrysub.Tax_Rate__c/100;
                    }
                    
                    
                    pil4insert.add (pli);
                }
                insert pil4insert;
                
            }
            
            if (zq.zqu__QuoteChargeDetails__r.size()>0 && rectype!='Default') 
            {
                list <Proforma_Invoice_Line__c> pil4insert = new list <Proforma_Invoice_Line__c>();
                for (zqu__QuoteChargeDetail__c qcd : zq.zqu__QuoteChargeDetails__r)
                {
                    Proforma_Invoice_Line__c pli = new Proforma_Invoice_Line__c();
                    pli.Proforma_Invoice__c = pi.id;
                    pli.Rate_Plan__c = qcd.name;
                    pli.Sub_Total__c= qcd.zqu__DeltaTCV__c;
                    pli.Tax__c = 0;
                    pli.status__c='Posted';
                    if (countrysub!=null)
                    {
                        if (zq.zqu__Certificate_ID__c!=null && countrysub.Taxable__c!=null && 
                            countrysub.Taxable__c=='All' && zq.Tax_Region__c!=null && zq.Tax_Region__c.EqualsIgnoreCase('EU Non-Taxable'))
                        {
                            pli.Tax__c = 0;     
                        }
                        else if (countrysub.Tax_Rate__c!=null) pli.tax__c = countrysub.Tax_Rate__c/100;
                    }
                    
                    
                    pil4insert.add (pli);
                }
                insert pil4insert;
                
            }
            
            system.debug('TESTING err is '+err);
            // Preparing Conga URL
            /*
            if (err.length()==0)
            {
                Proforma_Invoice__c pinew = [select id,PartnerServerURL__c,name from Proforma_Invoice__c where id=:pi.id limit 1];
                string sessionid = UserInfo.getSessionID();
                string partnerserverurl = pinew.PartnerServerURL__c;
                string baseurl = 'https://composer.congamerge.com?';
                string url = 'SolMgr=1&sessionId='+sessionid+'&serverUrl='+partnerserverurl+'&Id='+pi.id+'&ReportId=[InvoiceProforma]00Og0000000UYl7';
                system.debug('TESTING url is '+url);
    
                string subs = pi.Subsidiary__c;
                string templateID='';
                if (subs =='Parent Company : SimilarWeb UK') templateID='a39g0000000dbjw';
                if (subs =='Parent Company : SimilarWeb IL') templateID='a39g0000000dWHv';
                if (subs =='Parent Company : SimilarWeb Inc') templateID='a39g0000000dbk1';
    
    
                url = url+'&TemplateId='+templateid;
                
                
                url = url+'&DefaultPDF=1&SC0=1&SC1=Attachments&AttachmentParentId=';
                string apprvlstatus = pi.Approval_Status__c;
                string temp = pi.id;
                if (apprvlstatus=='Approved') temp = pi.Opportunity__c;
                url = url+temp+'&OFN=';
                temp = 'Not Approved'+pinew.name;
                if (apprvlstatus=='Approved') temp = pinew.name;
                url = url+temp+'&DC=';
                temp = '1';
                if (apprvlstatus=='Approved'|| apprvlstatus=='Not Approved' || apprvlstatus=='Rejected') temp='0';
                url = url+temp+'&DS6=1&DS4=1&DS5=1&DS2=1&DS0=1';
                
                url = baseurl+url;//EncodingUtil.urlEncode(url,'UTF8');
                err = url;
                system.debug('TESTING final URL is '+url);
                
            }   */  
            
            
        }
        
        
        return err;
    }
    
    public static void GenData (list <Proforma_Invoice__c> pilist, string event)
    {
        if (event=='Update')
        {
            list <id> tempid = new list <id>();
            for (Proforma_Invoice__c pi : pilist) if (pi.id!=null) tempid.add (pi.id);
            if (tempid.size()>0)
            {
                list <Proforma_Invoice__c> pilisttemp = [select id,Status__c, 
                                                         (select id from Proforma_Invoice_Lines__r)
                                                         from Proforma_Invoice__c where id=:tempid
                
                                                        ];
                if (pilist.size()>0) PIMap.putall (pilisttemp);
            }
        }       
    }
    
    public static void UpdateItemstoCancelled (list <Proforma_Invoice__c> pilist,string event)
    {
        if (event=='Update')
        {
            if (pilist.size()>0) for (Proforma_Invoice__c pi : pilist)
            {
                if (oldmap!=null && oldmap.containskey (pi.id) && pi.status__c!=null && pi.status__c.tolowercase()=='cancelled' 
                    && oldmap.get (pi.id).status__c!=null && oldmap.get (pi.id).status__c.tolowercase()!='cancelled'
                )
                {
                    if (piMap.containskey (pi.id) && pimap.get (pi.id).Proforma_Invoice_Lines__r.size()>0)
                    {
                        list <Proforma_Invoice_Line__c> pilinelist = pimap.get (pi.id).Proforma_Invoice_Lines__r;
                        for (Proforma_Invoice_Line__c pil : pilinelist)
                        {
                            pil.status__c=pi.status__c;
                            piLine4Update.put (pil.id,pil);
                        }
                    }
                }       
            }
        }
    }
    
    public static void HandleAFTER (list <Proforma_Invoice__c> pilist, map <id,Proforma_Invoice__c> oldtriggermap, string event)
    {
        if (oldtriggermap!=null) oldmap = oldtriggermap;
        GenData (pilist,event);
        UpdateItemstoCancelled (pilist,event);
        if (piLine4Update.size()>0) update piLine4Update.values();
    }

}