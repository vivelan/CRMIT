/****************************************************************************
* Name: CalculatePriceOnOpportunity
* Author: Harshitha UdayKumar
* Created Date: 25/10/2023
* Description: Controller class of CalculatePriceOnOpportunity
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description
****************************************************************************/
public with sharing class CalculatePriceOnOpportunity {
    @AuraEnabled
    public static List<Id> getOLIRecord(String recordId){
        List<ID> oliids = new  List<ID>();        
        for(OpportunityLineItem oli : [SELECT Id,Opportunity.UsePricingTool__c,UsePricingTool__c FROM OpportunityLineItem
                                            WHERE OpportunityId = :recordId AND UsePricingTool__c = TRUE])
        {
            oliids.add(oli.Id);
        }
        return oliids;
    }

}