/****************************************************************************
* Name: OpportunityTriggerHandler
* Author: Naina Butle
* Created Date: 19/10/2022
* Description: Handler class for Opportunity Trigger
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
*Naina Butle        10/1/2023               US-1250- removed checkRelatedTechnicalReqStatus method
****************************************************************************/
public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
        if(!((list<Opportunity>) trigger.new).isEmpty()){
            OpportunityTriggerHelper.updateSalesRProductMQualityR((list<Opportunity>) trigger.new, null); //2218
        }
    }
    
    public override void beforeUpdate() {
        if(!((list<Opportunity>) trigger.new).isEmpty() && !((Map<Id, Opportunity>) trigger.oldMap).isEmpty()){
            OpportunityTriggerHelper.updateSalesRProductMQualityR((list<Opportunity>) trigger.new, (Map<Id,Opportunity>)trigger.oldMap); //2218
            OpportunityTriggerHelper.updateFinalCheckStartDate((list<Opportunity>) trigger.new,(Map<Id,Opportunity>)trigger.oldMap);
            OpportunityTriggerHelper.updateQualityCheckTotalDuration((list<Opportunity>) trigger.new,(Map<Id,Opportunity>)trigger.oldMap,(Map<Id,Opportunity>)trigger.NewMap);
        }
    }   
}