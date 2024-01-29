/****************************************************************************
* Name: AccountTriggerHandler
* Author: Naina Butle
* Created Date: 07/12/2022
* Description: Handler class for Account Trigger
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
****************************************************************************/
public with sharing class AccountTriggerHandler extends TriggerHandler{

    public override void beforeUpdate() {
        if(!((List<Account>) trigger.new).isEmpty() && !((Map<Id, Account>) trigger.oldMap).isEmpty()){
           AccountTriggerHelper.preventUpdatingAccount((List<Account>) trigger.new, (Map<Id, Account>) trigger.oldMap);
           AccountTriggerHelper.updateLastUpdatedCommentsFields((List<Account>) trigger.new, (Map<Id, Account>) trigger.oldMap);
        }
    }
    public override void beforeInsert() {
        if(!((List<Account>) trigger.new).isEmpty() ){
           AccountTriggerHelper.updateLastUpdatedCommentsFields((List<Account>) trigger.new, null);
        }
    }
    
    //US-7028 Start
      public override void afterInsert() {
        if(!((Map<Id, Account>) trigger.newMap).isEmpty()){
            AccountTriggerHelper.updateSegmentFieldonContact((Map<Id, Account>) trigger.newMap, null);
        }
    }  
    
    public override void afterUpdate() {
        if(!((Map<Id, Account>) trigger.newMap).isEmpty() && !((Map<Id, Account>) trigger.oldMap).isEmpty()){
            AccountTriggerHelper.updateSegmentFieldonContact((Map<Id, Account>) trigger.newMap, (Map<Id, Account>) trigger.oldMap);
        }
    }  

    public override void beforeDelete() {
        if(!((Map<Id, Account>) trigger.oldMap).isEmpty()){
            AccountTriggerHelper.removeSegmentFieldonContact((Map<Id, Account>) trigger.oldMap); //7028
        }
    }
}