/****************************************************************************
* Name: PrakulaTriggerHandler
* Author: Harshitha Udaykumar
* Created Date: 13/09/2023
* Description: Handler class for Prakula Trigger
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
* Naina Butle       14/9/2023               US-7210 Move/Update text block automations
****************************************************************************/
public with sharing class PrakulaTriggerHandler extends TriggerHandler{
    public override void beforeInsert() {
        if(!((List<Praekula__c>) trigger.new).isEmpty()){
            PrakulaTriggerHelper.updateUserRoleOnPrakula((List<Praekula__c>) trigger.new, null);
            PrakulaTriggerHelper.populateTechnicalOffer((List<Praekula__c>) trigger.new, null); //US-7210   
        }
    }
    public override void beforeUpdate() {
        if(!((List<Praekula__c>) trigger.new).isEmpty() && !((Map<Id, Praekula__c>) trigger.oldMap).isEmpty()){
            PrakulaTriggerHelper.updateUserRoleOnPrakula((List<Praekula__c>) trigger.new, (Map<Id, Praekula__c>) trigger.oldMap);
            PrakulaTriggerHelper.populateTechnicalOffer((List<Praekula__c>) trigger.new, (Map<Id, Praekula__c>) trigger.oldMap); //US-7210   
        }
    }
}