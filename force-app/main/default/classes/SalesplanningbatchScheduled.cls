/****************************************************************************
* Name: SalesplanningbatchScheduled
* Author: Gunjan Saxena
* Created Date: 03/19/2023
* Class Name: SalesplanningbatchScheduled 
* Description: Schecduled class for Salesplanningbatch class
*****************************************************************************/
/*****************************************************************************
* Modification log
* Name		        Date	           		Description
* Developer Name	Date of Modification	Modification Description   
****************************************************************************/
global without sharing class SalesplanningbatchScheduled implements Schedulable {
	global void execute(SchedulableContext sc) {
      Salesplanningbatch b = new Salesplanningbatch(); 
      Database.executeBatch(b);
   }
}
