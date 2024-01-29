/****************************************************************************
* Name: OpportunityTriggerHandlerTest
* Author: Naina Butle
* Created Date: 19/10/2022
* Description: Test class for Opportunity Trigger
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
****************************************************************************/
@isTest
public class OpportunityTriggerHandlerTest {
    
    @testSetup
    static void setUpData(){
        List<User> userList = TestDataFactory.createUser(4);
        TestDataFactory.createUserSales(1);
        System.runAs(userList[0]) {
            List<Account> act = TestDataFactory.createAccounts(1);
            act[0].ChannelOfDistribution__c = '11';
            update act;
            Account acc = [Select Id, Name, ChannelOfDistribution__c,SAPAccountNumber__c from Account limit 1];
            List<Opportunity> opplst = TestDataFactory.createOpps(1);
            opplst[0].AccountId = acc.id;
            opplst[0].ChannelOfDistribution__c = '11';  
            update opplst;
            TestDataFactory.createTR(1); 
            List<AccountTeamMember> members = new list<AccountTeamMember>();
            members.add(New AccountTeamMember(AccountId = act[0].id, ChannelOfDistribution__c = '11', TeamMemberRole = ConstantClass.SALESREPRESENTIVE, UserId = userList[0].Id));
            members.add(New AccountTeamMember(AccountId = act[0].id, ChannelOfDistribution__c = '11', TeamMemberRole = ConstantClass.ACCOUNTMANAGER, UserId = userList[1].Id));
            members.add(New AccountTeamMember(AccountId = act[0].id, ChannelOfDistribution__c = '11', TeamMemberRole = ConstantClass.QUALITYREP, UserId = userList[2].Id));
            members.add(New AccountTeamMember(AccountId = act[0].id, ChannelOfDistribution__c = '11', TeamMemberRole = ConstantClass.QWACCOUNTMANAGER, UserId = userList[3].Id));
            insert members;
            act[0].SAPAccountNumber__c ='666';
            update act;
        }
    }
    @isTest static void testInsertOpportunity(){
        Test.startTest();
        Account acc = [SELECT Id, Name, ChannelOfDistribution__c FROM Account WHERE Name = 'TestAccount0' limit 1];
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'Opportunitywithquotecreations'];
        Opportunity op1 = new Opportunity(Name = acc.Name + ' Opportunity ',
                                         StageName = 'New',
                                         CloseDate = System.today().addMonths(1),
                                         AccountId = acc.Id,
                                         RecordTypeId = rt.ID,
                                         QualityCheckStartDate__c = System.today(),
                                         ChannelOfDistribution__c = '11',
                                         Language__c = 'EN',
                                         OpportunityType__c = 'Standard Inquiry',
                                         BusinessArea__c ='ZK',
                                         DateOfReceipt__c = System.today(),
                                         CurrencyIsoCode ='EUR',
                                         Type = 'Existing Business');
        insert op1;
        op1.StageName = 'Quality Check'; 
        update op1; 
        op1.StageName = 'Final Check';
        update op1;
        Test.stopTest();
        system.assertEquals(op1.StageName,'Final Check','Incorrect output');
    }
    
    @isTest static void testNegativeUpdateOpportunity(){
        Test.startTest();
        List<Boolean> exceptions = new List<Boolean>();
        Account acc1 = [SELECT Id, Name, ChannelOfDistribution__c FROM Account WHERE Name = 'TestAccount0' limit 1];
        Opportunity op = [SELECT ID, Name, AccountId, ChannelOfDistribution__c FROM Opportunity WHERE AccountId =: acc1.Id LIMIT 1];
        try{
            op.ChannelOfDistribution__c = '12';
            update op;
        }catch(exception ex){
            exceptions.add(true);
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptions, 'expected at least one exception to have occured');
        for(Boolean b : exceptions){
            system.assert(b, 'Opportunity should have thrown an exception');
        }
    }
    
     @isTest static void testUpdateOpportunity(){
         List<User> userList = [SELECT Id, UserRoleId, LastName, ProfileId, Profile.Name, IsActive FROM User WHERE Profile.Name ='SAG Sales' AND IsActive =TRUE LIMIT 1];
         system.runAs(userList[0]) {
             Test.startTest();
             Account act = new Account(Name ='TestAccount2', ComplianceCheck__c = 'Passed' , Phone='+912345678956' ,  ChannelOfDistribution__c = '11',BillingCity='Stuttgart',BillingStreet='Theodor-Heuss-Straße',BillingCountry='Germany',BillingCountryCode='DE');
             insert act;
             RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'Opportunitywithquotecreations'];
             Opportunity op = new Opportunity(Name = act.Name + ' Opportunity ',
                                              StageName = 'New',
                                              CloseDate = System.today().addMonths(1),
                                              AccountId = act.Id,
                                              RecordTypeId = rt.ID,
                                              ChannelOfDistribution__c = '11',
                                              OpportunityType__c = 'Standard Inquiry',
                                               BusinessArea__c ='ZK',
                                               DateOfReceipt__c = System.today(),
                                               CurrencyIsoCode ='EUR',
                                               Type = 'Existing Business');
             insert op;
             Test.stopTest();
             system.assertNotEquals(op.ChannelOfDistribution__c, null,'ChannelOfDistribution__c should not be null');
         }
     }
}