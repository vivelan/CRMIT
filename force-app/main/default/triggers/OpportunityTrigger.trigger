/****************************************************************************
* Name: OpportunityTrigger
* Author: Naina Butle
* Created Date: 19/10/2022
* Description: Opportunity Trigger class
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
****************************************************************************/
trigger OpportunityTrigger on Opportunity (before insert,before Update) {
    String objectName = 'Opportunity';
    OpportunityTriggerHandler oppTriggerHandler = new OpportunityTriggerHandler();
    oppTriggerHandler.setMaxLoopCount(7, 'Opportunity');
    oppTriggerHandler.run(objectName);
}
