/**
 * Created by Alon.Shalev on 3/4/2025.
 */

public with sharing class NoTouchProcessSchedule implements Schedulable {
  private NoTouchProcess.NoTouchObj noTouchObj;
  private Integer numberOfRetries;

  public NoTouchProcessSchedule(
    NoTouchProcess.NoTouchObj noTouchObj,
    Integer numberOfRetries
  ) {
    this.noTouchObj = noTouchObj;
    this.numberOfRetries = numberOfRetries;
  }

  public void execute(SchedulableContext context) {
    NoTouchProcessQueueable queueable = new NoTouchProcessQueueable(
      this.noTouchObj,
      this.numberOfRetries
    );
    system.enqueueJob(queueable);
  }
}
