/****************************************************************************
* Name: OLIProductfinder
* Author: Gunjan Saxena
* Created Date: 14/09/2023
* Description: Class to be called from  'Calculate Price' Button to find product and update Product Finder Status accordingly.
* // zero condition - IF FMN is populated product finder = 'FMN is specified on tr' is removed as not tr will exist.
* Requirement Document: US-7212
*****************************************************************************/
/*****************************************************************************
* Modification log
* Name              Date                    Description
* Developer Name    Date of Modification    Modification Description   
****************************************************************************/
public with sharing class OLIProductfinder {
 /****************************************************************************
* Author Name: Harshitha U
* Description: Method to update the product Finder Status on the OLI
* Created Date: 14/09/2023
* Last Modified Date: 26/09/2023
****************************************************************************/
    @AuraEnabled
    public static List<Id> updateOLIProductFinderStatus(List < ID > OLIRecordIDlst) {
        Map<Id, FMHZVstatusreturnwrapper> fmidmap = Productfinderlogic(OLIRecordIDlst);
        List<OpportunityLineItem> olitoupdate = new List<OpportunityLineItem>();
        List<String> oliIds = new List<String>();
        try{
            for(OpportunityLineItem existingoli : [SELECT ID, TechnicalRequirement__c, TechnicalRequirement__r.Opportunity__c,
                                                   UnitPrice, Quantity, Opportunity.Pricebook2Id, TechnicalRequirement__r.Product__c, TechnicalRequirement__r.FinishedGoods__r.Product__c,
                                                   TechnicalRequirement__r.Quantity__c,FinalPrice__c, Opportunity.Incoterms__c, Product2Id,ProductFinderStatus__c, FinishedGoodsSales__c FROM OpportunityLineItem
                                                   WHERE Id IN :OLIRecordIDlst AND Opportunity.RecordType.Name = 'Opportunity with quote creations']){
                                                       if(fmidmap.containskey(existingoli.ID)){
                                                           
                                                           FMHZVstatusreturnwrapper fmn =   fmidmap.get(existingoli.ID);
                                                           if(existingoli.FinishedGoodsSales__c != NULL){
                                                             existingoli.FinishedGoods__c = existingoli.FinishedGoodsSales__c;
                                                             existingoli.ProductFinderstatus__c = ConstantClass.FMNSPECIFIED_FINDERSTATUS;
                                                           }
                                                           else{
                                                             existingoli.FinishedGoodsSales__c = fmn.fmid;
                                                             existingoli.FinishedGoods__c = fmn.fmid;
                                                             existingoli.ProductFinderstatus__c = fmn.status;
                                                           }
                                                           existingoli.SemiFinishedGoods__c = fmn.hzvid;                 
                                                           if(existingoli.FinalPrice__c != null){
                                                               existingoli.UnitPrice = existingoli.FinalPrice__c;  
                                                           }else{
                                                               existingoli.UnitPrice = 0; 
                                                           }
                                                           olitoupdate.add(existingoli);
                                                           oliIds.add(existingoli.ID);
                                                       }
                                                   }
            if(!olitoupdate.isEmpty()){
                update olitoupdate;
            }
      }
        catch (exception exe) {
            for (opportunitylineitem oli: olitoupdate) {
                ExceptionUtilClass.logException('OpportunityLineItem', 'OLIProductfinder', string.valueOf(oli.ID), string.valueOf(exe), 'Update');
            }
        }
        return oliIds;
    }
    public static Map<Id, FMHZVstatusreturnwrapper> Productfinderlogic (List<String> OLIRecordIDlst) {
        List<ID> OLIInductivelst = new List<ID>();
        Map<string,List<ID>> trprid = new Map<string,List<ID>>();
        Map<ID,Decimal> IDDim = new Map<ID,Decimal>();
        Map<ID,Decimal> FMIDDIMA = new Map<ID,Decimal>();
        Map<ID,decimal> mindimIDmap = new Map<ID,decimal>();
        Map<ID,decimal> maxdimIDmap = new Map<ID,decimal>();
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
        MAP<ID,string> strFMMAP = new MAP<ID,string>();
        Set<string> rmTrSet = new Set<string>();
        Set<string> procodeSet = new Set<string>();
        List<RollingMill__c> rmList = new List<RollingMill__c>();
        List<Decimal> dimAList = new List<Decimal>();
        List<Decimal> rmDimFromList =new List<Decimal>();
        List<Decimal> rmDimToList =new List<Decimal>();
        Map<string, Id> fmkey = new Map<string, Id>();
        Map<Id, FMHZVstatusreturnwrapper> trfmmap = new Map<Id, FMHZVstatusreturnwrapper>();
        List<opportunitylineitem> secscentechrlst = new List<opportunitylineitem>();
        Map<Id, string> trkeyFG = new Map<Id, string>();
        Map<Id, opportunitylineitem> oliIDolikey = new Map<Id, opportunitylineitem>();
        FOR(opportunitylineitem olirecord : [SELECT Id,DimensioncalculationA__c, DimensionB__c,FinishedGoods__c, SemiFinishedGoods__c, Product2Id,Product2.Flat__c,Product2.IsActive, Product2.ProductCode,LVPosition__c,
                                             LVPosition__r.InternalSteelGrade__r.SELNumber__c,LVPosition__r.InternalSteelGrade__r.ExcludeFromProductFinder__c, 
                                             LVPosition__r.Rollingmill__c, Opportunity.RecordType.Name,
                                             LVPosition__r.PrimRollingHomogenize__c,  LVPosition__r.PrimRollingInputformat__c, LVPosition__r.HZVCheckTreatment__c, 
                                             LVPosition__r.HeatTreatment__c, LVPosition__r.SurfaceTreatment__c, LVPosition__r.Surfacedefectinspec__c, 
                                             LVPosition__r.Peelingbarwirerod__c, LVPosition__r.Homogenize__c, LVPosition__r.HZVAnnealing__c, LVPosition__r.USInspection__c,Product2.Family,LVPosition__r.HZVSampletest__c  FROM OpportunityLineItem 
                                             Where ID IN :OLIRecordIDlst ]){
                                                 
                                                 if((olirecord.Product2.Flat__c== false && olirecord.Product2.Family == 'Wire Rod' && olirecord.LVPosition__r.InternalSteelGrade__r.ExcludeFromProductFinder__c == false) || 
                                                    (olirecord.Product2.Family == 'Bar steel' && olirecord.LVPosition__r.Peelingbarwirerod__c== null && olirecord.LVPosition__r.SurfaceTreatment__c== null && olirecord.LVPosition__r.MultipleStraightening__c == null && olirecord.LVPosition__r.Surfacedefectinspec__c == null)){
                                                        rmTrSet.add(olirecord.LVPosition__r.Rollingmill__c);
                                                        procodeSet.add(olirecord.Product2.ProductCode);
                                                        dimAList.add(olirecord.DimensioncalculationA__c);
                                                        IDDim.put(olirecord.Id,olirecord.DimensioncalculationA__c);
                                                        string prroll = 'p'+ (olirecord.Product2.ProductCode != null ? olirecord.Product2.ProductCode : '') + 'r' + (olirecord.LVPosition__r.Rollingmill__c != null ? olirecord.LVPosition__r.Rollingmill__c : '') ;
                                                        if(trprid.containskey(prroll)){
                                                            List<Id> trid = new List<Id>();
                                                            trid = trprid.get(prroll);
                                                            trid.add(olirecord.id);
                                                            trprid.put(prroll,trid); 
                                                        }else{
                                                            List<Id> trid = new list<ID>();
                                                            trid.add(olirecord.id);
                                                            trprid.put(prroll,trid);
                                                        }
                                                        if(olirecord.LVPosition__r.InternalSteelGrade__r.ExcludeFromProductFinder__c){
                                                            OLIInductivelst.add(olirecord.Id);
                                                            FMHZVstatusreturnwrapper fmwr = new FMHZVstatusreturnwrapper(null,null,ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS);
                                                            trfmmap.put(olirecord.ID, fmwr); 
                                                        }
                                                        
                                                    }
                                                 if(olirecord.Product2.IsActive == true){
                                                            productlst.add(olirecord.Product2Id);                                                            
                                                        }
                                                  selnumberlst.add(olirecord.LVPosition__r.InternalSteelGrade__r.SelNumber__c);
                                                  rollingmilllst.add(olirecord.LVPosition__r.Rollingmill__c);
                                                  primrollinghomogenizelst.add(olirecord.LVPosition__r.PrimRollingHomogenize__c);
                                                  PrimRollingInputformatlst.add(olirecord.LVPosition__r.PrimRollingInputformat__c); 
                                                  hzvchecktreatmentlst.add(olirecord.LVPosition__r.HZVCheckTreatment__c);
                                                  heattreatmentlst.add(olirecord.LVPosition__r.HeatTreatment__c);
                                                  straighteninglst.add(olirecord.LVPosition__r.SurfaceTreatment__c);   
                                                  peelingbarwirerodlst.add(olirecord.LVPosition__r.Peelingbarwirerod__c);
                                                  surfacedefectinspeclst.add(olirecord.LVPosition__r.Surfacedefectinspec__c);
                                                  usinspectionlst.add(olirecord.LVPosition__r.USInspection__c);
                                                  string strFM = '';
                                                 // Scenerio 1:  First fmn Search on below parameters Product Finder status = 'Matching fmn found'
                                                        if(olirecord.Product2.Flat__c){
                                                                strFM = 'P' + olirecord.Product2ID + 'SN' + olirecord.LVPosition__r.InternalSteelGrade__r.SelNumber__c + 'R' + olirecord.LVPosition__r.Rollingmill__c + 'DA' + olirecord.DimensioncalculationA__c  + 'DB' + olirecord.DimensionB__c + 'PH' + olirecord.LVPosition__r.PrimRollingHomogenize__c +'PI'+ olirecord.LVPosition__r.PrimRollingInputformat__c  +'CT' + olirecord.LVPosition__r.HZVCheckTreatment__c + 'HT' + olirecord.LVPosition__r.HeatTreatment__c + 'ST' + olirecord.LVPosition__r.SurfaceTreatment__c + 'PW' + olirecord.LVPosition__r.Peelingbarwirerod__c + 'SD'+ olirecord.LVPosition__r.Surfacedefectinspec__c + 'UI'+ olirecord.LVPosition__r.USInspection__c;                           
                                                                dimensionalst.add(olirecord.DimensioncalculationA__c);
                                                                dimensionblst.add(olirecord.DimensionB__c);
                                                                
                                                            }
                                                        else if((olirecord.Product2.Flat__c== false && olirecord.Product2.Family == 'Wire Rod' && olirecord.LVPosition__r.InternalSteelGrade__r.ExcludeFromProductFinder__c == false) || // US-857
                                                           (olirecord.Product2.Family == 'Bar steel' && olirecord.LVPosition__r.Peelingbarwirerod__c== null && olirecord.LVPosition__r.SurfaceTreatment__c== null && olirecord.LVPosition__r.MultipleStraightening__c == null && olirecord.LVPosition__r.Surfacedefectinspec__c == null)){
                                                               strFM = 'P' + olirecord.Product2Id + 'SN' + olirecord.LVPosition__r.InternalSteelGrade__r.SelNumber__c + 'R'+ olirecord.LVPosition__r.Rollingmill__c + 'PH' + olirecord.LVPosition__r.PrimRollingHomogenize__c + 'PI' + olirecord.LVPosition__r.PrimRollingInputformat__c + 'CT' + olirecord.LVPosition__r.HZVCheckTreatment__c + 'HT' + olirecord.LVPosition__r.HeatTreatment__c + 'ST' + olirecord.LVPosition__r.SurfaceTreatment__c + 'PW' + olirecord.LVPosition__r.Peelingbarwirerod__c + 'SD' + olirecord.LVPosition__r.Surfacedefectinspec__c + 'UI' + olirecord.LVPosition__r.USInspection__c;       
                                                           }else {
                                                               strFM = 'P' +  olirecord.Product2Id + 'SN' + olirecord.LVPosition__r.InternalSteelGrade__r.SelNumber__c + 'R'+ olirecord.LVPosition__r.Rollingmill__c + 'DA' + olirecord.DimensioncalculationA__c + 'PH' + olirecord.LVPosition__r.PrimRollingHomogenize__c + 'PI' + olirecord.LVPosition__r.PrimRollingInputformat__c + 'CT' + olirecord.LVPosition__r.HZVCheckTreatment__c + 'HT' + olirecord.LVPosition__r.HeatTreatment__c + 'ST' + olirecord.LVPosition__r.SurfaceTreatment__c + 'PW' + olirecord.LVPosition__r.Peelingbarwirerod__c + 'SD' + olirecord.LVPosition__r.Surfacedefectinspec__c + 'UI' + olirecord.LVPosition__r.USInspection__c;       
                                                               dimensionalst.add(olirecord.DimensioncalculationA__c);
                                                           }
                                                                strFMMAP.put(olirecord.Id,strFM);
                                                                oliIDolikey.put(olirecord.ID,olirecord);
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
                                        string strFMC = 'P' + fmn.Product__c + 'SN' + fmn.SteelGradeLookup__r.SELNumber__c + 'R' + fmn.Rollingmill__c + 'DA' + fmn.DimensionA__c + 'PH' + fmn.PrimRollingHomogenize__c + 'PI' + fmn.PrimRollingInputformat__c + 'CT'+ fmn.HZVCheckTreatment__c + 'HT' + fmn.HeatTreatment__c + 'ST' + fmn.Straightening__c + 'PW' + fmn.PeelRodWire__c + 'SD' + fmn.Surfacedefectinspec__c + 'UI' + fmn.USInspection__c;
                                        fmkey.put( strFMA, fmn.ID);
                                        fmkey.put( strFMB, fmn.ID);
                                        fmkey.put( strFMC, fmn.ID);
                                        if(strFMID.containskey(strFMB)){
                                            FMIDDim = strFMID.get(strFMB);
                                            FMIDDim.put(fmn.ID,fmn.MaterialNumber__c);
                                            strFMID.put(strFMB,FMIDDim);
                                            FMIDDIMA.put(fmn.ID,fmn.DimensionA__c); 
                                        }else{
                                            FMIDDim.put(fmn.ID,fmn.MaterialNumber__c);//Material number
                                            strFMID.put(strFMB,FMIDDim);
                                            FMIDDIMA.put(fmn.ID,fmn.DimensionA__c);
                                        }
                                    }
        for(StrING oliId : strFMMAP.keySet()){
            list<string> materiallst = new list<string>();
            string maxmaterial = '';
            if(strFMID.get(strFMMAP.get(oliId)) != null){
                materiallst = strFMID.get(strFMMAP.get(oliId)).values();
                FMIDDim = strFMID.get(strFMMAP.get(oliId));
                materiallst.sort(); 
                maxmaterial = materiallst[materiallst.size()-1];
            }
            if(fmkey.containskey(strFMMAP.get(oliId ))){
                    FMHZVstatusreturnwrapper fmwr = new FMHZVstatusreturnwrapper(fmkey.get(strFMMAP.get(oliId )),null,ConstantClass.MATCHINGFMN_FINDERSTATUS);
                    trfmmap.put(oliId, fmwr);  
            }else{
                secscentechrlst.add(oliIDolikey.get(oliId));
            }
            if(strFMID.get(strFMMAP.get(oliId)) != null){
                for(id fid : strFMID.get(strFMMAP.get(oliId)).keyset()){
                    if(FMIDDIMA.get(fid)>= mindimIDmap.get(oliId) && FMIDDIMA.get(fid)<= maxdimIDmap.get(oliId)){
                        if(strFMID.get(strFMMAP.get(oliId)).get(fid) == maxmaterial && !OLIInductivelst.contains(oliId)){
                                FMHZVstatusreturnwrapper fmwr = new FMHZVstatusreturnwrapper(fid,null,ConstantClass.MATCHINGFMN_FINDERSTATUS); 
                                trfmmap.put(oliId, fmwr);
                        }
                    }
                    
                }
            }
        }
        // SCENERIO 2
        // Search fmn for excluded OLI records from SCENERIO 1
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
            strFMMAP.clear();
            selnumberlst.clear();
            primrollinghomogenizelst.clear();
            primrollinginputformatlst.clear();   
            hzvchecktreatmentlst.clear();
            List<string> hzvsampletestlst = new List<string>();
            List<string> annealinglst = new  List<string>();
            List<string> homogenizelst = new  List<string>();  
            Map<String, String> mastervaluesMap = new Map<String, String>();
            List<MasterValues__mdt> mastervalue = [SELECT Id, MasterLabel, Position__r.MasterLabel, FieldMappedTo__c, Value__c, PositionFieldValue__c,PositionFieldValue__r.PicklistValue__c
                                                      FROM MasterValues__mdt];
            if(!mastervalue.isEmpty()){
               for (MasterValues__mdt metadata : mastervalue) {
                        string[] key = metadata.MasterLabel.split('_');
                       if(key.size()>1){
                        mastervaluesMap.put(key[1], metadata.Value__c);
                       }
                }
            }
            for(opportunitylineitem oli :secscentechrlst){
                if(oli.Product2.IsActive == True){
                    productlst.add(oli.Product2Id);
                }
                rollingmilllst.add(oli.LVPosition__r.Rollingmill__c);
                heattreatmentlst.add(oli.LVPosition__r.HeatTreatment__c);
                straighteninglst.add(oli.LVPosition__r.SurfaceTreatment__c);   
                peelingbarwirerodlst.add(oli.LVPosition__r.Peelingbarwirerod__c);
                surfacedefectinspeclst.add(oli.LVPosition__r.Surfacedefectinspec__c);
                usinspectionlst.add(oli.LVPosition__r.USInspection__c);  
                selnumberlst.add(oli.LVPosition__r.InternalSteelGrade__r.SELNumber__c);
                primrollinghomogenizelst.add(oli.LVPosition__r.PrimRollingHomogenize__c);
                primrollinginputformatlst.add(oli.LVPosition__r.PrimRollingInputformat__c);
                hzvchecktreatmentlst.add(oli.LVPosition__r.HZVCheckTreatment__c);
                hzvsampletestlst.add(oli.LVPosition__r.HZVSampletest__c);
                annealinglst.add(oli.LVPosition__r.HZVAnnealing__c);
                homogenizelst.add(oli.LVPosition__r.Homogenize__c);
                string strFM = '';
            
                if(oli.Product2.Flat__c){
                    strFM = 'P' + oli.Product2ID + 'R' + oli.LVPosition__r.Rollingmill__c + 'DA' + oli.DimensioncalculationA__c + 'DB' + oli.DimensionB__c + 'HT' + oli.LVPosition__r.HeatTreatment__c + 'ST' + oli.LVPosition__r.SurfaceTreatment__c + 'PW' + oli.LVPosition__r.Peelingbarwirerod__c + 'SD' + oli.LVPosition__r.Surfacedefectinspec__c + 'UI' + oli.LVPosition__r.USInspection__c;                       
                    dimensionalst.add(oli.DimensioncalculationA__c);
                    dimensionalst.add(oli.DimensionB__c);
                }else if((oli.Product2.Flat__c = false && oli.Product2.Family == 'Wire Rod' && oli.LVPosition__r.InternalSteelGrade__r.ExcludeFromProductFinder__c == false) || 
                         (oli.Product2.Family == 'Bar steel' && oli.LVPosition__r.Peelingbarwirerod__c== null && oli.LVPosition__r.SurfaceTreatment__c== null && oli.LVPosition__r.MultipleStraightening__c == null && oli.LVPosition__r.Surfacedefectinspec__c == null)){
                             strFM = 'P' + oli.Product2ID + 'R'+ oli.LVPosition__r.Rollingmill__c + 'DA' + oli.DimensioncalculationA__c +  'HT' + oli.LVPosition__r.HeatTreatment__c + 'ST' + oli.LVPosition__r.SurfaceTreatment__c + 'PW' +  oli.LVPosition__r.Peelingbarwirerod__c + 'SD' +  oli.LVPosition__r.Surfacedefectinspec__c + 'UI' + oli.LVPosition__r.USInspection__c;       
                         }
                else{
                       strFM = 'P' + oli.Product2ID + 'R' + oli.LVPosition__r.Rollingmill__c + 'HT' + oli.LVPosition__r.HeatTreatment__c + 'ST' + oli.LVPosition__r.SurfaceTreatment__c + 'PW' + oli.LVPosition__r.Peelingbarwirerod__c + 'SD' + oli.LVPosition__r.Surfacedefectinspec__c + 'UI' + oli.LVPosition__r.USInspection__c;  
                       dimensionalst.add(oli.DimensioncalculationA__c);
                     }
                if(mastervaluesMap.containsKey(oli.LVPosition__r.HeatTreatment__c) && mastervaluesMap.get(oli.LVPosition__r.HeatTreatment__c) == 'TRUE') {
                    OLIInductivelst.add(oli.Id);
                    FMHZVstatusreturnwrapper fmwr = new FMHZVstatusreturnwrapper(null,null,ConstantClass.REACHOUTTOCON_FINDERSTATUS);
                    trfmmap.put(oli.Id, fmwr);
                }else if(oli.LVPosition__r.InternalSteelGrade__r.ExcludeFromProductFinder__c){ 
                    OLIInductivelst.add(oli.Id);
                    FMHZVstatusreturnwrapper fmwr = new FMHZVstatusreturnwrapper(null,null,ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS);
                    trfmmap.put(oli.ID, fmwr);  
                }else{
                    trkeyFG.put(oli.ID, strFM);
                }
                strFM = 'S' + oli.LVPosition__r.InternalSteelGrade__r.SELNumber__c + 'PH' + oli.LVPosition__r.PrimRollingHomogenize__c + 'PI' + oli.LVPosition__r.PrimRollingInputformat__c + 'HS' + oli.LVPosition__r.HZVSampletest__c + 'HC' + oli.LVPosition__r.HZVCheckTreatment__c + 'HA' + oli.LVPosition__r.HZVAnnealing__c + 'HG' + oli.LVPosition__r.Homogenize__c;                           
                strFMMAP.put(oli.ID, strFM);
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
            for(ID oliid : strFMMAP.keySet()){
                if(!(OLIInductivelst.contains(oliid))){
                    if(fmkey.containskey(strFMMAP.get(oliid))){
                        FMHZVstatusreturnwrapper fmwr = new FMHZVstatusreturnwrapper(fmkey.get(strFMMAP.get(oliid)),null,ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS);//2793
                        trfmmap.put(oliid, fmwr);  
                    }
                }
            }
            Map<string,ID>  sfmkey = new Map<string,ID>();
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
            for(ID oliid : strFMMAP.keySet()){
                if(!(OLIInductivelst.contains(oliid))){
                    if(sfmkey.containskey(strFMMAP.get(oliid )) && fmkey.containskey(trkeyFG.get(oliid))){
                        FMHZVstatusreturnwrapper fmwr = new FMHZVstatusreturnwrapper(fmkey.get(trkeyFG.get(oliid)),sfmkey.get(strFMMAP.get(oliid)),ConstantClass.PRICEINDICATOR_FINDERSTATUS);
                        trfmmap.put(oliid, fmwr);  
                    }else{
                        FMHZVstatusreturnwrapper fmwr = new FMHZVstatusreturnwrapper(null,null,ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS);
                        trfmmap.put(oliid, fmwr);
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
    @testVisible static List<MasterValues__mdt> customMetadata { 
    get {
        if ( customMetadata == null )
            customMetadata = [ SELECT Value__c FROM MasterValues__mdt WHERE MasterLabel = 'HeatTreatment_NE']; 
        return customMetadata;
    } set; }
}