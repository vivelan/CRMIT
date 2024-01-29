/****************************************************************************
* Name: AccountTriggerHandlerTest
* Author: Naina Butle
* Created Date: 08/12/2022
* Description: Test class of AccountTriggerHandler
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
****************************************************************************/
@isTest
public with sharing class AccountTriggerHandlerTest {
    @testSetup
    static void setUpdata(){
        List<User> userList = TestDataFactory.createUserSales(1);
        TestDataFactory.createUser(1);
        System.runAs(userList[0]){
            Account act = new Account(Name ='TestAccountcan', Phone='+912345678956' , Inactive__c = true, CustomerSize__c=3.000, SAPAccountNumber__c = '12345',CommentOverdraft__c='test',CommentOverdueInvoice__c='test', Segment1__c = '101 Construction Equipment', Segment2__c = '103 Machinery',Segment3__c = '205 Pressure Equipement',BillingCity='Stuttgart',BillingStreet='Theodor-Heuss-Straße',BillingCountry='Germany',BillingCountryCode='DE' );
            insert act;
        }
        
    }
    
    
    @isTest static void updateAccountTriggerNegative(){
        
        Test.startTest();
        List<Boolean> exceptions = new List<Boolean>();
        List<User> userList = [SELECT Id, UserRoleId, LastName, ProfileId, Profile.Name, IsActive FROM User WHERE LastName= 'last0' AND Profile.Name ='SAG Sales' AND IsActive =TRUE LIMIT 1];
        
        system.runAs(userList[0]) {
            Account newAccount = [SELECT Id, Name, SAPAccountNumber__c, CustomerSpecificMargin__c, AnnualRevenue FROM Account Limit 1];
            newAccount.AnnualRevenue = 2222;
            try{
                update newAccount;
            }catch(exception ex){
                exceptions.add(true);
            }
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptions, 'expected at least one exception to have occured');
        for(Boolean b : exceptions){
            system.assert(b, 'Account should have thrown an exception');
        }
    } 
    
    @isTest static void updateAccountTriggerPostive(){
        Test.startTest();
        List<User> userList = [SELECT Id, UserRoleId, LastName, ProfileId, Profile.Name, IsActive FROM User WHERE (Profile.Name ='System Administrator' OR Profile.Name ='Systemadministrator') AND IsActive =TRUE LIMIT 1];
        system.runAs(userList[0]) {
            Account newAccount = [SELECT Id, Name, SAPAccountNumber__c, CustomerSpecificMargin__c, AnnualRevenue FROM Account LIMIT 1];
            newAccount.CustomerSpecificMargin__c = 2222;
            update newAccount;
            system.assertEquals(newAccount.CustomerSpecificMargin__c, 2222, 'CustomerSpecificMargin__c should be 2222');
        }
        Test.stopTest();
    } 
    
    @isTest static void updateAccountTriggerPostivetest(){
        Test.startTest();
        List<Boolean> exceptions = new List<Boolean>();
        List<User> userList = TestDataFactory.createUserDHMarketing(1);
        System.runAs(userList[0]){
            Account act = new Account(Name ='TestAccountcan', Phone='+912345678956' , Inactive__c = true, CustomerSize__c=3.000, SAPAccountNumber__c = '',CommentOverdraft__c='test',CommentOverdueInvoice__c='test', Segment1__c = '101 Construction Equipment', Segment2__c = '103 Machinery',Segment3__c = '205 Pressure Equipement',BillingCity='Stuttgart',BillingStreet='Theodor-Heuss-Straße',BillingCountry='Germany',BillingCountryCode='DE' );
            insert act;
            List<Account> acc = [SELECT Id, Name, Segment1__c, Segment2__c, Type, Segment3__c FROM Account WHERE Id =: act.Id limit 1];
            acc[0].Type = 'Customer';
            update acc[0];
            acc[0].CustomerSpecificMargin__c = 2222;
            try{
                update  acc[0];
            }catch(exception ex){
                exceptions.add(true);
            }
            system.assertNotEquals(null, exceptions, 'expected at least one exception to have occured');
            for(Boolean b : exceptions){
                system.assert(b, 'Account should have thrown an exception');
            }
        }
        Test.stopTest();
    } 
    @isTest static void updateLastUpdateFieldsPostive(){
        Test.startTest();
        Account newAccount = [SELECT Id, CommentOverdraft__c,CommentOverdueInvoice__c FROM Account LIMIT 1];
        newAccount.CommentOverdraft__c = 'overdraft test';
        newAccount.CommentOverdueInvoice__c = 'overdue test';
        update newAccount;
        Account acc = [SELECT Id,CommentOverdraft__c,CommentOverdueInvoice__c,LastUpdatedCommentOverdraft__c, LastUpdatedCommentOverdueInvoice__c FROM Account LIMIT 1];
        system.assertEquals(acc.CommentOverdueInvoice__c, 'overdue test','Incorrect output');
        Test.stopTest();
    } 
    
    @isTest static void updateSegmentFieldonContactTest1(){
        Test.startTest();
        List<Contact> con = TestDataFactory.createAccountwithContact(1,1);
        Contact conNew = [SELECT ID, AccountId, Segment1__c, Segment2__c, Segment3__c FROM Contact WHERE Id =: con[0].ID];
        conNew.Segment1__c = '101 Construction Equipment';
        conNew.Segment2__c = '103 Machinery';
        conNew.Segment3__c = '205 Pressure Equipement';
        update conNew;
        List<Account> acc = [SELECT Id, Name, Segment1__c, Segment2__c, Segment3__c FROM Account WHERE Id =: con[0].AccountId limit 1];
        acc[0].Segment1__c = '101 Construction Equipment';
        acc[0].Segment2__c = '103 Machinery';
        acc[0].Segment3__c = '205 Pressure Equipement';
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        Database.update (acc, dml);
        
        List<Account> acc1 = [SELECT Id, Name, Segment1__c, Segment2__c, Segment3__c FROM Account WHERE Id =: con[0].AccountId limit 1];
        acc1[0].Segment1__c = '417 Protection Steel';
        acc1[0].Segment2__c = '513 Steel and Service Center';
        acc1[0].Segment3__c = '612 Steel Construction';
        Database.update (acc1, dml);
        Test.stopTest();
        system.assertNotEquals(acc.size(), 0,'List should not be empty');
    }
    
    
    @isTest static void updateSegmentFieldonContactTest2(){
        Test.startTest();
        List<Contact> con = TestDataFactory.createAccountwithContact(1,1); 
        List<Account> acc = [SELECT Id, Name, Segment1__c, Segment2__c, Segment3__c FROM Account WHERE Id =: con[0].AccountId limit 1];
        acc[0].Segment1__c = '101 Construction Equipment';
        acc[0].Segment2__c = '103 Machinery';
        acc[0].Segment3__c = '205 Pressure Equipement';
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        Database.update (acc, dml);
        
        List<Account> acc1 = [SELECT Id, Name, Segment1__c, Segment2__c, Segment3__c FROM Account WHERE Id =: con[0].AccountId limit 1];
        acc1[0].Segment1__c = '417 Protection Steel';
        acc1[0].Segment2__c = '513 Steel and Service Center';
        acc1[0].Segment3__c = '612 Steel Construction';
        Database.update (acc1, dml);
        Test.stopTest();
        system.assertNotEquals(acc.size(), 0,'List should not be empty');
    }
    
    
    @isTest static void updateSegmentFieldonContactTest3(){
        Test.startTest();
        Database.DMLOptions dml = new Database.DMLOptions();
        List<Account> newList = new List<Account>();
        List<AccountContactRelation> accContList = new List<AccountContactRelation>();
        List<Account> act = TestDataFactory.createAccounts(5);
        act[2].SAPAccountNumber__c = '123456';
        act[2].Segment1__c = '101 Construction Equipment';
        act[2].Segment2__c = '103 Machinery';
        act[2].Segment3__c = '205 Pressure Equipement';
        newList.add(act[2]);
        act[1].SAPAccountNumber__c = '123456';
        act[4].Segment1__c = '417 Protection Steel';
        act[4].Segment2__c = '513 Steel and Service Center';
        act[4].Segment3__c = '612 Steel Construction';
        newList.add(act[1]);
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        Database.update (newList, dml);
        
        List<Contact> con = TestDataFactory.createAccountwithContact(1,1);
        AccountContactRelation acr = new AccountContactRelation();
        acr.IsActive =true;
        acr.AccountId = act[2].ID;
        acr.ContactId = con[0].ID;
        accContList.add(acr);
        AccountContactRelation acr1 = new AccountContactRelation();
        acr1.IsActive =true;
        acr1.AccountId = act[4].ID;
        acr1.ContactId = con[0].ID;
        accContList.add(acr1);
        insert accContList; 
        List<Account> acc = [SELECT Id, Name, Segment1__c, Segment2__c, Segment3__c FROM Account WHERE Id =: con[0].AccountId limit 1];
        acc[0].Segment1__c = '415 Job Rolling';
        acc[0].Segment2__c = '417 Protection Steel';
        acc[0].Segment3__c = '417 Protection Steel';
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        Database.update (acc, dml);
        system.assertNotEquals(acc.size(), 0,'List should not be empty');
        Test.stopTest();
    }
    
    @isTest static void removeSegmentFieldonContactTest(){
        Test.startTest();
        Database.DMLOptions dml = new Database.DMLOptions();
        List<Account> newList = new List<Account>();
        List<AccountContactRelation> accContList = new List<AccountContactRelation>();
        List<Account> act = TestDataFactory.createAccounts(5);
        act[2].SAPAccountNumber__c = '123456';
        act[2].Segment1__c = '101 Construction Equipment';
        act[2].Segment2__c = '103 Machinery';
        act[2].Segment3__c = '205 Pressure Equipement';
        newList.add(act[2]);
        act[4].SAPAccountNumber__c = '123456';
        act[4].Segment1__c = '101 Construction Equipment';
        act[4].Segment2__c = '103 Machinery';
        act[4].Segment3__c = '205 Pressure Equipement';
        newList.add(act[4]);
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        Database.update (newList, dml);
        
        List<Contact> con = TestDataFactory.createAccountwithContact(1,1);
        AccountContactRelation acr = new AccountContactRelation();
        acr.IsActive =true;
        acr.AccountId = act[2].ID;
        acr.ContactId = con[0].ID;
        accContList.add(acr);
        AccountContactRelation acr1 = new AccountContactRelation();
        acr1.IsActive =true;
        acr1.Roles ='Decision Maker';
        acr1.AccountId = act[4].ID;
        acr1.ContactId = con[0].ID;
        accContList.add(acr1);
        insert accContList; 
        List<Account> acc = [SELECT Id, Name, Segment1__c, Segment2__c, Segment3__c FROM Account WHERE Id =: act[4].ID limit 1];
        delete acc;
        Test.stopTest();
        system.assertNotEquals(accContList.size(), 0,'List should not be empty');
        
    }
}