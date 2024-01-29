/****************************************************************************
* Name: QuoteTriggerHandlerTest
* Author: Impana Paalyam
* Created Date: 02/02/2023
* Description: Test class for Quote Trigger
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
****************************************************************************/
@isTest
public class QuoteTriggerHandlerTest {
    
    @testSetup
    static void setUpData(){
        List<User> userList = TestDataFactory.createUser(3);
        System.runAs(userList[0]) {
            List<Account> act = TestDataFactory.createAccounts(1);
            act[0].ChannelOfDistribution__c = '11';
            update act;
            Account acc = [Select Id, Name, ChannelOfDistribution__c from Account limit 1];
            List<Opportunity> opplst = TestDataFactory.createOpps(1);
            opplst[0].AccountId = acc.id;
            opplst[0].ChannelOfDistribution__c = '11';  
            update opplst;
       }
    }
    @isTest static void testInsertOpportunity(){
        Test.startTest();
        Account acc = [SELECT Id, Name, ChannelOfDistribution__c FROM Account WHERE Name = 'TestAccount0' limit 1];
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'Opportunitywithquotecreations'];
        Opportunity op = new Opportunity(Name = 'Test',
                                         StageName = 'New',
                                         CloseDate = System.today().addMonths(1),
                                         AccountId = acc.Id,
                                         RecordTypeId = rt.ID,
                                         QuoteOfferedDate__c= System.today(),
                                         ChannelOfDistribution__c = '11',
                                                OpportunityType__c = 'Standard Inquiry',
                                               BusinessArea__c ='ZK',
                                               DateOfReceipt__c = System.today(),
                                               CurrencyIsoCode ='EUR',
                                               CalculationTimePoint__c = 'Monthly',
                                               QuoteValidTill__c = System.today(),
                                               Incoterms__c = 'CAD - CAD',
                                               DateOf_Payment__c = 'AA',
                                               Type = 'Existing Business'
                                       );
        insert op;
        Quote qo = new Quote();
        qo.Name = 'TestQuote';
        qo.OpportunityId =op.id; 
        insert qo;
        qo.Status = ConstantClass.OFFERED_STATUS;
        update qo;
        system.assertEquals(op.ChannelOfDistribution__c, '11' , 'ChannelOfDistribution__c should be 11');
        Test.stopTest();
    }
}