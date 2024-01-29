/****************************************************************************
* Name: AccountTrigger
* Author: Naina Butle
* Created Date: 07/12/2022
* Description: Account Trigger
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
****************************************************************************/
trigger AccountTrigger on Account (before insert, before update, after insert, after update, before delete)
{      
    String acc = 'Account';
    AccountTriggerHandler accTriggerHandler = new AccountTriggerHandler();
    accTriggerHandler.run(acc);
}