/****************************************************************************
* Name: AccountTeamMemberTrigger
* Author: Naina Butle
* Created Date: 29/11/2022
* Description: AccountTeamMember Trigger
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description 
* Naina Butle       20/02/2022              US-2218 Opportunity Creator to be inserted as Sales Rep when Sales Profile
****************************************************************************/
trigger AccountTeamMemberTrigger on AccountTeamMember (after insert, after update, before delete, after delete) {
    String objectName = 'AccountTeamMember';
    AccountTeamMemberTriggerHandler accTeamTriggerHandler = new AccountTeamMemberTriggerHandler();
    accTeamTriggerHandler.run(objectName);
}