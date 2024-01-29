public with sharing class QuoteTriggerHelper {
/****************************************************************************
* Author Name: Naina B
* Description: Method to update the QuoteOfferedDate based on the date when related Quote is set in Offered Stage.
* Created Date: 31/01/2023
* Last Modified Date: 
****************************************************************************/
    public static void updateQuoteOfferedDate (Map<Id, Quote> quoteoldMap,Map<Id, Quote> quoteNewMap){
        Set<Id> oppIdSet = new  Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id, List<Opportunity>> idVsoppMap = new Map<Id, List<Opportunity>>();
        for(Quote currentQuote : quoteNewMap.values())
        {
            oppIdSet.add(currentQuote.OpportunityId);
        }
        
        for(Opportunity opp : [SELECT Id, QuoteOfferedDate__c  FROM Opportunity WHERE Id IN : oppIdSet]){
            if(!idVsoppMap.containsKey(opp.Id)){
                idVsoppMap.put(opp.Id, new List<Opportunity>());
            }
            idVsoppMap.get(opp.Id).add(opp);
        }
        for(Quote oldQuoteLoop : quoteNewMap.values())
        {
            if(quoteoldMap.get(oldQuoteLoop.Id).Status != ConstantClass.OFFERED_STATUS && oldQuoteLoop.Status == ConstantClass.OFFERED_STATUS){
                for(Opportunity oppLoop : idVsoppMap.get(oldQuoteLoop.OpportunityId)){
                    if(oppLoop.QuoteOfferedDate__c == null){
                        oppLoop.QuoteOfferedDate__c = System.today();
                    }
                }
            }
            
        }
        for(Id oppId : idVsoppMap.KeySet()){
            oppList.addAll(idVsoppMap.get(oppId)); 
        }
        update oppList;    
    }
/****************************************************************************
* Author Name: Harshitha U
* Description: Method to check mandatory fields during Quote Creation.
* Created Date: 05/08/2023
* Last Modified Date: 05/08/2023
****************************************************************************/
public static void checkMandatoryFieldsOnCreation(list<Quote> quoteList,Map<Id, Quote> quoteOldMap, Map<Id, Quote> quoteNewMap){
    List<OpportunityLineItem> relatedOLI = new List<OpportunityLineItem>();
    Map<Id,List<Quote>> quoteIds = new Map<Id,List<Quote>>();
    for (Quote qts : quoteList) {
         if(quoteIds.containsKey(qts.OpportunityId)) {
         List<Quote> quoteIdslst = quoteIds.get(qts.OpportunityId);
         quoteIdslst.add(qts);
     } else {
        List<Quote> newQuoteIds = new List<Quote>();
        newQuoteIds.add(qts);
        quoteIds.put(qts.OpportunityId, newQuoteIds);
    }

   }
    if(!quoteIds.IsEmpty()){
        relatedOLI = [SELECT Id, CustomerSteelGrade__c, HeatTreatmentSales__c, SurfaceCondition__c, UnitOfMeasurement__c, PurposeOfUse__c, Certificate__c, ShortPiece__c, DimensionAFrom__c, FinalPrice__c, Surcharge1__c,
                      FreightCosts__c, Position__c, QuantityUnit__c,OpportunityId,DimensioncalculationA__c,UsePricingTool__c FROM OpportunityLineItem WHERE OpportunityId IN :quoteIds.keyset()];
        
        for(OpportunityLineItem oli : relatedOLI){
            for(Schema.FieldSetMember fieldSetMemberObj : SObjectType.OpportunityLineItem.FieldSets.OLIFieldSet.getFields()){
                if(oli.get(fieldSetMemberObj.getFieldPath()) == null || (oli.UsePricingTool__c == true && oli.DimensioncalculationA__c==null)){
                    for(Quote qt : quoteIds.get(oli.OpportunityId)){
                        qt.addError(System.Label.QuoteError);
                    }
                    break;
                }
            }                
        }
    }
}
}