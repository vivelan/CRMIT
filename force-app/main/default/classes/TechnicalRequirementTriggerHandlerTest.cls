/****************************************************************************
* Name: TechnicalRequirementTriggerHandlerTest
* Author: Priyanka Kumari
* Created Date: 30/11/2022
* Description: Test class for TechnicalRequirementTriggerHandler
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
****************************************************************************/
@isTest
public class TechnicalRequirementTriggerHandlerTest {
    
    @testSetup
    static void setUpData(){
        List<Account> acc = TestDataFactory.createAccountsWithOpps(1, 1);
        OrgWideSettings__c setting = new OrgWideSettings__c();
        setting.Name = 'Org Wide Info';
        setting.ActivateAlternateBasicPlan__c = false;
        insert setting;
    }   
    
    @isTest
    static void updateTechReqPositive(){
        List<Opportunity> op = [SELECT id, Language__c, AccountId FROM Opportunity LIMIT 1];
        op[0].Language__c = 'DE';
        update op;
        TechnicalRequirement__c tr = New TechnicalRequirement__c();
        tr.Opportunity__c = op[0].id;
        tr.Account__c = op[0].AccountId;
        tr.TextForSelectionQuality__c = 'Not in product portfolio';
        Test.startTest();        
        insert tr;
        List<TechnicalRequirement__c> techReq = [SELECT id, TechnicalOffer__c, TextForSelectionQuality__c,LANGUAGE__C FROM TechnicalRequirement__c LIMIT 1];
        system.assertEquals(techReq[0].TechnicalOffer__c, 'Wir bedauern Ihnen mitteilen zu müssen, dass wir diese Güte nicht in unserem Lieferprogramm führen.' , 'Wir bedauern Ihnen mitteilen zu müssen, dass wir diese Güte nicht in unserem Lieferprogramm führen.');
       	Test.stopTest();
    }
    @isTest
    static void updateTechReqNegative(){
        List<Opportunity> op = [SELECT id, Language__c, AccountId FROM Opportunity LIMIT 1];
        TechnicalRequirement__c tr = New TechnicalRequirement__c();
        tr.Opportunity__c = op[0].id;
        tr.Account__c = op[0].AccountId;
        tr.TextForSelectionQuality__c = 'Not in product portfolio';
        Test.startTest();
        op[0].Language__c = 'FR';
        update op;
        insert tr;
        List<TechnicalRequirement__c> techReq = [SELECT id, TechnicalOffer__c, TextForSelectionQuality__c FROM TechnicalRequirement__c LIMIT 1];
        techReq[0].TextForSelectionQuality__c = 'Acceptance of Spec.';
        update techReq;
        system.assertNotEquals(techReq[0].TechnicalOffer__c, 'Wir bedauern Ihnen mitteilen zu müssen, dass wir diese Güte nicht in unserem Lieferprogramm führen.' , 'Technical offer value should be - "Nous regrettons de vous informer que cette type dacierx nest pas dans notre gamme de produits.');
        Test.stopTest();
    }
    @isTest
    static void deleteOLITest(){
        OpportunityLineItem oli = TestDataFactory.oppLineItemTestData();
        
        TechnicalRequirement__c tr = [SELECT id, Active__c FROM TechnicalRequirement__c LIMIT 1];
        String trId=tr.id;
        Test.startTest();
        tr.Active__c=false;
        update tr;
        List<OpportunityLineItem> oliList = [SELECT id FROM OpportunityLineItem where TechnicalRequirement__c= :trId];
        system.assertEquals(oliList.size(),0, 'Incorrect output');
        Test.stopTest();
    }
    
    
    @isTest
    static void testCloneTR(){
        List<Opportunity> op = [SELECT id, Language__c, AccountId FROM Opportunity LIMIT 1];
        TechnicalRequirement__c tr = New TechnicalRequirement__c();
        tr.Opportunity__c = op[0].id;
        tr.Account__c = op[0].AccountId;
        tr.TextForSelectionQuality__c = 'Not in product portfolio';
        tr.TechnicalOffer__c = 'Testing';
        tr.Quantity__c =2;
        insert tr;
        Id trid=[Select Id from TechnicalRequirement__c where id=:tr.Id].Id;
        System.debug('Inside CloneTest' +trid);
        List<Id> trList=new List<id>();
        trList.add(trid);
        Test.startTest();
        TechnicalRequirementHelper.CloneTechnicalRequirement(trList);
        Id tridnew=[Select Id from TechnicalRequirement__c order by createdDate desc Limit 1].Id;
        system.assertEquals(tr.Quantity__c,2,'Incorrect output');
        Test.stopTest();
    }
    
}