/****************************************************************************
* Name: AccountSalesPlanningController
* Author: Harshitha U
* Created Date: 24/03/2023
* Description: Controller class of Account SalesForecasting LWC
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
* Gunjan Saxena     04-08-2023              US-6779 - part 2
****************************************************************************/
public with sharing class AccountSalesPlanningController {
    public static final String CONVARIABLE = '#@#';
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to get the Dynamic columns for the Account Sales Planning Table
* Created Date: 04/05/2023
* Last Modified Date: 04/05/2023
****************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<String> getAccountPlanningColumnNames() {
        List<String> columnNames = new List<String>();
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.year();
        String acc = 'Account';     
        columnNames.add(acc);
        columnNames.add('SAP Account Number');
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
        columnNames.add('');
        columnNames.add('Account');
        for(Integer i = 12; i >= 1; i--){
            String monthName = Datetime.newInstance(currentDate.addMonths(-i), Time.newInstance(0, 0, 0, 0)).format('MMM yy');
            columnNames.add(monthName);
        }
        return columnNames;
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Wrapper class to poulate each row on the Account Sales Planning table. 
* Created Date: 24/03/2023
* Last Modified Date: 24/03/2023
****************************************************************************/
    public class AccountSoldAmountawrapper {
        @AuraEnabled public String BusinessArea {get;set;}
        @AuraEnabled public String Account {get;set;}
        @AuraEnabled public String accountId {get;set;}
        @AuraEnabled public String sapAccNumber {get;set;}
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
        @AuraEnabled public ActualAccountWrapper actualWrapper {get; set;} //4216
        @AuraEnabled public Boolean isTotal {get;set;}
        @AuraEnabled public Boolean isAverage {get;set;}
        @AuraEnabled public Boolean isNetProceed {get;set;} //3911 for deltaNetProceed
        @AuraEnabled public Boolean deltaNetProceed {get;set;} //3911 //for blankline
        @AuraEnabled public Boolean blankline {get;set;} //3911 for NetProccedLabel
        @AuraEnabled public Boolean isSoldAmount {get;set;} //3911
        @AuraEnabled public Boolean isPerRow {get;set;} //6559
        public AccountSoldAmountawrapper(String BusinessArea ,String Account, String accountId, String sapAccNumber, Decimal ActualSoldAmount,
                                         Decimal currentFSoldAmount, Decimal current1FSoldAmount, Decimal current2FSoldAmount, Decimal current3FSoldAmount, Decimal current4FSoldAmount,
                                         Decimal current5FSoldAmount, Decimal current6FSoldAmount,Decimal current7FSoldAmount ,Decimal current8FSoldAmount,Decimal current9FSoldAmount,Decimal current10FSoldAmount,Decimal current11FSoldAmount, Decimal current12FSoldAmount,
                                         Decimal rollingForecastCurrentYear,Decimal yearlySoldAmount,Decimal yearly1SoldAmount,Decimal yearly2SoldAmount,
                                         ActualAccountWrapper actualWrapper, Boolean isTotal,Boolean isAverage, Boolean isNetProceed,Boolean deltaNetProceed,Boolean blankline, Boolean isSoldAmount, Boolean isPerRow){ //3911
                                             this.Account = Account;
                                             this.sapAccNumber = sapAccNumber;
                                             this.accountId = accountId;
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
                                             this.actualWrapper = actualWrapper; //4216
                                             this.isTotal = isTotal;
                                             this.isAverage = isAverage;
                                             this.isNetProceed = isNetProceed;//3911
                                             this.deltaNetProceed = deltaNetProceed;
                                             this.blankline = blankline;
                                             this.isSoldAmount = isSoldAmount; //4263
                                             this.isPerRow = isPerRow; //6559
                                         }
    }
    
    public class ActualAccountWrapper {
        @AuraEnabled public String accountLast {get;set;}
        @AuraEnabled public String accountActualId {get;set;}
        @AuraEnabled public Decimal actualSoldAmountL{get;set;}
        @AuraEnabled public Decimal actualSoldAmountL1 {get;set;} 
        @AuraEnabled public Decimal actualSoldAmountL2 {get;set;} 
        @AuraEnabled public Decimal actualSoldAmountL3 {get;set;}
        @AuraEnabled public Decimal actualSoldAmountL4 {get;set;}
        @AuraEnabled public Decimal actualSoldAmountL5 {get;set;}
        @AuraEnabled public Decimal actualSoldAmountL6 {get;set;}
        @AuraEnabled public Decimal actualSoldAmountL7 {get;set;}
        @AuraEnabled public Decimal actualSoldAmountL8 {get;set;}
        @AuraEnabled public Decimal actualSoldAmountL9{get;set;}
        @AuraEnabled public Decimal actualSoldAmountL10 {get;set;}
        @AuraEnabled public Decimal actualSoldAmountL11 {get;set;}
        //4216 End
        
        public ActualAccountWrapper(String accountLast, String accountActualId, Decimal actualSoldAmountL, Decimal actualSoldAmountL1, Decimal actualSoldAmountL2, Decimal actualSoldAmountL3, Decimal actualSoldAmountL4, Decimal actualSoldAmountL5,
                                    Decimal actualSoldAmountL6, Decimal actualSoldAmountL7, Decimal actualSoldAmountL8, Decimal actualSoldAmountL9, Decimal actualSoldAmountL10, Decimal actualSoldAmountL11) {
                                        this.accountLast = accountLast;
                                        this.accountActualId = accountActualId;
                                        this.actualSoldAmountL = actualSoldAmountL;
                                        this.actualSoldAmountL1 = actualSoldAmountL1;
                                        this.actualSoldAmountL2 = actualSoldAmountL2; 
                                        this.actualSoldAmountL3 = actualSoldAmountL3;
                                        this.actualSoldAmountL4 = actualSoldAmountL4;
                                        this.actualSoldAmountL5 = actualSoldAmountL5;
                                        this.actualSoldAmountL6 = actualSoldAmountL6;
                                        this.actualSoldAmountL7 = actualSoldAmountL7;
                                        this.actualSoldAmountL8 = actualSoldAmountL8;
                                        this.actualSoldAmountL9 = actualSoldAmountL9;
                                        this.actualSoldAmountL10 = actualSoldAmountL10;
                                        this.actualSoldAmountL11 = actualSoldAmountL11;
                                        //4216 end
                                    }
    }
    
    
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to populate the Actual table data for the Account Sales Planning Table.
* Created Date: 24/03/2023
* Last Modified Date: 24/03/2023
****************************************************************************/  
    @AuraEnabled   
    public static SoldNetActualWrapper showActualTableData(String businessArea){
        Map<String, Map<String,SalesPlanning__c>>  monthVsSalesPlan = new Map<String, Map<String, SalesPlanning__c>>();
        for(SalesPlanning__c salesPlanloop : [SELECT Id, Account__c, Account__r.Name, toLabel(BusinessArea__c), ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, Frequency__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                              FROM SalesPlanning__c WHERE ForecastLevel__c ='Account' AND BusinessArea__c =:businessArea AND ForecastTimePoint__c >= LAST_N_MONTHS:12 AND ForecastTimePoint__c < THIS_MONTH AND Frequency__c='Monthly' ORDER By ForecastTimePoint__c ASC]){
                                                  DateTime nextMonth = salesPlanloop.ForecastTimePoint__c;
                                                  String monthName = nextMonth.format('MMM yy');
                                                  if(salesPlanloop.Account__c!=null ){
                                                      if(!monthVsSalesPlan.containsKey(salesPlanloop.Account__c+CONVARIABLE+salesPlanloop.Account__r.Name)){
                                                          monthVsSalesPlan.put(salesPlanloop.Account__c+CONVARIABLE+salesPlanloop.Account__r.Name, new Map<String, SalesPlanning__c>()); 
                                                      }
                                                      Map<String, SalesPlanning__c> innerMap = monthVsSalesPlan.get(salesPlanloop.Account__c+CONVARIABLE+salesPlanloop.Account__r.Name);
                                                      innerMap.put(monthName+CONVARIABLE+salesPlanloop.Account__c, salesPlanloop);
                                                  }else if(salesPlanloop.Account__c == null){
                                                      if(!monthVsSalesPlan.containsKey('NPA'+CONVARIABLE+System.Label.SumofnotplannedAccounts)){
                                                          monthVsSalesPlan.put('NPA'+CONVARIABLE+System.Label.SumofnotplannedAccounts, new Map<String, SalesPlanning__c>()); 
                                                      }
                                                      Map<String, SalesPlanning__c> innerMap = monthVsSalesPlan.get('NPA'+CONVARIABLE+System.Label.SumofnotplannedAccounts);
                                                      innerMap.put(monthName+CONVARIABLE+'NPA', salesPlanloop);
                                                  }
                                              }
        SoldNetActualWrapper soldNetWrapper = getActualAccountwrapper(businessArea, monthVsSalesPlan);
        return soldNetWrapper;
    }  
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to calculate and populate the monthly Forecast and Actual Values.
* Created Date: 24/03/2023
* Last Modified Date: 24/03/2023
****************************************************************************/
    @AuraEnabled(cacheable=true)
    public static SoldNetActualWrapper getActualAccountwrapper(String businessArea, Map<String, Map<String,SalesPlanning__c>> monthVsSalesPlan){
        List<ActualAccountWrapper> accountwrapperSold = new List<ActualAccountWrapper>();
        List<ActualAccountWrapper> accountwrapperNet = new List<ActualAccountWrapper>();
        //4263
        accountwrapperSold.add(new ActualAccountWrapper(null,null,null, null, 
                                                        null, null, null,null, null, 
                                                        null, null, null, null, null));
        accountwrapperSold.add(new ActualAccountWrapper(null,null,null, null, 
                                                        null, null, null,null, null, 
                                                        null, null, null, null, null));
        
        ActualAccountWrapper accWrapperLastRowSold = new ActualAccountWrapper(System.Label.SumofnotplannedAccounts, System.Label.SumofnotplannedAccounts,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0); //3911
        
        ActualAccountWrapper accWrapperLastRowNet = new ActualAccountWrapper(System.Label.AverageofnotplannedAccounts, System.Label.AverageofnotplannedAccounts,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0); //3911
        
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.year()-1;
        for (String accdata : monthVsSalesPlan.keySet()) {
            String[] accountKey = accdata.split(CONVARIABLE);
            List<Decimal> decListMonths = new Decimal[13];
            List<Decimal> netListMonths = new Decimal[13];
            Integer monthNumber=0;
            Map<String, SalesPlanning__c> innerMap = monthVsSalesPlan.get(accdata);
            for(SalesPlanning__c dateloop : innerMap.values()){
                while(dateloop.ForecastTimePoint__c.month() != currentMonth){
                    if(currentMonth != 12){
                        decListMonths.add(monthNumber, null);
                        netListMonths.add(monthNumber, null);
                        currentMonth++;
                        monthNumber++;
                    }
                    else{
                        decListMonths.add(monthNumber, null);
                        netListMonths.add(monthNumber, null);
                        currentMonth = 1;
                        currentYear++;
                        monthNumber++;
                    }
                }
                
                if (dateloop.ForecastTimePoint__c.year() == currentYear && dateloop.ForecastTimePoint__c.month() == currentMonth) {
                    decListMonths.add(monthNumber, dateloop.ActualSoldAmount__c);
                    netListMonths.add(monthNumber, dateloop.ActualNetProceeds__c);
                    if(currentMonth!=12){
                        currentMonth++;
                    }
                    else{
                        currentMonth = 1;
                        currentYear++;
                    }
                    monthNumber++;
                }
            }
            currentDate = Date.today();
            currentMonth = currentDate.month();
            currentYear = currentDate.year()-1;
            if(accountKey[0]!='NPA'){
                accountwrapperSold.add(new ActualAccountWrapper(accountKey[1], accountKey[0],
                                                                decListMonths[0] != null ? Math.Round(decListMonths[0]) : null, decListMonths[1] != null ? Math.Round(decListMonths[1]) : null, decListMonths[2] != null ? Math.Round(decListMonths[2]) : null, decListMonths[3] != null ? Math.Round(decListMonths[3]) : null, 
                                                                decListMonths[4] != null ? Math.Round(decListMonths[4]) : null, decListMonths[5] != null ? Math.Round(decListMonths[5]) : null, decListMonths[6] != null ? Math.Round(decListMonths[6]) : null, decListMonths[7] != null ?  Math.Round(decListMonths[7]): null, 
                                                                decListMonths[8] != null ? Math.Round(decListMonths[8]) : null, decListMonths[9] != null ? Math.Round(decListMonths[9]) : null, decListMonths[10] != null ? Math.Round(decListMonths[10]) : null, decListMonths[11] != null ? Math.Round(decListMonths[11]) : null));//3911
                accountwrapperNet.add(new ActualAccountWrapper(accountKey[1], accountKey[0],
                                                               netListMonths[0] != null ? Math.Round(netListMonths[0]) : null, netListMonths[1] != null ? Math.Round(netListMonths[1]) : null, netListMonths[2] != null ? Math.Round(netListMonths[2]) : null, netListMonths[3] != null ? Math.Round(netListMonths[3]) : null, 
                                                               netListMonths[4] != null ? Math.Round(netListMonths[4]) : null, netListMonths[5] != null ? Math.Round(netListMonths[5]) : null, netListMonths[6] != null ? Math.Round(netListMonths[6]) : null, netListMonths[7] != null ? Math.Round(netListMonths[7]) : null,
                                                               netListMonths[8] != null ? Math.Round(netListMonths[8]) : null, netListMonths[9] != null ? Math.Round(netListMonths[9]) : null, netListMonths[10] != null? Math.Round(netListMonths[10]) : null, netListMonths[11] != null ? Math.Round(netListMonths[11]) : null ));//3911
            }else if(accountKey[0]=='NPA'){
                accWrapperLastRowSold.accountLast = System.Label.SumofnotplannedAccounts;
                accWrapperLastRowSold.actualSoldAmountL= decListMonths[0] != null ? Math.Round(decListMonths[0]) : null;
                accWrapperLastRowSold.actualSoldAmountL1= decListMonths[1] != null ? Math.Round(decListMonths[1]) : null;
                accWrapperLastRowSold.actualSoldAmountL2= decListMonths[2] != null ? Math.Round(decListMonths[2]) : null;
                accWrapperLastRowSold.actualSoldAmountL3= decListMonths[3] != null ? Math.Round(decListMonths[3]) : null;
                accWrapperLastRowSold.actualSoldAmountL4= decListMonths[4] != null ? Math.Round(decListMonths[4]) : null;
                accWrapperLastRowSold.actualSoldAmountL5= decListMonths[5] != null ? Math.Round(decListMonths[5]) : null;
                accWrapperLastRowSold.actualSoldAmountL6= decListMonths[6] != null ? Math.Round(decListMonths[6]) : null;
                accWrapperLastRowSold.actualSoldAmountL7= decListMonths[7] != null ? Math.Round(decListMonths[7]) : null;
                accWrapperLastRowSold.actualSoldAmountL8= decListMonths[8] != null ? Math.Round(decListMonths[8]) : null;
                accWrapperLastRowSold.actualSoldAmountL9= decListMonths[9] != null ? Math.Round(decListMonths[9]) : null;
                accWrapperLastRowSold.actualSoldAmountL10= decListMonths[10] != null ? Math.Round(decListMonths[10]) : null;
                accWrapperLastRowSold.actualSoldAmountL11= decListMonths[11] != null ? Math.Round(decListMonths[11]) : null;
                
                accWrapperLastRowNet.accountLast = System.Label.AverageofnotplannedAccounts;
                accWrapperLastRowNet.actualSoldAmountL= netListMonths[0] != null ? Math.Round(netListMonths[0]) : null;
                accWrapperLastRowNet.actualSoldAmountL1= netListMonths[1] != null ? Math.Round(netListMonths[1]) : null;
                accWrapperLastRowNet.actualSoldAmountL2= netListMonths[2] != null ? Math.Round(netListMonths[2]) : null;
                accWrapperLastRowNet.actualSoldAmountL3= netListMonths[3] != null ? Math.Round(netListMonths[3]) : null;
                accWrapperLastRowNet.actualSoldAmountL4= netListMonths[4] != null ? Math.Round(netListMonths[4]) : null;
                accWrapperLastRowNet.actualSoldAmountL5= netListMonths[5] != null ? Math.Round(netListMonths[5]) : null;
                accWrapperLastRowNet.actualSoldAmountL6= netListMonths[6] != null ? Math.Round(netListMonths[6]) : null;
                accWrapperLastRowNet.actualSoldAmountL7= netListMonths[7] != null ? Math.Round(netListMonths[7]) : null;
                accWrapperLastRowNet.actualSoldAmountL8= netListMonths[8] != null ? Math.Round(netListMonths[8]) : null;
                accWrapperLastRowNet.actualSoldAmountL9= netListMonths[9] != null ? Math.Round(netListMonths[9]) : null;
                accWrapperLastRowNet.actualSoldAmountL10= netListMonths[10] != null ? Math.Round(netListMonths[10]) : null;
                accWrapperLastRowNet.actualSoldAmountL11= netListMonths[11] != null ? Math.Round(netListMonths[11]) : null;
                
            }
        }
        accountwrapperSold.add(accWrapperLastRowSold);
        accountwrapperNet.add(accWrapperLastRowNet);
        SoldNetActualWrapper soldNetWrapper = new SoldNetActualWrapper();
        soldNetWrapper.accountwrapperSold = accountwrapperSold;
        soldNetWrapper.accountwrapperNet = accountwrapperNet;
        return soldNetWrapper;
    }   
    
    
    public class SoldNetActualWrapper {
        @AuraEnabled
        public List<ActualAccountWrapper> accountwrapperSold {get;set;}
        @AuraEnabled
        public List<ActualAccountWrapper> accountwrapperNet  {get;set;}
    }
    
    @AuraEnabled
    public static String toCalculateDeltaNet(String newAccDeltaWrapper,String bussinessArea){
        List<AccountSoldAmountawrapper> wrapperDeltaDataList = (List<AccountSoldAmountawrapper>) JSON.deserialize(newAccDeltaWrapper, List<AccountSoldAmountawrapper>.class);
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.year();
        
        Map<String, SalesPlanning__c> dateVsBASalesPlann = new Map<String, SalesPlanning__c>();
        SalesPlanning__c salesPlanUpdate = new SalesPlanning__c();
        List<SalesPlanning__c> updatedSpList = new List<SalesPlanning__c>();
        List<SalesPlanning__c> spList = [SELECT Id, Account__c,Account__r.Name, BusinessArea__c, ForecastTimePoint__c, Frequency__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                   FROM SalesPlanning__c WHERE ForecastLevel__c ='Account' AND 
                                   ForecastTimePoint__c > LAST_MONTH  AND ForecastTimePoint__c <= NEXT_N_MONTHS:12 AND BusinessArea__c=:bussinessArea AND Frequency__c='Monthly' ORDER By ForecastTimePoint__c ASC];

        Map<String, List<SalesPlanning__c>> dateVsSalesPlann = AccountSalesPlanningHelper.keyValueMapReturn(spList);  //6559       
        for(SalesPlanning__c ss : [SELECT Id, Account__c, BusinessArea__c, Frequency__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                   FROM SalesPlanning__c WHERE ForecastLevel__c ='Business Area/Product Group' AND Account__c = null AND BusinessArea__c =:bussinessArea AND
                                   ForecastTimePoint__c > LAST_MONTH  AND ForecastTimePoint__c <= NEXT_N_MONTHS:12 AND Frequency__c='Monthly' ORDER By ForecastTimePoint__c ASC]){
                                       Integer monthss = ss.ForecastTimePoint__c.month();
                                       Integer yearss = ss.ForecastTimePoint__c.year();
                                       Integer monInt = 0;
                                       if(yearss == currentYear){
                                           monInt = monthss - currentMonth;
                                       }
                                       else if(yearss > currentYear){
                                           monInt = 12 - currentMonth + monthss;
                                       }
                                       if(monInt == 0){
                                           dateVsBASalesPlann.put('currentFSoldAmount',ss); 
                                       }else{
                                           dateVsBASalesPlann.put('current'+monInt+'FSoldAmount',ss); 
                                       }
                                   }
        
        AccountSoldAmountawrapper accwrapper = getDeltaBussinessArea(bussinessArea);
        Map<String, Decimal> mapDeltadata  = convertToMap(wrapperDeltaDataList);
        Map<String, Decimal> mapOldDeltadata  = convertToMap(new List<AccountSoldAmountawrapper>{accwrapper});
        
        for(AccountSoldAmountawrapper newLoop : wrapperDeltaDataList){
            if(newLoop.isNetProceed){
                if(newLoop.currentFSoldAmount != null && accwrapper.currentFSoldAmount != newLoop.currentFSoldAmount && dateVsBASalesPlann.containsKey('currentFSoldAmount')){
                    salesPlanUpdate = dateVsBASalesPlann.get('currentFSoldAmount');
                    salesPlanUpdate.DeltaNetProceeds__c = newLoop.currentFSoldAmount;
                    updatedSpList.add(salesPlanUpdate);
                }
                if(newLoop.current1FSoldAmount != null && accwrapper.current1FSoldAmount != newLoop.current1FSoldAmount && dateVsBASalesPlann.containsKey('current1FSoldAmount')){
                    salesPlanUpdate = dateVsBASalesPlann.get('current1FSoldAmount');
                    salesPlanUpdate.DeltaNetProceeds__c = newLoop.current1FSoldAmount;
                    updatedSpList.add(salesPlanUpdate);
                }
                if(newLoop.current2FSoldAmount != null && accwrapper.current2FSoldAmount != newLoop.current2FSoldAmount && dateVsBASalesPlann.containsKey('current2FSoldAmount')){
                    salesPlanUpdate = dateVsBASalesPlann.get('current2FSoldAmount');
                    salesPlanUpdate.DeltaNetProceeds__c = newLoop.current2FSoldAmount;
                    updatedSpList.add(salesPlanUpdate);
                }
                if(newLoop.current3FSoldAmount != null && accwrapper.current3FSoldAmount != newLoop.current3FSoldAmount &&  dateVsBASalesPlann.containsKey('current3FSoldAmount')){
                    salesPlanUpdate = dateVsBASalesPlann.get('current3FSoldAmount');
                    salesPlanUpdate.DeltaNetProceeds__c = newLoop.current3FSoldAmount;
                    updatedSpList.add(salesPlanUpdate);
                }
                if(newLoop.current4FSoldAmount != null && accwrapper.current4FSoldAmount != newLoop.current4FSoldAmount &&  dateVsBASalesPlann.containsKey('current4FSoldAmount')){
                    salesPlanUpdate = dateVsBASalesPlann.get('current4FSoldAmount');
                    salesPlanUpdate.DeltaNetProceeds__c = newLoop.current4FSoldAmount;
                    updatedSpList.add(salesPlanUpdate);
                }
                if(newLoop.current5FSoldAmount != null && accwrapper.current5FSoldAmount != newLoop.current5FSoldAmount &&  dateVsBASalesPlann.containsKey('current5FSoldAmount')){
                    salesPlanUpdate = dateVsBASalesPlann.get('current5FSoldAmount');
                    salesPlanUpdate.DeltaNetProceeds__c = newLoop.current5FSoldAmount;
                    updatedSpList.add(salesPlanUpdate);
                }
                if(newLoop.current6FSoldAmount != null && accwrapper.current6FSoldAmount != newLoop.current6FSoldAmount && dateVsBASalesPlann.containsKey('current6FSoldAmount')){
                    salesPlanUpdate = dateVsBASalesPlann.get('current6FSoldAmount');
                    salesPlanUpdate.DeltaNetProceeds__c = newLoop.current6FSoldAmount;
                    updatedSpList.add(salesPlanUpdate);
                }
                if(newLoop.current7FSoldAmount != null && accwrapper.current7FSoldAmount != newLoop.current7FSoldAmount && dateVsBASalesPlann.containsKey('current7FSoldAmount')){
                    salesPlanUpdate = dateVsBASalesPlann.get('current7FSoldAmount');
                    salesPlanUpdate.DeltaNetProceeds__c = newLoop.current7FSoldAmount;
                    updatedSpList.add(salesPlanUpdate);
                }
                if(newLoop.current8FSoldAmount != null && accwrapper.current8FSoldAmount != newLoop.current8FSoldAmount && dateVsBASalesPlann.containsKey('current8FSoldAmount')){
                    salesPlanUpdate = dateVsBASalesPlann.get('current8FSoldAmount');
                    salesPlanUpdate.DeltaNetProceeds__c = newLoop.current8FSoldAmount;
                    updatedSpList.add(salesPlanUpdate);
                }
                if(newLoop.current9FSoldAmount != null && accwrapper.current9FSoldAmount != newLoop.current9FSoldAmount && dateVsBASalesPlann.containsKey('current9FSoldAmount')){
                    salesPlanUpdate = dateVsBASalesPlann.get('current9FSoldAmount');
                    salesPlanUpdate.DeltaNetProceeds__c = newLoop.current9FSoldAmount;
                    updatedSpList.add(salesPlanUpdate);
                }
                if(newLoop.current10FSoldAmount != null && accwrapper.current10FSoldAmount != newLoop.current10FSoldAmount && dateVsBASalesPlann.containsKey('current10FSoldAmount')){
                    salesPlanUpdate = dateVsBASalesPlann.get('current10FSoldAmount');
                    salesPlanUpdate.DeltaNetProceeds__c = newLoop.current10FSoldAmount;
                    updatedSpList.add(salesPlanUpdate);
                }
                if(newLoop.current11FSoldAmount != null && accwrapper.current11FSoldAmount != newLoop.current11FSoldAmount && dateVsBASalesPlann.containsKey('current11FSoldAmount')){
                    salesPlanUpdate = dateVsBASalesPlann.get('current11FSoldAmount');
                    salesPlanUpdate.DeltaNetProceeds__c = newLoop.current11FSoldAmount;
                    updatedSpList.add(salesPlanUpdate);
                }
                if(newLoop.current12FSoldAmount != null && accwrapper.current12FSoldAmount != newLoop.current12FSoldAmount && dateVsBASalesPlann.containsKey('current12FSoldAmount')){
                    salesPlanUpdate = dateVsBASalesPlann.get('current12FSoldAmount');
                    salesPlanUpdate.DeltaNetProceeds__c = newLoop.current12FSoldAmount;
                    updatedSpList.add(salesPlanUpdate);
                }
            }
        }
        for(String sploop : dateVsSalesPlann.keySet()){
            if(mapDeltadata.containsKey(sploop) && mapOldDeltadata.containsKey(sploop) && mapDeltadata.get(sploop) != mapOldDeltadata.get(sploop)){
                List<SalesPlanning__c> innerMapSP = dateVsSalesPlann.get(sploop);
                for(SalesPlanning__c innerLoop : innerMapSP){
                    Decimal deltaValue = mapDeltadata.get(sploop);
                    if(innerLoop.ForecastNetProceeds__c != null && deltaValue != null){
                        salesPlanUpdate = innerLoop;
                        salesPlanUpdate.ForecastNetProceeds__c = innerLoop.ForecastNetProceeds__c + deltaValue;
                        updatedSpList.add(salesPlanUpdate);
                    }
                }  
            }
            
        }
        if(!updatedSpList.isEmpty()){
            update updatedSpList;
        }
        return 'Success';
    }
    
    
    public static Map<String, Decimal> convertToMap(List<AccountSoldAmountawrapper> wrapperDeltaDataList){
        Map<String, Decimal> mapDeltadata  = new Map<String, Decimal>();
        for(AccountSoldAmountawrapper newLoopDelta : wrapperDeltaDataList){ 
            mapDeltadata.put('currentFSoldAmount', newLoopDelta.currentFSoldAmount);
            mapDeltadata.put('current1FSoldAmount', newLoopDelta.current1FSoldAmount);
            mapDeltadata.put('current2FSoldAmount', newLoopDelta.current2FSoldAmount);
            mapDeltadata.put('current3FSoldAmount', newLoopDelta.current3FSoldAmount);
            mapDeltadata.put('current4FSoldAmount', newLoopDelta.current4FSoldAmount);
            mapDeltadata.put('current5FSoldAmount', newLoopDelta.current5FSoldAmount);
            mapDeltadata.put('current6FSoldAmount', newLoopDelta.current6FSoldAmount);
            mapDeltadata.put('current7FSoldAmount', newLoopDelta.current7FSoldAmount);
            mapDeltadata.put('current8FSoldAmount', newLoopDelta.current8FSoldAmount);
            mapDeltadata.put('current9FSoldAmount', newLoopDelta.current9FSoldAmount);
            mapDeltadata.put('current10FSoldAmount', newLoopDelta.current10FSoldAmount);
            mapDeltadata.put('current11FSoldAmount', newLoopDelta.current11FSoldAmount);
            mapDeltadata.put('current12FSoldAmount', newLoopDelta.current12FSoldAmount);
        }
        return mapDeltadata;
    }
    
        
    //4216
    public static ActualAccountWrapper totalActualCalculation(List<ActualAccountWrapper> accSoldWrap){
        List<Decimal> actualSoldAmountL = new List<Decimal>(); //4112
        List<Decimal> actualSoldAmountL1= new List<Decimal>();
        List<Decimal> actualSoldAmountL2= new List<Decimal>();     
        List<Decimal> actualSoldAmountL3 = new List<Decimal>(); 
        List<Decimal> actualSoldAmountL4 = new List<Decimal>(); 
        List<Decimal> actualSoldAmountL5 = new List<Decimal>();
        List<Decimal> actualSoldAmountL6 = new List<Decimal>();
        List<Decimal> actualSoldAmountL7 = new List<Decimal>();
        List<Decimal> actualSoldAmountL8 = new List<Decimal>();
        List<Decimal> actualSoldAmountL9 = new List<Decimal>();
        List<Decimal> actualSoldAmountL10 = new List<Decimal>();
        List<Decimal> actualSoldAmountL11= new List<Decimal>();
        
        for(ActualAccountWrapper acc : accSoldWrap){
            actualSoldAmountL.add(acc.actualSoldAmountL); 
            actualSoldAmountL1.add(acc.actualSoldAmountL1);
            actualSoldAmountL2.add(acc.actualSoldAmountL2);
            actualSoldAmountL3.add(acc.actualSoldAmountL3);
            actualSoldAmountL4.add(acc.actualSoldAmountL4);
            actualSoldAmountL5.add(acc.actualSoldAmountL5);
            actualSoldAmountL6.add(acc.actualSoldAmountL6);
            actualSoldAmountL7.add(acc.actualSoldAmountL7);
            actualSoldAmountL8.add(acc.actualSoldAmountL8);
            actualSoldAmountL9.add(acc.actualSoldAmountL9);
            actualSoldAmountL10.add(acc.actualSoldAmountL10);
            actualSoldAmountL11.add(acc.actualSoldAmountL11);
        }
        ActualAccountWrapper actualWrapperTotal = new ActualAccountWrapper(null, null,sumAmount(actualSoldAmountL),sumAmount(actualSoldAmountL1),sumAmount(actualSoldAmountL2),sumAmount(actualSoldAmountL3),sumAmount(actualSoldAmountL4),
                                                                           sumAmount(actualSoldAmountL5),sumAmount(actualSoldAmountL6),sumAmount(actualSoldAmountL7),sumAmount(actualSoldAmountL8),
                                                                           sumAmount(actualSoldAmountL9),sumAmount(actualSoldAmountL10),sumAmount(actualSoldAmountL11)); //3911
        
        return actualWrapperTotal;
    }
    
    public static ActualAccountWrapper netActualAverageCalculation(List<ActualAccountWrapper> soldWrap, List<ActualAccountWrapper> netWrap, ActualAccountWrapper actualTotal){
        Map<String, ActualAccountWrapper> soldWrapperMap = new Map<String, ActualAccountWrapper>();
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
        
        for(ActualAccountWrapper soldLoop : soldWrap)
        {
            if(soldLoop.accountLast != System.Label.SumofnotplannedAccounts)
                soldWrapperMap.put(soldLoop.accountActualId, soldLoop);
            else
                soldWrapperMap.put(System.Label.AverageofnotplannedAccounts, soldLoop); 
        }
        for(ActualAccountWrapper bs : netWrap){
            if(soldWrapperMap.containsKey(bs.accountActualId)){
                ActualAccountWrapper  soldList = soldWrapperMap.get(bs.accountActualId);
                totalNetF = totalNetF + (bs.actualSoldAmountL != null ? bs.actualSoldAmountL : 0 ) * (soldList.actualSoldAmountL != null ? soldList.actualSoldAmountL : 0);
                totalNetF1 = totalNetF1 + (bs.actualSoldAmountL1 != null ? bs.actualSoldAmountL1 : 0) * (soldList.actualSoldAmountL1 != null ? soldList.actualSoldAmountL1 : 0);
                totalNetF2 = totalNetF2 + (bs.actualSoldAmountL2 != null ? bs.actualSoldAmountL2 : 0) * (soldList.actualSoldAmountL2 != null ? soldList.actualSoldAmountL2 : 0);
                totalNetF3 = totalNetF3 + (bs.actualSoldAmountL3 != null ? bs.actualSoldAmountL3 : 0) * (soldList.actualSoldAmountL3 != null ? soldList.actualSoldAmountL3 : 0);
                totalNetF4 = totalNetF4 + (bs.actualSoldAmountL4 != null ? bs.actualSoldAmountL4 : 0) * (soldList.actualSoldAmountL4 != null ? soldList.actualSoldAmountL4 : 0);
                totalNetF5 = totalNetF5 + (bs.actualSoldAmountL5 != null ? bs.actualSoldAmountL5 : 0) * (soldList.actualSoldAmountL5 != null ? soldList.actualSoldAmountL5 : 0);
                totalNetF6 = totalNetF6 + (bs.actualSoldAmountL6 != null ? bs.actualSoldAmountL6 : 0) * (soldList.actualSoldAmountL6 != null ? soldList.actualSoldAmountL6 : 0);
                totalNetF7 = totalNetF7 +  (bs.actualSoldAmountL7 != null ? bs.actualSoldAmountL7 : 0) * (soldList.actualSoldAmountL7 != null ? soldList.actualSoldAmountL7 : 0);
                totalNetF8 = totalNetF8 + (bs.actualSoldAmountL8 != null ? bs.actualSoldAmountL8 : 0) * (soldList.actualSoldAmountL8 != null ? soldList.actualSoldAmountL8 : 0);
                totalNetF9 = totalNetF9 + (bs.actualSoldAmountL9 != null ? bs.actualSoldAmountL9 : 0) * (soldList.actualSoldAmountL9 != null ? soldList.actualSoldAmountL9 : 0);
                totalNetF10 = totalNetF10 + (bs.actualSoldAmountL10 != null ? bs.actualSoldAmountL10 : 0) * (soldList.actualSoldAmountL10 != null ? soldList.actualSoldAmountL10 : 0);
                totalNetF11 = totalNetF11 + (bs.actualSoldAmountL11 != null ? bs.actualSoldAmountL11 : 0) * (soldList.actualSoldAmountL11 != null ?soldList.actualSoldAmountL11 : 0);
            }
        }
        
        ActualAccountWrapper actualAverageNet = new ActualAccountWrapper(null, null, 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0); 
        
        if(totalNetF != 0 && actualTotal.actualSoldAmountL != 0){
            actualAverageNet.actualSoldAmountL = Math.Round(totalNetF / actualTotal.actualSoldAmountL);
        }else{
            actualAverageNet.actualSoldAmountL = 0;
        }
        if(totalNetF1 != 0 && actualTotal.actualSoldAmountL1 != 0){
            actualAverageNet.actualSoldAmountL1 = Math.Round(totalNetF1 / actualTotal.actualSoldAmountL1);
        }else{
            actualAverageNet.actualSoldAmountL1 = 0;
        }
        if(totalNetF2 != 0 && actualTotal.actualSoldAmountL2 != 0){
            actualAverageNet.actualSoldAmountL2 = Math.Round(totalNetF2 / actualTotal.actualSoldAmountL2);
        }else{
            actualAverageNet.actualSoldAmountL2 = 0;
        }
        if(totalNetF3 != 0 && actualTotal.actualSoldAmountL3 != 0){
            actualAverageNet.actualSoldAmountL3 = Math.Round(totalNetF3 / actualTotal.actualSoldAmountL3);
        }else{
            actualAverageNet.actualSoldAmountL3 = 0;
        }
        if(totalNetF4 != 0 && actualTotal.actualSoldAmountL4 != 0){
            actualAverageNet.actualSoldAmountL4 = Math.Round(totalNetF4 / actualTotal.actualSoldAmountL4);
        }else{
            actualAverageNet.actualSoldAmountL4 = 0;
        }
        if(totalNetF5 != 0 && actualTotal.actualSoldAmountL5 != 0){
            actualAverageNet.actualSoldAmountL5 = Math.Round(totalNetF5 / actualTotal.actualSoldAmountL5);
        }else{
            actualAverageNet.actualSoldAmountL5 = 0;
        }
        if(totalNetF6 != 0 && actualTotal.actualSoldAmountL6 != 0){
            actualAverageNet.actualSoldAmountL6 = Math.Round(totalNetF6 / actualTotal.actualSoldAmountL6);
        }else{
            actualAverageNet.actualSoldAmountL6 = 0;
        }
        if(totalNetF7 != 0 && actualTotal.actualSoldAmountL7 != 0){
            actualAverageNet.actualSoldAmountL7 = Math.Round(totalNetF7 / actualTotal.actualSoldAmountL7);
        }else{
            actualAverageNet.actualSoldAmountL7 = 0;
        }
        if(totalNetF8 != 0 && actualTotal.actualSoldAmountL8 != 0){
            actualAverageNet.actualSoldAmountL8 = Math.Round(totalNetF8 / actualTotal.actualSoldAmountL8);
        }else{
            actualAverageNet.actualSoldAmountL8 = 0;
        }
        if(totalNetF9 != 0 && actualTotal.actualSoldAmountL9 != 0){
            actualAverageNet.actualSoldAmountL9 = Math.Round(totalNetF9 / actualTotal.actualSoldAmountL9);
        }else{
            actualAverageNet.actualSoldAmountL9 = 0;
        }
        if(totalNetF10 != 0 && actualTotal.actualSoldAmountL10 != 0){
            actualAverageNet.actualSoldAmountL10 = Math.Round(totalNetF10 / actualTotal.actualSoldAmountL10);
        }else{
            actualAverageNet.actualSoldAmountL10 = 0;
        }
        if(totalNetF11 != 0 && actualTotal.actualSoldAmountL11 != 0){
            actualAverageNet.actualSoldAmountL11 = Math.Round(totalNetF11 / actualTotal.actualSoldAmountL11);
        }else{
            actualAverageNet.actualSoldAmountL11 = 0;
        }
        
        return actualAverageNet;
    }
    
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to populate the table data for the Account Sales Planning Table.
* Created Date: 24/03/2023
* Last Modified Date: 24/03/2023
****************************************************************************/
    @AuraEnabled
    public static DataTableResponse showtabledata(String businessArea, String sortOrder) {
        //For Sold Amount
        Map<String, Map<Date,Decimal>> accountVsForecastvalue = new Map<String, Map<Date,Decimal>>();
        Map<String, Map<Date,Decimal>> accountVsForecastNetProceedMap = new Map<String, Map<Date,Decimal>>();
        //actual amount
        Map<String, Decimal> accountVsActualSoldAmount = new  Map<String, Decimal>();
        Map<String, Decimal> accountVsActualNetProceeds = new  Map<String, Decimal>();
        //RollingFCurrentYrMap
        Map<String, List<Decimal>> soldAmountRollingFCurrentYrMap = new Map<String, List<Decimal>>();
        Map<String, Map<String, SalesPlanning__c>> netProceedRollingFCurrentYrMap = new Map<String, Map<String, SalesPlanning__c>>(); //4292
        Map<String, Decimal> accSoldAmountVsRFCurYr = new Map<String, Decimal>();
        Map<String, Decimal> accFNetVsRFCurYr = new Map<String, Decimal>();
        //For Yearly
        Map<String, Map<Integer,Decimal>> accountVSYearlyAmt = new Map<String, Map<Integer,Decimal>>();
        Map<String, Map<Integer,Decimal>> accountVSYearlyNetProceeds = new Map<String, Map<Integer,Decimal>>();
        Map<String, SalesPlanning__c> accountVsSpMap = new Map<String, SalesPlanning__c>();
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.year();
        Decimal totalRollingFCurrentYr = 0;
        String orderByField = 'ForecastTimePoint__c';
        String sortingorder = 'ASC';
        String AccountField = 'Account';
        String Frequency = 'Monthly';
        String dynamicQuery = 'SELECT Id, Account__c, Account__r.Name, Account__r.SAPAccountNumber__c, BusinessArea__c, Frequency__c, ' +
                              'ForecastTimePoint__c, ForecastSoldAmount__c, ActualNetProceeds__c, ActualSoldAmount__c, ForecastNetProceeds__c, ' +
                              'ForecastLevel__c, DeltaNetProceeds__c ' +
                              'FROM SalesPlanning__c ' +
                              'WHERE ForecastLevel__c = ' ;
                              if(AccountField!=null)
                              dynamicQuery+= ':AccountField ' ;
                                  
                              dynamicQuery+= 'AND BusinessArea__c = :businessArea ' +
                              'AND ForecastTimePoint__c > LAST_MONTH AND ForecastTimePoint__c <= NEXT_N_MONTHS:12 ';
                              if(Frequency!=null)
                              dynamicQuery+= 'AND Frequency__c = :Frequency ' +
                              'ORDER BY '+ orderByField +' ' + sortingorder+' NULLS LAST';
        String strdynamic = String.escapeSingleQuotes(dynamicQuery);
        List<SalesPlanning__c> salesplanningrecords = Database.query(strdynamic);
        for(SalesPlanning__c sp : salesplanningrecords ){
                                       // map to store Sold Amount values
                                       if(sp.Account__c!=null && !accountVsForecastvalue.containsKey(sp.Account__c+CONVARIABLE+sp.Account__r.Name)) {
                                           accountVsForecastvalue.put(sp.Account__c+CONVARIABLE+sp.Account__r.Name, new Map<Date, Decimal>());
                                       }
                                       else if(sp.Account__c==null && !accountVsForecastvalue.containsKey('NPA'+CONVARIABLE+System.Label.SumofnotplannedAccounts)){
                                           accountVsForecastvalue.put('NPA'+CONVARIABLE+System.Label.SumofnotplannedAccounts, new Map<Date, Decimal>());
                                       }
                                       if(sp.Account__c!=null){
                                           Map<Date, Decimal> innerMap = accountVsForecastvalue.get(sp.Account__c+CONVARIABLE+sp.Account__r.Name);
                                           innerMap.put(sp.ForecastTimePoint__c, sp.ForecastSoldAmount__c);
                                           accountVsSpMap.put(sp.Account__c, sp);
                                       }
                                       else{
                                           Map<Date, Decimal> innerMap = accountVsForecastvalue.get('NPA'+CONVARIABLE+System.Label.SumofnotplannedAccounts);
                                           innerMap.put(sp.ForecastTimePoint__c, sp.ForecastSoldAmount__c);
                                       }
                                       
                                       // map to store Forecast Net Proceeds values
                                       if (sp.Account__c!=null && !accountVsForecastNetProceedMap.containsKey(sp.Account__c+CONVARIABLE+sp.Account__r.Name)) {
                                           accountVsForecastNetProceedMap.put(sp.Account__c+CONVARIABLE+sp.Account__r.Name, new Map<Date, Decimal>());
                                       }
                                       else if(sp.Account__c==null && !accountVsForecastNetProceedMap.containsKey('NPA'+CONVARIABLE+System.Label.AverageofnotplannedAccounts)){
                                           accountVsForecastNetProceedMap.put('NPA'+CONVARIABLE+System.Label.AverageofnotplannedAccounts, new Map<Date, Decimal>());
                                       }
                                       if(sp.Account__c!=null){
                                           Map<Date, Decimal> innerMapNetProceed = accountVsForecastNetProceedMap.get(sp.Account__c+CONVARIABLE+sp.Account__r.Name);
                                           innerMapNetProceed.put(sp.ForecastTimePoint__c, sp.ForecastNetProceeds__c);
                                       }
                                       else{
                                           Map<Date, Decimal> innerMapNetProceed = accountVsForecastNetProceedMap.get('NPA'+CONVARIABLE+System.Label.AverageofnotplannedAccounts);
                                           innerMapNetProceed.put(sp.ForecastTimePoint__c, sp.ForecastNetProceeds__c);
                                       }
                                       
                                   }
        //To Populate Actual Amount
        for(SalesPlanning__c sPlanloop : [SELECT Id, Account__c, BusinessArea__c, ForecastSoldAmount__c, Frequency__c, ForecastNetProceeds__c, ForecastTimePoint__c, ActualSoldAmount__c, ActualNetProceeds__c
                                          FROM SalesPlanning__c WHERE ForecastLevel__c ='Account' AND BusinessArea__c = :businessarea  AND Frequency__c ='Monthly' ORDER By ForecastTimePoint__c DESC]){   //4690
                                              if((sPlanLoop.ForecastTimePoint__c.month() == currentMonth - 1 && sPlanLoop.ForecastTimePoint__c.Year() == currentYear) || (sPlanLoop.ForecastTimePoint__c.month() == 12 && sPlanLoop.ForecastTimePoint__c.Year() == currentYear -1)){ //4690 
                                                  if(sPlanLoop.Account__c != null && sPlanLoop.ActualSoldAmount__c != null ){
                                                      accountVsActualSoldAmount.put(sPlanloop.Account__c, Math.round(sPlanloop.ActualSoldAmount__c)); //4695
                                                  }
                                                  else if(sPlanLoop.Account__c == null && sPlanLoop.ActualSoldAmount__c != null ){
                                                      accountVsActualSoldAmount.put('NPA', Math.round(sPlanloop.ActualSoldAmount__c));//4695
                                                  }
                                                  if(sPlanLoop.Account__c != null && sPlanLoop.ActualNetProceeds__c != null ){
                                                      accountVsActualNetProceeds.put(sPlanLoop.Account__c, Math.round(sPlanLoop.ActualNetProceeds__c));//4695
                                                  }
                                                  else if(sPlanLoop.Account__c == null && sPlanLoop.ActualNetProceeds__c != null ){
                                                      accountVsActualNetProceeds.put('NPA', Math.round(sPlanloop.ActualNetProceeds__c));//4695
                                                  }
                                              }
                                              DateTime nextMonth = sPlanLoop.ForecastTimePoint__c;
                                              String monthName = nextMonth.format('MMM yy');
                                              if(sPlanLoop.ForecastTimePoint__c.month() < currentMonth && sPlanLoop.ForecastTimePoint__c.Year() == currentYear){
                                                  if(sPlanLoop.Account__c != null && sPlanLoop.ActualSoldAmount__c != null ){
                                                      if(!soldAmountRollingFCurrentYrMap.containsKey(sPlanLoop.Account__c)){
                                                          soldAmountRollingFCurrentYrMap.put(sPlanLoop.Account__c, New List<Decimal>()); 
                                                      }
                                                      soldAmountRollingFCurrentYrMap.get(sPlanLoop.Account__c).add(sPlanLoop.ActualSoldAmount__c); 
                                                  }
                                                  else if(sPlanLoop.Account__c == null && sPlanLoop.ActualSoldAmount__c != null ){
                                                      if(!soldAmountRollingFCurrentYrMap.containsKey('NPA')){
                                                          soldAmountRollingFCurrentYrMap.put('NPA', New List<Decimal>()); 
                                                      }
                                                      soldAmountRollingFCurrentYrMap.get('NPA').add(sPlanLoop.ActualSoldAmount__c); 
                                                  }
                                                  
                                                  if(sPlanLoop.Account__c != null && sPlanLoop.ActualNetProceeds__c != null ){
                                                      //4292
                                                      if(!netProceedRollingFCurrentYrMap.containsKey(sPlanLoop.Account__c)){
                                                          Map<String, SalesPlanning__c> innerMap = new Map<String, SalesPlanning__c>();
                                                          innerMap.put(monthName, sPlanLoop);
                                                          netProceedRollingFCurrentYrMap.put(sPlanLoop.Account__c, innerMap);
                                                          
                                                      }
                                                      else {
                                                          Map<String, SalesPlanning__c> innerMap = netProceedRollingFCurrentYrMap.get(sPlanLoop.Account__c);
                                                          innerMap.put(monthName, sPlanLoop);
                                                      } 
                                                  }
                                                  else if(sPlanLoop.Account__c == null && sPlanLoop.ActualNetProceeds__c != null ){
                                                      if(!netProceedRollingFCurrentYrMap.containsKey('NPA')){
                                                          netProceedRollingFCurrentYrMap.put('NPA', new Map<String, SalesPlanning__c>()); 
                                                      }
                                                      netProceedRollingFCurrentYrMap.get('NPA').put(monthName,sPlanLoop); 
                                                  }
                                              }
                                              if(sPlanLoop.ForecastTimePoint__c.month() >= currentMonth && sPlanLoop.ForecastTimePoint__c.Year() == currentYear){
                                                  if(sPlanLoop.Account__c != null && sPlanLoop.ForecastSoldAmount__c != null ){
                                                      if(!soldAmountRollingFCurrentYrMap.ContainsKey(sPlanLoop.Account__c)){
                                                          soldAmountRollingFCurrentYrMap.put(sPlanLoop.Account__c, New List<Decimal>()); 
                                                      }
                                                      soldAmountRollingFCurrentYrMap.get(sPlanLoop.Account__c).add(sPlanLoop.ForecastSoldAmount__c); 
                                                  }
                                                  else if(sPlanLoop.Account__c == null && sPlanLoop.ForecastSoldAmount__c != null ){
                                                      if(!soldAmountRollingFCurrentYrMap.ContainsKey('NPA')){
                                                          soldAmountRollingFCurrentYrMap.put('NPA', New List<Decimal>()); 
                                                      }
                                                      soldAmountRollingFCurrentYrMap.get('NPA').add(sPlanLoop.ForecastSoldAmount__c); 
                                                  }
                                                  
                                                  if(sPlanLoop.Account__c != null && sPlanLoop.ForecastNetProceeds__c != null ){
                                                      //4292
                                                      if(!netProceedRollingFCurrentYrMap.ContainsKey(sPlanLoop.Account__c)){
                                                          Map<String, SalesPlanning__c> innerMap = new Map<String, SalesPlanning__c>();
                                                          innerMap.put(monthName, sPlanLoop);
                                                          netProceedRollingFCurrentYrMap.put(sPlanLoop.Account__c, innerMap); 
                                                      }
                                                      else {
                                                          Map<String, SalesPlanning__c> innerMap = netProceedRollingFCurrentYrMap.get(sPlanLoop.Account__c);
                                                          innerMap.put(monthName, sPlanLoop);
                                                      }
                                                  }
                                                  else if(sPlanLoop.Account__c == null && sPlanLoop.ForecastNetProceeds__c != null ){
                                                      if(!netProceedRollingFCurrentYrMap.ContainsKey('NPA')){
                                                          netProceedRollingFCurrentYrMap.put('NPA', new Map<String, SalesPlanning__c>()); 
                                                      }
                                                      netProceedRollingFCurrentYrMap.get('NPA').put(monthName,sPlanLoop); 
                                                  }
                                                  
                                              }
                                          }
        //Yearly        
        for(SalesPlanning__c sPlanloop : [SELECT Id, Account__c, BusinessArea__c, ForecastSoldAmount__c, ForecastNetProceeds__c, ForecastTimePoint__c, ActualSoldAmount__c, ActualNetProceeds__c
                                          FROM SalesPlanning__c WHERE ForecastLevel__c ='Account' AND BusinessArea__c = :businessarea AND Frequency__c = 'Yearly' ORDER By ForecastTimePoint__c DESC]){   
                                              Integer yearss;
                                              if(sPlanLoop.Account__c != null){
                                                  if(!accountVSYearlyAmt.containsKey(sPlanloop.Account__c)){
                                                      accountVSYearlyAmt.put(sPlanloop.Account__c, new Map<Integer, Decimal>()); 
                                                  }
                                                  Map<Integer, Decimal> innerMap = accountVSYearlyAmt.get(sPlanloop.Account__c);
                                                  yearss = sPlanloop.ForecastTimePoint__c.year();                         
                                                  innerMap.put(yearss, sPlanloop.ForecastSoldAmount__c);
                                                  
                                                  if(!accountVSYearlyNetProceeds.containsKey(sPlanloop.Account__c)) {
                                                      accountVSYearlyNetProceeds.put(sPlanloop.Account__c, new Map<Integer, Decimal>());
                                                  }
                                                  Map<Integer, Decimal> innerMapNetProceed = accountVSYearlyNetProceeds.get(sPlanloop.Account__c);
                                                  innerMapNetProceed.put(yearss, sPlanloop.ForecastNetProceeds__c);   
                                              }else{
                                                  if(!accountVSYearlyAmt.containsKey('NPA')){
                                                      accountVSYearlyAmt.put('NPA', new Map<Integer, Decimal>()); 
                                                  }
                                                  Map<Integer, Decimal> innerMap = accountVSYearlyAmt.get('NPA');
                                                  yearss = sPlanloop.ForecastTimePoint__c.year();                         
                                                  innerMap.put(yearss, sPlanloop.ForecastSoldAmount__c);
                                                  
                                                  if (!accountVSYearlyNetProceeds.containsKey('NPA')) {
                                                      accountVSYearlyNetProceeds.put('NPA', new Map<Integer, Decimal>());
                                                  }
                                                  Map<Integer, Decimal> innerMapNetProceed = accountVSYearlyNetProceeds.get('NPA');
                                                  innerMapNetProceed.put(yearss, sPlanloop.ForecastNetProceeds__c);  
                                              }
                                              
                                          }
        
        for(String rCYLoop : soldAmountRollingFCurrentYrMap.keyset()){
            for(Decimal dc : soldAmountRollingFCurrentYrMap.get(rCYLoop)){
                totalRollingFCurrentYr = Math.round(totalRollingFCurrentYr + dc);
            }
            accSoldAmountVsRFCurYr.put(rCYLoop, totalRollingFCurrentYr);
            totalRollingFCurrentYr = 0;
        }
        
        //4292 -Start
        for(String monthLoop : netProceedRollingFCurrentYrMap.keySet()){
            Map<String, SalesPlanning__c> innerMapList = netProceedRollingFCurrentYrMap.get(monthLoop);
            Decimal totalReceived = 0;
            for(SalesPlanning__c sPlanLoop : innerMapList.values()){
                if(sPlanLoop.ForecastTimePoint__c.month() < currentMonth && sPlanLoop.ForecastTimePoint__c.Year() == currentYear){
                    if(sPlanLoop.ActualSoldAmount__c != null && sPlanLoop.ActualNetProceeds__c != null){
                        totalReceived = totalReceived + (sPlanLoop.ActualNetProceeds__c * sPlanLoop.ActualSoldAmount__c);
                    }
                }else if(sPlanLoop.ForecastTimePoint__c.month() >= currentMonth && sPlanLoop.ForecastTimePoint__c.Year() == currentYear){
                    if(sPlanLoop.ForecastSoldAmount__c != null && sPlanLoop.ForecastNetProceeds__c != null){
                        totalReceived = totalReceived + (sPlanLoop.ForecastNetProceeds__c * sPlanLoop.ForecastSoldAmount__c);
                    }
                }
            }
            Decimal totalSoldAmmount = accSoldAmountVsRFCurYr.containsKey(monthLoop) ? accSoldAmountVsRFCurYr.get(monthLoop) : 0;
            Decimal averageNet;
            if( totalReceived != 0 && totalSoldAmmount != 0){
                averageNet = Math.Round(totalReceived / totalSoldAmmount); 
            }
            accFNetVsRFCurYr.put(monthLoop, averageNet);
        }
        //4292 -End
        //4216 - start
        SoldNetActualWrapper soldNetWrapper = showActualTableData(businessArea);
        List<ActualAccountWrapper> actualSoldWrap = soldNetWrapper.accountwrapperSold;
        List<ActualAccountWrapper> actualNetProceedWrap =  soldNetWrapper.accountwrapperNet;
        //4216 - end
        List<AccountSoldAmountawrapper> accSoldWrap =  getAccountwrapper(businessArea,accountVsForecastvalue, accountVsActualSoldAmount, accSoldAmountVsRFCurYr , accountVSYearlyAmt, true, true, actualSoldWrap, accountVsSpMap ); 
        List<AccountSoldAmountawrapper> accNetProceedWrap =  getAccountwrapper(businessArea,accountVsForecastNetProceedMap, accountVsActualNetProceeds, accFNetVsRFCurYr, accountVSYearlyNetProceeds, false, false, actualNetProceedWrap, accountVsSpMap); 
        List<AccountSoldAmountawrapper> accountTotalSoldwrapper = new List<AccountSoldAmountawrapper>();
        List<AccountSoldAmountawrapper> accountAveragewrapper = new List<AccountSoldAmountawrapper>();
        List<AccountSoldAmountawrapper> accountDeltawrapper = new List<AccountSoldAmountawrapper>();
        
        Map<String, Decimal> soldTotal = soldCalculation(accSoldWrap);
        List<Decimal> listsoldTotal = new List<Decimal>();
        for(Decimal dc :  soldTotal.values()){
            listsoldTotal.add(dc);
        }
        //4216
        ActualAccountWrapper actualTotal = totalActualCalculation(actualSoldWrap);
        ActualAccountWrapper actualAverage = netActualAverageCalculation(actualSoldWrap, actualNetProceedWrap, actualTotal);
        ActualAccountWrapper nullactual = new ActualAccountWrapper(null,null,null, null, null, null, null,null, null,null, null, null, null, null);
        //Total
        
        accountTotalSoldwrapper.add(new AccountSoldAmountawrapper(null,null,null,null,
                                                                  listsoldTotal[0], listsoldTotal[1], listsoldTotal[2],listsoldTotal[3], listsoldTotal[4], 
                                                                  listsoldTotal[5], listsoldTotal[6], listsoldTotal[7], listsoldTotal[8], listsoldTotal[9], listsoldTotal[10], listsoldTotal[11],listsoldTotal[12],
                                                                  listsoldTotal[13],listsoldTotal[14],listsoldTotal[15],listsoldTotal[16],listsoldTotal[17],actualTotal,true,false, false,false,false,false,false)); //3911, 4112
        accountTotalSoldwrapper.add(new AccountSoldAmountawrapper(null,null, null, null,null,
                                                                  null, null, null,null, null, 
                                                                  null, null, null, null, null, null, null,null,
                                                                  null,null,null,null,nullactual,false,false,false,true,false,false,false));
        AccountSoldAmountawrapper accwrapper = getDeltaBussinessArea(businessArea);
        accountDeltawrapper.add(new AccountSoldAmountawrapper(null,null, null, null,null,
                                                              null, null, null,null, null, 
                                                              null, null, null, null, null, null, null,null,
                                                              null,null,null,null,nullactual,false,false,false,false,true,false,false)); 
        accountDeltawrapper.add(accwrapper);
        
        List<Decimal> monthVsNetProceed = netAverageCalculation(accSoldWrap, accNetProceedWrap, soldTotal);
        //Average
        accountAveragewrapper.add(new AccountSoldAmountawrapper(null,null,null,null,
                                                                monthVsNetProceed[0], monthVsNetProceed[1], monthVsNetProceed[2],monthVsNetProceed[3], monthVsNetProceed[4], 
                                                                monthVsNetProceed[5], monthVsNetProceed[6], monthVsNetProceed[7], monthVsNetProceed[8], monthVsNetProceed[9], monthVsNetProceed[10], monthVsNetProceed[11],monthVsNetProceed[12],
                                                                monthVsNetProceed[13],monthVsNetProceed[14],monthVsNetProceed[15],monthVsNetProceed[16],monthVsNetProceed[17], actualAverage, false,true, false,false,false,false,false));//3911, 4112
        DataTableResponse finalWrapper   = new DataTableResponse();
        finalWrapper.getSoldAmount = accSoldWrap;//forecast sold Amount data
        finalWrapper.ForecastNetProceeds = accNetProceedWrap;// forecast net Proceed data
        finalWrapper.soldCalculation = accountTotalSoldwrapper; // Total of Sold Amount
        finalWrapper.netProceedCalculation = accountAveragewrapper; // Weighted Average 
        finalWrapper.deltacalculation = accountDeltawrapper; //Delta Net proceeds
        
        //sorting US- 8548 start
            map<String,AccountSoldAmountawrapper> ForecastSoldAmountmap = new map<String,AccountSoldAmountawrapper>();
            map<String,AccountSoldAmountawrapper> ActualSoldAmountmap = new map<String,AccountSoldAmountawrapper>();
            map<String,AccountSoldAmountawrapper> ActualNetProceedsmap = new map<String,AccountSoldAmountawrapper>();
            map<String,AccountSoldAmountawrapper> ForecastNetProceedsmap = new map<String,AccountSoldAmountawrapper>();
            map<String,AccountSoldAmountawrapper> ForecastNetProceedsFinalmap = new map<String,AccountSoldAmountawrapper>();
            map<String,AccountSoldAmountawrapper> AccountSortedmap = new map<String,AccountSoldAmountawrapper>();
            map<String,AccountSoldAmountawrapper> AccountSortedNetmap = new map<String,AccountSoldAmountawrapper>();
            map<String,AccountSoldAmountawrapper> getSoldAmountFinalmap = new map<String,AccountSoldAmountawrapper>();
            map<String,AccountSoldAmountawrapper> ActualSoldAmountFinalmap = new map<String,AccountSoldAmountawrapper>();
            map<String,AccountSoldAmountawrapper> ActualNetProceedsFinalmap = new map<String,AccountSoldAmountawrapper>();
            map<String,Decimal> rollingForecastCurrentYearlstSold = new map<String,Decimal>();
            map<String,Decimal> rollingForecastCurrentYearlstNetProceed = new map<String,Decimal>();
            map<String,Decimal> ActuallstSold = new  map<String,Decimal>();
            map<String,Decimal> ActuallstNetProceed = new map<String,Decimal>();
            list<String> accountlist = new list<String>();
            list<String> accountlistNet = new list<String>();
            list<String> updatedAccountList = new list<String>();
        
         for(AccountSoldAmountawrapper gsa : finalWrapper.getSoldAmount){
                accountlist.add(gsa.Account);
                ForecastSoldAmountmap.put(gsa.Account ,gsa);
                ActualSoldAmountmap.put(gsa.Account ,gsa);
                rollingForecastCurrentYearlstSold.put(gsa.Account,gsa.rollingForecastCurrentYear);
                ActuallstSold.put(gsa.Account,gsa.ActualSoldAmount);
           }
        for(AccountSoldAmountawrapper netproceed : finalWrapper.ForecastNetProceeds){
                accountlistNet.add(netproceed.Account);
                ForecastNetProceedsmap.put(netproceed.Account ,netproceed);
                ActualNetProceedsmap.put(netproceed.Account,netproceed);
                rollingForecastCurrentYearlstNetProceed.put(netproceed.Account, netproceed.rollingForecastCurrentYear);
                ActuallstNetProceed.put(netproceed.Account,netproceed.ActualSoldAmount);
          }
        List<String> valuesToRemove = new List<String>{System.label.SumofnotplannedAccounts ,System.label.PercentageChangeLabel, System.label.SoldAmount};
        if(sortOrder == System.label.Sorting1){
            //SoldAmountSorting
            String removedValue;
            for (String value : accountlist) {
                if (!valuesToRemove.contains(value)) {
                    updatedAccountList.add(value);
                }
            }
            updatedAccountList.sort();
            AccountSortedmap.put(System.label.SoldAmount, ForecastSoldAmountmap.get(System.label.SoldAmount));
            AccountSortedmap.put(System.label.PercentageChangeLabel, ForecastSoldAmountmap.get(System.label.PercentageChangeLabel));
            for (String sortedValue : updatedAccountList) {
                    for (String account : ForecastSoldAmountmap.keySet()) {
                        if (account == sortedValue) {
                            AccountSortedmap.put(account, ForecastSoldAmountmap.get(account));
                        }
                    }
              }
            AccountSortedmap.put(System.label.SumofnotplannedAccounts, ForecastSoldAmountmap.get(System.label.SumofnotplannedAccounts));
            //NetProceedsSorting
            for(Integer i=0;i<accountlistNet.size();i++)
            {
                if(accountlistNet[i]==System.label.AverageofnotplannedAccounts){
                  removedValue = accountlistNet[i];
                  accountlistNet.remove(i);
                  i--;
                }
            }
            accountlistNet.sort();
            for (String sortedValue : accountlistNet) {
                    for (String account : ForecastNetProceedsmap.keySet()) {
                        if (account == sortedValue) {
                            AccountSortedNetmap.put(account, ForecastNetProceedsmap.get(account));
                        }
                    }
              }
            AccountSortedNetmap.put(System.label.AverageofnotplannedAccounts, ForecastNetProceedsmap.get(System.label.AverageofnotplannedAccounts));
            finalWrapper.getSoldAmount = AccountSortedmap.values();
            finalWrapper.ForecastNetProceeds = AccountSortedNetmap.values();
        }
        if(sortOrder == System.label.Sorting2){
          //SoldAmountSorting
            String removedValue;
            for (String value : accountlist) {
                if (!valuesToRemove.contains(value)) {
                    updatedAccountList.add(value);
                }
            }
            updatedAccountList.sort();
            AccountSortedmap.put(System.label.SoldAmount, ForecastSoldAmountmap.get(System.label.SoldAmount));
            AccountSortedmap.put(System.label.PercentageChangeLabel, ForecastSoldAmountmap.get(System.label.PercentageChangeLabel));
            for (Integer i = updatedAccountList.size() - 1; i >= 0; i--) {
                String sortedValue = updatedAccountList[i];
                for (String account : ForecastSoldAmountmap.keySet()) {
                        if (account == sortedValue) {
                            AccountSortedmap.put(account, ForecastSoldAmountmap.get(account));
                        }
                    }
            }
            AccountSortedmap.put(System.label.SumofnotplannedAccounts, ForecastSoldAmountmap.get(System.label.SumofnotplannedAccounts));
            //NetProceedsSorting
            for(Integer i=0;i<accountlistNet.size();i++)
            {
                if(accountlistNet[i]==System.label.AverageofnotplannedAccounts){
                  removedValue = accountlistNet[i];
                  accountlistNet.remove(i);
                  i--;
                }
            }
            accountlistNet.sort();
            for (Integer i = accountlistNet.size() - 1; i >= 0; i--) {
                String sortedValue = accountlistNet[i];
                    for (String account : ForecastNetProceedsmap.keySet()) {
                        if (account == sortedValue) {
                            AccountSortedNetmap.put(account, ForecastNetProceedsmap.get(account));
                        }
                    }
              }
            AccountSortedNetmap.put(System.label.AverageofnotplannedAccounts, ForecastNetProceedsmap.get(System.label.AverageofnotplannedAccounts));
            finalWrapper.getSoldAmount = AccountSortedmap.values();
            finalWrapper.ForecastNetProceeds = AccountSortedNetmap.values();   
        }
        if(sortOrder == System.label.Sorting3){
            //SoldAmountSorting
            Decimal removedValue;
            if (rollingForecastCurrentYearlstSold.get(System.label.SumofnotplannedAccounts) != null)
                removedValue = rollingForecastCurrentYearlstSold.get(System.label.SumofnotplannedAccounts);
            
               rollingForecastCurrentYearlstSold.remove(System.label.SumofnotplannedAccounts);
            
            List<Decimal> sortedValues = new List<Decimal>(rollingForecastCurrentYearlstSold.values());
             sortedValues.sort(); 
             //sortedValues.add(removedValue);
             for (Decimal sortedValue : sortedValues) {
                    for (String account : rollingForecastCurrentYearlstSold.keySet()) {
                        if (rollingForecastCurrentYearlstSold.get(account) == sortedValue) {
                            getSoldAmountFinalmap.put(account, ForecastSoldAmountmap.get(account));
                        }
                    }
              }
            getSoldAmountFinalmap.put(System.label.SumofnotplannedAccounts, ForecastSoldAmountmap.get(System.label.SumofnotplannedAccounts));
            
            //NetProceedsSorting
            Decimal removedNetValue;
            if (rollingForecastCurrentYearlstNetProceed.get(System.label.AverageofnotplannedAccounts) != null)
             removedNetValue= rollingForecastCurrentYearlstNetProceed.get(System.label.AverageofnotplannedAccounts);
            
             rollingForecastCurrentYearlstNetProceed.remove(System.label.AverageofnotplannedAccounts);           
             List<Decimal> sortedNetValues = new List<Decimal>(rollingForecastCurrentYearlstNetProceed.values());
             sortedNetValues.sort(); 
             //sortedNetValues.add(removedNetValue); 
            for (Decimal sortedNetValue : sortedNetValues) {
                    for (String account : rollingForecastCurrentYearlstNetProceed.keySet()) {
                        if (rollingForecastCurrentYearlstNetProceed.get(account) == sortedNetValue) {
                            ForecastNetProceedsFinalmap.put(account, ForecastNetProceedsmap.get(account));
                        }
                    }
              }
            ForecastNetProceedsFinalmap.put(System.label.AverageofnotplannedAccounts, ForecastNetProceedsmap.get(System.label.AverageofnotplannedAccounts));
            finalWrapper.getSoldAmount = getSoldAmountFinalmap.values();
            finalWrapper.ForecastNetProceeds = ForecastNetProceedsFinalmap.values();
        }
        if(sortOrder == System.label.Sorting4){
            
            //SoldAmountSorting
            Decimal removedValue;
            if (rollingForecastCurrentYearlstSold.get(System.label.SumofnotplannedAccounts) != null)
                removedValue = rollingForecastCurrentYearlstSold.get(System.label.SumofnotplannedAccounts);
            
            rollingForecastCurrentYearlstSold.remove(System.label.SumofnotplannedAccounts); 
            rollingForecastCurrentYearlstSold.remove(System.label.SoldAmount); 
            rollingForecastCurrentYearlstSold.remove(System.label.PercentageChangeLabel); 
               List<Decimal> sortedValues = new List<Decimal>(rollingForecastCurrentYearlstSold.values());
               sortedValues.sort();  
            getSoldAmountFinalmap.put(System.label.SoldAmount, ForecastSoldAmountmap.get(System.label.SoldAmount));
            getSoldAmountFinalmap.put(System.label.PercentageChangeLabel, ForecastSoldAmountmap.get(System.label.PercentageChangeLabel));
            for (Integer i = sortedValues.size() - 1; i >= 0; i--) {
                Decimal sortedValue = sortedValues[i];
                for (String account : rollingForecastCurrentYearlstSold.keySet()) {
                    if (!account.equals(System.label.SoldAmount) && !account.equals(System.label.PercentageChangeLabel) && rollingForecastCurrentYearlstSold.get(account) == sortedValue) {
                        getSoldAmountFinalmap.put(account, ForecastSoldAmountmap.get(account));
                    }
                }
            }
            getSoldAmountFinalmap.put(System.label.SumofnotplannedAccounts, ForecastSoldAmountmap.get(System.label.SumofnotplannedAccounts));
            //NetProceedsSorting
            Decimal removedNetValue;
            if (rollingForecastCurrentYearlstNetProceed.get(System.label.AverageofnotplannedAccounts) != null)
             removedNetValue= rollingForecastCurrentYearlstNetProceed.get(System.label.AverageofnotplannedAccounts);
            
             rollingForecastCurrentYearlstNetProceed.remove(System.label.AverageofnotplannedAccounts);           
             List<Decimal> sortedNetValues = new List<Decimal>(rollingForecastCurrentYearlstNetProceed.values());
             sortedNetValues.sort(); 
             for (Integer i = sortedNetValues.size() - 1; i >= 0; i--) {
              Decimal sortedNetValue = sortedNetValues[i];
               for (String account : rollingForecastCurrentYearlstNetProceed.keySet()) {
                   if (rollingForecastCurrentYearlstNetProceed.get(account) == sortedNetValue) {
                        ForecastNetProceedsFinalmap.put(account, ForecastNetProceedsmap.get(account));
                   }
                }
             }
            ForecastNetProceedsFinalmap.put(System.label.AverageofnotplannedAccounts, ForecastNetProceedsmap.get(System.label.AverageofnotplannedAccounts));
            finalWrapper.getSoldAmount = getSoldAmountFinalmap.values();
            finalWrapper.ForecastNetProceeds = ForecastNetProceedsFinalmap.values();
        }
        if(sortOrder == System.label.Sorting5){
          //ActualSoldAmountSorting
            Decimal removedValue;
            if (ActuallstSold.get(System.label.SumofnotplannedAccounts) != null)
                removedValue = ActuallstSold.get(System.label.SumofnotplannedAccounts);
            
                ActuallstSold.remove(System.label.SumofnotplannedAccounts);           
               List<Decimal> sortedValues = new List<Decimal>(ActuallstSold.values());
               sortedValues.sort();
               //sortedValues.add(removedValue);  
            
            for (Decimal sortedValue : sortedValues) {
                    for (String account : ActuallstSold.keySet()) {
                        if (ActuallstSold.get(account) == sortedValue) {
                            ActualSoldAmountFinalmap.put(account, ActualSoldAmountmap.get(account));
                        }
                    }
              }
             ActualSoldAmountFinalmap.put(System.label.SumofnotplannedAccounts, ActualSoldAmountmap.get(System.label.SumofnotplannedAccounts));
         //NetProceedsSorting
            Decimal removedNetValue;
            if (ActuallstNetProceed.get(System.label.AverageofnotplannedAccounts) != null)
             removedNetValue= ActuallstNetProceed.get(System.label.AverageofnotplannedAccounts);
            
             ActuallstNetProceed.remove(System.label.AverageofnotplannedAccounts);           
             List<Decimal> sortedNetValues = new List<Decimal>(ActuallstNetProceed.values());
             sortedNetValues.sort(); 
             //sortedNetValues.add(removedNetValue); 
            
            for (Decimal sortedNetValue : sortedNetValues) {
                    for (String account : ActuallstSold.keySet()) {
                        if (ActuallstNetProceed.get(account) == sortedNetValue) {
                            ActualNetProceedsFinalmap.put(account, ActualNetProceedsmap.get(account));
                        }
                    }
              }
            ActualNetProceedsFinalmap.put(System.label.AverageofnotplannedAccounts, ActualNetProceedsmap.get(System.label.AverageofnotplannedAccounts));
            finalWrapper.getSoldAmount = ActualSoldAmountFinalmap.values();
            finalWrapper.ForecastNetProceeds = ActualNetProceedsFinalmap.values();
        }
        if(sortOrder == System.label.Sorting6){
            //ActualSoldAmountSorting
            Decimal removedValue;
            if (ActuallstSold.get(System.label.SumofnotplannedAccounts) != null)
                removedValue = ActuallstSold.get(System.label.SumofnotplannedAccounts);
            
               ActuallstSold.remove(System.label.SumofnotplannedAccounts); 
               ActuallstSold.remove(System.label.SoldAmount); 
               ActuallstSold.remove(System.label.PercentageChangeLabel);
            
               List<Decimal> sortedValues = new List<Decimal>(ActuallstSold.values());
               sortedValues.sort();
            ActualSoldAmountFinalmap.put(System.label.SoldAmount, ActualSoldAmountmap.get(System.label.SoldAmount));
            ActualSoldAmountFinalmap.put(System.label.PercentageChangeLabel, ActualSoldAmountmap.get(System.label.PercentageChangeLabel));
            for (Integer i = sortedValues.size() - 1; i >= 0; i--) {
                Decimal sortedValue = sortedValues[i];
                for (String account : ActuallstSold.keySet()) {
                    if (!account.equals(System.label.SoldAmount) && !account.equals(System.label.PercentageChangeLabel) && ActuallstSold.get(account) == sortedValue) {
                        ActualSoldAmountFinalmap.put(account, ActualSoldAmountmap.get(account));
                    }
                }
            }
            ActualSoldAmountFinalmap.put(System.label.SumofnotplannedAccounts, ActualSoldAmountmap.get(System.label.SumofnotplannedAccounts));
            //NetProceedsSorting
            Decimal removedNetValue;
            if (ActuallstNetProceed.get(System.label.AverageofnotplannedAccounts) != null)
             removedNetValue= ActuallstNetProceed.get(System.label.AverageofnotplannedAccounts);
             ActuallstNetProceed.remove(System.label.AverageofnotplannedAccounts);           
             List<Decimal> sortedNetValues = new List<Decimal>(ActuallstNetProceed.values());
             sortedNetValues.sort(); 
             //sortedNetValues.add(removedNetValue); 
            for (Integer i = sortedNetValues.size() - 1; i >= 0; i--) {
              Decimal sortedNetValue = sortedNetValues[i];
               for (String account : ActuallstNetProceed.keySet()) {
                   if (ActuallstNetProceed.get(account) == sortedNetValue) {
                        ActualNetProceedsFinalmap.put(account, ActualNetProceedsmap.get(account));
                   }
                }
             }
            ActualNetProceedsFinalmap.put(System.label.AverageofnotplannedAccounts, ActualNetProceedsmap.get(System.label.AverageofnotplannedAccounts));
            finalWrapper.getSoldAmount = ActualSoldAmountFinalmap.values();
            finalWrapper.ForecastNetProceeds = ActualNetProceedsFinalmap.values();
        }
        //sorting US- 8548 end - Harshitha
        return finalWrapper;
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to calculate the Weighted Average.
* Created Date: 24/03/2023
* Last Modified Date: 24/03/2023
****************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Decimal> netAverageCalculation(List<AccountSoldAmountawrapper> soldWrap, List<AccountSoldAmountawrapper> netWrap, Map<String, Decimal> soldTotal){
        Map<String, AccountSoldAmountawrapper> soldWrapperMap = new Map<String, AccountSoldAmountawrapper>();
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
        for(AccountSoldAmountawrapper soldLoop : soldWrap)
        {
            if(soldLoop.Account!=System.Label.SumofnotplannedAccounts)
                soldWrapperMap.put(soldLoop.accountId, soldLoop);
            else
                soldWrapperMap.put(System.URL.getSalesforceBaseURL().toExternalForm()+'/'+System.Label.AverageofnotplannedAccounts, soldLoop); 
        }
        for(AccountSoldAmountawrapper bs : netWrap){
            if(soldWrapperMap.containsKey(bs.accountId)){
                AccountSoldAmountawrapper  soldList = soldWrapperMap.get(bs.accountId);
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
    /****************************************************************************
* Author Name: Harshitha U
* Description: Wrapper Class for Table data
* Created Date: 24/03/2023
* Last Modified Date: 24/03/2023
****************************************************************************/
    public class DataTableResponse {
        @AuraEnabled
        public List<AccountSoldAmountawrapper> getSoldAmount {get;set;}
        @AuraEnabled
        public List<AccountSoldAmountawrapper> ForecastNetProceeds {get;set;}
        @AuraEnabled
        public List<AccountSoldAmountawrapper> soldCalculation {get;set;}
        @AuraEnabled
        public List<AccountSoldAmountawrapper> netProceedCalculation {get;set;}
        @AuraEnabled
        public List<AccountSoldAmountawrapper> deltacalculation {get;set;}
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to calculate and populate the monthly Forecast and Actual Values.
* Created Date: 24/03/2023
* Last Modified Date: 24/03/2023
****************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<AccountSoldAmountawrapper> getAccountwrapper(String businessArea, Map<String, Map<Date,Decimal>> AccountVsForecastMap, Map<String, Decimal> accountVsActualMap,Map<String, Decimal> accVsRollingFCurrentYr, Map<String, Map<Integer,Decimal>> NextYearVsAmt,Boolean soldAmount, Boolean soldAmountRow, List<ActualAccountWrapper> actualWrapper, Map<String, SalesPlanning__c> accountVsSpMap){
        Map<String, ActualAccountWrapper> mapActualWrapper = new Map<String, ActualAccountWrapper>();
        for(ActualAccountWrapper acWrap : actualWrapper){
            mapActualWrapper.put(acWrap.accountActualId, acWrap);
        }
        List<AccountSoldAmountawrapper> accountwrapper = new List<AccountSoldAmountawrapper>();
        AccountSoldAmountawrapper accWrapperLastRow;
        if(soldAmountRow == true){ //4263
            accountwrapper.add(new AccountSoldAmountawrapper(null,System.label.SoldAmount, null, null, null,
                                                             null, null, null,null, null, 
                                                             null, null, null, null, null, null, null,null,
                                                             null,null,null,null,null,false,false,false,false,false,true,false)); 
            accountwrapper.add(new AccountSoldAmountawrapper(businessArea, System.label.PercentageChangeLabel , null, null, null,
                                                             null, null, null,null, null, 
                                                             null, null, null, null, null, null, null,null,
                                                             null,null,null,null,null,false,false,false,false,false,false,true)); //6559 
        }
        if(soldAmount==true){
             ActualAccountWrapper actualWrapdataSP = mapActualWrapper.containsKey(System.Label.SumofnotplannedAccounts) ? mapActualWrapper.get(System.Label.SumofnotplannedAccounts):null;
            accWrapperLastRow=new AccountSoldAmountawrapper(businessArea, System.Label.SumofnotplannedAccounts, null, null, 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,actualWrapdataSP,false,false,false,false,false,false,false); //3911
        }else{
            ActualAccountWrapper actualWrapdataNP = mapActualWrapper.containsKey(System.Label.AverageofnotplannedAccounts) ? mapActualWrapper.get(System.Label.AverageofnotplannedAccounts):null;
            accWrapperLastRow=new AccountSoldAmountawrapper(businessArea, System.Label.AverageofnotplannedAccounts, null, null, 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,actualWrapdataNP,false,false,false,false,false,false,false); //3911
        }
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.year();
        for (String accdata : AccountVsForecastMap.keySet()) {
            String[] accountKey = accdata.split(CONVARIABLE);
            List<Decimal> decListMonths = new Decimal[13];
            Integer monthNumber=0;
            Map<Date, Decimal> innerMap = AccountVsForecastMap.get(accdata);
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
            }
            currentDate = Date.today();
            currentMonth = currentDate.month();
            currentYear = currentDate.year();
            Decimal actualSoldAmount = null;
            if(accountVsActualMap != null){
                actualSoldAmount = accountVsActualMap.containsKey(accountKey[0]) ? accountVsActualMap.get(accountKey[0]) : null;
            }
            //Yearly
            Date currDate = Date.today();
            Integer currYear = currDate.year();
            Map<Integer, Decimal> innerNextMap =  new Map<Integer, Decimal>();
            if(NextYearVsAmt.containsKey(accountKey[0])){
                innerNextMap = NextYearVsAmt.get(accountKey[0]);
            }
            if(accountKey[0]!='NPA'){
                ActualAccountWrapper actualWrapdata = mapActualWrapper.containsKey(accountKey[0]) ? mapActualWrapper.get(accountKey[0]):null;
                if(actualWrapdata == null){
                    actualWrapdata = new ActualAccountWrapper(accountKey[1], null, null, null, null, null, null,null, null,null, null, null, null, null);  
                }
               
                SalesPlanning__c spData = accountVsSpMap.get(accountKey[0]);
                accountwrapper.add(new AccountSoldAmountawrapper(businessArea,accountKey[1], System.URL.getSalesforceBaseURL().toExternalForm()+'/'+spData.Account__c ,spData.Account__r.SAPAccountNumber__c, actualSoldAmount, 
                                                                 decListMonths[0] != null ? Math.Round(decListMonths[0]) : null, decListMonths[1] != null ? Math.Round(decListMonths[1]) : null, decListMonths[2] != null ? Math.Round(decListMonths[2]) : null, decListMonths[3] != null ? Math.Round(decListMonths[3]) : null, 
                                                                 decListMonths[4] != null ? Math.Round(decListMonths[4]) : null, decListMonths[5] != null ? Math.Round(decListMonths[5]) : null, decListMonths[6] != null ? Math.Round(decListMonths[6]) : null, decListMonths[7] != null ?  Math.Round(decListMonths[7]): null, 
                                                                 decListMonths[8] != null ? Math.Round(decListMonths[8]) : null, decListMonths[9] != null ? Math.Round(decListMonths[9]) : null, decListMonths[10] != null ? Math.Round(decListMonths[10]) : null, decListMonths[11] != null ? Math.Round(decListMonths[11]) : null, decListMonths[12] != null ? Math.Round(decListMonths[12]) : null,
                                                                 accVsRollingFCurrentYr != null ? accVsRollingFCurrentYr.containsKey(accountKey[0]) ? accVsRollingFCurrentYr.get(accountKey[0]) : null : null,
                                                                 innerNextMap != null ? innerNextMap.containsKey(currYear+1) ? innerNextMap.get(currYear+1) != null ? Math.Round(innerNextMap.get(currYear+1)) : null : null : null,
                                                                 innerNextMap != null ? innerNextMap.containsKey(currYear+2) ? innerNextMap.get(currYear+2) != null ? Math.Round(innerNextMap.get(currYear+2)) : null : null : null,
                                                                 innerNextMap != null ? innerNextMap.containsKey(currYear+3) ? innerNextMap.get(currYear+3) != null ? Math.Round(innerNextMap.get(currYear+3)) : null : null : null, 
                                                                 actualWrapdata,false,false,false,false,false,false,false));//3911
                
            }
            else if(accountKey[0]=='NPA'){
                accWrapperLastRow.Account= accountKey[1];
                accWrapperLastRow.accountId = System.URL.getSalesforceBaseURL().toExternalForm()+'/'+accountKey[1];
                accWrapperLastRow.ActualSoldAmount= actualSoldAmount != null ? Math.Round(actualSoldAmount) : null;
                accWrapperLastRow.currentFSoldAmount= decListMonths[0] != null ? Math.Round(decListMonths[0]) : null;
                accWrapperLastRow.current1FSoldAmount= decListMonths[1] != null ? Math.Round(decListMonths[1]) : null;
                accWrapperLastRow.current2FSoldAmount= decListMonths[2] != null ? Math.Round(decListMonths[2]) : null;
                accWrapperLastRow.current3FSoldAmount= decListMonths[3] != null ? Math.Round(decListMonths[3]) : null;
                accWrapperLastRow.current4FSoldAmount= decListMonths[4] != null ? Math.Round(decListMonths[4]) : null;
                accWrapperLastRow.current5FSoldAmount= decListMonths[5] != null ? Math.Round(decListMonths[5]) : null;
                accWrapperLastRow.current6FSoldAmount= decListMonths[6] != null ? Math.Round(decListMonths[6]) : null;
                accWrapperLastRow.current7FSoldAmount= decListMonths[7] != null ? Math.Round(decListMonths[7]) : null;
                accWrapperLastRow.current8FSoldAmount= decListMonths[8] != null ? Math.Round(decListMonths[8]) : null;
                accWrapperLastRow.current9FSoldAmount= decListMonths[9] != null ? Math.Round(decListMonths[9]) : null;
                accWrapperLastRow.current10FSoldAmount= decListMonths[10] != null ? Math.Round(decListMonths[10]) : null;
                accWrapperLastRow.current11FSoldAmount= decListMonths[11] != null ? Math.Round(decListMonths[11]) : null;
                accWrapperLastRow.current12FSoldAmount= decListMonths[12] != null ? Math.Round(decListMonths[12]) : null;
                accWrapperLastRow.rollingForecastCurrentYear= accVsRollingFCurrentYr != null ? accVsRollingFCurrentYr.containsKey(accountKey[0]) ? accVsRollingFCurrentYr.get(accountKey[0]) : null : null;
                accWrapperLastRow.yearlySoldAmount= innerNextMap != null ? innerNextMap.containsKey(currYear+1) ? innerNextMap.get(currYear+1) != null ? Math.Round(innerNextMap.get(currYear+1)) : null : null : null;
                accWrapperLastRow.yearly1SoldAmount= innerNextMap != null ? innerNextMap.containsKey(currYear+2) ? innerNextMap.get(currYear+2) != null ? Math.Round(innerNextMap.get(currYear+2)) : null : null : null;
                accWrapperLastRow.yearly2SoldAmount= innerNextMap != null ? innerNextMap.containsKey(currYear+3) ? innerNextMap.get(currYear+3) != null? Math.Round(innerNextMap.get(currYear+3)) : null : null : null;  
                //accWrapperLastRow.actualWrapper = mapActualWrapper.containsKey(accountKey[1]) ? mapActualWrapper.get(accountKey[1]):null;
            }
            
        }
        accountwrapper.add(accWrapperLastRow);   
        return accountwrapper;
    }
    
    public static Map<String, Decimal> soldCalculation(List<AccountSoldAmountawrapper> accSoldWrap){
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
        for(AccountSoldAmountawrapper acc : accSoldWrap){
            actualSoldAmount.add(acc.ActualSoldAmount); //4112
            currentFSoldAmount.add(acc.currentFSoldAmount);
            current1FSoldAmount.add(acc.current1FSoldAmount);
            current2FSoldAmount.add(acc.current2FSoldAmount);
            current3FSoldAmount.add(acc.current3FSoldAmount);
            current4FSoldAmount.add(acc.current4FSoldAmount);
            current5FSoldAmount.add(acc.current5FSoldAmount);
            current6FSoldAmount.add(acc.current6FSoldAmount);
            current7FSoldAmount.add(acc.current7FSoldAmount);
            current8FSoldAmount.add(acc.current8FSoldAmount);
            current9FSoldAmount.add(acc.current9FSoldAmount);
            current10FSoldAmount.add(acc.current10FSoldAmount);
            current11FSoldAmount.add(acc.current11FSoldAmount);
            current12FSoldAmount.add(acc.current12FSoldAmount);
            rollingForecastCurrentYear.add(acc.rollingForecastCurrentYear);
            yearlySoldAmount.add(acc.yearlySoldAmount);
            yearly1SoldAmount.add(acc.yearly1SoldAmount);
            yearly2SoldAmount.add(acc.yearly2SoldAmount);
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
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to update the values on save from the table.
* Created Date: 24/03/2023
* Last Modified Date: 24/03/2023
****************************************************************************/
    @AuraEnabled
    public static String upsertSPForecaste(String newAccSoldWrapper, String newAccNetWrapper,String bussinessArea){
        DataTableResponse dataresponse = showtabledata(bussinessArea,'');
        List<AccountSoldAmountawrapper> wrapperSoldDataList = (List<AccountSoldAmountawrapper>) JSON.deserialize(newAccSoldWrapper, List<AccountSoldAmountawrapper>.class);
        List<AccountSoldAmountawrapper> oldWrapperSoldDataList = new  List<AccountSoldAmountawrapper>();
        List<AccountSoldAmountawrapper> wrapperNetDataList = (List<AccountSoldAmountawrapper>) JSON.deserialize(newAccNetWrapper, List<AccountSoldAmountawrapper>.class);
        List<AccountSoldAmountawrapper> oldWrapperNetDataList = new  List<AccountSoldAmountawrapper>(); 
        oldWrapperSoldDataList = dataresponse.getSoldAmount;
        oldWrapperNetDataList = dataresponse.ForecastNetProceeds;
        Map<String, Map<String, Decimal>> oldaccVsSoldAmount  = oldaccVsAmount(oldWrapperSoldDataList);
        Map<String, Map<String, Decimal>> oldaccVsNetAmount  = oldaccVsAmount(oldWrapperNetDataList);
        Map<String,SalesPlanning__c> recordInUpdate = new Map<String,SalesPlanning__c>();
        Map<String, Map<String, SalesPlanning__c>> recordToCreate = new  Map<String, Map<String, SalesPlanning__c>>();
        List<SalesPlanning__c> salesPlanningList = new List<SalesPlanning__c>(); //4726
        Savepoint sp;
        try{
            sp = Database.setSavepoint();
            Date currentDate = Date.today();
            Integer currentMonth = currentDate.month();
            Integer currentYear = currentDate.year();
            Map<String, SalesPlanning__c> dateVsSalesPlann = new Map<String, SalesPlanning__c>();
            Map<String, SalesPlanning__c> YearVsSalesPlann = new Map<String, SalesPlanning__c>();
            Map<String, SalesPlanning__c> idVsSalesPlann = new Map<String, SalesPlanning__c>();
            for(SalesPlanning__c s : [SELECT Id, Account__c,Account__r.Name, Account__r.SAPAccountNumber__c, BusinessArea__c, Frequency__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                      FROM SalesPlanning__c WHERE ForecastLevel__c ='Account' 
                                      AND BusinessArea__c=:bussinessArea AND Frequency__c ='Yearly' ORDER By ForecastTimePoint__c ASC]){
                                          Integer yearss = s.ForecastTimePoint__c.year();
                                          if(yearss > currentYear && yearss <= currentYear + 3){
                                              if(s.Account__c != null){
                                                  YearVsSalesPlann.put(yearss+s.Account__r.Name+CONVARIABLE+s.Account__c,s);  //5411
                                              }else{
                                                  YearVsSalesPlann.put(yearss+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts, s);
                                                  YearVsSalesPlann.put(yearss+System.Label.AverageofnotplannedAccounts+CONVARIABLE+System.Label.AverageofnotplannedAccounts, s);
                                              }
                                          }
                                          
                                      }
            for(SalesPlanning__c ss : [SELECT Id, Account__c, Account__r.Name, Account__r.SAPAccountNumber__c, BusinessArea__c, Frequency__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                       FROM SalesPlanning__c WHERE ForecastLevel__c ='Account' AND 
                                       ForecastTimePoint__c > LAST_MONTH  AND ForecastTimePoint__c <= NEXT_N_MONTHS:12 AND BusinessArea__c=:bussinessArea AND Frequency__c ='Monthly' ORDER By ForecastTimePoint__c ASC]){
                                           Integer monthss = ss.ForecastTimePoint__c.month();
                                           Integer yearss = ss.ForecastTimePoint__c.year();
                                           Integer monInt = 0;
                                           if(yearss == currentYear){
                                               monInt = monthss - currentMonth;
                                           }
                                           else if(yearss > currentYear){
                                               monInt = 12-currentMonth +monthss;
                                           }
                                           if(ss.Account__c != null){
                                               dateVsSalesPlann.put('current'+monInt+'FSoldAmount'+ss.Account__r.Name+CONVARIABLE+ss.Account__c,ss); //5411
                                           }else{
                                               dateVsSalesPlann.put('current'+monInt+'FSoldAmount'+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts, ss);  
                                               dateVsSalesPlann.put('current'+monInt+'FSoldAmount'+System.Label.AverageofnotplannedAccounts+CONVARIABLE+System.Label.AverageofnotplannedAccounts, ss);
                                           }
                                           idVsSalesPlann.put(ss.Id, ss); //6559
                                       }
            Map<String, Date> CurrentYearVsDate = SalesForecastingController.getDateAccCurrMonth(); 
            UpdateTableResponse newMapBAVsSOLDAmount = compareNewOldSoldRecord(oldaccVsSoldAmount, wrapperSoldDataList,  dateVsSalesPlann, CurrentYearVsDate ,bussinessArea,YearVsSalesPlann);
            
            recordInUpdate = newMapBAVsSOLDAmount.wrapperMapToUpdate;            
            recordToCreate = newMapBAVsSOLDAmount.wrapperMapToCreate;
            //6559
            UpdateTableResponse newPercentageSOLDAmount = AccountSalesPlanningHelper.calPercentageChange(recordToCreate, recordInUpdate, wrapperSoldDataList, idVsSalesPlann);
            recordInUpdate = newPercentageSOLDAmount.wrapperMapToUpdate;            
            recordToCreate = newPercentageSOLDAmount.wrapperMapToCreate;
            
            UpdateTableResponse newMapBAVsNETAmount = compareNewOldNetRecord(recordToCreate, recordInUpdate, oldaccVsNetAmount, wrapperNetDataList, dateVsSalesPlann, CurrentYearVsDate,bussinessArea,YearVsSalesPlann);
            recordInUpdate = newMapBAVsNETAmount.wrapperMapToUpdate;
            recordToCreate = newMapBAVsNETAmount.wrapperMapToCreate;
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
            if(recordInUpdate != null && !recordInUpdate.isEmpty()){
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
    
    
    public static Map<String, Map<String, Decimal>> oldaccVsAmount(List<AccountSoldAmountawrapper> oldWrapperSoldDataList){
        Map<String, Map<String, Decimal>> oldAccVsForecastAmount  = new Map<String, Map<String, Decimal>>();
        for(AccountSoldAmountawrapper salesPlanloop : oldWrapperSoldDataList){
            String accId;
            if(salesPlanloop.accountId != null){
                String[] accIdArray = salesPlanloop.accountId.split(System.URL.getSalesforceBaseURL().toExternalForm()+'/');
                accId = accIdArray[1];
            }else{
                if(salesPlanloop.Account == System.Label.SumofnotplannedAccounts){
                    accId = System.Label.SumofnotplannedAccounts; 
                }else if(salesPlanloop.Account == System.Label.AverageofnotplannedAccounts){
                    accId = System.Label.AverageofnotplannedAccounts; 
                }
            } 
            if(accId != null){
                if (!oldAccVsForecastAmount.containsKey(salesPlanloop.Account+CONVARIABLE+accId)) { //5411
                    oldAccVsForecastAmount.put(salesPlanloop.Account+CONVARIABLE+accId, new Map<String, Decimal>());
                }
                Map<String, Decimal> innerMap = oldAccVsForecastAmount.get(salesPlanloop.Account+CONVARIABLE+accId); //5411
                innerMap.put('currentFSoldAmount', salesPlanloop.currentFSoldAmount); //4023
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
                innerMap.put('yearlySoldAmount', salesPlanloop.yearlySoldAmount);
                innerMap.put('yearly1SoldAmount', salesPlanloop.yearly1SoldAmount);
                innerMap.put('yearly2SoldAmount', salesPlanloop.yearly2SoldAmount); 
            }
        }
        return oldAccVsForecastAmount;
    }
    
    public static UpdateTableResponse compareNewOldSoldRecord(Map<String, Map<String, Decimal>> oldBussVsSoldAmount, List<AccountSoldAmountawrapper> wrapperSoldDataList, Map<String, SalesPlanning__c> dateVsSalesPlann, Map<String, Date> CurrentYearVsDate,String bussinessArea, Map<String, SalesPlanning__c> YearVsSalesPlann){
        Map<String,Map<String, SalesPlanning__c>> salesPlanMapToCreate = new Map<String,Map<String, SalesPlanning__c>>();
        Map<String, SalesPlanning__c> salesPlanMapToUpdate = new Map<String, SalesPlanning__c>();
        Map<String, Map<String, SalesPlanning__c>> mapToListInsert = new Map<String, Map<String, SalesPlanning__c>>();
        Map<String, SalesPlanning__c> mapToUpdate = new Map<String, SalesPlanning__c>();
        SalesPlanning__c salesPlanUpdate = new SalesPlanning__c();
        for(AccountSoldAmountawrapper newLoop : wrapperSoldDataList){ 
            if(!newLoop.isPerRow){
                String accId;
                if(newLoop.accountId != null){
                    String[] accIdArray = newLoop.accountId.split(System.URL.getSalesforceBaseURL().toExternalForm()+'/');
                    accId = accIdArray[1];
                }else{
                    accId = System.Label.SumofnotplannedAccounts; 
                }
                if(oldBussVsSoldAmount.containsKey(newLoop.Account+CONVARIABLE+accId)){ //5411
                    Map<String, Decimal> innerMap = oldBussVsSoldAmount.get(newLoop.Account+CONVARIABLE+accId);
                    if(newLoop.current1FSoldAmount != null && innerMap.get('current1FSoldAmount') != newLoop.current1FSoldAmount){
                        if(dateVsSalesPlann.keySet().contains('current1FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                            salesPlanUpdate = dateVsSalesPlann.get('current1FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                            salesPlanUpdate.ForecastSoldAmount__c = newLoop.current1FSoldAmount;
                            salesPlanUpdate.Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null;
                            salesPlanMapToUpdate.put(salesPlanUpdate.Id,salesPlanUpdate);
                        }
                        else{
                            if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            Date fTp = CurrentYearVsDate.containsKey('current1FSoldAmount') ? CurrentYearVsDate.get('current1FSoldAmount') : null;
                            salesPlanMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current1FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current1FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                        }
                    }
                    if(newLoop.current2FSoldAmount != null && innerMap.get('current2FSoldAmount') != newLoop.current2FSoldAmount){
                        if(dateVsSalesPlann.keySet().contains('current2FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                            salesPlanUpdate = dateVsSalesPlann.get('current2FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                            salesPlanUpdate.ForecastSoldAmount__c = newLoop.current2FSoldAmount;
                            salesPlanUpdate.Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null;
                            salesPlanMapToUpdate.put(salesPlanUpdate.Id,salesPlanUpdate);
                        }
                        else{
                            if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            Date fTp = CurrentYearVsDate.containsKey('current2FSoldAmount') ? CurrentYearVsDate.get('current2FSoldAmount') : null;
                            salesPlanMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current2FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current2FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                        }
                    }
                    if(newLoop.current3FSoldAmount != null && innerMap.get('current3FSoldAmount') != newLoop.current3FSoldAmount){
                        if(dateVsSalesPlann.keySet().contains('current3FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                            salesPlanUpdate = dateVsSalesPlann.get('current3FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                            salesPlanUpdate.ForecastSoldAmount__c = newLoop.current3FSoldAmount;
                            salesPlanUpdate.Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null;
                            salesPlanMapToUpdate.put(salesPlanUpdate.Id,salesPlanUpdate);
                        }
                        else{
                            if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            Date fTp = CurrentYearVsDate.containsKey('current3FSoldAmount') ? CurrentYearVsDate.get('current3FSoldAmount') : null;
                            salesPlanMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current3FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current3FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                        }
                    }
                    if(newLoop.current4FSoldAmount != null && innerMap.get('current4FSoldAmount') != newLoop.current4FSoldAmount){
                        if(dateVsSalesPlann.keySet().contains('current4FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                            salesPlanUpdate = dateVsSalesPlann.get('current4FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                            salesPlanUpdate.ForecastSoldAmount__c = newLoop.current4FSoldAmount;
                            salesPlanUpdate.Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null;
                            salesPlanMapToUpdate.put(salesPlanUpdate.Id,salesPlanUpdate);
                        }
                        else{
                            if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            Date fTp = CurrentYearVsDate.containsKey('current4FSoldAmount') ? CurrentYearVsDate.get('current4FSoldAmount') : null;
                            salesPlanMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current4FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current4FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                        }
                    }
                    if(newLoop.current5FSoldAmount != null && innerMap.get('current5FSoldAmount') != newLoop.current5FSoldAmount){
                        if(dateVsSalesPlann.keySet().contains('current5FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                            salesPlanUpdate = dateVsSalesPlann.get('current5FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                            salesPlanUpdate.ForecastSoldAmount__c = newLoop.current5FSoldAmount;
                            salesPlanUpdate.Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null;
                            salesPlanMapToUpdate.put(salesPlanUpdate.Id,salesPlanUpdate);
                        }
                        else{
                            if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            Date fTp = CurrentYearVsDate.containsKey('current5FSoldAmount') ? CurrentYearVsDate.get('current5FSoldAmount') : null;
                            salesPlanMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current5FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current5FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                        }
                    }
                    if(newLoop.current6FSoldAmount != null && innerMap.get('current6FSoldAmount') != newLoop.current6FSoldAmount){
                        if(dateVsSalesPlann.keySet().contains('current6FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                            salesPlanUpdate = dateVsSalesPlann.get('current6FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                            salesPlanUpdate.ForecastSoldAmount__c = newLoop.current6FSoldAmount;
                            salesPlanUpdate.Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null;
                            salesPlanMapToUpdate.put(salesPlanUpdate.Id,salesPlanUpdate);
                        }
                        else{
                            if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            Date fTp = CurrentYearVsDate.containsKey('current6FSoldAmount') ? CurrentYearVsDate.get('current6FSoldAmount') : null;
                            salesPlanMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current6FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current6FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                        }
                    }
                    if(newLoop.current7FSoldAmount != null && innerMap.get('current7FSoldAmount') != newLoop.current7FSoldAmount){
                        if(dateVsSalesPlann.keySet().contains('current7FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                            salesPlanUpdate = dateVsSalesPlann.get('current7FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                            salesPlanUpdate.ForecastSoldAmount__c = newLoop.current7FSoldAmount;
                            salesPlanUpdate.Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null;
                            salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                        }
                        else{
                            if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            Date fTp = CurrentYearVsDate.containsKey('current7FSoldAmount') ? CurrentYearVsDate.get('current7FSoldAmount') : null;
                            salesPlanMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current7FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current7FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                        }
                    }
                    if(newLoop.current8FSoldAmount != null && innerMap.get('current8FSoldAmount') != newLoop.current8FSoldAmount){
                        if(dateVsSalesPlann.keySet().contains('current8FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                            salesPlanUpdate = dateVsSalesPlann.get('current8FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                            salesPlanUpdate.ForecastSoldAmount__c = newLoop.current8FSoldAmount;
                            salesPlanUpdate.Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null;
                            salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                        }
                        else{
                            if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            Date fTp = CurrentYearVsDate.containsKey('current8FSoldAmount') ? CurrentYearVsDate.get('current8FSoldAmount') : null;
                            salesPlanMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current8FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current8FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                        }
                    }
                    if(newLoop.current9FSoldAmount != null && innerMap.get('current9FSoldAmount') != newLoop.current9FSoldAmount){
                        if(dateVsSalesPlann.keySet().contains('current9FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                            salesPlanUpdate = dateVsSalesPlann.get('current9FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                            salesPlanUpdate.ForecastSoldAmount__c = newLoop.current9FSoldAmount;
                            salesPlanUpdate.Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null;
                            salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                        }
                        else{
                            if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            Date fTp = CurrentYearVsDate.containsKey('current9FSoldAmount') ? CurrentYearVsDate.get('current9FSoldAmount') : null;
                            salesPlanMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current9FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current9FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                        }
                    }
                    if(newLoop.current10FSoldAmount != null && innerMap.get('current10FSoldAmount') != newLoop.current10FSoldAmount){
                        if(dateVsSalesPlann.keySet().contains('current10FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                            salesPlanUpdate = dateVsSalesPlann.get('current10FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                            salesPlanUpdate.ForecastSoldAmount__c = newLoop.current10FSoldAmount;
                            salesPlanUpdate.Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null;
                            salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                        }
                        else{
                            if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            Date fTp = CurrentYearVsDate.containsKey('current10FSoldAmount') ? CurrentYearVsDate.get('current10FSoldAmount') : null;
                            salesPlanMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current10FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current10FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                        }
                    }
                    if(newLoop.current11FSoldAmount != null && innerMap.get('current11FSoldAmount') != newLoop.current11FSoldAmount){
                        if(dateVsSalesPlann.keySet().contains('current11FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                            salesPlanUpdate = dateVsSalesPlann.get('current11FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                            salesPlanUpdate.ForecastSoldAmount__c = newLoop.current11FSoldAmount;
                            salesPlanUpdate.Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null;
                            salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                        }
                        else{
                            if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            Date fTp = CurrentYearVsDate.containsKey('current11FSoldAmount') ? CurrentYearVsDate.get('current11FSoldAmount') : null;
                            salesPlanMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current11FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current11FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                        }
                    }
                    if(newLoop.current12FSoldAmount != null && innerMap.get('current12FSoldAmount') != newLoop.current12FSoldAmount){
                        if(dateVsSalesPlann.keySet().contains('current12FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                            salesPlanUpdate = dateVsSalesPlann.get('current12FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                            salesPlanUpdate.ForecastSoldAmount__c = newLoop.current12FSoldAmount;
                            salesPlanUpdate.Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null;
                            salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                        }
                        else{
                            if(!salesPlanMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            Date fTp = CurrentYearVsDate.containsKey('current12FSoldAmount' ) ? CurrentYearVsDate.get('current12FSoldAmount') : null;
                            salesPlanMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current12FSoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.current12FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                        }
                    }
                    Date currentDate = Date.today();
                    Integer currentYear = currentDate.year();
                    if(newLoop.yearlySoldAmount != null && innerMap.get('yearlySoldAmount') != newLoop.yearlySoldAmount){
                        Integer year = currentYear+1;
                        if(YearVsSalesPlann.keySet().contains(year+newLoop.Account+CONVARIABLE+accId)){ 
                            salesPlanUpdate = YearVsSalesPlann.get(year+newLoop.Account+CONVARIABLE+accId);
                            salesPlanUpdate.ForecastSoldAmount__c = newLoop.yearlySoldAmount;
                            salesPlanUpdate.Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null;
                            salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                        }
                        else{
                            if(!salesPlanMapToCreate.containsKey(year+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanMapToCreate.put(year+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            Date fTp = Date.newInstance(year, 1, 1);
                            salesPlanMapToCreate.get(year+newLoop.Account+CONVARIABLE+accId).put('yearlySoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.yearlySoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Yearly'));
                        }
                    }
                    if(newLoop.yearly1SoldAmount != null && innerMap.get('yearly1SoldAmount') != newLoop.yearly1SoldAmount){
                        Integer year1 = currentYear+2;
                        if(YearVsSalesPlann.keySet().contains(year1+newLoop.Account+CONVARIABLE+accId)){ 
                            salesPlanUpdate = YearVsSalesPlann.get(year1+newLoop.Account+CONVARIABLE+accId);
                            salesPlanUpdate.ForecastSoldAmount__c = newLoop.yearly1SoldAmount;
                            salesPlanUpdate.Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null;
                            salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                        }
                        else{
                            if(!salesPlanMapToCreate.containsKey(year1+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanMapToCreate.put(year1+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            Date fTp = Date.newInstance(year1, 1, 1);
                            salesPlanMapToCreate.get(year1+newLoop.Account+CONVARIABLE+accId).put('yearly1SoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.yearly1SoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Yearly'));
                        }
                    }
                    if(newLoop.yearly2SoldAmount != null && innerMap.get('yearly2SoldAmount') != newLoop.yearly2SoldAmount){
                        Integer year2 = currentYear+3;
                        if(YearVsSalesPlann.keySet().contains(year2+newLoop.Account+CONVARIABLE+accId)){ 
                            salesPlanUpdate = YearVsSalesPlann.get(year2+newLoop.Account+CONVARIABLE+accId);
                            salesPlanUpdate.ForecastSoldAmount__c = newLoop.yearly2SoldAmount;
                            salesPlanUpdate.Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null;
                            salesPlanMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                        }
                        else{
                            if(!salesPlanMapToCreate.containsKey(year2+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanMapToCreate.put(year2+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            Date fTp = Date.newInstance(year2, 1, 1);
                            salesPlanMapToCreate.get(year2+newLoop.Account+CONVARIABLE+accId).put('yearly2SoldAmount', new SalesPlanning__c(ForecastSoldAmount__c = newLoop.yearly2SoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.SumofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Yearly'));
                        }
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
    
    public static UpdateTableResponse compareNewOldNetRecord(Map<String, Map<String, SalesPlanning__c>> recordInCreate, Map<String,SalesPlanning__c> recordInUpdate, Map<String, Map<String, Decimal>> oldBussVsSoldAmount, List<AccountSoldAmountawrapper> wrapperSoldDataList, Map<String, SalesPlanning__c> dateVsSalesPlann, Map<String, Date> CurrentYearVsDate,String bussinessArea, Map<String, SalesPlanning__c> YearVsSalesPlann){
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
        for(AccountSoldAmountawrapper newLoop : wrapperSoldDataList){
            String accId;
            if(newLoop.accountId != null){
                String[] accIdArray = newLoop.accountId.split(System.URL.getSalesforceBaseURL().toExternalForm()+'/');
                accId = accIdArray[1];
            }else{
                accId = System.Label.AverageofnotplannedAccounts;
            }
            if(oldBussVsSoldAmount.containsKey(newLoop.Account+CONVARIABLE+accId)){
                Map<String, Decimal> innerMap = oldBussVsSoldAmount.get(newLoop.Account+CONVARIABLE+accId);
                if(newLoop.current1FSoldAmount != null && innerMap.get('current1FSoldAmount') != newLoop.current1FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current1FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                        salesPlanUpdate = dateVsSalesPlann.get('current1FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id); 
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current1FSoldAmount;
                        salesPlanUpdate.Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null;
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(salesPlanListMapToCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) &&
                           recordInCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) &&
                           recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).containsKey('current1FSoldAmount') && 
                           recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).get('current1FSoldAmount').Account__c == null && 
                           newLoop.Account == System.Label.AverageofnotplannedAccounts){
                               salesPlanCreateMap = recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts);
                               salesPlanCreate = salesPlanCreateMap.get('current1FSoldAmount');
                               salesPlanCreate.ForecastNetProceeds__c = newLoop.current1FSoldAmount; 
                               salesPlanListMapToCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).put('current1FSoldAmount', salesPlanCreate);
                           }else{
                               if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanListMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                               }
                               if(recordInCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId);
                                   salesPlanCreate = salesPlanCreateMap.get('current1FSoldAmount');
                                   salesPlanCreate.ForecastNetProceeds__c = newLoop.current1FSoldAmount; 
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current1FSoldAmount', salesPlanCreate);
                               }
                               else{
                                   Date fTp = CurrentYearVsDate.containsKey('current1FSoldAmount') ? CurrentYearVsDate.get('current1FSoldAmount') : null;
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current1FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current1FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                               }
                           }
                    }
                }
                if(newLoop.current2FSoldAmount != null && innerMap.get('current2FSoldAmount') != newLoop.current2FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current2FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                        salesPlanUpdate = dateVsSalesPlann.get('current2FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current2FSoldAmount;
                        salesPlanUpdate.Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null;
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(salesPlanListMapToCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) &&
                           recordInCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) && recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).containsKey('current2FSoldAmount') && 
                           recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).get('current2FSoldAmount').Account__c == null && newLoop.Account == System.Label.AverageofnotplannedAccounts){
                               salesPlanCreateMap = recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts);
                               salesPlanCreate = salesPlanCreateMap.get('current2FSoldAmount');
                               salesPlanCreate.ForecastNetProceeds__c = newLoop.current2FSoldAmount; 
                               salesPlanListMapToCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).put('current2FSoldAmount', salesPlanCreate);
                           }else{
                               if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanListMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                               }
                               if(recordInCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId);
                                   salesPlanCreate = salesPlanCreateMap.get('current2FSoldAmount');
                                   salesPlanCreate.ForecastNetProceeds__c = newLoop.current2FSoldAmount; 
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current2FSoldAmount', salesPlanCreate);
                               }
                               else{
                                   Date fTp = CurrentYearVsDate.containsKey('current2FSoldAmount') ? CurrentYearVsDate.get('current2FSoldAmount') : null;
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current2FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current2FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                               }
                           }
                    }
                }
                if(newLoop.current3FSoldAmount != null && innerMap.get('current3FSoldAmount') != newLoop.current3FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current3FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                        salesPlanUpdate = dateVsSalesPlann.get('current3FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current3FSoldAmount;
                        salesPlanUpdate.Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null;
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(salesPlanListMapToCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) &&
                           recordInCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) && recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).containsKey('current3FSoldAmount') && 
                           recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).get('current3FSoldAmount').Account__c == null && newLoop.Account == System.Label.AverageofnotplannedAccounts){
                               salesPlanCreateMap = recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts);
                               salesPlanCreate = salesPlanCreateMap.get('current3FSoldAmount');
                               salesPlanCreate.ForecastNetProceeds__c = newLoop.current3FSoldAmount; 
                               salesPlanListMapToCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).put('current3FSoldAmount', salesPlanCreate);
                           }else{
                               if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanListMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                               }
                               if(recordInCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId);
                                   salesPlanCreate = salesPlanCreateMap.get('current3FSoldAmount');
                                   salesPlanCreate.ForecastNetProceeds__c = newLoop.current3FSoldAmount; 
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current3FSoldAmount', salesPlanCreate);
                               }
                               else{
                                   Date fTp = CurrentYearVsDate.containsKey('current3FSoldAmount') ? CurrentYearVsDate.get('current3FSoldAmount') : null;
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current3FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current3FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                               }
                           }
                    }
                }
                if(newLoop.current4FSoldAmount != null && innerMap.get('current4FSoldAmount') != newLoop.current4FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current4FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                        salesPlanUpdate = dateVsSalesPlann.get('current4FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current4FSoldAmount;
                        salesPlanUpdate.Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null;
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(salesPlanListMapToCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) &&
                           recordInCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) && recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).containsKey('current4FSoldAmount') && 
                           recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).get('current4FSoldAmount').Account__c == null && newLoop.Account == System.Label.AverageofnotplannedAccounts){
                               salesPlanCreateMap = recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts);
                               salesPlanCreate = salesPlanCreateMap.get('current4FSoldAmount');
                               salesPlanCreate.ForecastNetProceeds__c = newLoop.current4FSoldAmount; 
                               salesPlanListMapToCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).put('current4FSoldAmount', salesPlanCreate);
                           }else{
                               if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanListMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                               }
                               if(recordInCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId);
                                   salesPlanCreate = salesPlanCreateMap.get('current4FSoldAmount');
                                   salesPlanCreate.ForecastNetProceeds__c = newLoop.current4FSoldAmount; 
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current4FSoldAmount', salesPlanCreate);
                               }
                               else{
                                   Date fTp = CurrentYearVsDate.containsKey('current4FSoldAmount') ? CurrentYearVsDate.get('current4FSoldAmount') : null;
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current4FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current4FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                               }
                           }
                    }
                }
                if(newLoop.current5FSoldAmount != null && innerMap.get('current5FSoldAmount') != newLoop.current5FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current5FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                        salesPlanUpdate = dateVsSalesPlann.get('current5FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current5FSoldAmount;
                        salesPlanUpdate.Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null;
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(salesPlanListMapToCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) &&
                           recordInCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) && recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).containsKey('current5FSoldAmount') && 
                           recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).get('current5FSoldAmount').Account__c == null && newLoop.Account == System.Label.AverageofnotplannedAccounts){
                               salesPlanCreateMap = recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts);
                               salesPlanCreate = salesPlanCreateMap.get('current5FSoldAmount');
                               salesPlanCreate.ForecastNetProceeds__c = newLoop.current5FSoldAmount; 
                               salesPlanListMapToCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).put('current5FSoldAmount', salesPlanCreate);
                           }else{
                               if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanListMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                               }
                               if(recordInCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId);
                                   salesPlanCreate = salesPlanCreateMap.get('current5FSoldAmount');
                                   salesPlanCreate.ForecastNetProceeds__c = newLoop.current5FSoldAmount; 
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current5FSoldAmount', salesPlanCreate);
                               }
                               else{
                                   Date fTp = CurrentYearVsDate.containsKey('current5FSoldAmount') ? CurrentYearVsDate.get('current5FSoldAmount') : null;
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current5FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current5FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                               }
                           }
                    }
                }
                if(newLoop.current6FSoldAmount != null && innerMap.get('current6FSoldAmount') != newLoop.current6FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current6FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                        salesPlanUpdate = dateVsSalesPlann.get('current6FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current6FSoldAmount;
                        salesPlanUpdate.Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null;
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(salesPlanListMapToCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) &&
                           recordInCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) && recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).containsKey('current6FSoldAmount') && 
                           recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).get('current6FSoldAmount').Account__c == null && newLoop.Account == System.Label.AverageofnotplannedAccounts){
                               salesPlanCreateMap = recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts);
                               salesPlanCreate = salesPlanCreateMap.get('current6FSoldAmount');
                               salesPlanCreate.ForecastNetProceeds__c = newLoop.current6FSoldAmount; 
                               salesPlanListMapToCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).put('current6FSoldAmount', salesPlanCreate);
                           }else{
                               if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanListMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                               }
                               if(recordInCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId);
                                   salesPlanCreate = salesPlanCreateMap.get('current6FSoldAmount');
                                   salesPlanCreate.ForecastNetProceeds__c = newLoop.current6FSoldAmount; 
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current6FSoldAmount', salesPlanCreate);
                               }
                               else{
                                   Date fTp = CurrentYearVsDate.containsKey('current6FSoldAmount') ? CurrentYearVsDate.get('current6FSoldAmount') : null;
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current6FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current6FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                               }
                           }
                    }
                }
                if(newLoop.current7FSoldAmount != null && innerMap.get('current7FSoldAmount') != newLoop.current7FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current7FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                        salesPlanUpdate = dateVsSalesPlann.get('current7FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current7FSoldAmount;
                        salesPlanUpdate.Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null;
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(salesPlanListMapToCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) &&
                           recordInCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) && recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).containsKey('current7FSoldAmount') && 
                           recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).get('current7FSoldAmount').Account__c == null && newLoop.Account == System.Label.AverageofnotplannedAccounts){
                               salesPlanCreateMap = recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts);
                               salesPlanCreate = salesPlanCreateMap.get('current7FSoldAmount');
                               salesPlanCreate.ForecastNetProceeds__c = newLoop.current7FSoldAmount; 
                               salesPlanListMapToCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).put('current7FSoldAmount', salesPlanCreate);
                           }else{
                               if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanListMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                               }
                               if(recordInCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId);
                                   salesPlanCreate = salesPlanCreateMap.get('current7FSoldAmount');
                                   salesPlanCreate.ForecastNetProceeds__c = newLoop.current7FSoldAmount; 
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current7FSoldAmount', salesPlanCreate);
                               }
                               else{
                                   Date fTp = CurrentYearVsDate.containsKey('current7FSoldAmount') ? CurrentYearVsDate.get('current7FSoldAmount') : null;
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current7FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current7FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                               }
                           }
                    }
                }
                if(newLoop.current8FSoldAmount != null && innerMap.get('current8FSoldAmount') != newLoop.current8FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current8FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                        salesPlanUpdate = dateVsSalesPlann.get('current8FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current8FSoldAmount;
                        salesPlanUpdate.Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null;
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(salesPlanListMapToCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) &&
                           recordInCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) && recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).containsKey('current8FSoldAmount') && 
                           recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).get('current8FSoldAmount').Account__c == null && newLoop.Account == System.Label.AverageofnotplannedAccounts){
                               salesPlanCreateMap = recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts);
                               salesPlanCreate = salesPlanCreateMap.get('current8FSoldAmount');
                               salesPlanCreate.ForecastNetProceeds__c = newLoop.current8FSoldAmount; 
                               salesPlanListMapToCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).put('current8FSoldAmount', salesPlanCreate);
                           }else{
                               if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanListMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                               }
                               if(recordInCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId);
                                   salesPlanCreate = salesPlanCreateMap.get('current8FSoldAmount');
                                   salesPlanCreate.ForecastNetProceeds__c = newLoop.current8FSoldAmount; 
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current8FSoldAmount', salesPlanCreate);
                               }
                               else{
                                   Date fTp = CurrentYearVsDate.containsKey('current8FSoldAmount') ? CurrentYearVsDate.get('current8FSoldAmount') : null;
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current8FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current8FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                               }                    
                           }
                    }
                }
                if(newLoop.current9FSoldAmount != null && innerMap.get('current9FSoldAmount') != newLoop.current9FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current9FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                        salesPlanUpdate = dateVsSalesPlann.get('current9FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current9FSoldAmount;
                        salesPlanUpdate.Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null;
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(salesPlanListMapToCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) &&
                           recordInCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) && recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).containsKey('current9FSoldAmount') && 
                           recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).get('current9FSoldAmount').Account__c == null && newLoop.Account == System.Label.AverageofnotplannedAccounts){
                               salesPlanCreateMap = recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts);
                               salesPlanCreate = salesPlanCreateMap.get('current9FSoldAmount');
                               salesPlanCreate.ForecastNetProceeds__c = newLoop.current9FSoldAmount; 
                               salesPlanListMapToCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).put('current9FSoldAmount', salesPlanCreate);
                           }else{
                               if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanListMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                               }
                               if(recordInCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId);
                                   salesPlanCreate = salesPlanCreateMap.get('current9FSoldAmount');
                                   salesPlanCreate.ForecastNetProceeds__c = newLoop.current9FSoldAmount; 
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current9FSoldAmount', salesPlanCreate);
                               }
                               else{
                                   Date fTp = CurrentYearVsDate.containsKey('current9FSoldAmount') ? CurrentYearVsDate.get('current9FSoldAmount') : null;
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current9FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current9FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                               }
                           }
                    }
                }
                if(newLoop.current10FSoldAmount != null && innerMap.get('current10FSoldAmount') != newLoop.current10FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current10FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                        salesPlanUpdate = dateVsSalesPlann.get('current10FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current10FSoldAmount;
                        salesPlanUpdate.Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null;
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(salesPlanListMapToCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) &&
                           recordInCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) && recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).containsKey('current10FSoldAmount') && 
                           recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).get('current10FSoldAmount').Account__c == null && newLoop.Account == System.Label.AverageofnotplannedAccounts){
                               salesPlanCreateMap = recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts);
                               salesPlanCreate = salesPlanCreateMap.get('current10FSoldAmount');
                               salesPlanCreate.ForecastNetProceeds__c = newLoop.current10FSoldAmount; 
                               salesPlanListMapToCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).put('current10FSoldAmount', salesPlanCreate);
                           }else{
                               if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanListMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                               }
                               if(recordInCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId);
                                   salesPlanCreate = salesPlanCreateMap.get('current10FSoldAmount');
                                   salesPlanCreate.ForecastNetProceeds__c = newLoop.current10FSoldAmount; 
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current10FSoldAmount', salesPlanCreate);
                               }
                               else{
                                   Date fTp = CurrentYearVsDate.containsKey('current10FSoldAmount') ? CurrentYearVsDate.get('current10FSoldAmount') : null;
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current10FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current10FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                               }
                           }
                    }
                }
                if(newLoop.current11FSoldAmount != null && innerMap.get('current11FSoldAmount') != newLoop.current11FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current11FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                        salesPlanUpdate = dateVsSalesPlann.get('current11FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current11FSoldAmount;
                        salesPlanUpdate.Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null;
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(salesPlanListMapToCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) &&
                           recordInCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) && recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).containsKey('current11FSoldAmount') && 
                           recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).get('current11FSoldAmount').Account__c == null && newLoop.Account == System.Label.AverageofnotplannedAccounts){
                               salesPlanCreateMap = recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts);
                               salesPlanCreate = salesPlanCreateMap.get('current11FSoldAmount');
                               salesPlanCreate.ForecastNetProceeds__c = newLoop.current11FSoldAmount; 
                               salesPlanListMapToCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).put('current11FSoldAmount', salesPlanCreate);
                           }else{
                               if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanListMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                               }
                               if(recordInCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId);
                                   salesPlanCreate = salesPlanCreateMap.get('current11FSoldAmount');
                                   salesPlanCreate.ForecastNetProceeds__c = newLoop.current11FSoldAmount; 
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current11FSoldAmount', salesPlanCreate);
                               }
                               else{
                                   Date fTp = CurrentYearVsDate.containsKey('current11FSoldAmount') ? CurrentYearVsDate.get('current11FSoldAmount') : null;
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current11FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current11FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                               }
                           }
                    }
                }
                if(newLoop.current12FSoldAmount != null && innerMap.get('current12FSoldAmount') != newLoop.current12FSoldAmount){
                    if(dateVsSalesPlann.keySet().contains('current12FSoldAmount'+newLoop.Account+CONVARIABLE+accId)){
                        salesPlanUpdate = dateVsSalesPlann.get('current12FSoldAmount'+newLoop.Account+CONVARIABLE+accId);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.current12FSoldAmount;
                        salesPlanUpdate.Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null;
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(salesPlanListMapToCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) &&
                           recordInCreate.containsKey(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) && recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).containsKey('current12FSoldAmount') && 
                           recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).get('current12FSoldAmount').Account__c == null && newLoop.Account == System.Label.AverageofnotplannedAccounts){
                               salesPlanCreateMap = recordInCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts);
                               salesPlanCreate = salesPlanCreateMap.get('current12FSoldAmount');
                               salesPlanCreate.ForecastNetProceeds__c = newLoop.current12FSoldAmount; 
                               salesPlanListMapToCreate.get(System.Today()+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).put('current12FSoldAmount', salesPlanCreate);
                               
                           }else{
                               if(!salesPlanListMapToCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanListMapToCreate.put(System.Today()+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                               }
                               if(recordInCreate.containsKey(System.Today()+newLoop.Account+CONVARIABLE+accId)){
                                   salesPlanCreateMap = recordInCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId);
                                   salesPlanCreate = salesPlanCreateMap.get('current12FSoldAmount');
                                   salesPlanCreate.ForecastNetProceeds__c = newLoop.current12FSoldAmount; 
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current12FSoldAmount', salesPlanCreate);
                               }
                               else{
                                   Date fTp = CurrentYearVsDate.containsKey('current12FSoldAmount') ? CurrentYearVsDate.get('current12FSoldAmount') : null;
                                   salesPlanListMapToCreate.get(System.Today()+newLoop.Account+CONVARIABLE+accId).put('current12FSoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.current12FSoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Monthly'));
                               }
                           }
                        
                    }
                }
                Date currentDate = Date.today();
                Integer currentYear = currentDate.year();
                if(newLoop.yearlySoldAmount != null && innerMap.get('yearlySoldAmount') != newLoop.yearlySoldAmount){
                    Integer year1 = currentYear+1;
                    if(YearVsSalesPlann.keySet().contains(year1+newLoop.Account+CONVARIABLE+accId)){ 
                        salesPlanUpdate = YearVsSalesPlann.get(year1+newLoop.Account+CONVARIABLE+accId);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.yearlySoldAmount;
                        salesPlanUpdate.Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null;
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(salesPlanListMapToCreate.containsKey(year1+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) && 
                           recordInCreate.containsKey(year1+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) && 
                           recordInCreate.get(year1+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).get('yearlySoldAmount').Account__c == null && newLoop.Account == System.Label.AverageofnotplannedAccounts){
                               salesPlanCreateMap = recordInCreate.get(year1+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts);
                               salesPlanCreate = salesPlanCreateMap.get('yearlySoldAmount');
                               salesPlanCreate.ForecastNetProceeds__c = newLoop.yearlySoldAmount; 
                               salesPlanListMapToCreate.get(year1+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).put('yearlySoldAmount', salesPlanCreate);
                           }
                        else {
                            if(!salesPlanListMapToCreate.containsKey(year1+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanListMapToCreate.put(year1+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            if(recordInCreate.containsKey(year1+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanCreateMap = recordInCreate.get(year1+newLoop.Account+CONVARIABLE+accId);
                                salesPlanCreate = salesPlanCreateMap.get('yearlySoldAmount');
                                salesPlanCreate.ForecastNetProceeds__c = newLoop.yearlySoldAmount; 
                                salesPlanListMapToCreate.get(year1+newLoop.Account+CONVARIABLE+accId).put('yearlySoldAmount', salesPlanCreate);
                            }
                            else{
                                Date fTp = Date.newInstance(year1, 1, 1);
                                salesPlanListMapToCreate.get(year1+newLoop.Account+CONVARIABLE+accId).put('yearlySoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.yearlySoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Yearly'));
                            }  
                        }
                    }
                }
                if(newLoop.yearly1SoldAmount != null && innerMap.get('yearly1SoldAmount') != newLoop.yearly1SoldAmount){
                    Integer year2 = currentYear+2;
                    if(YearVsSalesPlann.keySet().contains(year2+newLoop.Account+CONVARIABLE+accId)){ 
                        salesPlanUpdate = YearVsSalesPlann.get(year2+newLoop.Account+CONVARIABLE+accId);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.yearly1SoldAmount;
                        salesPlanUpdate.Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null;
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(salesPlanListMapToCreate.containsKey(year2+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) && 
                           recordInCreate.containsKey(year2+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) && 
                           recordInCreate.get(year2+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).get('yearly1SoldAmount').Account__c == null && newLoop.Account == System.Label.AverageofnotplannedAccounts){
                               salesPlanCreateMap = recordInCreate.get(year2+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts);
                               salesPlanCreate = salesPlanCreateMap.get('yearly1SoldAmount');
                               salesPlanCreate.ForecastNetProceeds__c = newLoop.yearly1SoldAmount; 
                               salesPlanListMapToCreate.get(year2+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).put('yearly1SoldAmount', salesPlanCreate);
                           }
                        else {
                            if(!salesPlanListMapToCreate.containsKey(year2+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanListMapToCreate.put(year2+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            if(recordInCreate.containsKey(year2+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanCreateMap = recordInCreate.get(year2+newLoop.Account+CONVARIABLE+accId);
                                salesPlanCreate = salesPlanCreateMap.get('yearly1SoldAmount');
                                salesPlanCreate.ForecastNetProceeds__c = newLoop.yearly1SoldAmount; 
                                salesPlanListMapToCreate.get(year2+newLoop.Account+CONVARIABLE+accId).put('yearly1SoldAmount', salesPlanCreate);
                            }
                            else{
                                Date fTp = Date.newInstance(year2, 1, 1);
                                salesPlanListMapToCreate.get(year2+newLoop.Account+CONVARIABLE+accId).put('yearly1SoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.yearly1SoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Yearly'));
                            }
                        }
                    }
                }
                if(newLoop.yearly2SoldAmount != null && innerMap.get('yearly2SoldAmount') != newLoop.yearly2SoldAmount){
                    Integer year3 = currentYear+3;
                    if(YearVsSalesPlann.keySet().contains(year3+newLoop.Account+CONVARIABLE+accId)){ 
                        salesPlanUpdate = YearVsSalesPlann.get(year3+newLoop.Account+CONVARIABLE+accId);
                        if(recordInUpdate.keySet().contains(salesPlanUpdate.Id))
                            salesPlanUpdate = recordInUpdate.get(salesPlanUpdate.Id);
                        salesPlanUpdate.ForecastNetProceeds__c = newLoop.yearly2SoldAmount;
                        salesPlanUpdate.Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null;
                        salesPlanListMapToUpdate.put(salesPlanUpdate.Id, salesPlanUpdate);
                    }
                    else{
                        if(salesPlanListMapToCreate.containsKey(year3+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) && 
                           recordInCreate.containsKey(year3+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts) && 
                           recordInCreate.get(year3+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).get('yearly2SoldAmount').Account__c == null && newLoop.Account == System.Label.AverageofnotplannedAccounts){
                               salesPlanCreateMap = recordInCreate.get(year3+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts);
                               salesPlanCreate = salesPlanCreateMap.get('yearly2SoldAmount');
                               salesPlanCreate.ForecastNetProceeds__c = newLoop.yearly1SoldAmount; 
                               salesPlanListMapToCreate.get(year3+System.Label.SumofnotplannedAccounts+CONVARIABLE+System.Label.SumofnotplannedAccounts).put('yearly2SoldAmount', salesPlanCreate);
                           }
                        else {
                            if(!salesPlanListMapToCreate.containsKey(year3+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanListMapToCreate.put(year3+newLoop.Account+CONVARIABLE+accId, new Map<String, SalesPlanning__c>());
                            }
                            if(recordInCreate.containsKey(year3+newLoop.Account+CONVARIABLE+accId)){
                                salesPlanCreateMap = recordInCreate.get(year3+newLoop.Account+CONVARIABLE+accId);
                                salesPlanCreate = salesPlanCreateMap.get('yearly2SoldAmount');
                                salesPlanCreate.ForecastNetProceeds__c = newLoop.yearly2SoldAmount; 
                                salesPlanListMapToCreate.get(year3+newLoop.Account+CONVARIABLE+accId).put('yearly2SoldAmount', salesPlanCreate);
                            }
                            else{
                                Date fTp = Date.newInstance(year3, 1, 1);
                                salesPlanListMapToCreate.get(year3+newLoop.Account+CONVARIABLE+accId).put('yearly2SoldAmount', new SalesPlanning__c(ForecastNetProceeds__c = newLoop.yearly2SoldAmount, ForecastTimePoint__c = fTp, Account__c = accId != null ? accId != System.Label.AverageofnotplannedAccounts ? accId : null : null,  ForecastLevel__c = 'Account',BusinessArea__c =bussinessArea,Frequency__c ='Yearly'));
                            }
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
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to update the Last Save On date on the sales Palnning Log.
* Created Date: 24/03/2023
* Last Modified Date: 24/03/2023
****************************************************************************/
    @AuraEnabled
    public static sobject updateSalesPlanningLog(){
        SalesPlanningLog__c spLog =  [SELECT Id, Name, LastSavedOn__c,EditedBy__c, LastSubmittedOn__c, LastRolledUpOn__c, LastRolledUpAnnualPlanning__c, ForecastLevel__c FROM SalesPlanningLog__c WHERE  ForecastLevel__c =:'Account' LIMIT 1];
        if(spLog != null){
            spLog.LastSubmittedOn__c = System.today();            
            UPDATE spLog;
        }
        return spLog;
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to query the Sales Planning Log.
* Created Date: 24/03/2023
* Last Modified Date: 24/03/2023
****************************************************************************/
    @AuraEnabled
    public static SalesPlanningLog__c getSalesPlanningLogForEdit(){
        SalesPlanningLog__c spLog =  [SELECT Id, Name, InEditMode__c, EditedBy__c FROM SalesPlanningLog__c WHERE  ForecastLevel__c =:'Account' LIMIT 1];
        
        return spLog;
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to update the Sales Planning Log on edit.
* Created Date: 24/03/2023
* Last Modified Date: 24/03/2023
****************************************************************************/  
    @AuraEnabled
    public static String updateSalesPlanningLogForEdit(Boolean IsEdit,Boolean editbutton){
        SalesPlanningLog__c spLog =  [SELECT Id, Name, LastModifiedById , InEditMode__c, EditedBy__c FROM SalesPlanningLog__c WHERE  ForecastLevel__c =:'Account' LIMIT 1];
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
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to get the logged in users profile for disabling the buttons on the the view.
* Created Date: 17/04/2023
* Last Modified Date: 17/04/2023
****************************************************************************/ 
    @AuraEnabled
    public static Boolean getMarketingUsers(){
        Boolean istrue = false;
        String profilename = [SELECT ID, Name, Title, Profile.Name From User WHERE ID = :UserInfo.getUserId() LIMIT 1].Profile.Name;
        if(profilename != null && profilename == ConstantClass.SAG_SALES_PROFILE){ 
            List<PermissionSetAssignment> permissionSet = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name, Assignee.Profile.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = : ConstantClass.SAG_SALES_USER_PERMISSION];
            for(PermissionSetAssignment per : permissionSet){
                if( per.AssigneeId == UserInfo.getUserId() ){
                    istrue = true;
                    break;
                }
            }
        }
        if( istrue || profilename == ConstantClass.SAG_MARKETING_PROFILE || profilename == System.label.SystemAdministratorProfile){
            return true;
        }
        return false;
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Wrapper class to create or Update the Sales Planning data.
* Created Date: 24/03/2023
* Last Modified Date: 24/03/2023
****************************************************************************/ 
    public class UpdateTableResponse {
        @AuraEnabled
        public Map<String, SalesPlanning__c> wrapperMapToUpdate {get;set;}
        @AuraEnabled
        public Map<String, Map<String, SalesPlanning__c>>  wrapperMapToCreate {get;set;}
    }
    
    public static AccountSoldAmountawrapper getDeltaBussinessArea(String businessArea){
        Map<String, Map<Date,Decimal>> busAreaVsDeltaNetProceedMap = new Map<String, Map<Date,Decimal>>();
        ActualAccountWrapper nullactual = new ActualAccountWrapper(null,null,null, null, null, null, null,null, null,null, null, null, null, null); //4216
        // US-6779 start
        AccountSoldAmountawrapper accountwrapper = new AccountSoldAmountawrapper(null,null, null, null,null,
                                                                                 null, null, null,null, null, 
                                                                                 null, null, null, null, null, null, null,null,
                                                                                 null,null,null,null,nullactual,false, false, true,false,false,false,false);
        List<SalesPlanning__c> SalesPlanningList= new List<SalesPlanning__c>([SELECT Id, Account__c, toLabel(BusinessArea__c), ForecastTimePoint__c, Frequency__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                                                              FROM SalesPlanning__c WHERE ForecastLevel__c ='Business Area/Product Group' AND Account__c = null AND BusinessArea__c =: businessArea AND  
                                                                              ForecastTimePoint__c > LAST_MONTH  AND ForecastTimePoint__c <= NEXT_N_MONTHS:12 AND Frequency__c ='Monthly' ORDER By ForecastTimePoint__c ASC]); 
        if(!SalesPlanningList.isempty()){
            for(SalesPlanning__c salesPlanloop : SalesPlanningList){
                if (!busAreaVsDeltaNetProceedMap.containsKey(salesPlanloop.BusinessArea__c)) {
                    busAreaVsDeltaNetProceedMap.put(salesPlanloop.BusinessArea__c, new Map<Date, Decimal>());
                }
                Map<Date, Decimal> innerMapDeltaNetProceed = busAreaVsDeltaNetProceedMap.get(salesPlanloop.BusinessArea__c);
                innerMapDeltaNetProceed.put(salesPlanloop.ForecastTimePoint__c, salesPlanloop.DeltaNetProceeds__c);
            }
            List<SalesForecastingController.BusAreawrapper> deltaNet= SalesForecastingController.getBusAreawrapper(busAreaVsDeltaNetProceedMap, null, null, null);
            accountwrapper = new AccountSoldAmountawrapper(deltaNet[0].businessArea, null, null, null, null,
                                                           deltaNet[0].currentFSoldAmount != null ? Math.round(deltaNet[0].currentFSoldAmount) : null,
                                                           deltaNet[0].current1FSoldAmount != null ? Math.round(deltaNet[0].current1FSoldAmount) : null, 
                                                           deltaNet[0].current2FSoldAmount != null ? Math.round(deltaNet[0].current2FSoldAmount) : null, 
                                                           deltaNet[0].current3FSoldAmount != null ? Math.round(deltaNet[0].current3FSoldAmount) : null, 
                                                           deltaNet[0].current4FSoldAmount != null ? Math.round(deltaNet[0].current4FSoldAmount) : null, 
                                                           deltaNet[0].current5FSoldAmount != null ? Math.round(deltaNet[0].current5FSoldAmount) : null, 
                                                           deltaNet[0].current6FSoldAmount != null ? Math.round(deltaNet[0].current6FSoldAmount) : null, 
                                                           deltaNet[0].current7FSoldAmount != null ? Math.round(deltaNet[0].current7FSoldAmount) : null, 
                                                           deltaNet[0].current8FSoldAmount != null ? Math.round(deltaNet[0].current8FSoldAmount) : null, 
                                                           deltaNet[0].current9FSoldAmount != null ? Math.round(deltaNet[0].current9FSoldAmount) : null,
                                                           deltaNet[0].current10FSoldAmount != null ? Math.round(deltaNet[0].current10FSoldAmount) : null,
                                                           deltaNet[0].current11FSoldAmount != null ? Math.round(deltaNet[0].current11FSoldAmount) : null,
                                                           deltaNet[0].current12FSoldAmount != null ? Math.round(deltaNet[0].current12FSoldAmount) : null,
                                                           null, null, null, null, nullactual,false, false, true,false,false,false,false);
        }
        // US-6779 stop
        return accountwrapper;
    }
    //6993
    @AuraEnabled
    public static String overrideCalulation(String oVMonth, String previousMonth, String bussinessArea){
           return AccountSalesPlanningHelper.overrideCalulationHelper(oVMonth, previousMonth, bussinessArea);
    }
}