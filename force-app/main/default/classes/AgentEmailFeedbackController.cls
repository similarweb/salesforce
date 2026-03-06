public with sharing class AgentEmailFeedbackController {
	@AuraEnabled(cacheable = false)
	public static AgentEmailDTO getData(String recordId) {
		Task t = [
				SELECT Id, HTML_Template_Approval_Status__c, HTML_Template_Reviewer_Notes__c, WhoId
				FROM Task
				WHERE Id =: recordId
		];

		String htmlTemplate = String.isNotBlank(t.WhoId) ? (String.valueOf(t.WhoId).startsWith('00Q') ?
							  [SELECT Id, Last_Contact_Us_Form_HTML_Template__c FROM Lead WHERE Id =: t.WhoId].Last_Contact_Us_Form_HTML_Template__c :
							  [SELECT Id, Last_Contact_Us_Form_HTML_Template__c FROM Contact WHERE Id =: t.WhoId].Last_Contact_Us_Form_HTML_Template__c) :
							  null;

		return new AgentEmailDTO(t, htmlTemplate);
	}

	@AuraEnabled(cacheable = false)
	public static String saveData(String jsonInput) {
		AgentEmailDTO agentEmailDTO = (AgentEmailDTO) JSON.deserialize(jsonInput, AgentEmailDTO.class);

		Task t = new Task(
				Id = agentEmailDTO.taskId,
				HTML_Template_Approval_Status__c = agentEmailDTO.approvalStatus,
				HTML_Template_Reviewer_Notes__c = agentEmailDTO.reviewerNotes
		);

		try {
			update t;
		} catch (Exception e) {
			return e.getMessage();
		}

		return 'Success';
	}

	public class AgentEmailDTO {
		@AuraEnabled
		public String taskId;
		@AuraEnabled
		public String htmlTemplate;
		@AuraEnabled
		public String approvalStatus;
		@AuraEnabled
		public String reviewerNotes;

		private AgentEmailDTO(Task t, String htmlTemplate) {
			this.taskId = t.Id;
			this.htmlTemplate = htmlTemplate;
			this.approvalStatus = t.HTML_Template_Approval_Status__c;
			this.reviewerNotes = t.HTML_Template_Reviewer_Notes__c;
		}
	}
}