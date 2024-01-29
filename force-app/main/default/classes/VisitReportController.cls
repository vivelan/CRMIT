/****************************************************************************
* Name: VisitReportController
* Author: Harshitha U
* Created Date: 02/11/2023
* Description: VisitReportController class is used to process data related to Visit.
*****************************************************************************/
/*****************************************************************************
* Modification log
* Name              Date                    Description
* Developer Name    Date of Modification    Modification Description 
****************************************************************************/
public with sharing class VisitReportController {
  @TestVisible
  private static Boolean coverCode = false;
  /********************************************************************************************************
   * @author           Harshitha U
   * @description      This method will retrieve the record from Visitor Settings medatadata
   * @param            void
   * @return           Map<String, Boolean>
   *********************************************************************************************************/
  @AuraEnabled
  public static Map<String, Boolean> displayManageVisitReportTiles() {
    try {

      ManagingVisitReports__mdt visitReportSettings = VisitReportUtility.getVisitReportSettingsMetadata();

      Map<String, Boolean> mapManagingVisitReports = new Map<String, Boolean>();
      if (visitReportSettings != null) {
        mapManagingVisitReports.put(
          'Manage_Internal_Attendees',
          visitReportSettings.ManageInternalAttendees__c
        );

        mapManagingVisitReports.put(
          'Manage_External_Attendees',
          visitReportSettings.ManageExternalAttendees__c
        );

        mapManagingVisitReports.put(
          'Manage_Checklists',
          visitReportSettings.ManageChecklists__c
        );
      }

      return mapManagingVisitReports;
    } catch (Exception e) {
       String exdetails = e.getCause()+' ; '+e.getLineNumber() + ' ; '+e.getMessage()+' ; '+e.getStackTraceString()
                +' ; '+e.getTypeName() ;
       ExceptionUtilClass.publishException('Visit__c','Manage Visits',null,exdetails,ConstantClass.APEX_CLASS);
            
   
    }
    return null;
  }
    /********************************************************************************************************
   * @author           Harshitha U
   * @description      This method will return the information about 2 fields <ExtendedContactsasAttendees__c> and <ExtendUsersasAttendees__c> from Visitor Settings metadata
   * @return           Map<String, Boolean>
   *********************************************************************************************************/
  @AuraEnabled
  public static Map<String, Boolean> getExtendedFieldsValue() {

      ManagingVisitReports__mdt visitReportSettings = VisitReportUtility.getVisitReportSettingsMetadata();

      Map<String, Boolean> mapManagingVisitReports = new Map<String, Boolean>();
      if (visitReportSettings != null) {
        mapManagingVisitReports.put(
          'Extended_Contacts',
          visitReportSettings.ExtendedContactsasAttendees__c
        );

        mapManagingVisitReports.put(
          'Extended_Users',
          visitReportSettings.ExtendUsersasAttendees__c
        );
      }

      return mapManagingVisitReports;
  }

    /********************************************************************************************************
   * @author           Harshitha U
   * @description      This method is used to insert a list of attendees.
   * @param            String jsonInput, String vrId
   *********************************************************************************************************/
  @AuraEnabled
  public static void insertAttendees(String jsonInput, String vrId) {
            try {
      //Boolean isValidAttendee = GlobalConstantClass.chkAccess('Visitor', 'Creating', new List<String>{'VisitId', 'Contact__c', 'User__c', 'Comment__c', 'IsPrimaryContact__c'});
      //if(isValidAttendee) {  
        List<Map<String, String>> deserializedMap = new List<Map<String, String>>(
            (List<Map<String, String>>) JSON.deserialize(
              jsonInput,
              List<Map<String, String>>.class
            )
        );
        List<Visitor__c> attendeesList = new List<Visitor__c>();
        for(Map<String, String> attendeeMap : deserializedMap){
          Visitor__c attendee = new Visitor__c();
          attendee.Visit__c = vrId;
          if(attendeeMap.get('Account.Name') != null) {
            attendee.Contact__c = attendeeMap.get('Id');
            //attendee.AssigneeId = attendeeMap.get('Id');
          }
          else {
            attendee.User__c = attendeeMap.get('Id');
            //attendee.AssigneeId = attendeeMap.get('Id');
          }
          if(attendeeMap.get('detailedComment') != null && attendeeMap.get('detailedComment') != ''){
            attendee.Comment__c = attendeeMap.get('detailedComment');
          }
          /*if(attendeeMap.get('isPrimaryContact') != null && attendeeMap.get('isPrimaryContact') != ''){
            attendee.IsPrimaryContact__c = Boolean.valueOf(attendeeMap.get('isPrimaryContact'));
          }*/
          attendeesList.add(attendee);
        }
        if(attendeesList.size() > 0){
          insert attendeesList;
        }
      //}
    } catch (Exception e) {
        String exdetails = e.getCause()+' ; '+e.getLineNumber() + ' ; '+e.getMessage()+' ; '+e.getStackTraceString()
                +' ; '+e.getTypeName() ;
       ExceptionUtilClass.publishException('Visit__c','Manage Visits',null,exdetails,ConstantClass.APEX_CLASS);
    }
  }
}