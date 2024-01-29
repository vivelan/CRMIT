/****************************************************************************
* Author Name: Priyanka K
* Description: Method to call Integration Procedure for Quote PDF Generation.
* Created Date: 10/11/2023
* Last Modified Date: 01/12/2023
****************************************************************************/
global with sharing class QuotePDFGeneration {
    
    public static void createDocumentGenerationProcessRequest(List<Id> qIds) {
      
        Savepoint sp = Database.setSavepoint();
        try{
            // US-8308
            List<Quote> quote = [SELECT Id, Name, Opportunity.Name, Opportunity.Language__c, QuoteNumber, CreatedDate, CreationDate__c FROM Quote WHERE Id =: qIds[0]];
            String pdfLang = quote[0].Opportunity.Language__c;
            List<DocumentTemplate> documentTemplate = [SELECT id, Name, Language__c FROM DocumentTemplate WHERE Name LIKE '%Quote PDF Server Side%'];
           
            String procedureName = 'DocumentServiceGateway_DocGeneration';
            String documentName;
            String outputFileFormat = 'pdf';
            Map<String, Object> ipInput = new Map<String, Object> ();
            Map<String, Object> ipOutput = new Map<String, Object> ();
            Map<String, Object> ipOptions = new Map<String, Object> ();
            
            
            Date dToday = Date.valueOf(quote[0].CreationDate__c);
            DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
            String dateofQuoteCreation = dt.format('ddMMyyyy');
            String dateofQuoteCreationENG = dt.format('yyyyMMdd');
            
            
            for(DocumentTemplate docTemp : documentTemplate){
                if(pdfLang == docTemp.Language__c){
                    ipInput.put('objectId', qIds[0]);
                    ipInput.put('templateId', docTemp.Id);
                    ipInput.put('outputFileFormat', outputFileFormat);
                     if(docTemp.Language__c == 'DE'){
                        documentName = 'DE Angebot' + '_' + quote[0].Name + '_' + dateofQuoteCreation;
                    }else if(docTemp.Language__c == 'EN'){
                        documentName = 'EN Offer' + '_'  + quote[0].Name + '_' + dateofQuoteCreationENG;
                    }else if(docTemp.Language__c == 'FR'){
                        documentName = 'FR Offre' + '_'  + quote[0].Name + '_' + dateofQuoteCreation;
                    }
                    ipInput.put('title', documentName);
                    ipInput.put('contextId', qIds[0]);
                    ipOutput = (Map<String, Object>) omnistudio.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
                }
            }
                      
        }catch(Exception e){
            Database.RollBack(sp);   
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; '+ e.getMessage() + ' ; '+ e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.QUOTE_OBJECT, ConstantClass.QUOTEPDF_ERROR, null, exdetails, ConstantClass.APEX_CLASS);
           
        }
    }  
}