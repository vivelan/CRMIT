/****************************************************************************
* Name: RepeatingSchedulerDHUserUpdateTest 
* Author: Naina B
* Created Date: 22/12/2023
* Description: Test class of RepeatingSchedulerDHUserUpdate
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
****************************************************************************/
@isTest
public with sharing class RepeatingSchedulerDHUserUpdateTest { 
    @testSetup  
    static void setUpData(){
        TestDataFactory.createUserDHCustomerCommunityPlusLoginUser(5);
        List<User> userNewList = [SELECT Id, Name, Email, Username, IsPortalEnabled, ContactId, Contact.AccountId, Profile.Name from User WHERE ContactId != Null  AND Contact.AccountId != null LIMIT 4];
        userNewList[0].Username = 'abhhj@shsPhhh.com';
        userNewList[0].Email = 'testdhemai0@shsproject.com';
        userNewList[1].Username = 'abhhj@shs.com';
        userNewList[2].Email = 'testdhemai0@shsproject.com';
        userNewList[3].Email = 'testdhemai4@shsproject.com';
        update userNewList;
        
        Group testGroup = new Group(Name = ConstantClass.SYSTEMADMINS_QUEUE, Type='Queue');
        insert testGroup;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
    }
    
    @isTest static void testUpdateUserName(){
        Test.startTest();
        List<User> userList = [SELECT Id, UserRoleId, LastName, ProfileId, Profile.Name, IsActive FROM User LIMIT 3];
		ScheduleUsernameUpdate testsche = new ScheduleUsernameUpdate();
		Datetime sysTime = System.now().addMinutes(5);
        String cronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
		system.schedule('ScheduleUsernameUpdate1Test', cronExpression, testsche);  
        system.assertNotEquals(userList.size(), 0,'List should not be empty');
        Test.stopTest(); 
        
    }
}  
