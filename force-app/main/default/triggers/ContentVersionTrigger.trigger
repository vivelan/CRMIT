/**
 * @description       : 
 * @author            : Ashutosh Rao
 * @group             : 
 * @last modified on  : 11-01-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger ContentVersionTrigger on ContentVersion (after update) {
        ContentVersionTriggerHandler ContentTriggerHandler = new ContentVersionTriggerHandler();
        String objectName = 'ContentVersion';
        ContentTriggerHandler.run(objectName);
    	
}