/****************************************************************************
* Name: ConstantClass
* Author: Naina Butle
* Test Class: 
* Created Date: 18/08/2022
* Description: Initializing constant
*****************************************************************************
* Modification log
* Developer Name	Date of Modification	Modification Description  
* Naina Butle       14/11/2022               added FINALCHECK_STAGENAME,COMPLETE_STATUS
* Priyanka 			30/11/2022				added TECHREQEXCEPTIONERROR_MSG
* Naina Butle       08/12/2022              added INTERGRATION_PROFILE,SYSTEMADMIN_PROFILE
* Monika Kadam      13/01/2023			added OLIDELETEEXCEPTIONERROR_MSG 
****************************************************************************/

public class ConstantClass {
    
    public static final String ACCOUNT_OBJECT = 'Account';
    public static final String OPPORTUNITY_OBJECT = 'Opportunity';
    public static final String CHANNELDISCLASS_ERROR = 'Insert/Update Channel Of Distribution on Opportunity';
    public static final String SALESREPRESENTIVE = 'ZM';
    public static final String ACCOUNTMANAGER = 'ZK';
    public static final String QUALITYREP = 'ZS';
    public static final String OPPORTUNITYLINEITEM_OBJECT = 'Opportunity Line Item';
    public static final String FINALCHECK_STAGENAME = 'Final Check';
    public static final String COMPLETE_STATUS = 'Complete';
    public static final String OLIEXCEPTIONERROR_MSG = 'Convert Technical Requirement to New Opportunity Line Item' ;
    public static final String FMNSPECIFIED_FINDERSTATUS = 'FMN specified on Position';
    public static final String SUCCESS = 'Success';
    public static final String APEX_CLASS = 'Apex class';
    public static final String FETCHCOP = 'Fetching CoP';
    public static final String UPDATECOP = 'Update on CoP';
    public static final String UPDATEFINALPRICE = 'Update Final Price';

    public static final String CONVERTOLIERROR_MSG = 'Please update the Stage as Final Check';
    public static final String TRRECORDTYPENAME = 'Technical Requirement';
    public static final String TRLIGHTRECORDTYPENAME = 'Technical Requirement Light';
    

    //US-0931
    public static final String INTERGRATION_PROFILE = 'Salesforce API Only System Integrations';
    public static final String SYSTEMADMIN_PROFILE = 'System Administrator';
    public static final String SYSTEMADMIN_PROFILEGERMAN = 'Systemadministrator';
    
    // US-1679
    public static final String PricebookStandard = 'Standard Price Book';

    
    //US-216 Start
    public static final String TECHREQUIREMENT_OBJECT = 'TechnicalRequirement__c';   
    public static final String NOMATCHINGSTEEL_FINDERSTATUS = 'No matching steel grade found. Reach out to Controlling.';
    public static final String REACHOUTTOCON_FINDERSTATUS = 'Inductive heat treatment. Reach out to Controlling.';
    public static final String PRICEINDICATOR_FINDERSTATUS = 'New combination of steel grade and rolling mill/further processing created. Only use as price indicator';
    public static final String MATCHINGFMN_FINDERSTATUS = 'Matching FMN found';
    
    //US-698 Start :
    public static final String ACCTEAMMEMBER_OBJECT = 'AccountTeamMember';
    public static final String ACCTEAMMEMTRIGGER_ERROR = 'Getting Error while Inserting/Updating Account Team Member';
    
    //US-740 Start :
    public static final String RAWMATERIAL_OBJECT = 'Raw Material';
    public static final String RAWMATERIALEXCEPTIONERROR_MSG = 'Sending Raw Material Data To Heroku';
    //US-0811


    public static final String TECHREQEXCEPTIONERROR_MSG = 'Updating Technical Offer Field on Technical Requirement';

    
    //US-0873
    public static final String OLIHELPEREXCEPTIONERROR_MSG = 'Updating Commercial Offer Field on OLI';
    
       
    public static final String ORG_WIDE_INFO = 'Org Wide Info';
    
    //US-3011
    public static final String CUSTOMER_PORTAL_USER = 'Customer Portal User';
    public static final String MANAGE_CUSTOMER_PORTAL_PERMISSION = 'Manage_Customer_Portal_Role';
    
    //US-0873
    public static final String OLI_LANGUAGE = 'DE';
    
    //815
    public static final String SAG_QUALITY_PROFILE = 'SAG Quality Profile';
    
    //1154
    public static final String SAG_MARKETING_PROFILE = 'SAG Marketing Profile';
    public static final String SHS_ADMIN = 'SHS Admin';
    public static final String SAG_SALES_PROFILE = 'SAG Sales';
    public static final String PRODUCTION_KEY_TYPE = 'Production Key';
    public static final List<String> POSITIONS_FOR_SALES = new List<String>{'PrimRollingHomogenize', 'PrimRollingInputformat', 'HZVSampletest', 'HZVCheckOrTreatment','HZVAnnealing', 'Homogenize', 'HeatTreatment', 'StraighteningOrSurfaceTreat', 'PeelingBarOrWireRod', 'InspecSurfacedefectinspec', 'InspecUSInspection'};
    //1367
     public static final String OLIDELETEEXCEPTIONERROR_MSG = 'Error in deleting the OLIs of inactive TR';
    // 411
    public static final String QUALITYCHECK_STAGENAME = 'Quality Check';
    public static final String OFFERED_STATUS = 'Offered';
    //2002
    public static final String OPPORTUNITY_PI_RECORDTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('PriceIndicationwithoutquote').getRecordTypeId();
    public static final String TRLIGHT_RECORDTYPE = Schema.SObjectType.TechnicalRequirement__c.getRecordTypeInfosByDeveloperName().get('TechnicalRequirementLight').getRecordTypeId();
    public static final String OPEN_STAGENAME='Open';
    
    //2396
    public static final String SALESPALNNING_OBJECT = 'SalesPlanning__c';
    public static final String SALESPALNNING_ERROR = 'Getting Error while Inserting/Updating SalesPlanning';
    
    //US-563
    public static final String SAG_SALES_USER_PERMISSION = 'SAGSalesUserPermission';
    
    //6993
    public static final String DATANOTFOUND = 'data not found';
    public static final String INPUTNOTFOUND = 'input not found';
  
    //5121
    public static final String Negotiation_StageName  = 'Negotiation';

    //4911
    public static final String DH_MARKETING_PROFILE = 'DH Marketing Profile';
    public static final String DH_SALES_PROFILE = 'DH Sales Profile';

    //7428
    public static final String QWACCOUNTMANAGER  = 'ZQ'; 

    //7210
     public static final String PRAKULA_OBJECT = 'Praekula__c';
     public static final String PRAKULATRIGGER_ERROR = 'Getting Error while Inserting/Updating Prakula';

    //5630
     public static final String VISIT_OBJECT = 'Visit__c'; 
     public static final String VISITREPORTUTI_ERROR = 'Getting Error in  VisitReportUtility class'; 

     //8965
     public static final String DELIVERYINSTRUCTIONS_OBJECT = 'DeliveryInstructions__c';
     public static final String CREATDOCGEN_ERROR = 'Getting Error while creating DocumentGeneration';
    
    //8308
    public static final String QUOTE_OBJECT = 'Quote';
    public static final String QUOTEPDF_ERROR = 'Getting Error while Quote PDF Generation';
    public static final String QUOTE_DOC_NAME_EN = 'Quote PDF Server Side EN';

     //5326
     public static final String SYSTEMADMINS_QUEUE = 'SystemAdmins';
     public static final String QUEUE = 'Queue';
     public static final String USER_REG_RECORDTYPE = 'Userregistration';
     public static final String DH_CUSTOMER_PORTALACCESS_PERMISSION = 'DHCustomerPortalAccess';
     public static final String DH_CUSTOMER_COMMUNITY_USER = 'DH Customer Community Plus Login User';
     public static final String SCHEDULEUSERNAMECLASS = 'ScheduleUsernameUpdate Class';
     public static final String DH_CUSTOMER_RESTRICTED_USER = 'DH Customer Restricted Portal Access';
     public static final String USER_OBJECT = 'User';

}
