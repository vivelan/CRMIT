/****************************************************************************
* Name: VisitReportUtility
* Author: Harshitha U
* Created Date: 02/11/2023
* Description: VisitReportsUtility class is used to process data related to Visit.
*****************************************************************************/
/*****************************************************************************
* Modification log
* Name              Date                    Description
* Developer Name    Date of Modification    Modification Description
****************************************************************************/
public with sharing class VisitReportUtility {
    @TestVisible 
    private static Boolean coverCode = false;
    @TestVisible
    public static List<ChecklistQuestionResponse__c> checklistQuestionResponseList = new List<ChecklistQuestionResponse__c>();
    @TestVisible
    public static List<Id> checklistList = new List<Id>();
    @TestVisible
    public static List<Checklist__c> checklistListFinal = new List<Checklist__c>();
    @TestVisible
    public static List<ChecklistQuestion__c> checklistQuestionList = new List<ChecklistQuestion__c>();
    @TestVisible
    public static List<ChecklistSection__c> checklistSectionList = new List<ChecklistSection__c>();
    @TestVisible
    public static Map<Id, List<String>> mapPossibleAnswers = new Map<Id, List<String>>();
    @TestVisible
    public static Map<Id,List<String>> mapActualResponses = new Map<Id,List<String>>();
    @TestVisible
    public static Map<Id, List<ChecklistSection__c>> mapChecklistAndChecklistSection = new Map<Id, List<ChecklistSection__c>>();
    @TestVisible
    public static Map<Id, Id> mapQuestionAndQuestionResponse = new Map<Id, Id>();
    @TestVisible
    public static Map<Id, List<ChecklistQuestionResponse__c>> mapChecklistSectionAndResponse = new Map<Id, List<ChecklistQuestionResponse__c>>();
    @TestVisible
    public static Map<Id, Visit__c> mapIdAndVisitReport = new Map<Id, Visit__c>();
    @TestVisible
    public static String emptyResponse = 'N/A';
    
/********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will get a list of Visitor related to the current Visit Report
* @param            string visitReportId
* @return           List <Visitor>
*********************************************************************************************************/
    @AuraEnabled
    public static List<Visitor__c> getRecords(
        string visitReportId
    ) {
        try {
            if (Test.isRunningTest() && coverCode) {
                CalloutException e = (CalloutException) CalloutException.class
                    .newInstance();
                e.setMessage('Error when fetching sales agreement id');
                throw e;
            }
            List<Visitor__c> vrAttendee = new List<Visitor__c>();
            if (visitReportId != null) {
                vrAttendee = [
                    SELECT Id, Name
                    FROM Visitor__c
                    WHERE Visit__c = :visitReportId
                    WITH SECURITY_ENFORCED
                ];
            }
            return vrAttendee;
        } catch (Exception e) {
            return null;
        }
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method is used to return a SObject List based on the given query
* @param            String query
* @return           List<SObject>
*********************************************************************************************************/
    @AuraEnabled
    public static List<SObject> getAttendees(String query) {
        SoqlQuery sQuery = (SoqlQuery) JSON.deserialize(query, SoqlQuery.class);
        string sql = String.format(
            'SELECT {0} FROM {1} ',
            new List<string>{ String.join(sQuery.fields, ','), sQuery.sObjectName }
        );
        if (String.isNotEmpty(sQuery.whereClause)) {
            sql += ' WHERE ' + sQuery.whereClause;
        }
        sql += ' WITH SECURITY_ENFORCED ';
        
        if (String.isNotEmpty(sQuery.orderbyClause)) {
            sql += ' ORDER BY ' + sQuery.orderbyClause;
        }
        
        if (String.isNotEmpty(sQuery.rowCount)) {
            sql += ' LIMIT ' + sQuery.rowCount;
        }
        
        try {
            if (Test.isRunningTest() && coverCode) {
                CalloutException e = (CalloutException) CalloutException.class
                    .newInstance();
                e.setMessage('Error');
                throw e;
            }
           String  strEsc = String.escapeSingleQuotes(sql); 
           String str = strEsc.remove('\\');
            return Database.query(str);
        } catch (Exception e) {
            return null;
        }
    }
/********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will get a list of active Checklists and which are not linked to the current visit report
* @param            String visitReportId, String searchKey
* @return           List <Checklist__c>
*********************************************************************************************************/
    @AuraEnabled
    public static List<Checklist__c> getChecklists(
        String visitReportId,
        String searchKey
    ) {
        List<Checklist__c> allChecklistList = new List<Checklist__c>();
        List<Id> allChecklistIdsList = new List<Id>();
        List<Checklist__c> checklistResult = new List<Checklist__c>();
        List<ChecklistQuestionResponse__c> checklistQuestionList = new List<ChecklistQuestionResponse__c>();
        List<Checklist__c> tempChecklistList = new List<Checklist__c>();
        Set<Id> checklistIds = new Set<Id>();
        
        List<Checklist__c> allChecklistUnfilteredList = new List<Checklist__c>();
        List<Id> allChecklistSectionUnfilteredIdsList = new List<Id>();
        List<ChecklistSection__c> allChecklistSectionUnfilteredList = new List<ChecklistSection__c>();
        List<Id> allChecklistFilteredIdsList = new List<Id>();
        
        try {
            if (Test.isRunningTest() && coverCode) {
                CalloutException e = (CalloutException) CalloutException.class
                    .newInstance();
                e.setMessage('Error when fetching sales agreement id');
                throw e;
            }
            
            allChecklistUnfilteredList = [SELECT Id, (SELECT Id FROM Checklist_Sections__r)
                                          FROM Checklist__c
                                          WHERE Active__c = TRUE
                                          WITH SECURITY_ENFORCED];
            
            for (Checklist__c checklistRecord : allChecklistUnfilteredList) {
                if (checklistRecord.Checklist_Sections__r.size() > 0) {
                    for (ChecklistSection__c checklistSectionRecord : checklistRecord.Checklist_Sections__r) {
                        allChecklistSectionUnfilteredIdsList.add(checklistSectionRecord.Id);
                    }
                }
            }
            allChecklistSectionUnfilteredList = [SELECT Id, Checklist__c, 
                                                 (SELECT Id FROM Checklist_Question_Templates__r WHERE Active__c = TRUE)
                                                 FROM ChecklistSection__c
                                                 WHERE Id IN: allChecklistSectionUnfilteredIdsList
                                                 WITH SECURITY_ENFORCED];
            
            Map<Id, List<ChecklistSection__c>> checklistSectionsByChecklistId = new Map<Id, List<ChecklistSection__c>>();
            for(ChecklistSection__c c : allChecklistSectionUnfilteredList) {
                if(!checklistSectionsByChecklistId.containsKey(c.Checklist__c)) {
                    checklistSectionsByChecklistId.put(c.Checklist__c, new List<ChecklistSection__c>());
                }
                checklistSectionsByChecklistId.get(c.Checklist__c).add(c);
            }
            
            for (Checklist__c checklistRecord : allChecklistUnfilteredList) {
                Boolean allChecklistSectionsHaveActiveQuestion = true;
                if(checklistSectionsByChecklistId.containsKey(checklistRecord.Id)) {
                    for(ChecklistSection__c checklistSectionRec : checklistSectionsByChecklistId.get(checklistRecord.Id)) {
                        if(checklistSectionRec.Checklist_Question_Templates__r.size() == 0) {
                            allChecklistSectionsHaveActiveQuestion = false;
                        }
                    }
                } else {
                    allChecklistSectionsHaveActiveQuestion = false;
                }
                if (allChecklistSectionsHaveActiveQuestion) {
                    allChecklistFilteredIdsList.add(checklistRecord.Id);
                }
            }
            User user = [SELECT ID, Profile.Name From User WHERE ID = :UserInfo.getUserId() LIMIT 1];
            allChecklistList = [
                SELECT Id, Name , Public__c,CreatedById
                FROM Checklist__c
                WHERE Id IN: allChecklistFilteredIdsList AND ( Public__c = true OR (Public__c = false AND CreatedById =: user.Id))
                WITH SECURITY_ENFORCED
                ORDER BY Name
            ];
            
            for (Checklist__c checklistRec : allChecklistList) {
                allChecklistIdsList.add(checklistRec.Id);
            }
            searchKey = String.escapeSingleQuotes(searchKey);
            String searchString = '%' + searchKey + '%';
            searchString = String.escapeSingleQuotes(searchString);
            if (visitReportId != null) {
                visitReportId = String.escapeSingleQuotes(visitReportId);
                checklistQuestionList = [
                    SELECT Id, Checklist__c
                    FROM ChecklistQuestionResponse__c
                    WHERE Visit__r.Id = :visitReportId
                    WITH SECURITY_ENFORCED
                ];
                
                for (
                    ChecklistQuestionResponse__c questionChecklist : checklistQuestionList
                ) {
                    checklistIds.add(questionChecklist.Checklist__c);
                }
                
                if (checklistQuestionList.size() == 0 && searchKey == '') {
                    return allChecklistList;
                } else if (checklistQuestionList.size() == 0 && searchKey != '') {
                    checklistResult = [
                        SELECT Id, Name
                        FROM Checklist__c
                        WHERE Id IN :allChecklistIdsList AND Name LIKE :searchString
                        WITH SECURITY_ENFORCED
                        ORDER BY Name
                    ];
                    return checklistResult;
                } else if (checklistQuestionList.size() > 0 && searchKey == '') {
                    checklistResult = [
                        SELECT Id, Name,Public__c,CreatedById
                        FROM Checklist__c
                        WHERE Id IN :checklistIds
                        WITH SECURITY_ENFORCED
                        ORDER BY Name
                    ];
                    for (Checklist__c checklist : allChecklistList) {
                        if (!checklistResult.contains(checklist)) {
                            tempChecklistList.add(checklist);
                        }
                    }
                    return tempChecklistList;
                    
                } else if (checklistQuestionList.size() > 0 && searchKey != '') {
                    checklistResult = [
                        SELECT Id, Name, Public__c,CreatedById
                        FROM Checklist__c
                        WHERE Id IN :checklistIds
                        WITH SECURITY_ENFORCED
                        ORDER BY Name
                    ];
                    for (Checklist__c checklist : allChecklistList) {
                        if (!checklistResult.contains(checklist)) {
                            tempChecklistList.add(checklist);
                        }
                    }
                    
                    List<Id> tempChecklistIds = new List<Id>();
                    for (Checklist__c checklistRecordd : tempChecklistList) {
                        tempChecklistIds.add(checklistRecordd.Id);
                    }
                    
                    List<Checklist__c> checklistResult2 = [
                        SELECT Id, Name,Public__c,CreatedById
                        FROM Checklist__c
                        WHERE Id IN :tempChecklistIds AND Name LIKE :searchString
                        WITH SECURITY_ENFORCED
                        ORDER BY Name
                    ];
                    return checklistResult2;
                }
            }
            return null;
        } catch (Exception e) {
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, visitReportId, exdetails, ConstantClass.APEX_CLASS);
            return null;
        }
    }
    
/********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method is used to delete a list of attendees
* @param            List<Id> attendeesIds
* @return           void
*********************************************************************************************************/
    @AuraEnabled
    public static void deleteAttendees(List<Id> attendeesIds) {
        try {
            if (Test.isRunningTest() && coverCode) {
                CalloutException e = (CalloutException) CalloutException.class
                    .newInstance();
                e.setMessage('Error when deleting attendees');
                throw e;
            }
            List<Visitor__c> vrAttendee = new List<Visitor__c>();
            if (attendeesIds.size() > 0) {
                vrAttendee = [
                    SELECT Id
                    FROM Visitor__c
                    WHERE Id IN :attendeesIds
                    WITH SECURITY_ENFORCED
                ];
            }
            
            Boolean isValid = GlobalConstantClass.chkAccess('Visitor__c', 'Deleting', new List<String>{'Id'});
            if(isValid) {
                delete vrAttendee;
            }
        } catch (Exception e) {
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, '', exdetails, ConstantClass.APEX_CLASS);
            
        }
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method is used to update a list of attendees
* @param            String jsonInput
* @return           void
*********************************************************************************************************/
    @AuraEnabled
    public static void updateAttendees(String jsonInput) {
        try {
            if (Test.isRunningTest() && coverCode) {
                CalloutException e = (CalloutException) CalloutException.class
                    .newInstance();
                e.setMessage('Error when fetching updating attendees');
                throw e;
            }
           // Boolean isValidVRUpdate = GlobalConstantClass.chkAccess('Visitor__c', 'Updating', new List<String>{'Id', 'Comment__c', 'IsPrimaryContact__c'});
              Boolean isValidVRUpdate = GlobalConstantClass.chkAccess('Visitor__c', 'Updating', new List<String>{'Id', 'Comment__c'});
            if (isValidVRUpdate) {
                List<Map<String, String>> deserializedMap = new List<Map<String, String>>(
                    (List<Map<String, String>>) JSON.deserialize(
                        jsonInput,
                        List<Map<String, String>>.class
                    )
                );
                List<String> listOfAttendeeIds = new List<String>();
                for (Integer i = 0; i < deserializedMap.size(); i++) {
                    listOfAttendeeIds.add(deserializedMap[i].get('Id'));
                }
                List<Visitor__c> vrAttendee = [
                    SELECT Id, Comment__c
                    FROM Visitor__c
                    WHERE Id IN :listOfAttendeeIds
                    WITH SECURITY_ENFORCED
                ];//, IsPrimaryContact__c
                for (Integer i = 0; i < deserializedMap.size(); i++) {
                    for (
                        Visitor__c visitReportAttendeeRec : vrAttendee
                    ) {
                        if (deserializedMap[i].get('Id') == visitReportAttendeeRec.Id) {
                            visitReportAttendeeRec.Comment__c = deserializedMap[i]
                                .get('Comment__c');
                           /* visitReportAttendeeRec.IsPrimaryContact__c = Boolean.valueOf(
                                deserializedMap[i].get('IsPrimaryContact__c')
                            );*/
                        }
                    }
                }
                update vrAttendee;
            }
        } catch (Exception e) {
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, '', exdetails, ConstantClass.APEX_CLASS);
        }
    }
/********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will retrieve a record from Cloud4M Visit Report Settings medatadata
* @param            void
* @return           ManagingVisitReports__mdt       
*********************************************************************************************************/
    @AuraEnabled
    public static ManagingVisitReports__mdt getVisitReportSettingsMetadata() {
        return ManagingVisitReports__mdt.getInstance('VisitReportSettings');
    }
    
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will create the list of Checklist Question Response created for the current Visit Report.
* @param            Id
* @return           void
*********************************************************************************************************/
    public static void createChecklistQuestionResponseList(Id visitReportId) {
        try {
            checklistQuestionResponseList = [
                SELECT
                Id,
                Name,
                Visit__c,
                Checklist__c,
                ChecklistQuestion__c,
                QuestionText__c,
                Answers__c,
                Response__c,
                Type__c
                FROM ChecklistQuestionResponse__c
                WHERE
                Visit__c = :String.escapeSingleQuotes(visitReportId)
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate ASC
            ];
        } catch (Exception e) {
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, visitReportId, exdetails, ConstantClass.APEX_CLASS);
        }
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will create the list of Checklist Ids based on checklistQuestionResponseList
* @param            Id
* @return           void
*********************************************************************************************************/
    public static void createChecklistList() {
        try {
            for (
                ChecklistQuestionResponse__c cqr : checklistQuestionResponseList
            ) {
                checklistList.add(cqr.Checklist__c);
            }
        } catch (Exception e) {
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, '', exdetails, ConstantClass.APEX_CLASS);
        }
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will create the list of Checklist records based on checklistList
* @param            -
* @return           void
*********************************************************************************************************/
    public static void createChecklistListFinal() {
        try {
            List<Checklist__c> tempFinalList = [
                SELECT ID, Name
                FROM Checklist__c
                WHERE Id IN :checklistList
                WITH SECURITY_ENFORCED
            ];
            Map<Id, Checklist__c> mapIdAndChecklist = new Map<Id, Checklist__c>();
            for (Checklist__c checklist : tempFinalList) {
                mapIdAndChecklist.put(checklist.Id, checklist);
            }
            for (Id checklistId : checklistList) {
                if (!checklistListFinal.contains(mapIdAndChecklist.get(checklistId))) {
                    checklistListFinal.add(mapIdAndChecklist.get(checklistId));
                }
            }
        } catch (Exception e) {
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, '', exdetails, ConstantClass.APEX_CLASS);
        }
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will create the list of Checklist Question records based on checklistQuestionResponseList
* @param            -
* @return           void
*********************************************************************************************************/
    public static void createChecklistQuestionList() {
        List<Id> tempChecklistQuestionList = new List<Id>();
        try {
            for (
                ChecklistQuestionResponse__c qr : checklistQuestionResponseList
            ) {
                tempChecklistQuestionList.add(qr.ChecklistQuestion__c);
            }
            
            checklistQuestionList = [
                SELECT Id, Name, ChecklistSection__c, Order__c
                FROM ChecklistQuestion__c
                WHERE Id IN :tempChecklistQuestionList
                WITH SECURITY_ENFORCED
                ORDER BY Order__c ASC
            ];
        } catch (Exception e) {
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, '', exdetails, ConstantClass.APEX_CLASS);
        }
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will create the list of Checklist Section records based on checklistList
* @param            -
* @return           void
*********************************************************************************************************/
    public static void createChecklistSectionList() {
        try {
            checklistSectionList = [
                SELECT Id, Name, Checklist__c, Order__c
                FROM ChecklistSection__c
                WHERE Checklist__c IN :checklistList
                WITH SECURITY_ENFORCED
                ORDER BY Order__c ASC
            ];
        } catch (Exception e) {
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, '', exdetails, ConstantClass.APEX_CLASS);
            
        }
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will create 2 maps: one map between ChecklistQuestion Response record ids and Answers field values and one map between ChecklistQuestion Response record ids and Response field values
* @param            -
* @return           void
*********************************************************************************************************/
    public static void createMapPossibleAnswersAndActualResponses() {
        List<String> actualResponsesList = new List<String>();
        try {
            for (ChecklistQuestionResponse__c qr : checklistQuestionResponseList) {
                if (qr.Answers__c != null) {
                    if(qr.Answers__c.contains('\r')){
                        mapPossibleAnswers.put(qr.Id, (qr.Answers__c).split('\r\n'));
                    }else{
                        mapPossibleAnswers.put(qr.Id, (qr.Answers__c).split('\n'));
                    }
                }
                if(qr.Type__c == 'Checkbox'){
                    if(qr.Response__c.contains('\r')){
                        mapActualResponses.put(qr.Id, (qr.Response__c).split('\r\n'));
                    }else{
                        mapActualResponses.put(qr.Id, (qr.Response__c).split('\n'));
                    }
                }else{
                    actualResponsesList = new List<String>();
                    actualResponsesList.add(qr.Response__c);
                    mapActualResponses.put(qr.Id, actualResponsesList);
                }
            }
        } catch (Exception e) {
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, '', exdetails, ConstantClass.APEX_CLASS);
        }
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will create a map between Checklist id and Cheklist Section records
* @param            -
* @return           void
*********************************************************************************************************/
    public static void createMapChecklistAndChecklistSection() {
        try {
            for (ChecklistSection__c cs : checklistSectionList) {
                if (mapChecklistAndChecklistSection.containsKey(cs.Checklist__c)) {
                    mapChecklistAndChecklistSection.get(cs.Checklist__c).add(cs);
                } else {
                    mapChecklistAndChecklistSection.put(
                        cs.Checklist__c,
                        new List<ChecklistSection__c>{ cs }
                    );
                }
            }
        } catch (Exception e) {
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, '', exdetails, ConstantClass.APEX_CLASS);
        }
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will create a map between Question and Question Response
* @param            -
* @return           void
*********************************************************************************************************/
    public static void createMapQuestionAndQuestionResponse() {
        try {
            for (
                ChecklistQuestionResponse__c qr : checklistQuestionResponseList
            ) {
                mapQuestionAndQuestionResponse.put(
                    qr.ChecklistQuestion__c,
                    qr.Id
                );
            }
        } catch (Exception e) {
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, '', exdetails, ConstantClass.APEX_CLASS);
        }
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will create a map between Checklist Section and Question Response
* @param            -
* @return           void
*********************************************************************************************************/
    public static void createMapChecklistSectionAndResponse() {
        try {
            Map<Id, ChecklistQuestionResponse__c> tempMapIdAndQuestionResponse = new Map<Id, ChecklistQuestionResponse__c>();
            for (
                ChecklistQuestionResponse__c qr : checklistQuestionResponseList
            ) {
                tempMapIdAndQuestionResponse.put(qr.Id, qr);
            }
            
            for (ChecklistQuestion__c cq : checklistQuestionList) {
                if (
                    mapChecklistSectionAndResponse.containsKey(
                        cq.ChecklistSection__c
                    )
                ) {
                    mapChecklistSectionAndResponse.get(cq.ChecklistSection__c)
                        .add(
                            tempMapIdAndQuestionResponse.get(
                                mapQuestionAndQuestionResponse.get(cq.Id)
                            )
                        );
                } else {
                    mapChecklistSectionAndResponse.put(
                        cq.ChecklistSection__c,
                        new List<ChecklistQuestionResponse__c>{
                            tempMapIdAndQuestionResponse.get(
                                mapQuestionAndQuestionResponse.get(cq.Id)
                            )
                                }
                    );
                }
            }
        } catch (Exception e) {
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, '', exdetails, ConstantClass.APEX_CLASS);
        }
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will gets the ChecklistWrapper list which will be returned to front-end
* @param            Id
* @return           List<ChecklistWrapper>
*********************************************************************************************************/
    @AuraEnabled
    public static List<ChecklistWrapper> getChecklistWrapperList(Id visitReportId) {
        List<ChecklistWrapper> checklistWrapperList = new List<ChecklistWrapper>();
        ChecklistWrapper checklistWrapper;
        List<ChecklistSectionWrapper> checklistSectionWrapperList;
        ChecklistSectionWrapper checklistSectionWrapper;
        List<ChecklistQuestionResponseWrapper> checklistQuestionResponseWrapperList;
        ChecklistQuestionResponseWrapper checklistQuestionResponseWrapper;
        List<ActualAnswerWrapper> actualAnswerWrapperList;
        ActualAnswerWrapper actualAnswerWrapper;
        List<CheckboxAndRadioQuestionResponseWrapper> checkboxAndRadioQuestionResponseWrapperList;
        CheckboxAndRadioQuestionResponseWrapper checkboxAndRadioQuestionResponseWrapper;
        
        List<ChecklistSection__c> tempChecklistSectionList;
        List<ChecklistQuestionResponse__c> tempChecklistQuestionResponseList;
        List<String> tempActualAnswersList;
        List<String> tempActualAnswersListWithoutEmpty;
        try {
            createChecklistQuestionResponseList(visitReportId);
            createChecklistList();
            createChecklistListFinal();
            createChecklistQuestionList();
            createChecklistSectionList();
            createMapPossibleAnswersAndActualResponses();
            createMapChecklistAndChecklistSection();
            createMapQuestionAndQuestionResponse();
            createMapChecklistSectionAndResponse();
            
            for (Checklist__c checklist : checklistListFinal) {
                checklistWrapper = new ChecklistWrapper();
                checklistWrapper.checklistId = checklist.Id;
                checklistWrapper.checklistName = checklist.Name;
                checklistWrapper.checklistSectionWrapperList = null;
                
                tempChecklistSectionList = new List<ChecklistSection__c>();
                tempChecklistSectionList = mapChecklistAndChecklistSection.get(checklist.Id);
                checklistSectionWrapperList = new List<ChecklistSectionWrapper>();
                for (ChecklistSection__c section : tempChecklistSectionList) {
                    checklistSectionWrapper = new ChecklistSectionWrapper();
                    checklistSectionWrapper.checklistSectionId = section.Id;
                    checklistSectionWrapper.checklistSectionName = section.Name;
                    checklistSectionWrapper.checklistQuestionResponseWrapperList = null;
                    
                    tempChecklistQuestionResponseList = new List<ChecklistQuestionResponse__c>();
                    tempChecklistQuestionResponseList = mapChecklistSectionAndResponse.get(section.Id);
                    checklistQuestionResponseWrapperList = new List<ChecklistQuestionResponseWrapper>();
                    for (ChecklistQuestionResponse__c questionResponse : tempChecklistQuestionResponseList) {
                        checklistQuestionResponseWrapper = new ChecklistQuestionResponseWrapper();
                        checklistQuestionResponseWrapper.checklistQuestionResponseId = questionResponse.Id;
                        checklistQuestionResponseWrapper.questionText = questionResponse.QuestionText__c;
                        checklistQuestionResponseWrapper.questionType = questionResponse.Type__c;
                        if (checklistQuestionResponseWrapper.questionType == 'Text') {
                            checklistQuestionResponseWrapper.typeIsText = true;
                            checklistQuestionResponseWrapper.typeIsNumber = false;
                            checklistQuestionResponseWrapper.typeIsDropdown = false;
                            checklistQuestionResponseWrapper.typeIsCheckbox = false;
                            checklistQuestionResponseWrapper.typeIsRadioButton = false;
                        } else if (checklistQuestionResponseWrapper.questionType == 'Number') {
                            checklistQuestionResponseWrapper.typeIsText = false;
                            checklistQuestionResponseWrapper.typeIsNumber = true;
                            checklistQuestionResponseWrapper.typeIsDropdown = false;
                            checklistQuestionResponseWrapper.typeIsCheckbox = false;
                            checklistQuestionResponseWrapper.typeIsRadioButton = false;
                        } else if (checklistQuestionResponseWrapper.questionType == 'Dropdown') {
                            checklistQuestionResponseWrapper.typeIsText = false;
                            checklistQuestionResponseWrapper.typeIsNumber = false;
                            checklistQuestionResponseWrapper.typeIsDropdown = true;
                            checklistQuestionResponseWrapper.typeIsCheckbox = false;
                            checklistQuestionResponseWrapper.typeIsRadioButton = false;
                        } else if (checklistQuestionResponseWrapper.questionType == 'Checkbox') {
                            checklistQuestionResponseWrapper.typeIsText = false;
                            checklistQuestionResponseWrapper.typeIsNumber = false;
                            checklistQuestionResponseWrapper.typeIsDropdown = false;
                            checklistQuestionResponseWrapper.typeIsCheckbox = true;
                            checklistQuestionResponseWrapper.typeIsRadioButton = false;
                        } else if (checklistQuestionResponseWrapper.questionType == 'Radio Button') {
                            checklistQuestionResponseWrapper.typeIsText = false;
                            checklistQuestionResponseWrapper.typeIsNumber = false;
                            checklistQuestionResponseWrapper.typeIsDropdown = false;
                            checklistQuestionResponseWrapper.typeIsCheckbox = false;
                            checklistQuestionResponseWrapper.typeIsRadioButton = true;
                        }
                        checklistQuestionResponseWrapper.answersList = mapPossibleAnswers.get(questionResponse.Id);
                        actualAnswerWrapperList = new List<ActualAnswerWrapper>();
                        checkboxAndRadioQuestionResponseWrapperList = new List<CheckboxAndRadioQuestionResponseWrapper>();
                        tempActualAnswersList = new List<String>();
                        tempActualAnswersList = mapActualResponses.get(questionResponse.Id);
                        if(questionResponse.Type__c == 'Dropdown'){
                            for(String possibleAnswer: checklistQuestionResponseWrapper.answersList){
                                actualAnswerWrapper = new ActualAnswerWrapper();
                                actualAnswerWrapper.answerText = possibleAnswer;
                                if(tempActualAnswersList.indexOf(possibleAnswer) > -1){
                                    if(possibleAnswer != emptyResponse){
                                        actualAnswerWrapper.isAnswerChecked = true;
                                    }else{
                                        actualAnswerWrapper.isAnswerNotChecked = true;
                                    }
                                }else{
                                    actualAnswerWrapper.isAnswerNotChecked = true;
                                }
                                actualAnswerWrapperList.add(actualAnswerWrapper);
                            }
                        }else if(questionResponse.Type__c == 'Text' || questionResponse.Type__c == 'Number'){
                            actualAnswerWrapper = new ActualAnswerWrapper();
                            actualAnswerWrapper.answerText = tempActualAnswersList[0];
                            if(tempActualAnswersList[0] != emptyResponse){
                                actualAnswerWrapper.isAnswerChecked = true;
                            }else{
                                actualAnswerWrapper.isAnswerNotChecked = true;
                            }
                            actualAnswerWrapperList.add(actualAnswerWrapper);
                        }else if(questionResponse.Type__c == 'Checkbox'){
                            for(String possibleAnswer: checklistQuestionResponseWrapper.answersList){
                                checkboxAndRadioQuestionResponseWrapper = new CheckboxAndRadioQuestionResponseWrapper();
                                checkboxAndRadioQuestionResponseWrapper.label = possibleAnswer;
                                checkboxAndRadioQuestionResponseWrapper.value = possibleAnswer;
                                checkboxAndRadioQuestionResponseWrapperList.add(checkboxAndRadioQuestionResponseWrapper);
                            }
                            checklistQuestionResponseWrapper.checkboxAndRadioQuestionResponseWrapperList = checkboxAndRadioQuestionResponseWrapperList;
                            if(tempActualAnswersList.indexOf(emptyResponse) > -1){
                                tempActualAnswersListWithoutEmpty = new List<String>();
                                for(String answer : tempActualAnswersList){
                                    if(answer != emptyResponse){
                                        tempActualAnswersListWithoutEmpty.add(answer);
                                    }
                                }
                                checklistQuestionResponseWrapper.checkboxSelectedValueList = tempActualAnswersListWithoutEmpty;
                            }else{
                                checklistQuestionResponseWrapper.checkboxSelectedValueList = tempActualAnswersList;
                            }
                        }else{
                            for(String possibleAnswer: checklistQuestionResponseWrapper.answersList){
                                checkboxAndRadioQuestionResponseWrapper = new CheckboxAndRadioQuestionResponseWrapper();
                                checkboxAndRadioQuestionResponseWrapper.label = possibleAnswer;
                                checkboxAndRadioQuestionResponseWrapper.value = possibleAnswer;
                                checkboxAndRadioQuestionResponseWrapperList.add(checkboxAndRadioQuestionResponseWrapper);
                            }
                            checklistQuestionResponseWrapper.checkboxAndRadioQuestionResponseWrapperList = checkboxAndRadioQuestionResponseWrapperList;
                            if(tempActualAnswersList[0] != emptyResponse){
                                checklistQuestionResponseWrapper.radioSelectedValue = tempActualAnswersList[0];
                            }else{
                                checklistQuestionResponseWrapper.radioSelectedValue = '';
                            }
                        }
                        checklistQuestionResponseWrapper.actualAnswerWrapperList = actualAnswerWrapperList;
                        checklistQuestionResponseWrapperList.add(checklistQuestionResponseWrapper);
                    }
                    checklistSectionWrapper.checklistQuestionResponseWrapperList = checklistQuestionResponseWrapperList;
                    checklistSectionWrapperList.add(checklistSectionWrapper);
                }
                checklistWrapper.checklistSectionWrapperList = checklistSectionWrapperList;
                checklistWrapperList.add(checklistWrapper);
            }
            return checklistWrapperList;
        } catch (Exception e) {
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, '', exdetails, ConstantClass.APEX_CLASS);
            return null;
        }
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will create a map between Visit Report Id and Visit `report record
* @param            -
* @return           void
*********************************************************************************************************/
    public static void createMapIdAndVisitReport() {
        try {
            if(Test.isRunningTest() && coverCode){
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                e.setMessage('Error');
                throw e;  
            }else{
                List<Visit__c> allVisitReportsList = [SELECT Id, Name FROM Visit__c WITH SECURITY_ENFORCED];
                for (Visit__c vr : allVisitReportsList) {
                    mapIdAndVisitReport.put(vr.Id, vr);
                }  
            } 
        } catch (Exception e) {
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, '', exdetails, ConstantClass.APEX_CLASS);
        }
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will create Checlists Question Response records based on VisitId and Checklist Ids
* @param            Id, List<Id>
* @return           void
*********************************************************************************************************/
    @AuraEnabled
    public static void createChecklistQuestionResponses(
        Id visitReportId,
        List<Id> checklistIds
    ) {
        List<ChecklistQuestionResponse__c> questionResponseList = new List<ChecklistQuestionResponse__c>();
        ChecklistQuestionResponse__c questionResponse;
        
        try {
            Boolean isValid = GlobalConstantClass.chkAccess(
                'ChecklistQuestionResponse__c',
                'Creating',
                new List<String>{ 'Name', 'Answers__c', 'Checklist__c', 'ChecklistQuestion__c', 'QuestionText__c', 'Response__c', 'Type__c', 'Order__c', 'Visit__c'}
            );
            if (isValid) {
                createMapIdAndVisitReport();
                List<ChecklistQuestion__c> questionList = [
                    SELECT
                    Id,
                    Name,
                    Active__c,
                    ChecklistSection__c,
                    ChecklistSection__r.Checklist__r.Id,
                    Answers__c,
                    QuestionText__c,
                    Type__c,
                    Order__c
                    FROM ChecklistQuestion__c
                    WHERE
                    Active__c = TRUE
                    AND ChecklistSection__r.Checklist__r.Id IN :checklistIds
                    AND ChecklistSection__r.Checklist__r.Active__c = TRUE
                    WITH SECURITY_ENFORCED
                ];
                for (ChecklistQuestion__c question : questionList) {
                    questionResponse = new ChecklistQuestionResponse__c();
                    questionResponse.Name =
                        'QR-' +
                        question.Name +
                        '-' +
                        mapIdAndVisitReport.get(visitReportId).Name;
                    questionResponse.Answers__c = question.Answers__c;
                    questionResponse.Checklist__c = question.ChecklistSection__r.Checklist__r.Id;
                    questionResponse.ChecklistQuestion__c = question.Id;
                    questionResponse.QuestionText__c = question.QuestionText__c;
                    questionResponse.Response__c = emptyResponse;
                    questionResponse.Type__c = question.Type__c;
                    questionResponse.Order__c = question.Order__c;
                    questionResponse.Visit__c = visitReportId;
                    questionResponseList.add(questionResponse);
                }
                insert questionResponseList;
            }
        } catch (Exception e) {
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, visitReportId, exdetails, ConstantClass.APEX_CLASS);
            
        }
    }
    
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will update Checklists Question Response records based on Checklist Question Response Id and the string input values
* @param            String 
* @return           void
*********************************************************************************************************/
    @AuraEnabled
    public static void saveChecklistQuestionResponses(String jsonActualAnswers, Id visitReportId, Id checklistId){
        Map<Id, List<String>> mapCurrentResponsesFromSystem = new Map<Id, List<String>>();
        Map<Id, List<String>> mapQuestionResponseAndAnswerToUpdate = new Map<Id, List<String>>(); 
        List<String> responseList;
        try{
            Boolean isValid = GlobalConstantClass.chkAccess('ChecklistQuestionResponse__c', 'Updating', new List<String>{'Id', 'Name', 'Type__c', 'Response__c' , 'Checklist__c'});
            if (isValid) {
                createChecklistQuestionResponseList(visitReportId);
                createMapPossibleAnswersAndActualResponses();
                
                mapCurrentResponsesFromSystem = mapActualResponses;
                
                List<UpdatedChecklistQuestionResponseWrapper> listMapQuestionResponseAndActualAnswer = new List<UpdatedChecklistQuestionResponseWrapper>((List<UpdatedChecklistQuestionResponseWrapper>) JSON.deserialize(jsonActualAnswers, List<UpdatedChecklistQuestionResponseWrapper>.class));
                Map<Id, List<String>> mapQuestionResponseAndActualAnswer = new Map<Id, List<String>>();
                for(UpdatedChecklistQuestionResponseWrapper cqr : listMapQuestionResponseAndActualAnswer){
                    mapQuestionResponseAndActualAnswer.put(cqr.questionResponseId, cqr.actualResponseList);
                }
                
                for(Id qrId : mapCurrentResponsesFromSystem.keySet()){
                    if(mapQuestionResponseAndActualAnswer.containsKey(qrId)){
                        mapQuestionResponseAndAnswerToUpdate.put(qrId, mapQuestionResponseAndActualAnswer.get(qrId));
                    }else{
                        responseList = new List<String>();
                        responseList.add(emptyResponse);
                        mapQuestionResponseAndAnswerToUpdate.put(qrId, responseList);
                    }
                }
                
                List<ChecklistQuestionResponse__c> currentChecklistQuestionResponseList = [SELECT Id, Name, Type__c, Response__c , Checklist__c
                                                                                           FROM  ChecklistQuestionResponse__c
                                                                                           WHERE Id IN: mapQuestionResponseAndAnswerToUpdate.keySet()
                                                                                           AND Checklist__c =: String.escapeSingleQuotes(checklistId)
                                                                                           WITH SECURITY_ENFORCED];
                
                List<ChecklistQuestionResponse__c> questionResponseListToUpdate = new List<ChecklistQuestionResponse__c>();
                ChecklistQuestionResponse__c questionResponseToUpdate;
                String actualResponseText;
                for(ChecklistQuestionResponse__c cqr : currentChecklistQuestionResponseList){
                    questionResponseToUpdate = new ChecklistQuestionResponse__c();
                    questionResponseToUpdate = cqr;
                    if(questionResponseToUpdate.Type__c == 'Checkbox'){
                        actualResponseText = '';
                        for(String actualResponse : mapQuestionResponseAndAnswerToUpdate.get(cqr.Id)){
                            actualResponseText = actualResponseText + actualResponse + '\n';
                        }
                        questionResponseToUpdate.Response__c = actualResponseText;
                    }else{
                        questionResponseToUpdate.Response__c = mapQuestionResponseAndAnswerToUpdate.get(cqr.Id)[0];
                    }
                    questionResponseListToUpdate.add(questionResponseToUpdate);
                }
                update questionResponseListToUpdate;
            }
        }catch(Exception e){
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, visitReportId, exdetails, ConstantClass.APEX_CLASS);
        }
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will return the dynamic remove checklist message based on received parameters and custom label
* @param            String, String, String
* @return           String
*********************************************************************************************************/
    @AuraEnabled (cacheable = true)
    public static String getRemoveChecklistPopupMessage(String checklistName, String visitReportName, String customLabelMessage){      
        String removeChecklistMessage;
        try{
            List<String> parameters = new List<String>();
            parameters.add(checklistName);
            parameters.add(visitReportName);
            String label = customLabelMessage;
            label = label.replace('\'', '\'\'');
            removeChecklistMessage = String.format(label, parameters);
            
        }catch(Exception e){
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, '', exdetails, ConstantClass.APEX_CLASS);
           removeChecklistMessage = exdetails;
        }
        return removeChecklistMessage;
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will return the Checklist Name using the Checklist Id
* @param            String
* @return           String
*********************************************************************************************************/
    @AuraEnabled (cacheable = true)
    public static String getChecklistNameById(String checklistId){   
        String checklistName;
        try{
            List<Checklist__c> checklistList= [SELECT Name FROM Checklist__c WHERE Id =: String.escapeSingleQuotes(checklistId) WITH SECURITY_ENFORCED];
            checklistName = checklistList[0].Name;
        }
        catch(Exception e){
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, '', exdetails, ConstantClass.APEX_CLASS);
        } 
        return checklistName; 
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method will return the Visit Report Name using the VisitId
* @param            String
* @return           String
*********************************************************************************************************/
    @AuraEnabled (cacheable = true)
    public static String getVisitReportNameById(String visitReportId){      
        String visitReportName;
        try{
            List<Visit__c> visitReportList= [SELECT Name FROM Visit__c WHERE Id =: String.escapeSingleQuotes(visitReportId) WITH SECURITY_ENFORCED];
            visitReportName = visitReportList[0].Name;
        }
        catch(Exception e){
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, visitReportId, exdetails, ConstantClass.APEX_CLASS);
        } 
        return visitReportName; 
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This method deletes the Checklist Question Responses records based on VisitId and Checklist Id
* @param            String, String
* @return           void
*********************************************************************************************************/
    @AuraEnabled
    public Static String deleteChecklistQuestionResponses(String visitReportId, String checklistId){      //5630
        try{
            List<ChecklistQuestionResponse__c> checklistQuestionResponseList = [SELECT Id, Name FROM ChecklistQuestionResponse__c WHERE Checklist__c =: String.escapeSingleQuotes(checklistId) AND Visit__c =: String.escapeSingleQuotes(visitReportId) WITH SECURITY_ENFORCED];
            
            Boolean isValid = GlobalConstantClass.chkAccess('ChecklistQuestionResponse__c', 'Deleting', new List<String>{'Id', 'Name', 'Checklist__c', 'Visit'});
            if(isValid) {
                delete checklistQuestionResponseList;
            }
            return 'success';
        }
        catch(Exception e){
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.VISIT_OBJECT, ConstantClass.VISITREPORTUTI_ERROR, visitReportId, exdetails, ConstantClass.APEX_CLASS);
           return exdetails;
        } 
    }

    public class SoqlQuery {
        public string sObjectName { get; set; }
        
        public List<string> fields { get; set; }
        
        public string whereClause { get; set; }
        
        public string rowCount { get; set; }
        
        public string orderbyClause { get; set; }
    }
/********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This class is used to create an object which will store all the needed information for Checklist.
* @date             2023-11-02
*********************************************************************************************************/
    public class ChecklistWrapper {
        @AuraEnabled
        public Id checklistId;
        @AuraEnabled
        public String checklistName;
        @AuraEnabled
        public List<ChecklistSectionWrapper> checklistSectionWrapperList;
    }
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This class is used to create an object which will store all the needed information for Checklist Section.
* @date             2023-11-02
*********************************************************************************************************/
    public class ChecklistSectionWrapper {
        @AuraEnabled
        public Id checklistSectionId;
        @AuraEnabled
        public String checklistSectionName;
        @AuraEnabled
        public List<ChecklistQuestionResponseWrapper> checklistQuestionResponseWrapperList;
    }
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This class is used to create an object which will store all the needed information for Checklist Question Response.
* @date             2023-11-02
*********************************************************************************************************/
    public class ChecklistQuestionResponseWrapper {
        @AuraEnabled
        public Id checklistQuestionResponseId;
        @AuraEnabled
        public String questionText;
        @AuraEnabled
        public String questionType;
        @AuraEnabled
        public Boolean typeIsText;
        @AuraEnabled
        public Boolean typeIsNumber;
        @AuraEnabled
        public Boolean typeIsDropdown;
        @AuraEnabled
        public Boolean typeIsCheckbox;
        @AuraEnabled
        public Boolean typeIsRadioButton;
        @AuraEnabled
        public List<String> answersList;
        @AuraEnabled
        public List<ActualAnswerWrapper> actualAnswerWrapperList;
        @AuraEnabled
        public List<String> checkboxSelectedValueList;
        @AuraEnabled
        public String radioSelectedValue;
        @AuraEnabled
        public List<CheckboxAndRadioQuestionResponseWrapper> checkboxAndRadioQuestionResponseWrapperList;
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This class is used to create an object which stores the question responses provided by user
* @date             2023-11-02
*********************************************************************************************************/
    public class ActualAnswerWrapper {
        @AuraEnabled
        public String answerText;
        @AuraEnabled
        public Boolean isAnswerChecked;
        @AuraEnabled
        public Boolean isAnswerNotChecked;
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This class is used to create an object containing the question responses updated
* @date             2023-11-02
*********************************************************************************************************/
    public class UpdatedChecklistQuestionResponseWrapper {
        @AuraEnabled
        public Id questionResponseId;
        @AuraEnabled
        public List<String> actualResponseList;
        
        public UpdatedChecklistQuestionResponseWrapper(Id questionResponseId, List<String> actualResponseList){
            this.questionResponseId = questionResponseId;
            this.actualResponseList = actualResponseList;
        }
        public UpdatedChecklistQuestionResponseWrapper(){
        }
    }
    
    /********************************************************************************************************
* @author           Harshitha Udaykumar
* @description      This class is used to create an object containing the question responses for radio and checkbox types
* @date             2023-11-02
*********************************************************************************************************/
    public class CheckboxAndRadioQuestionResponseWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
}