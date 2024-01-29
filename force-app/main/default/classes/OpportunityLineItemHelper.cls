/****************************************************************************
* Name: OpportunityLineItemHelper
* Author: Gunjan Saxena
* Created Date: 14/12/2022
* Description: Handler class for Opportunity Line Item Trigger US-873
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
****************************************************************************/
public with sharing class OpportunityLineItemHelper {
    
    /***************************************************************************************************
     * Author Name: Ashutosh Rao
     * Description: Method to populate usePricingTool__C based on parent opporunity's value
     * Created Date: 09/15/2023
     * Last Modified Date: 
     ****************************************************************************************************/
    public static void populateUsePricingTool(List<OpportunityLineItem> lineItems){
        List<Id> opportunityIds = new List<Id>();
        for(OpportunityLineItem oli:lineItems){
            opportunityIds.add(oli.OpportunityId);
        }
        Map<id,Opportunity> opportunityMap = new Map<id,Opportunity>([select id,Name, TotalOLIs__c, USePricingTool__c,OpportunityType__c from opportunity where id in :opportunityIds]);
        for(OpportunityLineItem oli:lineItems){
            Opportunity parentOpty = opportunityMap.get(oli.opportunityId);
            oli.USePricingTool__c  = parentOpty.USePricingTool__c;
            if(parentOpty.OpportunityType__c=='Standard Inquiry')
            {
                oli.Position__c = parentOpty.Name + ' '+((parentOpty.TotalOLIs__c+1)*10);
            }
            else
            {
                oli.Position__c = parentOpty.Name + ' '+(parentOpty.TotalOLIs__c+1);
            }
        }
    }
   
}