/****************************************************************************
* Name: Salesplanningbatch
* Author: Gunjan Saxena
* Created Date: 03/19/2023
* Class Name: Salesplanningbatch 
* Description: Batch Class for creation of Sales Planning records for 12th month. 
* Updating actual sold amount and net proceed values from Invoicedorders
*****************************************************************************/
/*****************************************************************************
* Modification log
* Name		        Date	           		Description
* Developer Name	Date of Modification	Modification Description  
* Gunjan Saxena		13/03/2023				Created 
* Gunjan Saxena		04-08-2023				methods sendNotification and getEmailAddresses are moved from salesforecasting controller to this class.
* Gunjan Saxena		30-08-2023				US- 6894 Unplanned Account update for Sold Amount and Net Proceed
* Gunjan Saxena		11-10-2023				US- 7940 Unplanned Account update for Sold Amount and Net Proceed
****************************************************************************/
global class Salesplanningbatch implements Database.Batchable<sObject>,Database.Stateful{
Map<string,Decimal> mapActualSoldAmount = new Map<string,Decimal>();//Ac_01
Map<string,Decimal> mapActualTotalSale = new Map<string,Decimal>();
Map<string,Decimal> mapActualNetproceeds = new Map<string,Decimal>();//Ac_02
Map<string,decimal> ACBAAccSoldAmtMap = new Map<string,decimal>(); //Ac_05_02
Map<string,decimal> ACBAActNetProcMap = new Map<string,decimal>(); //Ac_05_03 
Map<string,decimal> NPAccSoldAmtMap = new Map<string,decimal>(); //Ac_06
Map<string,decimal> NPActNetProcMap = new Map<string,decimal>(); //Ac_07 
public Salesplanningbatch(){
	List<SalesPlanning__c> SPLstInsert = new List<SalesPlanning__c>();
	// US-2562 - AC:03_SD_01/03
	List<String> pickListValuesList= new List<String>();
	Schema.DescribeFieldResult fieldResult = SalesPlanning__c.BusinessArea__c.getDescribe();
	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	for( Schema.PicklistEntry pickListVal : ple){
		pickListValuesList.add(pickListVal.getValue());                                
	}
	//US-4023 AC:04 start 
	Map<string,double> Netproceedmap = new Map<string,double>(); // US-4374: AC:01
	Map<string,double> SoldAmountmap = new Map<string,double>(); // US-4374: AC:01
	Map<string,double> NetproceedBAmap = new Map<string,double>(); // US-5166
    Map<string,double> SoldAmountBAmap = new Map<string,double>(); // US-5166
        
	for(SalesPlanning__c sp : [SELECT Id, Account__c, BusinessArea__c, ForecastNetProceeds__c, ForecastSoldAmount__c,ForecastTimePoint__c, ForecastLevel__c FROM SalesPlanning__c  
							   WHERE ForecastTimePoint__c = :system.today().addMonths(11).toStartOfMonth()]){
								if(sp.ForecastLevel__c == 'Account'){
								   if(sp.Account__c != NULL){
									   Netproceedmap.put(sp.Account__c +'_'+ sp.BusinessArea__c,sp.ForecastNetProceeds__c);
									   SoldAmountmap.put(sp.Account__c +'_'+ sp.BusinessArea__c,sp.ForecastSoldAmount__c);
								   }Else{
									   Netproceedmap.put(sp.BusinessArea__c,sp.ForecastNetProceeds__c);
									   SoldAmountmap.put(sp.BusinessArea__c,sp.ForecastSoldAmount__c);
								   }
								}
								if(sp.ForecastLevel__c == 'Business Area/Product Group'){
									NetproceedBAmap.put(sp.BusinessArea__c,sp.ForecastNetProceeds__c);
									SoldAmountBAmap.put(sp.BusinessArea__c,sp.ForecastSoldAmount__c);
								}  

							  }
	//US-4023 AC:04 stop
	for(string str : pickListValuesList){
		SalesPlanning__c spb = new SalesPlanning__c();
		spb.BusinessArea__c = str;
		spb.ForecastTimePoint__c = system.today().addMonths(12).toStartOfMonth();
		spb.ForecastLevel__c = 'Business Area/Product Group';
		spb.Frequency__c = 'Monthly';
		if(NetproceedBAmap.containskey(str))
                spb.ForecastNetProceeds__c = NetproceedBAmap.get(str);
        if(SoldAmountBAmap.containskey(str))
                spb.ForecastSoldAmount__c = SoldAmountBAmap.get(str); 
		SPLstInsert.add(spb);
		
		SalesPlanning__c spa = new SalesPlanning__c();
		spa.BusinessArea__c = str;
		spa.ForecastTimePoint__c = system.today().addMonths(12).toStartOfMonth();
		spa.ForecastLevel__c = 'Account';
		spa.Frequency__c = 'Monthly';
		if(Netproceedmap.containskey(str))
			spa.ForecastNetProceeds__c = Netproceedmap.get(str);
		if(SoldAmountmap.containskey(str))
			spa.ForecastSoldAmount__c = SoldAmountmap.get(str);    
		SPLstInsert.add(spa);
	}
	// US-2562 - AC:03_SD_02
	For(Account Acc : [Select ID, BusiessAreaForPlanning__c from Account where BusiessAreaForPlanning__c != null]){
		for(string ba : Acc.BusiessAreaForPlanning__c.split(';')){
			SalesPlanning__c spa = new SalesPlanning__c(); 
			spa.BusinessArea__c = ba;
			spa.ForecastTimePoint__c = system.today().addMonths(12).toStartOfMonth();
			spa.ForecastLevel__c = 'Account';
			spa.Frequency__c = 'Monthly';
			spa.Account__c = Acc.Id;
			if(Netproceedmap.containskey( Acc.Id+'_'+ba))
				spa.ForecastNetProceeds__c = Netproceedmap.get(Acc.Id+'_'+ba);
			if(SoldAmountmap.containskey(Acc.Id+'_'+ba))
				spa.ForecastSoldAmount__c = SoldAmountmap.get(Acc.Id+'_'+ba);  
			SPLstInsert.add(spa);
		}            
	}
	
   insert SPLstInsert;
}
public Database.QueryLocator start(Database.BatchableContext BC){
	return Database.getQueryLocator([SELECT Id, Account__c,BusinessArea__c,SoldAmount__c,Nettoerloes__c, InvoiceDate__c,ProductCategoryBusinessArea__c,ProductGroupBusinessArea__c FROM InvoicedOrders__c 
									 where InvoiceDate__c =  :system.today().addMonths(-1).toStartOfMonth() order by Account__c ]);
}
public void execute(Database.BatchableContext BC, List<InvoicedOrders__c> scope){			
	List<Id> Accidsplst = new List<Id>();
		//set<Id> SPAccIdlst = new set<Id>(); //US-6894
		set<string> SPAccbalst = new set<string>(); //US-7940
	List<string> BusinessAreasplst = new List<string>();
	Set<SalesPlanning__c> SPlUpdateLst = new Set<SalesPlanning__c>();
	for(InvoicedOrders__c Invo : scope){
		If(Invo != null){
			// US-2562 - AC:01 the actual sold amounts of last month for every business area and store the value in the field 'Actual Sold Amount'. 
			// This amount is calculated by summing all actual sold amounts of the accounts assigned to this business area/ subgroup
			
			Accidsplst.add(Invo.Account__c);
			
			string BusinessArea = '';
			if(Invo.BusinessArea__c == 'ZZ'){
				if(Invo.ProductGroupBusinessArea__c == 'Low Carbon' && Invo.ProductCategoryBusinessArea__c!=null){
					BusinessArea = Invo.BusinessArea__c + ' - ' + Invo.ProductGroupBusinessArea__c + ' - ' + Invo.ProductCategoryBusinessArea__c; 
				}else{
					BusinessArea = Invo.BusinessArea__c + ' - ' + Invo.ProductGroupBusinessArea__c ; 
				}                                        
			}else{
				BusinessArea = Invo.BusinessArea__c;                                        
			}
			BusinessAreasplst.add(BusinessArea);
			//Ac:01
			if(mapActualSoldAmount.containsKey(BusinessArea)){
				mapActualSoldAmount.put(BusinessArea, Invo.SoldAmount__c + mapActualSoldAmount .get(BusinessArea));
			}else{
				mapActualSoldAmount.put(BusinessArea, Invo.SoldAmount__c);
			}
			if(mapActualTotalSale.containsKey(BusinessArea)){
				mapActualTotalSale.put(BusinessArea, Invo.Nettoerloes__c + mapActualTotalSale .get(BusinessArea));
			}else{
				mapActualTotalSale.put(BusinessArea, Invo.Nettoerloes__c);
			}
			//  }
			//Ac:05_02 
			if(ACBAAccSoldAmtMap.containsKey(Invo.Account__c+'_'+BusinessArea)){
                ACBAAccSoldAmtMap.put(Invo.Account__c+'_'+BusinessArea, Invo.SoldAmount__c + ACBAAccSoldAmtMap .get(Invo.Account__c+'_'+BusinessArea));
			}else{
				ACBAAccSoldAmtMap.put(Invo.Account__c+'_'+BusinessArea, Invo.SoldAmount__c);
			}
			//Ac:05_03 
			if(ACBAActNetProcMap.containskey(Invo.Account__c+'_'+BusinessArea)){
                ACBAActNetProcMap.put(Invo.Account__c+'_'+BusinessArea,(Invo.Nettoerloes__c + ACBAActNetProcMap.get(Invo.Account__c+'_'+BusinessArea) ));
			}else{
                ACBAActNetProcMap.put(Invo.Account__c+'_'+BusinessArea,Invo.Nettoerloes__c);
			}
		}
	}
	// US-2562 - AC:02
	 for(InvoicedOrders__c Invo : scope){
		If(Invo != null/* && Invo.Account__r.BusiessAreaForPlanning__c != null*/){   
			string BusinessArea = '';
			if(Invo.BusinessArea__c == 'ZZ'){
				if(Invo.ProductGroupBusinessArea__c == 'Low Carbon' && Invo.ProductCategoryBusinessArea__c!=null){
					BusinessArea = Invo.BusinessArea__c + ' - ' + Invo.ProductGroupBusinessArea__c + ' - ' + Invo.ProductCategoryBusinessArea__c; 
				}else{
					BusinessArea = Invo.BusinessArea__c + ' - ' + Invo.ProductGroupBusinessArea__c ; 
				}                                        
			}else{
				BusinessArea = Invo.BusinessArea__c;                                        
			}
			if(mapActualNetproceeds.containsKey(BusinessArea) && mapActualSoldAmount.containskey(BusinessArea) && Invo.SoldAmount__c != null && Invo.Nettoerloes__c != null){                                        
				mapActualNetproceeds.put(BusinessArea, ((/*Invo.SoldAmount__c**/Invo.Nettoerloes__c)/mapActualSoldAmount.get(BusinessArea)) + mapActualNetproceeds .get(BusinessArea));
			}else{ 
				if(mapActualSoldAmount.containskey(BusinessArea) && Invo.SoldAmount__c != null && Invo.Nettoerloes__c != null){
					mapActualNetproceeds.put(BusinessArea, (/*Invo.SoldAmount__c**/Invo.Nettoerloes__c)/mapActualSoldAmount.get(BusinessArea));
				}else{
					if(Invo.SoldAmount__c != null && Invo.Nettoerloes__c != null)
						mapActualNetproceeds.put(BusinessArea, (/*Invo.SoldAmount__c**/Invo.Nettoerloes__c));
				}                                        
			}
		}
	}
	// US- 2562 - AC:01/02 _ WHEN Forecast time period(month) = last month,AND forecast level = business area/ product group,
	for(SalesPlanning__c s : [SELECT Id, ForecastTimePoint__c, ForecastLevel__c,ActualSoldAmount__c,BusinessArea__c,Account__c FROM SalesPlanning__c 
							  Where  BusinessArea__c IN :BusinessAreasplst  AND ForecastLevel__c = 'Business Area/Product Group' AND Frequency__c = 'Monthly'
							  AND ForecastTimePoint__c = LAst_N_Months:1 ]){// removing Account
								  // US-2562 - AC:01
								  if(mapActualSoldAmount.get(s.BusinessArea__c)!= null)
									  s.ActualSoldAmount__c = mapActualSoldAmount.get(s.BusinessArea__c);
								  // US-2562 - AC:02
								  if(mapActualTotalSale.get(s.BusinessArea__c)!= null){
                                      if(mapActualTotalSale.get(s.BusinessArea__c)!=null && 
                                         mapActualSoldAmount.get(s.BusinessArea__c)!=null &&
                                        mapActualTotalSale.get(s.BusinessArea__c)!=0 && 
                                         mapActualSoldAmount.get(s.BusinessArea__c)!=0){
                                          Decimal netproceed = (mapActualTotalSale.get(s.BusinessArea__c)/mapActualSoldAmount.get(s.BusinessArea__c));
									  s.ActualNetProceeds__c = netproceed.setScale(5);	  
                                      }}
								  if(!SPlUpdateLst.contains(s)){
									  SPlUpdateLst.add(s);      
								  }
							  }
	//US:2562 AC_05_02and_03
	for(SalesPlanning__c s : [SELECT Id, Account__c, ActualSoldAmount__c, BusinessArea__c,ForecastLevel__c FROM SalesPlanning__c 
							  Where BusinessArea__c IN :BusinessAreasplst AND Account__c IN :Accidsplst  AND ForecastLevel__c = 'Account' AND Frequency__c = 'Monthly'
							  AND ForecastTimePoint__c = LAst_N_Months:1 ]){
								//SPAccIdlst.add(s.Account__c);//US-6894
                                SPAccbalst.add(s.BusinessArea__c+'_'+s.Account__c);//US-7940
								  s.ActualSoldAmount__c = ACBAAccSoldAmtMap.get(s.Account__c + '_' + s.BusinessArea__c);
                                  if(ACBAAccSoldAmtMap.get(s.Account__c + '_' + s.BusinessArea__c)!=null && 
                                     ACBAAccSoldAmtMap.get(s.Account__c + '_' + s.BusinessArea__c)!=0 && 
                                     ACBAActNetProcMap.get(s.Account__c + '_' + s.BusinessArea__c)!=null &&
                                    ACBAActNetProcMap.get(s.Account__c + '_' + s.BusinessArea__c)!=0){
                                    s.ActualNetProceeds__c = (ACBAActNetProcMap.get(s.Account__c + '_' + s.BusinessArea__c)/ACBAAccSoldAmtMap.get(s.Account__c + '_' + s.BusinessArea__c)).setScale(5);
								  }
								  if(!SPlUpdateLst.contains(s)){
									  SPlUpdateLst.add(s);
								  }
							  } 
	// US-2562 - AC:06 AC:07  
	BusinessAreasplst.clear();                          
	for(InvoicedOrders__c Invo : scope){
		If(Invo != null ){//US-7940
			string BusinessArea = '';
			if(Invo.BusinessArea__c == 'ZZ'){
				if(Invo.ProductGroupBusinessArea__c == 'Low Carbon' && Invo.ProductCategoryBusinessArea__c!=null){
					BusinessArea = Invo.BusinessArea__c + ' - ' + Invo.ProductGroupBusinessArea__c + ' - ' + Invo.ProductCategoryBusinessArea__c; 
				}else{
					BusinessArea = Invo.BusinessArea__c + ' - ' + Invo.ProductGroupBusinessArea__c ; 
				}                                        
			}else{
				BusinessArea = Invo.BusinessArea__c;                                        
			}
			BusinessAreasplst.add(BusinessArea); 
			//Ac:06 
			//if( !SPAccIdlst.contains(Invo.Account__c)){//US-6894
            if(!SPAccbalst.contains(BusinessArea+'_'+Invo.Account__c)){   //US-7950
				if(NPAccSoldAmtMap.containsKey(BusinessArea)){
					NPAccSoldAmtMap.put(BusinessArea, Invo.SoldAmount__c + NPAccSoldAmtMap.get(BusinessArea));
				}else{
					NPAccSoldAmtMap.put(BusinessArea, Invo.SoldAmount__c);
				}
				//Ac:07
				
				if(NPActNetProcMap.containsKey(BusinessArea)){
					NPActNetProcMap.put(BusinessArea, Invo.Nettoerloes__c + NPActNetProcMap.get(BusinessArea));
				}else{
					NPActNetProcMap.put(BusinessArea, Invo.Nettoerloes__c);
				}                                        
			}
		}
	}
	if(!BusinessAreasplst.isempty()){
		for(SalesPlanning__c s : [SELECT Id, ActualSoldAmount__c,ActualNetProceeds__c,BusinessArea__c,Account__c FROM SalesPlanning__c 
								  Where BusinessArea__c IN :BusinessAreasplst AND ForecastLevel__c = 'Account' AND Account__c = '' 
								  AND  ForecastTimePoint__c = LAst_N_Months:1 AND Frequency__c = 'Monthly' ]){
									  s.ActualSoldAmount__c = NPAccSoldAmtMap.get(s.BusinessArea__c);
                                      if(NPActNetProcMap.get(s.BusinessArea__c)!=null && 
                                         NPAccSoldAmtMap.get(s.BusinessArea__c)!=null &&
                                        NPActNetProcMap.get(s.BusinessArea__c)!=0 && 
                                         NPAccSoldAmtMap.get(s.BusinessArea__c)!=0){
                                      	s.ActualNetProceeds__c = (NPActNetProcMap.get(s.BusinessArea__c)/NPAccSoldAmtMap.get(s.BusinessArea__c)).setScale(5);
									  }
									  if(!SPlUpdateLst.contains(s)){
										  SPlUpdateLst.add(s);
									  }                                                              
								  } 
	}
	if(!SPlUpdateLst.isEmpty()){
		List<SalesPlanning__c> SPlUpdateSettoLst =  new List<SalesPlanning__c>();
		SPlUpdateSettoLst.addAll(SPlUpdateLst);
		Update SPlUpdateSettoLst;
	}            					
					}
					public static void sendNotification(){
						EmailTemplate emailTemplate =[Select Id from EmailTemplate where DeveloperName='MonthlyReminderBusinessAreaManagers'];
						Messaging.SingleEmailMessage[] messages = new  List<Messaging.SingleEmailMessage>();
						Map<String,String> mailToAddresses = getEmailAddresses();
						OrgWideEmailAddress owa = new OrgWideEmailAddress(); //US- 3860
						owa = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress limit 1]; //US- 3860
						for(String s:mailToAddresses.keySet()){
							List<String> sList=new List<String>();
							sList.add(mailToAddresses.get(s));
							Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
							message.setTargetObjectId(s);
							message.setUseSignature(false);
							message.setBccSender(false);
							message.setSaveAsActivity(false);
							message.setTemplateID(emailTemplate.Id);
							message.setToAddresses(sList);
							message.setOrgWideEmailAddressId(owa.id);//US- 3860
							messages.add(message);
						}
						Messaging.sendEmail(messages);        
					}
					public static Map<String,String> getEmailAddresses() {
						List<String> idList = new List<String>();
						Map<String,String> mailToAddresses = new Map<String,String>();
						Group g = [SELECT Id,(select userOrGroupId from groupMembers) FROM group WHERE DeveloperName = 'BusinessAreaSalesPlanningManagers'];
						for (GroupMember gm : g.groupMembers) {
							idList.add(gm.userOrGroupId);
						}
						User[] usr = [SELECT Id,email FROM user WHERE id IN :idList];
						for(User u : usr) {
							mailToAddresses.put(u.Id,u.email);
						}
						return mailToAddresses;
					}
					public void finish(Database.BatchableContext BC){        
	//US-4374 AC: 06
	sendNotification();
}
}
