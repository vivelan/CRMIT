/****************************************************************************
* Name: DeliveryInstrPDFGenerationTest
* Author: Naina Butle
* Created Date: 22/11/2023
* Description: test class of DeliveryInstrPDFGeneration.
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
****************************************************************************/
@isTest
public class DeliveryInstrPDFGenerationTest {
    
    @TestSetup
    static void createTestData(){
        TestDataFactory.createDeliveryInstruction();
        TestDataFactory.createdocumentTemplate(1);
    }
    
    @isTest 
    static void testcreateDocumentGenerationProcessRequest(){
        Test.startTest();
         List<DeliveryInstructions__c> deliveryInst = [SELECT Id, Name, Title__c, AdditionalTitle__c, FlagMonthYearOnly__c, DateOfIssue__c, Language__c, Revision__c  FROM DeliveryInstructions__c LIMIT 1];
		 deliveryInst[0].Language__c = 'DE';
         deliveryInst[0].AdditionalTitle__c = 'AddT';
         deliveryInst[0].Revision__c = 'Rev';
         deliveryInst[0].DateOfIssue__c = system.Today();
        update deliveryInst[0];
        DeliveryInstrPDFGeneration.createDocumentGenerationProcessRequest(new List<Id>{deliveryInst[0].Id});
        Test.stopTest();
        System.assertEquals(deliveryInst[0].Language__c, 'DE' , 'Language should be DE');
    }
    
    @isTest 
    static void testcreateDocumentGenerationProcessRequestEn(){
        Test.startTest();
         List<DeliveryInstructions__c> deliveryInst = [SELECT Id, Name, Title__c, AdditionalTitle__c, FlagMonthYearOnly__c, DateOfIssue__c, Language__c, Revision__c  FROM DeliveryInstructions__c LIMIT 1];
		 deliveryInst[0].Language__c = 'EN';
         deliveryInst[0].AdditionalTitle__c = 'AddT';
         deliveryInst[0].Revision__c = 'Rev';
         deliveryInst[0].DateOfIssue__c = system.Today();
        deliveryInst[0].FlagMonthYearOnly__c = true;
        update deliveryInst[0];
        List<DocumentTemplate> documentTemplate = [SELECT id, Name, Language__c FROM DocumentTemplate LIMIT 1];
        documentTemplate[0].Language__c = 'EN';
        update documentTemplate[0];
        DeliveryInstrPDFGeneration.createDocumentGenerationProcessRequest(new List<Id>{deliveryInst[0].Id});
        Test.stopTest();
        System.assertEquals(deliveryInst[0].Language__c, 'EN' , 'Language should be EN');
    }
}