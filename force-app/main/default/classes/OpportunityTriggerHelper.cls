/****************************************************************************
* Name: OpportunityTriggerHandler
* Author: Naina Butle
* Created Date: 02/12/2022
* Description: Helper class for Opportunity Trigger
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
* Naina Butle       08-02-2023              US-2241
* Naina Butle       20/02/2022              US-2218 Opportunity Creator to be inserted as Sales Rep when Sales Profile
****************************************************************************/
public with sharing class OpportunityTriggerHelper {
    /****************************************************************************
* Author Name: Naina B
* Description: Method to update the  quality team.
* Created Date: 19/10/2022
* Last Modified Date: 
****************************************************************************/
public static void updateSalesRProductMQualityR(list<Opportunity> oppList, Map<Id, Opportunity> oldOppMap){
    Set<Id> accountIdSet = new Set<Id>();
    Map<Id, List<AccountTeamMember>> accountIdVsAccountTeamMemberMap = new Map<Id, List<AccountTeamMember>>();
    Map<Id, String> accChannel = new Map<Id, String>();
    Map<Id, String> accSAPAccount = new Map<Id, String>();
     Savepoint sp;
    try{
       sp = Database.setSavepoint();
        User user = [SELECT ID, Profile.Name From User WHERE ID = :UserInfo.getUserId() LIMIT 1];//US-2218
        for(Opportunity opp : oppList){
            if(opp.AccountId != null){
                accountIdSet.add(opp.AccountId);
            }
            if(oldOppMap != null){ //5407
                if(opp.ChannelOfDistribution__c != null && oldOppMap.containsKey(opp.Id) && opp.ChannelOfDistribution__c != oldOppMap.get(opp.Id).ChannelOfDistribution__c){
                    opp.SalesRepresentative__c = null;
                    opp.ProductManager__c = null;
                    opp.QualityRep__c = null;
                }
                if(opp.ChannelOfDistribution__c != null && oldOppMap.containsKey(opp.Id) && opp.ChannelOfDistribution__c != oldOppMap.get(opp.Id).ChannelOfDistribution__c){
                    opp.SalesRepresentative__c = null;
                    opp.ProductManager__c = null;
                    opp.QualityRep__c = null;
                }
            }
        }
        for(Account acc: [SELECT Id,ChannelOfDistribution__c, SAPAccountNumber__c FROM Account WHERE ID IN:accountIdSet]){
            accChannel.put(acc.Id, acc.ChannelOfDistribution__c);
            if(acc.SAPAccountNumber__c != null){
                accSAPAccount.put(acc.Id, acc.SAPAccountNumber__c);
            }
        }
        for(AccountTeamMember accTeam : [SELECT Id, AccountId, ChannelOfDistribution__c, QualityDepartment__c, TeamMemberRole, UserId, User.Name,
                                         Account.ChannelOfDistribution__c
                                         FROM AccountTeamMember
                                         WHERE AccountId IN :accountIdSet]){
                                             if (String.isNotBlank(accTeam.AccountId) && String.isNotBlank(accTeam.Account.ChannelOfDistribution__c)){
                                                 if(!accountIdVsAccountTeamMemberMap.containsKey(accTeam.AccountId)){
                                                     accountIdVsAccountTeamMemberMap.put(accTeam.AccountId, new List<AccountTeamMember>());
                                                 }
                                                 accountIdVsAccountTeamMemberMap.get(accTeam.AccountId).add(accTeam);
                                             }
                                         }
        
        for(Opportunity oppData :oppList){
            if(accSAPAccount.containsKey(oppData.AccountId)){
                if(( (oppData.ChannelOfDistribution__c == null || String.isBlank(oppData.ChannelOfDistribution__c)) && (!accChannel.containsKey(oppData.AccountId) || accChannel.get(oppData.AccountId) == null)) ||
                   ((String.isNotBlank(oppData.ChannelOfDistribution__c) ) && 
                    (accChannel.containsKey(oppData.AccountId) && !String.isBlank(accChannel.get(oppData.AccountId)) && accChannel.get(oppData.AccountId) != null && accChannel.get(oppData.AccountId).contains(oppData.ChannelOfDistribution__c)) //US-2241
                   )){ 
                       if(accountIdVsAccountTeamMemberMap.containsKey(oppData.AccountId))
                       {   
                           for(AccountTeamMember accData : accountIdVsAccountTeamMemberMap.get(oppData.AccountId)){
                               if(oppData.ChannelOfDistribution__c == accData.ChannelOfDistribution__c){
                                   if(accData.TeamMemberRole == ConstantClass.SALESREPRESENTIVE){
                                       oppData.SalesRepresentative__c = accData.UserId;
                                   }else if(accData.TeamMemberRole == ConstantClass.ACCOUNTMANAGER){
                                       oppData.ProductManager__c = accData.UserId;
                                   }else if(accData.TeamMemberRole == ConstantClass.QUALITYREP){
                                       oppData.QualityRep__c = accData.UserId;
                                   }else if(accData.TeamMemberRole == ConstantClass.QWACCOUNTMANAGER){ //7428
                                    oppData.QualityManager__c = accData.UserId;
                                   }
                               }
                           }
                           //US-2218 - Start
                           if(user.Profile.Name == ConstantClass.SAG_SALES_PROFILE && (oppData.SalesRepresentative__c == null || String.isBlank(oppData.SalesRepresentative__c))){
                               oppData.SalesRepresentative__c = user.Id;
                           }
                           //US-2218 - end
                           
                       }else{
                           //oppData.ChannelOfDistribution__c.addError(oppData.ChannelOfDistribution__c + ' ' + System.Label.ChannelOfDistributionError);
                       }
                       //US-2218 - Start
                       if(user.Profile.Name == ConstantClass.SAG_SALES_PROFILE && (oppData.SalesRepresentative__c == null || String.isBlank(oppData.SalesRepresentative__c))){
                           oppData.SalesRepresentative__c = user.Id;
                       }
                       //US-2218 - end
                   }else{
                       oppData.ChannelOfDistribution__c.addError(oppData.ChannelOfDistribution__c + ' ' + System.Label.ChannelOfDistributionError);
                   }
            }
        }
    }catch(Exception e){
        Database.RollBack(sp);
        String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; '+ e.getMessage() + ' ; '+ e.getStackTraceString()
            + ' ; ' + e.getTypeName() ;
        ExceptionUtilClass.publishException(ConstantClass.OPPORTUNITY_OBJECT, ConstantClass.CHANNELDISCLASS_ERROR, oppList[0].Id, exdetails, ConstantClass.APEX_CLASS);
    }
}
    
    /****************************************************************************
* Author Name: Naina B
* Description: Method to update the FinalCheckStartDate and QualityCheckStartDate when Opportunity Stage is changed to "Final Check/Quality Check".
* Created Date: 31/01/2023
* Last Modified Date: 1/02/2023
****************************************************************************/
    public static void updateFinalCheckStartDate(list<Opportunity> oppList,Map<Id, Opportunity> oppOldMap){
        for(Opportunity opp : oppList){
            if(oppOldMap.get(opp.Id).StageName != ConstantClass.QUALITYCHECK_STAGENAME && opp.StageName == ConstantClass.QUALITYCHECK_STAGENAME){
                opp.QualityCheckStartDate__c = System.today();
            }
            else if(opp.StageName == ConstantClass.FINALCHECK_STAGENAME && opp.FinalCheckStartDate__c== null){
                opp.FinalCheckStartDate__c = System.today();
            }
        }
    }
    
    /****************************************************************************
* Author Name: Impana Paalyam
* Description: Method to update the QualityCheckTotalDuration when  Opportunity Stage is changed from Quality Check to some other stage.
* Created Date: 01/02/2023
* Last Modified Date: 
****************************************************************************/
    public static void updateQualityCheckTotalDuration (list<Opportunity> oppList,Map<Id, Opportunity> oppOldMap,Map<Id, Opportunity> oppNewMap){
        for(Opportunity opp : oppList){
            if(oppOldMap.get(opp.Id).StageName == ConstantClass.QUALITYCHECK_STAGENAME && oppNewMap.get(opp.Id).StageName != ConstantClass.QUALITYCHECK_STAGENAME && opp.QualityCheckStartDate__c!= null){
                Integer diff = opp.QualityCheckStartDate__c.date().daysBetween(Date.today());
                if(opp.QualityCheckTotalDuration__c!= null){
                    opp.QualityCheckTotalDuration__c = opp.QualityCheckTotalDuration__c + diff;
                } else {
                    opp.QualityCheckTotalDuration__c = diff;
                }
            }
        }
        
    } 
}
