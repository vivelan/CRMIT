/****************************************************************************
* Name: AccountTeamMemberTriggerHandler
* Author: Naina Butle
* Created Date: 28/11/2022
* Description: Handler class for AccountTeamMember Trigger
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description 
*Naina Butle       20/02/2022              US-2218 Opportunity Creator to be inserted as Sales Rep when Sales Profile
****************************************************************************/
public with sharing class AccountTeamMemberTriggerHandler extends TriggerHandler {
    
    public override void afterInsert() {
        if(!((Map<Id, AccountTeamMember>) trigger.newMap).isEmpty()){
            AccountTeamMemberTriggerHelper.updateCODAccountTeamMemberInsert((Map<Id, AccountTeamMember>) trigger.newMap);
        }
    }
    
    public override void afterUpdate() {
        if(!((Map<Id, AccountTeamMember>) trigger.oldMap).isEmpty()){
            AccountTeamMemberTriggerHelper.removeExistingUser((Map<Id, AccountTeamMember>) trigger.oldMap);
        }
        if(!((Map<Id, AccountTeamMember>) trigger.newMap).isEmpty()){
            AccountTeamMemberTriggerHelper.updateCODAccountTeamMemberInsert((Map<Id, AccountTeamMember>) trigger.newMap);
        }
    }  
    //2218
    public override void afterDelete() {
        if(!((Map<Id, AccountTeamMember>) trigger.oldMap).isEmpty()){
            AccountTeamMemberTriggerHelper.removeExistingUser((Map<Id, AccountTeamMember>) trigger.oldMap);
        }
    } 
}