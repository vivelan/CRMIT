/****************************************************************************
* Name: PricingToolController
* Author: Harshitha U
* Created Date: 08/09/2022
* Description: Controller class for pricing calculations
*****************************************************************************/
/*****************************************************************************
* Modification log
* Name              Date                    Description
* Developer Name    Date of Modification    Modification Description 
* Gunjan Saxena     01/12/2022  US-413 - Last saved Final price date to be saved every time when 'Save Final Price' button is clicked.
US - 413 - ReRunProductFinder called when 'Re-Run Product Finder' button is clicked.
****************************************************************************/
public with sharing class PricingToolController {
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to fetch the Opportunity Line Item Pricing Details
* Created Date: 08/09/2022
* Last Modified Date: 15/09/2022
****************************************************************************/
    @AuraEnabled
    public static List<PLWrapperData> getOpportunityLineItem (String OLIRecordID) {
        List<PLWrapperData> plWrapper = new List<PLWrapperData>();
         List<OpportunityLineItem> opp = [SELECT Id,usePricingTool__c, Name, OpportunityId, CostOfProduction__c, PriceLevel1__c, PriceLevel2__c,Opportunity.StageName,
                                        PriceLevel3__c,PriceLevel4__c,PriceLevel5__c,OrientationPrice__c,FinalPrice__c 
                                        FROM OpportunityLineItem 
                                        WHERE Id=:OLIRecordID WITH SECURITY_ENFORCED];
            PLWrapperData priceLevelWrapper = new PLWrapperData();
            priceLevelWrapper.id = (opp[0].Id);
            priceLevelWrapper.usePricingTool = (opp[0].UsePricingTool__c);
            priceLevelWrapper.costOfProduction = Math.round((elide(opp[0].CostOfProduction__c)));
            priceLevelWrapper.priceLevel1 = Math.round((elide(opp[0].PriceLevel1__c)));
            priceLevelWrapper.priceLevel2 = Math.round((elide(opp[0].PriceLevel2__c)));
            priceLevelWrapper.priceLevel3 = Math.round((elide(opp[0].PriceLevel3__c)));
            priceLevelWrapper.priceLevel4 = Math.round((elide(opp[0].PriceLevel4__c)));
            priceLevelWrapper.priceLevel5 = Math.round((elide(opp[0].PriceLevel5__c)));
            priceLevelWrapper.orientationPrice = Math.round((elide(opp[0].OrientationPrice__c)));
            priceLevelWrapper.finalPrice = (elide(opp[0].FinalPrice__c)).setscale(2);
            priceLevelWrapper.stageName = opp[0].Opportunity.StageName;
            plWrapper.add(priceLevelWrapper);
        
        return plWrapper;
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to calculate the Margin Price
* Created Date: 09/09/2022
* Last Modified Date: 15/09/2022
****************************************************************************/
    @AuraEnabled
    public static List<MarginWrapperData> getMarginPriceDetails(String OLIRecordID) {
        List<MarginWrapperData> LstMarginPrice = new List<MarginWrapperData>();
        for(OpportunityLineItem OLI : [SELECT Id, Name, OpportunityId, CostOfProduction__c, PriceLevel1__c, PriceLevel2__c, PriceLevel3__c, PriceLevel4__c,
                                       PriceLevel5__c, OrientationPrice__c, FinalPrice__c,LastSavedFinalPriceDate__c,LastRefreshedDate__c
                                       FROM OpportunityLineItem WHERE Id=:OLIRecordID])
        {
            MarginWrapperData marginprice = new MarginWrapperData();
            marginprice.MarginLevel1 = Math.round((elide(OLI.PriceLevel1__c) - elide(OLI.CostOfProduction__c)));
            marginprice.MarginLevel2 = Math.round((elide(OLI.PriceLevel2__c) - elide(OLI.PriceLevel1__c)));
            marginprice.MarginLevel3 = Math.round((elide(OLI.PriceLevel3__c) - elide(OLI.PriceLevel2__c)));
            marginprice.MarginLevel4 = Math.round((elide(OLI.PriceLevel4__c) - elide(OLI.PriceLevel3__c)));
            marginprice.MarginLevel5 = Math.round((elide(OLI.PriceLevel5__c) - elide(OLI.PriceLevel4__c)));
            marginprice.FinalMarginPrice = (elide(OLI.FinalPrice__c) - elide(OLI.CostOfProduction__c)).setscale(2);
            if(OLI.LastSavedFinalPriceDate__c != null){
                marginprice.LastFinalPrice = OLI.LastSavedFinalPriceDate__c.format(); 
            }else{
                marginprice.LastFinalPrice = null;
            }
            if(OLI.LastRefreshedDate__c != null){
                marginprice.LastRefreshedDate = OLI.LastRefreshedDate__c.format(); 
            }else{
                marginprice.LastRefreshedDate = null;
            }
            
            lstmarginprice.add(marginprice);
        }
        return lstmarginprice;
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to update the Final Price.
* Created Date: 13/09/2022
* Last Modified Date: 15/09/2022
****************************************************************************/
    @AuraEnabled
    public static Decimal saveFinalPrice(Decimal FinalPrice, String RecordID) {
        List<OpportunityLineItem> LstOfOpportunityProduct = [SELECT Id, Name, OpportunityId, CostOfProduction__c, PriceLevel1__c, PriceLevel2__c,
                                                             PriceLevel3__c, PriceLevel4__c, PriceLevel5__c, OrientationPrice__c, FinalPrice__c,LastSavedFinalPriceDate__c FROM OpportunityLineItem  WHERE Id=:RecordID WITH SECURITY_ENFORCED];
        try{
            if( !LstOfOpportunityProduct.isEmpty()){
                if(FinalPrice!=NULL)
                    LstOfOpportunityProduct[0].FinalPrice__c = FinalPrice;
                LstOfOpportunityProduct[0].LastSavedFinalPriceDate__c = system.today(); //US-413
            }
            UPDATE LstOfOpportunityProduct;
        }
        catch(Exception e)
        {
            String exdetails = e.getCause()+' ; '+e.getLineNumber() + ' ; '+e.getMessage()+' ; '+e.getStackTraceString()
                +' ; '+e.getTypeName() ;
            ExceptionUtilClass.publishException(ConstantClass.OPPORTUNITYLINEITEM_OBJECT,ConstantClass.UPDATEFINALPRICE,LstOfOpportunityProduct[0].Id,exdetails,ConstantClass.APEX_CLASS);
            
        }
        return LstOfOpportunityProduct[0].FinalPrice__c;
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to fetch the public groups members and check if the logged in user should get visiblity to the margin level prices.
* Created Date: 13/09/2022
* Last Modified Date: 13/09/2022
****************************************************************************/
    @AuraEnabled
    public static Boolean getPublicGroupUsers()
    {
        User user = [SELECT ID, FirstName, LastName, Name, Title, Profile.Name, Email From User WHERE ID = :UserInfo.getUserId() LIMIT 1];
        if(user.Profile.Name==ConstantClass.SAG_MARKETING_PROFILE || user.Profile.Name==System.label.SystemAdministratorProfile)
        {
            return true;
        }
        return false;
    }
    
    
    /****************************************************************************
    * Author Name: Priyanka Kumari
    * Description: Wrapper class to store the different Price Level values
    * Created Date: 01/03/2022
    * Last Modified Date: 
    ****************************************************************************/
    public class PLWrapperData
    {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public Boolean usePricingTool {get;set;}
        @AuraEnabled
        public Integer costOfProduction {get;set;}
        @AuraEnabled
        public Integer priceLevel1 {get;set;}
        @AuraEnabled
        public Integer priceLevel2 {get;set;}
        @AuraEnabled
        public Integer priceLevel3 {get;set;}
        @AuraEnabled
        public Integer priceLevel4 {get;set;}
        @AuraEnabled
        public Integer priceLevel5 {get;set;}
        @AuraEnabled
        public Integer orientationPrice {get;set;}
        @AuraEnabled
        public Decimal finalPrice {get;set;}
        @AuraEnabled
        public string stageName {get;set;}
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Wrapper class to store the Margin Price values
* Created Date: 09/09/2022
* Last Modified Date: 09/09/2022
****************************************************************************/
    public class MarginWrapperData
    {
        @AuraEnabled
        public Integer MarginLevel1 {get;set;}
        @AuraEnabled
        public Integer MarginLevel2 {get;set;}
        @AuraEnabled
        public Integer MarginLevel3 {get;set;}
        @AuraEnabled
        public Integer MarginLevel4 {get;set;}
        @AuraEnabled
        public Integer MarginLevel5 {get;set;}
        @AuraEnabled
        public Decimal FinalMarginPrice {get;set;}
        @AuraEnabled
        public string LastFinalPrice {get;set;}
        @AuraEnabled
        public string LastRefreshedDate {get;set;}
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to mark the input zero if the value is null
* Created Date: 09/09/2022
* Last Modified Date: 09/09/2022
****************************************************************************/
    public static Decimal elide(Decimal input)
    {
        return (input == null) ? 0 : input;
    }
    //US - 811 starts
    /****************************************************************************
    * Author Name: Priyanka Kumari
    * Description:  Method to call the callout method and update bulk CoP based on 
    received response 
    * Created Date: 02/12/2022
    * Last Modified Date:
    ****************************************************************************/
    @AuraEnabled
    public static String upadateBulkCOP(List<Id> oppRecordIds)
    {
        List<OpportunityLineItem> olisToReCalculate = new List<OpportunityLineItem>();
        Set<Id> olisToFetchCOP = new Set<Id>();
        for(OpportunityLineItem oli : [SELECT Id, LastRefreshedDate__c, PriceLevel1__c, PriceLevel2__c , PriceLevel3__c, PriceLevel4__c, PriceLevel5__c, OrientationPrice__c, UnitPrice, OfferedPrice__c, CoPForPP1__c,CustomerSpecificMargin__c, CostOfProduction__c, BusinessSubGroupOfProduct__c, CountryOfRelatedAccount__c, BusinessAreaOfProduct__c, ExternalCostOfProduction__c,ProductFinderStatus__c FROM OpportunityLineItem WHERE Id IN :oppRecordIds])
        {   
            if((oli.ProductFinderStatus__c == ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS) || (oli.ProductFinderStatus__c == ConstantClass.REACHOUTTOCON_FINDERSTATUS)){
               olisToReCalculate.add(oli);
            }                
            else
                olisToFetchCOP.add(oli.Id);
        }
        String description;
        Boolean rslt;
        String res;
        String strResult;
        if(!olisToFetchCOP.isempty()){
            strResult= bulkcallforcop(olisToFetchCOP);
        }
        if(!olisToReCalculate.isEmpty())
        {
            description = 'StatusBasedRecalculate';
            rslt = populatePriceLevelOnOLI(olisToReCalculate, description); //2003  
        }
        if(!olisToFetchCOP.isempty() && !olisToReCalculate.isempty())
        {
            if(strResult == 'true' && rslt == true){
                res = 'true';
            }
            else
                res = strResult;
            
        }
        else if(!olisToFetchCOP.isempty() && olisToReCalculate.isempty())            
            res = strResult;
        else if(olisToFetchCOP.isempty() && !olisToReCalculate.isempty())
            res = String.valueof(rslt);
        
     return res;
  }
  public static String bulkcallforcop(Set<Id> oliIds){
    List<RequestWrapper> request = new List<RequestWrapper>();
    Boolean isAlternatePlan = false;
    String pricePointInfo;
    Integer closedDateQuarter;
    Integer currentQuarter;
    Boolean result;
    Integer oppMonth;
    Integer oppYear;
    OrgWideSettings__c orgWideSetting = OrgWideSettings__c.getValues(ConstantClass.ORG_WIDE_INFO);
    isAlternatePlan = orgWideSetting.ActivateAlternateBasicPlan__c;
    Date lastUpdateDate = orgWideSetting.Rawmateriallastupdatedon__c;
    try{
        for(OpportunityLineItem oli : [SELECT Id, Opportunity.AppointedDayCalculation__c, Opportunity.CalculationTimePoint__c, FinishedGoods__r.MaterialNumber__c, 
                                       SemiFinishedGoods__r.MaterialNumber__c, ProductFinderstatus__c FROM OpportunityLineItem WHERE Id IN :oliIds]){   
                                           if(oli.Opportunity.AppointedDayCalculation__c!=null){
                                               oppMonth = oli.Opportunity.AppointedDayCalculation__c.month();
                                               oppYear = oli.Opportunity.AppointedDayCalculation__c.year();}
                                           if(oli.Opportunity.AppointedDayCalculation__c ==null) {
                                               ExceptionUtilClass.publishException(ConstantClass.OPPORTUNITYLINEITEM_OBJECT, ConstantClass.UPDATECOP, '', System.Label.AppointedDayMissingError, ConstantClass.APEX_CLASS);
                                               return System.Label.AppointedDayMissingError;
                                           }
                                           if(oli.Opportunity.CalculationTimePoint__c == 'Monthly'){
                                               if(oli.Opportunity.AppointedDayCalculation__c < lastUpdateDate){
                                                   
                                                   ExceptionUtilClass.publishException(ConstantClass.OPPORTUNITYLINEITEM_OBJECT, ConstantClass.UPDATECOP, '', System.Label.AppointedDayError, ConstantClass.APEX_CLASS);
                                                   return System.Label.AppointedDayError;
                                                   
                                               }
                                               
                                               else{ 
                                                   if(oppYear > (lastUpdateDate.year())){
                                                       
                                                       Integer difference = (12 - ((lastUpdateDate.month()))) + oppMonth;
                                                       pricePointInfo = 'pp' + String.valueOf(difference);
                                                   }
                                                   else{
                                                       if(oppMonth == lastUpdateDate.month()){
                                                           pricePointInfo = 'pp1';
                                                       }
                                                       else{
                                                           Integer difference = oppMonth - (lastUpdateDate.month());
                                                           pricePointInfo = 'pp' + String.valueOf(difference);
                                                       }
                                                   }
                                               }
                                           }
                                           else if(oli.Opportunity.CalculationTimePoint__c == 'Quarterly'){
                                               Map<Integer, List<Integer>> quaterlyMap = new Map<Integer, List<Integer>>();
                                               List<Integer> quarter1 = new List<Integer>{1,2,3};
                                                   List<Integer> quarter2 = new List<Integer>{4,5,6};
                                                       List<Integer> quarter3 = new List<Integer>{7,8,9};
                                                           List<Integer> quarter4 = new List<Integer>{10,11,12};
                                                               
                                                               quaterlyMap.put(1, quarter1);
                                               quaterlyMap.put(2, quarter2);  
                                               quaterlyMap.put(3, quarter3);
                                               quaterlyMap.put(4, quarter4);
                                               
                                               for(Integer quarter : quaterlyMap.keySet()){
                                                   for(Integer month : quaterlyMap.get(quarter)){
                                                       if(oppMonth == month)
                                                           closedDateQuarter = quarter;
                                                       if(lastUpdateDate.month() == month)
                                                           currentQuarter = quarter;
                                                   }
                                               }
                                               
                                               if(lastUpdateDate.month() != 3 && lastUpdateDate.month() != 6 && lastUpdateDate.month() != 9 && lastUpdateDate.month() != 12){
                                                   if(oppYear > (lastUpdateDate.year())){
                                                       if(lastUpdateDate.month() == 1 || lastUpdateDate.month() == 4 || lastUpdateDate.month() == 7|| lastUpdateDate.month()==10){
                                                           Integer difference = 17+(closedDateQuarter - currentQuarter);
                                                           pricePointInfo = 'pp' + String.valueOf(difference);
                                                       }   
                                                       else {
                                                           Integer difference = 16+(closedDateQuarter - currentQuarter);
                                                           pricePointInfo = 'pp' + String.valueOf(difference);
                                                       }
                                                   }
                                                   else if(lastUpdateDate.month() == 1 || lastUpdateDate.month() == 4 || lastUpdateDate.month() == 7|| lastUpdateDate.month()==10){
                                                       Integer difference = 13+(closedDateQuarter - currentQuarter);
                                                       pricePointInfo = 'pp' + String.valueOf(difference);
                                                       
                                                   }
                                                   else if((closedDateQuarter == currentQuarter) && (lastUpdateDate.year() == oppYear) && (lastUpdateDate.month() != 1 || lastUpdateDate.month() != 4 || lastUpdateDate.month() != 7 || lastUpdateDate.month() != 10 ) ){
                                                       ExceptionUtilClass.publishException(ConstantClass.OPPORTUNITYLINEITEM_OBJECT, ConstantClass.UPDATECOP, '', System.Label.PricePointNotAllowed, ConstantClass.APEX_CLASS);
                                                       return System.Label.PricePointNotAllowed;
                                                   }
                                                   
                                               }
                                               else if((closedDateQuarter == currentQuarter) && (lastUpdateDate.year() == oppYear) && (lastUpdateDate.month() != 1 || lastUpdateDate.month() != 4 || lastUpdateDate.month() != 7 || lastUpdateDate.month() != 10 ) ){
                                                   
                                                   ExceptionUtilClass.publishException(ConstantClass.OPPORTUNITYLINEITEM_OBJECT, ConstantClass.UPDATECOP, '', System.Label.PricePointNotAllowed, ConstantClass.APEX_CLASS);
                                                   return System.Label.PricePointNotAllowed;
                                               }
                                               else{
                                                   if(oppYear > (lastUpdateDate.year())){
                                                       Integer difference = 16+(closedDateQuarter - currentQuarter);
                                                       pricePointInfo = 'pp' + String.valueOf(difference);   
                                                   }
                                                   /* else {
Integer difference = 12+(closedDateQuarter - currentQuarter);
pricePointInfo = 'pp' + String.valueOf(difference);
}*/
                                               }
                                           } 
                    RequestWrapper reqWrapper = new RequestWrapper();
                    RequestWrapper reqWrapper1 = new RequestWrapper();
                    reqWrapper.salesforce_id = oli.Id;
                    reqWrapper.fmn = oli.FinishedGoods__r.MaterialNumber__c;
                    reqWrapper.hzv = oli.SemiFinishedGoods__r.MaterialNumber__c;
                    reqWrapper.price_point_information = pricePointInfo;
                    reqWrapper.alternate_basic_plan = isAlternatePlan;
                    request.add(reqWrapper);
                    
                    reqWrapper1.salesforce_id = oli.Id;
                    reqWrapper1.fmn = oli.FinishedGoods__r.MaterialNumber__c;
                    reqWrapper1.hzv = oli.SemiFinishedGoods__r.MaterialNumber__c;
                    reqWrapper1.price_point_information = 'pp1';
                    reqWrapper1.alternate_basic_plan = isAlternatePlan;
                    request.add(reqWrapper1);
                }
                String requestBody = JSON.serialize(request);
                result= makeBulkPostCallout(requestBody, pricePointInfo);
                return String.valueOF(result);
            }
            catch(Exception e){  
                String exdetails = e.getCause()+' ; '+e.getLineNumber() + ' ; '+e.getMessage()+' ; '+e.getStackTraceString()
                    +' ; '+e.getTypeName();
                ExceptionUtilClass.publishException(ConstantClass.OPPORTUNITYLINEITEM_OBJECT, ConstantClass.UPDATECOP, '', exdetails, ConstantClass.APEX_CLASS);
                return 'false';
            }
        }
    /****************************************************************************
    * Author Name: Priyanka Kumari
    * Description:  Method to make the callout to Heroku to get bulk CoP values 
    * and update the same. 
    * Created Date: 02/12/2022
    * Last Modified Date:
    ****************************************************************************/
    public static boolean makeBulkPostCallout(String reqBody, String ppInfo){
        List<OpportunityLineItem> oliListToUpdate =new List<OpportunityLineItem>();
        List<OpportunityLineItem> failedoliToUpdate =new List<OpportunityLineItem>();
        Map<String, Map<String, Object>> sucessfulOlisMap = new Map<String, Map<String, Object>>();
        Map<String, String> failedOlis = new Map<String, String>();
        Set<String> sucessfulOliIds = new Set<String>();
        Set<String> failedOliIds = new Set<String>();
        String ppValue;
        Boolean rslt = false;
        Boolean resForSuccess = false;
        Boolean resForFailed = false;
        String description;
        try{
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint('callout:COPCalculationLegacy');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(reqBody);
            Http http = new Http();
            HTTPResponse response = http.send(request);
            if(response.getStatusCode() == 200){
                List<Object> resultFromAPI = (List<Object>)JSON.deserializeUntyped(response.getBody());
                for(Object obj : resultFromAPI)
                {
                    Map<String, Object> res = (Map<String, Object>) obj;
                    String errorMessage = String.valueOf(res.get('status_message'));
                    if(errorMessage != ''){
                        failedOlis.put(String.valueOf(res.get('salesforce_id')), String.valueOf(res.get('status_message')));
                        failedOliIds.add(String.valueOf(res.get('salesforce_id')));
                    }
                    else{
                        String mapKey = String.valueOf(res.get('salesforce_id'))+'.'+String.valueOf(res.get('price_point_information'));
                        sucessfulOlisMap.put(mapKey, res);
                        sucessfulOliIds.add(String.valueOf(res.get('salesforce_id')));
                    }
                }
                for(OpportunityLineItem oli : [SELECT Id, LastRefreshedDate__c, PriceLevel1__c, PriceLevel2__c , PriceLevel3__c, PriceLevel4__c, PriceLevel5__c, OrientationPrice__c, UnitPrice, OfferedPrice__c, CoPForPP1__c,CustomerSpecificMargin__c, CostOfProduction__c, BusinessSubGroupOfProduct__c, CountryOfRelatedAccount__c, BusinessAreaOfProduct__c, ExternalCostOfProduction__c,ProductFinderStatus__c 
                                               FROM OpportunityLineItem 
                                               WHERE Id IN :failedOliIds]){
                    failedoliToUpdate.add(oli);           
                }
                if(!failedoliToUpdate.isEmpty()){
                    description = 'FailedRecalculate';
                    resForFailed = populatePriceLevelOnOLI(failedoliToUpdate, description);
                }
                   
                for(OpportunityLineItem oli : [SELECT Id, LastRefreshedDate__c, PriceLevel1__c, PriceLevel2__c , PriceLevel3__c, PriceLevel4__c, PriceLevel5__c, OrientationPrice__c, UnitPrice, OfferedPrice__c, CoPForPP1__c,CustomerSpecificMargin__c, CostOfProduction__c, BusinessSubGroupOfProduct__c, CountryOfRelatedAccount__c, BusinessAreaOfProduct__c, ExternalCostOfProduction__c,ProductFinderStatus__c 
                                               FROM OpportunityLineItem 
                                               WHERE Id IN :sucessfulOliIds]){
                                                  if(test.isRunningTest()){
                                                       ppInfo = 'pp1';
                                                   }  
                                                   
                    Map<String, Object> valuesForOriPP = new Map<String, Object>();
                    Map<String, Object> valuesForPP1 = new Map<String, Object>();
                    valuesForOriPP = sucessfulOlisMap.get(oli.Id+'.'+ppInfo);
                    valuesForPP1 = sucessfulOlisMap.get(oli.Id+'.pp1');
                    if(valuesForOriPP != null){
                        ppValue = String.valueOf(valuesForOriPP.get('price_point_information'));
                        if(ppValue == ppInfo && ppValue != 'pp1'){
                            oli.CostOfProduction__c = (Decimal.valueOf(String.valueOf(valuesForOriPP.get('cost_of_production_internal'))));
                            oli.ExternalCostOfProduction__c = (Decimal.valueOf(String.valueOf(valuesForOriPP.get('cost_of_production_external')))).setscale(2);
                            oli.LastRefreshedDate__c = System.now();
                            if(valuesForPP1 != null)
                                oli.CoPForPP1__c = (Decimal.valueOf(String.valueOf(valuesForPP1.get('cost_of_production_internal')))).setscale(2);
                        }
                        else if(ppValue == ppInfo && ppValue == 'pp1' && valuesForPP1 != null){
                            oli.CostOfProduction__c = (Decimal.valueOf(String.valueOf(valuesForPP1.get('cost_of_production_internal'))));
                            oli.ExternalCostOfProduction__c = (Decimal.valueOf(String.valueOf(valuesForPP1.get('cost_of_production_external')))).setscale(2);
                            oli.LastRefreshedDate__c = System.now();
                            oli.CoPForPP1__c = (Decimal.valueOf(String.valueOf(valuesForPP1.get('cost_of_production_internal')))).setscale(2);
                         }
                    }
                    else if(valuesForOriPP == null && valuesForPP1 != null)
                        oli.CoPForPP1__c = (Decimal.valueOf(String.valueOf(valuesForPP1.get('cost_of_production_internal')))).setscale(2);
                                                   
                     oliListToUpdate.add(oli);
                 }
            }
            
            if(!oliListToUpdate.isEmpty()){
                description = 'SuccessfulRecalculate';
                resForSuccess = populatePriceLevelOnOLI(oliListToUpdate, description);
            }
            rslt = resForSuccess || resForFailed;
            return rslt;
            
        }
        catch(Exception e){
            String exdetails = e.getCause()+' ; '+e.getLineNumber() + ' ; '+e.getMessage()+' ; '+e.getStackTraceString()
                +' ; '+e.getTypeName();
            ExceptionUtilClass.publishException(ConstantClass.OPPORTUNITYLINEITEM_OBJECT, ConstantClass.FETCHCOP, '', exdetails, ConstantClass.APEX_CLASS);
            return false;
        }
    }
    /****************************************************************************
    * Author Name: Priyanka Kumari
    * Description:  Wrapper class to store data for the callout request
    * Created Date: 02/12/2022
    * Last Modified Date:
    ****************************************************************************/
    public class RequestWrapper{
        String salesforce_id;
        String fmn;
        String hzv;
        String price_point_information;
        Boolean alternate_basic_plan;
    }
    //US - 811 ends
    
/****************************************************************************
* Author Name: Gunjan Saxena
* Description:  Method to call convert to technical requirement from ReRunProductFinder button on OLI
* Created Date: 30/11/2022
****************************************************************************/
    
@AuraEnabled(cacheable=false)
public Static List<OpportunityLineItem> ReRunProductFinder(String recordId)
{   List<OpportunityLineItem> OLIlst = new List<OpportunityLineItem>();
    try{
        //OrgWideSettings__c orgWideSetting = OrgWideSettings__c.getValues(ConstantClass.ORG_WIDE_INFO);
        //Date lastUpdateDate = orgWideSetting.Rawmateriallastupdatedon__c;
        OLIlst = [SELECT Id,Opportunity.AppointedDayCalculation__c FROM OpportunityLineItem
                                        WHERE Id = :recordId ];
        /*if(!OLIlst.isEmpty()){
            //if(OLIlst[0].TechnicalRequirement__c != null){
                if(OLIlst[0].Opportunity.AppointedDayCalculation__c < lastUpdateDate){
                  ExceptionUtilClass.publishException(ConstantClass.OPPORTUNITYLINEITEM_OBJECT, ConstantClass.UPDATECOP, '', System.Label.AppointedDayError, ConstantClass.APEX_CLASS);
                  return System.Label.AppointedDayError;
                }
                else if(OLIlst[0].Opportunity.AppointedDayCalculation__c == null){
                        ExceptionUtilClass.publishException(ConstantClass.OPPORTUNITYLINEITEM_OBJECT, ConstantClass.UPDATECOP, '', System.Label.AppointedDayMissingError, ConstantClass.APEX_CLASS);
                        return System.Label.AppointedDayMissingError;
                }
                else
                {
                    List<ID> trIDlst = new List<ID>();
                    trIDlst.add(OLIlst[0].TechnicalRequirement__c);
                    ConvertTechReqToOLI.ConvertTechnicalRequirementToOLI(trIDlst);
                }
            }
        }*/
        return OLIlst;
    }
    catch(Exception e){
        String exdetails = e.getCause()+' ; '+e.getLineNumber() + ' ; '+e.getMessage()+' ; '+e.getStackTraceString()
            +' ; '+e.getTypeName();
        ExceptionUtilClass.publishException(ConstantClass.OPPORTUNITYLINEITEM_OBJECT, ConstantClass.FETCHCOP, '', exdetails, ConstantClass.APEX_CLASS);
        return OLIlst;
    }
}
    
    /***************************************************************************************************
    * Author Name: Priyanka Kumari
    * Description: Method to populate different Price Levels on Opportunity Line Item when CoP is updated
    * Created Date:  09/09/2022 https://stahl-holding-saar--dev.sandbox.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
    * Last Modified Date:  09/09/2022
    ****************************************************************************************************/
    public static Boolean populatePriceLevelOnOLI (List<OpportunityLineItem> newOLILst, String description) {
        List<OpportunityLineItem> oliListToUpdate =new List<OpportunityLineItem>();
        Decimal value2b = 0;
        Decimal oppCustSize = 0.0;
        Decimal oppCustSize1 = 0.0;
        Decimal netProceedsIO = 0;
        Decimal productWin = 0;
        String oppAccountGroupid ='';
        List<PriceLevelSurcharge__c> level1 = new List<PriceLevelSurcharge__c>();
        Map<String, Decimal> level2c = new Map<String, Decimal>();    
        Map<String, Decimal> level2ca = new Map<String, Decimal>();    
        Map<Id, PriceLevelSurcharge__c> level2b =new Map<Id, PriceLevelSurcharge__c>();
        Map<String, Decimal> level3 = new Map<String, Decimal>();
        Map<String, Decimal> level5 = new Map<String, Decimal>(); 
        Map<String, Decimal> level5ba = new Map<String, Decimal>(); 
        Map<String, Decimal> levelOp1 = new Map<String, Decimal>(); 
        Map<String, Decimal> levelOp2 = new Map<String, Decimal>();
        Map<Id, Set<Id>> accOli = new Map<Id, Set<Id>>();
        Set<String> setOfFMNs = new Set<String>();
        Map<Id, Decimal> oliNettoerloesMap = new Map<Id, Decimal>();
        Map<Id,List<Decimal>> oliSumMap = new Map<Id,List<Decimal>>();
        Date today = System.today();
        Date lastNMonth = today.toStartOfMonth().addMonths(-3);
        Integer latestMonth = 0;
        
        for(PriceLevelSurcharge__c pls : [SELECT Id, Name, PriceLevel__c, Value__c, Country__c, BusinessArea__c, BusinessSubgroup__c,SizeFrom__c, SizeTo__c
                                          FROM PriceLevelSurcharge__c 
                                          ORDER BY PriceLevel__c ASC]){
            if(pls.PriceLevel__c == '1'){
                level1.add(pls);
            }else if(pls.PriceLevel__c == '2c' && pls.BusinessArea__c!=NULL && pls.Value__c!=NULL){
                if(pls.BusinessArea__c != 'ZZ' && pls.BusinessArea__c!=NULL && pls.Value__c!=NULL)
                    level2ca.put(pls.BusinessArea__c, pls.Value__c);
                else if(pls.BusinessSubgroup__c!=NULL && pls.Value__c!=NULL)
                    level2c.put(pls.BusinessSubgroup__c, pls.Value__c);
           }else if(pls.PriceLevel__c == '2b'){
                level2b.put(pls.id, pls); 
            }else if(pls.PriceLevel__c == '3' && pls.Country__c!=NULL && pls.Value__c!=NULL){
                level3.put(pls.Country__c, pls.Value__c);
            }else if(pls.PriceLevel__c == '5'){
                if(pls.BusinessArea__c != 'ZZ' && pls.BusinessArea__c!=NULL && pls.Value__c!=NULL)
                    level5ba.put(pls.BusinessArea__c, pls.Value__c);
                else if(pls.BusinessSubgroup__c!=NULL && pls.Value__c!=NULL)
                    level5.put(pls.BusinessSubgroup__c, pls.Value__c);
            }else if(pls.PriceLevel__c == 'Orientation Price'){
                if(pls.BusinessArea__c != 'ZZ' && pls.BusinessArea__c!=NULL && pls.Value__c!=NULL)
                    levelOp1.put(pls.BusinessArea__c, pls.Value__c);
                else if(pls.BusinessSubgroup__c!=NULL && pls.Value__c!=NULL)
                    levelOp2.put(pls.BusinessSubgroup__c, pls.Value__c);
            }
        }
        for(Opportunity opp:[SELECT Id, Account.CustomerSize__c, Account.AccountGroupID__c FROM Opportunity WHERE Id IN (SELECT OpportunityId FROM OpportunityLineItem WHERE Id IN: newOLILst)]){
            if( opp.Account.AccountGroupID__c == null && opp.Account.CustomerSize__c !=null ){
                oppCustSize = opp.Account.CustomerSize__c;
            }
            else if (opp.Account.AccountGroupID__c != null && opp.Account.CustomerSize__c != null)
            {
                oppAccountGroupid = opp.Account.AccountGroupID__c;
            } 
        }
        for(Account acc:[SELECT id,name,CustomerSize__c,AccountGroupID__c FROM Account WHERE AccountGroupID__c=:oppAccountGroupid]) 
        {
            oppCustSize1 += (acc.CustomerSize__c != null ? acc.CustomerSize__c : 0);
        }
        for(Id pls:level2b.keySet())
        {
            if(oppCustSize>= level2b.get(pls).SizeFrom__c && oppCustSize <=level2b.get(pls).SizeTo__c){
                value2b = level2b.get(pls).Value__c;
            }
            else if (oppCustSize1 >= level2b.get(pls).SizeFrom__c && oppCustSize1 <= level2b.get(pls).SizeTo__c){
                value2b = level2b.get(pls).Value__c;
            }
        }
        //US-141
        for(OpportunityLineItem oli : [SELECT Id, Opportunity.AccountId, FinishedGoods__r.MaterialNumber__c FROM OpportunityLineItem WHERE Id IN: newOLILst]){
            if(!accOli.containskey(oli.Opportunity.AccountId)){
                Set<Id> setofOLIids = new Set<ID>();
                setofOLIids.add(oli.ID);
                accOli.put(oli.Opportunity.AccountId, setofOLIids);
            }
            else{
              Set<ID> oliIDlst = accOli.get(oli.Opportunity.AccountId);
              oliIDlst.add(oli.Id);
            }
            setOfFMNs.add(oli.FinishedGoods__r.MaterialNumber__c);
        }
        Decimal NettoerloesWeightedAverage;
        for(InvoicedOrders__c iOrder : [SELECT id, Account__c, MaterialNumber__c, Nettoerloes__c,SoldAmount__c,NettoerloesWeightedAverage__c, InvoiceDate__c 
                                           FROM InvoicedOrders__c 
                                           WHERE (InvoiceDate__c >=: lastNMonth AND InvoiceDate__c<= :today)
                                           AND Account__c IN :accOli.keySet()
                                           ORDER BY InvoiceDate__c DESC]){
            if(!accOli.isEmpty()){
                for(Id oliID : accOli.get(iOrder.Account__c)){
                    if(setOfFMNs.contains(iOrder.MaterialNumber__c)){
                        if(!oliNettoerloesMap.containsKey(oliID)){
                        	Decimal WeightedAverage = iOrder.Nettoerloes__c/iOrder.SoldAmount__c;
                            oliNettoerloesMap.put(oliID, WeightedAverage);
                            if(accOli.get(iOrder.Account__c).size()==1)
                                accOli.remove(iOrder.Account__c);
                            else if(accOli.get(iOrder.Account__c).size()>1){
                                Set<Id> setofIds = accOli.get(iOrder.Account__c);
                                setofIds.remove(oliID);
                            }
                        }
                    }
                    else{    
                        if(latestMonth == 0)
                            latestMonth =  iOrder.InvoiceDate__c.Month();  
                        
                        if(iOrder.InvoiceDate__c.Month() == latestMonth){
                            //if no match found, then pick all the iorders with same acc as oli, calc the formula: 
                            if(oliSumMap!= null && oliSumMap.containskey(oliID)){
                                List<Decimal> newSoldAmtNettoerloesList = new Decimal[2];
                                newSoldAmtNettoerloesList = oliSumMap.get(oliID);
                                Decimal sumSoldAmtResult = newSoldAmtNettoerloesList[0]+iOrder.SoldAmount__c;
                                Decimal multiplyResult = iOrder.Nettoerloes__c;// * iOrder.SoldAmount__c;
                                Decimal sumNettoerlResult = newSoldAmtNettoerloesList[1]+multiplyResult;
                                newSoldAmtNettoerloesList.add(0,sumSoldAmtResult);
                                newSoldAmtNettoerloesList.add(1,sumNettoerlResult);                         
                            }
                            else{
                                List<Decimal> newSoldAmtNettoerloesList = new Decimal[2];
                                newSoldAmtNettoerloesList.add(0,iOrder.SoldAmount__c);
                                Decimal multiplyResult = iOrder.Nettoerloes__c;// * iOrder.SoldAmount__c;
                                newSoldAmtNettoerloesList.add(1,multiplyResult);
                                oliSumMap.put(oliID,newSoldAmtNettoerloesList);
                            }  
                        }
                    } 
                }
            } 
        }  
        for(Id oliID : oliSumMap.keySet()){
            List<Decimal> newSoldAmtNettoerloesList = oliSumMap.get(oliID);
            NettoerloesWeightedAverage= newSoldAmtNettoerloesList[1]/newSoldAmtNettoerloesList[0];
            if(!oliNettoerloesMap.containsKey(oliID))
                oliNettoerloesMap.put(oliID, NettoerloesWeightedAverage);   
        } 
        for(OpportunityLineItem oli : newOLILst) { 
            Decimal co2Surcharge = (!level1.isEmpty() && level1[0].Value__c != null) ? level1[0].Value__c: 0;   
            Decimal businessAreaSurcharge;
            Decimal orientationPriceSurcharge;
            if(level2ca.containsKey(oli.BusinessAreaOfProduct__c)){
            	businessAreaSurcharge = level2ca.get(oli.BusinessAreaOfProduct__c); 
            }              
            else if(level2c.containsKey(oli.BusinessSubGroupOfProduct__c)){
                businessAreaSurcharge = level2c.get(oli.BusinessSubGroupOfProduct__c); 
            }
            else
                businessAreaSurcharge = 0;
              
            Decimal countryLevelSurcharge = level3.containsKey(oli.CountryOfRelatedAccount__c) ? level3.get(oli.CountryOfRelatedAccount__c) : 0;
            Decimal competitiveEnvironmentSurcharge;
            //US-141
            if(oliNettoerloesMap!= null && oliNettoerloesMap.containskey(oli.Id) && oliNettoerloesMap.get(oli.Id)!= null)
                netProceedsIO = oliNettoerloesMap.get(oli.Id);
            //US-4716
            if(description == 'StatusBasedRecalculate'){

                if(oli.ProductFinderStatus__c == ConstantClass.NOMATCHINGSTEEL_FINDERSTATUS || oli.ProductFinderStatus__c == ConstantClass.REACHOUTTOCON_FINDERSTATUS){
                    if(oli.CostOfProduction__c != 0)
                    	oli.CoPForPP1__c = oli.CostOfProduction__c;
                    else{
                        oli.CoPForPP1__c = 0;
                    	oli.ExternalCostOfProduction__c = 0;
                    }    
                }   
            }
            if(description == 'FailedRecalculate'){
                oli.CostOfProduction__c = 0;
                oli.ExternalCostOfProduction__c = 0;
                oli.CoPForPP1__c = 0;
            }            
                productWin = netProceedsIO - oli.CoPForPP1__c;
                if(level5ba.containsKey(oli.BusinessAreaOfProduct__c)){
                    competitiveEnvironmentSurcharge = level5ba.get(oli.BusinessAreaOfProduct__c); 
                }              
                else if(level5.containsKey(oli.BusinessSubGroupOfProduct__c)){
                     competitiveEnvironmentSurcharge = level5.get(oli.BusinessSubGroupOfProduct__c); 
                }
                else
                    competitiveEnvironmentSurcharge = 0;
                
                if(levelOp1.containsKey(oli.BusinessAreaOfProduct__c)){
                    orientationPriceSurcharge = levelOp1.get(oli.BusinessAreaOfProduct__c); 
                }              
                else if(levelOp2.containsKey(oli.BusinessSubGroupOfProduct__c)){
                     orientationPriceSurcharge = levelOp2.get(oli.BusinessSubGroupOfProduct__c);
                }
                else
                    orientationPriceSurcharge = 0;
            
                oli.PriceLevel1__c = (oli.CostOfProduction__c + co2Surcharge);  //2547           
                oli.PriceLevel2__c = (oli.PriceLevel1__c +(oli.CustomerSpecificMargin__c + businessAreaSurcharge)+value2b);//2547                
                oli.PriceLevel3__c = (oli.PriceLevel2__c + countryLevelSurcharge);//2547
                //US-141
                if(netProceedsIO > 0){                    
                    if(productWin > (oli.PriceLevel3__c - oli.CostOfProduction__c)){
                        oli.PriceLevel4__c = (oli.CostOfProduction__c + productWin);//2547
                    }
                    else
                        oli.PriceLevel4__c = oli.PriceLevel3__c;
                }
                else
                    oli.PriceLevel4__c = oli.PriceLevel3__c;
                
                oli.PriceLevel5__c = (oli.PriceLevel4__c + competitiveEnvironmentSurcharge);//2547
                oli.OrientationPrice__c = (oli.CostOfProduction__c + orientationPriceSurcharge);
                /*Added for 1041*/
                oli.UnitPrice = oli.OfferedPrice__c;
                /*Added for 1985*/
                oliListToUpdate.add(oli);
        }
        if(!oliListToUpdate.isEmpty()){
            update oliListToUpdate;
            return true;
        }
        return false;
    }    
}