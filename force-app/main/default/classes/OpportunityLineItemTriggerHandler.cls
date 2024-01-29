/****************************************************************************
* Name: OpportunityLineItemTriggerHandler
* Author: Priyanka Kumari
* Created Date: 09/09/2022
* Description: Handler class for OpportunityLineItem Trigger
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
* Gunjan Saxena     15/12/2022              US-873
* Naina Butle
****************************************************************************/
public with sharing class OpportunityLineItemTriggerHandler extends TriggerHandler {

    /***************************************************************************************************
     * Author Name: Priyanka Kumari
     * Description: Method to make a callout to Heroku to get CoP value after Opprotunity Line Item Insert
                    Method to calculate Position on Opportunity Line Item when OLI is created.    
     * Created Date: 02/11/2022
     * Last Modified Date: 30/01/2023
     ****************************************************************************************************/  
    public override void afterInsert(){
        if(!((list<OpportunityLineItem>) trigger.new).isEmpty()){
            List<Id> oliIds = new List<Id>(trigger.newMap.keySet());
            OliTriggerCallout.callOutMethod(oliIds);
        }
    }
    
   /***************************************************************************************************
     * Author Name: Priyanka Kumari
     * Description: Method to populate different Price Levels on Opportunity Line Item when CoP is updated
     * Created Date: 09/09/2022
     * Last Modified Date: 20/12/2022
     ****************************************************************************************************/
    public override void beforeUpdate() {
        
    }
      /***************************************************************************************************
     * Author Name: Gunjan Saxena
     * Description: Method to populate UsePricingTool on Opportunity Line Item when OLI is Inserted
     * Created Date: 31/10/2023
     * Last Modified Date: 31/10/2023
     ****************************************************************************************************/
    public override void beforeInsert() {
        if(!((list<OpportunityLineItem>) trigger.new).isEmpty()){ 
            //OpportunityLineItemHelper.populateCommercialOffer((List<OpportunityLineItem>) trigger.new, null);  
            OpportunityLineItemHelper.populateUsePricingTool(trigger.new);
           // OpportunityLineItemHelper.calculatePositionOnOLI((List<OpportunityLineItem>) trigger.new);  //US-923
        }
    }
    //US-923 - Start
    /***************************************************************************************************
     * Author Name: Naina Butle
     * Description: Method to recalculate Position on Opportunity Line Item when OLI is Deleted
     * Created Date: 07/02/2023
     * Last Modified Date: 
     ****************************************************************************************************/
    /*public override void beforeDelete() {
        if(!((Map<Id, OpportunityLineItem>) trigger.oldMap).isEmpty()){   
            OpportunityLineItemHelper.recalculatePositionOnOLI((Map<Id, OpportunityLineItem>)trigger.oldMap); 
        }
    }*/
    //US-923 - End
    //
    

}