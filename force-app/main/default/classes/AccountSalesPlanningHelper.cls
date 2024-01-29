/****************************************************************************
* Name: AccountSalesPlanningHelper
* Author: Naina Butle
* Created Date: 21/08/2023
* Description: Helper class of Account SalesForecasting LWC
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
* 
****************************************************************************/
public with sharing class AccountSalesPlanningHelper {
    public static final String CONVARIABLE = '#@#';
    //6559 - Start
    public static Map<String, List<SalesPlanning__c>> keyValueMapReturn(List<SalesPlanning__c> spList){
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.year();
        Map<String, List<SalesPlanning__c>> dateVsSalesPlann = new Map<String, List<SalesPlanning__c>>();
        for(SalesPlanning__c ss : spList){
            Integer monthss = ss.ForecastTimePoint__c.month();
            Integer yearss = ss.ForecastTimePoint__c.year();
            Integer monInt = 0;
            if(yearss == currentYear){
                monInt = monthss - currentMonth;
            }
            else if(yearss > currentYear){
                monInt = 12-currentMonth +monthss;
            }
            if(monInt == 0){
                if(!dateVsSalesPlann.ContainsKey('currentFSoldAmount')){
                    dateVsSalesPlann.put('currentFSoldAmount', new List<SalesPlanning__c>());
                }
                dateVsSalesPlann.get('currentFSoldAmount').add(ss);
            }else{
                if(!dateVsSalesPlann.ContainsKey('current'+monInt+'FSoldAmount')){
                    dateVsSalesPlann.put('current'+monInt+'FSoldAmount', new List<SalesPlanning__c>());
                }
                dateVsSalesPlann.get('current'+monInt+'FSoldAmount').add(ss);
            }
            
        }
        return dateVsSalesPlann;
    }
    //6559 start
    public static AccountSalesPlanningController.UpdateTableResponse calPercentageChange(Map<String, Map<String, SalesPlanning__c>> recordInCreate, Map<String,SalesPlanning__c> recordInUpdate, List<AccountSalesPlanningController.AccountSoldAmountawrapper> wrapperSoldDataList, Map<String, SalesPlanning__c> idVsSalesPlann){
        List<SalesPlanning__c> spList = new List<SalesPlanning__c>();
        Map<String, Decimal> mapPerdata = new Map<String, Decimal>();
        SalesPlanning__c salesPlanUpdate = new SalesPlanning__c();
        Boolean checkvalue = false;
        for(AccountSalesPlanningController.AccountSoldAmountawrapper calLoop : wrapperSoldDataList){
            if(calLoop.isPerRow){
                mapPerdata  = AccountSalesPlanningController.convertToMap(new List<AccountSalesPlanningController.AccountSoldAmountawrapper>{calLoop});
            }
        }
        for(decimal mp : mapPerdata.values()){
            if(mp != null){
                checkvalue = true;
                break;
            }
        }
        if(checkvalue){
            for(string skey : idVsSalesPlann.keyset()){
                if(!recordInUpdate.containsKey(skey)){
                    spList.add(idVsSalesPlann.get(skey));
                }else{
                    spList.add(recordInUpdate.get(skey));
                }
            }
            Map<String, List<SalesPlanning__c>> dateVsSalesPlann = AccountSalesPlanningHelper.keyValueMapReturn(spList); 
            
            for(String sploop : dateVsSalesPlann.keySet()){
                if(mapPerdata.containsKey(sploop) && mapPerdata.get(sploop) != null){
                    List<SalesPlanning__c> innerMapSP = dateVsSalesPlann.get(sploop);
                    for(SalesPlanning__c innerLoop : innerMapSP){
                        if(mapPerdata.containsKey(sploop) && mapPerdata.get(sploop) != null){
                            Decimal perValue = mapPerdata.get(sploop)/100;
                            if(innerLoop.ForecastSoldAmount__c != null && perValue != null){
                                salesPlanUpdate = innerLoop;
                                salesPlanUpdate.ForecastSoldAmount__c = innerLoop.ForecastSoldAmount__c + (perValue * innerLoop.ForecastSoldAmount__c);
                                recordInUpdate.put(salesPlanUpdate.id, salesPlanUpdate);
                            }
                        } 
                    }
                }
            }
            for(string sploop : recordInCreate.KeySet()){
                Map<String, SalesPlanning__c> innerMapSP = recordInCreate.get(sploop);
                for(String innerLoop : innerMapSP.keyset()){
                    if(mapPerdata.containsKey(innerLoop) && mapPerdata.get(innerLoop) != null){
                        Decimal perValue = mapPerdata.get(innerLoop)/100;
                        SalesPlanning__c spNewdata = innerMapSP.get(innerLoop);
                        if(spNewdata.ForecastSoldAmount__c != null && perValue != null){
                            salesPlanUpdate = spNewdata;
                            salesPlanUpdate.ForecastSoldAmount__c = spNewdata.ForecastSoldAmount__c + (perValue * spNewdata.ForecastSoldAmount__c);
                            recordInCreate.get(sploop).put(innerLoop, salesPlanUpdate);
                        } 
                    }
                }
            }      
        }
        AccountSalesPlanningController.UpdateTableResponse updateWrapper = new AccountSalesPlanningController.UpdateTableResponse();
        updateWrapper.wrapperMapToUpdate = recordInUpdate;
        updateWrapper.wrapperMapToCreate = recordInCreate;
        return updateWrapper;
    }
    //6559 end
    //6993 Start
    public static String overrideCalulationHelper(String oVMonth, String previousMonth, String bussinessArea){
        Map<String, Date> columnNames = new Map<String, Date>();
        Map<String, SalesPlanning__c> accIdvsFSforOV = new Map<String, SalesPlanning__c>();
        Map<String, SalesPlanning__c> accIdvsFSforPM = new Map<String, SalesPlanning__c>();
        List<SalesPlanning__c> updateSpList = new List<SalesPlanning__c>();
        boolean checkNew = false;
        Savepoint sp;
        try{
            sp = Database.setSavepoint();
            Date currentDate = Date.today();
            Integer currentMonth = currentDate.month();
            Integer currentYear = currentDate.year();
            for(Integer i = 1; i <= 12; i++) {
                Date dateValue = Date.newInstance(currentYear, currentMonth + i, 1);
                columnNames.put('current'+i+'FSoldAmount', dateValue);    
            }
            Date dateOV = columnNames.get(oVMonth);
            Date datePM = columnNames.get(previousMonth);
            if(dateOV != null && datePM != null){
                List<SalesPlanning__c> spList = [SELECT Id, Account__c,Account__r.Name, BusinessArea__c, ForecastTimePoint__c, Frequency__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                                 FROM SalesPlanning__c WHERE ForecastLevel__c ='Account' AND 
                                                 ForecastTimePoint__c >=: datePM  AND ForecastTimePoint__c <=: dateOV AND BusinessArea__c=:bussinessArea AND Frequency__c='Monthly' ORDER By ForecastTimePoint__c ASC];
                Map<String, List<SalesPlanning__c>> dateVsSalesPlann = keyValueMapReturn(spList); 
                if(dateVsSalesPlann != null){
                    List<SalesPlanning__c> pmList = dateVsSalesPlann.containsKey(previousMonth) ? dateVsSalesPlann.get(previousMonth) : null;
                    if(!pmList.isEmpty() && pmList != null){
                        for(SalesPlanning__c spLoop : pmList){
                            if(spLoop.Account__c != null){
                                accIdvsFSforPM.put(spLoop.ForecastTimePoint__c+CONVARIABLE+spLoop.Account__c, spLoop);   
                            }else{
                                accIdvsFSforPM.put(spLoop.ForecastTimePoint__c+CONVARIABLE+'NP', spLoop); 
                            }
                        } 
                    }
                    List<SalesPlanning__c> ovList = dateVsSalesPlann.containsKey(oVMonth) ? dateVsSalesPlann.get(oVMonth) : null;
                    if(ovList == null){
                        checkNew = true;
                        for(SalesPlanning__c spData : accIdvsFSforPM.values()){
                            updateSpList.add(createSalesPlanning(spData));   
                        } 
                    }else if(!ovList.isEmpty() && ovList != null){
                        for(SalesPlanning__c spLoop : ovList){
                            date ForecastTimePoint = spLoop.ForecastTimePoint__c.addMonths(-1);
                            if(spLoop.Account__c != null){
                                accIdvsFSforOV.put(ForecastTimePoint+CONVARIABLE+spLoop.Account__c, spLoop);   
                            }else{
                                accIdvsFSforOV.put(ForecastTimePoint+CONVARIABLE+'NP', spLoop); 
                            }
                        }
                    }
                    
                    if(!checkNew){
                        for(String idKey : accIdvsFSforOV.KeySet()){
                            if(accIdvsFSforPM.ContainsKey(idKey)){
                                SalesPlanning__c spOverrideRecord = accIdvsFSforOV.get(idKey);
                                spOverrideRecord.ForecastSoldAmount__c = accIdvsFSforPM.get(idKey).ForecastSoldAmount__c;
                                updateSpList.add(spOverrideRecord);
                            }else{
                                SalesPlanning__c spOverrideRecord = accIdvsFSforOV.get(idKey);
                                spOverrideRecord.ForecastSoldAmount__c = null;
                                updateSpList.add(spOverrideRecord);
                            }
                        }
                        
                        for(String idKey : accIdvsFSforPM.KeySet()){
                            if(!accIdvsFSforOV.ContainsKey(idKey)){
                                SalesPlanning__c spData = accIdvsFSforPM.get(idKey);
                                updateSpList.add(createSalesPlanning(spData));  
                            }
                        }  
                    }
                    if(!updateSpList.isEmpty()){
                        upsert updateSpList;
                    }
                    return ConstantClass.SUCCESS;
                }
                return ConstantClass.DATANOTFOUND;
            }
            return ConstantClass.INPUTNOTFOUND;
        }catch(Exception e){
            Database.RollBack(sp);
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.SALESPALNNING_OBJECT, ConstantClass.SALESPALNNING_ERROR, '', exdetails, ConstantClass.APEX_CLASS);
            return exdetails;
        }
    }
    
    public static SalesPlanning__c createSalesPlanning(SalesPlanning__c spData){
        SalesPlanning__c spOverridenew = new SalesPlanning__c();
        spOverridenew.ForecastTimePoint__c = spData.ForecastTimePoint__c.addMonths(1);
        spOverridenew.BusinessArea__c = spData.BusinessArea__c;
        spOverridenew.ForecastLevel__c = 'Account';
        spOverridenew.Frequency__c = spData.Frequency__c;
        spOverridenew.Account__c = spData.Account__c;
        spOverridenew.ForecastSoldAmount__c = spData.ForecastSoldAmount__c;
        return spOverridenew;
    }
    //6993 End
}
