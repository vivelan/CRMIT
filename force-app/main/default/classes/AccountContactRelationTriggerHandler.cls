/****************************************************************************
* Name: AccountContactRelationTriggerHandler
* Author: Impana Paalyam
* Created Date: 20/04/2023
* Description: Handler class for AccountContactRelation Trigger
****************************************************************************/
public with sharing class AccountContactRelationTriggerHandler extends TriggerHandler{
    public override void afterInsert() {
          if(!((Map<Id, AccountContactRelation>) trigger.newMap).isEmpty()){
              AccountContactRelationTriggerHelper.AccountContactRelationInsert((Map<Id, AccountContactRelation>) trigger.newMap);
              AccountContactRelationTriggerHelper.updateSegmentFieldonContact((Map<Id, AccountContactRelation>) trigger.newMap); //7028
  
          }
      }
      public override void afterUpdate() {
          if(!((Map<Id, AccountContactRelation>) trigger.oldMap).isEmpty() && !((list<AccountContactRelation>) trigger.new).isEmpty()){  
          AccountContactRelationTriggerHelper.AccountContactRelationUpdate((Map<Id, AccountContactRelation>) trigger.newMap, (Map<Id, AccountContactRelation>) trigger.oldMap);
          }
         if(!((Map<Id, AccountContactRelation>) trigger.newMap).isEmpty()){
              AccountContactRelationTriggerHelper.updateSegmentFieldonContact((Map<Id, AccountContactRelation>) trigger.newMap); //7028
          }
      }
      public override void beforeDelete() {
          if(!((Map<Id, AccountContactRelation>) trigger.oldMap).isEmpty()){
              AccountContactRelationTriggerHelper.AccountContactRelationbeforeDelete((Map<Id, AccountContactRelation>) trigger.oldMap);
              AccountContactRelationTriggerHelper.removeSegmentFieldonContact((Map<Id, AccountContactRelation>) trigger.oldMap); //7028
            }
      }
       public override void afterDelete() {
          if(!((Map<Id, AccountContactRelation>) trigger.oldMap).isEmpty()){
              AccountContactRelationTriggerHelper.AccountContactRelationafterDelete((Map<Id, AccountContactRelation>) trigger.oldMap);
          }
      }
      
  }