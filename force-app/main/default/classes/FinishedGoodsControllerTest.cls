@isTest
public class FinishedGoodsControllerTest {
	@testSetup
    static void setUpData(){
            TestDataFactory.oppLineItemTestData();
            TestDataFactory.createOrgWideSetting();
            TestDataFactory.createFMN(2);
    }
    @isTest 
    static void testfetchPrakulatest(){
        Test.startTest();
        List<OpportunityLineItem> oli = [SELECT Id, TechnicalRequirement__c, OpportunityId, PricebookEntryId,  Quantity, UnitPrice, Opportunity.Pricebook2Id FROM OpportunityLineItem LIMIT 3];
        List<FinishedGoods__c> fmn = [SELECT Id, SteelGradeLookup__c , Product__c , Name , DimensionA__c , DimensionB__c  FROM  FinishedGoods__c WHERE DimensionA__c = 12];
        String name = fmn[0].Name;
        String product = fmn[0].Product__c; 
        String steelgrade = fmn[0].SteelGradeLookup__c;
        Integer dimA = 12;
        Integer dimB = 12;
        String oliID = oli[0].Id;
        FinishedGoodsController.getFinishedGoods(name, product, steelgrade, dimA, dimB, oliID);
        Test.stopTest();
        System.assertEquals(fmn[0].DimensionA__c,12, 'Fetch Dimension A');
    }
}