/****************************************************************************
* Name: ProcessExceptionHandlerTest
* Author: Harshitha U
* Created Date: 22/08/2022
* Description: Test class for ProcessExceptionHandler class.
*****************************************************************************/
@isTest
private class ProcessExceptionHandlerTest {
    @isTest static void testValidateEvent() {
        List<Account> lstaccts = new List<Account>();
        lstaccts = TestDataFactory.createAccounts(1);
        ExceptionLog__e expEvent = new ExceptionLog__e(Object__c='Account', 
                                             ExceptionDetails__c='DML Exception', 
                                             RecordID__c=lstaccts[0].ID);
        
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(expEvent);
        Test.stopTest();
        System.assertEquals(true, sr.isSuccess(),'Incorrect output');
        List<Exception__c> explst = [SELECT Id,Object__c,ExceptionDetails__c FROM Exception__c];
        System.assertEquals(1, explst.size(), 'Incorrect output');
    }
}