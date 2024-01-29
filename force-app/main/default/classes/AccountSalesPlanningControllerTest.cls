/****************************************************************************
* Name: AccountSalesPlanningControllerTest
* Author: Harshitha U
* Created Date: 29/03/2023
* Description: Test class for AccountSalesPlanningController
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
****************************************************************************/
@isTest
public class AccountSalesPlanningControllerTest {
    @testSetup
    static void setUpData(){
        List<SalesPlanning__c> sPLST = TestDataFactory.createSalesPlanningAcc(13);
        List<SalesPlanning__c> sPLSTdelta = TestDataFactory.createSalesPlanning(13);
        List<SalesPlanning__c> spListAccountYearly = TestDataFactory.createAccountYearlySalesPlanning(4);
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.year();
        Date fTp;
        List<SalesPlanning__c> salesPlan = new List<SalesPlanning__c>();
        List<SalesPlanning__c> salesPlanDelta = new List<SalesPlanning__c>();
        for(Integer i= 0 ; i <= 12 ;i++){
            Integer calYear = 0;
            Integer calMonth = 0;
            if(currentMonth + i > 12){
                calYear = currentYear + 1;
                calMonth = currentMonth + i - 12;
            }else{
                calMonth = currentMonth + i;
                calYear = currentYear;
            }
            fTp = Date.newInstance(calYear, calMonth, 1);
            SalesPlanning__c sp = sPLST[i];
            sp.ForecastTimePoint__c = fTp;
            sp.BusinessArea__c  = 'ZK';
            sp.ForecastSoldAmount__c = 100 + i;
            sp.ForecastNetProceeds__c = 100 + i;
            sp.Frequency__c ='Monthly';
            salesPlan.add(sp);
        }
         
        for(integer i=0 ; i <=3 ; i++){
             fTp = Date.newInstance(currentYear + i, i, 1);
             SalesPlanning__c spAccountYr = spListAccountYearly[i];
                spAccountYr.ForecastTimePoint__c = fTp;
                spAccountYr.BusinessArea__c  = 'ZW';
                spAccountYr.ForecastSoldAmount__c = 100 + i;
                spAccountYr.ForecastNetProceeds__c = 100 + i;
                spAccountYr.DeltaNetProceeds__c = 100 + i;
                salesPlan.add(spAccountYr);
        }
        update salesPlan;
        for(Integer i= 0 ; i <= 12 ;i++){
            Integer calYear = 0;
            Integer calMonth = 0;
            if(currentMonth + i > 12){
                calYear = currentYear + 1;
                calMonth = currentMonth + i - 12;
            }else{
                calMonth = currentMonth + i;
                calYear = currentYear;
            }
            fTp = Date.newInstance(calYear, calMonth, 1);
            SalesPlanning__c sp = sPLSTdelta[i];
            sp.ForecastTimePoint__c = fTp;
            sp.BusinessArea__c  = 'ZK';
            sp.DeltaNetProceeds__c = 100+ i;
            sp.Frequency__c ='Monthly';
            salesPlanDelta.add(sp);
        }
        update salesPlanDelta;
        SalesPlanningLog__c sp = TestDataFactory.createSalesPlanningLogAcc();
         User user = [SELECT ID, Profile.Name From User WHERE ID = :UserInfo.getUserId() LIMIT 1];
         System.runAs(user){
         List<User> opUser = TestDataFactory.createUserSales(1);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: ConstantClass.SAG_SALES_USER_PERMISSION];
        insert new PermissionSetAssignment(AssigneeId = opUser[0].id, PermissionSetId = ps.Id);
         }
    }
    
    @isTest static void testMethodAcc(){
        List<SalesPlanning__c> ss = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                     FROM SalesPlanning__c];
        List<User> userList = [SELECT Id, UserRoleId, LastName, ProfileId, Profile.Name, IsActive FROM User WHERE LastName= 'last0' AND Profile.Name ='SAG Sales' AND IsActive =TRUE LIMIT 1];
        Test.startTest();
        AccountSalesPlanningController.getAccountPlanningColumnNames();
        AccountSalesPlanningController.showActualTableData(ss[0].BusinessArea__c);
        AccountSalesPlanningController.showtabledata(ss[0].BusinessArea__c,'');
        AccountSalesPlanningController.updateSalesPlanningLog();
        AccountSalesPlanningController.updateSalesPlanningLogForEdit(true,true);
        system.runAs(userList[0]) {
        AccountSalesPlanningController.getMarketingUsers();
        }
        AccountSalesPlanningController.getSalesPlanningLogForEdit();
        Test.stopTest();
        system.assertNotEquals(ss.size(), 0,'List should not be empty');
    }
     @isTest static void testMethodAcc1(){
        List<SalesPlanning__c> ss = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                     FROM SalesPlanning__c];
        List<SalesPlanning__c> ssUpdateList=new List<SalesPlanning__c>();
         for(SalesPlanning__c s:ss){
             s.Account__c=null;
             ssUpdateList.add(s);
         }
        Test.startTest();
         update ssUpdateList;
        AccountSalesPlanningController.getAccountPlanningColumnNames();
        AccountSalesPlanningController.showtabledata(ss[0].BusinessArea__c,'');
        AccountSalesPlanningController.updateSalesPlanningLog();
        Test.stopTest();
        system.assertNotEquals(ss.size(), 0,'List should not be empty');
    }
     @isTest static void testMethodAcc2(){
        List<SalesPlanning__c> ss = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c ,Frequency__c
                                     FROM SalesPlanning__c where ForecastLevel__c='Account' ];
          SalesPlanningLog__c spLog =  [SELECT Id, Name, LastSavedOn__c, LastSubmittedOn__c, LastRolledUpOn__c, ForecastLevel__c,EditedBy__c,InEditMode__c FROM SalesPlanningLog__c WHERE ForecastLevel__c =:'Account' LIMIT 1];
          List<SalesPlanning__c> ssUpdateList=new List<SalesPlanning__c>();
         for(SalesPlanning__c s:ss){
             s.Frequency__c='Monthly';
            ssUpdateList.add(s);
         }
          update ssUpdateList;
        spLog.EditedBy__c =null;
        spLog.InEditMode__c =false;
        update spLog;
        String accountId = System.URL.getSalesforceBaseURL().toExternalForm()+'/'+ss[1].Account__c;
        String wrapper1 = '[{"Account":"Percentage Change","blankline":false,"deltaNetProceed":false,"isAverage":false,"isNetProceed":false,"isPerRow":true,"isSoldAmount":false,"isTotal":false,"source":"list1","current10FSoldAmount":"10","current11FSoldAmount":"-10"},{"isPerRow":false,"Account":"Test Account 1","accountId":"'+accountId+'","sapAccNumber":"1234","ActualSoldAmount":16,"BusinessArea":"Bearing Steel","current10FSoldAmount":2000,"current12FSoldAmount":300,"current1FSoldAmount":200,"currentFSoldAmount":1000,"rollingForecastCurrentYear":1316,"yearly1SoldAmount":10,"yearly2SoldAmount":10,"yearlySoldAmount":10,"current2FSoldAmount":200,"current3FSoldAmount":300,"current4FSoldAmount":400,"current5FSoldAmount":500,"current6FSoldAmount":600,"current7FSoldAmount":700,"current8FSoldAmount":800,"current9FSoldAmount":900,"current11FSoldAmount":200}]';
        String wrapper2 = '[{"isPerRow":false,"Account":"Test Account 1","accountId":"'+accountId+'","sapAccNumber":"1234","ActualSoldAmount":16,"BusinessArea":"Bearing Steel","current10FSoldAmount":4000,"current12FSoldAmount":300,"current1FSoldAmount":200,"currentFSoldAmount":1000,"rollingForecastCurrentYear":1316,"yearly1SoldAmount":10,"yearly2SoldAmount":10,"yearlySoldAmount":10,"current2FSoldAmount":200,"current3FSoldAmount":300,"current4FSoldAmount":400,"current5FSoldAmount":500,"current6FSoldAmount":600,"current7FSoldAmount":700,"current8FSoldAmount":800,"current9FSoldAmount":900,"current11FSoldAmount":200}]'; 
        Test.startTest();
        AccountSalesPlanningController.getAccountPlanningColumnNames();
        AccountSalesPlanningController.showtabledata(ss[0].BusinessArea__c,'');
        AccountSalesPlanningController.upsertSPForecaste(wrapper1,wrapper2,'ZK');
        AccountSalesPlanningController.updateSalesPlanningLog();
        AccountSalesPlanningController.updateSalesPlanningLogForEdit(true,false);
        Test.stopTest();
        system.assertNotEquals(ss.size(), 0,'List should not be empty');
    }
    
     @isTest static void testMethodAcc3(){
        List<SalesPlanning__c> ss = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c ,Frequency__c
                                     FROM SalesPlanning__c where ForecastLevel__c='Account' ];
          SalesPlanningLog__c spLog =  [SELECT Id, Name, LastSavedOn__c, LastSubmittedOn__c, LastRolledUpOn__c, ForecastLevel__c,EditedBy__c,InEditMode__c FROM SalesPlanningLog__c WHERE ForecastLevel__c =:'Account' LIMIT 1];
          List<SalesPlanning__c> ssUpdateList=new List<SalesPlanning__c>();
         for(SalesPlanning__c s:ss){
             s.Frequency__c='Yearly';
            ssUpdateList.add(s);
         }
          update ssUpdateList;
        spLog.EditedBy__c =null;
        spLog.InEditMode__c =false;
        update spLog;
        String accountId = System.URL.getSalesforceBaseURL().toExternalForm()+'/'+ss[1].Account__c;
        String wrapper1 = '[{"Account":"Percentage Change","blankline":false,"deltaNetProceed":false,"isAverage":false,"isNetProceed":false,"isPerRow":true,"isSoldAmount":false,"isTotal":false,"source":"list1","current10FSoldAmount":"10","current11FSoldAmount":"-10"},{"isPerRow":false,"Account":"Test Account 1","accountId":"'+accountId+'","sapAccNumber":"1234","ActualSoldAmount":16,"BusinessArea":"Bearing Steel","current10FSoldAmount":2000,"current12FSoldAmount":300,"current1FSoldAmount":200,"currentFSoldAmount":1000,"rollingForecastCurrentYear":1316,"yearly1SoldAmount":10,"yearly2SoldAmount":10,"yearlySoldAmount":10,"current2FSoldAmount":200,"current3FSoldAmount":300,"current4FSoldAmount":400,"current5FSoldAmount":500,"current6FSoldAmount":600,"current7FSoldAmount":700,"current8FSoldAmount":800,"current9FSoldAmount":900,"current11FSoldAmount":200}]';
        String wrapper2 = '[{"isPerRow":false,"Account":"Test Account 1","accountId":"'+accountId+'","sapAccNumber":"1234","ActualSoldAmount":16,"BusinessArea":"Bearing Steel","current10FSoldAmount":4000,"current12FSoldAmount":300,"current1FSoldAmount":200,"currentFSoldAmount":1000,"rollingForecastCurrentYear":1316,"yearly1SoldAmount":10,"yearly2SoldAmount":10,"yearlySoldAmount":10,"current2FSoldAmount":200,"current3FSoldAmount":300,"current4FSoldAmount":400,"current5FSoldAmount":500,"current6FSoldAmount":600,"current7FSoldAmount":700,"current8FSoldAmount":800,"current9FSoldAmount":900,"current11FSoldAmount":200}]'; 
        Test.startTest();
        AccountSalesPlanningController.getAccountPlanningColumnNames();
        AccountSalesPlanningController.showtabledata(ss[0].BusinessArea__c,'');
        AccountSalesPlanningController.upsertSPForecaste(wrapper1,wrapper2,'ZK');
        AccountSalesPlanningController.updateSalesPlanningLog();
        AccountSalesPlanningController.updateSalesPlanningLogForEdit(true,false);
        Test.stopTest();
        system.assertNotEquals(ss.size(), 0,'List should not be empty');
    }
 
    @isTest static void testMethodAcc4(){
        List<SalesPlanning__c> ss = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                     FROM SalesPlanning__c];
        
        ss[0].ForecastTimePoint__c = system.today().addMonths(-1);
        ss[0].ActualSoldAmount__c = 1000;
        ss[0].ActualNetProceeds__c =100;
        update ss[0];
        Test.startTest();
        AccountSalesPlanningController.showtabledata(ss[0].BusinessArea__c,'');
        Test.stopTest();
        system.assertEquals(ss[0].ActualNetProceeds__c, 100, 'ActualNetProceeds should be 1000');
    }
    
    @isTest static void testupsertSPForecaste5(){
        List<SalesPlanning__c> ss = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                     FROM SalesPlanning__c];
        String accountId = System.URL.getSalesforceBaseURL().toExternalForm()+'/'+ss[0].Account__c;
        String wrapper1 = '[{"Account":"Percentage Change","blankline":false,"deltaNetProceed":false,"isAverage":false,"isNetProceed":false,"isPerRow":true,"isSoldAmount":false,"isTotal":false,"source":"list1","current1FSoldAmount":"10","current11FSoldAmount":"10"},{"isPerRow":false,"Account":"TestAccount0","accountId":"'+accountId+'","ActualSoldAmount":16,"sapAccNumber":"1234","BusinessArea":"Cold Heading","current10FSoldAmount":2000,"current12FSoldAmount":300,"current1FSoldAmount":200,"currentFSoldAmount":1000,"rollingForecastCurrentYear":1316,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0,"current2FSoldAmount":200,"current3FSoldAmount":300,"current4FSoldAmount":400,"current5FSoldAmount":500,"current6FSoldAmount":600,"current7FSoldAmount":700,"current8FSoldAmount":800,"current9FSoldAmount":900,"current11FSoldAmount":200}]';
        String wrapper2 = '[{"Account":"TestAccount0","accountId":"'+accountId+'","ActualSoldAmount":16,"sapAccNumber":"1234","BusinessArea":"Cold Heading","current10FSoldAmount":2000,"current12FSoldAmount":300,"current1FSoldAmount":200,"currentFSoldAmount":1000,"rollingForecastCurrentYear":1316,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0,"current2FSoldAmount":200,"current3FSoldAmount":300,"current4FSoldAmount":400,"current5FSoldAmount":500,"current6FSoldAmount":600,"current7FSoldAmount":700,"current8FSoldAmount":800,"current9FSoldAmount":900,"current11FSoldAmount":200}]';
         Test.startTest();
        AccountSalesPlanningController.upsertSPForecaste(wrapper1, wrapper2,'ZK');
        Test.stopTest();
        system.assertNotEquals(ss.size(), 0,'List should not be empty');    
    }
    
    @isTest static void testupsertSPForecasteTest6(){
        List<SalesPlanning__c> salesPlanupdate = new List<SalesPlanning__c>();
        List<SalesPlanning__c> salesPlanList = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                     FROM SalesPlanning__c];
        for(SalesPlanning__c ss : salesPlanList){
            ss.Account__c = null;
            ss.BusinessArea__c ='ZS';
            salesPlanupdate.add(ss);
        }
        update salesPlanupdate;
        List<SalesPlanning__c> salesPlanningFAList= new List<SalesPlanning__c>([SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, DeltaNetProceeds__c,ActualNetProceeds__c FROM SalesPlanning__c 
                                                                                WHERE ForecastLevel__c ='Business Area/Product Group' ]);
        for(SalesPlanning__c sp : salesPlanningFAList){
            sp.BusinessArea__c = 'ZS';
        }
        update salesPlanningFAList;
        String wrapper1 = '[{"Account":"Percentage Change","blankline":false,"deltaNetProceed":false,"isAverage":false,"isNetProceed":false,"isPerRow":true,"isSoldAmount":false,"isTotal":false,"source":"list1","current11FSoldAmount":"10"},{"ActualSoldAmount":16,"Account":"Sum of not planned Accounts","BusinessArea":"Free Cutting Steel (SZO)","current10FSoldAmount":110,"current12FSoldAmount":112,"current1FSoldAmount":"101","currentFSoldAmount":100,"rollingForecastCurrentYear":1316,"yearly1SoldAmount":10,"yearly2SoldAmount":10,"yearlySoldAmount":10,"current2FSoldAmount":"102","current3FSoldAmount":"103","current4FSoldAmount":"104","current5FSoldAmount":"105","current6FSoldAmount":"106","current7FSoldAmount":"107","current8FSoldAmount":"108","current9FSoldAmount":"109","current11FSoldAmount":"110"},{"Account":"Test Account 1","ActualSoldAmount":16,"BusinessArea":"Cold Heading","current1FSoldAmount":5000,"currentFSoldAmount":5000,"rollingForecastCurrentYear":10016,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":32,"BusinessArea":"Forging Steel","current5FSoldAmount":100,"rollingForecastCurrentYear":132,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Tyre Cord","current10FSoldAmount":200,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - High Carbon","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Spring Steel","rollingForecastCurrentYear":16,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Free Cutting Steel (SZO)","rollingForecastCurrentYear":16,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Welding Wire","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Low Carbon (w.o. B10)","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":40,"BusinessArea":"Drawing Grades - Low Carbon - B10","rollingForecastCurrentYear":40,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0}]';
        String wrapper3 = '[{"ActualSoldAmount":16,"Account":"Average of not planned Accounts","BusinessArea":"Cold Heading","current10FSoldAmount":2000,"current12FSoldAmount":300,"current1FSoldAmount":"200","currentFSoldAmount":1000,"rollingForecastCurrentYear":1316,"yearly1SoldAmount":10,"yearly2SoldAmount":10,"yearlySoldAmount":10,"current2FSoldAmount":"200","current3FSoldAmount":"300","current4FSoldAmount":"400","current5FSoldAmount":"500","current6FSoldAmount":"600","current7FSoldAmount":"700","current8FSoldAmount":"800","current9FSoldAmount":"900","current11FSoldAmount":"200"},{"Account":"Test Account 1","ActualSoldAmount":16,"BusinessArea":"Cold Heading","current1FSoldAmount":5000,"currentFSoldAmount":5000,"rollingForecastCurrentYear":10016,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"Account":"Average of not planned Accounts","ActualSoldAmount":32,"BusinessArea":"Forging Steel","current5FSoldAmount":100,"rollingForecastCurrentYear":132,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Tyre Cord","current10FSoldAmount":200,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - High Carbon","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Spring Steel","rollingForecastCurrentYear":16,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Free Cutting Steel (SZO)","rollingForecastCurrentYear":16,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Welding Wire","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Low Carbon (w.o. B10)","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":40,"BusinessArea":"Drawing Grades - Low Carbon - B10","rollingForecastCurrentYear":40,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmout":10},{"Account":"Average of not planned Accounts","ActualSoldAmount":540,"BusinessArea":"Free Cutting Steel (SZO)","current11FSoldAmount":300,"current12FSoldAmount":10,"current10FSoldAmount":10,"rollingForecastCurrentYear":665,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0,"current1FSoldAmount":"100","current2FSoldAmount":"200","current3FSoldAmount":"200","current4FSoldAmount":"200","current5FSoldAmount":"200","current6FSoldAmount":"200","current7FSoldAmount":"200","current8FSoldAmount":"200","current9FSoldAmount":"200"}]';
        Test.startTest();
         AccountSalesPlanningController.upsertSPForecaste(wrapper1,wrapper3,'ZS');
         AccountSalesPlanningController.overrideCalulation('current11FSoldAmount', 'current10FSoldAmount' ,'ZS');
        Test.stopTest();
        system.assertNotEquals(salesPlanList.size(), 0,'List should not be empty');    
    }
    
    @isTest static void testupsertSPForecaste7(){
        List<SalesPlanning__c> ss = [SELECT Id, Account__c, Account__r.Name, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                     FROM SalesPlanning__c where Account__c != null];
        String accountId = System.URL.getSalesforceBaseURL().toExternalForm()+'/'+ss[0].Account__c;
        String accName = ss[0].Account__r.Name;
        String accountSP = System.URL.getSalesforceBaseURL().toExternalForm()+'/'+System.Label.SumofnotplannedAccounts;
        String accountNP = System.URL.getSalesforceBaseURL().toExternalForm()+'/'+System.Label.AverageofnotplannedAccounts;
        String wrapper1 = '[{"blankline":false,"deltaNetProceed":false,"isAverage":false,"isNetProceed":false,"isPerRow":false,"isSoldAmount":true,"isTotal":false,"source":"list1"},{"Account":"Percentage Change","blankline":false,"deltaNetProceed":false,"isAverage":false,"isNetProceed":false,"isPerRow":true,"isSoldAmount":false,"isTotal":false,"source":"list1","current1FSoldAmount":"10","current2FSoldAmount":"-10","current3FSoldAmount":"10","current4FSoldAmount":"-10","current5FSoldAmount":"10","current6FSoldAmount":"-10","current7FSoldAmount":"10","current8FSoldAmount":"-10","current9FSoldAmount":"10","current10FSoldAmount":"-10","current11FSoldAmount":"10","current12FSoldAmount":"-10"},'
+'{"Account":"'+accName+'","accountId":"'+accountId+'","actualWrapper":{"accountActualId":"0011q000016Qh1XAAS","accountLast":"Test Account for Price Calculation"},"blankline":false,"current10FSoldAmount":"110","current1FSoldAmount":"10","current2FSoldAmount":"20","current3FSoldAmount":"30","current4FSoldAmount":"40","current5FSoldAmount":"50","current6FSoldAmount":"60","current7FSoldAmount":"70","current9FSoldAmount":"90","currentFSoldAmount":30,"deltaNetProceed":false,"isAverage":false,"isNetProceed":false,"isPerRow":false,"isSoldAmount":false,"isTotal":false,"rollingForecastCurrentYear":150,"sapAccNumber":"1234","yearly1SoldAmount":"500","yearlySoldAmount":"400","source":"list1","current8FSoldAmount":"80","current11FSoldAmount":"200","current12FSoldAmount":"300","yearly2SoldAmount":"600"},'
+'{"Account":"Sum of not planned Accounts","accountId":"'+accountSP+'","actualWrapper":{"accountActualId":"Sum of not planned Accounts","accountLast":"Sum of not planned Accounts","actualSoldAmountL":0,"actualSoldAmountL1":0,"actualSoldAmountL10":0,"actualSoldAmountL11":0,"actualSoldAmountL2":0,"actualSoldAmountL3":0,"actualSoldAmountL4":0,"actualSoldAmountL5":0,"actualSoldAmountL6":0,"actualSoldAmountL7":0,"actualSoldAmountL8":0,"actualSoldAmountL9":0},"blankline":false,"current10FSoldAmount":"110","current8FSoldAmount":"80","current9FSoldAmount":"90","deltaNetProceed":false,"isAverage":false,"isNetProceed":false,"isPerRow":false,"isSoldAmount":false,"isTotal":false,"yearly1SoldAmount":"500","yearly2SoldAmount":"600","yearlySoldAmount":"400","source":"list1","current1FSoldAmount":"10","current2FSoldAmount":"20","current3FSoldAmount":"30","current4FSoldAmount":"40","current5FSoldAmount":"50","current6FSoldAmount":"60","current7FSoldAmount":"70","current11FSoldAmount":"200","current12FSoldAmount":"300"}]';
        String wrapper3 = '[{"Account":"'+accName+'","accountId":"'+accountId+'","actualWrapper":{"accountActualId":"0011q000016Qh1XAAS","accountLast":"Test Account for Price Calculation"},"blankline":false,"current10FSoldAmount":"100","current1FSoldAmount":"10","current2FSoldAmount":"20","current3FSoldAmount":"30","current4FSoldAmount":"40","current5FSoldAmount":"50","current6FSoldAmount":"60","current7FSoldAmount":"70","current9FSoldAmount":"90","currentFSoldAmount":30,"deltaNetProceed":false,"isAverage":false,"isNetProceed":false,"isPerRow":false,"isSoldAmount":false,"isTotal":false,"rollingForecastCurrentYear":46,"sapAccNumber":"1234","yearly1SoldAmount":"500","yearlySoldAmount":"400","source":"list2","current8FSoldAmount":"80","current11FSoldAmount":"200","current12FSoldAmount":"300","yearly2SoldAmount":"600"},'
                     +'{"Account":"Average of not planned Accounts","accountId":"'+accountNP+'","actualWrapper":{"accountActualId":"Average of not planned Accounts","accountLast":"Average of not planned Accounts","actualSoldAmountL":0,"actualSoldAmountL1":0,"actualSoldAmountL10":0,"actualSoldAmountL11":0,"actualSoldAmountL2":0,"actualSoldAmountL3":0,"actualSoldAmountL4":0,"actualSoldAmountL5":0,"actualSoldAmountL6":0,"actualSoldAmountL7":0,"actualSoldAmountL8":0,"actualSoldAmountL9":0},"blankline":false,"current10FSoldAmount":"100","current8FSoldAmount":"80","current9FSoldAmount":"90","deltaNetProceed":false,"isAverage":false,"isNetProceed":false,"isPerRow":false,"isSoldAmount":false,"isTotal":false,"yearly1SoldAmount":"550","yearly2SoldAmount":"600","yearlySoldAmount":"400","source":"list2","current1FSoldAmount":"10","current2FSoldAmount":"20","current3FSoldAmount":"30","current4FSoldAmount":"40","current5FSoldAmount":"50","current6FSoldAmount":"60","current7FSoldAmount":"70","current11FSoldAmount":"200","current12FSoldAmount":"300"}]';
        Test.startTest();
         AccountSalesPlanningController.upsertSPForecaste(wrapper1,wrapper3,'ZK');
        Test.stopTest();
        system.assertNotEquals(ss.size(), 0,'List should not be empty');    
    }
 
    @isTest static void testMethodAcc8(){
        List<SalesPlanning__c> ss = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                     FROM SalesPlanning__c];
        ss[0].Account__c=null;
        ss[0].ForecastTimePoint__c = system.today().addMonths(-10);
        ss[0].ActualSoldAmount__c = 1000;
        ss[0].ActualNetProceeds__c =100;
        update ss[0];
        Test.startTest();
        AccountSalesPlanningController.showActualTableData(ss[0].BusinessArea__c);
        Test.stopTest();
        system.assertEquals(ss[0].ActualNetProceeds__c, 100, 'ActualNetProceeds should be 1000');
    }
     @isTest static void testupsertSPForecaste9(){
        List<SalesPlanning__c> ss = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                     FROM SalesPlanning__c];
        String wrapper1 = '[{"isPerRow":false,"Account":"TestAccount0","sapAccNumber":"1234","ActualSoldAmount":16,"BusinessArea":"Cold Heading","current10FSoldAmount":2000,"current12FSoldAmount":300,"current1FSoldAmount":200,"currentFSoldAmount":1000,"rollingForecastCurrentYear":1316,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0,"current2FSoldAmount":200,"current3FSoldAmount":300,"current4FSoldAmount":400,"current5FSoldAmount":500,"current6FSoldAmount":600,"current7FSoldAmount":700,"current8FSoldAmount":800,"current9FSoldAmount":900,"current11FSoldAmount":200,"isNetProceed":true}]';
       Test.startTest();
        AccountSalesPlanningController.toCalculateDeltaNet(wrapper1,'ZK');
        AccountSalesPlanningController.overrideCalulation('current2FSoldAmount', 'current1FSoldAmount' ,'ZC');
        Test.stopTest();
        system.assertNotEquals(ss.size(), 0,'List should not be empty');    
    }
    
    @isTest static void testupsertSPForecaste10(){
        List<SalesPlanning__c> ss = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                     FROM SalesPlanning__c];
        String accountNP = System.URL.getSalesforceBaseURL().toExternalForm()+'/'+System.Label.AverageofnotplannedAccounts;
        String wrapper1 = '[{"Account":"Percentage Change","blankline":false,"deltaNetProceed":false,"isAverage":false,"isNetProceed":false,"isPerRow":true,"isSoldAmount":false,"isTotal":false,"source":"list1","current10FSoldAmount":"10","current1FSoldAmount":"-10"}]';
        String wrapper3 = '[{"Account":"Average of not planned Accounts","accountId":"'+accountNP+'","actualWrapper":{"accountActualId":"Average of not planned Accounts","accountLast":"Average of not planned Accounts","actualSoldAmountL":0,"actualSoldAmountL1":0,"actualSoldAmountL10":0,"actualSoldAmountL11":0,"actualSoldAmountL2":0,"actualSoldAmountL3":0,"actualSoldAmountL4":0,"actualSoldAmountL5":0,"actualSoldAmountL6":0,"actualSoldAmountL7":0,"actualSoldAmountL8":0,"actualSoldAmountL9":0},"blankline":false,"current10FSoldAmount":"1000","current11FSoldAmount":"2000","current12FSoldAmount":"3000","current1FSoldAmount":"100","current2FSoldAmount":"200","current3FSoldAmount":"300","current4FSoldAmount":"400","current5FSoldAmount":"500","current6FSoldAmount":"600","current7FSoldAmount":"700","current8FSoldAmount":"800","current9FSoldAmount":"900","deltaNetProceed":false,"isAverage":false,"isNetProceed":false,"isPerRow":false,"isSoldAmount":false,"isTotal":false,"rollingForecastCurrentYear":30,"yearly1SoldAmount":"50","yearly2SoldAmount":"60","yearlySoldAmount":"40","source":"list2"}]';
        Test.startTest();
         AccountSalesPlanningController.upsertSPForecaste(wrapper1,wrapper3,'ZK');
         AccountSalesPlanningController.overrideCalulation('current2FSoldAmount', 'current1FSoldAmount' ,'ZK');
        AccountSalesPlanningController.overrideCalulation('current2FSoldAmount', '' ,'ZC');
        Test.stopTest();
        system.assertNotEquals(ss.size(), 0,'List should not be empty');    
    }
    @isTest static void testupsertSPForecasteTest11(){
        List<SalesPlanning__c> salesPlanupdate = new List<SalesPlanning__c>();
        List<SalesPlanning__c> salesPlanList = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                     FROM SalesPlanning__c];
        for(SalesPlanning__c ss : salesPlanList){
            ss.BusinessArea__c ='ZS';
            ss.ForecastTimePoint__c = system.today().addMonths(1);
            salesPlanupdate.add(ss);
        }
        update salesPlanupdate;
        Test.startTest();
         AccountSalesPlanningController.overrideCalulation('current2FSoldAmount', 'current1FSoldAmount' ,'ZS');
        Test.stopTest();
        system.assertNotEquals(salesPlanList.size(), 0,'List should not be empty');    
    }
}
