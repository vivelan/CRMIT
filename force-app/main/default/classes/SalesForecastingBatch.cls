/****************************************************************************
* Name: SalesForecastingBatch
* Author: Impana Paalyam
* Created Date: 17/03/2023
* Description: Batch Class and Scheduled Class to run on July 1st Every Year to create sales planning records.
*****************************************************************************/
global class SalesForecastingBatch implements Database.Batchable<SObject>,Schedulable {   
    global void execute(SchedulableContext SC) {
        SalesForecastingBatch batchJob = new SalesForecastingBatch();
        Database.executeBatch(batchJob);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,name,SAPAccountNumber__c, BusiessAreaForPlanning__c from Account where SAPAccountNumber__c!=null and BusiessAreaForPlanning__c!=null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<SalesPlanning__c> newRecords = new List<SalesPlanning__c>();
        SalesPlanning__c sp = new SalesPlanning__c();
        List<String> businessAreas = new List<String>();
        
        // check if Business Area field is a picklist and retrieve all its values
        if (sp.getSObjectType().getDescribe().fields.getMap().containsKey('BusinessArea__c')) {
            Schema.DescribeFieldResult fieldResult = sp.getSObjectType().getDescribe().fields.getMap().get('BusinessArea__c').getDescribe();
            if (fieldResult.getType() == Schema.DisplayType.PICKLIST) {
                List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
                for (Schema.PicklistEntry picklistValue : picklistValues) {
                    if(picklistValue.isActive()) {
                        businessAreas.add(picklistValue.getValue());
                    }
                }
            }
        }
        //system.debug('****businessAreas***'+businessAreas);
        for (String businessArea : businessAreas) {
            SalesPlanning__c newSP = new SalesPlanning__c();
            newSP.BusinessArea__c = businessArea;
            newSP.ForecastTimePoint__c = Date.newInstance(System.today().year(), 1, 1).addMonths(36);
            newSP.ForecastLevel__c = 'Business Area/Product Group';
            newSP.Frequency__c = 'Yearly';
            newRecords.add(newSP);
        }
        Set<String> busiessAreaValueSet = new Set<String>();
        for (SObject record : scope) {
            Account acc = (Account)record;
            busiessAreaValueSet.addAll(acc.BusiessAreaForPlanning__c.split(';')); 
            //system.debug('****busiessAreaValueSet***'+busiessAreaValueSet);
            for (String businessArea : busiessAreaValueSet) {
                SalesPlanning__c newSP = new SalesPlanning__c();
                newSP.BusinessArea__c = businessArea;
                newSP.ForecastTimePoint__c = Date.newInstance(System.today().year(), 1, 1).addMonths(36);
                newSP.ForecastLevel__c = 'Account';
                newSP.Account__c=acc.id;
                newSP.Frequency__c = 'Yearly';
                newRecords.add(newSP);
            } busiessAreaValueSet.clear();
        }
        
        insert newRecords;
    }
    global void scheduleBatchJob() {
        Datetime jobStart = Datetime.newInstance(2023, 7, 1, 0, 0, 0);
        String cronExp = '0 0 0 1 7 ? *';
        System.schedule('Sales Forecast Batch Job', cronExp, new SalesForecastingBatch());
    }
    
    global void finish(Database.BatchableContext BC) {
        // implementation
    }
}