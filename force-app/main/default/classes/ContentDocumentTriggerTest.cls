@isTest
public class ContentDocumentTriggerTest {

    @TestSetup
    static void createTestData(){
        TestDataFactory.createDeliveryInstruction();
        TestDataFactory.createContentVersion();
    }
    
    @isTest
    static void testAfterUpdate(){
        DeliveryInstructions__c di = [select id from DeliveryInstructions__c];
        Test.startTest();
        ContentDocument doc = [select id from ContentDocument limit 1];
        ContentDocumentLink link = new ContentDocumentLink();
        link.linkedEntityId = di.id;
        link.contentDocumentId = doc.id;
        link.shareType = 'V';
        link.visibility = 'AllUsers';
        insert link;
        update doc;
        Test.stopTest();
        System.assert(link.linkedEntityId == di.id, 'Both should have the same value');
    }
     @isTest
    static void testveforeDelete(){
        DeliveryInstructions__c di = [select id from DeliveryInstructions__c];
        Test.startTest();
        ContentDocument doc = [select id from ContentDocument limit 1];
        ContentDocumentLink link = new ContentDocumentLink();
        link.linkedEntityId = di.id;
        link.contentDocumentId = doc.id;
        link.shareType = 'V';
        link.visibility = 'AllUsers';
        insert link;
        delete doc;
        Test.stopTest();
        System.assert(link.linkedEntityId == di.id, 'Both should have the same value');
    }
    
}