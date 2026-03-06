public without sharing class QuoteRatePlanChargeTriggerHandler {
  public static Boolean isFirstTime = true;
  public static map<id, zqu__QuoteRatePlanCharge__c> OldMap = new Map<id, zqu__QuoteRatePlanCharge__c>();
  public static string event = null;

  public static map<id, zqu__QuoteRatePlan__c> QRPMap = new Map<id, zqu__QuoteRatePlan__c>();
  public static map<id, ApprovedTermsFrequecy__c> ATFMap = new Map<id, ApprovedTermsFrequecy__c>();
  public static map<id, zqu__Quote__c> QuoteMap = new Map<id, zqu__Quote__c>();
  public static map<id, list<zqu__QuoteRatePlanCharge__c>> Q2QRPCMap = new Map<id, list<zqu__QuoteRatePlanCharge__c>>();

  public static map<id, zqu__Quote__c> Quote4Update = new Map<id, zqu__Quote__c>();

  public static void GenData(list<zqu__QuoteRatePlanCharge__c> QRPCList) {
    list<id> idlist = new List<id>();
    for (zqu__QuoteRatePlanCharge__c qrpc : QRPClist) {
      if (qrpc.zqu__QuoteRatePlan__c != null)
        idlist.add(qrpc.zqu__QuoteRatePlan__c);
    }

    list<zqu__QuoteRatePlan__c> QRPList = [
      SELECT
        id,
        zqu__Quote__c,
        zqu__ProductRatePlan__r.zqu__ZProduct__r.ProductCompatibility__c,
        zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c
      FROM zqu__QuoteRatePlan__c
      WHERE id = :idlist
    ];

    if (QRPList.size() > 0) {
      QRPMap.putall(QRPList);
      for (zqu__QuoteRatePlan__c qrp : QRPList)
        if (qrp.zqu__Quote__c != null)
          idlist.add(qrp.zqu__Quote__c);

      list<zqu__Quote__c> Qlist = [
        SELECT
          id,
          Discount_Percentage__c,
          Payment_Frequency__c,
          zqu__InitialTerm__c,
          zqu__RenewalTerm__c,
          Installments__c,
          Total_Price__c,
          Total_List_Price__c,
          Total_Discount__c
        FROM zqu__Quote__c
        WHERE id = :idlist
      ];

      if (Qlist.size() > 0)
        QuoteMap.putall(Qlist);
      /*{
             	for (zqu__Quote__c zq : Qlist)
             	{
             		if (zq.Installments__c==null || zq.Installments__c==0) zq.Installments__c=1;
             		if (zq.zqu__InitialTerm__c!=null) zq.Payment_Frequency__c = zq.zqu__InitialTerm__c / zq.Installments__c;
             	 	
             	}
             }*/
    }

    list<ApprovedTermsFrequecy__c> ATFList = [
      SELECT
        id,
        name,
        Billing_Remarks__c,
        Default__c,
        Frequency__c,
        Initial_Term__c
      FROM ApprovedTermsFrequecy__c
    ];
    if (ATFList.size() > 0)
      ATFMap.putall(ATFList);
  }
  /*
    public static void GenData_After (list <zqu__QuoteRatePlanCharge__c> QRPCList)
    {
        list <id> idlist = new list <id>();
        if (QuoteMap.size()>0) for (zqu__Quote__c zq : QuoteMap.values()) idlist.add (zq.id);
        list <zqu__Quote__c> NewQuoteList = ZQuoteHandler.QueryQuote (idlist);
        QuoteMap.putall (NewQuoteList);
        
        //Q2QRPCMap BUILD - START
        list <zqu__QuoteRatePlan__c> QRPList = [select id,zqu__Quote__c,
                                                (select id,zqu__ListPrice__c,zqu__Quantity__c,zqu__Period__c from zqu__Quote_Rate_Plan_Charges__r)
                                               from zqu__QuoteRatePlan__c where zqu__Quote__c=:idlist];
                                               
        if (QRPList.size()>0) for (zqu__QuoteRatePlan__c qrp : QRPList)
        {
            list <zqu__QuoteRatePlanCharge__c> QRPCTemp = new list <zqu__QuoteRatePlanCharge__c>();
            if (qrp.zqu__Quote__c!=null)
            {
                if (Q2QRPCMap.containskey (qrp.zqu__Quote__c)) QRPCTemp = Q2QRPCMap.get (qrp.zqu__Quote__c);
                if (qrp.zqu__Quote_Rate_Plan_Charges__r.size()>0) for (zqu__QuoteRatePlanCharge__c qrpc : qrp.zqu__Quote_Rate_Plan_Charges__r)
                {
                    QRPCTemp.add (qrpc);
                }
                Q2QRPCMap.put (qrp.zqu__Quote__c,QRPCTemp);
            }
        }
        //Q2QRPCMap BUILD - END
    }
    */
  public static void UpdateQRPCFields(
    list<zqu__QuoteRatePlanCharge__c> QRPCList
  ) {
    if (event == 'Insert') {
      for (zqu__QuoteRatePlanCharge__c qrpc : QRPCList) {
        system.debug('TESTING UpdateQRPCFields fired');
        zqu__Quote__c zq = QuoteMap.get(
          QRPMap.get(qrpc.zqu__QuoteRatePlan__c).zqu__Quote__c
        );
        boolean ATFFound = false;
        ApprovedTermsFrequecy__c ATFRec = null;

        if (ATFMap.size() > 0)
          for (ApprovedTermsFrequecy__c atf : ATFMap.values()) {
            if (
              atf.Frequency__c == zq.Payment_Frequency__c &&
              atf.initial_term__c == zq.zqu__InitialTerm__c &&
              atf.initial_term__c == zq.zqu__RenewalTerm__c
            ) {
              ATFFound = true;
              ATFRec = atf;
            }
          }

        if (zq != null) {
          decimal discount = 0;
          if (zq.Discount_Percentage__c != null)
            discount = zq.Discount_Percentage__c;
          //qrpc.zqu__Total__c = qrpc.zqu__ListPrice__c * (1-discount/100) * qrpc.zqu__Quantity__c;
          if (
            qrpc.zqu__Period__c != null &&
            qrpc.zqu__Period__c.EqualsIgnoreCase('Specific Months')
          ) {
            qrpc.zqu__SpecificBillingPeriod__c = zq.Payment_Frequency__c;

            string descr = '';
            if (qrpc.zqu__Description__c != null)
              descr = qrpc.zqu__Description__c;
            if (
              ATFRec != null &&
              ATFRec.Billing_Remarks__c != null &&
              qrpc.zqu__Period__c != null &&
              qrpc.zqu__Period__c.EqualsIgnoreCase('specific months')
            )
              qrpc.zqu__Description__c =
                qrpc.name +
                ' ' +
                ATFRec.Billing_Remarks__c;
          }
        }
      }
    }
  }

  public static void UpdateQRTotalFields(
    list<zqu__QuoteRatePlanCharge__c> QRPCList
  ) {
    if (
      (event == 'Insert' || event == 'Update' || event == 'Delete') &&
      isFirstTime
    ) {
      Set<zqu__Quote__c> zqList = new Set<zqu__Quote__c>();
      Map<id, zqu__Quote__c> fullQuoteMap = new Map<id, zqu__Quote__c>();
      for (zqu__QuoteRatePlanCharge__c qrpc : QRPCList) {
        if (
          event != 'Update' ||
          OldMap.get(qrpc.Id).zqu__ListTotal__c != qrpc.zqu__ListTotal__c ||
          OldMap.get(qrpc.Id).zqu__Total__c != qrpc.zqu__Total__c ||
          OldMap.get(qrpc.Id).zqu__Discount__c != qrpc.zqu__Discount__c
        ) {
          zqu__Quote__c zq = QuoteMap.get(
            QRPMap.get(qrpc.zqu__QuoteRatePlan__c).zqu__Quote__c
          );
          zq.Total_Price__c = 0;
          zq.Total_List_Price__c = 0;
          zq.Total_Discount__c = 0;
          fullQuoteMap.put(zq.Id, zq);
        }
      }
      Map<Id, zqu__QuoteRatePlanCharge__c> sss = new Map<Id, zqu__QuoteRatePlanCharge__c>(
        [
          SELECT Id, zqu__QuoteRatePlan__c
          FROM zqu__QuoteRatePlanCharge__c
          WHERE zqu__QuoteRatePlan__r.zqu__Quote__r.Id IN :fullQuoteMap.keySet()
        ]
      );
      Set<String> qRatePlanIds = new Set<String>();
      for (zqu__QuoteRatePlanCharge__c qrpc : sss.values()) {
        qRatePlanIds.add(qrpc.zqu__QuoteRatePlan__c);
      }
      Map<id, zqu__QuoteRatePlan__c> fullQRPMap = new Map<id, zqu__QuoteRatePlan__c>(
        [
          SELECT Id, zqu__Quote__c
          FROM zqu__QuoteRatePlan__c
          WHERE ID IN :qRatePlanIds
        ]
      );
      AggregateResult[] groupedResults = [
        SELECT
          zqu__QuoteRatePlan__c,
          SUM(zqu__ListTotal__c) listPrice,
          SUM(zqu__Total__c) listTotal,
          AVG(zqu__Discount__c) totalDiscount
        FROM zqu__QuoteRatePlanCharge__c
        WHERE
          Id IN :sss.keySet()
          AND zqu__ListTotal__c != NULL
          AND zqu__Total__c != NULL
          AND zqu__Discount__c != NULL
        GROUP BY zqu__QuoteRatePlan__c
      ];
      Map<String, Double> ratePlaneToTotalSum = new Map<String, Double>();
      Map<String, Double> ratePlaneToPriceSum = new Map<String, Double>();
      Map<String, Double> ratePlaneToDiscount = new Map<String, Double>();
      for (AggregateResult ar : groupedResults) {
        if (ar.get('zqu__QuoteRatePlan__c') != null) {
          ratePlaneToTotalSum.put(
            (String) ar.get('zqu__QuoteRatePlan__c'),
            (Decimal) ar.get('listTotal')
          );
          ratePlaneToPriceSum.put(
            (String) ar.get('zqu__QuoteRatePlan__c'),
            (Decimal) ar.get('listPrice')
          );
          ratePlaneToDiscount.put(
            (String) ar.get('zqu__QuoteRatePlan__c'),
            (Decimal) ar.get('totalDiscount')
          );
        }
      }
      for (String qRatePlaneId : qRatePlanIds) {
        if (ratePlaneToTotalSum.containsKey(qRatePlaneId))
          fullQuoteMap.get(fullQRPMap.get(qRatePlaneId).zqu__Quote__c)
            .Total_Price__c += ratePlaneToTotalSum.get(qRatePlaneId);
        if (ratePlaneToPriceSum.containsKey(qRatePlaneId))
          fullQuoteMap.get(fullQRPMap.get(qRatePlaneId).zqu__Quote__c)
            .Total_List_Price__c += ratePlaneToPriceSum.get(qRatePlaneId);
      }
      for (zqu__Quote__c quote_i : fullQuoteMap.values()) {
        if (
          quote_i.Total_Price__c != null &&
          quote_i.Total_List_Price__c != null &&
          quote_i.Total_List_Price__c != 0
        )
          quote_i.Total_Discount__c =
            (1 - (quote_i.Total_Price__c / quote_i.Total_List_Price__c)) * 100;
      }
      isFirstTime = false;
      update fullQuoteMap.values();
    }
  }
  /*  
    public static void UpdateQuotes (list <zqu__QuoteRatePlanCharge__c> QPRCList)
    {
        list <zqu__Quote__c> Qlist = new list <zqu__Quote__c>();
        for (zqu__QuoteRatePlanCharge__c qrpc : QPRCList)
        {
            zqu__QuoteRatePlan__c qrp = QRPMap.get (qrpc.zqu__QuoteRatePlan__c);
            
            zqu__Quote__c zq = QuoteMap.get (QRPMap.get (qrpc.zqu__QuoteRatePlan__c).zqu__Quote__c);
            date efdate = date.newinstance (2011,11,21);
            if (qrp.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__EffectiveStartDate__c!=null && 
                qrp.zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c <=efdate
            )
            {
                zq.IsOldProduct__c = true;
                Quote4Update.put (zq.id,zq);
            }
            //Qlist.add (zq);
        }
        
        //UpdateQuotes (Qlist);
    }
            
    
    public static void UpdateQuotes (list <zqu__Quote__c> Qlist)
    {
        for (zqu__Quote__c zq : Qlist)
        {
            
            
            if (Quote4Update.ContainsKey (zq.id)) zq=Quote4Update.get (zq.id);
            
            boolean ATFFound = false;
            ApprovedTermsFrequecy__c ATFRec = null;
            
            if (ATFMap.size()>0) for (ApprovedTermsFrequecy__c atf : ATFMap.values())
            {
                if (atf.Frequency__c == zq.Payment_Frequency__c && atf.initial_term__c  == zq.zqu__InitialTerm__c
                    && atf.initial_term__c == zq.zqu__RenewalTerm__c){ ATFFound=true; ATFRec = atf;}
            }
            
            // Calculate Upsell and Credit amount - START
            
            list <zqu__QuoteChargeDetail__c> QCDList = new list <zqu__QuoteChargeDetail__c>();
            if (zq.zqu__QuoteChargeDetails__r.size()>0) QCDList = zq.zqu__QuoteChargeDetails__r;
            
            if (QCDList.size()>0)zq=ZQuoteHandler.SetUpsellCreditfromQCD (QCDList,zq);
            
            system.debug('TESTING zq.upsell amount is '+zq.Upsell_amount__c);
            decimal totalbeforediscount = 0;
            
            
            if (Q2QRPCMap.ContainsKey (zq.id)) for (zqu__QuoteRatePlanCharge__c qrpc : Q2QRPCMap.get (zq.id))
            {
                decimal period = 1;
                if (zq.zqu__InitialTerm__c!=null && qrpc.zqu__Period__c!=null && qrpc.zqu__Period__c.EqualsIgnoreCase('specific months'))
                  period = zq.zqu__InitialTerm__c;
                system.debug('TESTING period is '+period);
                if (qrpc.zqu__Quantity__c==null) qrpc.zqu__Quantity__c=1;
                if (qrpc.zqu__ListPrice__c!=null && qrpc.zqu__ListPrice__c!=0 && qrpc.zqu__Quantity__c!=null && qrpc.zqu__Quantity__c!=0)
                {
                    totalbeforediscount = totalbeforediscount + (qrpc.zqu__ListPrice__c*qrpc.zqu__Quantity__c)*period;
                }
            }
            zq.Discount_Amount__c = 0;
            zq.Discount_Percentage__c = 0;
            
            system.debug('TESTING totalbeforediscountis '+totalbeforediscount);
            if (totalbeforediscount!=0)
            {
                
                if (zq.Upsell_amount__c==null) zq.Upsell_amount__c=0;
                decimal discount = 1 - (zq.Upsell_amount__c/totalbeforediscount*100);
                system.debug('TESTING Discount% set to '+discount);
                if (discount!=1)
                {
                    zq.Discount_Percentage__c = discount;
                    zq.Discount_Amount__c = (zq.Upsell_amount__c /  (1-zq.Discount_Percentage__c)) * (zq.Discount_Percentage__c/100);
                }
                system.debug('TESTING Discount_Amount__c set to '+zq.Discount_Amount__c);
            }
            
            
            //if (zq.Discount_Percentage__c!= oldmap.get (zq.id).Discount_Percentage__c)
            //{
            //  if (zq.Discount_Amount__c!=null && zq.Upsell_Amount__c!=null) 
            //            zq.Discount_Amount__c = zq.Discount_Amount__c/100 * zq.Upsell_Amount__c; 
            //          else 
            //            zq.Discount_Amount__c = 0;
             //   system.debug('TESTING Discount amount set to '+zq.Discount_Amount__c);
            //}
            //else if (zq.Discount_Amount__c != oldmap.get (zq.id).Discount_Amount__c && zq.Upsell_Amount__c!=null && zq.Upsell_Amount__c!=0)
            //{
            //  system.debug('TESTING upsell amount is '+zq.upsell_amount__c);
            //  zq.Discount_Percentage__c = zq.Discount_Amount__c/ zq.Upsell_Amount__c*100;
            //  system.debug('TESTING Discount percentage set to '+zq.Discount_Percentage__c);
            //}
        
            
            Quote4Update.put (zq.id,zq);
        }
    }
    */
  public static void HandleBefore(
    list<zqu__QuoteRatePlanCharge__c> QRPCList,
    map<id, zqu__QuoteRatePlanCharge__c> OldTriggerMap,
    string evnt
  ) {
    if (evnt != null)
      event = evnt;
    if (OldTriggerMap != null)
      OldMap = OldTriggerMap;

    GenData(QRPCList);
    if (event == 'Insert') {
      UpdateQRPCFields(QRPCList);
    }
  }

  public static void HandleAfter(
    list<zqu__QuoteRatePlanCharge__c> QRPCList,
    map<id, zqu__QuoteRatePlanCharge__c> OldTriggerMap,
    string evnt
  ) {
    if (evnt != null)
      event = evnt;
    if (OldTriggerMap != null)
      OldMap = OldTriggerMap;
    //GenData_After (QRPCList);
    //UpdateQuotes (QRPCList);
    GenData(QRPCList);
    UpdateQRTotalFields(QRPCList);
    utils.CodeOff = true;
    //if (Quote4Update.size()>0) update Quote4Update.values();
    utils.Codeoff = false;
  }
}
