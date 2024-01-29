/****************************************************************************
* Name: AccountTeamMemTriHandlerTest
* Author: Naina Butle
* Created Date: 19/10/2022
* Description: Test class of AccountTeamMemberTriggerHandler
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
****************************************************************************/
@isTest
public class AccountTeamMemTriHandlerTest {
    @testSetup  
    static void setUpData(){
        List<User> userList = TestDataFactory.createUser(4);
        
        system.runAs(userList[0]) {
            List<Account> act = TestDataFactory.createAccounts(1);
            act[0].ChannelOfDistribution__c = '11';
            update act;
            Account acc = [Select Id, Name, ChannelOfDistribution__c from Account limit 1];
            List<Opportunity> opplst = TestDataFactory.createOpps(1);
            opplst[0].AccountId = acc.id;
            opplst[0].ChannelOfDistribution__c = '11';  
            update opplst;
            List<AccountTeamMember> members = new list<AccountTeamMember>();
            members.add(new AccountTeamMember(AccountId = acc.id, ChannelOfDistribution__c = '11', TeamMemberRole = ConstantClass.SALESREPRESENTIVE, UserId = userList[0].Id));
            members.add(new AccountTeamMember(AccountId = acc.id, ChannelOfDistribution__c = '11', TeamMemberRole = ConstantClass.ACCOUNTMANAGER, UserId = userList[1].Id));
            members.add(new AccountTeamMember(AccountId = acc.id, ChannelOfDistribution__c = '11', TeamMemberRole = ConstantClass.QUALITYREP, UserId = userList[2].Id));
            members.add(New AccountTeamMember(AccountId = act[0].id, ChannelOfDistribution__c = '11', TeamMemberRole = ConstantClass.QWACCOUNTMANAGER, UserId = userList[3].Id));
            insert members;
        }
    }
    
    @isTest static void testInsertAccountTeam(){
        Test.startTest();
        Account acc = [SELECT Id, Name, ChannelOfDistribution__c FROM Account limit 1];
        List<User> userList = [SELECT Id, UserRoleId, LastName, ProfileId, Profile.Name, IsActive FROM User WHERE (Profile.Name ='System Administrator' OR Profile.Name ='Systemadministrator') AND IsActive =: TRUE];
        system.runAs(userList[0]) {
            List<AccountTeamMember> members = new list<AccountTeamMember>();
            members.add(New AccountTeamMember(AccountId = acc.id, ChannelOfDistribution__c = '11', TeamMemberRole =  ConstantClass.SALESREPRESENTIVE, UserId = userList[0].Id));
            members.add(new AccountTeamMember(AccountId = acc.id, ChannelOfDistribution__c = '11', TeamMemberRole = ConstantClass.ACCOUNTMANAGER, UserId = userList[1].Id));
            members.add(new AccountTeamMember(AccountId = acc.id, ChannelOfDistribution__c = '11', TeamMemberRole = ConstantClass.QUALITYREP, UserId = userList[2].Id));
            insert members;
            system.assertNotEquals(members.size(), 0,'List should not be empty');
        }
        Test.stopTest();
    }
    
    @isTest static void testDeleteAccTeam(){
        Test.startTest();
        Account acc = [SELECT Id, Name, ChannelOfDistribution__c FROM Account WHERE Name = 'TestAccount0' limit 1];
        Opportunity opp = [SELECT Id, AccountId, StageName, IsClosed, ChannelOfDistribution__c FROM Opportunity LIMIT 1];
        List<AccountTeamMember> accTeam = [SELECT Id, AccountId, ChannelOfDistribution__c, QualityDepartment__c, TeamMemberRole, UserId, User.Name, Account.ChannelOfDistribution__c FROM AccountTeamMember WHERE AccountId =: acc.Id];
        delete accTeam;
        Test.stopTest();
        system.assertEquals(opp.ChannelOfDistribution__c, '11' , 'ChannelOfDistribution__c should be 11');

    }
    
    @isTest static void testUpdateAccTeam(){
        Test.startTest();
        Account acc = [SELECT Id, Name, ChannelOfDistribution__c FROM Account WHERE Name = 'TestAccount0' limit 1];
        AccountTeamMember accTeam = [SELECT Id, AccountId, ChannelOfDistribution__c, QualityDepartment__c, TeamMemberRole, UserId, User.Name, Account.ChannelOfDistribution__c FROM AccountTeamMember WHERE AccountId =: acc.Id AND TeamMemberRole =: ConstantClass.ACCOUNTMANAGER AND ChannelOfDistribution__c =: '11'];
        accTeam.ChannelOfDistribution__c = '12';
        update accTeam;
        Test.stopTest();
        system.assertEquals(accTeam.ChannelOfDistribution__c, '12' , 'ChannelOfDistribution__c should be 12');
    }
    @isTest static void testAccTeamNegativeScenario(){
        Test.startTest();
        List<Boolean> exceptions = new List<Boolean>();
        Account acc = [SELECT Id, Name, ChannelOfDistribution__c FROM Account WHERE Name = 'TestAccount0' limit 1];
        acc.ChannelOfDistribution__c = '21';
        update acc;
        List<AccountTeamMember> accTeam = [SELECT Id, AccountId, ChannelOfDistribution__c, QualityDepartment__c, TeamMemberRole, UserId, User.Name, Account.ChannelOfDistribution__c FROM AccountTeamMember WHERE AccountId =: acc.Id LIMIT 1];
        accTeam[0].ChannelOfDistribution__c = '21';
        try{
            update accTeam;
        }catch(exception ex){
            exceptions.add(true);
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptions, 'expected at least one exception to have occured');
        for(Boolean b : exceptions){
            system.assert(b, 'AccountTeamMember should have thrown an exception');
        }
    }
    
    @isTest static void testInsertAccountTNegativeScenario(){
        Test.startTest();
        List<Boolean> exceptions = new List<Boolean>();
        Account acc = [SELECT Id, Name, ChannelOfDistribution__c FROM Account limit 1];
        List<User> userList = [SELECT Id, UserRoleId, LastName, ProfileId, Profile.Name, IsActive FROM User WHERE (Profile.Name ='System Administrator' OR Profile.Name ='Systemadministrator') AND IsActive =: TRUE LIMIT 1];
        system.runAs(userList[0]) {
            List<AccountTeamMember> members = new list<AccountTeamMember>();
            members.add(New AccountTeamMember(AccountId = acc.id, ChannelOfDistribution__c = '11', TeamMemberRole = ConstantClass.ACCOUNTMANAGER));
            try{
                insert members;
            }
            catch(exception ex){
                exceptions.add(true);
            }
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptions, 'expected at least one exception to have occured');
        for(Boolean b : exceptions){
            system.assert(b, 'AccountTeamMember should have thrown an exception');
        }
    }
    
}