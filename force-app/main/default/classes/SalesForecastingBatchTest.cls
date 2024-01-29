/****************************************************************************
* Name: SalesForecastingBatch_Test
* Author: Impana Paalyam
* Created Date: 17/03/2023
* Description: Test Class for Batch Class - SalesForecastingBatch
*****************************************************************************/
@isTest
private class SalesForecastingBatchTest {
    @isTest
    static void SalesForecastingBatchTest(){
        List<Account> act = TestDataFactory.createAccounts(1);
        act[0].BusiessAreaForPlanning__c = 'ZK';
        act[0].SAPAccountNumber__c ='666';
        update act;
        Account acc = [Select Id, Name, BusiessAreaForPlanning__c,SAPAccountNumber__c from Account limit 1];
        SalesPlanning__c newSP = new SalesPlanning__c();
        newSP.BusinessArea__c = 'ZK';
        newSP.ForecastTimePoint__c = Date.newInstance(System.today().year(), 1, 1).addMonths(36);
        newSP.ForecastLevel__c = 'Business Area/Product Group';
        newSP.Frequency__c = 'Yearly';
        insert newSP;
        List<SalesPlanning__c> SpList =  new List<SalesPlanning__c>();
        SpList.add(newSP); 
        SpList[0].Account__c = acc.id;
        SpList[0].BusinessArea__c = acc.BusiessAreaForPlanning__c; 
        update SpList;
        String CRON_EXP = '0 0 0 1 7 ? 2029';
        Test.startTest();
        SalesForecastingBatch ba= new SalesForecastingBatch();
        Database.executeBatch(ba,5);
        System.schedule('Sales Forecast Test Job',CRON_EXP, new SalesForecastingBatch());
        Test.stopTest();
        SalesPlanning__c sp = [SELECT id,BusinessArea__c,ForecastTimePoint__c, Account__c FROM SalesPlanning__c LIMIT 1];
        System.assertEquals('ZK', sp.BusinessArea__c, 'Incorrect output');
    }
}