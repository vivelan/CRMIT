@isTest
public class PrakulaDeliveryInstructionsContrTest {
	@testSetup
    static void setUpData(){
        	TestDataFactory.oppLineItemTestData();
            TestDataFactory.createOrgWideSetting();
            TestDataFactory.createPreakulaDeliveryInstruction(3);
            TestDataFactory.createPrakula(3);
            TestDataFactory.createLV(2);
    }
    
    @isTest 
    static void testfetchPrakulatest(){
        Test.startTest();
		List<OpportunityLineItem> oli = [SELECT Id, TechnicalRequirement__c, OpportunityId, PricebookEntryId,  Quantity, UnitPrice, Opportunity.Pricebook2Id FROM OpportunityLineItem LIMIT 3];
        List<Opportunity> opplist = [SELECT ID,Language__c,AccountId FROM  Opportunity WHERE id= :oli[0].OpportunityId];
        
        List<PraekulaDeliveryInstructions__c> deliveryInstructions = [SELECT Id, Praekula__c, Praekula__r.Name , Praekula__r.Account__c, Praekula__r.Account__r.Name,  Praekula__r.Language__c, DeliveryInstructions__c ,DeliveryInstructions__r.Type__c, DeliveryInstructions__r.Publisher__c, DeliveryInstructions__r.Revision__c, 
                                                         DeliveryInstructions__r.Title__c, DeliveryInstructions__r.DateOfIssue__c
                                                         FROM PraekulaDeliveryInstructions__c]; 
        String deliveryInstructionIdInput =  '';
        opplist[0].Language__c = deliveryInstructions[0].Praekula__r.Language__c;
        opplist[0].AccountId = deliveryInstructions[0].Praekula__r.Account__c;
        Update opplist;
        for(integer i = 0; i < 3; i++) {
            deliveryInstructionIdInput += String.valueOf(deliveryInstructions[0].DeliveryInstructions__c);
            if (i < deliveryInstructions.size() - 1) {
                deliveryInstructionIdInput += ',';
            }
        }
        String deliveryInsType = deliveryInstructions[0].DeliveryInstructions__r.Type__c;
        String deliveryInsPublisher = deliveryInstructions[0].DeliveryInstructions__r.Publisher__c; 
        String deliveryInsRevision = deliveryInstructions[0].DeliveryInstructions__r.Revision__c;
        String deliveryInsTitle = deliveryInstructions[0].DeliveryInstructions__r.Title__c;
        String deliveryInsDateOfIssue = String.valueOf(deliveryInstructions[0].DeliveryInstructions__r.DateOfIssue__c);
        String oliID = oli[0].Id;
        List<PraekulaDeliveryInstructions__c> prd = PrakulaDeliveryInstructionsController.getDeliveryInstructionId(deliveryInsType, deliveryInsPublisher, deliveryInsRevision, deliveryInsTitle, deliveryInsDateOfIssue, oliID);
        Test.stopTest();
        System.assertEquals(deliveryInstructions[0].ID, prd[0].ID , 'Fetch Prakula');
    }
    
    @isTest 
    static void testsendprakulaIds(){
        Test.startTest();
        List<OpportunityLineItem> oli = [SELECT Id, TechnicalRequirement__c, OpportunityId, CustomerSteelGrade__c,  Quantity, UnitPrice, DimensionATo__c FROM OpportunityLineItem LIMIT 3];
        oli[0].CustomerSteelGrade__c = '3';
        oli[0].DimensionATo__c = 3;
        update  oli[0];
        List<Opportunity> opplist = [SELECT ID, Language__c, AccountId, OpportunityType__c FROM  Opportunity WHERE id= :oli[0].OpportunityId];
        opplist[0].OpportunityType__c = 'Mass Inquiry';
        update opplist[0];
        Praekula__c Prakula = [Select Id, Language__c, Account__c FROM Praekula__c Limit 1]; 
        PrakulaDeliveryInstructionsController.sendprakulaIds(Prakula.Id, oli[0].Id);
        Test.stopTest();
        System.assertEquals(opplist[0].OpportunityType__c , 'Mass Inquiry' , 'opportunity type should be Mass Inquiry');
    }
    
     @isTest 
    static void testsendprakulaIds1(){
        Test.startTest();
        Praekula__c Prakula = [Select Id, Language__c, Account__c FROM Praekula__c Limit 1]; 
        List<OpportunityLineItem> oli = [SELECT Id, TechnicalRequirement__c, OpportunityId, CustomerSteelGrade__c,  Quantity, UnitPrice, DimensionATo__c FROM OpportunityLineItem LIMIT 3];
        oli[0].CustomerSteelGrade__c = '3';
        oli[0].DimensionATo__c = 3;
        oli[0].Prakula__c = Prakula.Id;
        update  oli[0];
         List<Opportunity> opplist = [SELECT ID, Language__c, AccountId, OpportunityType__c FROM  Opportunity WHERE id= :oli[0].OpportunityId];
        opplist[0].OpportunityType__c = 'Standard Inquiry';
        update opplist[0];
        List<LVPostion__c> lvlst = PrakulaDeliveryInstructionsController.sendprakulaIds(Prakula.Id, oli[0].Id);
        List<LVPostion__c> lvlstactual = new List<LVPostion__c>();
        Test.stopTest();
        System.assertEquals(lvlstactual , lvlst , 'Search Prakula');
    }
    @isTest 
    static void testsendprakulaIds2(){
        Test.startTest();
        Praekula__c Prakula = [Select Id, Language__c, Account__c FROM Praekula__c Limit 1]; 
        List<OpportunityLineItem> oli = [SELECT Id, TechnicalRequirement__c, OpportunityId, CustomerSteelGrade__c,  Quantity, UnitPrice, DimensionATo__c FROM OpportunityLineItem LIMIT 3];
        oli[0].CustomerSteelGrade__c = '3';
        oli[0].DimensionATo__c = null;
        oli[0].Prakula__c = Prakula.Id;
        update  oli[0];
         List<Opportunity> opplist = [SELECT ID, Language__c, AccountId, OpportunityType__c FROM  Opportunity WHERE id= :oli[0].OpportunityId];
        opplist[0].OpportunityType__c = 'Standard Inquiry';
        update opplist[0];
        List<LVPostion__c> lvlst = PrakulaDeliveryInstructionsController.sendprakulaIds(Prakula.Id, oli[0].Id);
        List<LVPostion__c> lvlstactual = new List<LVPostion__c>();
        Test.stopTest();
        System.assertEquals(lvlstactual , lvlst , 'Search Prakula');
    }
}