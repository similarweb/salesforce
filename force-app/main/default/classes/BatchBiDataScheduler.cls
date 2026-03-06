global class BatchBiDataScheduler implements Schedulable{  
    global void execute (SchedulableContext SC){
        BatchBIDataPopulateRelatedRecords biBatch = new BatchBIDataPopulateRelatedRecords(false);
        database.executeBatch(biBatch, 30);         
    }
}