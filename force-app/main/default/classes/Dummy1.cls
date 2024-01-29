/****************************************************************************
* Name: AccountContactRelationHandlerTest
* Author: Impana Paalyamgger 
* Created Date: 27/04/2023 
* Description: Test class for Quote Trigger
*****************************************************************************/
@isTest
public class AccountContactRelationHandlerTest {
    @testSetup static void setUpData() { 
        List<User> user = TestDataFactory.createUser(1);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Manage_Customer_Portal_Access'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = user[0].Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        System.runAs(user[0]) {
            List<AccountContactRelation> accContList = new List<AccountContactRelation>();
            List<Account> act = TestDataFactory.createAccounts(1);
            act[0].SAPAccountNumber__c = '123456';
            act[0].Segment1__c = '101 Construction Equipment';
            act[0].Segment2__c = '103 Machinery';
            act[0].Segment3__c = '205 Pressure Equipement';
            update act;
            List<Contact> con = TestDataFactory.createAccountwithContact(1,2);
            con[0].Segment1__c = '417 Protection Steel';
            con[0].Segment2__c = '513 Steel and Service Center';
            con[0].Segment3__c = '612 Steel Construction';
            update con[0];
            AccountContactRelation acr = new AccountContactRelation();
            acr.IsActive = true;
            acr.Roles ='Customer Portal User';
            acr.AccountId = act[0].ID;
            acr.ContactId = con[1].ID;
            accContList.add(acr);
            AccountContactRelation acr1 = new AccountContactRelation();
            acr1.IsActive =true;
            acr1.Roles ='Decision Maker';
            acr1.AccountId = act[0].ID;
            acr1.ContactId = con[0].ID;
            AccContList.add(acr1);
            insert AccContList;
        }
    }
    @isTest static void testAccountContactRelationUpdate(){
        Test.startTest();
        List<User> userList = [SELECT Id, UserRoleId, LastName, ProfileId, Profile.Name, IsActive FROM User WHERE CompanyName='TEST' AND IsActive =TRUE LIMIT 1]; 
        List<AccountContactRelation> accContList1 = [SELECT Id,Roles,IsActive,ContactId FROM AccountContactRelation WHERE Roles='Customer Portal User' limit 1]; 
        String value = 'Decision Maker;Customer Portal User';
        system.runAs(userList[0]) {
            accContList1[0].IsActive =false;
            accContList1[0].Roles =value;
            update accContList1;
            List<AccountContactRelation> accContList2 = [SELECT Id,Roles,IsActive,ContactId FROM AccountContactRelation WHERE Roles='Decision Maker' limit 1]; 
            String value1 ='Customer Portal User';
            accContList2[0].Roles =value1;
            update accContList2;
        }
        Test.stopTest();    
        System.assertEquals(false, accContList1[0].IsActive, 'Incorrect output'); 
    }
    @isTest static void testAccountContactRelationDelete(){
        Test.startTest();
        List<User> userList = [SELECT Id, UserRoleId, LastName, ProfileId, Profile.Name, IsActive FROM User WHERE CompanyName='TEST' AND IsActive =TRUE LIMIT 1];
        System.runAs(userList[0]){
            List<AccountContactRelation> accContList1 = [SELECT Id,Roles,IsActive FROM AccountContactRelation WHERE Roles='Customer Portal User' limit 1]; 
            delete accContList1;
            List<AccountContactRelation> accContList2 = [SELECT Id,Roles,IsActive FROM AccountContactRelation WHERE Roles='Customer Portal User' limit 1]; 
            System.assertEquals(accContList2.size(), 0, 'Incorrect output');
        }
        Test.stopTest();       
    }
    
}
