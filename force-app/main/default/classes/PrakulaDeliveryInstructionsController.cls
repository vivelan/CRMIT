/****************************************************************************
* Name: PrakulaDeliveryInstructionsController
* Author: Harshitha Udaykumar
* Created Date: 06/10/2023
* Description: Controller class for PrakulaDeliveryInstruction - LVPosition Search on OLI.
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
****************************************************************************/
public with sharing class PrakulaDeliveryInstructionsController {
    /****************************************************************************
* Author Name: Harshitha Udaykumar
* Description: to Fecth the list of prakula records based on the search criteria entered in UI.
* Created Date: 06/10/2023
* Last Modified Date: 
****************************************************************************/
public static List<PraekulaDeliveryInstructions__c> fetchPrakula(List<String> deliveryInstructionsID, String OLIID){
    List<String> lstDIds = deliveryInstructionsID;
    List<PraekulaDeliveryInstructions__c> devinstwithCond = new List<PraekulaDeliveryInstructions__c>();
    Set<String> prakulaId = new Set<String>();
    if(!lstDIds.isEmpty()){
        OpportunityLineItem oppIdRecord = [SELECT id, Opportunity.AccountId, Opportunity.Language__c FROM OpportunityLineItem WHERE Id =:OLIID];
        List<PraekulaDeliveryInstructions__c> devinst = [SELECT Id, Praekula__c, Praekula__r.Name , Praekula__r.Account__c, Praekula__r.Account__r.Name,  Praekula__r.Language__c, DeliveryInstructions__c ,DeliveryInstructions__r.Type__c,DeliveryInstructions__r.Publisher__c, DeliveryInstructions__r.Revision__c, 
                                                         DeliveryInstructions__r.Title__c, DeliveryInstructions__r.DateOfIssue__c
                                                         FROM PraekulaDeliveryInstructions__c WHERE DeliveryInstructions__c In: lstDIds 
                                                        ]; 
        for(PraekulaDeliveryInstructions__c pr : devinst){
            if(pr.Praekula__r.Account__c != null && oppIdRecord.Opportunity.AccountId != null && pr.Praekula__r.Account__c == oppIdRecord.Opportunity.AccountId && pr.Praekula__r.Language__c != null && oppIdRecord.Opportunity.Language__c != null && pr.Praekula__r.Language__c == oppIdRecord.Opportunity.Language__c){
                prakulaId.add(pr.Praekula__c);
            }
        } 
       devinstwithCond = [SELECT Id, Praekula__c, Praekula__r.Name , Praekula__r.Account__c, Praekula__r.Account__r.Name,  Praekula__r.Language__c, DeliveryInstructions__c ,DeliveryInstructions__r.Type__c,DeliveryInstructions__r.Publisher__c, DeliveryInstructions__r.Revision__c, 
                                                         DeliveryInstructions__r.Title__c, DeliveryInstructions__r.DateOfIssue__c
                                                         FROM PraekulaDeliveryInstructions__c WHERE Praekula__c In: prakulaId 
                                                        ]; 
        
    }
    return devinstwithCond;
}
    /****************************************************************************
* Author Name: Naina Butle
* Description: TO search the LV positions based on the Prakula selected.
* Created Date: 09/10/2023
* Last Modified Date: 
****************************************************************************/
    @AuraEnabled
    public static List<LVPostion__c> sendprakulaIds (String prakulaId, String OLIID)
    {
        String[] filtersOR = new String[0];
        OpportunityLineItem oppIdRecord = [SELECT id, Product2Id, Opportunity.AccountId, Prakula__c, Opportunity.OpportunityType__c, DimensionAFrom__c, DimensionATo__c, CustomerSteelGrade__c, Opportunity.Language__c FROM OpportunityLineItem WHERE Id = :OLIID];
        String oppIdRecordCustomerSteelGrade = oppIdRecord.CustomerSteelGrade__c;
        String oppIdRecordProduct2 = oppIdRecord.Product2Id;
        String oppIdRecordPrakula = oppIdRecord.Prakula__c;
        Decimal oppIdRecordDimensionAFrom = oppIdRecord.DimensionAFrom__c;
        Decimal oppIdRecordDimensionATo = oppIdRecord.DimensionATo__c;
        String StandardInquiry = 'Standard Inquiry';
        String MassInquiry = 'Mass Inquiry';
        String strEsc;
        String query = 'SELECT Id, Praekula__c, Name, Praekula__r.Name, Type__c, DimensionAFrom__c, HeatTreatmentSales__c, DimensionATo__c, Product__r.Name, CustomerSteelGrade__c FROM LVPostion__c WHERE ';
        
        if (oppIdRecordPrakula != null) {
            query += 'Praekula__c = :oppIdRecordPrakula AND ';
        }
        
        if (oppIdRecordCustomerSteelGrade != null) {
            query += 'CustomerSteelGrade__c = :oppIdRecordCustomerSteelGrade AND ';
        }
        
        if (oppIdRecordProduct2 != null) {
            query += 'Product__c = :oppIdRecordProduct2 AND ';
        }
        
        /*if (oppIdRecordDimensionAFrom != null) {
            query += 'DimensionAFrom__c <= :oppIdRecordDimensionAFrom AND DimensionATo__c >= :oppIdRecordDimensionAFrom AND ';
        }*/
        
        if (oppIdRecordDimensionATo != null && oppIdRecordDimensionAFrom!= null) {
            query += 'DimensionAFrom__c <= :oppIdRecordDimensionAFrom AND DimensionATo__c >= :oppIdRecordDimensionATo AND ';
        }
        
        
        if (oppIdRecord.Opportunity.OpportunityType__c != null) {
            if (oppIdRecord.Opportunity.OpportunityType__c == StandardInquiry) {
                query += 'Type__c =: StandardInquiry';
            } else if (oppIdRecord.Opportunity.OpportunityType__c == MassInquiry) {
                filtersOR.add('Type__c =: StandardInquiry');
                filtersOR.add('Type__c =: MassInquiry');
            }
        }
        
        if (filtersOR.size() > 0) {
            query += '(' + String.join(filtersOR, ' OR ') + ')';
        } 
        
        if (oppIdRecordDimensionAFrom != null && oppIdRecordDimensionATo == null) {
           query +=' AND (DimensionAFrom__c = :oppIdRecordDimensionAFrom ';
           query +=' OR ';
           query +='(DimensionAFrom__c <= :oppIdRecordDimensionAFrom AND DimensionATo__c >= :oppIdRecordDimensionAFrom))';
        }
        
        if (query.endsWith('AND ')) {     
            query = query.substring(0, query.length() - 4); 
        }
        if (oppIdRecordDimensionAFrom != null){
        strEsc = String.escapeSingleQuotes(query); 
        }
        List<LVPostion__c> lvlst = Database.query(strEsc);
        
        return lvlst;			
    }
    
    @AuraEnabled
    public static List<PraekulaDeliveryInstructions__c> getDeliveryInstructionId(String deliveryInsType, String deliveryInsPublisher, String deliveryInsRevision, String deliveryInsTitle, String deliveryInsDateOfIssue, String OLIID){
        List<String> deliveryInstructionsID = new List<String>();
        String query ;
        Date deliveryInsDateOfIssueDate;
        if(deliveryInsType != null || deliveryInsPublisher != null || deliveryInsRevision != null || deliveryInsTitle != null || deliveryInsDateOfIssue != null ){
            query = 'SELECT Id, Type__c, Publisher__c, Name, DateOfIssue__c, Title__c, Revision__c from DeliveryInstructions__c WHERE ';
        }
        if (deliveryInsType != null) {
            query += 'Type__c  = :deliveryInsType AND ';
        }
        
        if (deliveryInsPublisher != null) {
            query += 'Publisher__c   = :deliveryInsPublisher AND ';
        }
        
        if (deliveryInsRevision != null) {
            query += 'Revision__c   = :deliveryInsRevision AND ';
        }
        
        if (deliveryInsTitle != null) {
            query += 'Title__c   = :deliveryInsTitle AND ';
        }
        
        if (deliveryInsDateOfIssue != null) {
            deliveryInsDateOfIssueDate = Date.valueOf(deliveryInsDateOfIssue);
            query += 'DateOfIssue__c   = :deliveryInsDateOfIssueDate';
        }
        
        if(query != null){
            if (query.endsWith('AND ')) {     
                query = query.substring(0, query.length() - 4); 
            }
            String strEsc = String.escapeSingleQuotes(query); 
            List<DeliveryInstructions__c > deliveryInslst = Database.query(strEsc);
            for(DeliveryInstructions__c dIn : deliveryInslst){
                deliveryInstructionsID.add(dIn.Id);
            } 
        }
        List<PraekulaDeliveryInstructions__c> devinstwithCond = fetchPrakula(deliveryInstructionsID, OLIID);
        return devinstwithCond;
    }
    
}