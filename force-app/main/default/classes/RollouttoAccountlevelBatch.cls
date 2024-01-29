/****************************************************************************
* Name: RollouttoAccountlevelBatch
* Author: Gunjan Saxena
* Created Date: 05/22/2023
* Class Name: RollouttoAccountlevelBatch 
* Description: Batch Class for reset the Forecast sold Amount on Account level. 
* US-4374
*****************************************************************************/
/*****************************************************************************
* Modification log
* Name		        Date	           		Description
* Developer Name	Date of Modification	Modification Description  
* Gunjan Saxena		22/05/2023				Created 
****************************************************************************/
global class RollouttoAccountlevelBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    //global Variables;    
    global  MAP<string,decimal> OrderShareMap = new MAP<string,decimal>();
    global  MAP<string,decimal> NetOrderShareMap = new MAP<string,decimal>();
    global  MAP<string,decimal> NetOrderSharepercentMap = new MAP<string,decimal>();
    public RollouttoAccountlevelBatch(){
        
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator([SELECT Id, Account__c,BusinessArea__c,SoldAmount__c,Nettoerloes__c, InvoiceDate__c,ProductCategoryBusinessArea__c,ProductGroupBusinessArea__c FROM InvoicedOrders__c 
                                         where InvoiceDate__c >=  :system.today().addMonths(-3).toStartOfMonth() AND InvoiceDate__c <  :system.today().toStartOfMonth() 
                                        order by BusinessArea__c ]); 
    }
    public void execute(Database.BatchableContext BC, 
                        List<InvoicedOrders__c> scope){
                           for(InvoicedOrders__c Invo : scope){
                               string BusinessArea = '';
                                    if(Invo.BusinessArea__c == 'ZZ'){
                                        if(Invo.ProductGroupBusinessArea__c == 'Low Carbon'){
                                            BusinessArea = Invo.BusinessArea__c + ' - ' + Invo.ProductGroupBusinessArea__c + ' - ' + Invo.ProductCategoryBusinessArea__c; 
                                        }else{
                                            BusinessArea = Invo.BusinessArea__c + ' - ' + Invo.ProductGroupBusinessArea__c ; 
                                        }                                        
                                    }else{
                                        BusinessArea = Invo.BusinessArea__c;                                        
                                    }
                               if(Invo.Account__c != null){
                                  if(OrderShareMap.containsKey(Invo.Account__c+'_'+BusinessArea)){
                                        OrderShareMap.put(Invo.Account__c+'_'+BusinessArea, Invo.SoldAmount__c + OrderShareMap .get(Invo.Account__c+'_'+BusinessArea));
                                    }else{
                                        OrderShareMap.put(Invo.Account__c+'_'+BusinessArea, Invo.SoldAmount__c);
                                    }
                               }
                               if(NetOrderShareMap.containsKey(BusinessArea)){
                                        NetOrderShareMap.put(BusinessArea, Invo.SoldAmount__c + NetOrderShareMap .get(BusinessArea));
                                    }else{
                                        NetOrderShareMap.put(BusinessArea, Invo.SoldAmount__c);
                                    }
                           }
                        }
    public void finish(Database.BatchableContext BC){
        for(string str : OrderShareMap.keySet()){
            string BA = str.substringAfter('_');
            if(OrderShareMap.containsKey(str) && NetOrderShareMap.containsKey(BA))
            NetOrderSharepercentMap.put(str,OrderShareMap.get(str)/NetOrderShareMap.get(BA));
        }
        SalesPlanningFAmountupdateBatch b = new SalesPlanningFAmountupdateBatch(NetOrderSharepercentMap); 
     	 Database.executeBatch(b);
    }

}