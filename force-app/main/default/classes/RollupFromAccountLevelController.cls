/****************************************************************************
* Name: RollupFromAccountLevelController
* Author: Naina Butle
* Created Date: 28/03/2023
* Description: Controller class of RollupFromAccountLevelController LWC
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description 
****************************************************************************/
public with sharing class RollupFromAccountLevelController {
    @AuraEnabled
    public static String rollupFromAccountLevelCal(){
        Map<String, List<SalesPlanning__c>>  monthVsSalesPlan = new Map<String, List<SalesPlanning__c>>();
        Map<String, Decimal> monthVsSoldAmount = new Map<String, Decimal>();
        Map<String, Decimal> monthVsNetProceed = new Map<String, Decimal>();
        Savepoint sp;
        try{
            sp = Database.setSavepoint();
            for(SalesPlanning__c  salesPlanloop : [SELECT Id, Account__c, BusinessArea__c,Frequency__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                                   FROM SalesPlanning__c WHERE ForecastLevel__c ='Account' AND //US-3846
                                                   ForecastTimePoint__c > LAST_MONTH  AND ForecastTimePoint__c <= NEXT_N_MONTHS:12 AND Frequency__c ='Monthly' ORDER By ForecastTimePoint__c ASC]){
                                                       DateTime nextMonth = salesPlanloop.ForecastTimePoint__c;
                                                       String monthName = nextMonth.format('MMM yy');
                                                       if(!monthVsSalesPlan.ContainsKey(monthName+'-'+salesPlanloop.BusinessArea__c)){
                                                           monthVsSalesPlan.put(monthName+'-'+salesPlanloop.BusinessArea__c, new List<SalesPlanning__c>());
                                                       }
                                                       monthVsSalesPlan.get(monthName+'-'+salesPlanloop.BusinessArea__c).add(salesPlanloop);
                                                   }
            
            for(String monthLoop : monthVsSalesPlan.keySet()){
                List<SalesPlanning__c> innerMapList = monthVsSalesPlan.get(monthLoop);
                Decimal totalSoldAmount = sumSoldAmount(innerMapList);
                monthVsSoldAmount.put(monthLoop, totalSoldAmount);            
            }
            for(String monthLoop : monthVsSalesPlan.keySet()){
                List<SalesPlanning__c> innerMapList = monthVsSalesPlan.get(monthLoop);
                Decimal totalReceived = 0;
                Decimal average = 0;
                for(SalesPlanning__c dc : innerMapList){
                    if(dc.ForecastSoldAmount__c != null && dc.ForecastNetProceeds__c != null){ //US-3846
                        totalReceived = totalReceived + (dc.ForecastSoldAmount__c * dc.ForecastNetProceeds__c); 
                    }
                }
                if( totalReceived != 0 && monthVsSoldAmount.get(monthLoop) != 0){
                   average = Math.Round(totalReceived / monthVsSoldAmount.get(monthLoop)); 
                }
                monthVsNetProceed.put(monthLoop, average);
            }
            
            Map<String, SalesPlanning__c> dateVsSalesPlann = new Map<String, SalesPlanning__c>();
            for(SalesPlanning__c ss : [SELECT Id, Account__c, BusinessArea__c, Frequency__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                       FROM SalesPlanning__c WHERE ForecastLevel__c ='Business Area/Product Group' AND Account__c = null AND
                                       ForecastTimePoint__c > LAST_MONTH  AND ForecastTimePoint__c <= NEXT_N_MONTHS:12  AND Frequency__c ='Monthly' ORDER By ForecastTimePoint__c ASC]){
                                           DateTime nextMonth = ss.ForecastTimePoint__c;
                                           String monthName = nextMonth.format('MMM yy');
                                           dateVsSalesPlann.put(monthName+'-'+ss.BusinessArea__c, ss);
                                       }
            
            Map<String, SalesPlanning__c> addSoldAmountToSP = addSoldAmountToSP(monthVsSoldAmount, dateVsSalesPlann);
            Map<String, SalesPlanning__c> addNetProceedToSP = addNetProceedToSP(addSoldAmountToSP, monthVsNetProceed, dateVsSalesPlann);     
            
            if(addNetProceedToSP != null && !addNetProceedToSP.isEmpty()){
                update addNetProceedToSP.values();
            }
            return 'Success';
        }catch(Exception e){
            Database.RollBack(sp);
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.SALESPALNNING_OBJECT, ConstantClass.SALESPALNNING_ERROR, '', exdetails, ConstantClass.APEX_CLASS);
            return exdetails;
        }
    }
    
    public static Decimal sumSoldAmount(List<SalesPlanning__c> listOfSP){
        Decimal totalReceived = 0;
        for(SalesPlanning__c dc : listOfSP){
            if(dc.ForecastSoldAmount__c != null){ //US-3846
               totalReceived = totalReceived + dc.ForecastSoldAmount__c; 
            }
        }
        return totalReceived;
    }
    
    
    public static Map<String, SalesPlanning__c> addSoldAmountToSP(Map<String, Decimal> monthVsSoldAmount, Map<String, SalesPlanning__c> dateVsSalesPlann){
        SalesPlanning__c salesPlanUpdate = new SalesPlanning__c();
        Map<String, SalesPlanning__c> salesPlanMapToUpdate = new Map<String, SalesPlanning__c>();
        for(String month : monthVsSoldAmount.keySet()){
            if(dateVsSalesPlann.containsKey(month)){
                salesPlanUpdate = dateVsSalesPlann.get(month);
                salesPlanUpdate.ForecastSoldAmount__c = monthVsSoldAmount.get(month);
                salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
            }
        }
        return salesPlanMapToUpdate;
    }
    
    
    public static Map<String, SalesPlanning__c> addNetProceedToSP(Map<String, SalesPlanning__c> updatedMap, Map<String, Decimal> monthVsNetProceed, Map<String, SalesPlanning__c> dateVsSalesPlann){
        SalesPlanning__c salesPlanUpdate = new SalesPlanning__c();
        Map<String, SalesPlanning__c> salesPlanMapToUpdate = new Map<String, SalesPlanning__c>();
        for(String month : monthVsNetProceed.keySet()){
            if(dateVsSalesPlann.containsKey(month)){
                salesPlanUpdate = dateVsSalesPlann.get(month);
                if(updatedMap.containsKey(salesPlanUpdate.Id))
                    salesPlanUpdate = updatedMap.get(salesPlanUpdate.Id); 
                salesPlanUpdate.ForecastNetProceeds__c = monthVsNetProceed.get(month);
                salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
            }
        }
        return salesPlanMapToUpdate;
    }
    
    //US-3586
    @AuraEnabled
    public static String rollupAnnualPlanningCal(){
        Savepoint spoint;
        try{
            spoint = Database.setSavepoint();
        Date currentDate = Date.today();
        Integer NextYear = currentDate.year()+1;
        Integer NextYear2 = currentDate.year()+2;
        Integer NextYear3 = currentDate.year()+3;
        
        Map<String, Decimal> yearVsSoldAmount = new Map<String, Decimal>();
        Map<String, Decimal> YearlyNetProcceed = new Map<String, Decimal>();
        Map<String, List<SalesPlanning__c>>  yearVsSalesPlan = new Map<String, List<SalesPlanning__c>>();
        
            for(SalesPlanning__c salesPlanloop : [SELECT Id, Name, BusinessArea__c,ForecastTimePoint__c,ForecastLevel__c,ForecastSoldAmount__c,
                                                        ForecastNetProceeds__c,Frequency__c,DeltaNetProceeds__c FROM SalesPlanning__c WHERE Frequency__c='Yearly' AND ForecastLevel__c ='Account' Order by BusinessArea__c]){
                
                if(salesPlanloop.ForecastTimePoint__c.year() == NextYear){
                    if(!yearVsSalesPlan.ContainsKey(NextYear+':'+salesPlanloop.BusinessArea__c)){
                        yearVsSalesPlan.put(NextYear+':'+salesPlanloop.BusinessArea__c, new List<SalesPlanning__c>());
                    }
                    yearVsSalesPlan.get(NextYear+':'+salesPlanloop.BusinessArea__c).add(salesPlanloop);
                }
                else if(salesPlanloop.ForecastTimePoint__c.year() == NextYear2){
                    if(!yearVsSalesPlan.ContainsKey(NextYear2+':'+salesPlanloop.BusinessArea__c)){
                        yearVsSalesPlan.put(NextYear2+':'+salesPlanloop.BusinessArea__c, new List<SalesPlanning__c>());
                    }
                    yearVsSalesPlan.get(NextYear2+':'+salesPlanloop.BusinessArea__c).add(salesPlanloop);
                }
                else if(salesPlanloop.ForecastTimePoint__c.year() == NextYear3){
                    if(!yearVsSalesPlan.ContainsKey(NextYear3+':'+salesPlanloop.BusinessArea__c)){
                        yearVsSalesPlan.put(NextYear3+':'+salesPlanloop.BusinessArea__c, new List<SalesPlanning__c>());
                    }
                    yearVsSalesPlan.get(NextYear3+':'+salesPlanloop.BusinessArea__c).add(salesPlanloop);
                }
            }
            for(String yearLoop : yearVsSalesPlan.keySet()){
                List<SalesPlanning__c> innerMapList = yearVsSalesPlan.get(yearLoop);
                Decimal totalSoldAmount = sumSoldAmount(innerMapList);
                string[] yearss;
                yearss = yearLoop.split(':');
                if(yearss[0] == String.valueof(NextYear)){
                    yearVsSoldAmount.put('yearlySoldAmount'+yearss[1], totalSoldAmount);   
                } 
                else if(yearss[0] == String.valueof(NextYear2)){
                    yearVsSoldAmount.put('yearly1SoldAmount'+yearss[1], totalSoldAmount);   
                }
                else if(yearss[0] == String.valueof(NextYear3)){
                    yearVsSoldAmount.put('yearly2SoldAmount'+yearss[1], totalSoldAmount);   
                }
                yearss.clear();
            }          
           
            for(String yearLoop : yearVsSalesPlan.keySet()){
                List<SalesPlanning__c> innerMapList = yearVsSalesPlan.get(yearLoop);
                Decimal totalReceived = 0;
                Decimal average = 0;
                for(SalesPlanning__c dc : innerMapList){
                    if(dc.ForecastSoldAmount__c != null && dc.ForecastNetProceeds__c != null){ //US-3846
                        totalReceived = totalReceived + (dc.ForecastSoldAmount__c * dc.ForecastNetProceeds__c); 
                    }
                }
               
                string[] yearss;
                yearss = yearLoop.split(':');
                if(yearss[0] == String.valueof(NextYear)){
                    if( totalReceived != 0 && yearVsSoldAmount.get('yearlySoldAmount'+yearss[1]) != 0){
                        average = Math.Round(totalReceived / yearVsSoldAmount.get('yearlySoldAmount'+yearss[1])); 
                    }
                     YearlyNetProcceed.put('yearlySoldAmount'+yearss[1], average);
                }
                else if(yearss[0] == String.valueof(NextYear2)){
                    if( totalReceived != 0 && yearVsSoldAmount.get('yearly1SoldAmount'+yearss[1]) != 0){
                        average = Math.Round(totalReceived / yearVsSoldAmount.get('yearly1SoldAmount'+yearss[1])); 
                    }
                    YearlyNetProcceed.put('yearly1SoldAmount'+yearss[1], average);
                }
                else if(yearss[0] == String.valueof(NextYear3)){
                     if( totalReceived != 0 && yearVsSoldAmount.get('yearly2SoldAmount'+yearss[1]) != 0){
                        average = Math.Round(totalReceived / yearVsSoldAmount.get('yearly2SoldAmount'+yearss[1])); 
                    }
                       YearlyNetProcceed.put('yearly2SoldAmount'+yearss[1], average);
                }
                yearss.clear();
            }
            
            Map<String, SalesPlanning__c> addAmountToSP = updateSalesplanningRecord(yearVsSoldAmount, YearlyNetProcceed);
            
            if(addAmountToSP != null && !addAmountToSP.isEmpty()){
                update addAmountToSP.values();
            }
            return 'Success';
        }catch(Exception e){
            Database.RollBack(spoint);
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.SALESPALNNING_OBJECT, ConstantClass.SALESPALNNING_ERROR, '', exdetails, ConstantClass.APEX_CLASS);
            return exdetails;
        }
    }
    
    public static Map<String, SalesPlanning__c> updateSalesplanningRecord(Map<String, Decimal> YearlySoldAmount, Map<String, Decimal> YearlyNetProcceed){
        Map<String, SalesPlanning__c> dateVsSalesPlann = new Map<String, SalesPlanning__c>();
        Map<String, SalesPlanning__c> salesPlanMapToUpdate = new Map<String, SalesPlanning__c>();
        SalesPlanning__c salesPlanUpdate = new SalesPlanning__c();
        Date currentDate = Date.today();
        Integer currentYear = currentDate.year();
        List<SalesPlanning__c> salesPlanningNextYear = [SELECT Id, Name, BusinessArea__c, ForecastTimePoint__c, ForecastLevel__c, ForecastSoldAmount__c,
                                                        ForecastNetProceeds__c, Frequency__c, DeltaNetProceeds__c FROM SalesPlanning__c WHERE Frequency__c='Yearly' AND ForecastLevel__c ='Business Area/Product Group'
                                                        AND ForecastTimePoint__c >= NEXT_N_YEARS:3 AND ForecastTimePoint__c <= NEXT_N_YEARS:3  ORDER By ForecastTimePoint__c ASC];
        for( SalesPlanning__c ss : salesPlanningNextYear){
            Integer yearss = ss.ForecastTimePoint__c.year();
            if(yearss == currentYear + 1){
                dateVsSalesPlann.put('yearlySoldAmount'+ss.BusinessArea__c, ss);
            }
            else if(yearss == currentYear + 2){
                dateVsSalesPlann.put('yearly1SoldAmount'+ss.BusinessArea__c, ss);
            }
            else if(yearss == currentYear + 3){
                dateVsSalesPlann.put('yearly2SoldAmount'+ss.BusinessArea__c, ss);
            }
        }
        
        for(String yearSold : YearlySoldAmount.keySet()){
            if(dateVsSalesPlann.containsKey(yearSold)){
                salesPlanUpdate = dateVsSalesPlann.get(yearSold);
                salesPlanUpdate.ForecastSoldAmount__c = YearlySoldAmount.get(yearSold);
                salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
            }
        }
        
        for(String yearNet : YearlyNetProcceed.keySet()){
            if(dateVsSalesPlann.containsKey(yearNet)){
                salesPlanUpdate = dateVsSalesPlann.get(yearNet);
                if(salesPlanMapToUpdate.containsKey(salesPlanUpdate.Id))
                    salesPlanUpdate = salesPlanMapToUpdate.get(salesPlanUpdate.Id); 
                salesPlanUpdate.ForecastNetProceeds__c = YearlyNetProcceed.get(yearNet);
                salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
            }
        }
        return salesPlanMapToUpdate;
    }
}