/**
 * @description       : 
 * @author            : Ashutosh Rao
 * @group             : 
 * @last modified on  : 11-01-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ContentVersionTriggerHelper {
    public static void provideAccess( Map<id,ContentVersion> newVersionMap){
        List<Id> listToCreateAccess = new List<Id>();
        for(Id versionId :newVersionMap.keyset() ){
            ContentVersion version = newVersionMap.get(versionId);
            if(version.Purchaser__c!=null || version.Regulator__c!=null||version.Consumer__c!=null){
                listToCreateAccess.add(versionId);
            }
        }
         CreateAccess(listToCreateAccess,null,newVersionMap);
    } 
    public static void updateAccess(Map<id,ContentVersion> oldVersionMap,Map<id,ContentVersion> newVersionMap){
        List<Id> listToUpdateAccess = new List<Id>();
        for(Id versionId :newVersionMap.keyset() ){
            ContentVersion oldVersion = oldVersionMap.get(versionId);
            ContentVersion newVersion = newVersionMap.get(versionId);
            if(oldVersion.Purchaser__c!=newVersion.Purchaser__c || oldVersion.Regulator__c!=newVersion.Regulator__c
               ||oldversion.Consumer__c!=newversion.Consumer__c){
                   listToUpdateAccess.add(versionId);
               }
        }
        UpdateAccess(listToUpdateAccess,oldVersionMap,newVersionMap);
    }
    public static void UpdateAccess(List<Id> listToUpdateAccess,Map<id,ContentVersion> oldVersionMap,Map<id,ContentVersion> newVersionMap){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> documentIds = new Set<Id>();
        List<ContentDocumentLink> deleteCDLList = new List<ContentDocumentLink>();
        Set<String> accessKeys = new Set<String>();
        for(id versionId: listToUpdateAccess){
            if(newVersionMap.get(versionId).documentType__c==null){
                continue;
            }
            if(oldVersionMap.get(versionId).Purchaser__c!=newVersionMap.get(versionId).Purchaser__c){
                accountIds.add(oldVersionMap.get(versionId).Purchaser__c);
                documentIds.add(oldVersionMap.get(versionId).ContentDocumentId);
                accessKeys.add(oldVersionMap.get(versionId).Purchaser__c+':'+oldVersionMap.get(versionId).ContentDocumentId);
            }
            if(oldVersionMap.get(versionId).Consumer__c!=newVersionMap.get(versionId).Consumer__c ){
                accountIds.add(oldVersionMap.get(versionId).Consumer__c);
                documentIds.add(oldVersionMap.get(versionId).ContentDocumentId);
                accessKeys.add(oldVersionMap.get(versionId).Consumer__c+':'+oldVersionMap.get(versionId).ContentDocumentId);
            }
            if(oldVersionMap.get(versionId).regulator__c!=newVersionMap.get(versionId).regulator__c ){
                accountIds.add(oldVersionMap.get(versionId).regulator__c);
                documentIds.add(oldVersionMap.get(versionId).ContentDocumentId);
                accessKeys.add(oldVersionMap.get(versionId).regulator__c+':'+oldVersionMap.get(versionId).ContentDocumentId);
            }
        }
        if(documentIds.size()!=0 && accountIds.size()!=0){
          
        for(ContentDocumentLink cdl: [SELECT id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where
                                      LinkedEntityId in :accountIds  and ContentDocumentId in :documentIds  ]){
                                          if(accessKeys.contains(cdl.LinkedEntityId+':'+cdl.ContentDocumentId))   {
                                              deleteCDLList.add(cdl);
                                          }                            
                                      }
        }
        if(deleteCDLList.size()>0){ 
            delete deleteCDLList;
        }
        CreateAccess(listToUpdateAccess,oldVersionMap,newVersionMap);
    }
    public static void  CreateAccess(List<Id> listToCreateAccess,Map<id,ContentVersion> oldVersionMap,Map<id,ContentVersion> newVersionMap){
        List<ContentDocumentLink> documentLinkList = new List<ContentDocumentLink>();
        for(id versionId: listToCreateAccess){
            if( newVersionMap.get(versionId).DocumentType__c == 'Certificate'
               ||newVersionMap.get(versionId).DocumentType__c == 'Dispatch Note'
               ||newVersionMap.get(versionId).DocumentType__c == 'Packing List'){
                   if(newVersionMap.get(versionId).purchaser__c!=null 
                      &&( oldVersionMap==null || oldVersionMap.get(versionId).Purchaser__c!=newVersionMap.get(versionId).Purchaser__c)){
                       ContentDocumentLink cdlPruchaser = new ContentDocumentLink();
                       cdlPruchaser.contentDocumentId = newVersionMap.get(versionId).ContentDocumentId;
                       cdlPruchaser.shareType = 'V';
                       cdlPruchaser.visibility = 'AllUsers';
                       cdlPruchaser.LinkedEntityId = newVersionMap.get(versionId).purchaser__c;
                       documentLinkList.add(cdlPruchaser);
                   }
                   if(newVersionMap.get(versionId).Consumer__c!=null &&(
                          oldVersionMap==null || oldVersionMap.get(versionId).Consumer__c!=newVersionMap.get(versionId).Consumer__c)){
                       ContentDocumentLink cdlConsumer = new ContentDocumentLink();
                       cdlConsumer.contentDocumentId = newVersionMap.get(versionId).ContentDocumentId;
                       cdlConsumer.shareType = 'V';
                       cdlConsumer.visibility = 'AllUsers';
                       cdlConsumer.LinkedEntityId = newVersionMap.get(versionId).Consumer__c;
                       documentLinkList.add(cdlConsumer);
                   }
               }
            if( newVersionMap.get(versionId).DocumentType__c == 'Order Confirmation'){
                if(newVersionMap.get(versionId).purchaser__c!=null  &&(
                          oldVersionMap==null || oldVersionMap.get(versionId).Purchaser__c!=newVersionMap.get(versionId).Purchaser__c)){
                    ContentDocumentLink cdlPruchaser = new ContentDocumentLink();
                    cdlPruchaser.contentDocumentId = newVersionMap.get(versionId).ContentDocumentId;
                    cdlPruchaser.shareType = 'V';
                    cdlPruchaser.visibility = 'AllUsers';
                    cdlPruchaser.LinkedEntityId = newVersionMap.get(versionId).purchaser__c;
                    documentLinkList.add(cdlPruchaser);
                }
            }
            if( newVersionMap.get(versionId).DocumentType__c == 'Invoice'){
                if(newVersionMap.get(versionId).regulator__c!=null  &&(
                          oldVersionMap==null || oldVersionMap.get(versionId).regulator__c!=newVersionMap.get(versionId).regulator__c)){
                    ContentDocumentLink cdlPruchaser = new ContentDocumentLink();
                    cdlPruchaser.contentDocumentId = newVersionMap.get(versionId).ContentDocumentId;
                    cdlPruchaser.shareType = 'V';
                    cdlPruchaser.visibility = 'AllUsers';
                    cdlPruchaser.LinkedEntityId = newVersionMap.get(versionId).regulator__c;
                    documentLinkList.add(cdlPruchaser);
                }
            }
        }
        if(documentLinkList.size()>0){
            Database.Insert(documentLinkList,false);
        }
    }
}