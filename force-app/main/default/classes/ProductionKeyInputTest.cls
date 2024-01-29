/****************************************************************************
* Name: ProductionKeyInputTest
* Author: Priyanka Kumari
* Created Date: 11/12/2022
* Description: Test class for ProductionKeyInput class
*****************************************************************************/
@isTest
public class ProductionKeyInputTest {

    @testSetup
    static void setUpData(){
       TestDataFactory.createTR(1);
    }	

    @isTest
    static void callPositionNegative(){
       
        List<Object> ob = new List<Object>();
        TechnicalRequirement__c t = [SELECT Id FROM TechnicalRequirement__c LIMIT 1]; 
        List<Map<String, String>> pfv = new List<Map<String, String>>();
        Map<String, String> p =  new Map<String, String>();
        p.put('Target Product (St.1)', '1');
        p.put('Heat Treatment (St.29+30)', '17');
        pfv.add(p);
        Test.startTest();
        ob = ProductionKeyInput.getPosition(t.ID);
        String saveResult = ProductionKeyInput.saveProductionKey(pfv, t.Id);
        system.assertNotEquals(saveResult, 'false' , 'Value should not be false');
        Test.stopTest();
	}

 	@isTest
    static void callPositionPositive(){
    	List<Object> ob = new List<Object>();
        TechnicalRequirement__c tr = [SELECT Id , Opportunity__c, RecordTypeId FROM TechnicalRequirement__c LIMIT 1 ];
        List<Opportunity> opplst = [SELECT Id, StageName, RecordTypeId, PriceBook2Id FROM Opportunity WHERE Id =: tr.Opportunity__c LIMIT 1 ]; //TestDataFactory.createOpps(1);
        opplst[0].RecordTypeId = ConstantClass.OPPORTUNITY_PI_RECORDTYPE;
        update opplst;
        tr.RecordTypeId = ConstantClass.TRLIGHT_RECORDTYPE;
        update tr;
        
        TechnicalRequirement__c t = [SELECT Id FROM TechnicalRequirement__c LIMIT 1]; 
        List<Map<String, String>> pfv = new List<Map<String, String>>();
        Map<String, String> p =  new Map<String, String>();
        p.put('TargetProduct', 'D');
        p.put('HeatTreatment', 'IE');
        pfv.add(p);
        Test.startTest();
        Boolean profile = ProductionKeyInput.getProfile();
        ob = ProductionKeyInput.getPosition(tr.Id);
        String saveResult = ProductionKeyInput.saveProductionKey(pfv, t.Id);
        system.assertEquals(saveResult, 'true' , 'Value should be true');
        system.assertEquals(true, profile , 'Value should be true');
        Test.stopTest();
    }
    @isTest
    static void userDifferentLanguage(){
        String userProfile = System.Label.SystemAdministratorProfile;
    	User u = new User( 
         ProfileId = [SELECT Id FROM Profile WHERE Name =: userProfile].Id,
         LastName = 'last',
         Email = 'test@test.com',
         Username = 'test@test.com' + System.currentTimeMillis(),
         CompanyName = 'TEST',
         Title = 'title',
         Alias = 'alias',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'DE',
         LocaleSidKey = 'DE');
        
        System.runAs(u) {
            List<Object> ob = new List<Object>();
        TechnicalRequirement__c tr = [SELECT Id , Opportunity__c, RecordTypeId FROM TechnicalRequirement__c LIMIT 1 ];
        List<Opportunity> opplst = [SELECT Id, StageName, RecordTypeId, PriceBook2Id FROM Opportunity WHERE Id =: tr.Opportunity__c LIMIT 1 ]; //TestDataFactory.createOpps(1);
        opplst[0].RecordTypeId = ConstantClass.OPPORTUNITY_PI_RECORDTYPE;
        update opplst;
        tr.RecordTypeId = ConstantClass.TRLIGHT_RECORDTYPE;
        update tr;
        
        TechnicalRequirement__c t = [SELECT Id FROM TechnicalRequirement__c LIMIT 1]; 
        List<Map<String, String>> pfv = new List<Map<String, String>>();
        Map<String, String> p =  new Map<String, String>();
        p.put('HeatTreatment', 'WI - Stab - Walznormalisieren und induktiv Vergüten');
        pfv.add(p);
        Test.startTest();
        Boolean profile = ProductionKeyInput.getProfile();
        ob = ProductionKeyInput.getPosition(tr.Id);
        String saveResult = ProductionKeyInput.saveProductionKey(pfv, t.Id);
        system.assertEquals(saveResult, 'true' , 'Value should be true');
        system.assertEquals(true, profile , 'Value should be true');
        Test.stopTest();
        }
    }
}
