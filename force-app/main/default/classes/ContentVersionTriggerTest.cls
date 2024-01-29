/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-01-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@istest
public class ContentVersionTriggerTest {
    @isTest
    static void testInsertPackingList(){
       List<Account> accountList = TestDataFactory.createAccounts(2);
        Test.startTest();
        ContentVersion contentVersionTest = new ContentVersion(
            Title = 'Test Title',
            PathOnClient = 'test Image.jpg',
            VersionData = Blob.valueOf('Test Content'),
            isMajorVersion = true,
            documenttype__c = 'Packing List',
            purchaser__c = accountList[0].id,
            consumer__c =  accountList[1].id
        );
        insert contentVersionTest;
        Set<Id> accountids = new Set<Id>();
        accountids.add(accountList[0].id);
        accountids.add(accountList[1].id);
        Test.stopTest();
        List<contentDocument> docIds = [select id from contentDocument];
        List<ContentDocumentLink> links = [select id,linkedentityId,contentdocumentid from contentdocumentlink where contentdocumentid = :docIds[0].id];
        system.AssertEquals( links.size()>0,true,'Links should be created');
    }
    
    @isTest
    static void testInsertInvoice(){
       List<Account> accountList = TestDataFactory.createAccounts(2);
        Test.startTest();
        ContentVersion contentVersionTest = new ContentVersion(
            Title = 'Test Title',
            PathOnClient = 'test Image.jpg',
            VersionData = Blob.valueOf('Test Content'),
            isMajorVersion = true,
            documenttype__c = 'Invoice',
            regulator__c = accountList[0].id
        );
        insert contentVersionTest;
        Set<Id> accountids = new Set<Id>();
        accountids.add(accountList[0].id);
        Test.stopTest();
        
        List<contentDocument> docIds = [select id from contentDocument];
        List<ContentDocumentLink> links = [select id,linkedentityId,contentdocumentid from contentdocumentlink where contentdocumentid = :docIds[0].id];
        system.AssertEquals( links.size()>0,true,'Links should be created');
       }
    @isTest
    static void testInsertOrderConfirmation(){
       List<Account> accountList = TestDataFactory.createAccounts(2);
        Test.startTest();
        ContentVersion contentVersionTest = new ContentVersion(
            Title = 'Test Title',
            PathOnClient = 'test Image.jpg',
            VersionData = Blob.valueOf('Test Content'),
            isMajorVersion = true,
            documenttype__c = 'Order Confirmation',
            purchaser__c = accountList[0].id
        );
        insert contentVersionTest;
        Set<Id> accountids = new Set<Id>();
        accountids.add(accountList[0].id);
        Test.stopTest();
        
        List<contentDocument> docIds = [select id from contentDocument];
        List<ContentDocumentLink> links = [select id,linkedentityId,contentdocumentid from contentdocumentlink where contentdocumentid = :docIds[0].id];
        system.AssertEquals( links.size()>0,true,'Links should be created');
       }
    @isTest
    static void testUpdateOrderConfirmation(){
       List<Account> accountList = TestDataFactory.createAccounts(2);
        ContentVersion contentVersionTest = new ContentVersion(
            Title = 'Test Title',
            PathOnClient = 'test Image.jpg',
            VersionData = Blob.valueOf('Test Content'),
            isMajorVersion = true,
            documenttype__c = 'Invoice',
            regulator__c = accountList[0].id
        );
        insert contentVersionTest;
        Test.startTest();
        ContentVersionTriggerHandler.rerun = false;
        ContentVersion contentVersionupdate = [select id,regulator__c from contentVersion where id =:contentVersionTest.id ];
        contentVersionupdate.regulator__c = accountList[1].id;
        update contentVersionUpdate;
        Test.stopTest();
        Set<Id> accountids = new Set<Id>();
        accountids.add(accountList[0].id);
        accountids.add(accountList[1].id);
        
        List<contentDocument> docIds = [select id from contentDocument];
        List<ContentDocumentLink> links = [select id,linkedentityId,contentdocumentid from contentdocumentlink where contentdocumentid = :docIds[0].id];
        system.AssertEquals( links.size()>0,true,'Links should be created');
        }
}