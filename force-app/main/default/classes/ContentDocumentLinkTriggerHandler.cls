/****************************************************************************
* Name: ContentDocumentLinkTriggerHandler
* Author: Impana Paalyam
* Created Date: 16/11/2023
* Description: Handler class for ContentDocumentLink Trigger
****************************************************************************/
public with sharing class ContentDocumentLinkTriggerHandler extends TriggerHandler {


    public override void afterInsert() {
    	if(!((Map<Id, ContentDocumentLink>) trigger.newMap).isEmpty()){  
            ContentDocumentLinkTriggerHelper.publishPlatformEvent((Map<Id, ContentDocumentLink>) trigger.newMap);
        }
    }
}