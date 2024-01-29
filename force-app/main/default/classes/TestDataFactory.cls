/****************************************************************************
* Name: TestDataFactory
* Author: Harshitha U
* Created Date: 22/08/2022
* Description: Test Utility Class which contains test data creation for test classes.
*****************************************************************************/
@isTest
public class TestDataFactory {
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to create Test Accounts
* Created Date: 22/08/2022
* Last Modified Date: 22/08/2022
****************************************************************************/
    public static List<Account> createAccounts(Integer numAccts) {
        
        List<Account> accts = new List<Account>();
        for( Integer i = 0; i<numAccts; i++) {
            Account a = new Account(Name='TestAccount' + i, Inactive__c = true, Phone='+91234567895'+i , CustomerSize__c = 3.00,Language__c ='EN');
            accts.add(a);
        }
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            Database.insert(accts, dml);
        return accts;
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to create Test Lead Records
* Created Date: 22/08/2022
* Last Modified Date: 22/08/2022
****************************************************************************/
    public static List<Lead> createLeads(Integer numlds) {
        List<Lead> lstleads = new List<Lead>();
        for(integer i = 0; i < numlds; i++) {
            Lead objLead = new Lead( FirstName = 'Test', LastName = 'Sample', Company = 'Testing Sample Co');  
            lstleads.add(objLead);
        }
        INSERT lstleads; 
        return lstleads;
    }  
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to create Test Account with Contacts
* Created Date: 22/08/2022
* Last Modified Date: 22/08/2022
****************************************************************************/
    public static List<Contact> createAccountwithContact(Integer numAccts, Integer numContactsPerAcct) {
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        accounts = createAccounts(numAccts);
        for (integer i = 0; i < numAccts; i++) {
            for (integer j = numContactsPerAcct * i; j < numContactsPerAcct * (i + 1); j++) {
                contacts.add(new Contact(
                    FirstName = 'Test' + j,
                    LastName = 'Test' + j,
                    AccountId = accounts[i].Id
                ));
            }
        }
        INSERT contacts;
        return contacts;
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to create Test Opportunities
* Created Date: 22/08/2022
* Last Modified Date: 22/08/2022
****************************************************************************/
    public static List<Opportunity> createOpps(Integer numOpps) {
        List<Account> alst = new List<Account> ();
        alst = [SELECT Id, Name, Phone,ChannelOfDistribution__c from Account];
        if(alst.isempty()){
            alst = createAccounts(1); 
        }
        OrgWideSettings__c csobj=new OrgWideSettings__c();
        csobj.Rawmateriallastupdatedon__c=System.today().addMonths(5);
        csobj.name ='Org Wide Info Test';
        insert csobj;
        List<Opportunity> opps = new List<Opportunity>();
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'Opportunitywithquotecreations'];
        for (Integer k = 0; k < numOpps; k++) {
            opps.add(new Opportunity(Name = 'TestOpportunity ' + k,
                                     AccountId=alst[0].Id,
                                     ChannelOfDistribution__c = '11',
                                     StageName = 'New',
                                     RecordTypeId = rt.ID,
                                     CloseDate = System.today().addMonths(1),
                                     AppointedDayCalculation__c = System.today().addMonths(1),
                                     RMUDcheck__c = false,
                                     Pricebook2Id = Test.getStandardPricebookId(),
                                     Language__c = 'EN',
                                     OpportunityType__c = 'Standard Inquiry',
                                     BusinessArea__c ='ZK',
                                     DateOfReceipt__c = System.today(),
                                     CurrencyIsoCode ='EUR',
                                     //AppointedDayCalculation__c = system.today(),
                                     Type = 'Existing Business'  
                                    ));
        }
        INSERT opps;
        return opps;
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to create Test Account with Opportunities
* Created Date: 22/08/2022
* Last Modified Date: 22/08/2022
****************************************************************************/
    public static List<Account> createAccountsWithOpps(Integer numAccts, Integer numOppsPerAcct) {
        List<Account> accts = new List<Account>();
        List<Opportunity> opps = new List<Opportunity>();
        accts = createAccounts(numAccts); 
        for (Integer j = 0; j < numAccts; j++) {
            Account acct = accts[j];
            for (Integer k = 0; k < numOppsPerAcct; k++) {
                opps.add(new Opportunity(Name = acct.Name + ' Opportunity ' + k,
                                         StageName = 'New',
                                         CloseDate = System.today().addMonths(1),
                                         AccountId = acct.Id,
                                         OpportunityType__c = 'Standard Inquiry',
                                         BusinessArea__c ='ZK',
                                         DateOfReceipt__c = System.today(),
                                         CurrencyIsoCode ='EUR',
                                         Type = 'Existing Business',
                                        ChannelOfDistribution__c = '11'));
            }
        }
        INSERT opps;
        return accts;
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to Insert a List of sobjects
* Created Date: 24/08/2022
* Last Modified Date: 24/08/2022
****************************************************************************/
    @testVisible
    private void insertListOfsObject(List<SObject> sObjList){
        Database.SaveResult[] saveResults = Database.insert(sObjList, false);
        List<ExceptionLog__e> pelist = new List<ExceptionLog__e>();
        ExceptionLog__e pe;
        for (Database.SaveResult saveResult : saveResults) {
            pe = new ExceptionLog__e();
            String excdetail;
            for(Database.Error err : saveResult.getErrors()) {
                excdetail+= err.getStatusCode() + ':' + err.getMessage();
            }
            String detail = new dmlException().getStackTraceString();
            pe.ExceptionDetails__c = excdetail+detail;
            pelist.add(pe);
        }
        eventBus.publish(pelist);
    }
    /****************************************************************************
* Author Name: Naina Butle
* Description: Method to create Test OpportunityLineItem
* Created Date: 14/09/2022
* Last Modified Date: 
****************************************************************************/
    public static OpportunityLineItem oppLineItemTestData(){
        List<TechnicalRequirement__c> t = createTR(1);
        List<TechnicalRequirement__c> tRlst = [SELECT Id, Active__c, Account__c, FinishedGoods__c, Opportunity__c,Opportunity__r.Pricebook2Id, OpportunityProduct__c, FinishedGoods__r.Product__c, Quantity__c, Product__c FROM TechnicalRequirement__c  
                                               WHERE ID =: t[0].Id LIMIT 1]; 
        List<Product2> prod = createProduct(1);
        prod[0].IsActive = true;
        update prod;
        PricebookEntry customPrice = customPriceBook();
        List<FinishedGoods__c> FMNs = createFMN(1);
        createIOs(4);
        DateTime dt = system.Now();
        OpportunityLineItem oli = new OpportunityLineItem();
         if(tRlst[0].Opportunity__r.Pricebook2Id != customPrice.Pricebook2Id){
            list<PricebookEntry> lstpbe = [select id,Pricebook2Id from PricebookEntry where Pricebook2Id = :tRlst[0].Opportunity__r.Pricebook2Id AND Product2Id = :prod[0].Id ];
            if(lstpbe.size()>0){
                  oli = new OpportunityLineItem(OpportunityId = tRlst[0].Opportunity__c, FinishedGoods__c = fMNs[0].Id, TechnicalRequirement__c = tRlst[0].Id, Product2Id = prod[0].Id, Quantity = 5, PricebookEntryId = lstpbe[0].Id, DateOfDelivery__c = dt.date(),UsePricingTool__c = true,UnitOfMeasurement__c = 'Inch', PurposeOfUse__c = '1-UNKNOWN',ShortPiece__c =true, DimensionAFrom__c =3,QuantityUnit__c = 'Moto',DimensioncalculationA__c =7);
            }else{
                PricebookEntry pbe = createpriceBookEntry();
                 oli = new OpportunityLineItem(OpportunityId = tRlst[0].Opportunity__c, FinishedGoods__c = fMNs[0].Id, TechnicalRequirement__c = tRlst[0].Id, Product2Id = prod[0].Id, Quantity = 5, PricebookEntryId = pbe.Id,  DateOfDelivery__c = dt.date(),UsePricingTool__c = true,UnitOfMeasurement__c = 'Inch', PurposeOfUse__c = '1-UNKNOWN',ShortPiece__c =true, DimensionAFrom__c =3,QuantityUnit__c = 'Moto',DimensioncalculationA__c =7);
             }
        }else{
            oli = new OpportunityLineItem(OpportunityId = tRlst[0].Opportunity__c, FinishedGoods__c = fMNs[0].Id, TechnicalRequirement__c = tRlst[0].Id, Product2Id = prod[0].Id, Quantity = 5, PricebookEntryId = customPrice.Id, DateOfDelivery__c = dt.date(),UsePricingTool__c = true,UnitOfMeasurement__c = 'Inch', PurposeOfUse__c = '1-UNKNOWN',ShortPiece__c =true, DimensionAFrom__c =3,QuantityUnit__c = 'Moto',DimensioncalculationA__c =7);
        }
        oli.UnitPrice = 10;       
        INSERT oli;
        return oli;
    }
    /****************************************************************************
* Author Name: Priyanka Kumari
* Description: Method to create Invoiced Orders called from oppLineItemTestData()
* Created Date: 31/01/2023
* Last Modiied Date: 
****************************************************************************/
    public static List<InvoicedOrders__c> createIOs(Integer numIOs) {
        List<InvoicedOrders__c> IOs = new List<InvoicedOrders__c>();
        List<Account> alst = [SELECT Id from Account];
        
        for (Integer k = 0; k < numIOs; k++) {
            IOs.add(new InvoicedOrders__c(Name = 'Test IO ' + k, Account__c = alst[0].Id, MaterialNumber__c = '111'+ k, Nettoerloes__c = 1000, InvoiceDate__c = System.today().addMonths(-k), ProductGroupBusinessArea__c = 'Low Carbon',BusinessArea__c = 'ZZ', SoldAmount__c = 50, ProductCategoryBusinessArea__c = 'B10'));
        }
        INSERT IOs;
        return IOs;
    }
    
    /****************************************************************************
* Author Name: Priyanka Kumari
* Description: Method to create FMN called from oppLineItemTestData()
* Created Date: 31/01/2023
* Last Modiied Date: 
****************************************************************************/
    public static List<FinishedGoods__c> createFMN(Integer numFMN) {
        List<FinishedGoods__c> FMNs = new List<FinishedGoods__c>();
        SteelGrade__c st = new SteelGrade__c();
        st.SELNumber__c = '123';
        st.Name = 'xyz';
        st.ExternalID__c = 'ABC';
        insert st;
        List<Product2> prod = createProduct(1);
        for (Integer k = 0; k < numFMN; k++) {
            FMNs.add(new FinishedGoods__c(Name = 'Test FMN ' + k, Product__c = prod[0].Id , MaterialNumber__c = '111'+k, SteelGradeLookup__c = st.id, DimensionA__c = 12, RollingMill__c = 'rm', ExternalID__c = 'extid'));
        }
        INSERT FMNs;
        return FMNs;
    }
    
    /****************************************************************************
* Author Name: Naina Butle
* Description: Method to create Test Standard PricebookEntry
* Created Date: 09/01/2023
* Last Modified Date: 
****************************************************************************/ 
    public static PricebookEntry createpriceBookEntry(){
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true); 
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        update standardPricebook;
        List<Product2> prod = createProduct(1);
        Id pricebookId = standardPricebook.Id;
        List<PricebookEntry> pricebookEntries = [SELECT Id, Name, Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, IsActive, UseStandardPrice,
                                                 ProductCode
                                                 FROM PricebookEntry
                                                WHERE Pricebook2Id =:pricebookId AND Product2Id=:prod[0].Id];
        
        if(pricebookEntries.isEmpty())
        {            
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod[0].Id, UnitPrice = 10000, IsActive = true);
            INSERT pbEntry;
            return pbEntry;
        }
        return pricebookEntries.get(0);
    }
    
    /****************************************************************************
* Author Name: Naina Butle
* Description: Method to create Test Custom PricebookEntry
* Created Date: 14/09/2022
* Last Modified Date: 
****************************************************************************/    
    public static PricebookEntry customPriceBook(){        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;
        List<Product2> plst = new List<Product2>();
        plst = [SELECT ID FROM Product2];
        if(plst.isempty()){
            plst = createProduct(1); 
        }
        List<Product2> prod =  plst;
        List<PricebookEntry> pricebookEntries = [SELECT Id, Name, Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, IsActive, UseStandardPrice,
                                                 ProductCode
                                                 FROM PricebookEntry
                                                WHERE Pricebook2Id =:pricebookId AND Product2Id=:prod[0].Id];
        if(pricebookEntries.isEmpty())
        {
            PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = prod[0].Id, UnitPrice = 10000, IsActive = true,CurrencyIsoCode ='EUR',UseStandardPrice = true);
            INSERT standardPrice;
            
        }
        Pricebook2 customPB = new Pricebook2(Name = 'SAG', isActive = true);
        INSERT customPB;  
        PricebookEntry customPrice = new PricebookEntry();
              customPrice = [Select id, Product2Id, Pricebook2Id, UnitPrice, IsActive from PricebookEntry LIMIT 1];
        if(customPrice == null){
       customPrice = new PricebookEntry(Pricebook2Id = standardPricebook.Id, UnitPrice =2000, Product2Id = prod[0].Id, IsActive = true,CurrencyIsoCode ='EUR');
       INSERT customPrice;
        }
        return customPrice;
    }
    
    /****************************************************************************
* Author Name: Naina Butle
* Description: Method to create Test Standard Pricebook
* Created Date: 19/01/2022
* Last Modified Date: 
****************************************************************************/    
    public static Pricebook2 standardPriceBook(){
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Price Book', isActive = true);
        INSERT standardPB;
        return standardPB;
    }
    
    /****************************************************************************
* Author Name: Priyanka kumari
* Description: Method to create multiple Test OpportunityLineItem related to same Opportunity
* Created Date: 14/09/2022
* Last Modified Date: 
****************************************************************************/
    public static List<OpportunityLineItem> multipleOppLineItem(Integer noOfOlis){
        List<Account> alst = new List<Account> ();
        alst = [SELECT Id, Name, Phone from Account];
        if(alst.isempty()){
            alst = createAccounts(1); 
        }
        
        Account a = alst[0];
        PricebookEntry customPrice = customPriceBook();
        List<PricebookEntry> pbe = [SELECT ID,Product2Id FROM PricebookEntry];
        List<Opportunity> opp = createOpps(1);
        List<TechnicalRequirement__c> t = createTR(noOfOlis);//test
        opp[0].AccountId = a.Id;
        opp[0].Pricebook2Id = customPrice.Pricebook2Id;
        opp[0].CalculationTimePoint__c = 'Quarterly';
        UPDATE opp;
        DateTime dt = system.Now();
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        for (Integer j = 0; j < noOfOlis; j++) {
            olis.add(new OpportunityLineItem(OpportunityId = opp[0].Id, 
                                             Product2Id = pbe[0].Product2Id, Quantity = 5, 
                                             PricebookEntryId = customPrice.Id, 
                                             DateOfDelivery__c = dt.date(),TechnicalRequirement__c=t[j].Id,
                                             UsePricingTool__c = true,UnitOfMeasurement__c = 'Inch', PurposeOfUse__c = '1-UNKNOWN', ShortPiece__c =true,
                                             DimensionAFrom__c = 3,QuantityUnit__c= 'Moto',DimensioncalculationA__c=7));//test
        }
        INSERT olis;
        return olis;
    }
    /****************************************************************************
* Author Name: Priyanka Kumari
* Description: Method to create Test Price Level Surcharge
* Created Date: 14/09/2022
* Last Modiied Date: 
****************************************************************************/
    public static List<PriceLevelSurcharge__c> createPls(Integer numPls) {
        List<PriceLevelSurcharge__c> pls = new List<PriceLevelSurcharge__c>();
        for (Integer k = 0; k < numPls; k++) {
            pls.add(new PriceLevelSurcharge__c(Name = 'Test Price Level Surcharge ' + k, PriceLevel__c = '1', Value__c = 1));
        }
        INSERT pls;
        return pls;
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to create Test Technical Requirement
* Created Date: 11/11/2022
* Last Modified Date: 
****************************************************************************/
    public static List<TechnicalRequirement__c> createTR(Integer numTR) {
        
        List<Opportunity> oppList =  [select ID, Name, AccountId, StageName, CloseDate,AppointedDayCalculation__c, Pricebook2Id, Language__c from Opportunity Limit 1];
        if(oppList.isempty()){
           oppList =  createOpps(1);
        }
        List<TechnicalRequirement__c> tR = new List<TechnicalRequirement__c>();
        for (Integer k = 0; k < =numTR; k++) {
            tR.add(new TechnicalRequirement__c(Name = 'Test Technical Requirement ' + k, Account__c = oppList[0].AccountId , Opportunity__c = oppList[0].ID, Quantity__c = 20, Active__c = True, TextForSelectionQuality__c = 'Not in product portfolio;Standard sentence: "Further customer requirements"'));
        }
        INSERT tR;
        return tR;
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to create Test Finished Goods
* Created Date: 11/11/2022
* Last Modified Date: 
****************************************************************************/
    public static List<FinishedGoods__c> createFG(Integer numFG) {
        List<FinishedGoods__c> fG = new List<FinishedGoods__c>();
        List<Product2> prod = createProduct(1);
        SteelGrade__c st = new SteelGrade__c(Name='1', SELNumber__c='123');
        st.SELNumber__c = '123';
        st.Name = '1';
        st.ExternalID__c = 'DEF';
        insert st;
        for (Integer k = 0; k < numFG; k++) {
            fG.add(new FinishedGoods__c(Name = 'Test Finished Goods' + k, SteelGradeLookup__c = st.id, MaterialNumber__c = '100052669', CustomerSteelGrade__c = 'A', CustomerMaterialNumber__c = '789', BusinessArea__c = 'ZS', RollingMill__c = '11',
                                        ExternalID__c = '1', DimensionA__c = 10, DimensionB__c = 20, PrimRollingHomogenize__c = 'F', PrimRollingInputFormat__c ='FG', HZVCheckTreatment__c = 'HZV', HeatTreatment__c = '1', Straightening__c ='Y', PeelRodWire__c ='P',
                                        SurfaceDefectInspec__c = 'I', USInspection__c = 'U',Product__c = prod[0].ID, Active__c = true));
        }
        INSERT fG;
        return fG;
    }
    
    
    /****************************************************************************
* Author Name: Naina B
* Description: Method to create Test SemiFinished Goods
* Created Date: 25/11/2022
* Last Modified Date: 
****************************************************************************/
    public static List<SemiFinishedGoods__c> createSFG(Integer numFG) {
        List<SemiFinishedGoods__c> sFG = new List<SemiFinishedGoods__c>();
        // stgr = createSteelGrade();
        for (Integer k = 0; k < numFG; k++) {
            sFG.add(new SemiFinishedGoods__c(Name = 'Test SEmiFinished Goods' + k, SELNumber__c = '1233', ExternalID__c = '123', MaterialNumber__c = '123', Homogenize__c = '1',
                                             ReblockHomogenize__c = 'F', ReblockTapping__c ='FG', HZVCheckEdit__c = 'HZV', HZVStarting__c = '1', HZVSampleTest__c ='Y', SteelGrade__c = '1', Active__c = true));
        }
        INSERT sFG;
        return sFG;
    }
    /****************************************************************************
* Author Name: Harshitha U
* Description: Method to create Test Raw Material
* Created Date: 01/12/2022
* Last Modified Date: 01/12/2022
****************************************************************************/
    public static List<RawMaterial__c> createRM(Integer numRM) {
        List<RawMaterial__c> RM = new List<RawMaterial__c>();
        for (Integer k = 0; k < numRM; k++) {
            RM.add(new RawMaterial__c(Name = 'Test Raw Material' + k, MaterialNumber__c = '123', TimePoint1__c = 12, TimePoint2__c = 12, TimePoint3__c = 13,
                                      TimePoint4__c = 5, TimePoint5__c =6, TimePoint6__c =7, TimePoint7__c =6, TimePoint8__c =8,TimePoint9__c = 5,TimePoint10__c = 5,TimePoint11__c = 3,
                                      TimePoint12__c = 8,TimePoint13__c = 5,TimePoint14__c = 6,TimePoint15__c = 6,TimePoint16__c = 7,TimePoint17__c = 6,TimePoint18__c = 2,RLevel1__c='Metall. Einsatz',RLevel2__c='Schrott',RLevel3__c='Eigenschrott',Type__c = 'I'));
        }
        INSERT RM;
        return RM;
    }
    /****************************************************************************
* Author Name: Gunjan Saxena
* Description: Method to create Product
* Created Date: 12/15/2022
* Last Modified Date: 
****************************************************************************/
    public static List<Product2> createProduct(Integer numTR) {
        Pricebook2 customPB = new Pricebook2(Name = 'SAG', isActive = true);
        INSERT customPB;
         customPB = new Pricebook2(Name = 'DH', isActive = true);
        INSERT customPB;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true); 
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        update standardPricebook;
        List<Product2> prdlst = new List<Product2>();
        for (Integer k = 0; k < numTR; k++) {
            Product2 prod = new Product2(Name = 'P '+ DateTime.now().getTime() + k, Family = 'Hardware',Flat__c = True, IsActive = true);
            prdlst.add(prod);
            
        }
        INSERT prdlst; 
        //PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prdlst[0].Id, UnitPrice = 12000, IsActive = true);
        return prdlst;
    }
    /****************************************************************************
* Author Name: Gunjan Saxena
* Description: Method to create SteelGrade
* Created Date: 12/15/2022
* Last Modified Date: 
****************************************************************************/
    public static List<SteelGrade__c> createSteelGrade(Integer numTR) {
        List<SteelGrade__c> stglst = new List<SteelGrade__c>();
        for (Integer k = 0; k < numTR; k++) {
            SteelGrade__c stg = new SteelGrade__c(Name = 'Test stg'+ k, SELNumber__c = '123',ExternalID__c = '1234');
            stglst.add(stg);
            
        }
        INSERT stglst;
        return stglst;
    }
    
    
    /****************************************************************************
* Author Name: Gunjan Saxena
* Description: Method to create Test Technical Requirement
* Created Date: 12/08/2022
* Last Modified Date: 
****************************************************************************/
    public static List<TechnicalRequirement__c> createTRtechList(Integer numTR) {
        List<Product2> prodlst = createProduct(1);
        Product2 prod = prodlst[0];
        prod.Flat__c = true;
        update prod;
        createOpps(1);
        List<Opportunity> oppList =  [select ID, Name, AccountId, StageName, CloseDate, Pricebook2Id, Language__c from Opportunity Limit 1];
        List<SteelGrade__c> stGlst = createSteelGrade(1);
        SteelGrade__c stG = stGlst[0];
        List<TechnicalRequirement__c> TR = new List<TechnicalRequirement__c>();
        for (Integer k = 0; k < numTR; k++) {
            TR.add(new TechnicalRequirement__c(Name = 'Test Flat Product Technical Requirement ' + k, Account__c = oppList[0].AccountId , Opportunity__c = oppList[0].ID, Quantity__c = 20, Active__c = True, TextForSelectionQuality__c = 'Not in product portfolio;Standard sentence: "Further customer requirements"'
                                               ,Product__c = prod.Id,InternalSteelGrade__c = stG.Id,Inductive__c = True,BusinessArea__c = 'ZS',RollingMill__c = '11',DimensionA__c = 10,DimensionB__c = 20,PrimRollingHomogenize__c = 'F',PrimRollingInputFormat__c ='FG',
                                               HZVCheckTreatment__c = 'HZV',SurfaceTreatment__c ='Y',Peelingbarwirerod__c ='P',SurfaceDefectInspec__c = 'I',USInspection__c = 'U',HZVAnnealing__c = '1',Homogenize__c = '1'));
        }
        INSERT TR;
        return TR;
    }
    
    /****************************************************************************
* Author Name: Naina B
* Description: Method to create Test User
* Created Date: 14/12/2022
* Last Modified Date: 
****************************************************************************/
    public static List<User> createUser(Integer numRM) {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        String profileId = [SELECT Id FROM Profile WHERE Name IN ('System Administrator', 'Systemadministrator')].Id;
        List<User> userList = new List<User>();
        for (Integer k = 0; k < numRM; k++) {
            userList.add(new User(ProfileId = profileId,
                                  LastName = 'last' + k,
                                  Email = 'testemail'+k+'@shsproject.com',
                                  Username = 'testclassemail'+k+'@shsproject.com' + k,
                                  CompanyName = 'TEST',
                                  Title = 'title',
                                  Alias = 'alias',
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  EmailEncodingKey = 'UTF-8',
                                  LanguageLocaleKey = 'de',
                                  LocaleSidKey = 'de',
                                  UserRoleId = r.Id,
                                  IsActive  = True));
        }
        insert userList;
        return userList;
    }
    /****************************************************************************
* Author Name: Naina Butle
* Description: Method to create OrgWideSettings__c record
* Created Date: 09/01/2023
* Last Modified Date: 
****************************************************************************/ 
    public static OrgWideSettings__c createOrgWideSetting(){
        OrgWideSettings__c setting = new OrgWideSettings__c();
        setting.Name = 'Org Wide Info';
        setting.ActivateAlternateBasicPlan__c = false;
        insert setting;
        return setting;
    }
    
    public static List<User> createUserSales(Integer numRM) {
        UserRole r = new UserRole(DeveloperName = 'SAGName', Name = 'SAG');
        insert r;
        String profileId = [SELECT Id FROM Profile WHERE Name = 'SAG Sales'].Id;
        List<User> userList = new List<User>();
        for (Integer k = 0; k < numRM; k++) {
            userList.add(new User(ProfileId = profileId,
                                  LastName = 'last' + k,
                                  Email = 'testemail'+k+'@shsproject.com',
                                  Username = 'testclassemailmon'+k+'@shsproject.com' + k,
                                  CompanyName = 'TEST',
                                  Title = 'title',
                                  Alias = 'alias',
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  EmailEncodingKey = 'UTF-8',
                                  LanguageLocaleKey = 'de',
                                  LocaleSidKey = 'de',
                                  UserRoleId = r.Id,
                                  IsActive  = True
                                 ));
        }
        insert userList;
        return userList;
    }
    
     public static List<User> createUserDHMarketing(Integer numRM) {
        UserRole r = new UserRole(DeveloperName = 'DHName', Name = 'DH');
        insert r;
        String profileId = [SELECT Id FROM Profile WHERE Name =: ConstantClass.DH_MARKETING_PROFILE].Id;
        List<User> userList = new List<User>();
        for (Integer k = 0; k < numRM; k++) {
            userList.add(new User(ProfileId = profileId,
                                  LastName = 'last' + k,
                                  Email = 'testDHemai'+k+'@shsproject.com',
                                  Username = 'testdhMarketing'+k+'@shsproject.com' + k,
                                  CompanyName = 'TEST',
                                  Title = 'title',
                                  Alias = 'alias',
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  EmailEncodingKey = 'UTF-8',
                                  LanguageLocaleKey = 'de',
                                  LocaleSidKey = 'de',
                                  UserRoleId = r.Id,
                                  IsActive  = True
                                 ));
        }
        insert userList;
        return userList;
    }
     /****************************************************************************
* Author Name: Gunjan Saxena
* Description: Method to create Test RollingMill
* Created Date: 02/02/2023
* Last Modified Date: 
****************************************************************************/
    public static List<RollingMill__c> createRollingMill(Integer numRM) {
        List<RollingMill__c> RMLst = new List<RollingMill__c>();
        List<Product2> prodlst = [Select ID,ProductCode from Product2 limit 1];
        if(prodlst.isempty()){
            prodlst = createProduct(1);
        }            
        for (Integer k = 0; k < numRM; k++) {
            RollingMill__c RM = new RollingMill__c();
            RM.name = 'RM'+k;
            RM.DimensionFrom__c = 0;
            RM.DimenstionTo__c = 1000;
            RM.ProductCode__c = prodlst[0].ProductCode;
            RM.RollingMill__c = '11';
            RM.ExternalID__c = '0000';
            RMLst.add(RM);
        }
        Insert RMLst;
        return RMLst;
    }
     /****************************************************************************
* Author Name: Gunjan Saxena
* Description: Method to create Test RollingMill
* Created Date: 02/02/2023
* Last Modified Date: 
****************************************************************************/
    public static List<SalesPlanning__c> createSalesPlanning(Integer numRM) {
        List<SalesPlanning__c> SPLst = new List<SalesPlanning__c>();
        for (Integer k = 0; k < numRM; k++) {
        SalesPlanning__c SP = new SalesPlanning__c();
         SP.BusinessArea__c = 'ZZ - Low Carbon - B10';
         SP.ForecastTimePoint__c = system.today().addMonths(-1);
         SP.ForecastLevel__c = 'Business Area/Product Group';
         SP.Frequency__c='Monthly';
         SPLst.add(SP);   
        }
        insert SPLst;
        return SPLst;
    }
/****************************************************************************
* Author Name: Harshitha U
* Description: Method to create Test RollingMill
* Created Date: 02/02/2023
* Last Modified Date: 
****************************************************************************/
    public static List<SalesPlanning__c> createSalesPlanningAcc(Integer numRM) {
        List<Account> acc = createAccounts(1);
        List<SalesPlanning__c> SPLst = new List<SalesPlanning__c>();
        for (Integer k = 0; k < numRM; k++) {
        SalesPlanning__c SP = new SalesPlanning__c();
         SP.BusinessArea__c = 'ZK';
         SP.Account__c = acc[0].ID;
         SP.ForecastTimePoint__c = system.today();
         SP.ForecastLevel__c = 'Account';
         SP.Frequency__c='Monthly';
         SPLst.add(SP);   
        }
        insert SPLst;
        return SPLst;
    }
    /****************************************************************************
* Author Name: Naina Butle
* Description: Method to create Test SalesPlanning
* Created Date: 02/02/2023
* Last Modified Date: 
****************************************************************************/
    public static List<SalesPlanning__c> createSalesPlanningAccount(Integer numRM) {
        List<SalesPlanning__c> sPLst = new List<SalesPlanning__c>();
        List<Account> acclst = createAccounts(1);
        for (Integer k = 0; k < numRM; k++) {
        SalesPlanning__c sP = new SalesPlanning__c();
         sP.BusinessArea__c = 'ZK';
         sP.ForecastTimePoint__c = system.today();
         sP.ForecastLevel__c = 'Account';
         sp.Account__c = acclst[0].Id;
         sp.Frequency__c='Monthly';
         sPLst.add(sP);   
        }
        insert sPLst;
        return sPLst;
    }
    
    /****************************************************************************
* Author Name: Naina Butle
* Description: Method to create Test SalesPlanningLog
* Created Date: 02/02/2023
* Last Modified Date: 
****************************************************************************/
    public static SalesPlanningLog__c createSalesPlanningLog() {
        SalesPlanningLog__c spLogNew = new SalesPlanningLog__c();
         spLogNew.ForecastLevel__c = 'Business Area/Product Group';
        insert spLogNew;
        return spLogNew;
    }
/****************************************************************************
* Author Name: Harshitha U
* Description: Method to create Test SalesPlanningLog
* Created Date: 02/02/2023
* Last Modified Date: 
****************************************************************************/
    public static SalesPlanningLog__c createSalesPlanningLogAcc() {
        SalesPlanningLog__c spLogNew = new SalesPlanningLog__c();
         spLogNew.ForecastLevel__c = 'Account';
         spLogNew.InEditMode__c =false;
         spLogNew.EditedBy__c =null;
        insert spLogNew;
        return spLogNew;
    }
    
    
    /****************************************************************************
* Author Name: Naina Butle
* Description: Method to create Test yearly SalesPlanning
* Created Date: 02/02/2023
* Last Modified Date: 
****************************************************************************/
    public static List<SalesPlanning__c> createYearlySalesPlanning(Integer numRM) {
        List<SalesPlanning__c> sPLst = new List<SalesPlanning__c>();
        for (Integer k = 0; k < numRM; k++) {
        SalesPlanning__c sP = new SalesPlanning__c();
         sP.BusinessArea__c = 'ZW';
         sP.ForecastTimePoint__c = system.today().addMonths(-1);
         sP.ForecastLevel__c = 'Business Area/Product Group';
         sP.Frequency__c ='Yearly';
         sPLst.add(SP);   
        }
        insert sPLst;
        return sPLst;
    }
    
    /****************************************************************************
* Author Name: Naina Butle
* Description: Method to create Test Account yearly SalesPlanning
* Created Date: 31/05/2023
* Last Modified Date: 
****************************************************************************/
   public static List<SalesPlanning__c> createAccountYearlySalesPlanning(Integer numRM) {
        List<SalesPlanning__c> sPLst = new List<SalesPlanning__c>();
        List<Account> acclst = createAccounts(numRM);  
        for (Integer k = 0; k < numRM; k++) {
        SalesPlanning__c sP = new SalesPlanning__c();
         sP.BusinessArea__c = 'ZW';
         sP.ForecastTimePoint__c = system.today().addMonths(-1);
         sP.ForecastLevel__c = 'Account';
         sp.Account__c = acclst[k].Id;
         sP.Frequency__c ='Yearly';
         sPLst.add(SP);   
        }
        insert sPLst;
        return sPLst;
    }
     /****************************************************************************
* Author Name: Naina Butle
* Description: Method to create Test Technical Requirement
* Created Date: 14/04/2023
* Last Modified Date: 
****************************************************************************/
    public static List<TechnicalRequirement__c> createTechReq(Integer numTR) {
        createOpps(1);
        List<Opportunity> oppList =  [select ID, Name, AccountId, StageName, CloseDate, Pricebook2Id, Language__c from Opportunity Limit 1];
        List<Product2> prod = TestDataFactory.createProduct(2);
        List<TechnicalRequirement__c> tR = new List<TechnicalRequirement__c>();
        for (Integer k = 0; k < = numTR; k++) {
            tR.add(new TechnicalRequirement__c(Name = 'Test Technical Requirement ' + k, Product__c = prod[0].Id, Account__c = oppList[0].AccountId , Opportunity__c = oppList[0].Id, Quantity__c = 20, Active__c = True, TextForSelectionQuality__c = 'Not in product portfolio;Standard sentence: "Further customer requirements"'));
        }
        INSERT tR;
        return tR;
    }
/****************************************************************************
* Author Name: Naina Butle
* Description: Method to create Test oppLineItem
* Created Date: 14/04/2023
* Last Modified Date: 
****************************************************************************/
    public static OpportunityLineItem oppLineItem(List<TechnicalRequirement__c> tR, List<Product2> prod, List<FinishedGoods__c> fMNs){
        List<TechnicalRequirement__c> tRlst = [SELECT Id, Active__c, Account__c, FinishedGoods__c, Opportunity__c,Opportunity__r.Pricebook2Id, OpportunityProduct__c, FinishedGoods__r.Product__c, Quantity__c, Product__c FROM TechnicalRequirement__c  
                                               WHERE ID =: tR[0].Id LIMIT 1]; 
        PricebookEntry customPrice = customPriceBook();
        DateTime dt = system.Now();
        OpportunityLineItem oli = new OpportunityLineItem();
        if(tRlst[0].Opportunity__r.Pricebook2Id != customPrice.Pricebook2Id){
            list<PricebookEntry> lstpbe = [select id,Pricebook2Id from PricebookEntry where Pricebook2Id = :tRlst[0].Opportunity__r.Pricebook2Id AND Product2Id = :prod[0].Id ];
            if(lstpbe.size()>0){
              oli = new OpportunityLineItem(OpportunityId = tRlst[0].Opportunity__c, FinishedGoods__c = fMNs[0].Id, TechnicalRequirement__c = tRlst[0].Id, Product2Id = prod[0].Id, Quantity = 5, PricebookEntryId = lstpbe[0].Id, DateOfDelivery__c = dt.date(),UsePricingTool__c = true,UnitOfMeasurement__c = 'Inch', PurposeOfUse__c = '1-UNKNOWN',ShortPiece__c =true, DimensionAFrom__c =3,QuantityUnit__c = 'Moto',DimensioncalculationA__c =7 );
             }else{
                PricebookEntry pbe = createpriceBookEntry();
             oli = new OpportunityLineItem(OpportunityId = tRlst[0].Opportunity__c, FinishedGoods__c = fMNs[0].Id, TechnicalRequirement__c = tRlst[0].Id, Product2Id = prod[0].Id, Quantity = 5, PricebookEntryId = pbe.Id, DateOfDelivery__c = dt.date(),UsePricingTool__c = true,UnitOfMeasurement__c = 'Inch', PurposeOfUse__c = '1-UNKNOWN',ShortPiece__c =true, DimensionAFrom__c = 3,QuantityUnit__c ='Moto',DimensioncalculationA__c=7);
             }
        }else{
            oli = new OpportunityLineItem(OpportunityId = tRlst[0].Opportunity__c, FinishedGoods__c = fMNs[0].Id, TechnicalRequirement__c = tRlst[0].Id, Product2Id = prod[0].Id, Quantity = 5, PricebookEntryId = customPrice.Id, DateOfDelivery__c = dt.date(),UsePricingTool__c = true,UnitOfMeasurement__c = 'Inch', PurposeOfUse__c = '1-UNKNOWN', ShortPiece__c =true, DimensionAFrom__c = 3,QuantityUnit__c= 'Moto',DimensioncalculationA__c=7);
        }
        oli.UnitPrice = 10;
        INSERT oli;
        return oli;
    } 
     /****************************************************************************
* Author Name: Naina B
* Description: Method to create Test Case Records
* Created Date: 05/09/2023
* Last Modified Date: 22/08/2022
****************************************************************************/
    public static List<Case> createCases(Integer numlds) {
        List<Case> lstcases = new List<Case>();
        for(integer i = 0; i < numlds; i++) {
            Case objCase = new Case( SuppliedName = 'Test'+i, SuppliedLastName__c = 'Sample'+i, SuppliedCompany = 'Testing Sample Co', SuppliedEmail ='testemail'+i+'@gmail.com');  
            lstcases.add(objCase);
        }
        INSERT lstcases; 
        return lstcases;
    }  


    /****************************************************************************
* Author Name: Harshitha Udaykumar
* Description: Method to Prakula Records
* Created Date: 13/09/2023
* Last Modified Date: 13/09/2023
****************************************************************************/
    public static List<Praekula__c> createPrakula(Integer numprakula) {
        List<Account> acclst = TestDataFactory.createAccounts(1);
        List<Praekula__c> lstprakula = new List<Praekula__c>();
        for(integer i = 0; i < numprakula; i++) {
            Praekula__c objprakula = new Praekula__c(Language__c = 'DE',Account__c=acclst[0].ID,Status__c='New');  
            lstprakula.add(objprakula);
        }
        INSERT lstprakula; 
        return lstprakula;
    }
/****************************************************************************
* Author Name: Harshitha U
* Description: Method to create Test LV Position 
* Created Date: 28/09/2023
* Last Modified Date: 
****************************************************************************/
    public static List<LVPostion__c> createLV(Integer numLV) {
        List<LVPostion__c> lv = new List<LVPostion__c>();
        List<Product2> prod = createProduct(1);
        List<SteelGrade__c> steelgrade = createSteelGrade(1);
        for (Integer k = 0; k < numLV; k++) {
            lv.add(new LVPostion__c(InternalSteelGrade__c = steelgrade[0].Id,CustomerMaterial__c = '100052669', CustomerSteelGrade__c = 'A', RollingMill__c = '11',
        DimensionAFrom__c = 1,DimensionATo__c = 3,DimensionB__c = 20, PrimRollingHomogenize__c = 'F', PrimRollingInputFormat__c ='146', HZVCheckTreatment__c = 'MTA', HeatTreatment__c = 'GL', SurfaceTreatment__c='P', Surfacedefectinspec__c ='D2',
                                         Peelingbarwirerod__c = 'U', Homogenize__c = 'H',HZVAnnealing__c = 'G',USInspection__c = 'V',HZVSampletest__c='1', Product__c = prod[0].ID));
        }
        INSERT lv;
        return lv;
    }
    
    /****************************************************************************
    * Author Name: Ashutosh Rao
    * Description: Method to create Test Delivery Instruction
    * Created Date: 06/10/2023
    * Last Modified Date: 
    ****************************************************************************/
    public static DeliveryInstructions__c createDeliveryInstruction() {
        DeliveryInstructions__c di = new DeliveryInstructions__c();
        di.type__c = 'Norm';
        di.title__c = 'Test Title';
        di.Language__c  ='EN';
        di.publisher__c = 'Test Publisher';
        di.status__c ='New' ;
        di.SalesRepresentative__c = userinfo.getuserId();
        di.ProductManager__c=  userinfo.getuserId();
        di.QualityManager__c=  userinfo.getuserId();
        di.QualityRepresentative__c = userinfo.getuserId();
        di.DateOfIssue__c = Date.today();
        insert di;
        return di;
    }
    
    /****************************************************************************
    * Author Name: Ashutosh Rao
    * Description: Method to create Test ContentVersion
    * Created Date: 06/10/2023
    * Last Modified Date: 
    ****************************************************************************/
    public static void createContentVersion() {
         ContentVersion contentVersionTest = new ContentVersion(
            Title = 'Test Title',
            PathOnClient = 'test Image.jpg',
            VersionData = Blob.valueOf('Test Content'),
            isMajorVersion = true);
        insert contentVersionTest;
    }
            /****************************************************************************
    * Author Name: Pratiman Joshi
    * Description: Method to create Test Prakula Delivery Instruction data
    * Created Date: 10/10/2023
    * Last Modified Date: 
    ****************************************************************************/
    public static List<PraekulaDeliveryInstructions__c> createPreakulaDeliveryInstruction(Integer numInstruction) {
        List<PraekulaDeliveryInstructions__c> lstpdi = new List<PraekulaDeliveryInstructions__c>();
        List<Praekula__c> PraekulaLst = new List<Praekula__c>();
        PraekulaLst = TestDataFactory.createPrakula(numInstruction);
        for(integer i = 0; i < numInstruction; i++) {
            DeliveryInstructions__c deliveryInstructionVar = new DeliveryInstructions__c();
            Praekula__c PraekulaVar = new Praekula__c();
            deliveryInstructionVar = TestDataFactory.createDeliveryInstruction();
            PraekulaVar = PraekulaLst[i];
            PraekulaDeliveryInstructions__c PDI = new PraekulaDeliveryInstructions__c();
            PDI.DeliveryInstructions__c = deliveryInstructionVar.Id;
            PDI.Praekula__c = PraekulaVar.Id;
            lstpdi.add(PDI);
        }
        INSERT lstpdi;
        return lstpdi;
}       
  
/****************************************************************************
    * Author Name: Naina Butle
    * Description: Method to create Test documentTemplate data
    * Created Date: 22/11/2023
    * Last Modified Date: 
    ****************************************************************************/
    public static List<documentTemplate> createdocumentTemplate(Integer numdoc) {
       
        List<documentTemplate> lstdocumentTemplate = new List<documentTemplate>();
        for(integer i = 0; i < numdoc; i++) {
            documentTemplate objdocumentTemplate = new documentTemplate(Language__c = 'DE', Name ='German DI Side Letter document' + i, TokenMappingType ='JSON',
                                                                        Type ='MicrosoftWord', TokenMappingMethodType ='OmniDataTransform');  
            lstdocumentTemplate.add(objdocumentTemplate);
        }
        INSERT lstdocumentTemplate; 
        return lstdocumentTemplate;
    }

      /****************************************************************************
* Author Name: Naina Butle
* Description: Method to create Test createUserDHCustomerCommunityPlusLoginUser data
* Created Date: 22/12/2023
* Last Modified Date: 
****************************************************************************/
public static List<User> createUserDHCustomerCommunityPlusLoginUser(Integer numRM) {
    UserRole userRole = new UserRole(DeveloperName = 'DHName', Name = 'DH');
    insert userRole;
    User adminUser = [Select Id, UserRoleId, IsActive From User Where Profile.Name='System Administrator' AND IsActive = True Limit 1];
    
    adminUser.UserRoleId = userRole.Id;
    update adminUser;
    
    System.runAs(adminUser){
        List<Contact> con ;
        List<Contact> conList;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            con = TestDataFactory.createAccountwithContact(numRM,numRM);
            conList = [Select id, AccountId from Contact where AccountId != null];
        }
        
        String profileId = [SELECT Id FROM Profile WHERE Name =: ConstantClass.DH_CUSTOMER_COMMUNITY_USER].Id;
        List<User> userList = new List<User>();
        for (Integer k = 0; k < numRM; k++) {
            userList.add(new User(ProfileId = profileId,
                                  LastName = 'last' + k,
                                  Email = 'testdhemai'+k+'@shsproject.com',
                                  Username = 'testdhemai'+k+'@shsproject.com'+ k +'.dillinger',
                                  CompanyName = 'TEST',
                                  Title = 'title',
                                  Alias = 'alias',
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  EmailEncodingKey = 'UTF-8',
                                  LanguageLocaleKey = 'de',
                                  LocaleSidKey = 'de',
                                  IsActive  = True,
                                  ContactId = conList[k].Id != null ? conList[k].Id : conList[0].Id
                                 ));
        }
        insert userList;
        return userList;
    }
    return null;
}
}

