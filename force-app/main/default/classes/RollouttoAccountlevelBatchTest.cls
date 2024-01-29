/****************************************************************************
* Name: RollouttoAccountlevelBatchTest
* Author: Naina B
* Created Date: 21/03/2023
* Description: Test class for RollouttoAccountlevelBatch
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description 
* Gunjan Saxena     24/05/2023              Test Class for RollouttoAccountlevelBatch
****************************************************************************/
@isTest
public class RollouttoAccountlevelBatchTest {
@testSetup
    static void setUpData(){
        List<Account> Acclst = TestDataFactory.createAccounts(2);
        Acclst[0].BusiessAreaForPlanning__c = 'ZK';
        Acclst[1].BusiessAreaForPlanning__c = '';
        update Acclst;
        list<InvoicedOrders__c> IOs = TestDataFactory.createIOs(6);
        for(InvoicedOrders__c IO : IOs){
            IO.InvoiceDate__c = system.today().addMonths(-1).toStartOfMonth();
        }
        IOs[0].BusinessArea__c = 'ZZ';
        IOs[1].BusinessArea__c = 'ZZ';
        IOs[0].ProductGroupBusinessArea__c = 'Low Carbon';
        IOs[2].BusinessArea__c = 'ZF';
        IOs[3].BusinessArea__c = 'ZW'; 
        IOs[4].BusinessArea__c = 'ZZ';
        IOs[4].ProductGroupBusinessArea__c = 'Low Carbon';
        IOs[4].SoldAmount__c = 2000;
        IOs[5].BusinessArea__c = 'ZZ';
        IOs[5].ProductGroupBusinessArea__c = 'Low Carbon';
        IOs[5].SoldAmount__c = 3000;
        update IOs;
        
        List<SalesPlanning__c> SPLST = TestDataFactory.createSalesPlanning(10);
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
        
        List<SalesPlanning__c> SPLST1 = TestDataFactory.createSalesPlanning(12);
        
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
        SPLST1[5].Account__c =  IOs[4].Account__c;
        SPLST1[5].BusinessArea__c = 'ZZ - Low Carbon - B10';
        SPLST1[5].Frequency__c = 'Monthly';
        
        SPLST1[6].ForecastLevel__c = 'Account';
        SPLST1[6].ForecastTimePoint__c = system.today().addMonths(11).toStartOfMonth();
        SPLST1[6].Account__c =  NULL;
        SPLST1[6].BusinessArea__c = 'ZZ - Low Carbon - B10';
        SPLST1[6].Frequency__c = 'Monthly';
        
        SPLST1[7].ForecastLevel__c = 'Business Area/Product Group';
        SPLST1[7].ForecastTimePoint__c = system.today().addMonths(11).toStartOfMonth();
        SPLST1[7].Account__c =  NULL;
        SPLST1[7].BusinessArea__c = 'ZZ - Low Carbon - B10';
        SPLST1[7].Frequency__c = 'Monthly';
        SPLST1[7].ForecastSoldAmount__c = 1500;
        
        SPLST1[8].ForecastLevel__c = 'Business Area/Product Group';
        SPLST1[8].ForecastTimePoint__c = system.today().addMonths(11).toStartOfMonth();
        SPLST1[8].Account__c =  NULL;
        SPLST1[8].BusinessArea__c = 'ZZ - Low Carbon - B10';
        SPLST1[8].Frequency__c = 'Yearly';
        SPLST1[8].ForecastSoldAmount__c = 2000;
        
        SPLST1[9].ForecastLevel__c = 'Account';
        SPLST1[9].ForecastTimePoint__c = system.today().addMonths(30).toStartOfMonth();
        SPLST1[9].Account__c =  NULL;
        SPLST1[9].BusinessArea__c = 'ZZ - Low Carbon - B10';
        SPLST1[9].Frequency__c = 'Yearly';
        SPLST1[9].ForecastSoldAmount__c = 2000;
        
        SPLST1[10].ForecastLevel__c = 'Account';
        SPLST1[10].ForecastTimePoint__c = system.today().addMonths(30).toStartOfMonth();
        SPLST1[10].Account__c =  IOs[0].Account__c;
        SPLST1[10].BusinessArea__c = 'ZZ - Low Carbon - B10';
        SPLST1[10].Frequency__c = 'Yearly';
        SPLST1[10].ForecastSoldAmount__c = 2000;
        

        update SPLST1;
    }
    @isTest static void testRollouttoAccount(){
        list<InvoicedOrders__c> IOs = new list<InvoicedOrders__c>();
        IOs = [SELECT Id, Account__c,BusinessArea__c,SoldAmount__c,Nettoerloes__c, InvoiceDate__c,ProductCategoryBusinessArea__c,ProductGroupBusinessArea__c FROM InvoicedOrders__c ];
        list<SalesPlanning__c> SPold = new list<SalesPlanning__c>();
        SPold = [SELECT Id, Frequency__c, ForecastTimePoint__c, ForecastSoldAmount__c, ForecastLevel__c, Account__c,BusinessArea__c FROM SalesPlanning__c Where ForecastLevel__c = 'Account'];
        RollouttoAccountlevelBatch b = new RollouttoAccountlevelBatch(); 
        Database.executeBatch(b);
        list<SalesPlanning__c> SPnew = new list<SalesPlanning__c>();
        SPnew = [SELECT Id, Frequency__c, ForecastTimePoint__c, ForecastSoldAmount__c, ForecastLevel__c, Account__c,BusinessArea__c FROM SalesPlanning__c Where ForecastLevel__c = 'Account'];
        assert.areEqual(SPold.size(),SPnew.size(),'As it is the chain of batches update is done in future');
    }
}