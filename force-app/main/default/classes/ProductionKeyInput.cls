/****************************************************************************
* Name: ProductionKeyInput
* Author: Priyanka Kumari
* Created Date: 08/12/2022
* Description: Production Key Screen helper class present on Technical Requirement
*****************************************************************************
* Modification log
* Name    Date                 Description
* Developer Name  Date of Modification  Modification Description  
****************************************************************************/
public with sharing class ProductionKeyInput {
    
    /****************************************************************************
* Author Name: Priyanka Kumari
* Description: Get Data from multiple metadata
* Created Date: 08/12/2022
* Last Modified Date: 
****************************************************************************/
    @AuraEnabled
    public static List<PositionWrapper> getPosition(String recordId){
        List<PositionWrapper> posWrapperList = new List<PositionWrapper>();
        Map<Id, String> positionMap = new Map<Id, String>();
        Map<Id, String> positionMapForFieldValues = new Map<Id, String>();
        Map<String , String> posTranslationPicklistValue = new Map<String, String>();
        Map<Id, Boolean> isRequiredMap = new Map<Id, Boolean>();
        Map<Id, String> posTranslation = new Map<Id, String>();
        Map<String, List<String>> fieldValTranslation = new Map<String, List<String>>();
        Map<Id, Object> finalMap1 = new Map<Id, Object>();
        Map<Id, Object> finalMap = new Map<Id, Object>();
        
        String lang = getUserLanguage();
        Set<String> setOfPFV = new Set<String>();
        String recordtypename = [SELECT Id, Name, RecordtypeId, RecordType.name FROM TechnicalRequirement__c Where Id=:recordId].RecordType.Name;
        if(recordtypename == ConstantClass.TRRECORDTYPENAME){
            for(Position__mdt position : [SELECT Id, MasterLabel, Type__c,FieldMappedTo__c, IsRequired__c, PositionNumber__c
                                          FROM Position__mdt 
                                          WHERE Type__c = :ConstantClass.PRODUCTION_KEY_TYPE  
                                          ORDER BY PositionNumber__c ASC]){
                                              
                                              positionMap.put(position.Id, position.MasterLabel);
                                              String[] FieldMappedTo = position.FieldMappedTo__c.split('\\.');
                                              positionMapForFieldValues.put(position.Id, FieldMappedTo[1]);
                                              isRequiredMap.put(position.Id, position.IsRequired__c);
                                          }
        }
        else if(recordtypename == ConstantClass.TRLIGHTRECORDTYPENAME){
            for(Position__mdt position : [SELECT Id, MasterLabel, Type__c,FieldMappedTo__c, IsRequired__c, PositionNumber__c
                                          FROM Position__mdt 
                                          WHERE Type__c = :ConstantClass.PRODUCTION_KEY_TYPE 
                                          AND MasterLabel IN :ConstantClass.POSITIONS_FOR_SALES
                                          ORDER BY PositionNumber__c ASC]){     
                                              positionMap.put(position.Id, position.MasterLabel);
                                              String[] FieldMappedTo = position.FieldMappedTo__c.split('\\.');
                                              positionMapForFieldValues.put(position.Id, FieldMappedTo[1]);
                                              isRequiredMap.put(position.Id, position.IsRequired__c);
                                          }
        }
        TechnicalRequirement__c TR = [SELECT TargetProduct__c, Origin__c, STWCastingFormat__c, Degassing__c, CRule__c, SteelMillTesting__c, Sampling__c, CheckTreatment__c, HZVSampletest__c, EndProcessing__c,
                                      USHTesting__c ,PrimRollingHomogenize__c, PrimRollingInputformat__c, HZVCheckTreatment__c, HZVAnnealing__c,Homogenize__c,ProcessingbeforeHT__c, HeatTreatment__c,SurfaceTreatment__c, 
                                      MultipleStraightening__c, Peelingbarwirerod__c, EndProcessingSides__c, Surfacedefectinspec__c, USInspection__c, SpecialInspections__c, 
                                      TestingFinishedMaterial__c, Finishing__c, Packaging__c from TechnicalRequirement__c where Id= :recordId LIMIT 1];
        
        Map<String, Object> fieldsMapValues = TR.getPopulatedFieldsAsMap();
        for(Id i :positionMapForFieldValues.KeySet()){              
            for(String fieldmapped : fieldsMapValues.keySet()){                          
                if(positionMapForFieldValues.get(i) == fieldmapped){
                    finalMap.put(i, fieldsMapValues.get(fieldmapped));
                    setOfPFV.add(String.valueOf(fieldsMapValues.get(fieldmapped)));
                }
            }
        }
        for(Translations__mdt trans : [SELECT Id, TranslatedValue__c, Language__c, Position__c, PositionFieldValue__r.Status__c,
                                       PositionFieldValue__c, TranslationNumber__c , PositionFieldValue__r.PicklistValue__c
                                       FROM Translations__mdt 
                                       WHERE Language__c = :lang 
                                       AND (PositionFieldValue__r.PicklistValue__c IN :setOfPFV
                                            AND Position__c IN :finalMap.keySet())
                                            ORDER BY TranslationNumber__c ASC, TranslatedValue__c ASC]){
                                           if(finalMap.get(trans.Position__c) == trans.PositionFieldValue__r.PicklistValue__c)
                                               finalMap1.put(trans.Position__c, trans.TranslatedValue__c);                               
                                       }
        if(recordtypename == ConstantClass.TRRECORDTYPENAME){
            for(Translations__mdt trans : [SELECT Id, TranslatedValue__c, Language__c, Position__c,PositionFieldValue__r.Status__c, 
                                           PositionFieldValue__c, TranslationNumber__c , PositionFieldValue__r.PicklistValue__c
                                           FROM Translations__mdt 
                                           WHERE Language__c = :lang
                                           ORDER BY TranslationNumber__c ASC]){
                                               
                                               if(trans.Position__c != null && trans.PositionFieldValue__c == null){ 
                                                   posTranslation.put(trans.Position__c, trans.TranslatedValue__c);                    
                                               }
                                               if(trans.PositionFieldValue__r.Status__c == 'Active'){
                                                   
                                                   if(trans.Position__c != null && trans.PositionFieldValue__c != null && trans.TranslatedValue__c != null)
                                                   {
                                                       posTranslationPicklistValue.put(trans.PositionFieldValue__r.PicklistValue__c, trans.Position__c +';'+trans.TranslatedValue__c);                 
                                                       
                                                   }
                                                   if(trans.PositionFieldValue__c !=null){                
                                                       if(!fieldValTranslation.containsKey(trans.Position__c))
                                                           fieldValTranslation.put(trans.Position__c, new List<String>());
                                                       
                                                       List<String> list1 = fieldValTranslation.get(trans.Position__c);
                                                       list1.add(trans.TranslatedValue__c);
                                                   } 
                                               }
                                           }
        }
        else if(recordtypename == ConstantClass.TRLIGHTRECORDTYPENAME){ 
            for(Translations__mdt trans : [SELECT Id, TranslatedValue__c, Language__c, Position__c,PositionFieldValue__r.Status__c, Position__r.MasterLabel,
                                           PositionFieldValue__c, TranslationNumber__c , PositionFieldValue__r.PicklistValue__c
                                           FROM Translations__mdt 
                                           WHERE Language__c = :lang AND Position__r.MasterLabel IN :ConstantClass.POSITIONS_FOR_SALES
                                           ORDER BY TranslationNumber__c ASC]){
                                               
                                               if(trans.Position__c != null && trans.PositionFieldValue__c == null){ 
                                                   posTranslation.put(trans.Position__c, trans.TranslatedValue__c);                    
                                               }
                                               if(trans.PositionFieldValue__r.Status__c == 'Active'){
                                                   
                                                   if(trans.Position__c != null && trans.PositionFieldValue__c != null && trans.TranslatedValue__c != null)
                                                   {
                                                       posTranslationPicklistValue.put(trans.PositionFieldValue__r.PicklistValue__c, trans.Position__c +';'+trans.TranslatedValue__c);                 
                                                       
                                                   }
                                                   if(trans.PositionFieldValue__c !=null){                
                                                       if(!fieldValTranslation.containsKey(trans.Position__c))
                                                           fieldValTranslation.put(trans.Position__c, new List<String>());
                                                       
                                                       List<String> list1 = fieldValTranslation.get(trans.Position__c);
                                                       list1.add(trans.TranslatedValue__c);
                                                   } 
                                               }
                                           }
        }
        for(Id fieldValueId : fieldValTranslation.keySet()){
            PositionWrapper posWrapper = new PositionWrapper();
            posWrapper.posLabel = posTranslation.get(fieldValueId);
            List<String> s = new List<String>();
            for(String val : fieldValTranslation.get(fieldValueId)){
                if(val != String.valueOf(finalMap1.get(fieldValueId))){
                    if(s != null)
                        s.add(val);
                }
                else{
                    posWrapper.valueToBeDefaulted = String.valueOf(finalMap1.get(fieldValueId));
                }
            } 
            s.sort();   
            posWrapper.listOfFieldVal = s;
            posWrapper.isRequired = isRequiredMap.get(fieldValueId);
            posWrapperList.add(posWrapper);
        }              
        return posWrapperList;
    }
    
    /****************************************************************************
* Author Name: Priyanka Kumari
* Description: Save data from production key screen to respecitive fields on 
* technical requirement record
* Created Date: 13/12/2022
* Last Modified Date: 
****************************************************************************/
    @AuraEnabled
    public static String saveProductionKey(List<Map<String, String>> resultFromLWC, Id recordId){
        Savepoint sp;
        Map<String, String> posFieldValMap = new Map<String, String>();
        Map<String, String> fieldMapping = new Map<String, String>();
        Map<String, String> mastervalueMap = new Map<String, String>();
        Map<String, String> transMapping = new Map<String, String>();
        Map<String, String> transPosMapping = new Map<String, String>();
        Map<String, String> transvalues = new Map<String, String>();
        Map<String, String> transFinal = new Map<String, String>();
        set<String> setOfPositions = new  set<String>();
        Map<String, String> transpickval = new Map<String, String>();
        try{
            sp = Database.setSavepoint();
            for(Map<String, String> res : resultFromLWC){
                for(String s : res.keySet()){
                    posFieldValMap.put(s, res.get(s));
                }     
            }
            String lang = getUserLanguage();
            for(Translations__mdt trans : [SELECT Id, TranslatedValue__c, Language__c, Position__c, Position__r.MasterLabel, PositionFieldValue__c, PositionFieldValue__r.PicklistValue__c, TranslationNumber__c
                                           FROM Translations__mdt 
                                           WHERE Language__c = :lang
                                           ORDER BY TranslationNumber__c ASC]){
                String translatedValue;                              
                if(trans.TranslatedValue__c!= null) {
                	translatedValue = trans.TranslatedValue__c.replaceAll('(\\s+)', ' ');                    
               	} 
               	if(posFieldValMap.containsKey(translatedValue)){
                    if(trans.Position__c != null && trans.PositionFieldValue__c == null){
                        setOfPositions.add(trans.Position__c);
                        transMapping.put(posFieldValMap.get(trans.TranslatedValue__c), trans.Position__r.MasterLabel);
                        transvalues.put(trans.Position__r.MasterLabel,trans.TranslatedValue__c);
                    }  
                    if(trans.Position__r.MasterLabel == 'HeatTreatment' && trans.PositionFieldValue__c !=null){
                        transpickval.put(trans.PositionFieldValue__r.PicklistValue__c,translatedValue);                                   
                    }
                } 
           	}
            for(Translations__mdt trans : [SELECT Id, TranslatedValue__c, Language__c, Position__c, Position__r.MasterLabel, PositionFieldValue__c, PositionFieldValue__r.PicklistValue__c, TranslationNumber__c
                                           FROM Translations__mdt 
                                           WHERE Language__c = :lang AND Position__c IN :setOfPositions
                                           ORDER BY TranslationNumber__c ASC]){
                String translatedValue;                              
                if(trans.TranslatedValue__c!= null) {
                	translatedValue = trans.TranslatedValue__c.replaceAll('(\\s+)', ' ');                    
               	}
                Set<String> mapValueSet = new Set<String>(posFieldValMap.values());
                if(mapValueSet.contains(translatedValue)){
                    if(trans.PositionFieldValue__c != null){
                		transPosMapping.put(translatedValue, trans.PositionFieldValue__r.PicklistValue__c);
                	}                            
                }                           
           	}
            for(String s : transMapping.keySet()){
            	transFinal.put(transMapping.get(s), transPosMapping.get(s));     
            }
            for(MasterValues__mdt mastervalue : [SELECT Id, Position__r.MasterLabel, FieldMappedTo__c, Value__c, PositionFieldValue__c,PositionFieldValue__r.PicklistValue__c
                                                 FROM MasterValues__mdt 
                                                 WHERE Position__r.MasterLabel IN :transFinal.keySet()]){ 
            	String delimiter = '.'; 
                String value = transvalues.get(mastervalue.Position__r.MasterLabel);
                                                     
                if(transpickval.get(mastervalue.PositionFieldValue__r.PicklistValue__c) == posFieldValMap.get(value)){
                	mastervalueMap.put(mastervalue.Position__r.MasterLabel,mastervalue.Value__c); 
                    String mastervaluestr = (String.valueOf(mastervalue.FieldMappedTo__c)).substringAfter(delimiter);                     
                    fieldMapping.put(mastervaluestr,mastervalueMap.get(mastervalue.Position__r.MasterLabel));
              	}
           	}
            for(Position__mdt position : [SELECT Id, MasterLabel, FieldMappedTo__c 
                                          FROM Position__mdt 
                                          WHERE MasterLabel IN :transFinal.keySet()]){
				if(transFinal.containsKey(position.MasterLabel)){
                	String delimiter = '.';
                    String str = (String.valueOf(position.FieldMappedTo__c)).substringAfter(delimiter);
                    fieldMapping.put(str, transFinal.get(position.MasterLabel)); 
                    if(position.MasterLabel == System.label.HeatTreatment)
                    	fieldMapping.put(str, mastervalueMap.get(position.MasterLabel)); 
                }
           	}
            TechnicalRequirement__c techReq = new TechnicalRequirement__c();
            for(String field : fieldMapping.keySet()){
                if(field =='Inductive__c')
                    techReq.put(field, Boolean.valueOf(fieldMapping.get(field)));
                else
                    techReq.put(field, fieldMapping.get(field)); 
            }
            techReq.put('Id', recordId);
            TechnicalRequirement__c tReq = [SELECT Id, FinishedGoods__r.Active__c,Product__c,Product__r.IsActive from TechnicalRequirement__c where Id= :recordId LIMIT 1];
            if((tReq.FinishedGoods__c !=null && tReq.FinishedGoods__r.Active__c == false) || (tReq.Product__c !=null && tReq.Product__r.IsActive == false)){
                return 'Inactive';
            }
            else{
                if(!(techReq == null)){
                    update techReq;
                    return 'true';
                }
            }
            return 'false'; 
        }
        catch(Exception e){
            Database.RollBack(sp);
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            String error = e.getMessage();
            if(error.contains(System.Label.ValidationErrorOnTRForQualitycheck)){
                return System.Label.ValidationErrorOnTRForQualitycheck;
            }
            return exdetails;
        }
    }
    
 /****************************************************************************
* Author Name: Priyanka Kumari
* Description: Get profile for current user
* Created Date: 13/12/2022
* Last Modified Date: 
****************************************************************************/
    @AuraEnabled
    public static Boolean getProfile(){
        
        User user = [SELECT ID, FirstName, LastName, Name, Title, Profile.Name, Email From User WHERE ID = :UserInfo.getUserId() LIMIT 1];
        if(user.Profile.Name == System.label.SystemAdministratorProfile || user.Profile.Name == ConstantClass.SAG_QUALITY_PROFILE || user.Profile.Name == ConstantClass.SAG_SALES_PROFILE || user.Profile.Name == ConstantClass.SAG_MARKETING_PROFILE || user.Profile.Name ==  ConstantClass.SHS_ADMIN)
        {
            return true;
        }
        return false;
    }
    
    /****************************************************************************
* Author Name: Priyanka Kumari
* Description: Get user language
* Created Date: 13/12/2022
* Last Modified Date: 
****************************************************************************/
    @AuraEnabled
    public static String getUserLanguage(){
        
        String language = UserInfo.getLanguage();
        String lang;
        if(language == 'en_US'){
            String[] l = language.split('_');
            lang = String.valueOf(l[0].toUpperCase());
        }
        else
            lang = language.toUpperCase();
        
        return lang;
    }
    
    /****************************************************************************
* Author Name: Priyanka Kumari
* Description: Wrapper class used to pass data feom class to LWC component
* Created Date: 13/12/2022
* Last Modified Date: 
****************************************************************************/
    public class PositionWrapper{
        @AuraEnabled
        public String posLabel {get;set;}
        @AuraEnabled
        public Boolean isRequired {get;set;}
        @AuraEnabled
        public List<String> listOfFieldVal {get;set;}
        @AuraEnabled
        public String valueToBeDefaulted {get;set;}
        
    }   
}
