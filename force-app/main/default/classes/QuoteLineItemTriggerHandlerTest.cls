@isTest
public class QuoteLineItemTriggerHandlerTest {
    @testSetup
    static void setUpData(){
        List<User> userList = TestDataFactory.createUser(3);
        System.runAs(userList[0]) {
            List<Account> act = TestDataFactory.createAccounts(1);
            act[0].ChannelOfDistribution__c = '11';
            update act;
            Account acc = [Select Id, Name, ChannelOfDistribution__c from Account limit 1];
            List<Opportunity> opplst = TestDataFactory.createOpps(1);
            opplst[0].AccountId = acc.id;
            opplst[0].ChannelOfDistribution__c = '11';
            update opplst;  
            TestDataFactory.createdocumentTemplate(1);
            List<DocumentTemplate> Quoteserversidedoclst = [SELECT Id, Name, Language__c, CreatedDate, CreatedBy.name FROM DocumentTemplate Limit 1];
            IF(!Quoteserversidedoclst.isempty()){
                Quoteserversidedoclst[0].Name = ConstantClass.QUOTE_DOC_NAME_EN;
                Quoteserversidedoclst[0].Language__c = 'EN';
                update Quoteserversidedoclst;
            }
            OrgWideSettings__c setting = new OrgWideSettings__c();
            setting.Name = 'Org Wide Info';
            setting.ActivateAlternateBasicPlan__c = false;
            setting.Rawmateriallastupdatedon__c = System.today();
            insert setting;
        }
    }
    @isTest
    static void testAfterInsert() {
        Test.startTest();
        Account acc = [SELECT Id, Name, ChannelOfDistribution__c FROM Account WHERE Name = 'TestAccount0' limit 1];
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'Opportunitywithquotecreations'];
        List<Product2> prdlst = testdatafactory.createProduct(1);
        Opportunity op = new Opportunity(Name = 'Test',
                                         StageName = 'New',
                                         CloseDate = System.today().addMonths(1),
                                         AccountId = acc.Id,
                                         RecordTypeId = rt.ID,
                                         QuoteOfferedDate__c= System.today(),
                                         ChannelOfDistribution__c = '11',
                                         OpportunityType__c = 'Standard Inquiry',
                                         BusinessArea__c ='ZK',
                                         DateOfReceipt__c = System.today(),
                                         CurrencyIsoCode ='EUR',
                                         CalculationTimePoint__c = 'Monthly',
                                         QuoteValidTill__c = System.today(),
                                         Incoterms__c = 'CAD - CAD',
                                         DateOf_Payment__c = 'AA',
                                         Type = 'Existing Business'
                                        );
        
        PricebookEntry customPrice = testdatafactory.customPriceBook();
        op.Pricebook2Id = customPrice.Pricebook2Id;
        insert op;
        
        OpportunityLineItem OLI = new OpportunityLineItem();
        OLI.OpportunityId = op.Id;
        OLI.Status__c = 'Active';
        OLI.Product2Id = prdlst[0].Id;  
        OLI.UnitOfMeasurement__c = 'MM';
        OLI.Quantity = 5;
        OLI.UnitPrice = 10;
        OLI.HeatTreatmentSales__c = '+T-Tempered';
        OLI.CustomerSteelGrade__c = 'sdfdrg';
        OLI.SurfaceCondition__c ='As Rolled';
        OLI.UnitOfMeasurement__c = 'Inch';
        OLI.PurposeOfUse__c ='2-TRADE';
        OLI.Certificate__c ='No Certificate';
        OLI.ShortPiece__c = true;
        OLI.DimensionAFrom__c = 2.2;
        OLI.FinalPrice__c =0;
        OLI.Surcharge1__c =1;
        OLI.FreightCosts__c =1;
        OLI.QuantityUnit__c ='Moto';
        OLI.DimensioncalculationA__c = 1;
        OLI.UsePricingTool__c = true;
        if(OLI != null){
            Insert OLI;
        }
        Quote qo = new Quote();
        qo.Name = 'TestQuote';
        qo.Pricebook2Id = customPrice.Pricebook2Id;
        qo.OpportunityId =op.id; 
        insert qo;
        qo.Status = ConstantClass.OFFERED_STATUS;
        update qo;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qo.Id;
        qli.Quantity = 1;
        qli.UnitPrice = 100;
        qli.PricebookEntryId = customPrice.Id;
        qli.Product2Id = OLI.Product2Id;
        qli.OpportunityLineItemId = OLI.Id;
        insert qli;
        List<QuoteLineItem> insertedQLIs = [SELECT Id FROM QuoteLineItem WHERE QuoteId = :qo.Id LIMIT 1];
        system.assertEquals(1, insertedQLIs.size(), 'A new QuoteLineItem should be created for the given QuoteID'); //assert that trigger worked properly
        
        Test.stopTest();
    }
    
    @isTest
    static void testAfterInsert1() {
        Test.startTest();
        Account acc = [SELECT Id, Name, ChannelOfDistribution__c, Language__c FROM Account WHERE Name = 'TestAccount0' limit 1];
        acc.Language__c ='DE';
        update acc;
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'Opportunitywithquotecreations'];
        List<DocumentTemplate> Quoteserversidedoclst = [SELECT Id, Name, Language__c, CreatedDate, CreatedBy.name FROM DocumentTemplate Limit 1];
            IF(!Quoteserversidedoclst.isempty()){
                Quoteserversidedoclst[0].Name = ConstantClass.QUOTE_DOC_NAME_EN;
                Quoteserversidedoclst[0].Language__c = 'DE';
                update Quoteserversidedoclst;
            }
        List<Product2> prdlst = testdatafactory.createProduct(1);
        Opportunity op = new Opportunity(Name = 'Test',
                                         StageName = 'New',
                                         CloseDate = System.today().addMonths(1),
                                         AccountId = acc.Id,
                                         RecordTypeId = rt.ID,
                                         QuoteOfferedDate__c= System.today(),
                                         ChannelOfDistribution__c = '11',
                                         OpportunityType__c = 'Standard Inquiry',
                                         BusinessArea__c ='ZK',
                                         DateOfReceipt__c = System.today(),
                                         CurrencyIsoCode ='EUR',
                                         CalculationTimePoint__c = 'Monthly',
                                         QuoteValidTill__c = System.today(),
                                         Incoterms__c = 'CAD - CAD',
                                         DateOf_Payment__c = 'AA',
                                         Language__c = 'DE',
                                         Type = 'Existing Business'
                                        );
        
        PricebookEntry customPrice = testdatafactory.customPriceBook();
        op.Pricebook2Id = customPrice.Pricebook2Id;
        insert op;
        
        OpportunityLineItem OLI = new OpportunityLineItem();
        OLI.OpportunityId = op.Id;
        OLI.Status__c = 'Active';
        OLI.Product2Id = prdlst[0].Id;  
        OLI.UnitOfMeasurement__c = 'MM';
        OLI.Quantity = 5;
        OLI.UnitPrice = 10;
        OLI.HeatTreatmentSales__c = '+T-Tempered';
        OLI.CustomerSteelGrade__c = 'sdfdrg';
        OLI.SurfaceCondition__c ='As Rolled';
        OLI.UnitOfMeasurement__c = 'Inch';
        OLI.PurposeOfUse__c ='2-TRADE';
        OLI.Certificate__c ='No Certificate';
        OLI.ShortPiece__c = true;
        OLI.DimensionAFrom__c = 2.2;
        OLI.FinalPrice__c =0;
        OLI.Surcharge1__c =1;
        OLI.FreightCosts__c =1;
        OLI.QuantityUnit__c ='Moto';
        OLI.DimensioncalculationA__c = 1;
        OLI.UsePricingTool__c = true;
        if(OLI != null){
            Insert OLI;
        }
        Quote qo = new Quote();
        qo.Name = 'TestQuote';
        qo.Pricebook2Id = customPrice.Pricebook2Id;
        qo.OpportunityId =op.id; 
        insert qo;
        qo.Status = ConstantClass.OFFERED_STATUS;
        update qo;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qo.Id;
        qli.Quantity = 1;
        qli.UnitPrice = 100;
        qli.PricebookEntryId = customPrice.Id;
        qli.Product2Id = OLI.Product2Id;
        qli.OpportunityLineItemId = OLI.Id;
        insert qli;
        List<QuoteLineItem> insertedQLIs = [SELECT Id FROM QuoteLineItem WHERE QuoteId = :qo.Id LIMIT 1];
        system.assertEquals(1, insertedQLIs.size(), 'A new QuoteLineItem should be created for the given QuoteID'); //assert that trigger worked properly
        
        Test.stopTest();
    }
}