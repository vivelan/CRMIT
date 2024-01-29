/****************************************************************************
* Name: ExceptionUtilTest
* Author: Harshitha U
* Created Date: 22/08/2022
* Description: Test class for ExceptionUtil class.
*****************************************************************************/
@isTest
private class ExceptionUtilTest {
    @testSetup static void setup(){
        List<Account> lstaccts = new List<Account>();
        lstaccts = TestDataFactory.createAccounts(2);
        
    }
    @isTest static void validatelogException() {
        String exdetails = '';
        List<Account> accts = new List<Account>();
        List<Opportunity> opps = new List<Opportunity>();
        List<Database.Saveresult> resultlist = new List<Database.Saveresult>();
        List<String> exdetailslst = new List<String>();
        try{
            accts = [SELECT Name FROM Account WHERE Name LIKE 'TestAccount%' LIMIT 1];
            for (Integer k=0;k<2;k++) {
                opps.add(new Opportunity(Name='TestOpportunity ' + k,
                                         StageName='Prospecting'
                                        ));
            }
            if(!opps.isEmpty())
            {
                resultlist = Database.Insert(opps,false);
            }
        }
        catch(Exception e){
            exdetails = e.getCause()+' ; '+e.getLineNumber() + ' ; '+e.getMessage()+' ; '+e.getStackTraceString()
                +' ; '+e.getTypeName();
            exdetailslst.add(exdetails);
        }
        Test.startTest();
        ExceptionUtilClass.logException('Account','Insert Account',accts[0].Id,exdetails,'Apex');
        ExceptionUtilClass.logException('Opportunity','Insert Opportunity',resultlist,'Apex');
        ExceptionUtilClass.publishException('Account','Insert Account',accts[0].Id,exdetails,'Apex');
        ExceptionUtilClass.publishException('Opportunity','Insert Opportunity',resultlist,'Apex');
        System.assertEquals(resultlist.get(0).isSuccess(), false, 'Incorrect output');
        Test.stopTest();
    }
    
}