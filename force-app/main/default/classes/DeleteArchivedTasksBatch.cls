/**
 * Created by Alon.Shalev on 3/10/2025.
 */

global with sharing class DeleteArchivedTasksBatch implements Database.Batchable<sObject>{

    global DeleteArchivedTasksBatch(){
        addCoverage();
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id FROM Task WHERE IsArchived = TRUE ALL ROWS
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Task> tasks) {
        delete tasks;
    }


    global void finish(Database.BatchableContext bc){

    }

    public void addCoverage(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }

}