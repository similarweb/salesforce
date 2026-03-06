/**
 * Created by Alon.Shalev on 4/11/2024.
 */

public with sharing class UpdateMeetingOwnerBatch implements Database.Batchable<sObject> ,Database.Stateful{

    private Set<Id> meetingIdSet = new Set<Id>();
    private List<Log_Event__e> logEvents = new List<Log_Event__e>();
    private Map<String,FlowParamsObj> flowParamMap = new Map<String,FlowParamsObj>();

    public UpdateMeetingOwnerBatch(Set<Id> meetingIdSet){
        this.meetingIdSet = meetingIdSet;
    }
    public Database.QueryLocator start (Database.BatchableContext BC){
        System.debug('meetingIdSet--'+meetingIdSet);
        String query = 'SELECT Id, Name, OwnerId, TYPEOF Owner WHEN User THEN Name, Email, Manager.Name, Manager.Email WHEN Group THEN Name END FROM Meeting__c  WHERE Id IN :meetingIdSet';
        return Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext BC, List<Meeting__c> scope){
        System.debug('scope--'+scope.size());
        List<Meeting__c> meetingToUpdateList = new List<Meeting__c>();
        for(Meeting__c meeting : scope){
            SObject owner = meeting.Owner;
            if (owner.getSObjectType() == Group.sObjectType) {
                logEvents.add(LogEventUtils.createLogEventRecord(new List<String>{meeting.Id}, 'UpdateMeetingOwnerBatch',
                        'execute-updateMeetings', 'Cant update this Meeting because the owner is a group', 'no detailed Error', 'Error'));

            }else{
                User ownerForSure = (User)meeting.Owner;
                String managerId = ownerForSure.ManagerId;
                if(!this.flowParamMap.containsKey(managerId)){
                    this.flowParamMap.put(managerId, new FlowParamsObj());
                }
                System.debug('owner before --'+meeting.OwnerId);
                meeting.OwnerId = managerId;
                System.debug('owner after --'+meeting.OwnerId);
                FlowParamsObj thisManagerFlowParams = this.flowParamMap.get(managerId);
                thisManagerFlowParams.currentOwnerName = ownerForSure.Manager.Name;
                thisManagerFlowParams.previousOwnerName = ownerForSure.Name;
                thisManagerFlowParams.currentOwnerEmail = ownerForSure.Manager.Email;
                meetingToUpdateList.add(meeting);
            }


        }

        Integer index = 0;
        List<Database.SaveResult> saveResults = Database.update(meetingToUpdateList, false);
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                System.debug('didnt make it-- '+sr.getErrors()[0].getMessage());
                logEvents.add(LogEventUtils.createLogEventRecord(new List<String>{meetingToUpdateList[index].Id}, 'UpdateMeetingOwnerBatch',
                        'execute-updateMeetings', 'Cant update this Meeting', sr.getErrors().toString(), 'Error'));
            }
            index++;
        }

    }

    private void publishLogs(){
        if (!logEvents.isEmpty()) {
            EventBus.publish(logEvents);
        }
    }

    public void finish(Database.BatchableContext BC){
        System.debug('alon finished');
        System.debug('not empty');
        List<FlowParamsObj> flowParamList = this.flowParamMap.values();
        publishLogs();
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('JSON_Collection',flowParamList);
        inputs.put('typeOfRecord','Meeting');
        if(!this.flowParamMap.isEmpty() && !Test.isRunningTest()){
            Flow.Interview myFlow = new Flow.Interview.Generic_Send_Emails_to_New_Owners_Autolaunched(inputs);
            myFlow.start();
        }
    }

}