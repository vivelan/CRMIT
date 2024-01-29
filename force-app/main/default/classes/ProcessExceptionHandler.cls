/****************************************************************************
* Name: ProcessExceptionHandler
* Author: Harshitha U
* Test Class: ProcessExceptionHandlerTest
* Created Date: 22/08/2022
* Description: Handler Class to create and log exceptions.
(Includes method to create an exception record once the platform event is published)
*****************************************************************************/
public without sharing class ProcessExceptionHandler {
    public void createException(List<ExceptionLog__e> lstex){
        List<Exception__c> listex = new list<Exception__c>();
        for(ExceptionLog__e ex : lstex)
        {
            Exception__c exc = new Exception__c();
            exc.Object__c =ex.Object__c;
            exc.Operation__c = ex.Operation__c;
            exc.ExceptionDetails__c = ex.ExceptionDetails__c;
            exc.RecordID__c = ex.RecordID__c;
            exc.ErrorOccuredIn__c = ex.ErrorOccuredIn__c;
            listex.add(exc);       
        }
        if(!listex.isEmpty())
        {
            INSERT listex;
        }
    }
}