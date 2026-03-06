trigger LeadTrigger on Lead (before insert, after insert,
        before update, after update,
        before delete, after delete) {

    LeadTriggerHandler hndl = new LeadTriggerHandler();
    PardotDataManipulationHandler pdmh = new PardotDataManipulationHandler();
    //BiApiInteractionHandler baih = new BiApiInteractionHandler('Lead');
    NewBiApiInteractionHandler newbaih = new NewBiApiInteractionHandler('Lead');
    //CampaignAutomationHandlerNew cahn = new CampaignAutomationHandlerNew('Lead');//MIS-2723: Remove the creation of Salesloft's outbound campaigns
    FunelMonitorHandler fmh = new FunelMonitorHandler();
    MQLCalculationHandler mqlCalc = new MQLCalculationHandler();


    InferredSolutionHandler ish = new InferredSolutionHandler('Lead');

//    if (Trigger.isBefore && Trigger.isDelete){
//        hndl.UpdateMergedLeadFields(Trigger.old);
//    }

    if (Trigger.isAfter && Trigger.isUpdate){
        hndl.afterUpdate(Trigger.newMap, (Map<Id, Lead>)Trigger.oldMap);
        //Itzik Winograd 2021-06-24: Pass values from accounts to contacts on converted leads
        //PassValuesToConvertedLeads passVals = new PassValuesToConvertedLeads();//2022-05-22: Itzik Winograd, 2022-05-22, Commented Out. MIS-2257
        //passVals.handle(Trigger.new, Trigger.oldMap);

//        cahn.automateCompaign((List<Lead>)Trigger.new, (Map<Id,SObject>)Trigger.oldMap);
        //Itzik Winograd 2021-05-25: ShareASale Phase2
        //Itzik Winograd, 2022-02-02 Remove all ShareASale triggers
        //ShareASaleIntegration sasi = new ShareASaleIntegration();
        //sasi.handle((List <SObject>)Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        /** MIS-3230: Skip Polygraph calls
        PolyghraphInteractionHandler polygraphInteraction = new PolyghraphInteractionHandler();
        polygraphInteraction.enrichLeadList();//Remove the call to Polygraph
        */
        // CampaignAutomationHandler.automateLeadCampaign((Map<Id, Lead>)Trigger.newMap); 
        // cahn.automateCompaign((List<Lead>)Trigger.new, null);
        hndl.afterInsert(Trigger.newMap);
        //Added 07/03/2021 by Itzik Winograd
        //Itzik Winograd, 2022-02-02 Remove all ShareASale triggers
        //ShareASaleIntegration sasi = new ShareASaleIntegration();
        //sasi.handle((List <SObject>)Trigger.new, null);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        GroudonProtectionUtil.protectGroudonEnrichmentFields(Trigger.new, Trigger.oldMap);
        hndl.fillMasterDomain(Trigger.new);
        hndl.updateDomainFieldsOnUpdate(Trigger.new,Trigger.oldMap);
        hndl.marketingCloudAdjustment(Trigger.new, trigger.oldMap);
        hndl.leadGenIdPreventionManagement(Trigger.new, trigger.oldMap);
        System.debug('Trigger is fired');
        //hndl.updateDomainFields(Trigger.new,Trigger.oldMap);
        //hndl.updateDomainFieldsOnUpdate((List<Lead>)Trigger.new, (Map<Id, Lead>)Trigger.oldMap);
        //baih.fitscoreOnDfoxChange(Trigger.new,Trigger.oldMap);
        //List<Lead> leadToUpdate = new List<Lead>();
        //hndl.updateEmployeeMinAndMax(Trigger.newMap);//MIS-3047: get the employees min-max from the connector before the fit-score call
        hndl.setEmployeeMinTimestamp((List<Lead>)Trigger.new, (Map<Id, Lead>)Trigger.oldMap);
//        newbaih.fitscoreOnDfoxChange(Trigger.new,Trigger.oldMap);
        ish.setInferredSolution(Trigger.new, Trigger.oldMap);
        pdmh.checkIfCountryAuthorized();
        pdmh.unsubscribeFlow();
        pdmh.leadSourceDealRegistrationFlow();
        pdmh.similarWebEmployeesFlow();
        pdmh.outboundLeadsFlow();
        //pdmh.blackListFlow();
        pdmh.frenemiesFlow();
        pdmh.journeyDecisionFlow();
        pdmh.verifyCheck();
        fmh.funelMonitorUpdateLogic((List<Lead>)Trigger.new, (Map<Id, Lead>)Trigger.oldMap);
        //Added 2021/07/13 by Itzik Winograd: MQL calculation
        mqlCalc.handle(Trigger.new, Trigger.oldMap);
        hndl.recalculateBusinessUnit(Trigger.new , Trigger.oldMap);
        hndl.setSlaTimeStamp(Trigger.new , Trigger.oldMap);
        hndl.markGroudonOnBeforeUpdate(Trigger.newMap , Trigger.oldMap);
    }
    if(Trigger.isBefore && Trigger.isInsert){
        //system.debug(trigger.new[0].type)
        hndl.fillMasterDomain(Trigger.new);
        hndl.updateDomainFields(Trigger.new);
        hndl.marketingCloudAdjustment(Trigger.new, trigger.oldMap);
        fmh.funelMonitorInsertLogic((List<Lead>)Trigger.new);
        //hndl.updateDomainFields(Trigger.new,Trigger.oldMap);
        ish.setInferredSolution(Trigger.new, Trigger.oldMap);
        pdmh.checkIfCountryAuthorized();
        pdmh.unsubscribeFlow();
        pdmh.leadSourceDealRegistrationFlow();
        pdmh.similarWebEmployeesFlow();
        pdmh.outboundLeadsFlow();
        //hndl.updateEmployeeMinAndMax((List<Lead>)Trigger.new);
        //pdmh.blackListFlow();
        //pdmh.journeyDecisionFlow();    

        hndl.beforeInsert(Trigger.new);

        //Added 2021/07/13 by Itzik Winograd: MQL calculation
        mqlCalc.handle(Trigger.new, null);
    }
}