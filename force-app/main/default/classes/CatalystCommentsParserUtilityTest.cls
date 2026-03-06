@IsTest
public with sharing class CatalystCommentsParserUtilityTest {
	@IsTest
	static void parseTaskCommentsTest() {
		Task t = new Task(Subject = 'Test', Description = 'Categories: QBR\n## Tasks');
		insert t;

		Test.startTest();
		String subType = CatalystCommentsParserUtility.parseTaskComments(new List<String>{t.Id}).get(0);
		Test.stopTest();

		System.assertEquals('QBR', subType);
	}
}