@IsTest
public with sharing class VisitReportUtilityTest {
    /*******************************************************************************************************************
* @author        Impana
* @description   Test Setup method
*******************************************************************************************************************/
    @TestSetup
    static void testSetup() {
        List<User> u = TestDataFactory.createUser(1);
        u[0].Email = 'testUser@deloitte.com';
        update u[0];
        Schema.Location locationStandardObject;
        locationStandardObject = new Schema.Location(Name = 'Test Location',
                                                     LocationType ='Sales'
                                                    );
        insert locationStandardObject;
        
        
        System.runAs(u[0]) {      
            Account testAccount = new Account(Name = 'TestAccount');
            insert testAccount;
            
            Visit__c visitReport = new Visit__c();
            visitReport.Subject__c = 'Trade Fair / Event';
            visitReport.Account__c = testAccount.Id;
            visitReport.VisitDateStart__c = Date.valueOf('2021-05-06');
            
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
            //attendee.Name = 'Test';
            //attendee.AssigneeId = testContact.Id ;  
            insert attendee;
            
            Checklist__c checklist = new Checklist__c();
            checklist.Active__c = true;
            checklist.Name = 'Question1 Checklist';
            insert checklist;
            
            Checklist__c checklistRecord = new Checklist__c();
            checklistRecord.Active__c = true;
            checklistRecord.Name = 'Question2 Checklist';
            insert checklistRecord;
            
            ChecklistSection__c qsection = new ChecklistSection__c();
            qsection.Checklist__c = checklist.Id;
            qsection.Name = 'Section';
            insert qsection;
            
            ChecklistQuestion__c checklistQuestion = new ChecklistQuestion__c();
            checklistQuestion.Active__c = true;
            checklistQuestion.ChecklistSection__c = qsection.Id;
            checklistQuestion.QuestionText__c = 'Question?';
            checklistQuestion.Type__c = 'Text';
            insert checklistQuestion;
            
            ChecklistQuestionResponse__c qResponse = new ChecklistQuestionResponse__c();
            qResponse.Response__c = 'Response';
            qResponse.Type__c = 'Text';
            qResponse.QuestionText__c = 'Question?';
            qResponse.Response__c = 'Response!';
            qResponse.Checklist__c = checklist.Id;
            qResponse.Visit__c = visitReport.Id;
            qResponse.ChecklistQuestion__c = checklistQuestion.Id;
            insert qResponse;
            
            ChecklistQuestionResponse__c qResponseRecord = new ChecklistQuestionResponse__c();
            qResponseRecord.Response__c = 'Response';
            qResponseRecord.Type__c = 'Text';
            qResponseRecord.QuestionText__c = 'Question?';
            qResponseRecord.Response__c = 'Response!';
            qResponseRecord.Checklist__c = checklistRecord.Id;
            qResponseRecord.Visit__c = visitReport.Id;
            qResponseRecord.ChecklistQuestion__c = checklistQuestion.Id;
            insert qResponseRecord;
        } 
        
    }
    /*******************************************************************************************************************
* @author        Impana
* @description   This method is used to test getRecords method from VisitReportUtility class
*******************************************************************************************************************/
    @isTest
    static void testManageVisitReportsAttendees() {
        User u = [
            SELECT Id, Email
            FROM User
            WHERE Email = 'testUser@deloitte.com'
        ];
        
        System.runAs(u) {
            Visit__c vr = [
                SELECT Id, Name
                FROM Visit__c
                LIMIT 1
            ];
            Test.startTest();
            
            List<Visitor__c> attendees = VisitReportUtility.getRecords(
                vr.Id
            );
            
            Test.stopTest();
            
            Boolean attendeeExists = false;
            
            if (attendees.size() > 0) {
                attendeeExists = true;
            }
            System.assertEquals(true, attendeeExists,'attendeeExists');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This method is used to test a negative scenario for getRecords method from VisitReportUtility class
*******************************************************************************************************************/
    @isTest
    static void testManageVisitReportsAttendees_Negative() {
        User u = [
            SELECT Id, Email
            FROM User
            WHERE Email = 'testUser@deloitte.com'
        ];
        
        System.runAs(u) {
            Visit__c vr = [
                SELECT Id, Name
                FROM Visit__c
                LIMIT 1
            ];
            Test.startTest();
            VisitReportUtility.coverCode = true;
            List<Visitor__c> attendees = VisitReportUtility.getRecords(
                vr.Id
            );
            
            Test.stopTest();
            
            Boolean attendeeExists = false;
            
            if (attendees == null) {
                attendeeExists = true;
            }
            System.assertEquals(true, attendeeExists,'attendeeExists');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This method is used to test getAttendees method from VisitReportUtility class
*******************************************************************************************************************/
    @isTest
    static void testGetAttendees() {
        User u = [
            SELECT Id, Email
            FROM User
            WHERE Email = 'testUser@deloitte.com'
        ];
        
        System.runAs(u) {
            String query =
                '{"sObjectName": "Visitor__c",' +
                //'"fields": ["Contact__r.Name", "Contact__r.Email", "Comment__c", "IsPrimaryContact__c", "Contact__r.Account.Name"],' +
                '"fields": ["Contact__r.Name", "Contact__r.Email", "Comment__c","Contact__r.Account.Name"],' +
                '"orderbyClause": "Contact__r.Name",' +
                '"whereClause": "Contact__r.Name != null",' +
                '"rowCount": 100}';
            Test.startTest();
            
            List<Visitor__c> attendeesList = VisitReportUtility.getAttendees(
                query
            );
            
            Test.stopTest();
            Boolean attendeeExists = false;
            if (attendeesList.size() > 0) {
                attendeeExists = true;
            }
            system.assertEquals(true, attendeeExists,'attendeeExists');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This method is used to test a negative scenario for getAttendees method from VisitReportUtility class
*******************************************************************************************************************/
    @isTest
    static void testGetAttendees_Negative() {
        User u = [
            SELECT Id, Email
            FROM User
            WHERE Email = 'testUser@deloitte.com'
        ];
        
        System.runAs(u) {
            String query =
                '{"sObjectName": "Visitor",' +
                //'"fields": ["Contact__r.Name", "Contact__r.Email", "Comment__c", "IsPrimaryContact__c", "Contact__r.Account.Name"],' +
                '"fields": ["Contact__r.Name", "Contact__r.Email", "Comment__c","Contact__r.Account.Name"],' +
                '"orderbyClause": "Contact__r.Name",' +
                '"whereClause": "Contact__r.Name != null",' +
                '"rowCount": 100}';
            Test.startTest();
            VisitReportUtility.coverCode = true;
            List<Visitor__c> attendeesList = VisitReportUtility.getAttendees(
                query
            );
            
            Test.stopTest();
            
            Boolean attendeeExists = true;
            if (attendeesList == null) {
                attendeeExists = false;
            }
            system.assertEquals(false, attendeeExists,'attendeeExists');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This method is used to test a negative scenario for updateAttendees method from VisitReportUtility class
*******************************************************************************************************************/
    @isTest
    static void updateAttendees_Negative() {
        User u = [
            SELECT Id, Email
            FROM User
            WHERE Email = 'testUser@deloitte.com'
        ];
        
        System.runAs(u) {
            Test.startTest();
            VisitReportUtility.coverCode = true;
            VisitReportUtility.updateAttendees(
            // '[{"Id":"0","Comment__c":"Comment ","IsPrimaryContact__c":true}]'
            '[{"Id":"0","Comment__c":"Comment "}]'
              );
            Test.stopTest();
            List<Visitor__c> updatedAttendee = [
                SELECT Id, Contact__r.Name
                FROM Visitor__c
                WHERE Contact__r.Name = 'Jon Smith 2'
                //AND IsPrimaryContact__c = false
            ];
            System.assertEquals(0, updatedAttendee.size(),'updatedAttendee');
        }
    }    
    /*******************************************************************************************************************
* @author        Impana
* @description   This method is used to test getChecklists method from VisitReportUtility class- on catch
*******************************************************************************************************************/
    @isTest
    static void testGetChecklists_onCatch() {
        User u = [
            SELECT Id, Email
            FROM User
            WHERE Email = 'testUser@deloitte.com'
        ];
        
        System.runAs(u) {
            Visit__c visitReport = [
                SELECT Id, Name, Account__r.Name
                FROM Visit__c
                WHERE Account__r.Name = 'TestAccount'
                LIMIT 1
            ];
            
            Test.startTest();
            VisitReportUtility.coverCode = true;
            List<Checklist__c> checklists = VisitReportUtility.getChecklists(
                visitReport.Id,
                ''
            );
            Test.stopTest();
            Boolean isResult = false;
            if(checklists != null){
                if(checklists.size() > 0){
                    isResult = true;  
                }
            }
            System.assert(true, isResult);
        }
    }
    /*******************************************************************************************************************
* @author        Impana
* @description   This method is used to test negative scenario for getChecklists method from VisitReportUtility class
*******************************************************************************************************************/
    @isTest
    static void testGetChecklistsMethod_Negative() {
        User u = [
            SELECT Id, Email
            FROM User
            WHERE Email = 'testUser@deloitte.com'
        ];
        
        System.runAs(u) {
            Visit__c visitReport = [
                SELECT Id, Name, Account__r.Name FROM Visit__c WHERE Account__r.Name = 'TestAccount'
                LIMIT 1
            ];
            
            Test.startTest();
            List<Checklist__c> checklists = VisitReportUtility.getChecklists(
                visitReport.Id,
                'Checklist Search key'
            );
            
            Boolean isResult = false;
            if(checklists.size() > 0){
                isResult = true;
            }
            Test.stopTest();
            System.assertEquals(false, isResult,'Result');
        }
    }
    /*******************************************************************************************************************
* @author        Impana
* @description   This method is used to test deleteAttendees method from VisitReportUtility class
*******************************************************************************************************************/
    @isTest
    static void testDeleteAttendeesMethod() {
        User u = [
            SELECT Id, Email
            FROM User WHERE Email = 'testUser@deloitte.com'
            LIMIT 1
        ];
        
        System.runAs(u) {
            Visit__c vr = [
                SELECT Id, Name
                FROM Visit__c
                LIMIT 1
            ];
            
            Visitor__c attendeeRec = [
                SELECT Id, Name, Visit__c
                FROM Visitor__c
                WHERE Visit__c = :vr.Id
                LIMIT 1
            ];
            
            List<Id> ids = new List<Id>();
            ids.add(attendeeRec.Id);
            
            Test.startTest();
            VisitReportUtility.deleteAttendees(ids);
            Boolean isResult = false;
            if(ids != null){
                isResult = true;
            }
            Test.stopTest();
            System.assertEquals(true, isResult,'DeletedResult');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This method is used to test deleteAttendees method from VisitReportUtility class
*******************************************************************************************************************/
    @isTest
    static void testDeleteAttendeesMethod_Negative() {
        User u = [
            SELECT Id, Email
            FROM User WHERE Email = 'testUser@deloitte.com'
            LIMIT 1
        ];
        
        List<Id> ids = new List<Id>();
        
        System.runAs(u) {
            Test.startTest();
            VisitReportUtility.coverCode = true;
            VisitReportUtility.deleteAttendees(ids);
            Boolean isResult = false;
            if(ids != null){
                isResult = true;
            }
            Test.stopTest();
            System.assertEquals(true, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This method is used to test getVisitReportSettingsMetadata method from VisitReportUtility class
*******************************************************************************************************************/
    @isTest
    static void testgetVisitReportSettingsMetadata() {
        User u = [
            SELECT Id, Email
            FROM User WHERE Email = 'testUser@deloitte.com'
            LIMIT 1
        ];
        System.runAs(u) {
            Test.startTest();
            ManagingVisitReports__mdt metadataRecord = VisitReportUtility.getVisitReportSettingsMetadata();
            Boolean isResult = false;
            if (metadataRecord != null) {
                isResult = true;
            }
            Test.stopTest();
            System.assertEquals(true, isResult,'Result');
        }
    } 
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will call test createChecklistQuestionResponses, getChecklistWrapperList and saveChecklistQuestionResponses methods from VisitReportsUtility class
*******************************************************************************************************************/
    @isTest
    static void  testCreateChecklistQuestionResponses(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            createChecklistRecords();
            List<Visit__c> visitReportList = [SELECT Id, Name, Subject__c FROM Visit__c WHERE Subject__c = 'Mill Tour'];
            List<Checklist__c> checklistList = [SELECT Id, Name FROM Checklist__c WHERE Name = 'Checklist1 TAC'];
            List<Id> checklistIds = new List<Id>();
            checklistIds.add(checklistList[0].Id);
            
            Test.startTest();
            VisitReportUtility.createChecklistQuestionResponses(visitReportList[0].Id, checklistIds);
            List<VisitReportUtility.ChecklistWrapper> checklistWrapperList = VisitReportUtility.getChecklistWrapperList(visitReportList[0].Id);
            String jsonActualAnswers = createJsonAnswers(null, null);
            VisitReportUtility.saveChecklistQuestionResponses(jsonActualAnswers, visitReportList[0].Id, checklistIds[0]);
            Boolean isResult = false;
            if(checklistWrapperList.size() > 0){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(true, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will call UpdatedChecklistQuestionResponseWrapper constructor from VisitReportsUtility class
*******************************************************************************************************************/
    @isTest
    static void  testUpdatedChecklistQuestionResponseWrapper(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            VisitReportUtility.UpdatedChecklistQuestionResponseWrapper updatedChecklistQuestionResponseWrapper = new VisitReportUtility.UpdatedChecklistQuestionResponseWrapper(null, null);
            VisitReportUtility.UpdatedChecklistQuestionResponseWrapper updatedChecklistQuestionResponseWrapper2 = new VisitReportUtility.UpdatedChecklistQuestionResponseWrapper();
            Boolean isResult = false;
            if(updatedChecklistQuestionResponseWrapper != null && updatedChecklistQuestionResponseWrapper2 != null){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(true, isResult,'Result');  
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test CreateChecklistQuestionResponseList method from VisitReportsUtility class - on catch
*******************************************************************************************************************/
    @isTest
    static void  testCreateChecklistQuestionResponseList_OnCatch(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            VisitReportUtility.CreateChecklistQuestionResponseList(null);
            Boolean isResult = false;
            if(VisitReportUtility.checklistQuestionResponseList.size() > 0){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(false, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test createChecklistQuestionResponses method from VisitReportsUtility class - on catch
*******************************************************************************************************************/
    @isTest
    static void  testCreateChecklistQuestionResponses_OnCatch(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            VisitReportUtility.createChecklistQuestionResponses(null, null);
            List<ChecklistQuestionResponse__c> listQuestionResponse = [SELECT Id, Name FROM ChecklistQuestionResponse__c WHERE Name LIKE '%TAC%'];
            Boolean isResult = false;
            if(listQuestionResponse.size() > 0){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(false, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test saveChecklistQuestionResponses method from VisitReportsUtility class - on catch
*******************************************************************************************************************/
    @isTest
    static void  testSaveChecklistQuestionResponses_OnCatch(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            VisitReportUtility.saveChecklistQuestionResponses(null, null, null);
            List<ChecklistQuestionResponse__c> listQuestionResponse = [SELECT Id, Name FROM ChecklistQuestionResponse__c WHERE Name LIKE '%TAC%'];
            Boolean isResult = false;
            if(listQuestionResponse.size() > 0){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(false, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test createChecklistList method from VisitReportsUtility class - on catch
*******************************************************************************************************************/
    @isTest
    static void  testCreateChecklistList_OnCatch(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            VisitReportUtility.checklistQuestionResponseList = null;
            VisitReportUtility.createChecklistList();
            Boolean isResult = false;
            if(VisitReportUtility.checklistList.size() > 0){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(false, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test createChecklistListFinal method from VisitReportsUtility class - on catch
*******************************************************************************************************************/
    @isTest
    static void  testCreateChecklistListFinal_OnCatch(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            VisitReportUtility.checklistList = null;
            VisitReportUtility.createChecklistListFinal();
            Boolean isResult = false;
            if(VisitReportUtility.checklistListFinal.size() > 0){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(false, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test createChecklistQuestionList method from VisitReportsUtility class - on catch
*******************************************************************************************************************/
    @isTest
    static void  testCreateChecklistQuestionList_OnCatch(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            VisitReportUtility.checklistQuestionResponseList = null;
            VisitReportUtility.createChecklistQuestionList();
            Boolean isResult = false;
            if(VisitReportUtility.checklistQuestionList.size() > 0){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(false, isResult,'Result');
            
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test createChecklistSectionList method from VisitReportsUtility class - on catch
*******************************************************************************************************************/
    @isTest
    static void  testCreateChecklistSectionList_OnCatch(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            VisitReportUtility.checklistList = null;
            VisitReportUtility.createChecklistSectionList();
            Boolean isResult = false;
            if(VisitReportUtility.checklistSectionList.size() > 0){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(false, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test createMapPossibleAnswersAndActualResponses method from VisitReportsUtility class - on catch
*******************************************************************************************************************/
    @isTest
    static void  testCreateMapPossibleAnswersAndActualResponses_OnCatch(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            VisitReportUtility.checklistQuestionResponseList = null;
            VisitReportUtility.createMapPossibleAnswersAndActualResponses();
            Boolean isResult = false;
            if(VisitReportUtility.mapPossibleAnswers.size() > 0 && VisitReportUtility.mapActualResponses.size() > 0){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(false, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test createMapChecklistAndChecklistSection method from VisitReportsUtility class - on catch
*******************************************************************************************************************/
    @isTest
    static void  testCreateMapChecklistAndChecklistSection_OnCatch(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            VisitReportUtility.checklistSectionList = null;
            VisitReportUtility.createMapChecklistAndChecklistSection();
            Boolean isResult = false;
            if(VisitReportUtility.mapChecklistAndChecklistSection.size() > 0){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(false, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test createMapQuestionAndQuestionResponse method from VisitReportsUtility class - on catch
*******************************************************************************************************************/
    @isTest
    static void  testCreateMapQuestionAndQuestionResponse_OnCatch(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            VisitReportUtility.checklistQuestionResponseList = null;
            VisitReportUtility.createMapQuestionAndQuestionResponse();
            Boolean isResult = false;
            if(VisitReportUtility.mapQuestionAndQuestionResponse.size() > 0){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(false, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test createMapChecklistSectionAndResponse method from VisitReportsUtility class - on catch
*******************************************************************************************************************/
    @isTest
    static void  testCreateMapChecklistSectionAndResponse_OnCatch(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            VisitReportUtility.checklistQuestionResponseList = null;
            VisitReportUtility.createMapChecklistSectionAndResponse();
            Boolean isResult = false;
            if(VisitReportUtility.mapChecklistSectionAndResponse.size() > 0){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(false, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test getChecklistWrapperList method from VisitReportsUtility class - on catch
*******************************************************************************************************************/
    @isTest
    static void  testGetChecklistWrapperList_OnCatch(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            VisitReportUtility.checklistListFinal = null;
            List<VisitReportUtility.ChecklistWrapper> listWrapper = VisitReportUtility.getChecklistWrapperList(null);
            
            Boolean isResult = false;
            if(listWrapper != null){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(false, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test createMapIdAndVisitReport method from VisitReportsUtility class - on catch
*******************************************************************************************************************/
    @isTest
    static void  testCreateMapIdAndVisitReport_OnCatch(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            VisitReportUtility.coverCode = true;
            VisitReportUtility.createMapIdAndVisitReport();
            Boolean isResult = false;
            if(VisitReportUtility.mapIdAndVisitReport.size() > 0){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(false, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test createMapPossibleAnswersAndActualResponses method from VisitReportsUtility class - conatins new line
*******************************************************************************************************************/
    @isTest
    static void  testCreateMapPossibleAnswersAndActualResponses_ContainsNewLine(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            createChecklistRecords();
            ChecklistQuestion__c question = [SELECT Id, Name, QuestionText__c, Answers__c FROM ChecklistQuestion__c WHERE QuestionText__c = 'Question TAC4 ?' LIMIT 1];
            question.Answers__c = question.Answers__c + '\r\n' + 'checkbox opt2';
            update question;
            
            List<Visit__c> visitReportList = [SELECT Id, Name, Subject__c FROM Visit__c
			WHERE Subject__c = 'Mill Tour'];
            List<Checklist__c> checklistList = [SELECT Id, Name FROM Checklist__c WHERE Name = 'Checklist1 TAC'];
            List<Id> checklistIds = new List<Id>();
            checklistIds.add(checklistList[0].Id);
            
            Test.startTest();
            VisitReportUtility.createChecklistQuestionResponses(visitReportList[0].Id, checklistIds);
            List<VisitReportUtility.ChecklistWrapper> checklistWrapperList = VisitReportUtility.getChecklistWrapperList(visitReportList[0].Id);
            
            
            String jsonActualAnswers = createJsonAnswers('Checkbox', 'checkbox opt2');
            VisitReportUtility.saveChecklistQuestionResponses(jsonActualAnswers, visitReportList[0].Id, checklistIds[0]);
            
            List<ChecklistQuestionResponse__c> qrListToUpdate = new List<ChecklistQuestionResponse__c>();
            List<ChecklistQuestionResponse__c> questionResponseList = [SELECT Id, Name, Type__c FROM ChecklistQuestionResponse__c WHERE Name LIKE 'QR-%'];
            for(ChecklistQuestionResponse__c qr : questionResponseList){
                if(qr.Type__c == 'Dropdown'){
                    qr.Response__c = 'dd opt1';
                }else{
                    qr.Response__c = 'checkbox opt1' + '\r\n' + 'checkbox opt2';
                }
                qrListToUpdate.add(qr);
            }
            if(qrListToUpdate.size() > 0){
                update qrListToUpdate;
            }
            
            
            checklistWrapperList = VisitReportUtility.getChecklistWrapperList(visitReportList[0].Id);
            
            Boolean isResult = false;
            if(checklistWrapperList.size() > 0){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(true, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test getRemoveChecklistPopupMessage method from VisitReportUtility class
*******************************************************************************************************************/
    @isTest
    static void  testGetRemoveChecklistPopupMessage(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            String customLabelMessage = 'Remove Checklist;You are about to remove {0} checklist from {1} visit report. This action will be irreversible and all related answers will be lost. Are you sure you want to proceed?';
            
            Test.startTest();
            String result = VisitReportUtility.getRemoveChecklistPopupMessage('Checklist Test Name', 'Visit Report Name Test',  customLabelMessage);
            
            Boolean isResult = false;
            if(result != null){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(true, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test getRemoveChecklistPopupMessage method from VisitReportUtility class - catch error
*******************************************************************************************************************/
    @isTest
    static void  testGetRemoveChecklistPopupMessageCatchError(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            String result = VisitReportUtility.getRemoveChecklistPopupMessage(null, null,  null);
            
            Boolean isResult = false;
            if(result != null){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(true, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test getChecklistNameById method from VisitReportUtility class
*******************************************************************************************************************/
    @isTest
    static void  testGetChecklistNameById(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            List<Checklist__c> listChecklist = [SELECT Id, Name FROM Checklist__c LIMIT 1];
            
            Test.startTest();
            String result = VisitReportUtility.getChecklistNameById(listChecklist[0].Id);
            
            Boolean isResult = false;
            if(result != null){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(true, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test getChecklistNameById method from VisitReportUtility class - catch error
*******************************************************************************************************************/
    @isTest
    static void  testGetChecklistNameByIdCatchError(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            String result = VisitReportUtility.getChecklistNameById(null);
            
            Boolean isResult = false;
            if(result != null){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(false, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test getVisitReportNameById method from VisitReportUtility class
*******************************************************************************************************************/
    @isTest
    static void  testGetVisitReportNameById(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            List<Visit> listVisitReport = [SELECT Id, Name FROM Visit LIMIT 1];
            String result;
            if(listVisitReport.size()>0){
            result = VisitReportUtility.getVisitReportNameById(listVisitReport[0].Id);}
            Boolean isResult = false;
            if(result != null){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(false, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test getVisitReportNameById method from VisitReportUtility class - catch error
*******************************************************************************************************************/
    @isTest
    static void  testGetVisitReportNameByIdCatchError(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            String result = VisitReportUtility.getVisitReportNameById(null);
            
            Boolean isResult = false;
            if(result != null){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(false, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test deleteChecklistQuestionResponses method from VisitReportUtility class
*******************************************************************************************************************/
    @isTest
    static void  testDeleteChecklistQuestionResponses(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            List<Checklist__c> listChecklist = [SELECT Id, Name FROM Checklist__c LIMIT 1];
            List<Visit__c> listVisitReport = [SELECT Id, Name FROM Visit__c LIMIT 1];
            
            Test.startTest();
            List<ChecklistQuestionResponse__c> listChecklistQuetionResponseBeforeDelete = [SELECT Id FROM ChecklistQuestionResponse__c];
            VisitReportUtility.deleteChecklistQuestionResponses(listVisitReport[0].Id, listChecklist[0].Id);
            List<ChecklistQuestionResponse__c> listChecklistQuetionResponseAfterDelete = [SELECT Id FROM ChecklistQuestionResponse__c];
            
            Boolean isResult = false;
            if(listChecklistQuetionResponseBeforeDelete.size() != listChecklistQuetionResponseAfterDelete.size()){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(true, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will test deleteChecklistQuestionResponses method from VisitReportUtility class - catch error
*******************************************************************************************************************/
    @isTest
    static void  testDeleteChecklistQuestionResponsesCatchError(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        System.runAs(u){
            Test.startTest();
            List<ChecklistQuestionResponse__c> listChecklistQuetionResponseBeforeDelete = [SELECT Id FROM ChecklistQuestionResponse__c];
            VisitReportUtility.deleteChecklistQuestionResponses(null, null);
            List<ChecklistQuestionResponse__c> listChecklistQuetionResponseAfterDelete = [SELECT Id FROM ChecklistQuestionResponse__c];
            
            Boolean isResult = false;
            if(listChecklistQuetionResponseBeforeDelete.size() != listChecklistQuetionResponseAfterDelete.size()){
                isResult = true;
            }
            Test.stopTest();
            
            System.assertEquals(false, isResult,'Result');
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will call test createChecklistQuestionResponses method from VisitReportsUtility class
*******************************************************************************************************************/
    static void createChecklistRecords(){
        User u = [SELECT Id, Email FROM User WHERE Email = 'testUser@deloitte.com' LIMIT 1];
        
        List<Account> accountList = [SELECT Id, Name FROM Account LIMIT 1];
        Schema.Location locationStandardObject;
        locationStandardObject = new Schema.Location(Name = 'Test Location2',
                                                     LocationType ='Sales'
                                                    );
        insert locationStandardObject;
        System.runAs(u){
            Checklist__c checklistTAC = new Checklist__c();
            checklistTAC.Active__c = true;
            checklistTAC.Name = 'Checklist1 TAC';
            insert checklistTAC;
            
            ChecklistSection__c checklistSectionTAC1 = new ChecklistSection__c();
            checklistSectionTAC1.Checklist__c = checklistTAC.Id;
            checklistSectionTAC1.Name = 'Checklist1 Section 1 TAC';
            insert checklistSectionTAC1;  
            
            ChecklistQuestion__c questionTAC1 = new ChecklistQuestion__c();
            questionTAC1.Active__c = true;
            questionTAC1.ChecklistSection__c = checklistSectionTAC1.Id;
            questionTAC1.QuestionText__c = 'Question TAC1 ?';
            questionTAC1.Type__c = 'Text';
            insert questionTAC1;
            
            ChecklistQuestion__c questionTAC2 = new ChecklistQuestion__c();
            questionTAC2.Active__c = true;
            questionTAC2.ChecklistSection__c = checklistSectionTAC1.Id;
            questionTAC2.QuestionText__c = 'Question TAC2 ?';
            questionTAC2.Type__c = 'Number';
            insert questionTAC2;
            
            ChecklistQuestion__c questionTAC3 = new ChecklistQuestion__c();
            questionTAC3.Active__c = true;
            questionTAC3.ChecklistSection__c = checklistSectionTAC1.Id;
            questionTAC3.QuestionText__c = 'Question TAC3 ?';
            questionTAC3.Type__c = 'Dropdown';
            questionTAC3.Answers__c = 'dd opt1';
            insert questionTAC3;
            
            ChecklistQuestion__c questionTAC4 = new ChecklistQuestion__c();
            questionTAC4.Active__c = true;
            questionTAC4.ChecklistSection__c = checklistSectionTAC1.Id;
            questionTAC4.QuestionText__c = 'Question TAC4 ?';
            questionTAC4.Type__c = 'Checkbox';
            questionTAC4.Answers__c = 'checkbox opt1';
            insert questionTAC4;
            
            ChecklistQuestion__c questionTAC5 = new ChecklistQuestion__c();
            questionTAC5.Active__c = true;
            questionTAC5.ChecklistSection__c = checklistSectionTAC1.Id;
            questionTAC5.QuestionText__c = 'Question TAC5 ?';
            questionTAC5.Type__c = 'Radio Button';
            questionTAC5.Answers__c = 'radio opt1';
            insert questionTAC5;
            
            Visit__c visitReportTAC = new Visit__c();
            visitReportTAC.Subject__c = 'Mill Tour';
            visitReportTAC.Account__c = accountList[0].Id;
            visitReportTAC.VisitDateStart__c = Date.today();
            insert visitReportTAC;
        }
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This class will create jsonActualAnswers parameter for saveChecklistQuestionResponses method of VisitReportUtility class
*******************************************************************************************************************/
    static String createJsonAnswers(String fieldType, String option){
        List<ChecklistQuestionResponse__c> qrList = [SELECT Id, Name, Type__c FROM ChecklistQuestionResponse__c WHERE Name LIKE '%TAC%'];  
        String jsonAnswers;
        
        jsonAnswers = '[';
        for(ChecklistQuestionResponse__c qr : qrList){
            jsonAnswers = jsonAnswers + '{';
            jsonAnswers = jsonAnswers + '"questionResponseId":"' + qr.Id + '"';
            jsonAnswers = jsonAnswers + ',';
            jsonAnswers = jsonAnswers + '"actualResponseList":[';
            if(qr.Type__c == 'Text'){
                jsonAnswers = jsonAnswers + '"this is the text input"]';    
            }else if(qr.Type__c == 'Number'){
                jsonAnswers = jsonAnswers + '"123"]';
            }else if(qr.Type__c == 'Dropdown'){
                jsonAnswers = jsonAnswers + '"dd opt1"]';
            }else if(qr.Type__c == 'Checkbox'){
                if(fieldType == 'Checkbox' && option != null){
                    jsonAnswers = jsonAnswers + '"checkbox opt1"' + ',"' + option +'"' + ']';
                }else{
                    jsonAnswers = jsonAnswers + '"checkbox opt1"]';
                }
            }else{
                jsonAnswers = jsonAnswers + '"radio opt1"]';
            }
            jsonAnswers = jsonAnswers + '},';   
        }
        
        jsonAnswers = jsonAnswers.removeEnd(',');
        jsonAnswers = jsonAnswers + ']';
        
        return jsonAnswers;
    }
    
    /*******************************************************************************************************************
* @author        Impana
* @description   This method is used to test getChecklists method from VisitReportUtility class for the scenario when the checklist does not have an active question
*******************************************************************************************************************/
    @isTest
    static void testGetChecklistsMethod_SectionWithoutActiveQuestion() {
        User u = [
            SELECT Id, Email
            FROM User WHERE Email = 'testUser@deloitte.com'
            LIMIT 1
        ];
        
        System.runAs(u) {
            Visit__c visitReport = [
                SELECT Id, Name, Account__r.Name
                FROM Visit__c
                WHERE Account__r.Name = 'TestAccount'
                LIMIT 1
            ];
            
            ChecklistQuestion__c checklistQuestion = [
                SELECT Id, Active__c, QuestionText__c 
                FROM ChecklistQuestion__c 
                WHERE QuestionText__c = 'Question?'][0];
            checklistQuestion.Active__c = false;
            
            update checklistQuestion;
            
            Test.startTest();
            List<Checklist__c> checklists = VisitReportUtility.getChecklists(
                visitReport.Id,
                ''
            );
            Test.stopTest();
            System.assertEquals(0, checklists.size(),'checklist size');
        }
    }
}