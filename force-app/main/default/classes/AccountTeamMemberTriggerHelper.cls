/****************************************************************************
* Name: AccountTeamMemberTriggerHelper
* Author: Naina Butle
* Created Date: 28/11/2022
* Description: Helper class for AccountTeamMember Trigger
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
****************************************************************************/
public with sharing class AccountTeamMemberTriggerHelper {
    /****************************************************************************
* Author Name: Naina B
* Description: updating SalesRepresentative__c,ProductManager__c,QualityRep__c of opportunity when AccountTeamMember was created/updated.
* Created Date: 29/11/2022
* Last Modified Date: 
****************************************************************************/
    public static void updateCODAccountTeamMemberInsert(Map<Id, AccountTeamMember> accTeamMap){
        if(accTeamMap != null){
            Savepoint sp = Database.setSavepoint();
            Set<ID> accountIDSet = new Set<ID>();
            List<String> channelDistList = new List<String>();
            Map<ID, List<Opportunity>> accIdvsOppMap = new Map<ID, List<Opportunity>>();
            List<Opportunity> opps = new List<Opportunity>();
            try{
                for(AccountTeamMember accTeamMem : accTeamMap.values())
                {
                    accountIDSet.add(accTeamMem.AccountId);
                    if(accTeamMem.ChannelOfDistribution__c != null){
                        channelDistList.add(accTeamMem.ChannelOfDistribution__c);
                    }
                }
                for(Opportunity opp : [SELECT Id, AccountId, IsClosed, ChannelOfDistribution__c FROM Opportunity
                                       WHERE AccountId IN : accountIDSet AND IsClosed =: False
                                       AND ChannelOfDistribution__c IN : channelDistList]){
                                           if(!accIdvsOppMap.containsKey(opp.AccountId)){
                                               accIdvsOppMap.put(opp.AccountId, new List<Opportunity>());
                                           }
                                           accIdvsOppMap.get(opp.AccountId).add(opp);
                                       }
                for(AccountTeamMember ateamLoop : accTeamMap.values())
                {
                    if(accIdvsOppMap.containsKey(ateamLoop.AccountId)){
                        for(Opportunity oppLoop : accIdvsOppMap.get(ateamLoop.AccountId)){
                            if(ateamLoop.ChannelOfDistribution__c == oppLoop.ChannelOfDistribution__c){
                                if(ateamLoop.TeamMemberRole == ConstantClass.SALESREPRESENTIVE){
                                    oppLoop.SalesRepresentative__c = ateamLoop.UserId;
                                }else if(ateamLoop.TeamMemberRole == ConstantClass.ACCOUNTMANAGER){
                                    oppLoop.ProductManager__c = ateamLoop.UserId;
                                }else if(ateamLoop.TeamMemberRole == ConstantClass.QUALITYREP){
                                    oppLoop.QualityRep__c = ateamLoop.UserId;
                                }else if(ateamLoop.TeamMemberRole == ConstantClass.QWACCOUNTMANAGER){ //7428
                                    oppLoop.QualityManager__c = ateamLoop.UserId;
                                }
                            }
                        }
                    }
                }
                for(Id accId : accIdvsOppMap.KeySet())
                {
                    opps.addAll(accIdvsOppMap.get(accId));     
                }
                if(!opps.isEmpty()){ 
                    update opps; 
                }
                
            }catch(Exception e){
                Database.RollBack(sp);   
                String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; '+ e.getMessage() + ' ; '+ e.getStackTraceString()
                    + ' ; ' + e.getTypeName() ;
                ExceptionUtilClass.logException(ConstantClass.ACCTEAMMEMBER_OBJECT, ConstantClass.ACCTEAMMEMTRIGGER_ERROR, null, exdetails, ConstantClass.APEX_CLASS);
            }
        }
    }
    
    /****************************************************************************
* Author Name: Naina B
* Description: updating SalesRepresentative__c,ProductManager__c,QualityRep__c value as null when channel of distrubition was updated or AccountTeamMember was deleted.
* Created Date: 29/11/2022
* Last Modified Date: 
****************************************************************************/  
    public static void removeExistingUser(Map<Id, AccountTeamMember> accTeamOldMap){
        if(accTeamOldMap != null){
            Savepoint sp = Database.setSavepoint();
            Set<ID> accountIDSet = new Set<ID>();
            List<String> channelDistList = new List<String>();
            Map<ID, List<Opportunity>> accIdvsOppMap = new Map<ID, List<Opportunity>>();
            List<Opportunity> opps = new List<Opportunity>();
            try{
                for(AccountTeamMember accTeamMem : accTeamOldMap.values())
                {
                    accountIDSet.add(accTeamMem.AccountId);
                    if(accTeamMem.ChannelOfDistribution__c != null){
                        channelDistList.add(accTeamMem.ChannelOfDistribution__c);
                    }
                }
                for(Opportunity opp : [SELECT Id, AccountId, IsClosed, ChannelOfDistribution__c FROM Opportunity WHERE AccountId IN : accountIDSet AND IsClosed =: False AND ChannelOfDistribution__c IN : channelDistList]){
                    if(!accIdvsOppMap.containsKey(opp.AccountId)){
                        accIdvsOppMap.put(opp.AccountId, new List<Opportunity>());
                    }
                    accIdvsOppMap.get(opp.AccountId).add(opp);
                }
                for(AccountTeamMember ateamLoop : accTeamOldMap.values())
                {
                    if(accIdvsOppMap.containsKey(ateamLoop.AccountId)){
                        for(Opportunity oppLoop : accIdvsOppMap.get(ateamLoop.AccountId)){
                            if(ateamLoop.ChannelOfDistribution__c == oppLoop.ChannelOfDistribution__c){
                                if(ateamLoop.TeamMemberRole == ConstantClass.SALESREPRESENTIVE){
                                    oppLoop.SalesRepresentative__c = null;
                                }else if(ateamLoop.TeamMemberRole == ConstantClass.ACCOUNTMANAGER){
                                    oppLoop.ProductManager__c = null;
                                }else if(ateamLoop.TeamMemberRole == ConstantClass.QUALITYREP){
                                    oppLoop.QualityRep__c = null;
                                }else if(ateamLoop.TeamMemberRole == ConstantClass.QWACCOUNTMANAGER){ //7428
                                    oppLoop.QualityManager__c = null;
                                }
                            }
                        }
                    }
                }
                for(Id accId : accIdvsOppMap.KeySet())
                {
                    opps.addAll(accIdvsOppMap.get(accId));  
                }
                if(!opps.isEmpty()){ 
                    update opps; 
                }
            }catch(Exception e){
                Database.RollBack(sp);   
                String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; '+ e.getMessage() + ' ; '+ e.getStackTraceString()
                    + ' ; ' + e.getTypeName() ;
                ExceptionUtilClass.logException(ConstantClass.ACCTEAMMEMBER_OBJECT, ConstantClass.ACCTEAMMEMTRIGGER_ERROR, null, exdetails, ConstantClass.APEX_CLASS);
            } 
        }  
    }
    
}