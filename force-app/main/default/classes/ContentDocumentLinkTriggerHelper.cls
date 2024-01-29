/****************************************************************************
* Name: ContentDocumentLinkTriggerHelper
* Author: Impana Paalyam
* Created Date: 16/11/2023
* Description: Helper class for ContentDocumentLink Trigger
****************************************************************************/
public with sharing class ContentDocumentLinkTriggerHelper {
    public static Boolean isEventPublished = false;
    public static void publishPlatformEvent(Map<Id, ContentDocumentLink> newCDLMap){
        List<DeliveryInstructionUpdates__e> eventList = new List<DeliveryInstructionUpdates__e>();
        List<DeliveryInstructions__c> deliveryInstruction = [SELECT id FROM DeliveryInstructions__c LIMIT 49999];
        
        Map<Id, DeliveryInstructions__c> DIMap =new Map<Id, DeliveryInstructions__c>();
        for(DeliveryInstructions__c di: deliveryInstruction)
            if(!DIMap.containsKey(di.ID)){
                DIMap.put(di.ID,di); 
            }
        for (Id newCDId : newCDLMap.keySet()) {
            ContentDocumentLink newCDLink = newCDLMap.get(newCDId);
            if ((newCDLink.LinkedEntityId != null) && DIMap.containsKey(newCDLink.LinkedEntityId) && (!isEventPublished)) {
                DeliveryInstructionUpdates__e event = new DeliveryInstructionUpdates__e();
                event.DeliveryInstructionId__c = newCDLink.LinkedEntityId;
                event.AttachmentUpdated__c = true;
                eventList.add(event);
            }
            
        }
        if (!eventList.isEmpty()) {
            Database.SaveResult[] publishResults = EventBus.publish(eventList);
            isEventPublished = true;
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
