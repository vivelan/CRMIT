/****************************************************************************
* Name: PricingToolControllerTest
* Author: Naina Butle
* Created Date: 13/09/2022
* Description: test class of PricingToolController
*****************************************************************************
* Modification log
* Name		     Date	           		Description 
* Developer Name	Date of Modification	Modification Description   
****************************************************************************/
@isTest
public class PricingToolControllerTest {
    @testSetup static void setUpData() { 
        TestDataFactory.createpriceBookEntry();
        TestDataFactory.oppLineItemTestData();
        TestDataFactory.createFG(1);
        TestDataFactory.createPls(8);
        TestDataFactory.createIOs(2);
               
        List<PriceLevelSurcharge__c> pls1 = [SELECT id from PriceLevelSurcharge__c ];
        pls1[1].PriceLevel__c = '2c';
        pls1[1].BusinessArea__c = 'ZK';
        pls1[0].PriceLevel__c = '2b';
        pls1[2].BusinessArea__c = 'ZK';
        pls1[2].PriceLevel__c = '3';
        pls1[2].Country__c = 'IN';
        pls1[3].PriceLevel__c = '5';
        pls1[3].BusinessArea__c = 'ZZ';
        pls1[3].BusinessSubgroup__c = 'Welding Wire (SZW)';
        pls1[4].BusinessArea__c = 'ZK';
        pls1[4].PriceLevel__c = 'Orientation Price';
        pls1[5].PriceLevel__c = '5';
        pls1[5].BusinessArea__c = 'ZK';
        pls1[6].BusinessArea__c = 'ZZ';
        pls1[6].PriceLevel__c = 'Orientation Price';
        pls1[6].BusinessSubgroup__c = 'Welding Wire (SZW)';
        pls1[7].BusinessArea__c = 'ZZ';
        pls1[7].PriceLevel__c = '2c';
        pls1[7].BusinessSubgroup__c = 'Welding Wire (SZW)';
        update pls1;
               
		OrgWideSettings__c setting = new OrgWideSettings__c();
        setting.Name = 'Org Wide Info';
        setting.ActivateAlternateBasicPlan__c = false;
        setting.Rawmateriallastupdatedon__c = System.today();
        insert setting;
    }
    
    @isTest static void getOpportunityLineItemTest(){
        OpportunityLineItem oppItem = [SELECT Id, OpportunityId, Quantity, DateOfDelivery__c, PricebookEntryId, TotalPrice, Product2Id, CostOfProduction__c, PriceLevel1__c, PriceLevel2__c,Opportunity.StageName,
                                        PriceLevel3__c,PriceLevel4__c,PriceLevel5__c,OrientationPrice__c,FinalPrice__c FROM OpportunityLineItem LIMIT 1];
        Test.startTest();
        List<PricingToolController.PLWrapperData> oppList=PricingToolController.getOpportunityLineItem(oppItem.id);
        System.assertEquals(1, oppList.size(), '1 records should be returned');
        List<PricingToolController.MarginWrapperData> oppMarginList = PricingToolController.getMarginPriceDetails(oppItem.id);
        system.assertEquals(1, oppMarginList.size(), '1 records should be returned');
        Test.stopTest();
    }
    
    @isTest static void saveFinalPrice(){
        OpportunityLineItem oppItem = [SELECT Id,OpportunityId,Quantity,PricebookEntryId,TotalPrice,Product2Id,CostOfProduction__c from OpportunityLineItem LIMIT 1];
        Test.startTest();
        Decimal FinalPrice = PricingToolController.saveFinalPrice(23.00, oppItem.id);
        System.assertEquals(23.00, FinalPrice, 'Final Price Should be returned');
        Test.stopTest();
    }
    
    @isTest static void getPublicGroupUsers(){
        Test.startTest();
        Boolean ismemberofGroup = PricingToolController.getPublicGroupUsers();
        System.assertEquals(true, ismemberofGroup, 'ismemberofGroup should return true');
        Test.stopTest();
    }
    
    @isTest static void getReRunProductFinder(){
    	TechnicalRequirement__c TR = [SELECT Id FROM TechnicalRequirement__c LIMIT 1];
        OpportunityLineItem oppItem= [SELECT Id, OpportunityId, Quantity, PricebookEntryId,
                                      TotalPrice, Product2Id, CostOfProduction__c, TechnicalRequirement__c 
                                      FROM OpportunityLineItem LIMIT 1 ];
        oppItem.TechnicalRequirement__c = TR.Id;
        update oppItem;
        Test.startTest();
        List<OpportunityLineItem> rerun = PricingToolController.ReRunProductFinder(oppItem.Id);
        System.assertEquals(1, rerun.size(), 'reruning the method');
        Test.stopTest();
     }
       
     @isTest static void testBulkPostCallout(){
        List<Id> oliIds = new  List<Id>();
        List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();
        FinishedGoods__c fmn = [SELECT Id, BusinessArea__c, ProductGroupBusinessArea__c, MaterialNumber__c FROM FinishedGoods__c WHERE MaterialNumber__c != '' LIMIT 1];
        fmn.BusinessArea__c = 'ZZ';
        fmn.ProductGroupBusinessArea__c = 'Welding Wire (SZW)';
        update fmn;
        Opportunity opp = [SELECT Id, AppointedDayCalculation__c FROM Opportunity LIMIT 1];
        OrgWideSettings__c orgWideSetting = OrgWideSettings__c.getValues(ConstantClass.ORG_WIDE_INFO);
        Date lastUpdateDate = orgWideSetting.Rawmateriallastupdatedon__c;
        opp.CalculationTimePoint__c = 'Monthly';
        opp.AppointedDayCalculation__c = lastUpdateDate.addMonths(1);
        update opp;
        
        for(OpportunityLineItem oppItem : [SELECT Id, FinishedGoods__r.MaterialNumber__c FROM OpportunityLineItem]){
			oppItem.FinishedGoods__c = fmn.id;
         	oliToUpdate.add(oppItem);
            oliIds.add(oppItem.Id);
        }
        if(!oliToUpdate.isEmpty())
       		update oliToUpdate;
        
        List<InvoicedOrders__c> IOs = [SELECT Id, MaterialNumber__c FROM InvoicedOrders__c];
        IOs[0].MaterialNumber__c = fmn.MaterialNumber__c;
        update IOs;
       	Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MocktestRecord());
       	String res = PricingToolController.upadateBulkCOP(oliIds);
        System.assertEquals('true', res, 'upadateBulkCOP should return true');
        Test.stopTest();
	 }
    
      @isTest static void getOpportunityLineItem1Test(){
        OpportunityLineItem oppItem = [SELECT Id, OpportunityId, Quantity, DateOfDelivery__c, PricebookEntryId, TotalPrice, Product2Id, CostOfProduction__c, PriceLevel1__c, PriceLevel2__c,Opportunity.StageName,
                                        PriceLevel3__c,PriceLevel4__c,PriceLevel5__c,OrientationPrice__c,FinalPrice__c,LastSavedFinalPriceDate__c,LastRefreshedDate__c FROM OpportunityLineItem LIMIT 1];
        oppItem.LastSavedFinalPriceDate__c = system.today();
        oppItem.LastRefreshedDate__c = system.today();
        update oppItem;
        Test.startTest();
        List<PricingToolController.PLWrapperData> oppList=PricingToolController.getOpportunityLineItem(oppItem.id);
        System.assertEquals(1, oppList.size(), '1 records should be returned');
        List<PricingToolController.MarginWrapperData> oppMarginList = PricingToolController.getMarginPriceDetails(oppItem.id);
        system.assertEquals(1, oppMarginList.size(), '1 records should be returned');
        Test.stopTest();
    }
     @isTest static void testBulkPostelseCallout(){
        Set<Id> oliIds = new  Set<Id>();
        List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();
        FinishedGoods__c fmn = [SELECT Id, MaterialNumber__c FROM FinishedGoods__c WHERE MaterialNumber__c != '' LIMIT 1];
        List<ID> OPPIDLST = new List<ID>();
        for(OpportunityLineItem oppItem : [SELECT Id, FinishedGoods__r.MaterialNumber__c,OpportunityId FROM OpportunityLineItem]){
			oppItem.FinishedGoods__c = fmn.id;
         	oliToUpdate.add(oppItem);
            oliIds.add(oppItem.Id);
            OPPIDLST.add(oppItem.OpportunityId);
        }
        List<opportunity> opplst = [SELECT Id, CalculationTimePoint__c FROM Opportunity where ID IN :OPPIDLST];
        for(Opportunity opp : opplst){
           opp.CalculationTimePoint__c = 'Quarterly';  
        }
        OrgWideSettings__c orgWideSetting = OrgWideSettings__c.getValues(ConstantClass.ORG_WIDE_INFO);
        orgWideSetting.Rawmateriallastupdatedon__c = System.today().addMonths(5);   
        opplst[0].AppointedDayCalculation__c = System.today().addMonths(1);
        update opplst;
        if(!oliToUpdate.isEmpty())
       		update oliToUpdate;
         
       	Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MocktestRecord());
       	String res = PricingToolController.bulkcallforcop(oliIds);
        System.assertEquals('true', res, 'upadateBulkCOP should return true');
        Test.stopTest();
	}
    
     @isTest static void testWithoutFmnCallout(){
        List<Id> oliIds = new List<Id>();
        List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();
        for(OpportunityLineItem oppItem : [SELECT Id, FinishedGoods__r.MaterialNumber__c,OpportunityId FROM OpportunityLineItem]){
			oppItem.FinishedGoods__c = null;
            oppItem.ProductFinderStatus__c = ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS;
         	oliToUpdate.add(oppItem);
            oliIds.add(oppItem.Id);
        }
        if(!oliToUpdate.isEmpty())
       		update oliToUpdate;
         
       	Test.startTest();
        String res = PricingToolController.upadateBulkCOP(oliIds);
        System.assertEquals('true', res, 'upadateBulkCOP should return true');
        Test.stopTest();
	}
    
    private class MocktestRecord implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request) {
            List<OpportunityLineItem> olis = [SELECT Id FROM OpportunityLineItem];
            
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('[{"salesforce_id": "'+olis[0].Id+'", "fmn": "1234","hzv": "", "price_point_information": "pp0", "alternate_basic_plan": false, "cost_of_production_internal": "1051.930018", "cost_of_production_external": "1051.930018", "fixed_cost": "235.169031", "status_code": 200, "status_message": "OK" }, { "salesforce_id": "'+olis[0].Id+'", "fmn": "1234", "hzv": "", "price_point_information": "pp1", "alternate_basic_plan": false, "cost_of_production_internal": "20.930018", "cost_of_production_external": "30.930018", "fixed_cost": "23.169031", "status_code": 200, "status_message": ""}]');
			response.setStatusCode(200);
            return response; 
        }
    }
} 