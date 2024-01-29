/****************************************************************************
* Name: ConvertTechnicalReqControllerTest
* Author: Naina B
* Created Date: 14/11/2022
* Description: Test class for ConvertTechnicalReqController
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
* Naina Butle        9/01/2023              update test method for US-1250
* Naina Butle       02/02/2023              US-2003 On Demand 'Convert to OLI' & 'Convert Technical requirements'
****************************************************************************/
@isTest
public class ConvertTechnicalReqControllerTest {
    @testSetup
   static void setUpData(){
        List<TechnicalRequirement__c> tRlst = TestDataFactory.createTechReq(2); 
        List<Opportunity> opplst = [SELECT Id, StageName, PriceBook2Id FROM Opportunity WHERE Id =: tRlst[0].Opportunity__c LIMIT 1 ]; //TestDataFactory.createOpps(1);
        opplst[0].StageName = 'Final Check';
        update opplst;
        List<Product2> prod = [SELECT Id FROM Product2 WHERE ID =: tRlst[0].Product__c] ;
       if(prod.isEmpty()){
           TestDataFactory.createProduct(2);
       }
       List<FinishedGoods__c> fGlst = TestDataFactory.createFG(2);
        FinishedGoods__c fg = [SELECT Id, Name, SteelGradeLookup__r.SELNumber__c, Product__c FROM FinishedGoods__c LIMIT 1];
        fg.Product__c = prod[0].Id;
        update fg;
        TestDataFactory.createOrgWideSetting();
        TestDataFactory.oppLineItem(tRlst, prod, fGlst);
    }
    
    @isTest static void testOLIRecord(){
         Test.startTest();
        FinishedGoods__c fg = [SELECT Id, Name, Active__c, SteelGradeLookup__r.SELNumber__c FROM FinishedGoods__c LIMIT 1];
        TechnicalRequirement__c tR = [SELECT Id, Name, Active__c, Product__c, Product__r.IsActive,FinishedGoods__c,FinishedGoods__r.Active__c, FinishedGoods__r.Product__c, Quantity__c, Opportunity__c, Opportunity__r.StageName,  Opportunity__r.PriceBook2Id, OpportunityProduct__c, RecordTypeId, Opportunity__r.RecordTypeId, Opportunity__r.Incoterms__c FROM TechnicalRequirement__c LIMIT 1];
        tR.FinishedGoods__c = fg.ID; 
        tr.DimensionA__c = NULL;
        tr.Product__c = Null ;
        update tR;
        Opportunity opp = [SELECT Id, StageName, PriceBook2Id  FROM Opportunity WHERE ID =: tR.Opportunity__c LIMIT 1];
        ConvertTechnicalReqController.createOLIRecord(opp.ID);
        Test.stopTest();
        system.assertEquals(TR.Active__c, True, 'Technical Requirement should be Active');
    }
    @isTest static void testOLIRecordwithDifferentPB(){
        Test.startTest();
        List<Product2> prod = [SELECT Id, Name, IsActive FROM Product2 LIMIT 2];
        TechnicalRequirement__c tR = [SELECT Id, Active__c, FinishedGoods__c, Opportunity__c, OpportunityProduct__c, FinishedGoods__r.Product__c, Quantity__c, Product__c FROM TechnicalRequirement__c LIMIT 1];
        tR.Active__c = True;
        tr.Product__c = prod[0].Id;
        tr.DimensionA__c = NULL;
        update tR;
        Opportunity opp = [SELECT Id, StageName, PriceBook2Id FROM Opportunity WHERE ID =: tR.Opportunity__c LIMIT 1];
        List<PriceBookEntry> pbeList = [SELECT Id, Pricebook2Id, Product2Id, IsActive FROM PriceBookEntry where Product2Id =: tr.Product__c AND Pricebook2Id =: opp.PriceBook2Id LIMIT 1];
        if(!pbeList.isEmpty() && pbeList !=null){
        pbeList[0].IsActive = false;
        update pbeList;
        }
        ConvertTechnicalReqController.createOLIRecord(opp.ID);
        Test.stopTest();
        system.assertEquals(TR.Active__c, True, 'Technical Requirement should be Active');
    }
     @isTest static void testOLIRecordNUll(){
          Test.startTest();
        TechnicalRequirement__c tR = [SELECT Id, Active__c, FinishedGoods__c,Opportunity__c, Quantity__c, Product__c, DimensionA__c, Opportunity__r.PriceBook2Id FROM TechnicalRequirement__c LIMIT 1];
        tR.FinishedGoods__c = NUll; 
        tR.Product__c = Null;
        tr.DimensionA__c = NULL;
        update tR;
        Opportunity opp = [SELECT Id, StageName, PriceBook2Id FROM Opportunity WHERE ID =: tR.Opportunity__c LIMIT 1];
        ConvertTechnicalReqController.createOLIRecord(opp.ID);
        Test.stopTest();
        system.assertEquals(TR.Active__c, True, 'Technical Requirement should be Active');
    }
    @isTest static void testOLIRecordNotFinal(){
        Test.startTest();
        TechnicalRequirement__c tR = [SELECT Id, Active__c, FinishedGoods__c, Opportunity__c, Quantity__c, Product__c, DimensionA__c, Opportunity__r.PriceBook2Id FROM TechnicalRequirement__c LIMIT 1];
        Opportunity opp = [SELECT Id, StageName, PriceBook2Id FROM Opportunity WHERE ID =: tR.Opportunity__c LIMIT 1];
        opp.StageName = 'New';
        update opp;
        tR.Opportunity__c = opp.ID;
        update tR;
        ConvertTechnicalReqController.createOLIRecord(opp.ID);
        Test.stopTest();
        system.assertEquals(opp.StageName,'New','StageName should be New');
    }
    @isTest static void testOLIRecordNotActive(){
        Test.startTest();
        TechnicalRequirement__c tR = [SELECT Id, Active__c, FinishedGoods__c, Opportunity__c, Quantity__c, Product__c FROM TechnicalRequirement__c LIMIT 1];
        tR.Active__c = False;
        update tR;
         Opportunity opp = [SELECT Id, StageName, PriceBook2Id FROM Opportunity WHERE ID =: tR.Opportunity__c LIMIT 1];
        ConvertTechnicalReqController.createOLIRecord(opp.ID);
        Test.stopTest();
        system.assertNotEquals(TR.Active__c, null,'Active__c should not be null');
    }
    @isTest static void testOLIRecordIfNotProductEmpty(){
         Test.startTest();
        List<Product2> prod = [SELECT Id, Name,IsActive FROM Product2 LIMIT 2];
        List<OpportunityLineItem> oli = [SELECT Id,TechnicalRequirement__c,Product2Id from OpportunityLineItem LIMIT 1];
        TechnicalRequirement__c tR = [SELECT Id, Active__c, FinishedGoods__c, Opportunity__c, OpportunityProduct__c, FinishedGoods__r.Product__c, Quantity__c, Product__c FROM TechnicalRequirement__c LIMIT 1];
        tR.Active__c = True;
        tr.Product__c = prod[1].Id;
        tr.DimensionA__c = NULL;
        tr.OpportunityProduct__c = oli[0].Id;
        update tR;
        oli[0].TechnicalRequirement__c = tR.Id;
        update oli;
        Opportunity opp = [SELECT Id, StageName, PriceBook2Id FROM Opportunity WHERE ID =: tR.Opportunity__c LIMIT 1];
        ConvertTechnicalReqController.createOLIRecord(opp.ID);
        Test.stopTest();
        system.assertNotEquals(tR.Opportunity__c , null,'Opportunity should not be null');
    }
    @isTest static void testOLIRecordIfpricebookentrydifferent(){
         Test.startTest();
        List<Product2> prod = [SELECT Id, Name , IsActive FROM Product2 LIMIT 2];
        List<OpportunityLineItem> oli = [SELECT Id,TechnicalRequirement__c,Product2Id from OpportunityLineItem LIMIT 1];
        TechnicalRequirement__c tR = [SELECT Id, Active__c, FinishedGoods__c, Opportunity__c, OpportunityProduct__c, FinishedGoods__r.Product__c, Quantity__c, Product__c FROM TechnicalRequirement__c LIMIT 1];
        tR.Active__c = True;
        tr.Product__c = prod[1].Id;
        tr.DimensionA__c = NULL;
        tr.OpportunityProduct__c = oli[0].Id;
        update tR;
        oli[0].TechnicalRequirement__c = tR.Id;
        update oli;
         Opportunity opp = [SELECT Id, StageName, PriceBook2Id FROM Opportunity WHERE ID =: tR.Opportunity__c LIMIT 1];
        ConvertTechnicalReqController.createOLIRecord(opp.ID);
        Test.stopTest();
         system.assertNotEquals(tR.Opportunity__c , null,'Opportunity should not be null');
    }
    @isTest static void testOLIRecordIfExistingOLI(){
         Test.startTest();
        List<OpportunityLineItem> oli = [SELECT Id, TechnicalRequirement__c, Product2Id from OpportunityLineItem LIMIT 1];
        TechnicalRequirement__c tR = [SELECT Id, Active__c, FinishedGoods__c, Opportunity__c, OpportunityProduct__c, FinishedGoods__r.Product__c, Quantity__c, Product__c FROM TechnicalRequirement__c  WHERE Product__c != Null LIMIT 1];
        tR.Active__c = True;
        tr.Product__c = oli[0].Product2Id;
        tr.DimensionA__c = NULL;
        tr.OpportunityProduct__c = oli[0].Id;
        update tR;
        oli[0].TechnicalRequirement__c = tR.Id;
        update oli;
        ConvertTechnicalReqController.createOLIRecord(tr.Opportunity__c);
        Test.stopTest();
        system.assertNotEquals(tR.Opportunity__c , null,'Opportunity should not be null');
    }
    
    @isTest static void testNegativeOLIRecordException(){
        Test.startTest();
        List<Boolean> exceptions = new List<Boolean>();
        FinishedGoods__c fg = [SELECT Id, Name, SteelGradeLookup__r.SELNumber__c, Active__c,Product__c FROM FinishedGoods__c LIMIT 1];
         try{
        TechnicalRequirement__c tRNew = [SELECT Id, Active__c, Account__c, FinishedGoods__c,Opportunity__c, FinishedGoods__r.Product__c, Quantity__c, Product__c FROM TechnicalRequirement__c  LIMIT 1];
        tRNew.Active__c = True;
        tRNew.FinishedGoods__c = fg.ID;
        tRNew.Quantity__c = null;      
        update tRNew;
            ConvertTechnicalReqController.createOLIRecord(tRNew.Opportunity__c);
        }Catch(Exception e){
            exceptions.add(true);
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptions, 'expected at least one exception to have occured');
        for(Boolean b : exceptions){
            system.assert(b, 'Technical Requirement should have thrown an exception');
        }
    }
        @isTest static void testOLIRecord2(){
        Test.startTest();
        FinishedGoods__c fg = [SELECT Id, Name, SteelGradeLookup__r.SELNumber__c,Active__c FROM FinishedGoods__c LIMIT 1];
        TechnicalRequirement__c tR = [SELECT Id, Active__c, FinishedGoods__c, Opportunity__c, Quantity__c, Product__c, DimensionA__c FROM TechnicalRequirement__c LIMIT 1];
        tr.FinishedGoods__c = fg.ID; 
        tr.DimensionA__c = NULL;
        tr.Product__c = Null;
        update tR;
        fg.Active__c=false;
        update fg;
        Opportunity opp = [SELECT Id, StageName, PriceBook2Id FROM Opportunity WHERE ID =: tR.Opportunity__c LIMIT 1];
        ConvertTechnicalReqController.createOLIRecord(opp.ID);
        Test.stopTest();
        system.assertEquals(TR.Active__c, True, 'Technical Requirement should be Active');
    }
    
    @isTest static void testOLIRecord3(){
         Test.startTest();
        Product2 prod = [SELECT Id, Name,IsActive FROM Product2 LIMIT 1];
        TechnicalRequirement__c tR = [SELECT Id, Active__c, FinishedGoods__c, Opportunity__c, Quantity__c, Product__c, DimensionA__c FROM TechnicalRequirement__c LIMIT 1];
        tR.Product__c = prod.ID; 
        tr.DimensionA__c = NULL;
        update tR;
        prod.IsActive = false;
        update prod;
        Opportunity opp = [SELECT Id, StageName, PriceBook2Id FROM Opportunity WHERE ID =: tR.Opportunity__c LIMIT 1];
        ConvertTechnicalReqController.createOLIRecord(opp.ID);
        Test.stopTest();
        system.assertEquals(TR.Active__c, True, 'Technical Requirement should be Active');
    }
   @isTest static void testOLIRecord4TRlight(){
        Product2 prod = [SELECT Id, Name,IsActive FROM Product2 LIMIT 1];
        Opportunity opp = [SELECT Id, StageName,RecordtypeId,PriceBook2Id  FROM Opportunity LIMIT 1]; 
        opp.RecordtypeId = ConstantClass.OPPORTUNITY_PI_RECORDTYPE;
        opp.StageName='Closed';
        update opp;
        TechnicalRequirement__c tR = [SELECT Id, Active__c, FinishedGoods__c, Opportunity__c, Quantity__c,RecordtypeId, Product__c, DimensionA__c FROM TechnicalRequirement__c LIMIT 1];
        tR.Product__c = prod.ID; 
        tr.DimensionA__c = NULL;
        tr.RecordtypeId = ConstantClass.TRLIGHT_RECORDTYPE;
        tr.Opportunity__c =opp.id;
        tr.Active__c = true;
        update tR;
        prod.IsActive = false;
        update prod;
        Test.startTest();
        ConvertTechnicalReqController.createOLIRecord(opp.ID);
        Test.stopTest();
        system.assertEquals(TR.Active__c, True, 'Technical Requirement should be Active');
    }
    @isTest static void testOLIRecord5FMprodnull(){
        FinishedGoods__c fg = [SELECT Id, Name,SteelGradeLookup__r.SELNumber__c,Active__c,Product__c FROM FinishedGoods__c LIMIT 1];
        List<TechnicalRequirement__c> prFMList = new List<TechnicalRequirement__c>();
        List<TechnicalRequirement__c> tR = [SELECT Id, Active__c, FinishedGoods__c, Opportunity__c, Quantity__c, Product__c, DimensionA__c FROM TechnicalRequirement__c LIMIT 2];
        tR[0].Product__c = NULL; 
        tR[0].DimensionA__c = NULL;
        tR[0].Quantity__c = 6;
        tR[0].FinishedGoods__c = fg.ID;
        update tR[0];
        prFMList.add(tR[0]);
        Opportunity opp = [SELECT Id, StageName, PriceBook2Id,AccountId FROM Opportunity WHERE ID =: tR[0].Opportunity__c LIMIT 1];
        opp.StageName ='Final Check';
        tR[0].Opportunity__c = tR[1].Opportunity__c;
        update opp;
        tR[1].Opportunity__c = opp.id;
        tR[0].Quantity__c = 7;
        tR[1].Quantity__c = 6;
        upsert tR[0];
        upsert tR[1];
        Test.startTest();
        ConvertTechnicalReqController.createOLIRecord(opp.id);
        tR[0].Quantity__c = 10;
        update tR[0];
        ConvertTechnicalReqController.createOLIRecord(opp.id);
        Test.stopTest();
        system.assertEquals(TR[0].Active__c, true, 'Technical Requirement should  be Active');
    }
    @isTest static void testOLIRecord5FMprodnotnull(){
        Product2 prod = [SELECT Id, Name,IsActive FROM Product2 LIMIT 1];
        FinishedGoods__c fg = [SELECT Id, Name,SteelGradeLookup__r.SELNumber__c,Active__c,Product__c FROM FinishedGoods__c LIMIT 1];
        List<TechnicalRequirement__c> prFMList = new List<TechnicalRequirement__c>();
        List<TechnicalRequirement__c> tR = [SELECT Id, Active__c, FinishedGoods__c, Opportunity__c, Quantity__c, Product__c, DimensionA__c FROM TechnicalRequirement__c LIMIT 2];
        tR[0].Product__c = prod.id; 
        tR[0].DimensionA__c = NULL;
        tR[0].Quantity__c = 6;
        tR[0].FinishedGoods__c = fg.ID;
        update tR[0];
        prFMList.add(tR[0]);
        Opportunity opp = [SELECT Id, StageName, PriceBook2Id,AccountId FROM Opportunity WHERE ID =: tR[0].Opportunity__c LIMIT 1];
        opp.StageName ='Final Check';
        tR[0].Opportunity__c = tR[1].Opportunity__c;
        update opp;
        tR[1].Opportunity__c = opp.id;
        tR[0].Quantity__c = 7;
        tR[1].Quantity__c = 6;
        upsert tR[0];
        upsert tR[1];
        Test.startTest();
        ConvertTechnicalReqController.createOLIRecord(opp.id);
        tR[0].Quantity__c = 10;
        update tR[0];
        ConvertTechnicalReqController.createOLIRecord(opp.id);
        Test.stopTest();
        system.assertEquals(TR[0].Active__c, true, 'Technical Requirement should  be Active');
    }
}