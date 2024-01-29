/****************************************************************************
* Name: SalesplanningbatchTest
* Author: Gunjan Saxena
* Created Date: 08/11/2022
* Description: Test class of Salesplanningbatch
*****************************************************************************/
/*****************************************************************************
* Modification log
* Name		        Date	           		Description
* Developer Name	Date of Modification	Modification Description   
****************************************************************************/
@isTest
public class SalesplanningbatchTest {
    @testSetup
    static void setUpData(){
        List<Account> Acclst = TestDataFactory.createAccounts(2);
        Acclst[0].BusiessAreaForPlanning__c = 'ZK';
        Acclst[1].BusiessAreaForPlanning__c = '';
        
        Database.DMLOptions dml = new Database.DMLOptions();
			dml.DuplicateRuleHeader.allowSave = true;
			dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        	Database.update(Acclst, dml);
        
       // update Acclst;
        list<InvoicedOrders__c> IOs = TestDataFactory.createIOs(6);
        for(InvoicedOrders__c IO : IOs){
            IO.InvoiceDate__c = system.today().addmonths(-1).toStartOfMonth();
        }
        IOs[0].BusinessArea__c = 'ZZ';
        IOs[1].BusinessArea__c = 'ZZ';
        IOs[0].ProductGroupBusinessArea__c = 'Low Carbon';
        IOs[2].BusinessArea__c = 'ZF';
        IOs[3].BusinessArea__c = 'ZW';        
        update IOs;
        
        List<SalesPlanning__c> SPLST = TestDataFactory.createSalesPlanning(7);
        for( SalesPlanning__c sp : SPLST){
            sp.ForecastTimePoint__c = system.today().addmonths(-2);
            sp.Frequency__c = 'Monthly';
            sp.ActualSoldAmount__c = 1500;
        }
        SPLST[0].ForecastLevel__c = 'Account';
        SPLST[0].Account__c = Acclst[0].ID;
        SPLST[0].ForecastTimePoint__c = system.today().addMonths(-2).toStartOfMonth();
        SPLST[0].ActualSoldAmount__c = 20;
        SPLST[0].ForecastSoldAmount__c = 30;
        SPLST[0].ActualNetProceeds__c = 50;
        SPLST[0].ForecastNetProceeds__c = 100;
        SPLST[0].Frequency__c = 'Monthly';
        
        SPLST[1].ForecastLevel__c = 'Account';
        SPLST[1].Account__c = Acclst[0].ID;
        SPLST[1].ForecastTimePoint__c = system.today().addMonths(-2).toStartOfMonth();
        SPLST[1].ActualSoldAmount__c = 20;
        SPLST[1].ForecastSoldAmount__c = 30;
        SPLST[1].ActualNetProceeds__c = 50;
        SPLST[1].ForecastNetProceeds__c = 100;
        SPLST[1].Frequency__c = 'Monthly';
        update SPLST;
        
        List<SalesPlanning__c> SPLST1 = TestDataFactory.createSalesPlanning(7);
        
        SPLST1[0].ForecastTimePoint__c = system.today().addmonths(-1);
        SPLST1[0].Account__c =  Acclst[0].ID;
        SPLST1[0].BusinessArea__c = 'ZZ - Low Carbon - B10';
        SPLST1[0].ForecastLevel__c = 'Business Area/Product Group';
        SPLST1[0].Frequency__c = 'Monthly';
            
        SPLST1[1].ForecastTimePoint__c = system.today().addmonths(-1);
        SPLST1[1].Account__c =  Acclst[0].ID;
        SPLST1[1].BusinessArea__c = 'ZZ - Low Carbon - B10';
        SPLST1[1].ForecastLevel__c = 'Account';
        SPLST1[1].Frequency__c = 'Monthly';
        
        SPLST1[2].ForecastTimePoint__c = system.today().addmonths(-1);
        SPLST1[2].Account__c =  Acclst[1].ID;
        SPLST1[2].BusinessArea__c = 'ZZ - Low Carbon - B10';
        SPLST1[2].ForecastLevel__c = 'Business Area/Product Group';
        SPLST1[2].Frequency__c = 'Monthly';
        
        SPLST1[3].ForecastTimePoint__c = system.today().addmonths(-1);
        SPLST1[3].Account__c =  Acclst[1].ID;
        SPLST1[3].BusinessArea__c = 'ZZ - Low Carbon - B10';
        SPLST1[3].ForecastLevel__c = 'Account';
        SPLST1[3].Frequency__c = 'Monthly';
        
        SPLST1[5].ForecastLevel__c = 'Account';
        SPLST1[5].ForecastTimePoint__c = system.today().addMonths(11).toStartOfMonth();
        SPLST1[5].Account__c =  Acclst[1].ID;
        SPLST1[5].BusinessArea__c = 'ZZ - Low Carbon - B10';
        SPLST1[5].Frequency__c = 'Monthly';
        
        SPLST1[6].ForecastLevel__c = 'Account';
        SPLST1[6].ForecastTimePoint__c = system.today().addMonths(11).toStartOfMonth();
        SPLST1[6].Account__c =  NULL;
        SPLST1[6].BusinessArea__c = 'ZZ - Low Carbon - B10';
        SPLST1[6].Frequency__c = 'Monthly';
        
        update SPLST1;
                
    }
    @isTest static void testOLIRecord(){
        test.starttest();
        List<SalesPlanning__c> SPLSTbefore = [Select ID from SalesPlanning__c Where ForecastLevel__c = 'Account' AND Account__c = ''];
        Salesplanningbatch b = new Salesplanningbatch(); 
        Database.executeBatch(b); 
        List<SalesPlanning__c> SPLSTafter = [Select ID from SalesPlanning__c Where ForecastLevel__c = 'Account' AND Account__c = ''];
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = SalesPlanning__c.BusinessArea__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());                                
        }
        system.assertEquals(pickListValuesList.size(), (SPLSTafter.size() - SPLSTbefore.size()), 'Incorrect output');
        test.stoptest();
    }
    @isTest static void testOLIELSERecord(){
        test.starttest();
        InvoicedOrders__c IOs = [SELECT ID, Account__c  FROM InvoicedOrders__c LIMIT 1];
        Account Acc = [SELECT ID, BusiessAreaForPlanning__c  FROM Account Where ID = :IOs.Account__c LIMIT 1];
        Acc.BusiessAreaForPlanning__c = '';
        Database.DMLOptions dml = new Database.DMLOptions();
			dml.DuplicateRuleHeader.allowSave = true;
			dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        	Database.update(Acc, dml);
        //Update Acc;
        List<SalesPlanning__c> SPLSTbefore = [Select ID from SalesPlanning__c Where ForecastLevel__c = 'Account' AND Account__c = ''];
        Salesplanningbatch b = new Salesplanningbatch(); 
        Database.executeBatch(b); 
        List<SalesPlanning__c> SPLSTafter = [Select ID from SalesPlanning__c Where ForecastLevel__c = 'Account' AND Account__c = ''];
        
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = SalesPlanning__c.BusinessArea__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());                                
        }
        system.assertEquals(pickListValuesList.size(), (SPLSTafter.size() - SPLSTbefore.size()), 'Incorrect output');
   		test.stoptest();
    }
    
}