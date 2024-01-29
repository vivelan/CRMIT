/****************************************************************************
* Name: OLIProductfinderTest
* Author: Harshitha Udaykumar
* Created Date: 28/09/2023
* Description: Test class of OLIProductfinder
*****************************************************************************/
/*****************************************************************************
* Modification log
* Name		        Date	           		Description
* Developer Name	Date of Modification	Modification Description   
****************************************************************************/
@isTest
public class  OLIProductfinderTest {
    @testSetup
    static void setUpData(){
      TestDataFactory.oppLineItemTestData();
      TestDataFactory.createOrgWideSetting();
      TestDataFactory.createFG(1);
      TestDataFactory.createSFG(1);
      TestDataFactory.createRollingMill(2);
      TestDataFactory.createLV(1);
    }
    @isTest static void testOLIRecord(){
        OLIProductfinder.customMetadata  = (List<MasterValues__mdt>) JSON.deserialize( '[{"Value__c":"TRUE"}]', List<MasterValues__mdt>.class);
        List<OpportunityLineItem> oli = [SELECT Id, CostOfProduction__c, ExternalCostOfProduction__c,Product2Id,DimensioncalculationA__c from OpportunityLineItem LIMIT 1];
        List<LVPostion__c> lvlst = [SELECT Id,InternalSteelGrade__r.SELNumber__c, Rollingmill__c, HeatTreatment__c, DimensionAFrom__c, PrimRollingHomogenize__c, PrimRollingInputformat__c, HZVCheckTreatment__c,
                                    Surfacedefectinspec__c, SurfaceTreatment__c, Peelingbarwirerod__c, Homogenize__c, HZVAnnealing__c, USInspection__c, HZVSampletest__c, Product__c from LVPostion__c LIMIT 1];
        lvlst[0].Product__c = oli[0].Product2Id;
        update lvlst;
        oli[0].LVPosition__c = lvlst[0].Id;
        update oli;
        Product2 prod = [SELECT Id, Name FROM Product2 where Id = :oli[0].Product2Id LIMIT 1];
        prod.Flat__c = false;
        prod.Family = 'Wire Rod';
        update prod;
        SteelGrade__c stgr = new SteelGrade__c();
        stgr.SELNumber__c = '123';
        stgr.ExternalID__c = '1234';
        insert stgr;
        FinishedGoods__c fg = [SELECT Id, Name, SteelGradeLookup__r.SELNumber__c, Product__c,Rollingmill__c FROM FinishedGoods__c LIMIT 1];
        fg.Product__c = oli[0].Product2Id;
        fg.SteelGradeLookup__c = stgr.id;
        fg.DimensionA__c = 7.00;
        fg.PrimRollingInputFormat__c ='146';
        fg.HeatTreatment__c ='GL';
        fg.HZVCheckTreatment__c ='MTA';
        fg.Straightening__c ='P';
        fg.PeelRodWire__c = 'U';
        fg.SurfaceDefectInspec__c = 'D2';
        fg.USInspection__c = 'V';
        fg.Active__c = true;
        fg.RollingMill__c = '11';
        fg.MaterialNumber__c ='100052669';
        update fg;
        List<ID> olilst = new List<ID>();
        olilst.add(oli[0].id);
        Test.startTest();
        List<ID> oliID = OLIProductfinder.updateOLIProductFinderStatus(olilst);
        System.assertEquals(olilst, oliID, 'OLI Prouct FInder Status');
        Test.stopTest();
    }

}