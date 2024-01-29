/****************************************************************************
* Name: OliTriggerCallout
* Author: Priyanka Kumari
* Created Date: 02/11/2022
* Description: Class for making callout from OLI Trigger after Insert operation
*****************************************************************************/
/*****************************************************************************
* Modification log
* Name		        Date	           		Description
* Developer Name	Date of Modification	Modification Description   
****************************************************************************/
public with sharing class OliTriggerCallout {

    /****************************************************************************
    * Author Name: Priyanka Kumari
    * Description: Method to call 'upadateCostOfProduction' from Pricing Tool Class
      to make a callout to fetch CoP values from Heroku
    * Created Date: 02/11/2022
    * Last Modified Date: 
	****************************************************************************/
    @future(callout=true)
    public static void callOutMethod(List<Id> oliIds)
    {   
        PricingToolController.upadateBulkCOP(oliIds);
    }
}