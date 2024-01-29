/********************************************************************************************************
* @author         Harshitha Udaykumar
* @description    Utility class including all the constants used by the different Apex classes
* @date           2023-11-02
*********************************************************************************************************/
public With Sharing class GlobalConstantClass { 
    
    /*************************************** GENERIC CONSTANTS ******************************************************/
    public static final String PRICE_GROUP_EXTERNAL_ID = 'grid';

    /*************************************** SOBJECT CONSTANTS ******************************************************/  
    public static final String INTEGRATION_MESSAGE_STATUS_PENDING = 'Pending';
    public static final String INTEGRATION_MESSAGE_STATUS_PROCESSING = 'Processing';
    public static final String INTEGRATION_MESSAGE_STATUS_FAILED = 'Failed';
    public static final String INTEGRATION_MESSAGE_STATUS_SUCCESS = 'Success';
    // Sales Agreement
    public static final String SALES_AGREEMENT_STATUS_ACTIVATED = 'Activated';
    public static final String SALES_AGREEMENT_STATUS_UNDERREVISION = 'UnderRevision';
    public static final String SALES_AGREEMENT_STATUS_REJECTED = 'Rejected';
    public static final String SALES_AGREEMENT_STATUS_EXPIRED = 'Expired';
    public static final String SALES_AGREEMENT_STATUS_CANCELLED = 'Cancelled';
    // CC Price Group
    public static final String PRICE_GROUP_GROUP_TYPE_CONTRACT = 'Contract';
    // CC Featured Product
    public static final String FEATURED_PRODUCT_TYPE = 'Featured';
    public static boolean activateCCLogs = false;
    public static string ccLogName = '';
    // Default Delivery Method
    public static final String DEFAULT_DELIVERY_METHOD = 'Default Delivery Method';

    //Account Planning
    public static final String ACCOUNT_PLANNING_MANAGE_DECISION_MAKERS = 'Manage_Decision_Makers';
    public static final String ACCOUNT_PLANNING_MANAGE_MILESTONES = 'Manage_Milestones';
    public static final String ACCOUNT_PLANNING_MANAGE_PRODUCTS = 'Manage_Products';
    public static final String OPEN_STATUS = 'Open';
    public static final String COMPLETED_STATUS = 'Completed';
    public static final String ASC_SORTING_CRITERIA = 'C4MC_Chronological_order';

    @TestVisible
    private static string OrgNS;

    /********************************************************************************************************
    * @author           Deloitte
    * @description      This property will return the Org Namespace (OrgNS).
    *********************************************************************************************************/
    public static string OrgNamespace {
        get {
            if (OrgNS == null) {
                string className = GlobalConstantClass.class.getName();
                OrgNS = (className.contains('.')) ? className.substringBefore('.') : '';
            }
            return OrgNS;
        }
    }

    /********************************************************************************************************
    * @author           Deloitte
    * @description      This will return the Org Namespace (OrgNS).
    * @param            String objectName
    * @return           String
    *********************************************************************************************************/
    public static String getQualifiedAPIName(String objectName) {
        String ns = OrgNamespace;
        if(ns == '') {
            return objectName;
        }
        else {
            return ns + '__' + objectName;
        }
    }

    /********************************************************************************************************
    * @author           Deloitte
    * @description      This will return the Org Local.
    * @param            NULL
    * @return           String
    *********************************************************************************************************/
    @AuraEnabled
    public Static String getOrgLocal(){
        return [SELECT Id, TimeZoneSidKey FROM Organization LIMIT 1].TimeZoneSidKey;
    }

    /********************************************************************************************************
    * @author           Deloitte
    * @description      This will return the Org Namespace (OrgNS).
    * @param            String objName, String op, List<String> fieldNames
    * @return           boolean
    *********************************************************************************************************/
    public static boolean chkAccess(String objName, String op, List<String> fieldNames) {
        String UptObjName;
        if(objName.contains('__c')){
            UptObjName = getQualifiedAPIName(objName);
        }else{
            UptObjName = objName;
        }
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(UptObjName);
        Schema.DescribeSObjectResult objDesc = sobjType.getDescribe();
        //CRUD on object
        if ((op == 'Creating' && !objDesc.isCreateable()) || (op == 'Updating' &&!objDesc.isUpdateable())) {
                 return false;
           } else if ((op == 'Reading' && !objDesc.isAccessible())) {
                return false;
            } else if ((op == 'Deleting' && !objDesc.isDeletable())) {
                return false;
            }
        //CRUD on fields if the object passes the check above
        Map<String, Schema.SObjectField> fieldNameMetaMap = objDesc.fields.getMap();
        sObjectField field;
        Schema.DescribeFieldResult fieldDesc;
        if (fieldNames.size() > 0 && fieldNames != null) {
            for (String fieldName : fieldNames) {
                String updtFieldName;
                If(fieldName.contains('__c')){
                    updtFieldName = getQualifiedAPIName(fieldName);
                }else{
                    updtFieldName = fieldName;
                }
                if(fieldNameMetaMap.containsKey(updtFieldName)){
                field = fieldNameMetaMap.get(updtFieldName);
                fieldDesc = field.getDescribe();
                // ignore system fields that can't have permissions
                if (fieldDesc.isPermissionable()) {
                    if ((op == 'Creating' && !fieldDesc.isCreateable())
                        || (op == 'Updating' && !fieldDesc.isUpdateable())) {
                            return false;
                        } else if ((op == 'Reading' || op == 'Deleting') && !fieldDesc.isAccessible()) {
                            return false;
                        }
                }
            }
            }
        }

        return true;
    }
}