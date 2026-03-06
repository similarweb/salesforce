/**
 * Created by zohar.sinay on 03/07/2024.
 */

public with sharing class ZuoraUpdateChargeCARRSchedulable implements Schedulable {
  public void execute(SchedulableContext sc) {
    Id batchInstanceId = Database.executeBatch(
      new ZuoraUpdateChargeCARRBatch(),
      1
    );
  }
}
