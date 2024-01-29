/****************************************************************************
* Name: PrakulaTriggerHelper
* Author: Harshitha Udaykumar
* Created Date: 13/09/2023
* Description: Helper class for Prakula Trigger
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
****************************************************************************/
public  with sharing class PrakulaTriggerHelper {
    /****************************************************************************
* Author Name: Harshitha Udaykumar
* Description: Update the language and User role on Prakula based on the account populated.
* Created Date: 13/09/2022
* Last Modified Date: 
****************************************************************************/
    public static void updateUserRoleOnPrakula(List<Praekula__c> prakulaList,Map<Id, Praekula__c> prakulamap){
        List<Id> accountIDlst = new List<Id>();
        Map<Id,String> accountlst = new Map<Id,String>();
        for(Praekula__c newPrakulaLoop : prakulaList){
            if(newPrakulaLoop.Account__c != null)
                accountIDlst.add(newPrakulaLoop.Account__c);
        }
        List<Account> acclst = [SELECT Id,Language__c FROM Account where Id IN :accountIDlst];
         for(Account acc : acclst)
         {
             accountlst.put(acc.Id,acc.Language__c);
         }
        Map<Id, Map<String, Integer>> accountRoleCounts = new Map<Id, Map<String, Integer>>();
        List<AccountTeamMember> accountteammemberslst = [SELECT Id,TeamMemberRole,UserId,AccountId,ChannelOfDistribution__c from AccountTeamMember WHERE AccountId IN :accountIDlst];
        for (AccountTeamMember accmem : accountteammemberslst) {
        if (!accountRoleCounts.containsKey(accmem.AccountId)) {
            accountRoleCounts.put(accmem.AccountId, new Map<String, Integer>());
        }
        Map<String, Integer> roleCountMap = accountRoleCounts.get(accmem.AccountId);
          if (!roleCountMap.containsKey(accmem.TeamMemberRole)) {
                roleCountMap.put(accmem.TeamMemberRole, 1);
            } else {
                roleCountMap.put(accmem.TeamMemberRole, roleCountMap.get(accmem.TeamMemberRole) + 1);
            }
       }
        for (Praekula__c newPrakula : prakulaList) {
            Praekula__c prakulaoldmap;
           if(prakulamap!= null)
             prakulaoldmap = prakulamap.get(newPrakula.Id);
           if((prakulaoldmap!= null && prakulaoldmap.Account__c != newPrakula.Account__c) || prakulaoldmap == null){
             newPrakula.Language__c = accountlst.get(newPrakula.Account__c);
            for(AccountTeamMember accmem : accountteammemberslst){
                if(newPrakula.Account__c == accmem.AccountId ){
                    if(accmem.TeamMemberRole == 'ZS' && accountRoleCounts.get(newPrakula.Account__c).containsKey('ZS') && accountRoleCounts.get(newPrakula.Account__c).get('ZS') == 1)
                        newPrakula.QualityRepresentative__c = accmem.UserId;
                    if(accmem.TeamMemberRole == 'ZQ' && accountRoleCounts.get(newPrakula.Account__c).containsKey('ZQ') && accountRoleCounts.get(newPrakula.Account__c).get('ZQ') == 1)
                        newPrakula.QualityManager__c = accmem.UserId;
                    if(accmem.TeamMemberRole == 'ZK' && accountRoleCounts.get(newPrakula.Account__c).containsKey('ZK') && accountRoleCounts.get(newPrakula.Account__c).get('ZK') == 1)
                        newPrakula.ProductManager__c = accmem.UserId;
                    if(accmem.TeamMemberRole == 'ZM' && accountRoleCounts.get(newPrakula.Account__c).containsKey('ZM') && accountRoleCounts.get(newPrakula.Account__c).get('ZM') == 1)
                        newPrakula.SalesRepresentative__c = accmem.UserId; 
                } 
            }
           }
        }
    }
    
//US-7210    
/***************************************************************************************************
* Author Name: Naina Butle
* Description: Method to populate Technical Offer field value a Prakula record before insert.
* Created Date: 30/11/2022
* Last Modified Date: 
****************************************************************************************************/
    public static void populateTechnicalOffer (List<Praekula__c> newPrakulaMap, Map<Id, Praekula__c> oldPrMap) {
        Map<String, Map<String, String>> contentBlockMap = new Map<String, Map<String, String>>();
        List<String> exeptionList = new List<String>();
        try{
            for(ContentBlock__mdt cb : [SELECT Id, Language__c, PicklistValue__c, ContentText__c FROM ContentBlock__mdt]){
                if(!contentBlockMap.containsKey(cb.PicklistValue__c))
                    contentBlockMap.put(cb.PicklistValue__c, new Map<String, String>());
                Map<String, String> innerMap = contentBlockMap.get(cb.PicklistValue__c);
                innerMap.put(cb.Language__c, cb.ContentText__c);
            }
            for(Praekula__c prLoop : newPrakulaMap){
                List<String> pickListValuesList;
                if(prLoop.TextForSelectionQuality__c != null){
                    pickListValuesList = prLoop.TextForSelectionQuality__c.split(';');
                    String tempTextQuality=''; 
                    String oldTextQuality ='';           
                    for(String plv : pickListValuesList){
                        Map<String, String> valuesToBeChecked = contentBlockMap.get(plv);
                        if(oldPrMap != null && valuesToBeChecked != null  && oldPrMap.get(prLoop.ID).TextForSelectionQuality__c != null && oldPrMap.get(prLoop.ID).TechnicalRemarkQualityDepartment__c  != null){ //2
                            if(!oldPrMap.get(prLoop.ID).TextForSelectionQuality__c.contains(plv) && !oldPrMap.get(prLoop.ID).TechnicalRemarkQualityDepartment__c.contains(valuesToBeChecked.get(prLoop.Language__c))){ //3
                                tempTextQuality+= '\n' + valuesToBeChecked.get(prLoop.Language__c);
                            }
                        }
                        else if(valuesToBeChecked != null){
                            tempTextQuality+= '\n' + valuesToBeChecked.get(prLoop.Language__c);
                        }
                    }
                    if(oldPrMap != null && (prLoop.TextForSelectionQuality__c != oldPrMap.get(prLoop.ID).TextForSelectionQuality__c)){ //2
                        if(prLoop.TechnicalRemarkQualityDepartment__c  != null){//3
                            oldTextQuality = prLoop.TechnicalRemarkQualityDepartment__c  ;  
                        }else if(prLoop.TechnicalRemarkQualityDepartment__c  == null){
                            oldTextQuality = '';
                        }
                        tempTextQuality = tempTextQuality.replace('null', '');
                        oldTextQuality = oldTextQuality.replace('null', '');
                        prLoop.TechnicalRemarkQualityDepartment__c  = oldTextQuality + tempTextQuality;
                    }else if(oldPrMap == null){
                        prLoop.TechnicalRemarkQualityDepartment__c = oldTextQuality + tempTextQuality;
                    }
                } 
                //8137 start
                 if(prLoop.TextForSelectionSales__c != null){ //1
                    pickListValuesList = prLoop.TextForSelectionSales__c.split(';'); 
                    String tempTechOffer=''; 
                    String oldTechOffer ='';           
                    for(String plv : pickListValuesList){
                        Map<String, String> valuesToBeChecked;
                        valuesToBeChecked = contentBlockMap.get(plv);
                        if(oldPrMap != null && valuesToBeChecked != null  && oldPrMap.get(prLoop.ID).TextForSelectionSales__c != null && oldPrMap.get(prLoop.ID).TechnicalRemarkSales__c != null){ //2
                            if(!oldPrMap.get(prLoop.ID).TextForSelectionSales__c.contains(plv) && !oldPrMap.get(prLoop.ID).TechnicalRemarkSales__c.contains(valuesToBeChecked.get(prLoop.Language__c))){ //3
                                tempTechOffer+= '\n' + valuesToBeChecked.get(prLoop.Language__c);
                            }
                        }
                        else if(valuesToBeChecked != null){
                            tempTechOffer+= '\n' + valuesToBeChecked.get(prLoop.Language__c);
                        }
                    }
                    if(oldPrMap != null && (prLoop.TextForSelectionSales__c!=oldPrMap.get(prLoop.ID).TextForSelectionSales__c)){ //2
                        if(prLoop.TechnicalRemarkSales__c != null){//3
                            oldTechOffer = prLoop.TechnicalRemarkSales__c ;  
                        }else if(prLoop.TechnicalRemarkSales__c == null){
                            oldTechOffer = '';
                        }
                        tempTechOffer = tempTechOffer.replace('null', '');
                        oldTechOffer = oldTechOffer.replace('null', '');
                        prLoop.TechnicalRemarkSales__c = oldTechOffer + tempTechOffer;
                    }else if(oldPrMap == null){
                        prLoop.TechnicalRemarkSales__c = oldTechOffer + tempTechOffer;
                    }
                }
                //8137 end
            }
        }catch(Exception e){
            String exeptionDetails = e.getCause()+' ; '+e.getLineNumber() + ' ; '+e.getMessage()+' ; '+e.getStackTraceString()
                +' ; '+e.getTypeName() ;
            exeptionList.add(exeptionDetails);
            ExceptionUtilClass.logException(ConstantClass.TECHREQUIREMENT_OBJECT,ConstantClass.TECHREQEXCEPTIONERROR_MSG,'',exeptionDetails,ConstantClass.APEX_CLASS);  
        }
    }
}