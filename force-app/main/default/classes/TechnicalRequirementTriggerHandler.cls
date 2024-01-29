/****************************************************************************
* Name: TechnicalRequirementTriggerHandler
* Author: Priyanka Kumari
* Created Date: 29/11/2022
* Description: Handler class for TechnicalRequirement Trigger
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description 
* Monika Kadam		13/1/2023				Added afterUpdate method
****************************************************************************/
public class TechnicalRequirementTriggerHandler extends TriggerHandler{

    /***************************************************************************************************
     * Author Name: Priyanka Kumari
     * Description: To call a helper method to populate Technical Offer field value before inserting a 
     * technical requirement record.
     * Created Date: 29/11/2022
     * Last Modified Date: 
     ****************************************************************************************************/
    public override void beforeInsert() {  
    	if(!((list<TechnicalRequirement__c>) trigger.new).isEmpty()){
            TechnicalRequirementHelper.populateTechnicalOffer(Trigger.new,(Map<Id,TechnicalRequirement__c>)trigger.oldMap);   
        }    
    }
    /***************************************************************************************************
     * Author Name: Priyanka Kumari
     * Description: To call a helper method to populate Technical Offer field value before updating a 
     * technical requirement record.
     * Created Date: 29/11/2022
     * Last Modified Date: 
     ****************************************************************************************************/
    public override void beforeUpdate() {        
        if(!((list<TechnicalRequirement__c>) trigger.new).isEmpty()){
        	TechnicalRequirementHelper.populateTechnicalOffer(Trigger.new,(Map<Id,TechnicalRequirement__c>)trigger.oldMap); 
        }
     }
    public override void afterUpdate() {        
        if(!((list<TechnicalRequirement__c>) trigger.new).isEmpty()){
        	TechnicalRequirementHelper.deleteOLI(Trigger.new,(Map<Id,TechnicalRequirement__c>)Trigger.oldMap); 
        }
     }
}
