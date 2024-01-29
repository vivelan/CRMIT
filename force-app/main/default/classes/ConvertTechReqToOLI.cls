/****************************************************************************
* Name: ConvertTechReqToOLI
* Author: Gunjan Saxena
* Created Date: 08/11/2022
* Description: Class to be called on button click from technical requirement
to convert it to an OLI
*****************************************************************************/
/*****************************************************************************
* Modification log
* Name              Date                    Description
* Developer Name    Date of Modification    Modification Description   
* Naina Butle         25/11/2022            US-856 Added search parameters DimensionA__c,DimensionB__c and handle condition based on flat value.
* Naina Butle         19/01/2023            US-1534 Added the active flag for Semifinished Goods
* Gunjan Saxena       18/04/2023            US-3707 Update costs on OLI upon Product Finder Re-run/ update of OLI
****************************************************************************/
public with sharing class ConvertTechReqToOLI {
    @InvocableMethod(label = 'Convert Technical Requirement To OLI'
        description = 'Button click from technical requirement to convert it to an OLI'
        category = 'TechnicalRequirement')
    public static List < string > ConvertTechnicalRequirementToOLI(List < ID > trIDlst) {
        string Message = '';
        Map<Id, FMHZVstatusreturnwrapper> fmidmap = productFinderToolbulk(trIDlst);
        List<OpportunityLineItem> olitoupdate = new List<OpportunityLineItem>();
        List<OpportunityLineItem> olitoinsert = new List<OpportunityLineItem>();
        List<OpportunityLineItem> olitoinsertwithpbe = new List<OpportunityLineItem>();
        List<OpportunityLineItem> olitoinsertwopbe = new List<OpportunityLineItem>();
        List<OpportunityLineItem> olitodelete = new List<OpportunityLineItem>(); //2003
        Map<ID, ID> trIdVsProductId = new Map<ID, ID>(); //2003
        Map<Id, TechnicalRequirement__c> trIdVsTrMap = new Map<Id, TechnicalRequirement__c>(); //2003;
        List<OpportunityLineItem> oliClone = new List<OpportunityLineItem>(); //2003
        List<ID> existingOLIId = new List<ID>(); //2411
        List<ID> existingolitrid = new List<ID>();
        List<ID> ProductIDlst = new List<ID>();
        List<PriceBookEntry>  newPriceBEntrylst = new List<PriceBookEntry>();
        Map<ID,string> PBISOMAP = New Map<ID,string>();
        Map<ID,ID> OpportunityPricebookIDMap = new Map<ID,ID>(); // US-1679
        Map<ID,string> OldOpportunitystatusMap = new Map<ID,string>(); //US-3707
        Map<ID,string> NewOpportunitystatusMap = new Map<ID,string>(); //US-3707
        Map<ID,string> OldTechstatusIDMap = new Map<ID,string>(); //US-3707
        Map<ID,string> NewTechstatusIDMap = new Map<ID,string>(); //US-3707
        Map<ID,string> oppcurcode = new Map<ID,string>(); //US-5195
        string PricebookId = '';
        try{
            for(OpportunityLineItem existingoli : [SELECT ID, TechnicalRequirement__c, TechnicalRequirement__r.Opportunity__c,
                                                   UnitPrice, Quantity, Opportunity.Pricebook2Id, TechnicalRequirement__r.Product__c, TechnicalRequirement__r.FinishedGoods__r.Product__c,
                                                   TechnicalRequirement__r.Quantity__c,FinalPrice__c, Opportunity.Incoterms__c, Product2Id,ProductFinderStatus__c FROM OpportunityLineItem
                                                   WHERE TechnicalRequirement__c IN :trIDlst]){
                                                       OldOpportunitystatusMap.put(existingoli.Id,existingoli.ProductFinderStatus__c);
                                                       OldTechstatusIDMap.put(existingoli.TechnicalRequirement__c,existingoli.ProductFinderStatus__c);
                                                       if(fmidmap.containskey(existingoli.TechnicalRequirement__c)){
                                                           FMHZVstatusreturnwrapper fmn =   fmidmap.get(existingoli.TechnicalRequirement__c);
                                                           existingoli.FinishedGoods__c = fmn.fmid;
                                                           existingoli.SemiFinishedGoods__c = fmn.hzvid;
                                                           existingoli.ProductFinderstatus__c = fmn.status;
                                                           NewOpportunitystatusMap.put(existingoli.Id,existingoli.ProductFinderstatus__c);
                                                           NewTechstatusIDMap.put(existingoli.TechnicalRequirement__c,existingoli.ProductFinderstatus__c);
                                                           existingoli.Quantity = existingoli.TechnicalRequirement__r.Quantity__c;                    
                                                           if(existingoli.FinalPrice__c != null){
                                                               existingoli.UnitPrice = existingoli.FinalPrice__c;  
                                                           }else{
                                                               existingoli.UnitPrice = 0; 
                                                           }
                                                           olitoupdate.add(existingoli);
                                                           existingolitrid.add(existingoli.TechnicalRequirement__r.Id);
                                                       }
                                                       if(!trIdVsProductId.containsKey(existingoli.TechnicalRequirement__c)){
                                                           trIdVsProductId.put(existingoli.TechnicalRequirement__c, existingoli.Product2Id); //2003
                                                       }
                                                   }
            if(!olitoupdate.isEmpty()){
                update olitoupdate;
            }
            //2003 start
            List<TechnicalRequirement__c> trNewList = [SELECT Id, Product__c, Opportunity__r.Pricebook2Id, FinishedGoods__r.Product__c, OpportunityProduct__c, //2003
                                                       Opportunity__c, Quantity__c, Opportunity__r.Incoterms__c,Opportunity__r.CurrencyIsoCode FROM TechnicalRequirement__c
                                                       WHERE Id IN :trIDlst ];
            for(TechnicalRequirement__c trNew : trNewList){
                OpportunityPricebookIDMap.put(trNew.Opportunity__c,trNew.Opportunity__r.Pricebook2Id);
                oppcurcode.put(trNew.Opportunity__c,trNew.Opportunity__r.CurrencyIsoCode);
                existingOLIId.add(trNew.OpportunityProduct__c); //2411
                if(trNew.Product__c != null){
                    if(trNew.Product__c != trIdVsProductId.get(trNew.Id)){ //2003
                        if(!trIdVsTrMap.containsKey(trNew.id)){
                            trIdVsTrMap.put(trNew.id, trNew);
                        }
                    }
                } 
                if(trNew.FinishedGoods__r.Product__c != null){
                    if(trNew.FinishedGoods__r.Product__c != trIdVsProductId.get(trNew.Id)){ //2003
                        if(!trIdVsTrMap.containsKey(trNew.id)){
                            trIdVsTrMap.put(trNew.id, trNew);
                        }
                    }
                }   
            }
            if(!trIdVsTrMap.isEmpty()){ //2003
                for(OpportunityLineItem oliDataRecord : ConvertTechnicalReqController.getOpportunityLineItemList(existingOLIId))
                {
                    olitodelete.add(oliDataRecord);
                    oliClone.add(oliDataRecord.clone(false, false, false, false));
                }
                for(OpportunityLineItem oliDataRecord : oliClone){
                    if(trIdVsTrMap.get(oliDataRecord.TechnicalRequirement__c).Product__c != null){
                        oliDataRecord.Product2Id = trIdVsTrMap.get(oliDataRecord.TechnicalRequirement__c).Product__c;
                        ProductIDlst.add(trIdVsTrMap.get(oliDataRecord.TechnicalRequirement__c).Product__c);
                    }else{
                        oliDataRecord.Product2Id = trIdVsTrMap.get(oliDataRecord.TechnicalRequirement__c).FinishedGoods__r.Product__c;
                        ProductIDlst.add(trIdVsTrMap.get(oliDataRecord.TechnicalRequirement__c).FinishedGoods__r.Product__c);
                    }
                    if((OldTechstatusIDMap.get(oliDataRecord.TechnicalRequirement__c) != ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS && OldTechstatusIDMap.get(oliDataRecord.TechnicalRequirement__c) != ConstantClass.REACHOUTTOCON_FINDERSTATUS ) &&
                        (oliDataRecord.ProductFinderStatus__c == ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS || oliDataRecord.ProductFinderStatus__c == ConstantClass.REACHOUTTOCON_FINDERSTATUS )
                        ){
                            oliDataRecord.CostOfProduction__c = 0;
                            oliDataRecord.ExternalCostOfProduction__c = 0;
                    }
                    olitoinsert.add(oliDataRecord);
                }
            }
            //2003 end
            for(TechnicalRequirement__c tr : trNewList){
                if(tr.Opportunity__r.CurrencyIsoCode != null){
                   PBISOMAP.put(tr.Opportunity__c, tr.Opportunity__r.CurrencyIsoCode); 
                }
                if(fmidmap.containskey(tr.Id)){
                                                      FMHZVstatusreturnwrapper fmn =  fmidmap.get(tr.Id); 
                                                      OpportunityLineItem olinsert = new OpportunityLineItem();
                                                      if(tr.Product__c != null){
                                                          olinsert.Product2Id = tr.Product__c;
                                                          if(!ProductIDlst.contains(tr.Product__c)) //2003
                                                              ProductIDlst.add(tr.Product__c);
                                                      }else{
                                                          olinsert.Product2Id = tr.FinishedGoods__r.Product__c;
                                                          if(!ProductIDlst.contains(tr.FinishedGoods__r.Product__c)) //2003
                                                              ProductIDlst.add(tr.FinishedGoods__r.Product__c);
                                                      }
                                                      olinsert.OpportunityId = tr.Opportunity__c;
                                                      olinsert.TechnicalRequirement__c = tr.Id;
                                                      if(fmn != null){
                                                          if (fmn.fmid != null){olinsert.FinishedGoods__c = fmn.fmid;}
                                                          if (fmn.hzvid != null){olinsert.SemiFinishedGoods__c = fmn.hzvid;}
                                                          if (fmn.status != null){olinsert.ProductFinderstatus__c = fmn.status;}
                                                      }
                                                      olinsert.Quantity = tr.Quantity__c;
                                                      olinsert.UnitPrice = 0;
                                                      if(!existingolitrid.contains(tr.Id)){
                                                          olitoinsert.add(olinsert); 
                                                      }
                                                  }   
           }
            Map<string,ID> PBETRIDMAP = new Map<string,ID>(); 
            for(PriceBookEntry pbeList : [SELECT Id, Pricebook2Id, Product2Id, IsActive,CurrencyIsoCode FROM PriceBookEntry WHERE Product2Id =: ProductIDlst AND IsActive = true ]){
                    string prdpb = pbeList.Product2Id +''+ pbeList.Pricebook2Id + pbeList.CurrencyIsoCode;
                    PBETRIDMAP.put(prdpb,pbeList.Id);
                    PricebookId = pbeList.Pricebook2Id;
            }
            Pricebook2   Pricebook = [SELECT Name, Id FROM Pricebook2 where Name = :ConstantClass.PricebookStandard Limit 1]; //1679
            for(opportunitylineitem oli : olitoinsert){ 
                if(OpportunityPricebookIDMap.containskey(oli.OpportunityID) && OpportunityPricebookIDMap.get(oli.OpportunityID) != null){ //5195
                    PricebookId = OpportunityPricebookIDMap.get(oli.OpportunityID); //1679
                }else{
                    if((PricebookId == null || PricebookId == '')  && Pricebook != null){  //5195
                        PricebookId = Pricebook.Id;
                    }
                }
                string oliprdpb = oli.Product2Id + '' + PricebookId+oppcurcode.get(oli.OpportunityID);
                    
                if (PBETRIDMAP.keyset().contains(oliprdpb)) {
                    oli.PricebookEntryId = PBETRIDMAP.get(oli.Product2Id+PricebookId+oppcurcode.get(oli.OpportunityId));
                    olitoinsertwithpbe.add(oli);
                } else {
                    string stdpd = oli.Product2Id+''+Pricebook.Id+oppcurcode.get(oli.OpportunityID);
                    if(PricebookId != Pricebook.Id && !PBETRIDMAP.containskey(stdpd)){ //if opportunity dont have std pricebook
                        PriceBookEntry newstdPriceBEntry = new PriceBookEntry();
                        newstdPriceBEntry.Product2Id = oli.Product2Id;
                        newstdPriceBEntry.Pricebook2Id = Pricebook.Id;
                        newstdPriceBEntry.IsActive = true;
                        newstdPriceBEntry.UnitPrice = 0;
                        newstdPriceBEntry.CurrencyIsoCode = oppcurcode.get(oli.OpportunityId);
                        newPriceBEntrylst.add(newstdPriceBEntry);  // inserting std pricebook
                    }
                    PriceBookEntry newPriceBEntry = new PriceBookEntry();
                    newPriceBEntry.Product2Id = oli.Product2Id;
                    newPriceBEntry.Pricebook2Id = PricebookId;
                    newPriceBEntry.IsActive = true;
                    newPriceBEntry.UnitPrice = 0;
                    newPriceBEntry.CurrencyIsoCode = oppcurcode.get(oli.OpportunityId);
                    newPriceBEntrylst.add(newPriceBEntry);
                    
                    olitoinsertwopbe.add(oli);

                }
            }
                if (!newPriceBEntrylst.isempty()) {
                    Insert newPriceBEntrylst;
                    for (PriceBookEntry newPriceBEntry: newPriceBEntrylst) {
                        PBETRIDMAP.put(newPriceBEntry.Product2Id + '' + newPriceBEntry.Pricebook2Id, newPriceBEntry.Id);
                    }
                }
            insert olitoinsertwithpbe;
            for (opportunitylineitem oli: olitoinsertwopbe) {
                oli.PricebookEntryId = PBETRIDMAP.get(oli.Product2Id + '' + PricebookId);
            }
            if(!olitoinsertwopbe.isempty()){                
                insert olitoinsertwopbe;//1679   
            }
            //2003 Start
            if(!olitodelete.isEmpty()){
                delete olitodelete;
            }
            //2003 End

            List<Id> OLIlst = new List<Id>();
            for(opportunitylineitem oli : olitoupdate){
                OLIlst.add(oli.id);
            }
            for(opportunitylineitem oli : olitoinsertwopbe){
                if(!OldOpportunitystatusMap.keyset().contains(oli.Id) && OldTechstatusIDMap.containskey(oli.TechnicalRequirement__c)){
                        OldOpportunitystatusMap.put(oli.Id,OldTechstatusIDMap.get(oli.TechnicalRequirement__c));
                    }
                if(!NewOpportunitystatusMap.keyset().contains(oli.Id) && NewTechstatusIDMap.containskey(oli.TechnicalRequirement__c)){
                        NewOpportunitystatusMap.put(oli.Id,NewTechstatusIDMap.get(oli.TechnicalRequirement__c));
                    }
                OLIlst.add(oli.id);
            }
            for(opportunitylineitem oli : olitoinsertwithpbe){
                if(!OldOpportunitystatusMap.keyset().contains(oli.Id) && OldTechstatusIDMap.containskey(oli.TechnicalRequirement__c)){
                        OldOpportunitystatusMap.put(oli.Id,OldTechstatusIDMap.get(oli.TechnicalRequirement__c));
                    }
                if(!NewOpportunitystatusMap.keyset().contains(oli.Id) && NewTechstatusIDMap.containskey(oli.TechnicalRequirement__c)){
                        NewOpportunitystatusMap.put(oli.Id,NewTechstatusIDMap.get(oli.TechnicalRequirement__c));
                    }
                OLIlst.add(oli.id);
            }
            if (!OLIlst.isEmpty()) {
                pricingtoolcontroller(OLIlst,OldOpportunitystatusMap,NewOpportunitystatusMap);
            }
            Message = ConstantClass.SUCCESS;
        } catch (exception exe) {
            for (opportunitylineitem oli: olitoupdate) {
                ExceptionUtilClass.logException('TechnicalRequirement__c', 'ConvertTechReqToOLI', string.valueOf(oli.TechnicalRequirement__c), string.valueOf(exe), 'Update');
            }
            for (opportunitylineitem oli: olitoinsert) {
                ExceptionUtilClass.logException('TechnicalRequirement__c', 'ConvertTechReqToOLI', string.valueOf(oli.TechnicalRequirement__c), string.valueOf(exe), 'Insert');
            }
            Message = string.valueOf(exe);
        }
        List < string > returnlst = new List < string > ();
        returnlst.add(message);
        return returnlst;
    }
    @future(callout=true)
    public static void pricingtoolcontroller(List<Id> OLIlst,Map<ID,string> OldOpportunitystatusMap,Map<ID,string> NewOpportunitystatusMap){
       List<Id> PricingrequiredListId = new List<Id>();
        List<Id> ZeroListId = new List<Id>();
        for(Id olid: OLIlst){
           if((OldOpportunitystatusMap.get(olid) != ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS && OldOpportunitystatusMap.get(olid) != ConstantClass.REACHOUTTOCON_FINDERSTATUS ) &&
              (NewOpportunitystatusMap.get(olid) == ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS || NewOpportunitystatusMap.get(olid) == ConstantClass.REACHOUTTOCON_FINDERSTATUS )
              ){
                ZeroListId.add(olid); //3707
              }else{
                 PricingrequiredListId.add(olid); 
              } 
        }
        
        PricingToolController.upadateBulkCOP(PricingrequiredListId);
        List<opportunitylineitem> olilstzero = new List<opportunitylineitem>();
        for (opportunitylineitem oli : [Select Id,CostOfProduction__c, ExternalCostOfProduction__c  from opportunitylineitem where Id IN :ZeroListId]){
            oli.CostOfProduction__c = 0;
            oli.ExternalCostOfProduction__c = 0;
            olilstzero.add(oli);
        }
        If(!olilstzero.isempty())
        update olilstzero;
    }
    public static Map<Id, FMHZVstatusreturnwrapper> productFinderToolbulk(List<Id> technicalRequirementsToConvert){
        Map<Id, FMHZVstatusreturnwrapper> trfmmap = new Map<Id, FMHZVstatusreturnwrapper>();
        
        //Scenerio 0: When fmn value is provided on technical requirement detail page.
        //Product Finder status = 'fmn specified on Technical requirement'
        
        // Scenerio 1: When fmn value is not provided on technical requirement detail page. First fmn Search on below parameters
        // Quantity is required field on OLI and need on tr to be required or best way to reach the scenerio.
        // Product Finder status = 'Matching fmn found'
        List<ID> TRInductivelst = new List<ID>(); //US-2009
        Map<string,List<ID>> trprid = new Map<string,List<ID>>();//US-857
        Map<ID,Decimal> IDDim = new Map<ID,Decimal>();//US-857
        Map<ID,Decimal> FMIDDIMA = new Map<ID,Decimal>();//US-857
        Map<ID,decimal> mindimIDmap = new Map<ID,decimal>();//US-857
        Map<ID,decimal> maxdimIDmap = new Map<ID,decimal>();//US-857
        List<string> productlst = new List<string>();
        List<string> selnumberlst = new List<string>();
        List<string> rollingmilllst = new List<string>();
        List<Decimal> dimensionalst = new List<Decimal>();
        List<Decimal> dimensionblst = new List<Decimal>();
        List<string> primrollinghomogenizelst = new List<string>();
        List<string> primrollinginputformatlst = new List<string>();
        List<string> hzvchecktreatmentlst = new List<string>();
        List<string> heattreatmentlst = new List<string>();
        List<string> straighteninglst = new List<string>();
        List<string> peelingbarwirerodlst = new List<string>();
        List<string> surfacedefectinspeclst = new List<string>();
        List<string> usinspectionlst = new List<string>();
        Map<Id, string> trkey = new Map<Id, string>();
        Map<Id, string> trkeyFG = new Map<Id, string>(); //2279
        Map<Id, TechnicalRequirement__c> trIDtrkey = new Map<Id, TechnicalRequirement__c>();
        List<TechnicalRequirement__c> secscentechrlst = new List<TechnicalRequirement__c>();
        Map<string, Id> fmkey = new Map<string, Id>();
        //857 start
        Set<string> rmTrSet = new Set<string>();
        Set<string> procodeSet = new Set<string>();
        List<RollingMill__c> rmList = new List<RollingMill__c>();
        List<Decimal> dimAList = new List<Decimal>();
        List<Decimal> rmDimFromList =new List<Decimal>();
        List<Decimal> rmDimToList =new List<Decimal>();
        for(TechnicalRequirement__c tr:[SELECT Id,Rollingmill__c,Product__r.ProductCode,DimensionA__c,Product__r.Flat__c,Product__r.Family,
                                        InternalSteelGrade__r.ExcludeFromProductFinder__c,Peelingbarwirerod__c,SurfaceTreatment__c,MultipleStraightening__c,Surfacedefectinspec__c  
                                        FROM TechnicalRequirement__c WHERE ID IN:technicalRequirementsToConvert])
        {
            
            if((tr.Product__r.Flat__c== false && tr.Product__r.Family == 'Wire Rod' && tr.InternalSteelGrade__r.ExcludeFromProductFinder__c == false) || 
               (tr.Product__r.Family == 'Bar steel' && tr.Peelingbarwirerod__c== null && tr.SurfaceTreatment__c== null && tr.MultipleStraightening__c == null && tr.Surfacedefectinspec__c == null)){
                   rmTrSet.add(tr.Rollingmill__c);
                   procodeSet.add(tr.Product__r.ProductCode);
                   dimAList.add(tr.DimensionA__c);
                   IDDim.put(tr.Id,tr.DimensionA__c);
                   string prroll = 'p'+ (tr.Product__r.ProductCode != null ? tr.Product__r.ProductCode : '') + 'r' + (tr.Rollingmill__c != null ? tr.Rollingmill__c : '') ;
                   if(trprid.containskey(prroll)){
                       List<Id> trid = new List<Id>();
                       trid = trprid.get(prroll);
                       trid.add(tr.id);
                       trprid.put(prroll,trid); 
                   }else{
                       List<Id> trid = new list<ID>();
                       trid.add(tr.id);
                       trprid.put(prroll,trid);
                   }
               }
            if(tr.InternalSteelGrade__r.ExcludeFromProductFinder__c){
                TRInductivelst.add(tr.Id);
                FMHZVstatusreturnwrapper fmwr = new FMHZVstatusreturnwrapper(null,null,ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS); // 2793
                trfmmap.put(tr.Id, fmwr);
            }
        }
        If(rmTrSet.isempty()){
            rmTrSet.add(''); 
        }
        If(procodeSet.isempty()){
            procodeSet.add(''); 
        }
        dimAList.sort();
        if(!dimAList.isempty()){
            Decimal maxvalue = dimAList[0];
            For (integer i =0;i<dimAList.size();i++)
            { 
                if( dimAList[i] > maxvalue)
                    maxvalue = dimAList[i];             
            }  
            rmList =[SELECT Id,name,DimenstionTo__c, DimensionFrom__c, ExternalID__c, ProductCode__c,RollingMill__c from RollingMill__c 
                     WHERE RollingMill__c IN:rmTrSet  AND ProductCode__c IN:procodeSet AND DimensionFrom__c <= :maxvalue AND DimenstionTo__c >= :dimAList[0] order by DimensionFrom__c ASC];
            for(RollingMill__c rm:rmList)
            {
                rmDimFromList.add(rm.DimensionFrom__c);
                rmDimToList.add(rm.DimenstionTo__c);
                string prroll = 'p'+ (rm.ProductCode__c != null ? rm.ProductCode__c : '') + 'r' + (rm.RollingMill__c != null ? rm.RollingMill__c : '') ;
                for(ID trid: trprid.get(prroll)){
                    if(!mindimIDmap.containskey(trid)){
                        if(IDDim.get(trid)>=rm.DimensionFrom__c && IDDim.get(trid)<=rm.DimenstionTo__c){
                            mindimIDmap.put(trid,rm.DimensionFrom__c);
                            maxdimIDmap.put(trid,rm.DimenstionTo__c); 
                        }           
                    }
                    
                }            
            }
            
        }
        
        
        
        
        rmDimFromList.sort();
        rmDimToList.sort();
        
        Map<Id,string> FMIDDim = new Map<Id,string>();
        Map<string,Map<Id,string>> strFMID = new Map<string,Map<Id,string>>();
        Decimal MinDim;
        Decimal MaxDim;
        if(!rmDimFromList.isempty() && !rmDimToList.isempty()){
            MinDim = rmDimFromList[0];
            MaxDim = rmDimToList[rmDimToList.size()-1];
        }
        //857 End
        for(TechnicalRequirement__c tr : [SELECT id, Product__c,Product__r.IsActive,Product__r.Family,Product__r.Flat__c,DimensionA__c, DimensionB__c, InternalSteelGrade__r.SelNumber__c,
                                          Rollingmill__c, PrimRollingHomogenize__c, HZVCheckTreatment__c, HeatTreatment__c,InternalSteelGrade__r.ExcludeFromProductFinder__c,
                                          SurfaceTreatment__c, Peelingbarwirerod__c, Surfacedefectinspec__c,  Inductive__c, MultipleStraightening__c,
                                          USInspection__c, PrimRollingInputformat__c,  Homogenize__c,FinishedGoods__c,HZVSampletest__c,HZVAnnealing__c
                                          FROM TechnicalRequirement__c  
                                          WHERE ID IN: technicalRequirementsToConvert]){
                                              //Scenerio 0: When fmn value is provided on technical requirement detail page.
                                              //Product Finder status = 'fmn specified on Technical requirement'
                                              if(tr.FinishedGoods__c != null){
                                                  FMHZVstatusreturnwrapper fmn = new FMHZVstatusreturnwrapper(tr.FinishedGoods__c,null,ConstantClass.fmnSPECIFIED_FINDERSTATUS);
                                                  trfmmap.put(tr.Id, fmn); // 0 scenerio
                                              }else{
                                                  // Scenerio 1: When fmn value is not provided on technical requirement detail page. First fmn Search on below parameters
                                                  // Quantity is required field on OLI and need on tr to be required or best way to reach the scenerio.
                                                  // Product Finder status = 'Matching fmn found'
                                                  if(tr.Product__r.IsActive == True){
                                                      productlst.add(tr.Product__c);
                                                  }                                                  
                                                  selnumberlst.add(tr.InternalSteelGrade__r.SelNumber__c);
                                                  rollingmilllst.add(tr.Rollingmill__c);
                                                  primrollinghomogenizelst.add(tr.PrimRollingHomogenize__c);
                                                  PrimRollingInputformatlst.add(tr.PrimRollingInputformat__c); 
                                                  hzvchecktreatmentlst.add(tr.HZVCheckTreatment__c);
                                                  heattreatmentlst.add(tr.HeatTreatment__c);
                                                  straighteninglst.add(tr.SurfaceTreatment__c);   
                                                  peelingbarwirerodlst.add(tr.Peelingbarwirerod__c);
                                                  surfacedefectinspeclst.add(tr.Surfacedefectinspec__c);
                                                  usinspectionlst.add(tr.USInspection__c);  
                                                  string strFM = '';
                                                  //US-856 - Start
                                                  if(tr.Product__r.Flat__c){
                                                      strFM = 'P' + tr.Product__c + 'SN' + tr.InternalSteelGrade__r.SelNumber__c + 'R' + tr.Rollingmill__c + 'DA' + tr.DimensionA__c + 'DB' + tr.DimensionB__c + 'PH' + tr.PrimRollingHomogenize__c +'PI'+ tr.PrimRollingInputformat__c  +'CT' + tr.HZVCheckTreatment__c + 'HT' + tr.HeatTreatment__c + 'ST' + tr.SurfaceTreatment__c + 'PW' + tr.Peelingbarwirerod__c + 'SD'+ tr.Surfacedefectinspec__c + 'UI'+ tr.USInspection__c;                           
                                                      dimensionalst.add(tr.DimensionA__c);
                                                      dimensionblst.add(tr.DimensionB__c);
                                                  }else if((tr.Product__r.Flat__c== false && tr.Product__r.Family == 'Wire Rod' && tr.InternalSteelGrade__r.ExcludeFromProductFinder__c == false) || // US-857
                                                           (tr.Product__r.Family == 'Bar steel' && tr.Peelingbarwirerod__c== null && tr.SurfaceTreatment__c== null && tr.MultipleStraightening__c == null && tr.Surfacedefectinspec__c == null)){
                                                               strFM = 'P' + tr.Product__c + 'SN' + tr.InternalSteelGrade__r.SelNumber__c + 'R'+ tr.Rollingmill__c + 'PH' + tr.PrimRollingHomogenize__c + 'PI' + tr.PrimRollingInputformat__c + 'CT' + tr.HZVCheckTreatment__c + 'HT' + tr.HeatTreatment__c + 'ST' + tr.SurfaceTreatment__c + 'PW' + tr.Peelingbarwirerod__c + 'SD' + tr.Surfacedefectinspec__c + 'UI' + tr.USInspection__c;       
                                                               //dimensionalst.add(tr.DimensionA__c); // US-857 stop
                                                           }else {
                                                               strFM = 'P' + tr.Product__c + 'SN' + tr.InternalSteelGrade__r.SelNumber__c + 'R'+ tr.Rollingmill__c + 'DA' + tr.DimensionA__c + 'PH' + tr.PrimRollingHomogenize__c + 'PI' + tr.PrimRollingInputformat__c + 'CT' + tr.HZVCheckTreatment__c + 'HT' + tr.HeatTreatment__c + 'ST' + tr.SurfaceTreatment__c + 'PW' + tr.Peelingbarwirerod__c + 'SD' + tr.Surfacedefectinspec__c + 'UI' + tr.USInspection__c;       
                                                               dimensionalst.add(tr.DimensionA__c);
                                                           }
                                                  //US-856 - End
                                                  trkey.put(tr.ID, strFM); 
                                                  trIDtrkey.put(tr.ID,tr);
                                              }
                                          }
        for(FinishedGoods__c fmn : [SELECT Id, Product__c, SteelGradeLookup__r.SELNumber__c, RollingMill__c,  DimensionA__c, DimensionB__c,
                                    PrimRollingHomogenize__c,PrimRollingInputFormat__c,HZVCheckTreatment__c,Straightening__c,
                                    PeelRodWire__c,SurfaceDefectInspec__c,HeatTreatment__c,USInspection__c,MaterialNumber__c FROM FinishedGoods__c 
                                    WHERE Product__c IN :productlst  AND SteelGradeLookup__r.SELNumber__c IN :selnumberlst AND
                                    RollingMill__c IN :rollingmilllst  AND  (  ( DimensionA__c >= :MinDim AND DimensionA__c <= :MaxDim ) OR DimensionA__c IN :dimensionalst OR DimensionB__c IN :dimensionblst ) 
                                    AND  PrimRollingHomogenize__c IN :primrollinghomogenizelst AND PrimRollingInputFormat__c IN :primrollinginputformatlst AND HeatTreatment__c IN :heattreatmentlst
                                    AND HZVCheckTreatment__c IN :hzvchecktreatmentlst AND Straightening__c IN :straighteninglst AND 
                                    PeelRodWire__c IN :peelingbarwirerodlst  AND SurfaceDefectInspec__c IN :surfacedefectinspeclst AND 
                                    USInspection__c IN :usinspectionlst  AND Active__c = True order BY MaterialNumber__c ]){
                                        string strFMA = 'P' + fmn.Product__c + 'SN' + fmn.SteelGradeLookup__r.SELNumber__c + 'R' + fmn.Rollingmill__c + 'DA' + fmn.DimensionA__c + 'DB' + fmn.DimensionB__c + 'PH' + fmn.PrimRollingHomogenize__c + 'PI' + fmn.PrimRollingInputformat__c + 'CT' + fmn.HZVCheckTreatment__c + 'HT' + fmn.HeatTreatment__c + 'ST' + fmn.Straightening__c + 'PW' + fmn.PeelRodWire__c + 'SD' + fmn.Surfacedefectinspec__c + 'UI' + fmn.USInspection__c;                           
                                        string strFMB = 'P' + fmn.Product__c + 'SN' + fmn.SteelGradeLookup__r.SELNumber__c + 'R' + fmn.Rollingmill__c + 'PH' + fmn.PrimRollingHomogenize__c + 'PI' + fmn.PrimRollingInputformat__c + 'CT'+ fmn.HZVCheckTreatment__c + 'HT' + fmn.HeatTreatment__c + 'ST' + fmn.Straightening__c + 'PW' + fmn.PeelRodWire__c + 'SD' + fmn.Surfacedefectinspec__c + 'UI' + fmn.USInspection__c;    
                                        string strFMC = 'P' + fmn.Product__c + 'SN' + fmn.SteelGradeLookup__r.SELNumber__c + 'R' + fmn.Rollingmill__c + 'DA' + fmn.DimensionA__c + 'PH' + fmn.PrimRollingHomogenize__c + 'PI' + fmn.PrimRollingInputformat__c + 'CT'+ fmn.HZVCheckTreatment__c + 'HT' + fmn.HeatTreatment__c + 'ST' + fmn.Straightening__c + 'PW' + fmn.PeelRodWire__c + 'SD' + fmn.Surfacedefectinspec__c + 'UI' + fmn.USInspection__c;     // US-857
                                        fmkey.put( strFMA, fmn.ID);
                                        fmkey.put( strFMB, fmn.ID);
                                        fmkey.put( strFMC, fmn.ID);
                                        if(strFMID.containskey(strFMB)){
                                            FMIDDim = strFMID.get(strFMB);
                                            FMIDDim.put(fmn.ID,fmn.MaterialNumber__c);
                                            strFMID.put(strFMB,FMIDDim);
                                            FMIDDIMA.put(fmn.ID,fmn.DimensionA__c);
                                            //FMIDDim.clear(); 
                                        }else{
                                            FMIDDim.put(fmn.ID,fmn.MaterialNumber__c);//Material number
                                            strFMID.put(strFMB,FMIDDim);
                                            FMIDDIMA.put(fmn.ID,fmn.DimensionA__c);
                                        }
                                    }
        for(StrING trid : trkey.keySet()){
            list<string> materiallst = new list<string>();
            string maxmaterial = '';
            if(strFMID.get(trkey.get(trid)) != null){
                materiallst = strFMID.get(trkey.get(trid)).values();
                FMIDDim = strFMID.get(trkey.get(trid));
                materiallst.sort(); 
                maxmaterial = materiallst[materiallst.size()-1];
            }
            if(fmkey.containskey(trkey.get(trid ))){
                    FMHZVstatusreturnwrapper fmwr = new FMHZVstatusreturnwrapper(fmkey.get(trkey.get(trid )),null,ConstantClass.MATCHINGFMN_FINDERSTATUS);
                    trfmmap.put(trid, fmwr);  
            }else{
                secscentechrlst.add(trIDtrkey.get(trid));
            }
            if(strFMID.get(trkey.get(trid)) != null){
                for(id fid : strFMID.get(trkey.get(trid)).keyset()){
                    if(FMIDDIMA.get(fid)>= mindimIDmap.get(trid) && FMIDDIMA.get(fid)<= maxdimIDmap.get(trid)){
                        if(strFMID.get(trkey.get(trid)).get(fid) == maxmaterial && !TRInductivelst.contains(trid)){
                                FMHZVstatusreturnwrapper fmwr = new FMHZVstatusreturnwrapper(fid,null,ConstantClass.MATCHINGFMN_FINDERSTATUS); 
                                trfmmap.put(trid, fmwr);
                        }
                    }
                    
                }
            }
        }
        
        
        // SCENERIO 2
        // Search fmn for excuded tr records from Scenrio 1
        // status = ''Inductive heat treatment. Reach out to Controlling'
        // AND SCENERIO 3
        if(!secscentechrlst.isempty()){
            fmkey.clear();
            productlst.clear();
            rollingmilllst.clear();
            dimensionalst.clear();
            dimensionblst.clear();
            heattreatmentlst.clear();
            peelingbarwirerodlst.clear();
            surfacedefectinspeclst.clear();
            usinspectionlst.clear();
            trkey.clear();
            trfmmap.clear();
            selnumberlst.clear();
            primrollinghomogenizelst.clear();
            primrollinginputformatlst.clear();   
            hzvchecktreatmentlst.clear();
            List<string> hzvsampletestlst = new List<string>();
            List<string> annealinglst = new  List<string>();
            List<string> homogenizelst = new  List<string>();
            
            for(TechnicalRequirement__c tr :secscentechrlst){
                if(tr.Product__r.IsActive == True){
                    productlst.add(tr.Product__c);
                }
                rollingmilllst.add(tr.Rollingmill__c);
                heattreatmentlst.add(tr.HeatTreatment__c);
                straighteninglst.add(tr.SurfaceTreatment__c);   
                peelingbarwirerodlst.add(tr.Peelingbarwirerod__c);
                surfacedefectinspeclst.add(tr.Surfacedefectinspec__c);
                usinspectionlst.add(tr.USInspection__c);  
                selnumberlst.add(tr.InternalSteelGrade__r.SELNumber__c);
                primrollinghomogenizelst.add(tr.PrimRollingHomogenize__c);
                primrollinginputformatlst.add(tr.PrimRollingInputformat__c);
                hzvchecktreatmentlst.add(tr.HZVCheckTreatment__c);
                hzvsampletestlst.add(tr.HZVSampletest__c);
                annealinglst.add(tr.HZVAnnealing__c);
                homogenizelst.add(tr.Homogenize__c);
                string strFM = '';
                //US-856 - Start
                if(tr.Product__r.Flat__c){
                    strFM = 'P' + tr.Product__c + 'R' + tr.Rollingmill__c + 'DA' + tr.DimensionA__c + 'DB' + tr.DimensionB__c + 'HT' + tr.HeatTreatment__c + 'ST' + tr.SurfaceTreatment__c + 'PW' + tr.Peelingbarwirerod__c + 'SD' + tr.Surfacedefectinspec__c + 'UI' + tr.USInspection__c;                       
                    dimensionalst.add(tr.DimensionA__c);
                    dimensionalst.add(tr.DimensionB__c);
                }else if((tr.Product__r.Flat__c== false && tr.Product__r.Family == 'Wire Rod' && tr.InternalSteelGrade__r.ExcludeFromProductFinder__c == false) || 
                         (tr.Product__r.Family == 'Bar steel' && tr.Peelingbarwirerod__c== null && tr.SurfaceTreatment__c== null && tr.MultipleStraightening__c == null && tr.Surfacedefectinspec__c == null)){
                             strFM = 'P' + tr.Product__c + 'R'+ tr.Rollingmill__c + 'DA' + tr.DimensionA__c +  'HT' + tr.HeatTreatment__c + 'ST' + tr.SurfaceTreatment__c + 'PW' + tr.Peelingbarwirerod__c + 'SD' + tr.Surfacedefectinspec__c + 'UI' + tr.USInspection__c;       
                             //dimensionalst.add(tr.DimensionA__c);
                         }else{
                             strFM = 'P' + tr.Product__c + 'R' + tr.Rollingmill__c + 'HT' + tr.HeatTreatment__c + 'ST' + tr.SurfaceTreatment__c + 'PW' + tr.Peelingbarwirerod__c + 'SD' + tr.Surfacedefectinspec__c + 'UI' +tr.USInspection__c;  
                             dimensionalst.add(tr.DimensionA__c);
                         }
                //US-856 - End
                if(tr.Inductive__c ){
                    
                    TRInductivelst.add(tr.Id);
                    FMHZVstatusreturnwrapper fmwr = new FMHZVstatusreturnwrapper(null,null,ConstantClass.REACHOUTTOCON_FINDERSTATUS);//2009
                    trfmmap.put(tr.Id, fmwr);
                }else if(tr.InternalSteelGrade__r.ExcludeFromProductFinder__c){ 
                    TRInductivelst.add(tr.Id);
                    FMHZVstatusreturnwrapper fmwr = new FMHZVstatusreturnwrapper(null,null,ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS); // 2793
                    trfmmap.put(tr.Id, fmwr);  
                }else{
                    trkeyFG.put(tr.ID, strFM); // Inductive Check 
                }
                strFM = 'S' + tr.InternalSteelGrade__r.SELNumber__c + 'PH' + tr.PrimRollingHomogenize__c + 'PI' + tr.PrimRollingInputformat__c + 'HS' + tr.HZVSampletest__c + 'HC' + tr.HZVCheckTreatment__c + 'HA' + tr.HZVAnnealing__c + 'HG' + tr.Homogenize__c;                           
                trkey.put(tr.ID, strFM);
            }
            for(FinishedGoods__c fmn : [SELECT Id, Product__c, RollingMill__c,  DimensionA__c, DimensionB__c, HeatTreatment__c, 
                                        Straightening__c, PeelRodWire__c, SurfaceDefectInspec__c, USInspection__c FROM FinishedGoods__c 
                                        WHERE Product__c IN : productlst  AND RollingMill__c IN : rollingmilllst AND Active__c = True AND (( DimensionA__c >= :MinDim AND DimensionA__c <= :MaxDim ) OR DimensionA__c IN :dimensionalst  OR DimensionB__c IN : dimensionblst ) 
                                        AND HeatTreatment__c IN : heattreatmentlst AND Straightening__c IN :straighteninglst AND PeelRodWire__c IN : peelingbarwirerodlst
                                        AND SurfaceDefectInspec__c IN : surfacedefectinspeclst AND USInspection__c IN : usinspectionlst order BY MaterialNumber__c ]){
                                            string strFMA = 'P' + fmn.Product__c + 'R' + fmn.RollingMill__c + 'HT' + fmn.HeatTreatment__c + 'ST' + fmn.Straightening__c + 'PW'+ fmn.PeelRodWire__c + 'SD'+ fmn.SurfaceDefectInspec__c + 'UI' + fmn.USInspection__c ;
                                            string strFMC = 'P' + fmn.Product__c + 'R' + fmn.RollingMill__c + 'DA' + fmn.DimensionA__c + 'HT' + fmn.HeatTreatment__c + 'ST' + fmn.Straightening__c + 'PW'+ fmn.PeelRodWire__c + 'SD'+ fmn.SurfaceDefectInspec__c + 'UI' + fmn.USInspection__c ;
                                            string strFMB = 'P' + fmn.Product__c + 'R' + fmn.RollingMill__c + 'DA' + fmn.DimensionA__c + 'DB' + fmn.DimensionB__c + 'HT'+ fmn.HeatTreatment__c + 'ST' + fmn.Straightening__c + 'PW' + fmn.PeelRodWire__c + 'SD' + fmn.SurfaceDefectInspec__c + 'UI' + fmn.USInspection__c ;
                                            fmkey.put(strFMA, fmn.ID);
                                            fmkey.put(strFMB, fmn.ID);
                                            fmkey.put(strFMC, fmn.ID);
                                            
                                        }
            for(ID trid : trkey.keySet()){
                if(!(TRInductivelst.contains(trid))){ //Inductive check logic 
                    if(fmkey.containskey(trkey.get(trid))){
                        FMHZVstatusreturnwrapper fmwr = new FMHZVstatusreturnwrapper(fmkey.get(trkey.get(trid )),null,ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS);//2793
                        trfmmap.put(trid, fmwr);  
                    }
                }
            }
            Map<string,ID>     sfmkey = new Map<string,ID>();
            for(SemiFinishedGoods__c fmn : [SELECT Id,  SELNumber__c, ReblockHomogenize__c ,ReblockTapping__c, HZVSampleTest__c, 
                                            HZVCheckEdit__c, HZVStarting__c, Homogenize__c FROM SemiFinishedGoods__c 
                                            WHERE SELNumber__c IN : selnumberlst AND ReblockHomogenize__c IN : primrollinghomogenizelst AND     
                                            ReblockTapping__c IN : primrollinginputformatlst AND HZVSampleTest__c IN : hzvsampletestlst 
                                            AND  HZVCheckEdit__c IN : hzvchecktreatmentlst AND HZVStarting__c IN : annealinglst AND 
                                            Homogenize__c IN : homogenizelst AND Active__c = true]){
                                                string strFM  = '';
                                                strFM = 'S' + fmn.SELNumber__c  + 'PH' + fmn.ReblockHomogenize__c + 'PI' + fmn.ReblockTapping__c + 'HS' + fmn.HZVSampleTest__c + 'HC' + fmn.HZVCheckEdit__c + 'HA' + fmn.HZVStarting__c + 'HG' + fmn.Homogenize__c;                           
                                                sfmkey.put( strFM, fmn.ID);
                                            }
            for(ID trid : trkey.keySet()){
                if(!(TRInductivelst.contains(trid))){ //Inductive check logic
                    if(sfmkey.containskey(trkey.get(trid )) && fmkey.containskey(trkeyFG.get(trid))){ //US-2279
                        FMHZVstatusreturnwrapper fmwr = new FMHZVstatusreturnwrapper(fmkey.get(trkeyFG.get(trid)),sfmkey.get(trkey.get(trid)),ConstantClass.PRICEINDICATOR_FINDERSTATUS);
                        trfmmap.put(trid, fmwr);  
                    }else{
                        FMHZVstatusreturnwrapper fmwr = new FMHZVstatusreturnwrapper(null,null,ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS);
                        trfmmap.put(trid, fmwr);
                    }
                }
            }
        }
        return trfmmap;
    }
    public class FMHZVstatusreturnwrapper {
        ID fmid {
            get;
            set;
        }
        ID hzvid {
            get;
            set;
        }
        string status {
            get;
            set;
        }
        public FMHZVstatusreturnwrapper(ID fmid, ID hzvid, string status) {
            this.fmid = fmid;
            this.hzvid = hzvid;
            this.status = status;
        }
    }
}