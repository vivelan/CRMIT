/********************************************************************************************************
 * @author         Impana
 * @description    Test class for VisitReportController class
 * @date           2023-11-02
 *********************************************************************************************************/
@isTest
private with sharing class VisitReportControllerTest {
  /*******************************************************************************************************************
   * @author        Impana
   * @description   Test Setup method
   *******************************************************************************************************************/
  @testSetup
  static void testSetup() {
    List<User> u = TestDataFactory.createUser(1);
    System.runAs(u[0]) {        
      Account testAccount = new Account(Name = 'TestAccount');
      insert testAccount;
      Schema.Location locationStandardObject;
      locationStandardObject = new Schema.Location(Name = 'Test Location',
      LocationType ='Sales'
        );
      insert locationStandardObject;

      Visit__c visitReport = new Visit__c();
      visitReport.Subject__c = 'Mill Tour';
      visitReport.Account__c = testAccount.Id;
      visitReport.VisitDateStart__c= Date.valueOf('2030-05-06');
      insert visitReport;
      Contact testContact = new Contact(
          AccountId = testAccount.Id,
          LastName = 'TestContact'
      );
      
      insert testContact;
      
      Visitor__c attendee = new Visitor__c();
      
      attendee.Visit__c = visitReport.Id;
      attendee.Contact__c = testContact.Id;
      attendee.Comment__c = 'Comment';
      //attendee.IsPrimaryContact__c = false;
      //attendee.AssigneeId = u[0].Id;
      insert attendee;
    }
  }
  /*******************************************************************************************************************
   * @author        Impana
   * @description   This method is used to test displayManageVisitReportTiles method from VisitReportsController class
   *******************************************************************************************************************/
  @isTest
    static void testDisplayManageVisitReportTiles(){
List<User> userList = [SELECT Id, UserRoleId, LastName, ProfileId, Profile.Name, IsActive FROM User WHERE (Profile.Name ='System Administrator' OR Profile.Name ='Systemadministrator') AND IsActive =TRUE LIMIT 1];
       
    System.runAs(userList[0]) {
      Test.startTest();
      Map<String, Boolean> tilesVisitReport = VisitReportController.displayManageVisitReportTiles();
      Boolean isResult = false;
      if (tilesVisitReport != null) {
        isResult = true;
      }
      Test.stopTest();
      System.assertEquals(true, isResult,'tilesVisitReport');
    }
  }
  /*******************************************************************************************************************
   * @author        Impana
   * @description   This method is used to test displayManageVisitReportTiles method from VisitReportController class
   *******************************************************************************************************************/
  @isTest
  static void testDisplayManageVisitReportTiles_Negative() {
List<User> userList = [SELECT Id, UserRoleId, LastName, ProfileId, Profile.Name, IsActive FROM User WHERE (Profile.Name ='System Administrator' OR Profile.Name ='Systemadministrator') AND IsActive =TRUE LIMIT 1];
       
    System.runAs(userList[0]) {
      Test.startTest();
      VisitReportController.coverCode = true;
      Map<String, Boolean> tilesVisitReport = VisitReportController.displayManageVisitReportTiles();
      Boolean isResult = false;
      if (tilesVisitReport != null) {
        isResult = true;
      }
      Test.stopTest();
      System.assertEquals(true, isResult,'TilesnotNull');
    }
  }
  /*******************************************************************************************************************
   * @author        Impana
   * @description   This method is used to test getExtendedFieldsValue method from VisitReportController class
   *******************************************************************************************************************/
  @isTest
  static void testGetExtendedFieldsValue() {
   List<User> userList = [SELECT Id, UserRoleId, LastName, ProfileId, Profile.Name, IsActive FROM User WHERE (Profile.Name ='System Administrator' OR Profile.Name ='Systemadministrator') AND IsActive =TRUE LIMIT 1];
       
    System.runAs(userList[0]) {
      Test.startTest();
      Map<String, Boolean> fieldsVisitReport = VisitReportController.getExtendedFieldsValue();
      Boolean isResult = false;
      if (fieldsVisitReport != null) {
        isResult = true;
      }
      Test.stopTest();
      System.assertEquals(true, isResult,'fieldvisitreport');
    }
  }

  /*******************************************************************************************************************
  * @author        Impana
  * @description   This method is used to test insertAttendees method from VisitReportController class
  *******************************************************************************************************************/
  @isTest
  static void insertAttendees() {
  List<User> userList = [SELECT Id, UserRoleId, LastName, ProfileId, Profile.Name, IsActive FROM User WHERE (Profile.Name ='System Administrator' OR Profile.Name ='Systemadministrator') AND IsActive =TRUE LIMIT 1];
       
    System.runAs(userList[0]) {
      Visit__c visitReport = [
        SELECT Id, Name, Account__r.Name, Account__c
        FROM Visit__c
        WHERE Account__r.Name = 'TestAccount'
        LIMIT 1
      ];

      Test.startTest();
      VisitReportController.insertAttendees(
        //'[{"VisitId":"visitReport","Contact":"Test Contact","User":"Test User","Comment":"Comment","isPrimaryContact":true}]',
        '[{"VisitId":"visitReport","Contact":"Test Contact","User":"Test User","Comment":"Comment"}]',
        visitReport.Id
      );
      Test.stopTest();
      List<Visitor__c> newAttendee = [
        SELECT Id, Visit__c
        FROM Visitor__c
        WHERE Visit__c =: visitReport.Id
      ];

      System.assertEquals(2, newAttendee.size(),'Newattendee Size');
    }
  }

  /*******************************************************************************************************************
  * @author        Impana
  * @description   This method is used to test the scenario when inserting Users as Attendees for insertAttendees method from VisitReportsController class
  *******************************************************************************************************************/
  @isTest
  static void insertUserAsAttendees() {
List<User> userList = [SELECT Id, UserRoleId, LastName, ProfileId, Profile.Name, IsActive FROM User WHERE (Profile.Name ='System Administrator' OR Profile.Name ='Systemadministrator') AND IsActive =TRUE LIMIT 1];
       
    System.runAs(userList[0]) {
      Visit__c visitReport = [
        SELECT Id, Name, Account__r.Name, Account__c
        FROM Visit__c
        WHERE Account__r.Name = 'TestAccount'
        LIMIT 1
      ];

      Test.startTest();
      VisitReportController.insertAttendees(
        //'[{"Name":"Automated Process","isPrimaryContact":false,"detailedComment":"Comment"}]',
          '[{"Name":"Automated Process","detailedComment":"Comment"}]',
        visitReport.Id
      );
      Test.stopTest();
      List<Visitor__c> newAttendee = [
        SELECT Id, Visit__c
        FROM Visitor__c
        WHERE Visit__c =: visitReport.Id
      ];

      System.assertEquals(2, newAttendee.size(),'Newattendee size');
    }
  }


  @isTest
  static void insertAttendees_Negative() {
List<User> userList = [SELECT Id, UserRoleId, LastName, ProfileId, Profile.Name, IsActive FROM User WHERE (Profile.Name ='System Administrator' OR Profile.Name ='Systemadministrator') AND IsActive =TRUE LIMIT 1];
       
    System.runAs(userList[0]) {
     Visit__c visitReport = [
        SELECT Id, Name,Account__r.Name, Account__c
        FROM Visit__c
        WHERE Account__r.Name = 'TestAccount'
        LIMIT 1
      ];

      Test.startTest();
      VisitReportController.coverCode = true;
      VisitReportController.insertAttendees(
        //'[{"Id":"0","Name":"Jon Smith 2","Account.Name":"Ink corp","isPrimaryContact":true,"detailedComment":"Comment"}]',
        '[{"Id":"0","Name":"Jon Smith 2","Account.Name":"Ink corp","detailedComment":"Comment"}]',
        visitReport.Id
      );
      Test.stopTest();
      List<Visitor__c> newAttendee = [
        SELECT Id, Contact__r.Name
        FROM Visitor__c
        WHERE Contact__r.Name = 'Jon Smith 2'
      ];

      System.assertEquals(0, newAttendee.size(),'New Attendee Size');
    }
  }
}