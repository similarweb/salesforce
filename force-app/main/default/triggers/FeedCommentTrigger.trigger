/**
 * Created by Alon.Shalev on 10/20/2024.
 */


trigger FeedCommentTrigger on FeedComment ( after delete, after insert, after undelete,
        after update, before delete, before insert, before update) {

    FeedCommentHandler handler = new FeedCommentHandler();

    if(Trigger.isInsert){


        if(Trigger.isAfter){
            handler.callFlowWhenCaseRelated((List<FeedComment>)Trigger.new);
        }
    }

}