/****************************************************************************
* Name: ContentDocumentTriggerHelper
* Author: Priyanka Kumari
* Created Date: 05/10/2023
* Description: Helper class for ContentDocument Trigger
****************************************************************************/
public with Sharing class ContentDocumentTriggerHelper {
    //private static Boolean isEventPublished = false;
    /***************************************************************************************************
* Author Name: Priyanka Kumari
* Description: Method 
* Created Date: 05/10/2023
* Last Modified Date: 
****************************************************************************************************/
    public static void publishPlatformEventAfterUpdate(Map<Id, ContentDocument> newCDMap, Map<Id, ContentDocument> oldCDMap){
        List<DeliveryInstructionUpdates__e> eventList = new List<DeliveryInstructionUpdates__e>();
        List<DeliveryInstructions__c> deliveryInstruction = [SELECT id FROM DeliveryInstructions__c LIMIT 49999];
        Set<Id> deliveryInstructionIds = new Set<Id>(new Map<Id, DeliveryInstructions__c>(deliveryInstruction).keySet());
        List<ContentDocumentLink> CDLink = [SELECT id, ContentDocumentId, LinkedEntityId,SystemModstamp,ContentDocument.ContentModifiedDate
                                            FROM ContentDocumentLink
                                            WHERE ContentDocumentId IN :newCDMap.keyset() AND LinkedEntityId IN :deliveryInstructionIds];
        for(ContentDocumentLink cd : CDLink){
            if(oldCDMap != null  && (!ContentDocumentLinkTriggerHelper.isEventPublished)){
                if((newCDMap.get(cd.ContentDocumentId).LastModifiedDate) != (oldCDMap.get(cd.ContentDocumentId).LastModifiedDate) ||
                   (newCDMap.get(cd.ContentDocumentId).SystemModstamp) != (oldCDMap.get(cd.ContentDocumentId).SystemModstamp)||
                   (newCDMap.get(cd.ContentDocumentId).ContentModifiedDate) != (oldCDMap.get(cd.ContentDocumentId).ContentModifiedDate)){
                       DeliveryInstructionUpdates__e event = new DeliveryInstructionUpdates__e();
                       event.DeliveryInstructionId__c = cd.LinkedEntityId;
                       event.AttachmentUpdated__c = true;
                       eventList.add(event);
                   }
            }
        }
        
        if (!eventList.isEmpty()) {
            Database.SaveResult[] publishResults = EventBus.publish(eventList);
            //ContentDocumentLinkTriggerHelper.isEventPublished = true;
            for (Database.SaveResult result : publishResults) {
                if (!result.isSuccess()) {
                    String excdetail;
                    for (Database.Error error : result.getErrors()) {
                        excdetail+= error.getStatusCode() + ':' + error.getMessage();
                    }
                }
            }
        }
    }
    
    // Content Document on delete 
    public static void publishPlatformEventBeforeDelete(Map<Id, ContentDocument> oldCDMap){
        List<DeliveryInstructions__c> deliveryInstruction = [SELECT id FROM DeliveryInstructions__c LIMIT 49999];
        Set<Id> deliveryInstructionIds = new Set<Id>(new Map<Id, DeliveryInstructions__c>(deliveryInstruction).keySet());
        try{
            List<ContentDocumentLink> CDLink = [SELECT id,ContentDocumentId,LinkedEntityId,SystemModstamp,ContentDocument.ContentModifiedDate
                                                FROM ContentDocumentLink
                                                WHERE ContentDocumentId IN :oldCDMap.keyset() AND LinkedEntityId IN :deliveryInstructionIds]; 
            list<Id> DeletedRecordList = new list<id>();
            list<Id> DeletedRecordLinkList = new list<id>();
            for(ContentDocument cd1:oldCDMap.values()){
                DeletedRecordList.add(cd1.id);
            }
            for(ContentDocumentLink cd : CDLink){
                DeletedRecordLinkList.add(cd.LinkedEntityId);
            }
            if (!System.isFuture() && Limits.getFutureCalls() < Limits.getLimitFutureCalls()) {
                try{
                    PublishEvent(DeletedRecordList,DeletedRecordLinkList);
                }catch (Exception e) {
                    System.debug(LoggingLevel.ERROR,'Exception in calling PublishEvent FutureMethod: ' + e.getMessage());  
                }
            }    
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'Exception in publishPlatformEventBeforeDelete: ' + e.getMessage());
        }
    }
    
    @future
    public static void PublishEvent(list<id> recordIds,list<id> recordlinkIds){
        List<DeliveryInstructionUpdates__e> eventList = new List<DeliveryInstructionUpdates__e>();
        if(recordIds != null && recordlinkIds != null){
            for(Id cd : recordlinkIds){
                DeliveryInstructionUpdates__e event = new DeliveryInstructionUpdates__e();
                event.DeliveryInstructionId__c = cd;
                event.AttachmentUpdated__c = true;
                eventList.add(event); 
            }
        }
        if (!eventList.isEmpty()) {
            Database.SaveResult[] publishResults = EventBus.publish(eventList);
            //ContentDocumentLinkTriggerHelper.isEventPublished = true;
            for (Database.SaveResult result : publishResults) {
                if (!result.isSuccess()) {
                    String excdetail;
                    for (Database.Error error : result.getErrors()) {
                        excdetail+= error.getStatusCode() + ':' + error.getMessage();
                    }
                }
            }
        }
    }
    
}