public class EnrichLeadListSchedulable implements Schedulable {
  private List<Lead> leadList;
  public EnrichLeadListSchedulable(List<Lead> leadList) {
    this.leadList = leadList;
  }
  public void execute(SchedulableContext ctx) {
    System.debug(Limits.getQueueableJobs());
    update leadList;
    System.debug(Limits.getQueueableJobs());
    System.abortJob(ctx.getTriggerId());
  }
}
