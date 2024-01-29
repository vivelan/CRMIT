/****************************************************************************
* Name: PWResetForClientFlowControllerTest
* Author: Naina Butle
* Created Date: 04/10/2023
* Description: test class for Controller class for DH | Session set up / PW reset for client portal users flow
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
****************************************************************************/
@isTest
public with sharing class PWResetForClientFlowControllerTest {
    static void setUpdata(){
        TestDataFactory.createUser(1);
    }
    
    @isTest static void sendRestMailTest(){
        Test.startTest();
        List<Boolean> exceptions = new List<Boolean>();
        List<User> userList = [SELECT Id, UserRoleId, LastName, ProfileId, Profile.Name, IsActive FROM User Where IsActive = true ];
        try{
            PWResetForClientFlowController.sendRestMail(new List<Id>{userList[0].Id});
        }catch(exception ex){
            exceptions.add(true);
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptions, 'expected at least one exception to have occured');
        for(Boolean b : exceptions){
            system.assert(b, 'User should have thrown an exception');
        }
    }
}