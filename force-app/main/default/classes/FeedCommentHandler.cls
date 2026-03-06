/**
 * Created by Alon.Shalev on 10/20/2024.
 */

public with sharing class FeedCommentHandler {
  public void callFlowWhenCaseRelated(List<FeedComment> newList) {
    Map<String, Object> inputs = new Map<String, Object>();
    List<FeedComment> relevantFeedComments = new List<FeedComment>();
    Set<Id> caseIds = new Set<Id>();

    for (FeedComment comment : newList) {
      String parentId = comment.ParentId;
      if (parentId.startsWith('500')) {
        relevantFeedComments.add(comment);
        caseIds.add(parentId);
      }
    }
    if (!relevantFeedComments.isEmpty()) {
      Map<Id, Case> relatedCasesMap = new Map<Id, Case>(
        [
          SELECT
            Id,
            CaseNumber,
            Subject,
            Status,
            type,
            RecordType.Name,
            Case_Sub_Type__c,
            Requester__r.profile.Name,
            Requester__c,
            Do_Not_Reopen__c,
            Original_Requester__c
          FROM Case
          WHERE Id IN :caseIds
        ]
      );
      Map<Id, FlowParamsObj> flowParamMap = new Map<Id, FlowParamsObj>();
      for (FeedComment feedComment : relevantFeedComments) {
        if (!flowParamMap.containsKey(feedComment.Id)) {
          flowParamMap.put(feedComment.Id, new FlowParamsObj());
        }
        FlowParamsObj thisFlowObj = flowParamMap.get(feedComment.Id);
        thisFlowObj.caseItem = relatedCasesMap.get(feedComment.ParentId);
        thisFlowObj.feedComment = feedComment;
      }
      system.debug('hello tal');
      inputs.put('JSON_Collection', flowParamMap.values()[0]);
      Flow.Interview myFlow = new Flow.Interview.FeedComment_AL_New_Comment_On_Case(
        inputs
      );
      system.debug('hello tal2 -- ' + inputs);
      myFlow.start();
      system.debug('hello tal3 -- ' + inputs);
    }
  }
}
