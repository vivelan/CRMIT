/****************************************************************************
* Name: OpportunityLineItemTriggerHandlerTest
* Author: Priyanka Kumari
* Created Date: 12/09/2022
* Description: Test class for OpportunityLineItemTriggerHandler class
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
****************************************************************************/
@isTest
public class OpportunityLineItemTriggerHandlerTest {

    @testSetup
    static void setUpData(){
        TestDataFactory.createOrgWideSetting();
        TestDataFactory.oppLineItemTestData();
        
    }
    @isTest static void insertOli(){
      List<OpportunityLineItem> oli = [SELECT Id, TechnicalRequirement__c, OpportunityId, PricebookEntryId, Quantity, UnitPrice, Opportunity.Pricebook2Id FROM OpportunityLineItem LIMIT 3];
      system.assertNotEquals(oli.size(), 0,'List should not be empty');
    }
}