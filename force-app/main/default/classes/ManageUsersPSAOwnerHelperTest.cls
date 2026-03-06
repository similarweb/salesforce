@isTest
private class ManageUsersPSAOwnerHelperTest {

	@isTest(SeeAllData=true) static void testWithRealPermissionSetAssignment() {
		PermissionSet ps;
		try {
			ps = [SELECT Id, IsOwnedByProfile FROM PermissionSet WHERE IsOwnedByProfile = false ORDER BY CreatedDate DESC LIMIT 1];
		} catch (Exception e) {
			System.assert(true);
			return;
		}

		Id assigneeId = UserInfo.getUserId();

		PermissionSetAssignment psa = new PermissionSetAssignment(
				AssigneeId = assigneeId,
				PermissionSetId = ps.Id
		);
		insert psa;

		PermissionSetAssignment nullPsa = new PermissionSetAssignment();
		List<PermissionSetAssignment> inputs = new List<PermissionSetAssignment>{ psa, nullPsa };

		List<Boolean> results = ManageUsersPSAOwnerHelper.getPSAProfileOwnership(inputs);

		System.assertEquals(2, results.size());
		System.assertEquals(ps.IsOwnedByProfile, results[0]);
		System.assertEquals(null, results[1]);

		delete psa;
	}
}