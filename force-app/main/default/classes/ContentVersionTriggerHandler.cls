/**
 * @description       : 
 * @author            : Ashutosh Rao
 * @group             : 
 * @last modified on  : 11-01-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public with sharing class ContentVersionTriggerHandler extends TriggerHandler {
    public static Boolean rerun = false;
    public override void afterInsert() {
        if(rerun){
            return;
        }
        rerun = true;
        if(!((Map<Id, ContentVersion>) trigger.newMap).isEmpty()){
            ContentVersionTriggerHelper.provideAccess( (Map<Id, ContentVersion>) trigger.newMap);
        }
    }  
    
    public override void afterUpdate() {
        if(rerun){
            return;
        }
        rerun = true;
        if(!((Map<Id, ContentVersion>) trigger.newMap).isEmpty()){
            ContentVersionTriggerHelper.updateAccess( (Map<Id, ContentVersion>) trigger.oldMap, (Map<Id, ContentVersion>) trigger.newMap);
        }
    }  
    
}