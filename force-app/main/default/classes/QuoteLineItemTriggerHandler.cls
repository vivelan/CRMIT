/****************************************************************************
* Name: QuoteLineItemTriggerHandler
* Author: Gunjan Saxena
* Created Date: 24/11/2023
* Description: Handler class for QuoteLineItem Trigger
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
****************************************************************************/
public with sharing class QuoteLineItemTriggerHandler extends TriggerHandler {
    
    /***************************************************************************************************
* Author Name: Gunjan Saxena
* Description:     
* Created Date: 24/11/2023
* Last Modified Date: 30/01/2023
****************************************************************************************************/  
    public override void afterInsert(){
        if (Trigger.isAfter) {
            if(!((list<QuoteLineItem>) trigger.new).isEmpty()){
                QuoteLineItemHelper.GenerateQuotePDF(trigger.new);
            }
        }
    }
}