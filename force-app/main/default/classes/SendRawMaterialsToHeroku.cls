/****************************************************************************
* Name: SendRawMaterialsToHeroku
* Author: Harshitha U
* Created Date: 09/11/2022
* Description: Class contains methods to send Raw Material data to Heroku.
*****************************************************************************/
/*****************************************************************************
* Modification log
* Name	SendRawMaterialsToHeroku	   Date	28/11/2022     Description
* Developer Name Harshitha U	Date of Modification 28/11/2022	Modification Description   
****************************************************************************/
public with sharing class SendRawMaterialsToHeroku {
    
    @InvocableMethod(label='SendRawMaterialsToHeroku' description='Sends Raw Material Data To Heroku')
    public static List<String> sendDataToHeroku(List<List<RawMaterial__c>> lstRawMaterial)
    {
        List<String> errormsg = new List<String>();
        List<RawMaterial__c> lstOfRawMaterial = new List<RawMaterial__c>();
        if(!lstRawMaterial.isEmpty())
            lstOfRawMaterial = lstRawMaterial.get(0);
        //------------------------------------------------------------
        List<RawMaterialData> requestlst = new List<RawMaterialData>();
        try{
            for(RawMaterial__c rawmaterial : lstOfRawMaterial)
            {   
                RawMaterialData rawMaterialdata = new RawMaterialData();
                rawMaterialdata.material_raw_id= rawmaterial.MaterialNumber__c;
                rawMaterialdata.price_point_1 = rawmaterial.TimePoint1__c;
                rawMaterialdata.price_point_2 = rawmaterial.TimePoint2__c;
                rawMaterialdata.price_point_3 = rawmaterial.TimePoint3__c;
                rawMaterialdata.price_point_4 = rawmaterial.TimePoint4__c;
                rawMaterialdata.price_point_5 = rawmaterial.TimePoint5__c;
                rawMaterialdata.price_point_6 = rawmaterial.TimePoint6__c;
                rawMaterialdata.price_point_7 = rawmaterial.TimePoint7__c;
                rawMaterialdata.price_point_8 = rawmaterial.TimePoint8__c;
                rawMaterialdata.price_point_9 = rawmaterial.TimePoint9__c;
                rawMaterialdata.price_point_10 = rawmaterial.TimePoint10__c;
                rawMaterialdata.price_point_11 = rawmaterial.TimePoint11__c;
                rawMaterialdata.price_point_12 = rawmaterial.TimePoint12__c;
                rawMaterialdata.price_point_13 = rawmaterial.TimePoint13__c;
                rawMaterialdata.price_point_14 = rawmaterial.TimePoint14__c;
                rawMaterialdata.price_point_15 = rawmaterial.TimePoint15__c;
                rawMaterialdata.price_point_16 = rawmaterial.TimePoint16__c;
                rawMaterialdata.price_point_17 = rawmaterial.TimePoint17__c;
                rawMaterialdata.price_point_18 = rawmaterial.TimePoint18__c;
                rawMaterialdata.category_1 = rawmaterial.RLevel1__c;
                rawMaterialdata.category_2 = rawmaterial.RLevel2__c;
                rawMaterialdata.category_3 = rawmaterial.RLevel3__c;
                rawMaterialdata.type = rawmaterial.Type__c;
                requestlst.add(rawMaterialdata);
            }
            String requestJSON = JSON.serialize(requestlst);
            errormsg = makePostCallout(requestJSON);
        }
        catch(Exception e){    
            String exdetails = e.getCause()+' ; '+e.getLineNumber() + ' ; '+e.getMessage()+' ; '+e.getStackTraceString()
                +' ; '+e.getTypeName() ;
            ExceptionUtilClass.publishException(ConstantClass.RAWMATERIAL_OBJECT,ConstantClass.RAWMATERIALEXCEPTIONERROR_MSG,'',exdetails,ConstantClass.APEX_CLASS);             
        }
        return errormsg;
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to make callout to Heroku to send the Raw Material data.
* Created Date: 09/11/2022
* Last Modified Date: 28/11/2022
****************************************************************************/
    public static List<String> makePostCallout(String requestbody) {
        List<RawMaterial__c> lstrawMaterialToUpdate =new List<RawMaterial__c>();
        List<String> errorlst = new List<String>();
        try{
            HttpRequest feedRequest = new HttpRequest();
            feedRequest.setMethod('POST');
            feedRequest.setEndpoint('callout:RawMaterial');
            feedRequest.setHeader('Content-Type', 'application/json');
            feedRequest.setBody(requestbody);
            Http http = new Http();
            HTTPResponse feedResponse = http.send(feedRequest);
            Boolean Issuccesful = false;
            if(feedResponse.getStatusCode()==200){
                
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(feedResponse.getBody()); 
                for(Object obj : results.values())
                {   
                    if(obj=='Success'){
                        Issuccesful = true;
                        break;
                    }
                }
                if(Issuccesful){
                   //-----US-3865---
                        OrgWideSettings__c orgWideSetting = OrgWideSettings__c.getValues(ConstantClass.ORG_WIDE_INFO);
                        orgWideSetting.Rawmateriallastupdatedon__c = System.today();
                        update orgWideSetting;
                  //---------------
                  List<RawMaterial__c> lstrawMaterialToDelete = [SELECT Id, Name, MaterialNumber__c FROM RawMaterial__c];
                  delete lstrawMaterialToDelete;
                }
            }
            else if(feedResponse.getStatusCode()==400)
            {   Map<String,String> mapofunsucessfulIDs = new Map<String,String>();
             Set<String> uniqueIds = new Set<String>();
             Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(feedResponse.getBody());
             String status = (String) results.get('status');
             List<Object> data = (List<Object>) results.get('data');
             for(Object obj : data) {
                 Map<String, Object> dataMap = (Map<String, Object>) obj;
                 String materialRawId = (String) dataMap.get('material_raw_id');
                 String materialtype = (String) dataMap.get('type');
                 //Decimal statusCode = (Decimal) dataMap.get('status_code');
                 String statusMessage = (String) dataMap.get('status_message');
                 mapofunsucessfulIDs.put(materialRawId+'-'+materialtype,statusMessage);
                 uniqueIds.add(materialRawId+'-'+materialtype);
             }
             String MaterialNumberName = 'MaterialNumber__c';
             String TypeName = 'Type__c';
             String query = 'SELECT Id, Name, ' + MaterialNumberName + ', ' + TypeName +
                 ' FROM RawMaterial__c WHERE ';
             
             if (!uniqueIds.isEmpty()) {
                 List<String> uniqueIdsList = new List<String>(uniqueIds);
                 String materialTypesClause = '';
                 for (Integer i = 0; i < uniqueIdsList.size(); i++) {
                     String[] ids = uniqueIdsList[i].split('-');
                     materialTypesClause += '( ' + MaterialNumberName + ' = \'' + ids[0] + '\' AND ' + TypeName + ' = \'' + ids[1] + '\' )';
                     if (i < uniqueIdsList.size() - 1) {
                         materialTypesClause += ' OR ';
                     }
                 }
                 query += ' (' + materialTypesClause + ')';
             }
             List<SObject> records = Database.query(query);
             for(SObject raw : records)
             {
                 if (raw instanceof RawMaterial__c) {
                     RawMaterial__c material = (RawMaterial__c) raw;
                     material.error__c = mapofunsucessfulIDs.get(material.MaterialNumber__c + '-' + material.Type__c);
                     lstrawMaterialToUpdate.add(material);
                 }
             }
             UPDATE lstrawMaterialToUpdate;
             if(status=='error')
                 errorlst.add(status);
            }  
        }
        catch(Exception e){
            //get exception details
            String exdetails = e.getCause()+' ; '+e.getLineNumber() + ' ; '+e.getMessage()+' ; '+e.getStackTraceString()
                +' ; '+e.getTypeName() ;
            errorlst.add(exdetails);
            ExceptionUtilClass.publishException(ConstantClass.RAWMATERIAL_OBJECT,ConstantClass.RAWMATERIALEXCEPTIONERROR_MSG,'',exdetails,ConstantClass.APEX_CLASS);
        }
        return errorlst;
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Wrapper class to store Raw Material Data
* Created Date: 09/11/2022
* Last Modified Date: 09/11/2022
****************************************************************************/
    public class RawMaterialData{
        public String material_raw_id;
        public String category_1;
        public String category_2;
        public String category_3;
        public Decimal price_point_1;
        public Decimal price_point_2;
        public Decimal price_point_3;
        public Decimal price_point_4;
        public Decimal price_point_5;
        public Decimal price_point_6;
        public Decimal price_point_7;
        public Decimal price_point_8;
        public Decimal price_point_9;
        public Decimal price_point_10;
        public Decimal price_point_11;
        public Decimal price_point_12;
        public Decimal price_point_13;
        public Decimal price_point_14;
        public Decimal price_point_15;
        public Decimal price_point_16;
        public Decimal price_point_17;
        public Decimal price_point_18;
        public String  type;
    }
    
}