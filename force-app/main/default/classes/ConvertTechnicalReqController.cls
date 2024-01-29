/****************************************************************************
* Name: ConvertTechnicalReqController
* Author: Naina Butle
* Created Date: 14/11/2022
* Description: Controller class of convertTechnicalReqLWC
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description 
* Gunjan Saxena     14/12/2022              US-916 - Add Error for bulk if technical recuirement have product 
* Naina Butle       09/01/2023              US-1209 added changes related to PriceBookEntry
* Naina Butle       10/01/2023              US-1250 added Error message.
* Naina Butle       17/01/2023              US-1484 Added ProductID in PriceBookEntry
* Naina Butle       30/01/2023              US-1998 updated existing OLI
* Naina Butle       02/02/2023              US-2003 On Demand 'Convert to OLI' & 'Convert Technical requirements'
* Monika Kadam      03/02/2023              US-2002 Allow TR Lights to be converted when Oppty stage is Open
* Naina Butle       16/02/2023              US-2530 reload the site
* Monika Kadam      13/03/2023              US-2835 Adjust error message when trying to convert inactive FMN / Products to OLI
* Gunjan Saxena       18/04/2023            US-3707 Update costs on OLI upon Product Finder Re-run/ update of OLI
* Gunjan Saxena       30/06/2023            US-5195 Update costs on OLI upon Product Finder Re-run/ update of OLI
****************************************************************************/
public with sharing class ConvertTechnicalReqController {
    /****************************************************************************
* Author Name: Naina B
* Description: Convert Technical Requirement to OLI
* Created Date: 14/11/2022
* Last Modified Date: 
****************************************************************************/
    @AuraEnabled
    public static String createOLIRecord(String recordId){
        Savepoint sp;
        List<OpportunityLineItem> listOLI = new List<OpportunityLineItem>();
        List<OpportunityLineItem> listUpdateOLI = new List<OpportunityLineItem>(); //2003
        List<OpportunityLineItem> deletelistOLI = new List<OpportunityLineItem>();
        List<TechnicalRequirement__c> emptyProductTechList = new List<TechnicalRequirement__c>();
        List<TechnicalRequirement__c> productFinishTechList = new List<TechnicalRequirement__c>();
        List<TechnicalRequirement__c> emptyFinishTechList = new List<TechnicalRequirement__c>();
        List<Id> techIDList = new List<Id>();
        List<Id> oLIlst = new List<Id>(); //2003
        List<Id> inactiveFMTechList=new List<Id>();
        List<Id> inactiveProductTechList=new List<Id>();
        Map<ID,string> OldOpportunitystatusMap = new Map<ID,string>(); //US-3707
        Map<ID,string> NewOpportunitystatusMap = new Map<ID,string>(); //US-3707
        Map<ID,string> OldTechstatusIDMap = new Map<ID,string>(); //US-3707
            try{
            sp = Database.setSavepoint();
            for(TechnicalRequirement__c techLoop : [SELECT Id, Name, Active__c, Product__c, Product__r.IsActive,FinishedGoods__c,FinishedGoods__r.Active__c, FinishedGoods__r.Product__c, Quantity__c, Opportunity__c, Opportunity__r.StageName,  Opportunity__r.PriceBook2Id, Opportunity__r.CurrencyIsoCode, OpportunityProduct__c,OpportunityProduct__r.ProductFinderStatus__c, RecordTypeId, Opportunity__r.RecordTypeId, Opportunity__r.Incoterms__c FROM TechnicalRequirement__c WHERE Opportunity__c =: recordId AND Active__c =: TRUE]){
                 OldOpportunitystatusMap.put(techLoop.OpportunityProduct__c,techLoop.OpportunityProduct__r.ProductFinderStatus__c); //US-3707 start
                OldTechstatusIDMap.put(techLoop.Id,techLoop.OpportunityProduct__r.ProductFinderStatus__c);
                if((techLoop.Opportunity__r.StageName == ConstantClass.FINALCHECK_STAGENAME) || (techLoop.Opportunity__r.StageName == ConstantClass.OPEN_STAGENAME && techLoop.Opportunity__r.RecordTypeId == ConstantClass.OPPORTUNITY_PI_RECORDTYPE && techLoop.RecordTypeId == ConstantClass.TRLIGHT_RECORDTYPE)){
                    if(techLoop.FinishedGoods__c != null && techLoop.Product__c == null){
                        emptyProductTechList.add(techLoop);
                    }else if(techLoop.Product__c != null &&  techLoop.FinishedGoods__c == null){
                        techIDList.add(techLoop.Id);
                        emptyFinishTechList.add(techLoop);
                    }else if(techLoop.FinishedGoods__c != null && techLoop.Product__c != null){
                        productFinishTechList.add(techLoop);
                    }else if(techLoop.FinishedGoods__c == null && techLoop.Product__c == null){
                        return system.Label.CTOLI_ValidationProductFMN; //US-916
                    }
                    if(techLoop.FinishedGoods__c!=null && techLoop.FinishedGoods__r.Active__c == false){
                        inactiveFMTechList.add(techLoop.Id);
                    }
                    if(techLoop.Product__c!=null && techLoop.Product__r.IsActive == false){
                        inactiveProductTechList.add(techLoop.Id);
                    }
                }else{
                    if(techLoop.RecordTypeId == ConstantClass.TRLIGHT_RECORDTYPE){
                        return system.Label.CheckOpenStage;
                    }
                    else{
                        return system.Label.CheckFinalCheckStage; //US-1250
                    }
                    
                }
            }
            if(!inactiveFMTechList.isEmpty()){
                return system.Label.InactiveOppFMNVaildation;
            }else if(!inactiveProductTechList.isEmpty()){
                return system.Label.InactiveOppProductVaildation;
            }else if(!emptyProductTechList.isEmpty() || !emptyFinishTechList.isEmpty() || !productFinishTechList.isEmpty()){
                for(TechnicalRequirement__c prList : emptyProductTechList){
                    OLINewExistingWrapper wrapperNewData = getOLIRecord(prList, prList.FinishedGoods__c, prList.FinishedGoods__r.Product__c, ConstantClass.FMNSPECIFIED_FINDERSTATUS, null);
                    if(wrapperNewData.oliRecordNew != null && !wrapperNewData.checkExisting){
                        listOLI.add(wrapperNewData.oliRecordNew);
                    }else if(wrapperNewData.oliRecordNew != null && wrapperNewData.checkExisting){
                        listUpdateOLI.add(wrapperNewData.oliRecordNew);
                    }
                    if(wrapperNewData.oliRecordExisting != null){
                        deletelistOLI.add(wrapperNewData.oliRecordExisting);
                    }
                }
                if(!techIDList.isEmpty()){
                    Map<Id, ConvertTechReqToOLI.FMHZVstatusreturnwrapper> mapIdvsWrapper = ConvertTechReqToOLI.productFinderToolbulk(techIDList);
                    for(TechnicalRequirement__c fmList : emptyFinishTechList){
                        if(mapIdvsWrapper.containsKey(fmList.Id)){
                            OLIwrapper wrapperData = (OLIwrapper) JSON.deserialize(JSON.serialize(mapIdvsWrapper.get(fmList.Id)), OLIwrapper.class);
                            OLINewExistingWrapper wrapperNewData = getOLIRecord(fmList, wrapperData.fMID, fmList.Product__c, wrapperData.status, wrapperData.hZVID);
                            if(wrapperNewData.oliRecordNew != null && !wrapperNewData.checkExisting){
                                listOLI.add(wrapperNewData.oliRecordNew);
                            }else if(wrapperNewData.oliRecordNew != null && wrapperNewData.checkExisting){
                                listUpdateOLI.add(wrapperNewData.oliRecordNew);
                            }
                            if(wrapperNewData.oliRecordExisting != null){
                                deletelistOLI.add(wrapperNewData.oliRecordExisting);
                            }
                        }
                    }
                }
                for(TechnicalRequirement__c prFMList : productFinishTechList){
                    OLINewExistingWrapper wrapperNewData = getOLIRecord(prFMList, prFMList.FinishedGoods__c, prFMList.Product__c, '', null);
                    if(wrapperNewData.oliRecordNew != null && !wrapperNewData.checkExisting){
                        listOLI.add(wrapperNewData.oliRecordNew);
                    }else if(wrapperNewData.oliRecordNew != null && wrapperNewData.checkExisting){
                        listUpdateOLI.add(wrapperNewData.oliRecordNew);
                    }
                    if(wrapperNewData.oliRecordExisting != null){
                        deletelistOLI.add(wrapperNewData.oliRecordExisting);
                    }
                }
                if(!listOLI.isEmpty()){
                    For(opportunitylineitem oliDataRecord : listOLI){
                         if((OldTechstatusIDMap.get(oliDataRecord.TechnicalRequirement__c) != ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS && OldTechstatusIDMap.get(oliDataRecord.TechnicalRequirement__c) != ConstantClass.REACHOUTTOCON_FINDERSTATUS ) &&
                        (oliDataRecord.ProductFinderStatus__c == ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS || oliDataRecord.ProductFinderStatus__c == ConstantClass.REACHOUTTOCON_FINDERSTATUS )
                        ){
                            oliDataRecord.CostOfProduction__c = 0;
                            oliDataRecord.ExternalCostOfProduction__c = 0;
                    }
                    }
                    insert listOLI;
                    //US-2003
                    if(!deletelistOLI.isEmpty()){
                        delete deletelistOLI;
                    }
                }
                //2003 - start
                if(!listUpdateOLI.isEmpty()){
                    update listUpdateOLI;
                    for(opportunitylineitem oli : listUpdateOLI){
                        oLIlst.add(oli.id);
                    }
                }
                if(!oLIlst.isEmpty()){
                    //US-3707 start
                     for(opportunitylineitem oli : listUpdateOLI){ 
                        NewOpportunitystatusMap.put(oli.Id, oli.ProductFinderStatus__c);
                    }
                    ConvertTechReqToOLI.pricingtoolcontroller(oLIlst,OldOpportunitystatusMap,NewOpportunitystatusMap);    //US-3707 stop
                }
                return system.Label.Success_Message_OLI;
                //2003 - end
            }else{
                return system.Label.CheckTechReqInactive; //US-1250
            }
        }catch(Exception e){
            Database.RollBack(sp);
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.publishException(ConstantClass.OPPORTUNITYLINEITEM_OBJECT, ConstantClass.OLIEXCEPTIONERROR_MSG, recordId,exdetails, ConstantClass.APEX_CLASS);
            return system.Label.ErrorMessageOLI +' '+exdetails;
        }
    }
    
    /****************************************************************************
* Author Name: Naina B
* Description: return new OLI record
* Created Date: 14/11/2022
* Last Modified Date: 09/01/2023
****************************************************************************/
   public static OLINewExistingWrapper getOLIRecord(TechnicalRequirement__c techRecord, String finishedGoodsId, String productId, String productFinderStatus, String semiFinishedGoodsId){
        OpportunityLineItem oliRecord = new opportunitylineitem();
        OpportunityLineItem oliRecordExisting = new opportunitylineitem();
        OLINewExistingWrapper wrapperForOli = new OLINewExistingWrapper();
        //2003 start
        if(techRecord.OpportunityProduct__c != null){
            List<OpportunityLineItem> oliRecordExistingList = getOpportunityLineItemList(new List<Id>{techRecord.OpportunityProduct__c});
            oliRecordExisting = oliRecordExistingList[0];
            if(oliRecordExisting.Product2Id != productId){
                oliRecord  = oliRecordExisting.clone(false, false, false, false);
                oliRecordExisting = null;
                wrapperForOli.oliRecordExisting = oliRecordExistingList[0];
                wrapperForOli.checkExisting = false;
                oliRecord.Product2Id = productId;
                oliRecord.PricebookEntryId = getPriceBookEntryId(techRecord.Opportunity__r.PriceBook2Id, productId, techRecord.Opportunity__r.CurrencyIsoCode); //1209
            }else{
                oliRecord.Id = oliRecordExisting.Id;
                wrapperForOli.oliRecordExisting = null;
                wrapperForOli.checkExisting = true;
            }
        }else{
            oliRecord.PricebookEntryId =  getPriceBookEntryId(techRecord.Opportunity__r.PriceBook2Id, productId, techRecord.Opportunity__r.CurrencyIsoCode); //1209
            oliRecord.Product2Id = productId;
            oliRecord.OpportunityId = techRecord.Opportunity__c;
            wrapperForOli.oliRecordExisting = null;
            wrapperForOli.checkExisting = false;
        }
        oliRecord.TechnicalRequirement__c = oliRecordExisting != null ? oliRecordExisting.TechnicalRequirement__c == techRecord.Id ? oliRecordExisting.TechnicalRequirement__c : techRecord.Id : techRecord.Id;
        oliRecord.FinishedGoods__c = oliRecordExisting != null ? oliRecordExisting.FinishedGoods__c == finishedGoodsId ? oliRecordExisting.FinishedGoods__c : finishedGoodsId : finishedGoodsId;
        oliRecord.ProductFinderStatus__c = oliRecordExisting != null ? oliRecord.ProductFinderStatus__c == productFinderStatus ? oliRecord.ProductFinderStatus__c : productFinderStatus : productFinderStatus;
        oliRecord.UnitPrice = oliRecordExisting != null ? oliRecordExisting.FinalPrice__c != null ? oliRecordExisting.FinalPrice__c : 0 : 0;
        oliRecord.SemiFinishedGoods__c = oliRecordExisting != null ? oliRecordExisting.SemiFinishedGoods__c == semiFinishedGoodsId ? oliRecordExisting.SemiFinishedGoods__c : semiFinishedGoodsId : semiFinishedGoodsId;
        oliRecord.Quantity = oliRecordExisting != null ? oliRecordExisting.Quantity == techRecord.Quantity__c ? oliRecordExisting.Quantity : techRecord.Quantity__c : techRecord.Quantity__c;
        //3707 start
       if(oliRecordExisting != null)
       if((oliRecordExisting.ProductFinderStatus__c != ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS && oliRecordExisting.ProductFinderStatus__c != ConstantClass.REACHOUTTOCON_FINDERSTATUS ) &&
              (oliRecord.ProductFinderStatus__c == ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS || oliRecord.ProductFinderStatus__c == ConstantClass.REACHOUTTOCON_FINDERSTATUS )
              ){
                oliRecord.CostOfProduction__c = 0;
                oliRecord.ExternalCostOfProduction__c = 0;  
              }
       //3707 stop
       wrapperForOli.oliRecordNew = oliRecord;
        return wrapperForOli;
         //2003 end
    }
    
    /****************************************************************************
* Author Name: Naina B
* Description: Wapper class
* Created Date: 14/11/2022
* Last Modified Date: 
****************************************************************************/
    public class OLIwrapper{
        ID fMID {get; set;}
        ID hZVID {get; set;}
        String status {get; set;}
        
    } 
 /****************************************************************************
* Author Name: Naina B
* Description: Wapper class
* Created Date: 02/02/2022
* Last Modified Date: 
****************************************************************************/
    public class OLINewExistingWrapper{
        OpportunityLineItem oliRecordNew {get; set;}
        OpportunityLineItem oliRecordExisting {get; set;}
        Boolean checkExisting {get; set;}
    }
    /****************************************************************************
* Author Name: Naina B
* Description: getting OpportunityLineItem record
* Created Date: 02/02/2022
* Last Modified Date: 
****************************************************************************/
    public static List<OpportunityLineItem> getOpportunityLineItemList(List<Id> trOLIId){
        String fieldsNames = '';
        for (Schema.SObjectField sObjectField : OpportunityLineItem.SObjectType.getDescribe().fields.getMap().values()) {
            fieldsNames += sObjectField.getDescribe().getName() + ',';
        }
        fieldsNames = fieldsNames.removeEnd(',');
        String fieldsNames1 = fieldsNames.replace('TotalPrice,','Opportunity.Incoterms__c,');
        String soqlQuery = 'SELECT ' + String.escapeSingleQuotes(fieldsNames1) + ' FROM OpportunityLineItem Where Id In :trOLIId';
        List<OpportunityLineItem> oLIMaster = Database.query(soqlQuery);
        return oLIMaster;
    }
    
 /****************************************************************************
* Author Name: Naina B
* Description: getting PriceBookEntryId
* Created Date: 15/02/2022
* Last Modified Date: 
****************************************************************************/
    public static Id getPriceBookEntryId(Id priceBookId, Id productId, String isoCode){
        Id returnvalue = null;
        PriceBookEntry  newPriceBEntry = new PriceBookEntry();
        PricebookEntry standardPriceBEntry = new PriceBookEntry();
            List<PriceBookEntry> pbeList = [SELECT Id, Pricebook2Id, Product2Id, IsActive FROM PriceBookEntry WHERE Pricebook2Id =: priceBookId AND Product2Id =: productId AND IsActive = true AND CurrencyIsoCode =: isoCode LIMIT 1];
            Map<string,ID> PBETRIDMAP = new Map<string,ID>(); 
            for(PriceBookEntry pbepr : [SELECT Id, Pricebook2Id, Product2Id, IsActive,CurrencyIsoCode FROM PriceBookEntry WHERE Product2Id =: productId AND IsActive = true ]){
                    string prdpb = pbepr.Product2Id +''+ pbepr.Pricebook2Id + pbepr.CurrencyIsoCode;
                    PBETRIDMAP.put(prdpb,pbepr.Id);
            }
          if(pbeList.isEmpty()){
                Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true ];
              if(!PBETRIDMAP.containskey(productId+''+standardPB.Id+isoCode)){
                standardPriceBEntry.Product2Id = productId;
                standardPriceBEntry.Pricebook2Id = standardPB.Id;
                standardPriceBEntry.IsActive = true;
                standardPriceBEntry.UnitPrice = 0; 
                standardPriceBEntry.CurrencyIsoCode = isoCode; //US-4536
                Insert standardPriceBEntry;
                returnvalue = standardPriceBEntry.Id; 
              }
             if(priceBookId != standardPB.Id && !PBETRIDMAP.containskey(productId+''+priceBookId+isoCode)){
                  newPriceBEntry.Product2Id = productId;
                newPriceBEntry.Pricebook2Id = priceBookId;
                newPriceBEntry.IsActive = true;
                newPriceBEntry.UnitPrice = 0; 
                newPriceBEntry.CurrencyIsoCode = isoCode;
                Insert newPriceBEntry;
              returnvalue = newPriceBEntry.Id;
              }
                
          }else{
              returnvalue = pbeList[0].Id;
          }
         return returnvalue;
    }
   
}