/****************************************************************************
* Name: AccountContactRelationTrigger
* Author: Impana Paalyam
* Created Date: 20/04/2023
* Description: AccountContactRelation Trigger 
*****************************************************************************/
trigger AccountContactRelationTrigger on AccountContactRelation (after insert, before update,after update, before delete, after delete) {
    String objectName = 'AccountContactRelation';
    AccountContactRelationTriggerHandler accContactTriggerHandler = new AccountContactRelationTriggerHandler();
    accContactTriggerHandler.run(objectName);
}