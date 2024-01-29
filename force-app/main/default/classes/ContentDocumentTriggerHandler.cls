/****************************************************************************
* Name: ContentDocumentTriggerHandler
* Author: Priyanka Kumari
* Created Date: 05/10/2023
* Description: Handler class for ContentDocument Trigger
****************************************************************************/
public with sharing class ContentDocumentTriggerHandler extends TriggerHandler {

    /***************************************************************************************************
     * Author Name: Priyanka Kumari
     * Description: Method 
     * Created Date: 05/10/2023
     * Last Modified Date: 
     ****************************************************************************************************/
    public override void afterUpdate() {
    	if(!((Map<Id, ContentDocument>) trigger.oldMap).isEmpty() && !((Map<Id, ContentDocument>) trigger.newMap).isEmpty()){  
            ContentDocumentTriggerHelper.publishPlatformEventAfterUpdate((Map<Id, ContentDocument>) trigger.newMap, (Map<Id, ContentDocument>) trigger.oldMap);
        }
    }  
    public override void beforeDelete() {
        if(!((Map<Id, ContentDocument>) trigger.oldMap).isEmpty()){  
            ContentDocumentTriggerHelper.publishPlatformEventBeforeDelete((Map<Id, ContentDocument>) trigger.oldMap);
        }
    }
}