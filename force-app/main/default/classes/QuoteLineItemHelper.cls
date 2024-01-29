/****************************************************************************
* Name: QuoteLineItemHelper
* Author: Gunjan Saxena
* Created Date: 24/11/2023
* Description: helper class for QuoteLineItemTriggerHandler
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
****************************************************************************/
public class QuoteLineItemHelper {
    
    /***************************************************************************************************
* Author Name: Gunjan Saxena
* Description: Method to populate Commercial Offer field value on OLI record before insert and before update.
* Created Date: 24/11/2023
* Last Modified Date: 
****************************************************************************************************/
    public static void GenerateQuotePDF (List<QuoteLineItem> newQLIs) {
        if (Trigger.isInsert) {
            List<Id> quoteId = new List<Id>();
            for (QuoteLineItem qli : newQLIs){
                if(quoteId.contains(qli.QuoteId)){
                    break;
                }
                else{
                    quoteId.add(qli.QuoteId);
                    List<Id> quoteIDs = new List<Id>();
                    quoteIDs.add(qli.QuoteId);
                    QuotePDFGeneration.createDocumentGenerationProcessRequest(quoteIDs);
                    
                }
            }
            
        }
    }
    
    
}