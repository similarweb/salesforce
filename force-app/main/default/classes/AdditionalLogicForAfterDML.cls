/**
 * @author Itzik Winograd
 * @date 17/06/2021
 * @description: An interface class that is used to created classes to be dynamically invoked
 *               using 'QueueableDMLUtils' class.
 */
public interface AdditionalLogicForAfterDML {
  /**
   * @author Itzik Winograd
   * @date 17/06/2021
   * @description Main method.
   * @param Set<Id> successIds - set of Ids that went through successful DML operation.
   * @param Set<Id> failIds - set of Ids that went through failed DML operation.
   * @return Void.
   */
  void handle(Set<Id> successIds, Set<Id> failIds);
}
