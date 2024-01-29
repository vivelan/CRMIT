/****************************************************************************
* Name: SalesPlanningFAmountupdateBatch
* Author: Gunjan Saxena
* Created Date: 05/23/2023
* Class Name: SalesPlanningFAmountupdateBatch 
* Description: Batch Class for reset the Forecast sold Amount on Account level. 
* US-4374
*****************************************************************************/
/*****************************************************************************
* Modification log
* Name              Date                    Description
* Developer Name    Date of Modification    Modification Description  
* Gunjan Saxena     22/05/2023              Created 
****************************************************************************/
global class SalesPlanningFAmountupdateBatch implements Database.Batchable<sObject>,Database.Stateful{    
    //global Variables;    
    global  MAP<string,decimal> OrderShareMap = new MAP<string,decimal>();
    global  MAP<string,decimal> ForecastSAMBAMap = new MAP<string,decimal>();
    global  MAP<string,decimal> ForecastSAYBAMap = new MAP<string,decimal>();
    global  MAP<string,decimal> NetMonthlyForecastMap = new MAP<string,decimal>();
    global  MAP<string,decimal> NetYearlyForecastMap = new MAP<string,decimal>();
    
    public SalesPlanningFAmountupdateBatch(MAP<string,decimal> OrderShareMap1){
        OrderShareMap = OrderShareMap1;
        for(SalesPlanning__c sp : [SELECT Id, Frequency__c, ForecastTimePoint__c, ForecastSoldAmount__c, ForecastLevel__c, Account__c,BusinessArea__c FROM SalesPlanning__c 
                                   Where ForecastTimePoint__c >= :system.today().addMonths(1).toStartOfMonth() AND ForecastTimePoint__c <= :system.today().addMonths(12).toStartOfMonth() 
                                   AND ForecastLevel__c = 'Business Area/Product Group' AND Frequency__c = 'Monthly']){
                                       ForecastSAMBAMap.put(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c), sp.ForecastSoldAmount__c);
                                   }
        for(SalesPlanning__c sp : [SELECT Id, Frequency__c, ForecastTimePoint__c, ForecastSoldAmount__c, ForecastLevel__c, Account__c,BusinessArea__c FROM SalesPlanning__c 
                                   Where ForecastTimePoint__c >= :system.today().addMonths(1).toStartOfMonth() AND ForecastTimePoint__c <= :system.today().addMonths(36).toStartOfMonth() 
                                   AND ForecastLevel__c = 'Business Area/Product Group' AND Frequency__c = 'Yearly']){
                                       ForecastSAYBAMap.put(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c), sp.ForecastSoldAmount__c);
                                   }
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Frequency__c, ForecastTimePoint__c, ForecastSoldAmount__c, ForecastLevel__c, Account__c,BusinessArea__c FROM SalesPlanning__c 
                                         where ForecastTimePoint__c >=  :system.today().addMonths(1).toStartOfMonth() AND ForecastTimePoint__c <=  :system.today().addMonths(36).toStartOfMonth() 
                                         AND ForecastLevel__c = 'Account' order by Account__c ]); 
    }
    public void execute(Database.BatchableContext BC, 
                        List<SalesPlanning__c> scope){
                            List<SalesPlanning__c> SalesPlanningLst = new List<SalesPlanning__c>();
                            for(SalesPlanning__c sp : scope){ 
                                if(sp.Account__c != null  && sp.Frequency__c == 'Monthly' && sp.ForecastTimePoint__c <= system.today().addMonths(12).toStartOfMonth()){
                                    if(ForecastSAMBAMap.containsKey(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c)) && OrderShareMap.containsKey(sp.Account__c+'_'+sp.BusinessArea__c))
                                        if(ForecastSAMBAMap.get(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c)) != null && OrderShareMap.get(sp.Account__c+'_'+sp.BusinessArea__c) != null )
                                        sp.ForecastSoldAmount__c = ForecastSAMBAMap.get(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c)) * OrderShareMap.get(sp.Account__c+'_'+sp.BusinessArea__c);
                                    if(sp.ForecastSoldAmount__c != null)
                                        if(NetMonthlyForecastMap.containsKey(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c))){
                                            NetMonthlyForecastMap.put(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c), NetMonthlyForecastMap.get(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c)) + sp.ForecastSoldAmount__c); 
                                        }else{
                                            NetMonthlyForecastMap.put(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c), sp.ForecastSoldAmount__c);  
                                        }
                                    SalesPlanningLst.add(sp);
                                }
                                if(sp.Account__c != null  && sp.Frequency__c == 'Yearly' ){
                                    if(ForecastSAYBAMap.containsKey(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c)) && OrderShareMap.containsKey(sp.Account__c+'_'+sp.BusinessArea__c)) 
                                        sp.ForecastSoldAmount__c = ForecastSAYBAMap.get(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c)) * OrderShareMap.get(sp.Account__c+'_'+sp.BusinessArea__c);
                                    if(sp.ForecastSoldAmount__c != null)
                                        if(NetYearlyForecastMap.containsKey(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c))){
                                            NetYearlyForecastMap.put(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c), NetYearlyForecastMap.get(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c)) + sp.ForecastSoldAmount__c); 
                                        }else{
                                            NetYearlyForecastMap.put(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c), sp.ForecastSoldAmount__c);  
                                        }
                                    SalesPlanningLst.add(sp);
                                }
                            }
                            for(SalesPlanning__c sp : scope){
                                if(sp.Account__c == null  && sp.Frequency__c == 'Monthly' && sp.ForecastTimePoint__c <= system.today().addMonths(12).toStartOfMonth()){
                                    if(ForecastSAMBAMap.containsKey(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c)) && NetMonthlyForecastMap.containsKey(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c))){
                                        if(ForecastSAMBAMap.get(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c)) != null && NetMonthlyForecastMap.get(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c))  != null )
                                            sp.ForecastSoldAmount__c =  ForecastSAMBAMap.get(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c)) - NetMonthlyForecastMap.get(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c));
                                        SalesPlanningLst.add(sp); 
                                    }                                        
                                }
                                if(sp.Account__c == null  && sp.Frequency__c == 'Yearly' ){
                                    if(ForecastSAYBAMap.containsKey(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c)) && NetYearlyForecastMap.containsKey(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c))){
                                        if(ForecastSAYBAMap.get(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c)) != null && NetYearlyForecastMap.get(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c))  != null )
                                            sp.ForecastSoldAmount__c =  ForecastSAYBAMap.get(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c)) - NetYearlyForecastMap.get(sp.BusinessArea__c+'_'+ string.valueOf(sp.ForecastTimePoint__c));
                                        SalesPlanningLst.add(sp);
                                    }
                                }
                            }
                            if(SalesPlanningLst.size() > 0){
                                Update SalesPlanningLst;
                            }
                        }
    public void finish(Database.BatchableContext BC){
        
    }    
}