/****************************************************************************
* Name: DeliveryInstrPDFGeneration
* Author: Naina Butle
* Created Date: 22/11/2023
* Description: Button click from Delivery Instruction to generate document.
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
****************************************************************************/
global with sharing class DeliveryInstrPDFGeneration {
    @InvocableMethod(label =  'Delivery Instruction document generator'
                     description = 'Button click from Delivery Instruction to generate document'
                     category = 'Delivery Instruction')
    public static List<String> createDocumentGenerationProcessRequest(List<Id> recordId) {
        Savepoint sp = Database.setSavepoint();
        string Message = '';
        try{
            
            List<DeliveryInstructions__c> deliveryInst = [SELECT Id, Name, Title__c, AdditionalTitle__c, FlagMonthYearOnly__c, DateOfIssue__c, Language__c, Revision__c  FROM DeliveryInstructions__c WHERE Id =: recordId[0]];
            String lang = deliveryInst[0].Language__c;
            List<DocumentTemplate> documentTemplate = [SELECT id, Name, Language__c FROM DocumentTemplate WHERE Name LIKE '%DI Side Letter document%'];
            
            String procedureName = 'DocumentServiceGateway_DocGeneration';
            Map<String, Object> ipInput = new Map<String, Object> ();
            Map<String, Object> ipOutput = new Map<String, Object> ();
            Map<String, Object> ipOptions = new Map<String, Object> ();
            String documentName;
            String outputFileFormat = 'pdf';
            String dateofIssue;
            String dateofIssueENG;
            String titleAddTitleVersion;
            
            Date dToday = Date.today();
            DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
            String dateofDocumentCreation = dt.format('ddMMyyyy');
            String dateofDocumentCreationENG = dt.format('yyyyMMdd');
            
            if(deliveryInst[0].Title__c != null){
                titleAddTitleVersion = '_' + deliveryInst[0].Title__c;
            }
            if(deliveryInst[0].AdditionalTitle__c != null){
                if(titleAddTitleVersion != null){
                    titleAddTitleVersion = titleAddTitleVersion +'_'+deliveryInst[0].AdditionalTitle__c;
                }else{
                    titleAddTitleVersion = '_' + deliveryInst[0].AdditionalTitle__c;    
                }
            }
            if(deliveryInst[0].Revision__c != null){
                if(titleAddTitleVersion != null){
                    titleAddTitleVersion = titleAddTitleVersion +'_' +deliveryInst[0].Revision__c;
                }else{
                    titleAddTitleVersion = '_' + deliveryInst[0].Revision__c;    
                }
            }
            if(deliveryInst[0].DateOfIssue__c != null){
                Date dToday1 = deliveryInst[0].DateOfIssue__c;
                DateTime dt1 = DateTime.newInstance(dToday1.year(), dToday1.month(), dToday1.day());
                
                if(deliveryInst[0].FlagMonthYearOnly__c){
                    dateofIssue =  '_' + dt1.format('ddMMyyyy');
                    dateofIssueENG = '_' + dt1.format('yyyyMMdd');
                }else{
                    dateofIssue = '_' + dt1.format('MMyyyy'); 
                    dateofIssueENG = '_' + dt1.format('yyyyMM'); 
                }
            }
            
            for(DocumentTemplate docTemp : documentTemplate){
                if(lang.Contains(docTemp.Language__c)){
                    ipInput.put('objectId', recordId[0]);
                    ipInput.put('templateId', docTemp.Id);
                    ipInput.put('outputFileFormat', outputFileFormat);
                    
                    if(docTemp.Language__c == 'DE'){
                        documentName = 'DE Stellungnahme' + '_'+ DateofDocumentCreation + TitleAddTitleVersion + DateOfIssue;
                    }else if(docTemp.Language__c == 'EN'){
                        documentName = 'EN Statement' + '_'+ DateofDocumentCreationENG + TitleAddTitleVersion + DateofIssueENG;
                    }else if(docTemp.Language__c == 'FR'){
                        documentName = 'FRPriseDePosition' + '_'+ DateofDocumentCreation + TitleAddTitleVersion + DateOfIssue;
                    }
                    
                    ipInput.put('title', documentName);
                    ipInput.put('contextId', recordId[0]);
                    ipOutput = (Map<String, Object>) omnistudio.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
                }
            }
            Message = ConstantClass.SUCCESS;
            
        }catch(Exception e){
            Database.RollBack(sp);   
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; '+ e.getMessage() + ' ; '+ e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.DELIVERYINSTRUCTIONS_OBJECT, ConstantClass.CREATDOCGEN_ERROR, null, exdetails, ConstantClass.APEX_CLASS);
            Message = string.valueOf(exdetails);
        } 
        List < string > returnlst = new List < string > ();
        returnlst.add(message);
        return returnlst;
    }  
}