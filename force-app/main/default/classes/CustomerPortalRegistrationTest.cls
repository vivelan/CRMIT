/****************************************************************************
* Name: CustomerPortalRegistrationTest
* Author: Naina Butle
* Created Date: 05/09/2023
* Description: Test class for CustomerPortalRegistration
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
****************************************************************************/
@isTest
public class CustomerPortalRegistrationTest {
     @testSetup
    static void setUpData(){
       TestDataFactory.createCases(1);
    }
    
    @isTest static void sendEmailTest(){
         Test.startTest();
        List<Case> caseData = [SELECT Id, CaseNumber, SuppliedEmail FROM Case];
        List<String> recordId = new List<String>();
        for(Case cs : caseData){
            recordId.add(cs.Id);
        }
         CustomerPortalRegistration.sendEmail(recordId);
         Integer invocations = Limits.getEmailInvocations();
          Test.stopTest();
         System.assertEquals(1, invocations, 'Email has not been sent');
    }
}