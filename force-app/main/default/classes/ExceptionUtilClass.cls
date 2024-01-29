/****************************************************************************
* Name: ExceptionUtilClass
* Author: Harshitha U
* Test Class: ExceptionUtilTest
* Created Date: 22/08/2022
* Description: Utility Class to handle and log exceptions 
(Includes methods to create an exception record and publish platform event which inturn logs an exception)
*****************************************************************************/

public without sharing class ExceptionUtilClass {
    public class MyException extends Exception {}
    /****************************************************************************
    * Author Name: Harshitha U
    * Description: Method to Log Custom Exception
    * Created Date: 22/08/2022
    * Last Modified Date: 22/08/2022
	****************************************************************************/
    @InvocableMethod(label='Invoke ExceptionUtil')
    public static void throwcustomException(List<String> excmessage){
        
        throw new MyException('An internal exception happened during current operation.'+ 
                              'Please contact system administrator with this exception details:'+excmessage[0]);
        
    }
    
    /****************************************************************************
    * Author Name: Harshitha U
    * Description: Log Single Exception
    * Created Date: 22/08/2022
    * Last Modified Date: 26/08/2022
    ****************************************************************************/
    public static void logException(String objname, String processname, String recordID, String exceptiondetails ,String exceptionOccuredIn){
        Exception__c exc = new Exception__c();
        exc.Object__c = objname;
        exc.Operation__c = processname;
        exc.ExceptionDetails__c = exceptiondetails;
        exc.RecordID__c = recordID;
        exc.ErrorOccuredIn__c = exceptionOccuredIn;
        INSERT exc;
    }   
    /****************************************************************************
    * Author Name: Harshitha U
    * Description: Log Exceptions
    * Created Date: 22/08/2022
    * Last Modified Date: 26/08/2022
    ****************************************************************************/
    public static void logException(String objname, String processname, List<Database.SaveResult> listSaveResult , String exceptionOccuredIn){
        List<Exception__c> exclist = new List<Exception__c>();
        Exception__c exc;
        for(Database.SaveResult res : listSaveResult){
            if(!res.isSuccess()){
                exc = new Exception__c();
                exc.Object__c = objname;
                exc.Operation__c = processname;
                String excdetail;
                for(Database.Error err : res.getErrors()) {
                    excdetail+= err.getStatusCode()+':'+err.getMessage(); 
                }
                String detail = new dmlException().getStackTraceString();
                exc.ExceptionDetails__c =excdetail+detail ;
                exc.RecordID__c = res.getId();
                exc.ErrorOccuredIn__c = exceptionOccuredIn ; 
                exclist.add(exc);
            }
        }
        if(!exclist.isEmpty()){
            INSERT exclist;
        }
    }
    /****************************************************************************
    * Author Name: Harshitha U
    * Description: Publish Event to capture exceptions
    * Created Date: 22/08/2022
    * Last Modified Date: 26/08/2022
    ****************************************************************************/
    public static void publishException(String objname, String processname, String recordID, String exceptiondetails , String exceptionOccuredIn){
        ExceptionLog__e pe = new ExceptionLog__e();
        pe.Object__c = objname;
        pe.Operation__c = processname;
        pe.ExceptionDetails__c = exceptiondetails;
        pe.RecordID__c = recordID;
        pe.ErrorOccuredIn__c = exceptionOccuredIn; 
        eventBus.publish(pe);
    }
    /****************************************************************************
    * Author Name: Harshitha U
    * Description: Publish Events to capture exceptions
    * Created Date: 22/08/2022
    * Last Modified Date: 26/08/2022
    ****************************************************************************/
    public static void publishException(String objname, String processname, List<Database.SaveResult> listSaveResult, String exceptionOccuredIn){
        List<ExceptionLog__e> pelist = new List<ExceptionLog__e>();
        ExceptionLog__e pe;
        for(Database.SaveResult res : listSaveResult){
            if(!res.isSuccess()){
                pe = new ExceptionLog__e();
                pe.Object__c = objname;
                pe.Operation__c = processname;
                String excdetail;
                for(Database.Error err : res.getErrors()) {
                    excdetail+= err.getStatusCode()+':'+err.getMessage();
                }
                String detail = new dmlException().getStackTraceString();
                pe.ExceptionDetails__c = excdetail+detail;
                pe.ErrorOccuredIn__c = exceptionOccuredIn;
                pelist.add(pe);
            }
        }
        if(!pelist.isEmpty()){
            eventBus.publish(pelist);
        }
    }
}