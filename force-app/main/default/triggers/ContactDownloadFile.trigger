/*
 * @Author: ZedXagE - ITmyWay
 * @Date: 2018-12-25 09:50:47
 * @Last Modified by: ZedXagE
 * @Last Modified time: 2019-02-28 12:23:10
 */

trigger ContactDownloadFile on Contact(after insert, after update) {
  Map<String, List<String>> ups = new Map<String, List<String>>();
  List<ZCampaignAutomation.objcheck> objs = new List<ZCampaignAutomation.objcheck>();
  for (Contact con : Trigger.new) {
    ups.put(con.id, new List<String>());
    if (Trigger.isUpdate) {
      String formname = con.Web_Form_Name__c != null
        ? con.Web_Form_Name__c
        : '';
      if (
        con.Form_Submission_Date_and_Time__c != null &&
        con.Form_Submission_Date_and_Time__c !=
        Trigger.OldMap.get(con.id).Form_Submission_Date_and_Time__c
      ) {
        if (ITmyWayEngagementController.formnames.containsKey(formname))
          formname = ITmyWayEngagementController.formnames.get(formname);
        String subj = '';
        Boolean ok = false;
        if (formname.contains('Report')) {
          ok = true;
          subj = con.CTA_Description__c != null ? con.CTA_Description__c : '';
        } else if (formname.contains('Webinar')) {
          ok = true;
          subj = con.Webinar_Name__c != null ? con.Webinar_Name__c : '';
        } else if (formname.contains('Event')) {
          ok = true;
          subj = con.Event_Name__c != null ? con.Event_Name__c : '';
        }
        if (ok)
          ups.get(con.id).add('Form Handler: ' + formname + ' - ' + subj);
        if (
          formname.contains('Webinar Recorded') || formname.contains('Report')
        )
          objs.add(
            new ZCampaignAutomation.objcheck('Contact', con.id, formname, subj)
          );
      }
      if (
        (con.Web_Form_Name__c != Trigger.oldMap.get(con.id).Web_Form_Name__c ||
        con.Webinar_Name__c != Trigger.oldMap.get(con.id).Webinar_Name__c) &&
        formname.contains('Zoom') &&
        (formname.contains('Registered') || formname.contains('Attended'))
      ) {
        String subj = con.Webinar_Name__c != null ? con.Webinar_Name__c : '';
        objs.add(
          new ZCampaignAutomation.objcheck('Contact', con.id, formname, subj)
        );
      }
    } else if (Trigger.isInsert) {
      String formname = con.Web_Form_Name__c != null
        ? con.Web_Form_Name__c
        : '';
      if (con.Form_Submission_Date_and_Time__c != null) {
        if (ITmyWayEngagementController.formnames.containsKey(formname))
          formname = ITmyWayEngagementController.formnames.get(formname);
        String subj = '';
        Boolean ok = false;
        if (formname.contains('Report')) {
          ok = true;
          subj = con.CTA_Description__c != null ? con.CTA_Description__c : '';
        } else if (formname.contains('Webinar')) {
          ok = true;
          subj = con.Webinar_Name__c != null ? con.Webinar_Name__c : '';
        } else if (formname.contains('Event')) {
          ok = true;
          subj = con.Event_Name__c != null ? con.Event_Name__c : '';
        }
        if (ok)
          ups.get(con.id).add('Form Handler: ' + formname + ' - ' + subj);
        if (
          formname.contains('Webinar Recorded') || formname.contains('Report')
        )
          objs.add(
            new ZCampaignAutomation.objcheck('Contact', con.id, formname, subj)
          );
      }
      if (
        formname.contains('Zoom') &&
        (formname.contains('Registered') || formname.contains('Attended'))
      ) {
        String subj = con.Webinar_Name__c != null ? con.Webinar_Name__c : '';
        objs.add(
          new ZCampaignAutomation.objcheck('Contact', con.id, formname, subj)
        );
      }
    }
  }
  ITmyWayEngagementController.createTask(ups);
  ZCampaignAutomation.Handler(objs);
}
