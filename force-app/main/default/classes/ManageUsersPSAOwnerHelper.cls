public with sharing class ManageUsersPSAOwnerHelper {
  @InvocableMethod(
    label='Get IsOwnedByProfile for Permission Set Assignments'
    description='Returns true if each related Permission Set is owned by a Profile.'
  )
  public static List<Boolean> getPSAProfileOwnership(
    List<PermissionSetAssignment> psaList
  ) {
    List<Boolean> results = new List<Boolean>();

    if (psaList == null || psaList.isEmpty()) {
      return results;
    }

    // Collect PSA Ids
    Set<Id> psaIds = new Set<Id>();
    for (PermissionSetAssignment psa : psaList) {
      if (psa.Id != null)
        psaIds.add(psa.Id);
    }

    if (psaIds.isEmpty()) {
      return results;
    }

    // Query PermissionSetAssignment with related PermissionSet
    Map<Id, PermissionSetAssignment> psaMap = new Map<Id, PermissionSetAssignment>(
      [
        SELECT Id, PermissionSet.IsOwnedByProfile
        FROM PermissionSetAssignment
        WHERE Id IN :psaIds
      ]
    );

    // Match the order of inputs
    for (PermissionSetAssignment psa : psaList) {
      if (psaMap.containsKey(psa.Id)) {
        results.add(psaMap.get(psa.Id).PermissionSet.IsOwnedByProfile);
      } else {
        results.add(null);
      }
    }

    return results;
  }
}
