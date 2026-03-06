/**
 * Created by Alon.Shalev on 2/2/2025.
 */

public with sharing class NoTouchProcessQueueable implements Queueable {
  private NoTouchProcess.NoTouchObj noTouchObj;
  private Integer numberOfRetries;

  public NoTouchProcessQueueable(
    NoTouchProcess.NoTouchObj noTouchObj,
    Integer numberOfRetries
  ) {
    this.noTouchObj = noTouchObj;
    this.numberOfRetries = numberOfRetries;
  }

  public void execute(QueueableContext context) {
    NoTouchProcess noTouchProcess = new NoTouchProcess();
    String NT_Subscription_FirstCharge_DateStr = this.noTouchObj.NT_Subscription_FirstCharge_Date !=
      null
      ? String.valueOf(this.noTouchObj.NT_Subscription_FirstCharge_Date)
      : null;
    String accountId = noTouchProcess.handleNoTouch(
      this.noTouchObj.uid,
      this.noTouchObj.email,
      this.noTouchObj.cname,
      this.noTouchObj.fName,
      this.noTouchObj.lName,
      this.noTouchObj.country,
      this.noTouchObj.websiteDomain,
      this.noTouchObj.industry,
      this.noTouchObj.minEmployees,
      this.noTouchObj.maxEmployees,
      NT_Subscription_FirstCharge_DateStr,
      this.numberOfRetries
    );

    Services.handleResponse(accountId, new RestResponse(), '', noTouchProcess);
    //        String jsonResponse = '';
    //        if (Services.validateSfAccountId(accountId)) {
    //            jsonResponse = '{"response": {"status": "Success", "message": "", "accountId": "' + accountId + '" }}';
    //            noTouchProcess.recordLog(true, jsonResponse, accountId);
    //        }else{
    //            jsonResponse = '{"response": {"status": "Failure", "message": "' + accountId + '", "accountId": ""}}';
    //            noTouchProcess.recordLog(false, jsonResponse, accountId);
    //        }
    //
    //        if (noTouchProcess.retryNeeded && this.numberOfRetries < 3) {
    //            String cronExpression = System.now().addMinutes(5).format('s m H d M ? yyyy');
    //            System.schedule('Retry NoTouch Process - ' + Datetime.now(), cronExpression,
    //                    new NoTouchProcessSchedule(this.noTouchObj, this.numberOfRetries + 1));
    //        }
  }
}
