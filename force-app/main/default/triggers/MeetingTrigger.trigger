/**
 * Created by alonshalev on 25/01/2023.
 */
// this class is a custom trigger that support levelEleven for meeting custom object
trigger MeetingTrigger on Meeting__c(after insert, after update, after delete) {
  if (UserInfo.isCurrentUserLicensed('ePrize_Zemzu')) {
    ePrize_Zemzu.SCBCustomContestEvaluator.evaluate(
      'Meeting__c',
      Trigger.new,
      Trigger.old
    );
  }

}
