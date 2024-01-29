/****************************************************************************
* Name: SalesForecastingController 
* Author: Naina Butle
* Created Date: 27/03/2023
* Description: Controller class of SalesForecasting LWC
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description 
* Gunjan Saxena     29/03/2023              US-2399 - Creation of method SubmitBAPlanning - This Method is called when Submit button is clicked from BusinessArea Sales Planning Lightning Page/businessPlanning Component. 
* Gunjan Saxena     04/08/2023              US-6779 - part 1
****************************************************************************/
public with sharing class SalesForecastingController {
    
    public class BusAreawrapper {
        @AuraEnabled public String BusinessArea {get;set;}
        @AuraEnabled public Decimal ActualSoldAmount{get;set;}
        @AuraEnabled public Decimal currentFSoldAmount{get;set;}
        @AuraEnabled public Decimal current1FSoldAmount{get;set;}     
        @AuraEnabled public Decimal current2FSoldAmount {get;set;} 
        @AuraEnabled public Decimal current3FSoldAmount {get;set;} 
        @AuraEnabled public Decimal current4FSoldAmount {get;set;}
        @AuraEnabled public Decimal current5FSoldAmount {get;set;}
        @AuraEnabled public Decimal current6FSoldAmount {get;set;}
        @AuraEnabled public Decimal current7FSoldAmount {get;set;}
        @AuraEnabled public Decimal current8FSoldAmount {get;set;}
        @AuraEnabled public Decimal current9FSoldAmount {get;set;}
        @AuraEnabled public Decimal current10FSoldAmount{get;set;}
        @AuraEnabled public Decimal current11FSoldAmount {get;set;}
        @AuraEnabled public Decimal current12FSoldAmount {get;set;}
        @AuraEnabled public Decimal rollingForecastCurrentYear {get;set;}
        @AuraEnabled public Decimal yearlySoldAmount {get;set;}
        @AuraEnabled public Decimal yearly1SoldAmount {get;set;}
        @AuraEnabled public Decimal yearly2SoldAmount {get;set;}
        public BusAreawrapper(String BusinessArea, Decimal ActualSoldAmount,
                              Decimal currentFSoldAmount, Decimal current1FSoldAmount, Decimal current2FSoldAmount, Decimal current3FSoldAmount, Decimal current4FSoldAmount,
                              Decimal current5FSoldAmount, Decimal current6FSoldAmount,Decimal current7FSoldAmount ,Decimal current8FSoldAmount,Decimal current9FSoldAmount,Decimal current10FSoldAmount,Decimal current11FSoldAmount, Decimal current12FSoldAmount,
                              Decimal rollingForecastCurrentYear, Decimal yearlySoldAmount,Decimal yearly1SoldAmount,Decimal yearly2SoldAmount){
                                  
                                  this.BusinessArea = BusinessArea;
                                  this.ActualSoldAmount = ActualSoldAmount;
                                  this.currentFSoldAmount = currentFSoldAmount ; 
                                  this.current1FSoldAmount = current1FSoldAmount ; 
                                  this.current2FSoldAmount = current2FSoldAmount ; 
                                  this.current3FSoldAmount = current3FSoldAmount ; 
                                  this.current4FSoldAmount = current4FSoldAmount; 
                                  this.current5FSoldAmount = current5FSoldAmount ; 
                                  this.current6FSoldAmount = current6FSoldAmount ; 
                                  this.current7FSoldAmount = current7FSoldAmount ; 
                                  this.current8FSoldAmount  = current8FSoldAmount ; 
                                  this.current9FSoldAmount  = current9FSoldAmount ; 
                                  this.current10FSoldAmount  = current10FSoldAmount; 
                                  this.current11FSoldAmount  = current11FSoldAmount ; 
                                  this.current12FSoldAmount  = current12FSoldAmount ; 
                                  this.rollingForecastCurrentYear  = rollingForecastCurrentYear ; 
                                  this.yearlySoldAmount  = yearlySoldAmount ; 
                                  this.yearly1SoldAmount  = yearly1SoldAmount ; 
                                  this.yearly2SoldAmount  = yearly2SoldAmount ; 
                              }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getColumnNames() {
        List<String> columnNames = new List<String>();
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.year();
        String bs = System.label.BusinessArea; //'Business Area'; 
        columnNames.add(bs);
        for (Integer i = -1; i <= 12; i++) {
            DateTime nextMonth = Date.newInstance(currentYear, currentMonth + i, 1);
            String monthName = nextMonth.format('MMM yy');
            columnNames.add(monthName);
        }
        columnNames.add(System.label.RollingForeCastCurrentYear);
        for (Integer i = 1; i <= 3; i++) {
            DateTime nextYear = Date.newInstance(currentYear + i, currentMonth, 1);
            String monthName = nextYear.format('yyyy');
            columnNames.add(monthName);
        } 
        return columnNames;
    }
    
    @AuraEnabled(cacheable=true)
    public static DataTableResponse getSoldAmount() { 
        //forcast amount
        Map<String, Map<Date,Decimal>> busAreaVsForecastvalue = new Map<String, Map<Date,Decimal>>();
        Map<String, Map<Date,Decimal>> busAreaVsForecastNetProceedMap = new Map<String, Map<Date,Decimal>>();
        //actual amount
        Map<String, Decimal> busAreaVsActualSoldAmount = new  Map<String, Decimal>();
        Map<String, Decimal> busAreaVsActualNetProceeds = new  Map<String, Decimal>();
        //RollingFCurrentYrMap
        Map<String, List<Decimal>> soldAmountRollingFCurrentYrMap = new Map<String, List<Decimal>>();
        Map<String, Map<String, SalesPlanning__c>> netProceedRollingFCurrentYrMap = new Map<String, Map<String, SalesPlanning__c>>(); //4292
        Map<String, Decimal> bASoldAmountVsRFCurYr = new Map<String, Decimal>();
        Map<String, Decimal> bAFNetVsRFCurYr = new Map<String, Decimal>();
        Decimal totalRollingFCurrentYr = 0;
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.year();
        List<SalesPlanning__c> SalesPlanningList= new List<SalesPlanning__c>([SELECT Id, Account__c, toLabel(BusinessArea__c), ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, Frequency__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                                                              FROM SalesPlanning__c WHERE ForecastLevel__c ='Business Area/Product Group' AND Account__c = null AND BusinessArea__c != null AND Frequency__c ='Monthly' AND //4250 //US-3847 
                                                                              ForecastTimePoint__c > LAST_MONTH  AND ForecastTimePoint__c <= NEXT_N_MONTHS:12 ORDER By ForecastTimePoint__c,BusinessArea__c ASC]);  //US-3911
        
        for(SalesPlanning__c salesPlanloop : SalesPlanningList){
            // map to store Forecast Sold Amount values
            if (!busAreaVsForecastvalue.containsKey(salesPlanloop.BusinessArea__c)) {
                busAreaVsForecastvalue.put(salesPlanloop.BusinessArea__c, new Map<Date, Decimal>());
            }
            Map<Date, Decimal> innerMap = busAreaVsForecastvalue.get(salesPlanloop.BusinessArea__c);
            innerMap.put(salesPlanloop.ForecastTimePoint__c, salesPlanloop.ForecastSoldAmount__c);
            // map to store Forecast Net Proceeds values
            if (!busAreaVsForecastNetProceedMap.containsKey(salesPlanloop.BusinessArea__c)) {
                busAreaVsForecastNetProceedMap.put(salesPlanloop.BusinessArea__c, new Map<Date, Decimal>());
            }
            Map<Date, Decimal> innerMapNetProceed = busAreaVsForecastNetProceedMap.get(salesPlanloop.BusinessArea__c);
            innerMapNetProceed.put(salesPlanloop.ForecastTimePoint__c, salesPlanloop.ForecastNetProceeds__c);
        }
        
        List<SalesPlanning__c> salesPlanningFullYear = [SELECT Id, Account__c, toLabel(BusinessArea__c), Frequency__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, 
                                                        ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c
                                                        FROM SalesPlanning__c WHERE ForecastLevel__c ='Business Area/Product Group' AND Frequency__c ='Monthly' //4250
                                                        AND BusinessArea__c != null AND Account__c = null
                                                        ORDER By ForecastTimePoint__c ASC];
        
        for(SalesPlanning__c sPlanLoop : salesPlanningFullYear){
            if((sPlanLoop.ForecastTimePoint__c.month() == currentMonth - 1 && sPlanLoop.ForecastTimePoint__c.Year() == currentYear) || (sPlanLoop.ForecastTimePoint__c.month() == 12 && sPlanLoop.ForecastTimePoint__c.Year() == currentYear -1)){
                if(sPlanLoop.BusinessArea__c != null && sPlanLoop.ActualSoldAmount__c != null ){
                    busAreaVsActualSoldAmount.put(sPlanLoop.BusinessArea__c, Math.round(sPlanLoop.ActualSoldAmount__c)); //4695
                }
                if(sPlanLoop.BusinessArea__c != null && sPlanLoop.ActualNetProceeds__c != null ){
                    busAreaVsActualNetProceeds.put(sPlanLoop.BusinessArea__c, Math.round(sPlanLoop.ActualNetProceeds__c));//4695
                }
            }
            DateTime nextMonth = sPlanLoop.ForecastTimePoint__c;
            String monthName = nextMonth.format('MMM yy');
            
            if(sPlanLoop.ForecastTimePoint__c.month() < currentMonth && sPlanLoop.ForecastTimePoint__c.Year() == currentYear){
                if(sPlanLoop.BusinessArea__c != null && sPlanLoop.ActualSoldAmount__c != null ){
                    if(!soldAmountRollingFCurrentYrMap.ContainsKey(sPlanLoop.BusinessArea__c)){
                        soldAmountRollingFCurrentYrMap.put(sPlanLoop.BusinessArea__c, New List<Decimal>()); 
                    }
                    soldAmountRollingFCurrentYrMap.get(sPlanLoop.BusinessArea__c).add(sPlanLoop.ActualSoldAmount__c); 
                }
                if(sPlanLoop.BusinessArea__c != null && sPlanLoop.ActualNetProceeds__c != null ){
                    //4292
                    if (!netProceedRollingFCurrentYrMap.containsKey(sPlanLoop.BusinessArea__c)) {
                        Map<String, SalesPlanning__c> innerMap = new Map<String, SalesPlanning__c>();
                        innerMap.put(monthName, sPlanLoop);
                        netProceedRollingFCurrentYrMap.put(sPlanLoop.BusinessArea__c, innerMap);
                    } else {
                        Map<String, SalesPlanning__c> innerMap = netProceedRollingFCurrentYrMap.get(sPlanLoop.BusinessArea__c);
                        innerMap.put(monthName, sPlanLoop);
                    }
                }
            }
            if(sPlanLoop.ForecastTimePoint__c.month() >= currentMonth && sPlanLoop.ForecastTimePoint__c.Year() == currentYear){
                if(sPlanLoop.BusinessArea__c != null && sPlanLoop.ForecastSoldAmount__c != null ){
                    if(!soldAmountRollingFCurrentYrMap.ContainsKey(sPlanLoop.BusinessArea__c)){
                        soldAmountRollingFCurrentYrMap.put(sPlanLoop.BusinessArea__c, New List<Decimal>()); 
                    }
                    soldAmountRollingFCurrentYrMap.get(sPlanLoop.BusinessArea__c).add(sPlanLoop.ForecastSoldAmount__c); 
                }
                if(sPlanLoop.BusinessArea__c != null && sPlanLoop.ForecastNetProceeds__c != null ){
                    //4292
                    if (!netProceedRollingFCurrentYrMap.containsKey(sPlanLoop.BusinessArea__c)) {
                        Map<String, SalesPlanning__c> innerMap = new Map<String, SalesPlanning__c>();
                        innerMap.put(monthName, sPlanLoop);
                        netProceedRollingFCurrentYrMap.put(sPlanLoop.BusinessArea__c, innerMap);
                    } else {
                        Map<String, SalesPlanning__c> innerMap = netProceedRollingFCurrentYrMap.get(sPlanLoop.BusinessArea__c);
                        innerMap.put(monthName, sPlanLoop);
                    }
                } 
            }
        }
        
        for(String rCYLoop : soldAmountRollingFCurrentYrMap.Keyset()){
            for(Decimal dc : soldAmountRollingFCurrentYrMap.get(rCYLoop)){
                totalRollingFCurrentYr = Math.Round(totalRollingFCurrentYr + dc);
            }
            bASoldAmountVsRFCurYr.put(rCYLoop, totalRollingFCurrentYr);
            totalRollingFCurrentYr = 0;
        }
        //4292 -start
        for(String monthLoop : netProceedRollingFCurrentYrMap.keySet()){
            Map<String, SalesPlanning__c> innerMapList = netProceedRollingFCurrentYrMap.get(monthLoop);
            Decimal totalReceived = 0;
            for(SalesPlanning__c sPlanLoop : innerMapList.values()){
                if(sPlanLoop.ForecastTimePoint__c.month() < currentMonth && sPlanLoop.ForecastTimePoint__c.Year() == currentYear){
                    if(sPlanLoop.BusinessArea__c != null && sPlanLoop.ActualSoldAmount__c != null && sPlanLoop.ActualNetProceeds__c != null){
                        totalReceived = totalReceived + (sPlanLoop.ActualNetProceeds__c * sPlanLoop.ActualSoldAmount__c);
                    }
                }else if(sPlanLoop.ForecastTimePoint__c.month() >= currentMonth && sPlanLoop.ForecastTimePoint__c.Year() == currentYear){
                    if(sPlanLoop.BusinessArea__c != null && sPlanLoop.ForecastSoldAmount__c != null && sPlanLoop.ForecastNetProceeds__c != null){
                         totalReceived = totalReceived + (sPlanLoop.ForecastNetProceeds__c * sPlanLoop.ForecastSoldAmount__c);
                    }
                }
            }
                Decimal totalSoldAmmount = bASoldAmountVsRFCurYr.containsKey(monthLoop) ? bASoldAmountVsRFCurYr.get(monthLoop) : 0;
                Decimal averageNet;
                if( totalReceived != 0 && totalSoldAmmount != 0){
                    averageNet = Math.Round(totalReceived / totalSoldAmmount); 
                }
                bAFNetVsRFCurYr.put(monthLoop, averageNet);
        }
        //4292 end
        //US-3586 - Start
        Map<String, Decimal> YearlySoldAmount = new Map<String, Decimal>();
        Map<String, Decimal> YearlyNetProcceed = new Map<String, Decimal>();
        for( SalesPlanning__c ss : [SELECT Id, Name, tolabel(BusinessArea__c), ForecastTimePoint__c, ForecastLevel__c, ForecastSoldAmount__c,
                                    ForecastNetProceeds__c, Frequency__c, DeltaNetProceeds__c FROM SalesPlanning__c WHERE Frequency__c='Yearly' AND ForecastLevel__c ='Business Area/Product Group' //AND BusinessArea__c !='Across Business Area' 
                                    AND ForecastTimePoint__c >= NEXT_N_YEARS:3 AND ForecastTimePoint__c <= NEXT_N_YEARS:3
                                    ORDER By ForecastTimePoint__c ASC]){
                                        Integer yearss = ss.ForecastTimePoint__c.year();
                                        if(yearss == currentYear + 1){
                                            if(ss.ForecastSoldAmount__c != null){
                                                YearlySoldAmount.put('yearlySoldAmount'+ss.BusinessArea__c, ss.ForecastSoldAmount__c);
                                            }
                                            if(ss.ForecastNetProceeds__c != null){
                                                YearlyNetProcceed.put('yearlySoldAmount'+ss.BusinessArea__c, ss.ForecastNetProceeds__c);
                                            }
                                        }
                                        else if(yearss == currentYear + 2){
                                            if(ss.ForecastSoldAmount__c != null){
                                                YearlySoldAmount.put('yearly1SoldAmount'+ss.BusinessArea__c, ss.ForecastSoldAmount__c);
                                            }
                                            if(ss.ForecastNetProceeds__c != null){
                                                YearlyNetProcceed.put('yearly1SoldAmount'+ss.BusinessArea__c, ss.ForecastNetProceeds__c);
                                            }
                                        }
                                        else if(yearss == currentYear + 3){
                                            if(ss.ForecastSoldAmount__c != null){
                                                YearlySoldAmount.put('yearly2SoldAmount'+ss.BusinessArea__c, ss.ForecastSoldAmount__c);
                                            }
                                            if(ss.ForecastNetProceeds__c != null){
                                                YearlyNetProcceed.put('yearly2SoldAmount'+ss.BusinessArea__c, ss.ForecastNetProceeds__c);
                                            }
                                            
                                        }
                                    }
        //US-3586 - end
        List<BusAreawrapper> bsSoldWrap =  getBusAreawrapper(busAreaVsForecastvalue, busAreaVsActualSoldAmount, bASoldAmountVsRFCurYr, YearlySoldAmount); 
        List<BusAreawrapper> bsNetProceedWrap =  getBusAreawrapper(busAreaVsForecastNetProceedMap, busAreaVsActualNetProceeds, bAFNetVsRFCurYr, YearlyNetProcceed); 
        Schema.DescribeFieldResult fieldResult = SalesPlanning__c.BusinessArea__c.getDescribe();
        Map<string,BusAreawrapper> bsSoldmap = new Map<string,BusAreawrapper>();
        Map<string,BusAreawrapper> bsNetProceedmap = new Map<string,BusAreawrapper>();
       	//List<string> bsSoldWrapBAlst = new List<string>();
        //List<string> bsNetProceedWrapBAlst = new List<string>();
        for(BusAreawrapper BAWrapper : bsSoldWrap){
            bsSoldmap.put(BAWrapper.BusinessArea,BAWrapper);
        }
        for(BusAreawrapper BAWrapper : bsNetProceedWrap){
            bsNetProceedmap.put(BAWrapper.BusinessArea,BAWrapper);
        }
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        bsSoldWrap.clear();
        bsNetProceedWrap.clear();
        for( Schema.PicklistEntry pickListVal : ple){
            if(!bsSoldmap.containskey(pickListVal.getLabel())){
                bsSoldWrap.add(new BusAreawrapper(pickListVal.getLabel(), null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
            }else{
                bsSoldWrap.add(bsSoldmap.get(pickListVal.getLabel()));
            }
            if(!bsNetProceedmap.containskey(pickListVal.getLabel())){
                bsNetProceedWrap.add(new BusAreawrapper(pickListVal.getLabel(), null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
            }else{
                bsNetProceedWrap.add(bsNetProceedmap.get(pickListVal.getLabel()));
            }
        }
        Map<String, Decimal> soldTotal = soldCalculation(bsSoldWrap);
        List<Decimal> listsoldTotal = new List<Decimal>();
        for(Decimal dc :  soldTotal.values()){
            listsoldTotal.add(dc);
        }
        List<BusAreawrapper> soldDrawingList = getDrawingPicklist(bsSoldWrap);
        Map<String, Decimal> soldTotalDrawing = soldCalculation(soldDrawingList);
        List<Decimal> listDrawingsoldTotal = new List<Decimal>();
        for(Decimal dc :  soldTotalDrawing.values()){
            listDrawingsoldTotal.add(dc);
        }
        List<BusAreawrapper> NetDrawingList = getDrawingPicklist(bsNetProceedWrap);
        DataTableResponse finalWrapper   = new DataTableResponse();
        finalWrapper.getSoldAmount = bsSoldWrap;  // forecaste sold amount data
        finalWrapper.ForecastNetProceeds = bsNetProceedWrap;// forecast net Proceed data
        finalWrapper.soldCalculation = listsoldTotal;
        finalWrapper.netProceedCalculation =  netAverageCalculation(bsSoldWrap, bsNetProceedWrap, soldTotal);
        finalWrapper.drawingSoldCalculation = listDrawingsoldTotal;
        finalWrapper.drawingnetProceedCalculation = netAverageCalculation(soldDrawingList, NetDrawingList, soldTotalDrawing);
        return finalWrapper;
    }
    
    
    public static List<Decimal> netAverageCalculation(List<BusAreawrapper> soldWrap, List<BusAreawrapper> netWrap, Map<String, Decimal> soldTotal){
        Map<String, BusAreawrapper> soldWrapperMap = new Map<String, BusAreawrapper>();
        decimal totalNetActual = 0; //4112
        decimal totalNetF = 0;
        decimal totalNetF1 = 0;
        decimal totalNetF2 = 0;
        decimal totalNetF3 = 0;
        decimal totalNetF4 = 0;
        decimal totalNetF5 = 0;
        decimal totalNetF6 = 0;
        decimal totalNetF7 = 0;
        decimal totalNetF8 = 0;
        decimal totalNetF9 = 0;
        decimal totalNetF10 = 0;
        decimal totalNetF11 = 0;
        decimal totalNetF12 = 0;
        decimal totalNetNextyear = 0;
        decimal totalNetNextyear1 = 0;
        decimal totalNetNextyear2 = 0;
        decimal totalrollingForecastCurrentYear = 0;
        for(BusAreawrapper soldLoop : soldWrap)
        {
            soldWrapperMap.put(soldLoop.BusinessArea, soldLoop);
        }
        for(BusAreawrapper bs : netWrap){
            if(soldWrapperMap.containsKey(bs.BusinessArea)){
                BusAreawrapper  soldList = soldWrapperMap.get(bs.BusinessArea);
                totalNetActual = totalNetActual + (bs.actualSoldAmount != null ? bs.actualSoldAmount : 0 ) * (soldList.actualSoldAmount != null ? soldList.actualSoldAmount : 0); //4112
                totalNetF = totalNetF + (bs.currentFSoldAmount != null ? bs.currentFSoldAmount : 0 ) * (soldList.currentFSoldAmount != null ? soldList.currentFSoldAmount : 0);
                totalNetF1 = totalNetF1 + (bs.current1FSoldAmount != null ? bs.current1FSoldAmount : 0) * (soldList.current1FSoldAmount != null ? soldList.current1FSoldAmount : 0);
                totalNetF2 = totalNetF2 + (bs.current2FSoldAmount != null ? bs.current2FSoldAmount : 0) * (soldList.current2FSoldAmount != null ? soldList.current2FSoldAmount : 0);
                totalNetF3 = totalNetF3 + (bs.current3FSoldAmount != null ? bs.current3FSoldAmount : 0) * (soldList.current3FSoldAmount != null ? soldList.current3FSoldAmount : 0);
                totalNetF4 = totalNetF4 + (bs.current4FSoldAmount != null ? bs.current4FSoldAmount : 0) * (soldList.current4FSoldAmount != null ? soldList.current4FSoldAmount : 0);
                totalNetF5 = totalNetF5 + (bs.current5FSoldAmount != null ? bs.current5FSoldAmount : 0) * (soldList.current5FSoldAmount != null ? soldList.current5FSoldAmount : 0);
                totalNetF6 = totalNetF6 + (bs.current6FSoldAmount != null ? bs.current6FSoldAmount : 0) * (soldList.current6FSoldAmount != null ? soldList.current6FSoldAmount : 0);
                totalNetF7 = totalNetF7 +  (bs.current7FSoldAmount != null ? bs.current7FSoldAmount : 0) * (soldList.current7FSoldAmount != null ? soldList.current7FSoldAmount : 0);
                totalNetF8 = totalNetF8 + (bs.current8FSoldAmount != null ? bs.current8FSoldAmount : 0) * (soldList.current8FSoldAmount != null ? soldList.current8FSoldAmount : 0);
                totalNetF9 = totalNetF9 + (bs.current9FSoldAmount != null ? bs.current9FSoldAmount : 0) * (soldList.current9FSoldAmount != null ? soldList.current9FSoldAmount : 0);
                totalNetF10 = totalNetF10 + (bs.current10FSoldAmount != null ? bs.current10FSoldAmount : 0) * (soldList.current10FSoldAmount != null ? soldList.current10FSoldAmount : 0);
                totalNetF11 = totalNetF11 + (bs.current11FSoldAmount != null ? bs.current11FSoldAmount : 0) * (soldList.current11FSoldAmount != null ?soldList.current11FSoldAmount : 0);
                totalNetF12 = totalNetF12 + (bs.current12FSoldAmount != null ? bs.current12FSoldAmount : 0) * (soldList.current12FSoldAmount != null ? soldList.current12FSoldAmount : 0);
                totalrollingForecastCurrentYear = totalrollingForecastCurrentYear + (bs.rollingForecastCurrentYear != null ? bs.rollingForecastCurrentYear : 0) * (soldList.rollingForecastCurrentYear != null ? soldList.rollingForecastCurrentYear : 0);
                totalNetNextyear = totalNetNextyear + (bs.yearlySoldAmount != null ? bs.yearlySoldAmount : 0) * (soldList.yearlySoldAmount != null ? soldList.yearlySoldAmount : 0);
                totalNetNextyear1 = totalNetNextyear1 + (bs.yearly1SoldAmount != null ? bs.yearly1SoldAmount : 0) * (soldList.yearly1SoldAmount != null ? soldList.yearly1SoldAmount : 0);
                totalNetNextyear2 = totalNetNextyear2 + (bs.yearly2SoldAmount != null ? bs.yearly2SoldAmount : 0) * (soldList.yearly2SoldAmount != null ? soldList.yearly2SoldAmount : 0);
            }
        }
        List<Decimal> listAverageNet = new List<Decimal>();
        if(totalNetActual != 0 && soldTotal.get('actualSoldAmount') != 0){
            listAverageNet.add(Math.Round(totalNetActual / soldTotal.get('actualSoldAmount')));
        }else{
            listAverageNet.add(0);
        } //4112        
        if(totalNetF != 0 && soldTotal.get('currentFSoldAmount') != 0){
            listAverageNet.add(Math.Round(totalNetF / soldTotal.get('currentFSoldAmount')));
        }else{
            listAverageNet.add(0);
        }
        if(totalNetF1 != 0 && soldTotal.get('current1FSoldAmount') != 0){
            listAverageNet.add(Math.Round(totalNetF1 / soldTotal.get('current1FSoldAmount')));
        }else{
            listAverageNet.add(0);
        }
        if(totalNetF2 != 0 && soldTotal.get('current2FSoldAmount') != 0){
            listAverageNet.add(Math.Round(totalNetF2 / soldTotal.get('current2FSoldAmount')));
        }else{
            listAverageNet.add(0);
        }
        if(totalNetF3 != 0 && soldTotal.get('current3FSoldAmount') != 0){
            listAverageNet.add(Math.Round(totalNetF3 / soldTotal.get('current3FSoldAmount')));
        }else{
            listAverageNet.add(0);
        }
        if(totalNetF4 != 0 && soldTotal.get('current4FSoldAmount') != 0){
            listAverageNet.add(Math.Round(totalNetF4 / soldTotal.get('current4FSoldAmount')));
        }else{
            listAverageNet.add(0);
        }
        if(totalNetF5 != 0 && soldTotal.get('current5FSoldAmount') != 0){
            listAverageNet.add(Math.Round(totalNetF5 / soldTotal.get('current5FSoldAmount')));
        }else{
            listAverageNet.add(0);
        }
        if(totalNetF6 != 0 && soldTotal.get('current6FSoldAmount') != 0){
            listAverageNet.add(Math.Round(totalNetF6 / soldTotal.get('current6FSoldAmount')));
        }else{
            listAverageNet.add(0);
        }
        if(totalNetF7 != 0 && soldTotal.get('current7FSoldAmount') != 0){
            listAverageNet.add(Math.Round(totalNetF7 / soldTotal.get('current7FSoldAmount')));
        }else{
            listAverageNet.add(0);
        }
        if(totalNetF8 != 0 && soldTotal.get('current8FSoldAmount') != 0){
            listAverageNet.add(Math.Round(totalNetF8 / soldTotal.get('current8FSoldAmount')));
        }else{
            listAverageNet.add(0);
        }
        if(totalNetF9 != 0 && soldTotal.get('current9FSoldAmount') != 0){
            listAverageNet.add(Math.Round(totalNetF9 / soldTotal.get('current9FSoldAmount')));
        }else{
            listAverageNet.add(0);
        }
        if(totalNetF10 != 0 && soldTotal.get('current10FSoldAmount') != 0){
            listAverageNet.add(Math.Round(totalNetF10 / soldTotal.get('current10FSoldAmount')));
        }else{
            listAverageNet.add(0);
        }
        if(totalNetF11 != 0 && soldTotal.get('current11FSoldAmount') != 0){
            listAverageNet.add(Math.Round(totalNetF11 / soldTotal.get('current11FSoldAmount')));
        }else{
            listAverageNet.add(0);
        }
        if(totalNetF12 != 0 && soldTotal.get('current12FSoldAmount') != 0){
            listAverageNet.add(Math.Round(totalNetF12 / soldTotal.get('current12FSoldAmount')));
        }else{
            listAverageNet.add(0);
        }
        if(totalrollingForecastCurrentYear != 0 && soldTotal.get('rollingForecastCurrentYear') != 0){
            listAverageNet.add(Math.Round(totalrollingForecastCurrentYear / soldTotal.get('rollingForecastCurrentYear')));
        }else{
            listAverageNet.add(0);
        }
        if(totalNetNextyear != 0 && soldTotal.get('yearlySoldAmount') != 0){
            listAverageNet.add(Math.Round(totalNetNextyear / soldTotal.get('yearlySoldAmount')));
        }else{
            listAverageNet.add(0);
        }
        if(totalNetNextyear1 != 0 && soldTotal.get('yearly1SoldAmount') != 0){
            listAverageNet.add(Math.Round(totalNetNextyear1 / soldTotal.get('yearly1SoldAmount')));
        }else{
            listAverageNet.add(0);
        }
        if(totalNetNextyear2 != 0 && soldTotal.get('yearly2SoldAmount') != 0){
            listAverageNet.add(Math.Round(totalNetNextyear2 / soldTotal.get('yearly2SoldAmount')));
        }else{
            listAverageNet.add(0);
        }
        
        return listAverageNet;
    }
    
    
    public class DataTableResponse {
        @AuraEnabled
        public List<BusAreawrapper> getSoldAmount {get;set;}
        @AuraEnabled
        public List<BusAreawrapper> ForecastNetProceeds {get;set;}
        @AuraEnabled
        public List<Decimal> soldCalculation {get;set;}
        @AuraEnabled
        public List<Decimal> netProceedCalculation {get;set;}
        @AuraEnabled
        public List<Decimal> drawingSoldCalculation {get;set;}
        @AuraEnabled
        public List<Decimal> drawingnetProceedCalculation {get;set;}
    }
    
    public static List<BusAreawrapper> getBusAreawrapper(Map<String, Map<Date,Decimal>> busAreaVsForecastMap, Map<String, Decimal> busAreaVsActualMap, Map<String, Decimal> busAreaVsRollingFCurrentYr, Map<String, Decimal> YearlySalesPlanning){
        List<BusAreawrapper> bussArea = new List<BusAreawrapper>();
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.year();
        for (String bussAreaKey : busAreaVsForecastMap.keySet()) {
            List<Decimal> decListMonths = new Decimal[13];
            Integer monthNumber=0;
            Map<Date, Decimal> innerMap = busAreaVsForecastMap.get(bussAreaKey);
            if(innerMap != null){
            for(Date dateloop : innerMap.keySet()){
                while(dateloop.month() != currentMonth){
                    if(currentMonth != 12){
                        decListMonths.add(monthNumber, null);
                        currentMonth++;
                        monthNumber++;
                    }
                    else{
                        decListMonths.add(monthNumber, null);
                        currentMonth = 1;
                        currentYear++;
                        monthNumber++;
                    }
                }
                
                if (dateloop.year() == currentYear && dateloop.month() == currentMonth) {
                    decListMonths.add(monthNumber, innerMap.get(dateloop));
                    if(currentMonth!=12){
                        currentMonth++;
                    }
                    else{
                        currentMonth = 1;
                        currentYear++;
                    }
                    monthNumber++;
                }else if(dateloop.year() != currentYear && dateloop.month() == currentMonth){
                    decListMonths.add(12, innerMap.get(dateloop));
                }
            }}
            currentDate = Date.today();
            currentMonth = currentDate.month();
            currentYear = currentDate.year();
            //US-3586 - Start
            Decimal year1 = YearlySalesPlanning != null ? YearlySalesPlanning.ContainsKey('yearlySoldAmount'+bussAreaKey) ? YearlySalesPlanning.get('yearlySoldAmount'+bussAreaKey) : 0 : 0;  
            Decimal year2 = YearlySalesPlanning != null ? YearlySalesPlanning.ContainsKey('yearly1SoldAmount'+bussAreaKey) ? YearlySalesPlanning.get('yearly1SoldAmount'+bussAreaKey) : 0 : 0;  
            Decimal year3 = YearlySalesPlanning != null ? YearlySalesPlanning.ContainsKey('yearly2SoldAmount'+bussAreaKey) ? YearlySalesPlanning.get('yearly2SoldAmount'+bussAreaKey) : 0 : 0;  
            //US-3586 - End
            bussArea.add(new BusAreawrapper(bussAreaKey, busAreaVsActualMap != null ? busAreaVsActualMap.ContainsKey(bussAreaKey) ? busAreaVsActualMap.get(bussAreaKey) : null : null, 
                                            decListMonths[0] != null ? Math.Round(decListMonths[0]) : null, decListMonths[1] != null ? Math.Round(decListMonths[1]) : null, decListMonths[2] != null ? Math.Round(decListMonths[2]) : null,
                                            decListMonths[3] != null ? Math.Round(decListMonths[3]) : null, decListMonths[4] != null ? Math.Round(decListMonths[4]) : null, decListMonths[5] != null ? Math.Round(decListMonths[5]) : null, 
                                            decListMonths[6] != null ? Math.Round(decListMonths[6]) : null, decListMonths[7] != null ? Math.Round(decListMonths[7]) : null, decListMonths[8] != null ? Math.Round(decListMonths[8]) : null, 
                                            decListMonths[9] != null ? Math.Round(decListMonths[9]) : null, decListMonths[10] != null ? Math.Round(decListMonths[10]) : null, decListMonths[11] != null ?Math.Round(decListMonths[11]) : null, decListMonths[12] != null ? Math.Round(decListMonths[12]) : null,
                                            busAreaVsRollingFCurrentYr != null ? busAreaVsRollingFCurrentYr.ContainsKey(bussAreaKey) ? busAreaVsRollingFCurrentYr.get(bussAreaKey) : null : null, Math.Round(year1), Math.Round(year2), Math.Round(year3)) );   //US-3586 - year Changes added
        }
        
        return bussArea;
    }
    
    public static Map<String, Decimal> soldCalculation(List<BusAreawrapper> bsWrap){
        List<Decimal> actualSoldAmount = new List<Decimal>(); //4112
        List<Decimal> currentFSoldAmount= new List<Decimal>();
        List<Decimal> current1FSoldAmount= new List<Decimal>();     
        List<Decimal> current2FSoldAmount = new List<Decimal>(); 
        List<Decimal> current3FSoldAmount = new List<Decimal>(); 
        List<Decimal> current4FSoldAmount = new List<Decimal>();
        List<Decimal> current5FSoldAmount = new List<Decimal>();
        List<Decimal> current6FSoldAmount = new List<Decimal>();
        List<Decimal> current7FSoldAmount = new List<Decimal>();
        List<Decimal> current8FSoldAmount = new List<Decimal>();
        List<Decimal> current9FSoldAmount = new List<Decimal>();
        List<Decimal> current10FSoldAmount= new List<Decimal>();
        List<Decimal> current11FSoldAmount = new List<Decimal>();
        List<Decimal> current12FSoldAmount = new List<Decimal>();
        List<Decimal> rollingForecastCurrentYear = new List<Decimal>();
        List<Decimal> yearlySoldAmount = new List<Decimal>();
        List<Decimal> yearly1SoldAmount = new List<Decimal>();
        List<Decimal> yearly2SoldAmount = new List<Decimal>();
        Map<String, Decimal> MapOfAllSoldAmount = new Map<String, Decimal>();
        for(BusAreawrapper bw : bsWrap){
            actualSoldAmount.add(bw.ActualSoldAmount); //4112
            currentFSoldAmount.add(bw.currentFSoldAmount);
            current1FSoldAmount.add(bw.current1FSoldAmount);
            current2FSoldAmount.add(bw.current2FSoldAmount);
            current3FSoldAmount.add(bw.current3FSoldAmount);
            current4FSoldAmount.add(bw.current4FSoldAmount);
            current5FSoldAmount.add(bw.current5FSoldAmount);
            current6FSoldAmount.add(bw.current6FSoldAmount);
            current7FSoldAmount.add(bw.current7FSoldAmount);
            current8FSoldAmount.add(bw.current8FSoldAmount);
            current9FSoldAmount.add(bw.current9FSoldAmount);
            current10FSoldAmount.add(bw.current10FSoldAmount);
            current11FSoldAmount.add(bw.current11FSoldAmount);
            current12FSoldAmount.add(bw.current12FSoldAmount);
            rollingForecastCurrentYear.add(bw.rollingForecastCurrentYear);
            yearlySoldAmount.add(bw.yearlySoldAmount);
            yearly1SoldAmount.add(bw.yearly1SoldAmount);
            yearly2SoldAmount.add(bw.yearly2SoldAmount);
        }
        MapOfAllSoldAmount.put('actualSoldAmount', sumAmount(actualSoldAmount)); //4112
        MapOfAllSoldAmount.put('currentFSoldAmount', sumAmount(currentFSoldAmount));
        MapOfAllSoldAmount.put('current1FSoldAmount', sumAmount(current1FSoldAmount));
        MapOfAllSoldAmount.put('current2FSoldAmount', sumAmount(current2FSoldAmount));
        MapOfAllSoldAmount.put('current3FSoldAmount', sumAmount(current3FSoldAmount));
        MapOfAllSoldAmount.put('current4FSoldAmount', sumAmount(current4FSoldAmount));
        MapOfAllSoldAmount.put('current5FSoldAmount', sumAmount( current5FSoldAmount));
        MapOfAllSoldAmount.put('current6FSoldAmount', sumAmount(current6FSoldAmount));
        MapOfAllSoldAmount.put('current7FSoldAmount', sumAmount(current7FSoldAmount));
        MapOfAllSoldAmount.put('current8FSoldAmount', sumAmount(current8FSoldAmount));
        MapOfAllSoldAmount.put('current9FSoldAmount', sumAmount(current9FSoldAmount));
        MapOfAllSoldAmount.put('current10FSoldAmount', sumAmount(current10FSoldAmount));
        MapOfAllSoldAmount.put('current11FSoldAmount', sumAmount(current11FSoldAmount));
        MapOfAllSoldAmount.put('current12FSoldAmount', sumAmount(current12FSoldAmount));
        MapOfAllSoldAmount.put('rollingForecastCurrentYear', sumAmount(rollingForecastCurrentYear));
        MapOfAllSoldAmount.put('yearlySoldAmount', sumAmount(yearlySoldAmount));
        MapOfAllSoldAmount.put('yearly1SoldAmount', sumAmount(yearly1SoldAmount));
        MapOfAllSoldAmount.put('yearly2SoldAmount', sumAmount(yearly2SoldAmount));
        return MapOfAllSoldAmount;
    }
    public static Decimal sumAmount(List<Decimal> listOfDecimal){
        Decimal totalReceived = 0;
        for(Decimal dc : listOfDecimal){
            if(dc != null)
                totalReceived = Math.Round(totalReceived + dc);
        }
        return totalReceived;
    }
    
    public static List<BusAreawrapper> getDrawingPicklist(List<BusAreawrapper> bsWrap){
        List<String> pickListValuesList= new List<String>();
        List<BusAreawrapper> bsWrapList = new List<BusAreawrapper>();
        Map<String, String> pickListValuesMap = getBussineAreaPickist();
        for( String pickListVal : pickListValuesMap.keyset() ){
            if(pickListVal.contains(System.label.DrawingGradeLabel)){ //3911
                pickListValuesList.add(pickListVal);
            }
        }
        for(BusAreawrapper bsWrapper : bsWrap){
            if(pickListValuesList.contains(bsWrapper.BusinessArea)){
                bsWrapList.add(bsWrapper);
            }
        }
        return bsWrapList;
    }

    public static Map<String, String> getBussineAreaPickist(){
        Map<String, String> pickListValuesMap = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = SalesPlanning__c.BusinessArea__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesMap.put(pickListVal.getLabel(), pickListVal.getValue());
        }
        return pickListValuesMap;
    }
    
    @AuraEnabled
    public static Boolean getMarketingUsers()
    {
        String profilename = [SELECT ID, Name, Title, Profile.Name From User WHERE ID = :UserInfo.getUserId() LIMIT 1].Profile.Name;
        return (profilename == ConstantClass.SAG_MARKETING_PROFILE || profilename == System.label.SystemAdministratorProfile) ? true : false;
    }
    
    @AuraEnabled
    public static void updateSalesPlanningLog(String logDetails){
        SalesPlanningLog__c spLog =  [SELECT Id, Name, LastSavedOn__c, LastSubmittedOn__c, LastRolledUpOn__c, LastRolledUpAnnualPlanning__c, ForecastLevel__c FROM SalesPlanningLog__c WHERE  ForecastLevel__c =:'Business Area/Product Group' LIMIT 1];
        if(spLog != null){
            if(logDetails == 'LastSavedOn'){
                spLog.LastSavedOn__c = System.today();  
            }else if(logDetails == 'LastSubmittedOn'){
                spLog.LastSubmittedOn__c = System.today(); 
            }else if(logDetails == 'LastRolledUpOn'){
                spLog.LastRolledUpOn__c = System.today();
            }else if(logDetails == 'LastRollAccountPlan'){
                spLog.LastRolledUpAnnualPlanning__c = System.today();
            }
            
            update spLog;
        }
    }
    @AuraEnabled
    public static SalesPlanningLog__c getSalesPlanningLog(){
        try{
            SalesPlanningLog__c spLog =  [SELECT Id, Name, EditedBy__c, InEditMode__c , LastSavedOn__c, LastRolledUpAnnualPlanning__c, LastSubmittedOn__c, LastRolledUpOn__c, ForecastLevel__c FROM SalesPlanningLog__c WHERE ForecastLevel__c =:'Business Area/Product Group' LIMIT 1];
            return spLog;
        }catch(exception ex){
            SalesPlanningLog__c spLogNew = new SalesPlanningLog__c();
            spLogNew.ForecastLevel__c = 'Business Area/Product Group';
            insert spLogNew;
            return spLogNew;
        }
        
    }
    @AuraEnabled
    public static String updateSalesPlanningLogForEdit(Boolean IsEdit,Boolean editbutton){
        SalesPlanningLog__c spLog =  [SELECT Id, Name, LastModifiedById , InEditMode__c, EditedBy__c FROM SalesPlanningLog__c WHERE  ForecastLevel__c =:'Business Area/Product Group' LIMIT 1];
        if(editbutton && spLog.EditedBy__c==null && spLog.InEditMode__c==false){
            spLog.InEditMode__c = IsEdit;
            if(IsEdit==true)
                spLog.EditedBy__c = UserInfo.getUserId();
            else
                spLog.EditedBy__c = null;  
            
        }
        else if(editbutton== false){
            spLog.InEditMode__c = IsEdit;
            if(IsEdit==true)
                spLog.EditedBy__c = UserInfo.getUserId();
            else
                spLog.EditedBy__c = null;
        }
        update spLog;
        return spLog.EditedBy__c;
    }    
    @AuraEnabled
    public static String upsertSPForecaste(String newBussAreaSoldWrapper, String oldBussAreaSoldWrapper, String newBussAreaNetWrapper, String oldBussAreaNetWrapper){
        
        List<BusAreawrapper> wrapperSoldDataList = (List<BusAreawrapper>) JSON.deserialize(newBussAreaSoldWrapper, List<BusAreawrapper>.class);
        List<BusAreawrapper> oldWrapperSoldDataList = (List<BusAreawrapper>) JSON.deserialize(oldBussAreaSoldWrapper, List<BusAreawrapper>.class);
        List<BusAreawrapper> wrapperNetDataList = (List<BusAreawrapper>) JSON.deserialize(newBussAreaNetWrapper, List<BusAreawrapper>.class);
        List<BusAreawrapper> oldWrapperNetDataList = (List<BusAreawrapper>) JSON.deserialize(oldBussAreaNetWrapper, List<BusAreawrapper>.class);
        Map<String, Map<String, Decimal>> oldBussVsSoldAmount  = oldBussVsAmount(oldWrapperSoldDataList);
        Map<String, Map<String, Decimal>> oldBussVsNetAmount  = oldBussVsAmount(oldWrapperNetDataList);
        Map<String, SalesPlanning__c> recordInUpdate = new  Map<String, SalesPlanning__c>();
        Map<String, Map<String, SalesPlanning__c>> recordToCreate = new  Map<String, Map<String, SalesPlanning__c>>();
        List<SalesPlanning__c> salesPlanningList = new List<SalesPlanning__c>(); //4726
        Savepoint sp;
        try{
            sp = Database.setSavepoint();
            Map<String, String> pickListValuesMap = getBussineAreaPickist();
            Date currentDate = Date.today();
            Integer currentMonth = currentDate.month();
            Integer currentYear = currentDate.year();
            Map<String, SalesPlanning__c> dateVsSalesPlann = new Map<String, SalesPlanning__c>();
            for(SalesPlanning__c ss : [SELECT Id, Account__c, toLabel(BusinessArea__c), ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                       FROM SalesPlanning__c WHERE ForecastLevel__c ='Business Area/Product Group' AND Account__c = null AND Frequency__c ='Monthly' AND //4250
                                       ForecastTimePoint__c > LAST_MONTH  AND ForecastTimePoint__c <= NEXT_N_MONTHS:12 ORDER By ForecastTimePoint__c ASC]){
                                           Integer monthss = ss.ForecastTimePoint__c.month();
                                           Integer yearss = ss.ForecastTimePoint__c.year();
                                           Integer monInt = 0;
                                           if(yearss == currentYear){
                                               monInt = monthss - currentMonth;
                                           }
                                           else if(yearss > currentYear){
                                               monInt = 12-currentMonth +monthss;
                                           }
                                           dateVsSalesPlann.put('current'+monInt+'FSoldAmount'+ss.BusinessArea__c,ss);
                                       }
            Map<String, Date> CurrentYearVsDate = getDateAccCurrMonth(); 
            UpdateTableResponse newMapBAVsSOLDAmount = compareNewOldSoldRecord(oldBussVsSoldAmount, wrapperSoldDataList, pickListValuesMap, dateVsSalesPlann, CurrentYearVsDate);
            recordInUpdate = newMapBAVsSOLDAmount.wrapperMapToUpdate;
            recordToCreate = newMapBAVsSOLDAmount.wrapperMapToCreate; 
            UpdateTableResponse newMapBAVsNETAmount = compareNewOldNetRecord(recordToCreate, recordInUpdate, oldBussVsNetAmount, wrapperNetDataList, pickListValuesMap, dateVsSalesPlann, CurrentYearVsDate);
            recordInUpdate = newMapBAVsNETAmount.wrapperMapToUpdate;
            recordToCreate = newMapBAVsNETAmount.wrapperMapToCreate; 
            
            //US-3586 - Start
            Map<String, SalesPlanning__c> yearlySPRecord = updateYearlySP(wrapperSoldDataList, wrapperNetDataList, pickListValuesMap);
            if(yearlySPRecord != null && !yearlySPRecord.isEmpty()){
                recordInUpdate.putAll(yearlySPRecord);
            }
            //US-3586 End
            //US-4726 Start
            if(recordToCreate != null && !recordToCreate.isEmpty()){
                for (Map<String, SalesPlanning__c> innerMap : recordToCreate.values()) {
                    salesPlanningList.addAll(innerMap.values());
                }
            }
            
            if(salesPlanningList != null && !salesPlanningList.isEmpty()){
                insert salesPlanningList;
            }
            //US-4726 end
            //if(recordInUpdate != null && !recordInUpdate.isEmpty()){
              if(recordInUpdate.keySet()!=null){
                update recordInUpdate.values();
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
    
    public static Map<String, Map<String, Decimal>> oldBussVsAmount(List<BusAreawrapper> oldWrapperSoldDataList){
        Map<String, Map<String, Decimal>> oldBussVsForecastAmount  = new Map<String, Map<String, Decimal>>();
        for(BusAreawrapper salesPlanloop : oldWrapperSoldDataList){
            if (!oldBussVsForecastAmount.containsKey(salesPlanloop.BusinessArea)) {
                oldBussVsForecastAmount.put(salesPlanloop.BusinessArea, new Map<String, Decimal>());
            }
            Map<String, Decimal> innerMap = oldBussVsForecastAmount.get(salesPlanloop.BusinessArea);
            innerMap.put('current1FSoldAmount', salesPlanloop.current1FSoldAmount);
            innerMap.put('current2FSoldAmount', salesPlanloop.current2FSoldAmount);
            innerMap.put('current3FSoldAmount', salesPlanloop.current3FSoldAmount);
            innerMap.put('current4FSoldAmount', salesPlanloop.current4FSoldAmount);
            innerMap.put('current5FSoldAmount', salesPlanloop.current5FSoldAmount);
            innerMap.put('current6FSoldAmount', salesPlanloop.current6FSoldAmount);
            innerMap.put('current7FSoldAmount', salesPlanloop.current7FSoldAmount);
            innerMap.put('current8FSoldAmount', salesPlanloop.current8FSoldAmount);
            innerMap.put('current9FSoldAmount', salesPlanloop.current9FSoldAmount);
            innerMap.put('current10FSoldAmount', salesPlanloop.current10FSoldAmount);
            innerMap.put('current11FSoldAmount', salesPlanloop.current11FSoldAmount);
            innerMap.put('current12FSoldAmount', salesPlanloop.current12FSoldAmount);
        }
        
        return oldBussVsForecastAmount;
    }
    
    public static Map<String, Date> getDateAccCurrMonth(){
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.year();
        
        Map<String, Date> CurrentVsDate = new Map<String, Date>(); 
        for(Integer i= 1 ; i <= 12 ;i++){
            Integer calYear = 0;
            Integer calMonth = 0;
            if(currentMonth + i > 12){
                calYear = currentYear + 1;
                calMonth = currentMonth + i - 12;
            }else{
                calMonth = currentMonth + i;
                calYear = currentYear;
            }
            Date fTp = Date.newInstance(calYear, calMonth, 1);
            CurrentVsDate.put('current'+i+'FSoldAmount', fTp);
        }
        return CurrentVsDate;
    }
    
    public static UpdateTableResponse compareNewOldSoldRecord(Map<String, Map<String, Decimal>> oldBussVsSoldAmount, List<BusAreawrapper> wrapperSoldDataList, Map<String, String> pickListValuesMap, Map<String, SalesPlanning__c> dateVsSalesPlann, Map<String, Date> CurrentYearVsDate){
        Map<String,Map<String, SalesPlanning__c>> salesPlanMapToCreate = new Map<String,Map<String, SalesPlanning__c>>();
        Map<String, SalesPlanning__c> salesPlanMapToUpdate = new Map<String, SalesPlanning__c>();
        Map<String, Map<String, SalesPlanning__c>> mapToListInsert = new Map<String, Map<String, SalesPlanning__c>>();
        Map<String, SalesPlanning__c> mapToUpdate = new Map<String, SalesPlanning__c>();
        
        SalesPlanning__c salesPlanUpdate = new SalesPlanning__c();
        for(BusAreawrapper newLoop : wrapperSoldDataList){
            if(oldBussVsSoldAmount.containsKey(newLoop.BusinessArea)){
                Map<String, Decimal> innerMap = oldBussVsSoldAmount.get(newLoop.BusinessArea);
                if(newLoop.current1FSoldAmount != null && innerMap.get('current1FSoldAmount') != newLoop.current1FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current1FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current1FSoldAmount'+newLoop.BusinessArea);
                        salesPlanUpdate.ForecastSoldAmount__c = newLoop.current1FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanMapToUpdate.put(salesPlanUpdate.Id,salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        Date fTp = CurrentYearVsDate.containsKey('current1FSoldAmount') ? CurrentYearVsDate.get('current1FSoldAmount') : null;
                        salesPlanMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current1FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current1FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));//4250
                    }
                }
                if(newLoop.current2FSoldAmount != null && innerMap.get('current2FSoldAmount') != newLoop.current2FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current2FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current2FSoldAmount'+newLoop.BusinessArea);
                        salesPlanUpdate.ForecastSoldAmount__c = newLoop.current2FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanMapToUpdate.put(salesPlanUpdate.Id,salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        Date fTp = CurrentYearVsDate.containsKey('current2FSoldAmount') ? CurrentYearVsDate.get('current2FSoldAmount') : null;
                        salesPlanMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current2FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current2FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                    }
                }
                if(newLoop.current3FSoldAmount != null && innerMap.get('current3FSoldAmount') != newLoop.current3FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current3FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current3FSoldAmount'+newLoop.BusinessArea);
                        salesPlanUpdate.ForecastSoldAmount__c = newLoop.current3FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanMapToUpdate.put(salesPlanUpdate.Id,salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        Date fTp = CurrentYearVsDate.containsKey('current3FSoldAmount') ? CurrentYearVsDate.get('current3FSoldAmount') : null;
                        salesPlanMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current3FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current3FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                    }
                }
                if(newLoop.current4FSoldAmount != null && innerMap.get('current4FSoldAmount') != newLoop.current4FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current4FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current4FSoldAmount'+newLoop.BusinessArea);
                        salesPlanUpdate.ForecastSoldAmount__c = newLoop.current4FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanMapToUpdate.put(salesPlanUpdate.Id,salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        Date fTp = CurrentYearVsDate.containsKey('current4FSoldAmount') ? CurrentYearVsDate.get('current4FSoldAmount') : null;
                        salesPlanMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current4FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current4FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                    }
                }
                if(newLoop.current5FSoldAmount != null && innerMap.get('current5FSoldAmount') != newLoop.current5FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current5FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current5FSoldAmount'+newLoop.BusinessArea);
                        salesPlanUpdate.ForecastSoldAmount__c = newLoop.current5FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanMapToUpdate.put(salesPlanUpdate.Id,salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        Date fTp = CurrentYearVsDate.containsKey('current5FSoldAmount') ? CurrentYearVsDate.get('current5FSoldAmount') : null;
                        salesPlanMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current5FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current5FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                    }
                }
                if(newLoop.current6FSoldAmount != null && innerMap.get('current6FSoldAmount') != newLoop.current6FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current6FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current6FSoldAmount'+newLoop.BusinessArea);
                        salesPlanUpdate.ForecastSoldAmount__c = newLoop.current6FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanMapToUpdate.put(salesPlanUpdate.Id,salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        Date fTp = CurrentYearVsDate.containsKey('current6FSoldAmount') ? CurrentYearVsDate.get('current6FSoldAmount') : null;
                        salesPlanMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current6FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current6FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                    }
                }
                if(newLoop.current7FSoldAmount != null && innerMap.get('current7FSoldAmount') != newLoop.current7FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current7FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current7FSoldAmount'+newLoop.BusinessArea);
                        salesPlanUpdate.ForecastSoldAmount__c = newLoop.current7FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        Date fTp = CurrentYearVsDate.containsKey('current7FSoldAmount') ? CurrentYearVsDate.get('current7FSoldAmount') : null;
                        salesPlanMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current7FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current7FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                    }
                }
                if(newLoop.current8FSoldAmount != null && innerMap.get('current8FSoldAmount') != newLoop.current8FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current8FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current8FSoldAmount'+newLoop.BusinessArea);
                        salesPlanUpdate.ForecastSoldAmount__c = newLoop.current8FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        Date fTp = CurrentYearVsDate.containsKey('current8FSoldAmount') ? CurrentYearVsDate.get('current8FSoldAmount') : null;
                        salesPlanMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current8FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current8FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                    }
                }
                if(newLoop.current9FSoldAmount != null && innerMap.get('current9FSoldAmount') != newLoop.current9FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current9FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current9FSoldAmount'+newLoop.BusinessArea);
                        salesPlanUpdate.ForecastSoldAmount__c = newLoop.current9FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        Date fTp = CurrentYearVsDate.containsKey('current9FSoldAmount') ? CurrentYearVsDate.get('current9FSoldAmount') : null;
                        salesPlanMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current9FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current9FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                    }
                }
                if(newLoop.current10FSoldAmount != null && innerMap.get('current10FSoldAmount') != newLoop.current10FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current10FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current10FSoldAmount'+newLoop.BusinessArea);
                        salesPlanUpdate.ForecastSoldAmount__c = newLoop.current10FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        Date fTp = CurrentYearVsDate.containsKey('current10FSoldAmount') ? CurrentYearVsDate.get('current10FSoldAmount') : null;
                        salesPlanMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current10FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current10FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                    }
                }
                if(newLoop.current11FSoldAmount != null && innerMap.get('current11FSoldAmount') != newLoop.current11FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current11FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current11FSoldAmount'+newLoop.BusinessArea);
                        salesPlanUpdate.ForecastSoldAmount__c = newLoop.current11FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        Date fTp = CurrentYearVsDate.containsKey('current11FSoldAmount') ? CurrentYearVsDate.get('current11FSoldAmount') : null;
                        salesPlanMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current11FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current11FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                    }
                }
                if(newLoop.current12FSoldAmount != null && innerMap.get('current12FSoldAmount') != newLoop.current12FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current12FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current12FSoldAmount'+newLoop.BusinessArea);
                        salesPlanUpdate.ForecastSoldAmount__c = newLoop.current12FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        Date fTp = CurrentYearVsDate.containsKey('current12FSoldAmount' ) ? CurrentYearVsDate.get('current12FSoldAmount') : null;
                        salesPlanMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current12FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current12FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                    }
                }
            }
        }
        
        
        if(salesPlanMapToCreate != null && !salesPlanMapToCreate.isEmpty()){
            mapToListInsert.putAll(salesPlanMapToCreate);
        }
        if(salesPlanMapToUpdate != null && !salesPlanMapToUpdate.isEmpty()){
            mapToUpdate.putAll(salesPlanMapToUpdate); 
        }
        UpdateTableResponse updateWrapper = new UpdateTableResponse();
        updateWrapper.wrapperMapToUpdate = mapToUpdate;
        updateWrapper.wrapperMapToCreate = mapToListInsert;
        return updateWrapper;
    }
    
    public static UpdateTableResponse compareNewOldNetRecord(Map<String, Map<String, SalesPlanning__c>> recordInCreate, Map<String,SalesPlanning__c> recordInUpdate, Map<String, Map<String, Decimal>> oldBussVsSoldAmount, List<BusAreawrapper> wrapperSoldDataList, Map<String, String> pickListValuesMap, Map<String, SalesPlanning__c> dateVsSalesPlann, Map<String, Date> CurrentYearVsDate){
        Map<String, Map<String, SalesPlanning__c>> salesPlanListMapToCreate = new Map<String, Map<String, SalesPlanning__c>>();
        Map<String,SalesPlanning__c> salesPlanListMapToUpdate = new Map<String,SalesPlanning__c>();
        SalesPlanning__c salesPlanUpdate = new SalesPlanning__c();
        SalesPlanning__c salesPlanCreate = new SalesPlanning__c();
        Map<String, SalesPlanning__c> salesPlanCreateMap = new Map<String, SalesPlanning__c>();
        Map<String, Map<String, SalesPlanning__c>> mapToListInsert = new Map<String, Map<String, SalesPlanning__c>>();
        Map<String, SalesPlanning__c> mapToUpdate = new Map<String, SalesPlanning__c>();
        
        if(recordInCreate != null && !recordInCreate.isEmpty()){
            salesPlanListMapToCreate.putAll(recordInCreate); 
        }
        if(recordInUpdate != null && !recordInUpdate.isEmpty()){
            salesPlanListMapToUpdate.putAll(recordInUpdate); 
        }
        for(BusAreawrapper newLoop : wrapperSoldDataList){
            if(oldBussVsSoldAmount.containsKey(newLoop.BusinessArea)){
                Map<String, Decimal> innerMap = oldBussVsSoldAmount.get(newLoop.BusinessArea);
                
                if(newLoop.current1FSoldAmount != null && innerMap.get('current1FSoldAmount') != newLoop.current1FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current1FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current1FSoldAmount'+newLoop.BusinessArea);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id); 
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current1FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanListMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        if(recordInCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.BusinessArea);
                            salesPlanCreate = salesPlanCreateMap.get('current1FSoldAmount');
                            salesPlanCreate.ForecastNetProceeds__c = newLoop.current1FSoldAmount; 
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current1FSoldAmount', salesPlanCreate);
                        }
                        else{
                            Date fTp = CurrentYearVsDate.containsKey('current1FSoldAmount') ? CurrentYearVsDate.get('current1FSoldAmount') : null;
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current1FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current1FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                        }
                    }
                }
                if(newLoop.current2FSoldAmount != null && innerMap.get('current2FSoldAmount') != newLoop.current2FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current2FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current2FSoldAmount'+newLoop.BusinessArea);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current2FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanListMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        if(recordInCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.BusinessArea);
                            salesPlanCreate = salesPlanCreateMap.get('current2FSoldAmount');
                            salesPlanCreate.ForecastNetProceeds__c = newLoop.current2FSoldAmount; 
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current2FSoldAmount', salesPlanCreate);
                        }
                        else{
                            Date fTp = CurrentYearVsDate.containsKey('current2FSoldAmount') ? CurrentYearVsDate.get('current2FSoldAmount') : null;
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current2FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current2FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                        }
                    }
                }
                if(newLoop.current3FSoldAmount != null && innerMap.get('current3FSoldAmount') != newLoop.current3FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current3FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current3FSoldAmount'+newLoop.BusinessArea);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current3FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanListMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        if(recordInCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.BusinessArea);
                            salesPlanCreate = salesPlanCreateMap.get('current3FSoldAmount');
                            salesPlanCreate.ForecastNetProceeds__c = newLoop.current3FSoldAmount; 
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current3FSoldAmount', salesPlanCreate);
                        }
                        else{
                            Date fTp = CurrentYearVsDate.containsKey('current3FSoldAmount') ? CurrentYearVsDate.get('current3FSoldAmount') : null;
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current3FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current3FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                        }
                    }
                }
                if(newLoop.current4FSoldAmount != null && innerMap.get('current4FSoldAmount') != newLoop.current4FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current4FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current4FSoldAmount'+newLoop.BusinessArea);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current4FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanListMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        if(recordInCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.BusinessArea);
                            salesPlanCreate = salesPlanCreateMap.get('current4FSoldAmount');
                            salesPlanCreate.ForecastNetProceeds__c = newLoop.current4FSoldAmount; 
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current4FSoldAmount', salesPlanCreate);
                        }
                        else{
                            Date fTp = CurrentYearVsDate.containsKey('current4FSoldAmount') ? CurrentYearVsDate.get('current4FSoldAmount') : null;
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current4FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current4FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                        }
                    }
                }
                if(newLoop.current5FSoldAmount != null && innerMap.get('current5FSoldAmount') != newLoop.current5FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current5FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current5FSoldAmount'+newLoop.BusinessArea);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current5FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanListMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        if(recordInCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.BusinessArea);
                            salesPlanCreate = salesPlanCreateMap.get('current5FSoldAmount');
                            salesPlanCreate.ForecastNetProceeds__c = newLoop.current5FSoldAmount; 
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current5FSoldAmount', salesPlanCreate);
                        }
                        else{
                            Date fTp = CurrentYearVsDate.containsKey('current5FSoldAmount') ? CurrentYearVsDate.get('current5FSoldAmount') : null;
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current5FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current5FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                        }
                    }
                }
                if(newLoop.current6FSoldAmount != null && innerMap.get('current6FSoldAmount') != newLoop.current6FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current6FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current6FSoldAmount'+newLoop.BusinessArea);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current6FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanListMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        if(recordInCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.BusinessArea);
                            salesPlanCreate = salesPlanCreateMap.get('current6FSoldAmount');
                            salesPlanCreate.ForecastNetProceeds__c = newLoop.current6FSoldAmount; 
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current6FSoldAmount', salesPlanCreate);
                        }
                        else{
                            Date fTp = CurrentYearVsDate.containsKey('current6FSoldAmount') ? CurrentYearVsDate.get('current6FSoldAmount') : null;
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current6FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current6FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                        }
                    }
                }
                if(newLoop.current7FSoldAmount != null && innerMap.get('current7FSoldAmount') != newLoop.current7FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current7FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current7FSoldAmount'+newLoop.BusinessArea);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current7FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanListMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        if(recordInCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.BusinessArea);
                            salesPlanCreate = salesPlanCreateMap.get('current7FSoldAmount');
                            salesPlanCreate.ForecastNetProceeds__c = newLoop.current7FSoldAmount; 
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current7FSoldAmount', salesPlanCreate);
                        }
                        else{
                            Date fTp = CurrentYearVsDate.containsKey('current7FSoldAmount') ? CurrentYearVsDate.get('current7FSoldAmount') : null;
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current7FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current7FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                        }
                    }
                }
                if(newLoop.current8FSoldAmount != null && innerMap.get('current8FSoldAmount') != newLoop.current8FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current8FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current8FSoldAmount'+newLoop.BusinessArea);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current8FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanListMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        if(recordInCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.BusinessArea);
                            salesPlanCreate = salesPlanCreateMap.get('current8FSoldAmount');
                            salesPlanCreate.ForecastNetProceeds__c = newLoop.current8FSoldAmount; 
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current8FSoldAmount', salesPlanCreate);
                        }
                        else{
                            Date fTp = CurrentYearVsDate.containsKey('current8FSoldAmount') ? CurrentYearVsDate.get('current8FSoldAmount') : null;
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current8FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current8FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                        }                    
                    }
                }
                if(newLoop.current9FSoldAmount != null && innerMap.get('current9FSoldAmount') != newLoop.current9FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current9FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current9FSoldAmount'+newLoop.BusinessArea);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current9FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanListMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        if(recordInCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.BusinessArea);
                            salesPlanCreate = salesPlanCreateMap.get('current9FSoldAmount');
                            salesPlanCreate.ForecastNetProceeds__c = newLoop.current9FSoldAmount; 
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current9FSoldAmount', salesPlanCreate);
                        }
                        else{
                            Date fTp = CurrentYearVsDate.containsKey('current9FSoldAmount') ? CurrentYearVsDate.get('current9FSoldAmount') : null;
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current9FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current9FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                        }
                    }
                }
                if(newLoop.current10FSoldAmount != null && innerMap.get('current10FSoldAmount') != newLoop.current10FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current10FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current10FSoldAmount'+newLoop.BusinessArea);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current10FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanListMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        if(recordInCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.BusinessArea);
                            salesPlanCreate = salesPlanCreateMap.get('current10FSoldAmount');
                            salesPlanCreate.ForecastNetProceeds__c = newLoop.current10FSoldAmount; 
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current10FSoldAmount', salesPlanCreate);
                        }
                        else{
                            Date fTp = CurrentYearVsDate.containsKey('current10FSoldAmount') ? CurrentYearVsDate.get('current10FSoldAmount') : null;
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current10FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current10FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                        }
                    }
                }
                if(newLoop.current11FSoldAmount != null && innerMap.get('current11FSoldAmount') != newLoop.current11FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current11FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current11FSoldAmount'+newLoop.BusinessArea);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current11FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanListMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        if(recordInCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.BusinessArea);
                            salesPlanCreate = salesPlanCreateMap.get('current11FSoldAmount');
                            salesPlanCreate.ForecastNetProceeds__c = newLoop.current11FSoldAmount; 
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current11FSoldAmount', salesPlanCreate);
                        }
                        else{
                            Date fTp = CurrentYearVsDate.containsKey('current11FSoldAmount') ? CurrentYearVsDate.get('current11FSoldAmount') : null;
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current11FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current11FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                        }
                    }
                }
                if(newLoop.current12FSoldAmount != null && innerMap.get('current12FSoldAmount') != newLoop.current12FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current12FSoldAmount'+newLoop.BusinessArea)){
                        salesPlanUpdate = dateVsSalesPlann.get('current12FSoldAmount'+newLoop.BusinessArea);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current12FSoldAmount;
                        salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanListMapToCreate.put(System.Today()+newLoop.BusinessArea, new Map<String, SalesPlanning__c>());
                        }
                        if(recordInCreate.containsKey(System.Today()+newLoop.BusinessArea)){
                            salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.BusinessArea);
                            salesPlanCreate = salesPlanCreateMap.get('current12FSoldAmount');
                            salesPlanCreate.ForecastNetProceeds__c = newLoop.current12FSoldAmount; 
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current12FSoldAmount', salesPlanCreate);
                        }
                        else{
                            Date fTp = CurrentYearVsDate.containsKey('current12FSoldAmount') ? CurrentYearVsDate.get('current12FSoldAmount') : null;
                            salesPlanListMapToCreate.get(System.Today()+newLoop.BusinessArea).put('current12FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current12FSoldAmount, ForecastTimePoint__c = fTp, BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea), ForecastLevel__c = 'Business Area/Product Group',Frequency__c ='Monthly'));
                        }
                    }
                }
            }
        }
        
        if(salesPlanListMapToCreate != null && !salesPlanListMapToCreate.isEmpty()){
            mapToListInsert.putAll(salesPlanListMapToCreate);
        }
        if(salesPlanListMapToUpdate != null && !salesPlanListMapToUpdate.isEmpty()){
            mapToUpdate.putAll(salesPlanListMapToUpdate); 
        }
        UpdateTableResponse updateWrapper = new UpdateTableResponse();
        updateWrapper.wrapperMapToUpdate = mapToUpdate;
        updateWrapper.wrapperMapToCreate = mapToListInsert;
        return updateWrapper;
    }  
    public class UpdateTableResponse {
        @AuraEnabled
        public Map<String, SalesPlanning__c> wrapperMapToUpdate {get;set;}
        @AuraEnabled
        public Map<String, Map<String, SalesPlanning__c>>  wrapperMapToCreate {get;set;}
    }
    @AuraEnabled
    public static String uploadFile(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        cv.FirstPublishLocationId=[Select id from SalesPlanningLog__c where ForecastLevel__c ='Business Area/Product Group' Limit 1].id; //3911
        try {
            insert cv;
            return 'Success';
        } catch(DMLException e) {
            return null;
        }
    }
    
    /* 
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description 
* Gunjan Saxena     29/03/2023              US-2399 - Creation of method SubmitBAPlanning - This Method is called when Submit button is clicked from BusinessArea Sales Planning Lightning Page/businessPlanning Component.  
* Gunjan Saxena     28/04/2023              US-4004 - New Changes added as bug
* Gunjan Saxena     24/05/2023              US-4374 - Rollout to Account level functionality
* */
    
    @AuraEnabled
    public static void SubmitBAPlanning(){
        RollouttoAccountlevelBatch b = new RollouttoAccountlevelBatch(); 
        Database.executeBatch(b);
    }
    
    //US-3586 - Start
    public static Map<String, SalesPlanning__c> updateYearlySP(List<BusAreawrapper> wrapperSoldDataList, List<BusAreawrapper> wrapperNetDataList, Map<String, String> pickListValuesMap){
        Map<String, SalesPlanning__c> dateVsSalesPlann = new Map<String, SalesPlanning__c>();
        Map<String, SalesPlanning__c> salesPlanMapToUpdate = new Map<String, SalesPlanning__c>();
        SalesPlanning__c salesPlanUpdate = new SalesPlanning__c();
        Date currentDate = Date.today();
        Integer currentYear = currentDate.year();
        List<SalesPlanning__c> salesPlanningNextYear = [SELECT Id, Name, tolabel(BusinessArea__c), ForecastTimePoint__c, ForecastLevel__c, ForecastSoldAmount__c,
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
        for(BusAreawrapper newLoop : wrapperSoldDataList){
            if(dateVsSalesPlann.containsKey('yearlySoldAmount'+newLoop.BusinessArea)){
                salesPlanUpdate = dateVsSalesPlann.get('yearlySoldAmount'+newLoop.BusinessArea);
                if(newLoop.yearlySoldAmount != null && newLoop.yearlySoldAmount != salesPlanUpdate.ForecastSoldAmount__c){
                    salesPlanUpdate.ForecastSoldAmount__c = newLoop.yearlySoldAmount;
                    salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                    salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                }
            }
            if(dateVsSalesPlann.containsKey('yearly1SoldAmount'+newLoop.BusinessArea)){
                salesPlanUpdate = dateVsSalesPlann.get('yearly1SoldAmount'+newLoop.BusinessArea);
                if(newLoop.yearly1SoldAmount != null && newLoop.yearly1SoldAmount != salesPlanUpdate.ForecastSoldAmount__c){
                    salesPlanUpdate.ForecastSoldAmount__c = newLoop.yearly1SoldAmount;
                    salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                    salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                }
            }
            if(dateVsSalesPlann.containsKey('yearly2SoldAmount'+newLoop.BusinessArea)){
                salesPlanUpdate = dateVsSalesPlann.get('yearly2SoldAmount'+newLoop.BusinessArea);
                if(newLoop.yearly2SoldAmount != null && newLoop.yearly2SoldAmount != salesPlanUpdate.ForecastSoldAmount__c){
                    salesPlanUpdate.ForecastSoldAmount__c = newLoop.yearly2SoldAmount;
                    salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newLoop.BusinessArea);
                    salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                }
            }
        }        
        for(BusAreawrapper newNetLoop : wrapperNetDataList){
            if(dateVsSalesPlann.containsKey('yearlySoldAmount'+newNetLoop.BusinessArea)){
                salesPlanUpdate = dateVsSalesPlann.get('yearlySoldAmount'+newNetLoop.BusinessArea);
                if(newNetLoop.yearlySoldAmount != null && newNetLoop.yearlySoldAmount != salesPlanUpdate.ForecastNetProceeds__c){
                    if(salesPlanMapToUpdate.containsKey(salesPlanUpdate.Id))
                        salesPlanUpdate = salesPlanMapToUpdate.get(salesPlanUpdate.Id); 
                    salesPlanUpdate.ForecastNetProceeds__c = newNetLoop.yearlySoldAmount;
                    salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newNetLoop.BusinessArea);
                    salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                }
            }
            if(dateVsSalesPlann.containsKey('yearly1SoldAmount'+newNetLoop.BusinessArea)){
                salesPlanUpdate = dateVsSalesPlann.get('yearly1SoldAmount'+newNetLoop.BusinessArea);
                if(newNetLoop.yearly1SoldAmount != null && newNetLoop.yearly1SoldAmount != salesPlanUpdate.ForecastNetProceeds__c){
                    if(salesPlanMapToUpdate.containsKey(salesPlanUpdate.Id))
                        salesPlanUpdate = salesPlanMapToUpdate.get(salesPlanUpdate.Id); 
                    salesPlanUpdate.ForecastNetProceeds__c = newNetLoop.yearly1SoldAmount;
                    salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newNetLoop.BusinessArea);
                    salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                }
            }
            if(dateVsSalesPlann.containsKey('yearly2SoldAmount'+newNetLoop.BusinessArea)){
                salesPlanUpdate = dateVsSalesPlann.get('yearly2SoldAmount'+newNetLoop.BusinessArea);
                if(newNetLoop.yearly2SoldAmount != null && newNetLoop.yearly2SoldAmount != salesPlanUpdate.ForecastNetProceeds__c){
                    if(salesPlanMapToUpdate.containsKey(salesPlanUpdate.Id))
                        salesPlanUpdate = salesPlanMapToUpdate.get(salesPlanUpdate.Id); 
                    salesPlanUpdate.ForecastNetProceeds__c = newNetLoop.yearly2SoldAmount;
                    salesPlanUpdate.BusinessArea__c = pickListValuesMap.get(newNetLoop.BusinessArea);
                    salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                }
            }
        }
        return salesPlanMapToUpdate;
    }
    //US-3586 - end
}