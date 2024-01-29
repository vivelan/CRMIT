/****************************************************************************
* Name: TechnicalRequirementHelper
* Author: Priyanka Kumari
* Created Date: 30/11/2022
* Description: Handler class for TechnicalRequirement Trigger
*****************************************************************************
* Modification log
* Name			Date	           	Description 
* Monika Kadam          13/1/2023		Added deleteOLI method
****************************************************************************/
public with sharing class TechnicalRequirementHelper {

    /***************************************************************************************************
     * Author Name: Priyanka Kumari
     * Description: Method to populate Technical Offer field value a technical requirement record before insert.
     * Created Date: 30/11/2022
     * Last Modified Date: 
     ****************************************************************************************************/
      public static void populateTechnicalOffer (List<TechnicalRequirement__c> newTechReq, Map<Id, TechnicalRequirement__c> oldtrMap) {
        Map<String, Map<String, String>> contentBlockMap = new Map<String, Map<String, String>>();
        List<String> exeptionList = new List<String>();
        try{
            for(ContentBlock__mdt cb : [SELECT Id, Language__c, PicklistValue__c, ContentText__c FROM ContentBlock__mdt]){
                if(!contentBlockMap.containsKey(cb.PicklistValue__c))
                    contentBlockMap.put(cb.PicklistValue__c, new Map<String, String>());
                Map<String, String> innerMap = contentBlockMap.get(cb.PicklistValue__c);
                innerMap.put(cb.Language__c, cb.ContentText__c);
            }
            for(TechnicalRequirement__c tr : newTechReq){
                List<String> pickListValuesList;
                if(TR.TextForSelectionQuality__c != null){ //1
                    pickListValuesList = TR.TextForSelectionQuality__c.split(';'); 
                    String tempTechOffer=''; 
                    String oldTechOffer ='';           
                    for(String plv : pickListValuesList){
                        Map<String, String> valuesToBeChecked;
                        valuesToBeChecked = contentBlockMap.get(plv);
                        if(oldTrMap != null && valuesToBeChecked != null  && oldTrMap.get(TR.ID).TextForSelectionQuality__c != null && oldTrMap.get(TR.ID).TechnicalOffer__c != null){ //2
                            if(!oldTrMap.get(TR.ID).TextForSelectionQuality__c.contains(plv) && !oldTrMap.get(TR.ID).TechnicalOffer__c.contains(valuesToBeChecked.get(tr.Language__c))){ //3
                                tempTechOffer+= '\n' + valuesToBeChecked.get(tr.Language__c);
                            }
                        }
                        else if(valuesToBeChecked != null){
                            tempTechOffer+= '\n' + valuesToBeChecked.get(tr.Language__c);
                        }
                    }
                    if(oldTrMap != null && (TR.TextForSelectionQuality__c!=oldTrMap.get(TR.ID).TextForSelectionQuality__c)){ //2
                        if(TR.TechnicalOffer__c != null){//3
                            oldTechOffer = TR.TechnicalOffer__c ;  
                        }else if(TR.TechnicalOffer__c == null){
                            oldTechOffer = '';
                        }
                        tempTechOffer = tempTechOffer.replace('null', '');
                        oldTechOffer = oldTechOffer.replace('null', '');
                        TR.TechnicalOffer__c = oldTechOffer + tempTechOffer;
                    }else if(oldTrMap == null){
                        TR.TechnicalOffer__c = oldTechOffer + tempTechOffer;
                    }
                }
                if(tr.Language__c != null){
                    tr.CheckOnLanguageChange__c = false;  
                }
            }
        }
        catch(Exception e){
            String exeptionDetails = e.getCause()+' ; '+e.getLineNumber() + ' ; '+e.getMessage()+' ; '+e.getStackTraceString()
                +' ; '+e.getTypeName() ;
            exeptionList.add(exeptionDetails);
            ExceptionUtilClass.logException(ConstantClass.TECHREQUIREMENT_OBJECT,ConstantClass.TECHREQEXCEPTIONERROR_MSG,'',exeptionDetails,ConstantClass.APEX_CLASS);  
        }
    }
   	public static void deleteOLI (List<TechnicalRequirement__c> newTechReq, Map<Id,TechnicalRequirement__c> oldTechReq) {
        List<Id> trIdlst = new List<Id>();
        List<String> exeptionList = new List<String>();
        try{
         for(TechnicalRequirement__c tr : newTechReq){
             if(tr.Active__c!= oldTechReq.get(tr.Id).Active__c && tr.Active__c==false)   {
                 trIdlst.add(tr.Id);
             }
         }
        List<OpportunityLineitem> delOLIlst=[Select Id from OpportunityLineitem where TechnicalRequirement__c IN :trIdlst]; 
        delete delOLIlst;
        }catch(Exception e){
            String exeptionDetails = e.getCause()+' ; '+e.getLineNumber() + ' ; '+e.getMessage()+' ; '+e.getStackTraceString()
                +' ; '+e.getTypeName() ;
            exeptionList.add(exeptionDetails);
            ExceptionUtilClass.logException(ConstantClass.TECHREQUIREMENT_OBJECT,ConstantClass.OLIDELETEEXCEPTIONERROR_MSG,'',exeptionDetails,ConstantClass.APEX_CLASS);
        }
        
    }
    @InvocableMethod(label = 'Clone Technical Requirement' description = 'Clone Technical Requirement in system mode' category = 'TechnicalRequirement')
    public static List < TechnicalRequirement__c > CloneTechnicalRequirement(List<ID> trIDlst) {
       List < TechnicalRequirement__c > returnList =  new List <TechnicalRequirement__c>();
        String fieldsNames = '';
        for (Schema.SObjectField sObjectField : TechnicalRequirement__c.SObjectType.getDescribe().fields.getMap().values()) {
            fieldsNames += sObjectField.getDescribe().getName() + ',';
        }
        fieldsNames = fieldsNames.removeEnd(',');
        String soqlQuery = 'SELECT ' + fieldsNames + ' FROM TechnicalRequirement__c Where Id IN :trIDlst';
        List<TechnicalRequirement__c> TechReqMaster = Database.query(soqlQuery);
        List<TechnicalRequirement__c> techReqsToInsert = new List<TechnicalRequirement__c>();
        for(TechnicalRequirement__c tempTr : TechReqMaster)
        {
           TechnicalRequirement__c newTechReq = tempTr.clone();
            String Name = tempTr.Name + '-Clone';
            newTechReq.name = Name;
            newTechReq.OpportunityProduct__c = null;
            techReqsToInsert.add(newTechReq);
            returnList.add(newTechReq);
        }
        
        insert techReqsToInsert;
        return returnList;
    }
    
}
