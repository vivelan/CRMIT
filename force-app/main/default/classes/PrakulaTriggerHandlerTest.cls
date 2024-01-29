/****************************************************************************
* Name: PrakulaTriggerHandlerTest
* Author: Harshitha Udaykumar
* Created Date: 13/09/2023
* Description: Test class of PrakulaTriggerHandler
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
****************************************************************************/
@isTest
public class PrakulaTriggerHandlerTest {
    @testSetup
    static void setUpdata(){
        List<User> userList = TestDataFactory.createUser(4);
        system.runAs(userList[0]) {
            List<Account> acc = TestDataFactory.createAccounts(1);
            List<Praekula__c> prakulalst = TestDataFactory.createPrakula(1);
            prakulalst[0].Account__c = acc[0].id;
            Update prakulalst;
        }
    }
    @isTest static void testInsertPrakula(){
        Test.startTest();
        List<Account> acclst = [SELECT Id FROM Account WHERE CustomerSize__c = 3.00];
        List<User> userList = [SELECT Id FROM User WHERE CompanyName = 'TEST'];
        List<AccountTeamMember> members = new list<AccountTeamMember>();
        members.add(new AccountTeamMember(AccountId = acclst[0].id, ChannelOfDistribution__c = '11', TeamMemberRole = ConstantClass.SALESREPRESENTIVE, UserId = userList[0].Id));
        members.add(new AccountTeamMember(AccountId = acclst[0].id, ChannelOfDistribution__c = '11', TeamMemberRole = ConstantClass.ACCOUNTMANAGER, UserId = userList[1].Id));
        members.add(new AccountTeamMember(AccountId = acclst[0].id, ChannelOfDistribution__c = '11', TeamMemberRole = ConstantClass.QUALITYREP, UserId = userList[2].Id));
        members.add(New AccountTeamMember(AccountId = acclst[0].id, ChannelOfDistribution__c = '11', TeamMemberRole = ConstantClass.QWACCOUNTMANAGER, UserId = userList[3].Id));
        insert members;
        List<Praekula__c> praekulalst = [SELECT Id,Language__c, Account__c,QualityManager__c, QualityRepresentative__c, SalesRepresentative__c, ProductManager__c  FROM Praekula__c WHERE Language__c ='EN'];
        praekulalst[0].Language__c = 'DE';
        Update praekulalst;
        Test.stopTest();
        system.assertEquals( praekulalst[0].Language__c, 'DE', 'Language__c should be English');
        
    }
    
    //US-7210   
    @isTest static Void testUpdatePrakula(){
        Test.startTest();
        List<Praekula__c> praekulalst = [SELECT Id, Language__c,TextForSelectionSales__c,TextForSelectionQuality__c FROM Praekula__c WHERE Language__c ='EN'];
        praekulalst[0].TextForSelectionSales__c = 'Minimum order quantity (t)';
        praekulalst[0].TextForSelectionQuality__c = 'Not in product portfolio';
        Update praekulalst;
        Test.stopTest();
        system.assertEquals( praekulalst[0].TextForSelectionSales__c, 'Minimum order quantity (t)', 'TextForSelectionSales__c should be Minimum order quantity (t)');
    }
    
    @isTest static Void testUpdatePrakula2(){
        Test.startTest();
        List<Praekula__c> praekulalst = [SELECT Id, Language__c,TextForSelectionSales__c,TextForSelectionQuality__c,TechnicalRemarkSales__c FROM Praekula__c WHERE Language__c ='EN'];
        praekulalst[0].Language__c = 'DE';
        praekulalst[0].TextForSelectionSales__c = 'Minimum order quantity (t)';
        praekulalst[0].TechnicalRemarkSales__c = 'The minimum order quantity per item is 150 metricton.';
        praekulalst[0].TextForSelectionQuality__c = 'Not in product portfolio';
        praekulalst[0].TechnicalRemarkQualityDepartment__c ='We offer in accordance with the statement from Saarstahl to your specification.';
        Update praekulalst;
        praekulalst[0].TextForSelectionSales__c = null;
        praekulalst[0].TextForSelectionQuality__c = null;
        update praekulalst;
        Test.stopTest();
        system.assertEquals( praekulalst[0].TextForSelectionSales__c, null, 'TextForSelectionSales__c should be null');
    }
    
    @isTest static Void testUpdatePrakula3(){
        Test.startTest();
        List<Praekula__c> praekulalst = [SELECT Id, Language__c,TextForSelectionSales__c,TextForSelectionQuality__c,TechnicalRemarkSales__c FROM Praekula__c WHERE Language__c ='EN'];
        praekulalst[0].Language__c = 'DE';
        praekulalst[0].TextForSelectionSales__c = 'Minimum order quantity (t)';
        praekulalst[0].TextForSelectionQuality__c = 'Not in product portfolio';
        Update praekulalst;
        praekulalst[0].TextForSelectionSales__c = 'Batch size';
        praekulalst[0].TextForSelectionQuality__c = 'Acceptance of Spec.';
        update praekulalst;
        Test.stopTest();
        system.assertEquals( praekulalst[0].TextForSelectionSales__c, 'Batch size', 'TextForSelectionSales__c should be Batch size');
    }
}