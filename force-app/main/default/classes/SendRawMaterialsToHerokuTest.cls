/****************************************************************************
* Name: SendRawMaterialsToHerokuTest
* Author: Harshitha U
* Created Date: 1/12/2022
* Description: Test class for SendRawMaterialsToHeroku
*****************************************************************************
* Modification log
* Name		     Date	           		Description
* Developer Name	Date of Modification	Modification Description   
****************************************************************************/
@isTest
public class SendRawMaterialsToHerokuTest {
    @testSetup static void setUpData() { 
        List<RawMaterial__c> rm = TestDataFactory.createRM(1);
        OrgWideSettings__c setting = new OrgWideSettings__c();
        setting.Name = 'Org Wide Info';
        setting.ActivateAlternateBasicPlan__c = false;
        setting.Rawmateriallastupdatedon__c = System.today();
        insert setting;
    }
     @isTest static void testPostCallout(){
        Test.startTest();
        SendRawMaterialsToHeroku.RawMaterialData  wrp = new SendRawMaterialsToHeroku.RawMaterialData();
        Test.setMock(HttpCalloutMock.class, new MockSuccess());
        List<RawMaterial__c> rm1 = new List<RawMaterial__c>();
        List<List<RawMaterial__c>> rm2 = new List<List<RawMaterial__c>>();
        rm1= [Select Id,MaterialNumber__c,TimePoint1__c, TimePoint10__c, TimePoint11__c, 
                                     TimePoint12__c, TimePoint13__c, TimePoint14__c, TimePoint15__c, TimePoint16__c, TimePoint3__c, TimePoint4__c, TimePoint5__c, TimePoint6__c, TimePoint7__c, TimePoint8__c, TimePoint9__c, TimePoint17__c, TimePoint18__c, TimePoint2__c,
                                     RLevel2__c, RLevel1__c, RLevel3__c,Type__c,error__c from RawMaterial__c];
        rm2.add(rm1);
        SendRawMaterialsToHeroku.sendDataToHeroku(rm2);
         List<RawMaterial__c> rawmaterialList= [Select Id,MaterialNumber__c,TimePoint1__c, TimePoint10__c, TimePoint11__c, 
                                     TimePoint12__c, TimePoint13__c, TimePoint14__c, TimePoint15__c, TimePoint16__c, TimePoint3__c, TimePoint4__c, TimePoint5__c, TimePoint6__c, TimePoint7__c, TimePoint8__c, TimePoint9__c, TimePoint17__c, TimePoint18__c, TimePoint2__c,
                                     RLevel2__c, RLevel1__c, RLevel3__c,Type__c,error__c from RawMaterial__c];
         System.assertEquals(rawmaterialList.size(), 0, 'Incorrect output');
        Test.stopTest();
    }
    
        @isTest static void testErrorPostCallout(){
        Test.startTest();
        SendRawMaterialsToHeroku.RawMaterialData  wrp = new SendRawMaterialsToHeroku.RawMaterialData();
        Test.setMock(HttpCalloutMock.class, new Mock());
        List<RawMaterial__c> rm1 = new List<RawMaterial__c>();
        List<List<RawMaterial__c>> rm2 = new List<List<RawMaterial__c>>();
        rm1= [Select Id,MaterialNumber__c,TimePoint1__c, TimePoint10__c, TimePoint11__c, 
                                     TimePoint12__c, TimePoint13__c, TimePoint14__c, TimePoint15__c, TimePoint16__c, TimePoint3__c, TimePoint4__c, TimePoint5__c, TimePoint6__c, TimePoint7__c, TimePoint8__c, TimePoint9__c, TimePoint17__c, TimePoint18__c, TimePoint2__c,
                                     RLevel2__c, RLevel1__c, RLevel3__c,Type__c,error__c from RawMaterial__c];
        rm2.add(rm1);
        SendRawMaterialsToHeroku.sendDataToHeroku(rm2);
         List<RawMaterial__c> rawmaterialList= [Select Id,MaterialNumber__c,TimePoint1__c, TimePoint10__c, TimePoint11__c, 
                                     TimePoint12__c, TimePoint13__c, TimePoint14__c, TimePoint15__c, TimePoint16__c, TimePoint3__c, TimePoint4__c, TimePoint5__c, TimePoint6__c, TimePoint7__c, TimePoint8__c, TimePoint9__c, TimePoint17__c, TimePoint18__c, TimePoint2__c,
                                     RLevel2__c, RLevel1__c, RLevel3__c,Type__c,error__c from RawMaterial__c];
         System.assertNotEquals(rawmaterialList.size(), 0, 'Incorrect output');
        Test.stopTest();
    }
    
    @isTest static void testNegative(){
        Test.startTest();
        SendRawMaterialsToHeroku.RawMaterialData  wrp = new SendRawMaterialsToHeroku.RawMaterialData();
        Test.setMock(HttpCalloutMock.class, new Mock());
        List<RawMaterial__c> rm1 = new List<RawMaterial__c>();
        List<List<RawMaterial__c>> rm2 = new List<List<RawMaterial__c>>();
        rm1= [Select Id,MaterialNumber__c,TimePoint1__c, TimePoint10__c, TimePoint11__c, 
                                     TimePoint12__c, TimePoint13__c, TimePoint14__c, TimePoint15__c, TimePoint16__c, TimePoint3__c, TimePoint4__c, TimePoint5__c, TimePoint6__c, TimePoint7__c, TimePoint8__c, TimePoint9__c, TimePoint17__c, TimePoint18__c, TimePoint2__c,
                                     RLevel2__c, RLevel1__c, RLevel3__c from RawMaterial__c];
        rm2.add(rm1);
        SendRawMaterialsToHeroku.sendDataToHeroku(rm2);
        List<RawMaterial__c> rawmaterialList= [Select Id,MaterialNumber__c,TimePoint1__c, TimePoint10__c, TimePoint11__c, 
                                     TimePoint12__c, TimePoint13__c, TimePoint14__c, TimePoint15__c, TimePoint16__c, TimePoint3__c, TimePoint4__c, TimePoint5__c, TimePoint6__c, TimePoint7__c, TimePoint8__c, TimePoint9__c, TimePoint17__c, TimePoint18__c, TimePoint2__c,
                                     RLevel2__c, RLevel1__c, RLevel3__c,Type__c,error__c from RawMaterial__c];
         System.assertNotEquals(rawmaterialList.size(), 0, 'Incorrect output');
        Test.stopTest();
    }
    
    private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status": "error","message": "Raw material records not created.","data": [{ "material_raw_id": "00000001","type": "E","status_code": 400,"status_message": "duplicate material_raw_id and type combination"}]}');     
            response.setStatusCode(400);
            return response; 
        }
    }
    private class MockSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status": "Success"}');     
            response.setStatusCode(200);
            return response; 
        }
    }
}
