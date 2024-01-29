/****************************************************************************
* Name: ConvertTechReqToOLITest
* Author: Gunjan Saxena
* Created Date: 08/11/2022
* Description: Test class of ConvertTechReqToOLI
*****************************************************************************/
/*****************************************************************************
* Modification log
* Name		        Date	           		Description
* Developer Name	Date of Modification	Modification Description   
****************************************************************************/
@isTest
public class  ConvertTechReqToOLITest {
    @testSetup
    static void setUpData(){
        OpportunityLineItem oli = TestDataFactory.oppLineItemTestData();
        TestDataFactory.createRollingMill(2);
        TestDataFactory.standardPriceBook();
        TestDataFactory.createpriceBookEntry();
       //	List<Opportunity> opplst = TestDataFactory.createOpps(1);
       List<Opportunity> opplst = [Select ID,PriceBook2Id from Opportunity  Limit 1];
       // opplst[0].PriceBook2Id = priceBookEntryData.Pricebook2Id;
       // update opplst;       
        //List<TechnicalRequirement__c> tRlst = TestDataFactory.createTR(1); 
        List<TechnicalRequirement__c> tRlst = [Select ID,Opportunity__c FROM TechnicalRequirement__c LIMIT 1];
        If(tRlst.size() > 0){
            tRlst[0].Opportunity__c = opplst[0].Id;
        }
        update tRlst;        
        List<FinishedGoods__c> fGlst = TestDataFactory.createFG(1);
        FGlst[0].Product__c = oli.Product2Id;
        update FGlst[0];
        TestDataFactory.createSFG(1);
        TestDataFactory.createSteelGrade(1);
        TestDataFactory.createOrgWideSetting();
    }
    
    @isTest static void testOLIRecord(){
        Test.startTest();
        FinishedGoods__c fg = [SELECT Id, Name, SteelGradeLookup__r.SELNumber__c,Product__c FROM FinishedGoods__c LIMIT 1];
        Opportunity opp = [SELECT Id, StageName, PriceBook2Id FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oli = [SELECT Id,TechnicalRequirement__c from OpportunityLineItem LIMIT 1];
        TechnicalRequirement__c tR = [SELECT Id, Active__c,OpportunityProduct__c, FinishedGoods__c, Quantity__c, Product__c,DimensionA__c FROM TechnicalRequirement__c LIMIT 1];
        tR.Opportunity__c = opp.ID;
        tR.FinishedGoods__c = fg.ID; 
        tr.OpportunityProduct__c = oli[0].Id;
        tr.DimensionA__c = NULL;
        update tR;
        oli[0].TechnicalRequirement__c = tR.Id;
        update oli;
        List<ID> TRSC0lst  = new List<ID>();   
        TRSC0lst.add(tR.ID);
        //Test.startTest();
        ConvertTechReqToOLI.ConvertTechnicalRequirementToOLI(TRSC0lst);
        Test.stopTest();
        system.assertEquals(TR.Active__c, True, 'Technical Requirement should be Active');
    } 
    
     @isTest static void testOLIRecordprd(){
         Test.startTest();
        PriceBookEntry prb = [SELECT Id,  Product2Id FROM PriceBookEntry WHERE  IsActive = true LIMIT 1];
        Opportunity opp = [SELECT Id, StageName, PriceBook2Id FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oli = [SELECT Id,TechnicalRequirement__c from OpportunityLineItem LIMIT 1];
        TechnicalRequirement__c tR = [SELECT Id, Active__c,OpportunityProduct__c, Opportunity__c, Product__c, FinishedGoods__c, Quantity__c, DimensionA__c FROM TechnicalRequirement__c LIMIT 1];
        tR.Opportunity__c = opp.ID;
        tR.Product__c = prb.Product2Id; 
        tr.OpportunityProduct__c = oli[0].Id;
        tr.DimensionA__c = NULL;
        update tR;
        oli[0].TechnicalRequirement__c = tR.Id;
        update oli;
        List<ID> TRSC0lst  = new List<ID>();   
        TRSC0lst.add(tR.ID);
        //Test.startTest();
        ConvertTechReqToOLI.ConvertTechnicalRequirementToOLI(TRSC0lst);
        Test.stopTest();
        system.assertEquals(TR.Active__c, True, 'Technical Requirement should be Active');
    } 
     @isTest static void testOLIRecordst(){
         Test.startTest();
        PriceBookEntry prb = [SELECT Id,  Product2Id FROM PriceBookEntry WHERE  IsActive = true LIMIT 1];
         Product2 prd = [SELECT Id, Flat__c, Family FROM PRODUCT2 WHERE ID = :prb.Product2Id];
         prd.Flat__c = false;
         prd.Family = 'Wire Rod';
         update prd;
        
         List<SteelGrade__c> STLst = [Select ID,ExcludeFromProductFinder__c from SteelGrade__c];
         for(SteelGrade__c st : STLst){
             st.ExcludeFromProductFinder__c = False;
         }
         update STLst;
        Opportunity opp = [SELECT Id, StageName, PriceBook2Id FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oli = [SELECT Id,TechnicalRequirement__c from OpportunityLineItem LIMIT 1];
        TechnicalRequirement__c tR = [SELECT Id, Active__c,OpportunityProduct__c, Opportunity__c, Product__c, FinishedGoods__c, Quantity__c, DimensionA__c FROM TechnicalRequirement__c LIMIT 1];
        tR.Opportunity__c = opp.ID;
        tR.Product__c = prb.Product2Id; 
        tr.OpportunityProduct__c = oli[0].Id;
        tr.DimensionA__c = 5;
         tr.Rollingmill__c = '11';
        update tR;
        oli[0].TechnicalRequirement__c = tR.Id;
        update oli;
        List<ID> TRSC0lst  = new List<ID>();   
        TRSC0lst.add(tR.ID);
        //Test.startTest();
        ConvertTechReqToOLI.ConvertTechnicalRequirementToOLI(TRSC0lst);
         system.assertEquals(TR.Active__c, True, 'Technical Requirement should be Active');
        Test.stopTest();
        
    } 
    @isTest static void testinsertOLIRecord(){
        Test.startTest();
        FinishedGoods__c fg = [SELECT Id, Name, SteelGradeLookup__r.SELNumber__c,Product__c FROM FinishedGoods__c LIMIT 1];
        
        Opportunity opp = [SELECT Id, StageName, PriceBook2Id FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oli = [SELECT Id,TechnicalRequirement__c from OpportunityLineItem LIMIT 1];
        TechnicalRequirement__c tR = [SELECT Id, Active__c,OpportunityProduct__c, FinishedGoods__c, Quantity__c, Product__c,DimensionA__c FROM TechnicalRequirement__c where OpportunityProduct__c = '' LIMIT 1];
        tR.Opportunity__c = opp.ID;
        tR.FinishedGoods__c = fg.ID; 
        tr.OpportunityProduct__c = oli[0].Id;
        tr.DimensionA__c = NULL;
        update tR;
        List<ID> TRSC0lst  = new List<ID>();   
        TRSC0lst.add(tR.ID);
        //Test.startTest();
        ConvertTechReqToOLI.ConvertTechnicalRequirementToOLI(TRSC0lst);
        Test.stopTest();
        system.assertEquals(TR.Active__c, True, 'Technical Requirement should be Active');
    } 
 
    @isTest static void testproductFinderToolbulk(){
        List<Id> technicalRequirementsToConvert = new List<Id> ();
        for(TechnicalRequirement__c tr : [SELECT ID,Product__c,FinishedGoods__c,Opportunity__c,Quantity__c,Account__c FROM TechnicalRequirement__c  ]){
            technicalRequirementsToConvert.Add(TR.Id);
        }
        Test.startTest();
        Map<Id,ConvertTechReqToOLI.FMHZVstatusreturnwrapper> fmmap = ConvertTechReqToOLI.productFinderToolbulk(technicalRequirementsToConvert);
        Test.stopTest();
        System.assert(fmmap.size() > 0,'Map is not null'); 
    }
       
}