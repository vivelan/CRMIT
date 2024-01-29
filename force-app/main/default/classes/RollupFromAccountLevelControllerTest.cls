/****************************************************************************
* Name: RollupFromAccountLevelControllerTest
* Author: Naina B
* Created Date: 28/03/2023
* Description: Test class for RollupFromAccountLevelController
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
****************************************************************************/
@isTest
public class RollupFromAccountLevelControllerTest {
    @testSetup
    static void setUpData(){
        List<SalesPlanning__c> sPLST = TestDataFactory.createSalesPlanning(13);
       List<SalesPlanning__c> spListAccount = TestDataFactory.createSalesPlanningAccount(13);
        List<SalesPlanning__c> spListYearly = TestDataFactory.createYearlySalesPlanning(4);
        List<SalesPlanning__c> spListAccountYearly = TestDataFactory.createAccountYearlySalesPlanning(4);
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.year();
        Date fTp;
        List<SalesPlanning__c> SalesPlanBussiness = new List<SalesPlanning__c>();
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
                sp.BusinessArea__c  = 'ZW';
                sp.ForecastSoldAmount__c = 100 + i;
                sp.ForecastNetProceeds__c = 100 + i;
                SalesPlanBussiness.add(sp);
                
                SalesPlanning__c spAccount = spListAccount[i];
                spAccount.ForecastTimePoint__c = fTp;
                spAccount.BusinessArea__c  = 'ZW';
                spAccount.ForecastSoldAmount__c = 100 + i;
                spAccount.ForecastNetProceeds__c = 100 + i;
                spAccount.Frequency__c ='Monthly';
                SalesPlanBussiness.add(spAccount);
            }
        for(integer i=0 ; i <=3 ; i++){
             fTp = Date.newInstance(currentYear + i, i, 1);
             SalesPlanning__c spAccount = spListYearly[i];
                spAccount.ForecastTimePoint__c = fTp;
                spAccount.BusinessArea__c  = 'ZW';
                spAccount.ForecastSoldAmount__c = 100 + i;
                spAccount.ForecastNetProceeds__c = 100 + i;
                spAccount.DeltaNetProceeds__c = 100 + i;
                SalesPlanBussiness.add(spAccount);
            
             SalesPlanning__c spAccountYr = spListAccountYearly[i];
                spAccountYr.ForecastTimePoint__c = fTp;
                spAccountYr.BusinessArea__c  = 'ZW';
                spAccountYr.ForecastSoldAmount__c = 100 + i;
                spAccountYr.ForecastNetProceeds__c = 100 + i;
                spAccountYr.DeltaNetProceeds__c = 100 + i;
                SalesPlanBussiness.add(spAccountYr);
        }
        
        update SalesPlanBussiness;
    }
  
    @isTest static void testOLIRecord(){
      List<SalesPlanning__c> ss = [SELECT Id, Account__c, BusinessArea__c, ForecastTimePoint__c, ForecastSoldAmount__c, ActualSoldAmount__c, ForecastNetProceeds__c, ActualNetProceeds__c, ForecastLevel__c, DeltaNetProceeds__c 
                                                                                       FROM SalesPlanning__c];
        Test.startTest();

         RollupFromAccountLevelController.rollupFromAccountLevelCal();
         RollupFromAccountLevelController.rollupAnnualPlanningCal();

        Test.stopTest();
        system.assertNotEquals(ss.size(), 0,'List should not be empty');
    }
}