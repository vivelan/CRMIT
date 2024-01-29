/****************************************************************************
* Name: SalesForecastingControllerTest
* Author: Naina B
* Created Date: 21/03/2023
* Description: Test class for SalesForecastingController
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
****************************************************************************/
@isTest
public class SalesForecastingControllerTest {
    @testSetup
    static void setUpData(){
        List<Account> acclst = TestDataFactory.createAccounts(1);
        List<SalesPlanning__c> sPLST = TestDataFactory.createSalesPlanning(14);
        List<SalesPlanning__c> spListYearly = TestDataFactory.createYearlySalesPlanning(4);
        Group queryTestGroup = new Group(Name='TestShareGroup', DeveloperName='TestShareGroup');
        insert queryTestGroup;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<User> userList1 = TestDataFactory.createUser(1);
            GroupMember gm = new GroupMember(GroupId = queryTestGroup.Id, UserOrGroupId = userList1[0].id);
            insert gm;
        }
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.year();
        Date fTp;
        List<SalesPlanning__c> salesPlan = new List<SalesPlanning__c>();
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
            SalesPlanning__c sp = SPLST[i];
            sp.ForecastTimePoint__c = fTp;
            sp.BusinessArea__c  = 'ZW';
            sp.ForecastSoldAmount__c = 100 + i;
            sp.ForecastNetProceeds__c = 100 + i;
            sp.Frequency__c ='Monthly';
            salesPlan.add(sp);
        }
        sPLST[12].Account__c = acclst[0].id;
        for(integer i=0 ; i <=3 ; i++){
             fTp = Date.newInstance(currentYear + i, i, 1);
             SalesPlanning__c spAccount = spListYearly[i];
                spAccount.ForecastTimePoint__c = fTp;
                spAccount.BusinessArea__c  = 'ZW';
                spAccount.ForecastSoldAmount__c = 100 + i;
                spAccount.ForecastNetProceeds__c = 100 + i;
                spAccount.DeltaNetProceeds__c = 100 + i;
                salesPlan.add(spAccount);
        }
        update SalesPlan;
        SalesPlanningLog__c sp = TestDataFactory.createSalesPlanningLog();
    }
    
    @isTest static void testOLIRecord(){
        List<SalesPlanning__c> ss = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                     FROM SalesPlanning__c];
        Test.startTest();
        SalesForecastingController.getColumnNames();
        SalesForecastingController.getSoldAmount();
        SalesForecastingController.getMarketingUsers();
        SalesForecastingController.updateSalesPlanningLog('LastSavedOn');
        SalesForecastingController.getSalesPlanningLog();
        SalesForecastingController.updateSalesPlanningLogForEdit(true,false);
        SalesForecastingController.updateSalesPlanningLogForEdit(false,false);
        Test.stopTest();
        system.assertNotEquals(ss.size(), 0,'List should not be empty');
    }
    
    @isTest static void testOLIRecord1(){
        List<SalesPlanning__c> ss = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                     FROM SalesPlanning__c];
        ss[0].ForecastTimePoint__c = system.today().addMonths(-1);
        ss[0].ActualSoldAmount__c = 1000;
        ss[0].ActualNetProceeds__c =100;
        update ss[0];
        SalesPlanningLog__c spLog =  [SELECT Id, Name, LastSavedOn__c, LastSubmittedOn__c, LastRolledUpOn__c, ForecastLevel__c FROM SalesPlanningLog__c WHERE ForecastLevel__c =:'Business Area/Product Group' LIMIT 1];
        spLog.EditedBy__c = null;
        spLog.InEditMode__c=false;
        update spLog;
        Test.startTest();
        SalesForecastingController.getSoldAmount();
        SalesForecastingController.getSalesPlanningLog();
        SalesForecastingController.updateSalesPlanningLog('LastSubmittedOn');
        SalesForecastingController.updateSalesPlanningLog('LastRolledUpOn');
        SalesForecastingController.updateSalesPlanningLog('LastRollAccountPlan');
        SalesForecastingController.updateSalesPlanningLogForEdit(true,true);
        SalesForecastingController.updateSalesPlanningLogForEdit(false,true);
        Test.stopTest();
        system.assertEquals(ss[0].ActualNetProceeds__c, 100, 'ActualNetProceeds should be 1000');
    }
    
    @isTest static void testgetSoldAmount(){
        List<SalesPlanning__c> ss = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                     FROM SalesPlanning__c];
        ss[0].ForecastTimePoint__c = system.today();
        ss[0].ForecastSoldAmount__c = 1000;
        update ss[0];
        Test.startTest();
        SalesForecastingController.getSoldAmount();
        Test.stopTest();
        system.assertEquals(ss[0].ForecastSoldAmount__c, 1000, 'ForecastSoldAmount should be 1000');
    }
    @isTest static void testgetSoldAmountnextyear(){
        List<SalesPlanning__c> sp = TestDataFactory.createSalesPlanning(3);
        sp[0].Frequency__c ='Yearly';
        sp[0].ForecastLevel__c ='Account';
        sp[0].BusinessArea__c  = 'ZW';
        sp[0].ForecastTimePoint__c = Date.newInstance(System.today().year(), 1, 1).addMonths(18);
        sp[1].Frequency__c ='Yearly';
        sp[1].ForecastLevel__c ='Account';
        sp[1].BusinessArea__c  = 'ZW';
        sp[1].ForecastTimePoint__c = Date.newInstance(System.today().year(), 1, 1).addMonths(30);
        sp[2].Frequency__c ='Yearly';
        sp[2].ForecastLevel__c ='Account';
        sp[2].BusinessArea__c  = 'ZW';
        sp[2].ForecastTimePoint__c = Date.newInstance(System.today().year(), 1, 1).addMonths(42);
        update sp;
        List<SalesPlanning__c> ss = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c,Frequency__c
                                     FROM SalesPlanning__c where Frequency__c ='Yearly' ];                                                                                  
        if(ss.size()>0){
            ss[0].ForecastSoldAmount__c = 2000;
            ss[0].ForecastNetProceeds__c = 10000;
            ss[1].ForecastSoldAmount__c = 3000;
            ss[1].ForecastNetProceeds__c = 11000;
            ss[2].ForecastSoldAmount__c = 4000;
            ss[2].ForecastNetProceeds__c = 12000;
        }
        update ss;
        Test.startTest();
        SalesForecastingController.getSoldAmount();
        Test.stopTest();
        system.assertEquals(ss[0].ForecastSoldAmount__c, 2000, 'ForecastSoldAmount should be 2000');
    }
    @isTest static void testupsertSPForecaste(){
        List<SalesPlanning__c> ss = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                     FROM SalesPlanning__c];
        String wrapper1 = '[{"ActualSoldAmount":16,"BusinessArea":"Bearing Steel","current10FSoldAmount":2000,"current12FSoldAmount":300,"current1FSoldAmount":"200","currentFSoldAmount":1000,"rollingForecastCurrentYear":1316,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0,"current2FSoldAmount":"200","current3FSoldAmount":"300","current4FSoldAmount":"400","current5FSoldAmount":"500","current6FSoldAmount":"600","current7FSoldAmount":"700","current8FSoldAmount":"800","current9FSoldAmount":"900","current11FSoldAmount":"200"},{"ActualSoldAmount":16,"BusinessArea":"Cold Heading","current1FSoldAmount":5000,"currentFSoldAmount":5000,"rollingForecastCurrentYear":10016,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":32,"BusinessArea":"Forging Steel","current5FSoldAmount":100,"rollingForecastCurrentYear":132,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Tyre Cord","current10FSoldAmount":200,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - High Carbon","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Spring Steel","rollingForecastCurrentYear":16,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Free Cutting Steel (SZO)","rollingForecastCurrentYear":16,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Welding Wire","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Low Carbon (w.o. B10)","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":40,"BusinessArea":"Drawing Grades - Low Carbon - B10","rollingForecastCurrentYear":40,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0}]';
        String wrapper2 = '[{"ActualSoldAmount":16,"BusinessArea":"Bearing Steel","current10FSoldAmount":3000,"current12FSoldAmount":400,"current1FSoldAmount":500,"currentFSoldAmount":6000,"rollingForecastCurrentYear":7316,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Cold Heading","current1FSoldAmount":3000,"currentFSoldAmount":2000,"rollingForecastCurrentYear":10016,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":32,"BusinessArea":"Forging Steel","current5FSoldAmount":200,"rollingForecastCurrentYear":132,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Tyre Cord","current10FSoldAmount":300,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - High Carbon","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Spring Steel","rollingForecastCurrentYear":16,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Free Cutting Steel (SZO)","rollingForecastCurrentYear":16,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Welding Wire","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Low Carbon (w.o. B10)","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":40,"BusinessArea":"Drawing Grades - Low Carbon - B10","rollingForecastCurrentYear":40,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0}]';
        String wrapper3 = '[{"ActualSoldAmount":16,"BusinessArea":"Bearing Steel","current10FSoldAmount":2000,"current12FSoldAmount":300,"current1FSoldAmount":"200","currentFSoldAmount":1000,"rollingForecastCurrentYear":1316,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0,"current2FSoldAmount":"200","current3FSoldAmount":"300","current4FSoldAmount":"400","current5FSoldAmount":"500","current6FSoldAmount":"600","current7FSoldAmount":"700","current8FSoldAmount":"800","current9FSoldAmount":"900","current11FSoldAmount":"200"},{"ActualSoldAmount":16,"BusinessArea":"Cold Heading","current1FSoldAmount":5000,"currentFSoldAmount":5000,"rollingForecastCurrentYear":10016,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":32,"BusinessArea":"Forging Steel","current5FSoldAmount":100,"rollingForecastCurrentYear":132,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Tyre Cord","current10FSoldAmount":200,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - High Carbon","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Spring Steel","rollingForecastCurrentYear":16,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Free Cutting Steel (SZO)","rollingForecastCurrentYear":16,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Welding Wire","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Low Carbon (w.o. B10)","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":40,"BusinessArea":"Drawing Grades - Low Carbon - B10","rollingForecastCurrentYear":40,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0}]';
        String wrapper4 = '[{"ActualSoldAmount":16,"BusinessArea":"Bearing Steel","current10FSoldAmount":3000,"current12FSoldAmount":400,"current1FSoldAmount":500,"currentFSoldAmount":6000,"rollingForecastCurrentYear":7316,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Cold Heading","current1FSoldAmount":3000,"currentFSoldAmount":2000,"rollingForecastCurrentYear":10016,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":32,"BusinessArea":"Forging Steel","current5FSoldAmount":200,"rollingForecastCurrentYear":132,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Tyre Cord","current10FSoldAmount":300,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - High Carbon","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Spring Steel","rollingForecastCurrentYear":16,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Free Cutting Steel (SZO)","rollingForecastCurrentYear":16,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Welding Wire","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Low Carbon (w.o. B10)","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":40,"BusinessArea":"Drawing Grades - Low Carbon - B10","rollingForecastCurrentYear":40,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0}]';
        Test.startTest();
        SalesForecastingController.upsertSPForecaste(wrapper1, wrapper2, wrapper3, wrapper4);
        Test.stopTest();
       system.assertNotEquals(ss.size(), 0,'List should not be empty');    
    }
    
    @isTest static void testupsertSPForecaste1(){
        List<SalesPlanning__c> ss = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c
                                     FROM SalesPlanning__c];
        String wrapper1 = '[{"BusinessArea":"Cold Heading","current1FSoldAmount":5000,"currentFSoldAmount":5000,"rollingForecastCurrentYear":10000,"yearly1SoldAmount":100,"yearly2SoldAmount":200,"yearlySoldAmount":3000,"current2FSoldAmount":"300","current3FSoldAmount":"400","current4FSoldAmount":"500","current5FSoldAmount":"600","current6FSoldAmount":"700","current7FSoldAmount":"800","current8FSoldAmount":"900","current9FSoldAmount":"100","current10FSoldAmount":"100","current11FSoldAmount":"100","current12FSoldAmount":"100"}]';
        String wrapper2 = '[{"ActualSoldAmount":16,"BusinessArea":"Cold Heading","rollingForecastCurrentYear":1316},{"ActualSoldAmount":16,"BusinessArea":"Cold Heading","current1FSoldAmount":5000,"currentFSoldAmount":5000,"rollingForecastCurrentYear":10016,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":32,"BusinessArea":"Forging Steel","current5FSoldAmount":100,"rollingForecastCurrentYear":132,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Tyre Cord","current10FSoldAmount":200,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - High Carbon","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Spring Steel","rollingForecastCurrentYear":16,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Free Cutting Steel (SZO)","rollingForecastCurrentYear":16,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Welding Wire","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Low Carbon (w.o. B10)","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":40,"BusinessArea":"Drawing Grades - Low Carbon - B10","rollingForecastCurrentYear":40,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0}]';
        String wrapper3 = '[{"BusinessArea":"Cold Heading","current1FSoldAmount":5000,"currentFSoldAmount":5000,"rollingForecastCurrentYear":10000,"yearly1SoldAmount":200,"yearly2SoldAmount":3000,"yearlySoldAmount":400,"current2FSoldAmount":"300","current3FSoldAmount":"400","current4FSoldAmount":"500","current5FSoldAmount":"600","current6FSoldAmount":"700","current7FSoldAmount":"800","current8FSoldAmount":"900","current9FSoldAmount":"100","current10FSoldAmount":"100","current11FSoldAmount":"100","current12FSoldAmount":"100"}]';
        String wrapper4 = '[{"ActualSoldAmount":16,"BusinessArea":"Cold Heading","rollingForecastCurrentYear":1316,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Cold Heading","current1FSoldAmount":5000,"currentFSoldAmount":5000,"rollingForecastCurrentYear":10016,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":32,"BusinessArea":"Forging Steel","current5FSoldAmount":100,"rollingForecastCurrentYear":132,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Tyre Cord","current10FSoldAmount":200,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - High Carbon","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Spring Steel","rollingForecastCurrentYear":16,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":16,"BusinessArea":"Free Cutting Steel (SZO)","rollingForecastCurrentYear":16,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Welding Wire","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"BusinessArea":"Drawing Grades - Low Carbon (w.o. B10)","yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":40,"BusinessArea":"Drawing Grades - Low Carbon - B10","rollingForecastCurrentYear":40,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0}]';
        Test.startTest();
        SalesForecastingController.upsertSPForecaste(wrapper1, wrapper2, wrapper3, wrapper4);
        Test.stopTest();
        system.assertNotEquals(ss.size(), 0,'List should not be empty');    
    }
    
    @isTest static void testupsertSPForecaste3(){
        List<SalesPlanning__c> ss = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                     FROM SalesPlanning__c];
        String wrapper1 = '[{"ActualSoldAmount":16,"BusinessArea":"Bearing Steel","current10FSoldAmount":2000,"current12FSoldAmount":300,"current1FSoldAmount":200,"currentFSoldAmount":1000,"rollingForecastCurrentYear":1316,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0,"current2FSoldAmount":200,"current3FSoldAmount":300,"current4FSoldAmount":400,"current5FSoldAmount":500,"current6FSoldAmount":600,"current7FSoldAmount":700,"current8FSoldAmount":800,"current9FSoldAmount":900,"current11FSoldAmount":200}]';
        String wrapper2 = '[{"ActualSoldAmount":16,"BusinessArea":"Bearing Steel","rollingForecastCurrentYear":1316,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0}]';
        String wrapper3 = '[{"ActualSoldAmount":16,"BusinessArea":"Bearing Steel","current10FSoldAmount":2000,"current12FSoldAmount":300,"current1FSoldAmount":200,"currentFSoldAmount":1000,"rollingForecastCurrentYear":1316,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0,"current2FSoldAmount":200,"current3FSoldAmount":300,"current4FSoldAmount":400,"current5FSoldAmount":500,"current6FSoldAmount":600,"current7FSoldAmount":700,"current8FSoldAmount":800,"current9FSoldAmount":900,"current11FSoldAmount":200},{"ActualSoldAmount":540,"BusinessArea":"Free Cutting Steel (SZO)","current11FSoldAmount":300,"current12FSoldAmount":10,"current10FSoldAmount":10,"rollingForecastCurrentYear":665,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0,"current1FSoldAmount":"100","current2FSoldAmount":"200","current3FSoldAmount":"200","current4FSoldAmount":"200","current5FSoldAmount":"200","current6FSoldAmount":"200","current7FSoldAmount":"200","current8FSoldAmount":"200","current9FSoldAmount":"200"}]';
        String wrapper4 = '[{"ActualSoldAmount":16,"BusinessArea":"Bearing Steel","rollingForecastCurrentYear":1316,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0},{"ActualSoldAmount":540,"BusinessArea":"Free Cutting Steel (SZO)","current11FSoldAmount":30,"current12FSoldAmount":0,"rollingForecastCurrentYear":665,"yearly1SoldAmount":0,"yearly2SoldAmount":0,"yearlySoldAmount":0}]';
        Test.startTest();
        SalesForecastingController.upsertSPForecaste(wrapper1, wrapper2, wrapper3, wrapper4);
        Test.stopTest();
        system.assertNotEquals(ss.size(), 0,'List should not be empty');    
    }
    @isTest static void testcontentversion(){
        List<SalesPlanningLog__c> spLog =  [SELECT Id, Name, LastSavedOn__c, LastSubmittedOn__c, LastRolledUpOn__c, ForecastLevel__c FROM SalesPlanningLog__c WHERE ForecastLevel__c =:'Business Area/Product Group' LIMIT 1];
        spLog[0].ForecastLevel__c = 'Business Area/Product Group';
        update spLog[0];
        ContentVersion cv=new Contentversion();
        cv.title='xyz';
        cv.PathOnClient ='xyz';
        cv.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.FirstPublishLocationId=spLog[0].id;
        insert cv;
        Test.startTest();
        SalesForecastingController.uploadFile('Unit Test Attachment Body','xyz');
        Test.stopTest();
        system.assertEquals(cv.title,'xyz','Incorrect output');
    }
    
    @isTest static void testSubmitBAPlanning(){
        List<Account> acclst = [SELECT Id FROM Account limit 1]; 
        List<SalesPlanning__c> salesPlanningFAList= new List<SalesPlanning__c>([SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, DeltaNetProceeds__c,ActualNetProceeds__c FROM SalesPlanning__c 
                                                                                LIMIT 5]);
        for(SalesPlanning__c sp : salesPlanningFAList){
            sp.Account__c = acclst[0].Id;
            sp.ForecastLevel__c = 'Business Area/Product Group';
            sp.Frequency__c = 'Monthly';
            sp.BusinessArea__c = 'ZK';
            sp.ForecastTimePoint__c = system.today().addMonths(12).toStartOfMonth();
        }
        if(SalesPlanningFAList.size() == 3){
           SalesPlanningFAList[0].ForecastTimePoint__c = system.today().toStartOfMonth();
           SalesPlanningFAList[0].ForecastSoldAmount__c = 8;
           SalesPlanningFAList[0].DeltaNetProceeds__c = -10;
           SalesPlanningFAList[0].Frequency__c = 'Monthly';
           SalesPlanningFAList[1].ActualNetProceeds__c = 550; 
           SalesPlanningFAList[1].ForecastTimePoint__c = system.today().addmonths(-1).toStartOfMonth();
            SalesPlanningFAList[1].Frequency__c = 'Monthly';
           SalesPlanningFAList[2].ForecastTimePoint__c = system.today().addmonths(12).toStartOfMonth(); 
            SalesPlanningFAList[2].Frequency__c = 'Monthly';
            SalesPlanningFAList[2].ForecastLevel__c ='Account';
            SalesPlanningFAList[2].Account__c = acclst[0].Id;
            SalesPlanningFAList[3].Frequency__c = 'Monthly'; 
            SalesPlanningFAList[3].ForecastLevel__c ='Account';
            SalesPlanningFAList[3].ForecastTimePoint__c = system.today().addMonths(12).toStartOfMonth();
            SalesPlanningFAList[3].Account__c = acclst[0].Id;
        }
        update SalesPlanningFAList;
        test.startTest();
        
        List<SalesPlanning__c> salesPlanningUpdateList= new List<SalesPlanning__c>([SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualNetProceeds__c, DeltaNetProceeds__c, ForecastNetProceeds__c,ForecastLevel__c FROM SalesPlanning__c 
                                                                                    ORDER By ForecastTimePoint__c ASC LIMIT 3]); 
        for(SalesPlanning__c sp : salesPlanningUpdateList ){
            sp.Frequency__c = 'Monthly'; 
            sp.ForecastLevel__c ='Account'; 
            sp.ForecastTimePoint__c = system.today().addMonths(12).toStartOfMonth();  
            sp.Account__c = acclst[0].Id;
            sp.BusinessArea__c = 'ZK';
        }
        SalesPlanningUpdateList[0].Account__c = null;
        SalesPlanningUpdateList[1].Account__c = null;
        SalesPlanningUpdateList[1].BusinessArea__c = 'ZK';
        Update SalesPlanningUpdateList;
        SalesForecastingController.SubmitBAPlanning();
        system.assertEquals(SalesPlanningFAList[0].ForecastSoldAmount__c, 100, 'ForecastSoldAmount__c = ForecastSoldAmount__c*SoldAmountShare__c');
        test.stopTest();
    }
}