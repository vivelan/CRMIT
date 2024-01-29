/****************************************************************************
* Name: AccountContactRelationTriggerHelper
* Author: Impana Paalyam
* Created Date: 20/04/2023
* Description: Helper class for AccountContactRelation Trigger
*****************************************************************************/
public with sharing class AccountContactRelationTriggerHelper {
    public static void AccountContactRelationInsert(Map<Id, AccountContactRelation> acccontMap){
        Set<Id> contactSet =new Set<Id>();
        Set<Id> accountSet =new Set<Id>();
        List<User> usersToUpdate = new List<User>();
        if(acccontMap != null){
            for(AccountContactRelation acr:acccontMap.Values())
            {
                if(acr.Roles!=null && acr.Roles.contains(ConstantClass.CUSTOMER_PORTAL_USER)){
                    if(acr.ContactId!=null)
                    {
                        contactSet.add(acr.ContactId);
                    }
                }}
            List<AccountContactRelation> AccountList1 = new List<AccountContactRelation>();
            AccountList1=[Select accountid,Isactive,roles from AccountContactRelation where ContactId In:contactSet and Isactive = true  and roles INCLUDES('Customer Portal User')];
            for(AccountContactRelation ac:AccountList1){
                accountSet.add(ac.accountid);
            }
            
            usersToUpdate = [SELECT Id, AccountSAPIds__c,ContactId,accountId FROM User WHERE ContactId In :contactSet];
            Map<Id,Account> accidToSapnumberMap = new Map<Id,Account>([Select id,SAPAccountNumber__c from account where id in :accountSet and SAPAccountNumber__c!=null]);
            Map<Id,String> accidToSAP =new Map<Id,String> ();
            if(accidToSapnumberMap!=null){
                for(account a:accidToSapnumberMap.Values())
                {
                    if(a.SAPAccountNumber__c!=null && a.SAPAccountNumber__c!=''){
                        accidToSAP.put(a.id,a.SAPAccountNumber__c);
                    }
                }
                
            }
            List<AccountContactRelation> contactlist1 = [Select ContactId,account.SAPAccountNumber__c,accountid from AccountContactRelation where ContactId  IN :contactSet and account.SAPAccountNumber__c!=null and Isactive = true];
            Map<Id,Set<String>> contactidtoSapnumberMap = new Map<Id,Set<String>>();
            if(accidToSAP!=null && contactlist1.size()>0 ){
                for(AccountContactRelation acr1:contactlist1){
                    if(contactidtoSapnumberMap.containskey(acr1.ContactId)){
                        Set<String> SapSet = contactidtoSapnumberMap.get(acr1.ContactId);
                        SapSet.add(accidToSAP.get(acr1.accountId));
                        contactidtoSapnumberMap.put(acr1.ContactId, SapSet);}
                    else{
                        contactidtoSapnumberMap.put(acr1.ContactId,new Set<String>{accidToSAP.get(acr1.accountId)});
                    }
                }
            }
            List<String> accountSAPIds = new List<String>();
            for(AccountContactRelation acr:acccontMap.Values()){
                String Str;
                for (user u:usersToUpdate) {
                    if(contactidtoSapnumberMap.containskey(acr.ContactId)){
                        accountSAPIds.addAll(contactidtoSapnumberMap.get(acr.ContactId));}
                    Str = String.join(accountSAPIds,';'); 
                    str = str.removeEnd(';');
                    u.AccountSAPIds__c = Str; 
                }
            } 
        }
        if(usersToUpdate!=null){
            update usersToUpdate;
        }
    }
    
    public static void AccountContactRelationUpdate(Map<Id, AccountContactRelation> newacccontMap,Map<Id, AccountContactRelation> oldacccontMap){
        Set<Id> contactSet =new Set<Id>();
        Set<Id> accountSet =new Set<Id>();
        List<User> usersToUpdate = new List<User>();
        for(AccountContactRelation acr:newacccontMap.Values())
        {
            AccountContactRelation oldAcr = (AccountContactRelation)Trigger.oldMap.get(acr.Id);
            //8557
            if(acr.Roles!=null && oldAcr.Roles!=null && ((acr.Roles != oldAcr.Roles)||(oldAcr.Roles.contains(ConstantClass.CUSTOMER_PORTAL_USER) && !Acr.Roles.contains(ConstantClass.CUSTOMER_PORTAL_USER))||(!oldAcr.Roles.contains(ConstantClass.CUSTOMER_PORTAL_USER) && Acr.Roles.contains(ConstantClass.CUSTOMER_PORTAL_USER)) ||(oldAcr.IsActive==true && acr.IsActive == false)||(oldAcr.IsActive==false && acr.IsActive == true))){
                if(acr.ContactId!=null)
                {
                    contactSet.add(acr.ContactId);
                }
            }}
        List<AccountContactRelation> AccountList1 = new List<AccountContactRelation>();
        AccountList1=[Select accountid,Isactive,roles from AccountContactRelation where ContactId In:contactSet and Isactive = true  and roles INCLUDES('Customer Portal User')];
        for(AccountContactRelation ac:AccountList1){
            accountSet.add(ac.accountid);
        }
        usersToUpdate = [SELECT Id, AccountSAPIds__c,ContactId,accountId FROM User WHERE ContactId In :contactSet];
        Map<Id,Account> accidToSapnumberMap = new Map<Id,Account>([Select id,SAPAccountNumber__c from account where id in :accountSet and SAPAccountNumber__c!=null]);
        Map<Id,String> accidToSAP =new Map<Id,String> ();
        if(accidToSapnumberMap!=null){
            for(account a:accidToSapnumberMap.Values())
            {
                if(a.SAPAccountNumber__c!=null && a.SAPAccountNumber__c!=''){
                    accidToSAP.put(a.id,a.SAPAccountNumber__c);
                }
            }
            
        }
        List<AccountContactRelation> contactlist1 = [Select ContactId,account.SAPAccountNumber__c,accountid from AccountContactRelation where ContactId  IN :contactSet and account.SAPAccountNumber__c!=null and Isactive = true];
        Map<Id,Set<String>> contactidtoSapnumberMap = new Map<Id,Set<String>>();
        if(accidToSAP!=null && contactlist1.size()>0 ){
            for(AccountContactRelation acr1:contactlist1){
                if(contactidtoSapnumberMap.containskey(acr1.ContactId)){
                    Set<String> SapSet = contactidtoSapnumberMap.get(acr1.ContactId);
                    SapSet.add(accidToSAP.get(acr1.accountId));
                    contactidtoSapnumberMap.put(acr1.ContactId, SapSet);}
                else{
                    contactidtoSapnumberMap.put(acr1.ContactId,new Set<String>{accidToSAP.get(acr1.accountId)});
                }
            }
        }
        List<String> accountSAPIds = new List<String>();
        for(AccountContactRelation acr:newacccontMap.Values()){
            String Str;
            for (user u:usersToUpdate) {
                if(contactidtoSapnumberMap.containskey(acr.ContactId)){
                    accountSAPIds.addAll(contactidtoSapnumberMap.get(acr.ContactId));}
                Str = String.join(accountSAPIds,';'); 
                str = str.removeEnd(';');
                u.AccountSAPIds__c = Str; 
            }
        } 
        
        if(usersToUpdate!=null){
            update usersToUpdate;
        }
        
    }
    
    public static void AccountContactRelationbeforeDelete(Map<Id, AccountContactRelation> oldacccontMap){
        Boolean checkCustomPermission = FeatureManagement.checkPermission(ConstantClass.MANAGE_CUSTOMER_PORTAL_PERMISSION);
                for(AccountContactRelation acr:oldacccontMap.Values())
        {
            if(acr.Roles!=null && acr.Roles.contains(ConstantClass.CUSTOMER_PORTAL_USER) && checkCustomPermission == false ){
                acr.addError(System.Label.AccountContactRelationError);
            }}
        
    }
    
    public static void AccountContactRelationafterDelete(Map<Id, AccountContactRelation> oldacccontMap){
        for(AccountContactRelation acr:oldacccontMap.Values()){
            AccountContactRelation oldAcr = (AccountContactRelation)Trigger.oldMap.get(acr.Id);
            if(oldAcr.Roles!=null && oldAcr.Roles.contains(ConstantClass.CUSTOMER_PORTAL_USER)){
                AccountContactRelationTriggerHelper.AccountContactRelationInsert(oldacccontMap);
            }
        }
    }
        //7028 Start
    public static void updateSegmentFieldonContact(Map<Id, AccountContactRelation> acccontNewMap){
         Map<Id, Contact> contactAllMap = new Map<Id, Contact>();
        Set<Id> accountSet = new Set<Id>();
        for(AccountContactRelation acr:acccontNewMap.Values())
        {
            if(acr.AccountId != null){
                accountSet.add(acr.AccountId);
            }
        }
        
        for(AccountContactRelation accRLoop : [SELECT ID, ContactId, AccountId, Account.Segment1__c, Account.Segment2__c, Account.Segment3__c, Contact.Segment1__c, Contact.Segment2__c, Contact.Segment3__c FROM AccountContactRelation WHERE AccountId In:accountSet]){
            Contact con = new Contact();
            con.Id = accRLoop.ContactId; 
            if(accRLoop.Account.Segment1__c != null && accRLoop.Contact.Segment1__c != null && !accRLoop.Contact.Segment1__c.Contains(accRLoop.Account.Segment1__c)){
                List<String> segmentList = new List<String>();
                segmentList.add(accRLoop.Contact.Segment1__c);
                segmentList.add(accRLoop.Account.Segment1__c);
                String Str = String.join(segmentList,';').removeEnd(';'); 
                con.Segment1__c =  Str;
            }else if(accRLoop.Account.Segment1__c != null && accRLoop.Contact.Segment1__c == null){
                con.Segment1__c = accRLoop.Account.Segment1__c;
            }else{
                con.Segment1__c = accRLoop.Contact.Segment1__c;
            }
            
            if(accRLoop.Account.Segment2__c != null && accRLoop.Contact.Segment2__c != null && !accRLoop.Contact.Segment2__c.Contains(accRLoop.Account.Segment2__c)){
                List<String> segmentList = new List<String>();
                segmentList.add(accRLoop.Contact.Segment2__c);
                segmentList.add(accRLoop.Account.Segment2__c);
                String Str = String.join(segmentList,';').removeEnd(';'); 
                con.Segment2__c =  Str;
            }else if(accRLoop.Account.Segment2__c != null && accRLoop.Contact.Segment2__c == null){
                con.Segment2__c = accRLoop.Account.Segment2__c;
            }else{
                con.Segment2__c = accRLoop.Contact.Segment2__c;
            }
            
            if(accRLoop.Account.Segment3__c != null && accRLoop.Contact.Segment3__c != null && !accRLoop.Contact.Segment3__c.Contains(accRLoop.Account.Segment3__c)){
                List<String> segmentList = new List<String>();
                segmentList.add(accRLoop.Contact.Segment3__c);
                segmentList.add(accRLoop.Account.Segment3__c);
                String Str = String.join(segmentList,';').removeEnd(';'); 
                con.Segment3__c =  Str;
            }else if(accRLoop.Account.Segment3__c != null && accRLoop.Contact.Segment3__c == null){
                con.Segment3__c = accRLoop.Account.Segment3__c;
            }else{
                con.Segment3__c = accRLoop.Contact.Segment3__c;
            }
            contactAllMap.put(con.Id, con);
        }
        
        if(!contactAllMap.isEmpty()){
            update contactAllMap.values();
        }
    }
    
    
    public static void removeSegmentFieldonContact(Map<Id, AccountContactRelation> acccontOldMap){
        Map<Id, Contact> contactRemoveMap = new Map<Id, Contact>();
        Map<Id, Contact> contactUpdateMap = new Map<Id, Contact>();

        for(AccountContactRelation accRLoop : [SELECT ID, ContactId, AccountId, Account.Segment1__c, Account.Segment2__c, Account.Segment3__c, Contact.Segment1__c, Contact.Segment2__c, Contact.Segment3__c FROM AccountContactRelation WHERE Id In : acccontOldMap.Keyset()]){
            Contact con = new Contact();
            con.Id = accRLoop.ContactId; 
            if(accRLoop.Account.Segment1__c != null && accRLoop.Contact.Segment1__c != null && accRLoop.Contact.Segment1__c.Contains(accRLoop.Account.Segment1__c)){
                con.Segment1__c =  accRLoop.Contact.Segment1__c.remove(accRLoop.Account.Segment1__c);
            }
            
            if(accRLoop.Account.Segment2__c != null && accRLoop.Contact.Segment2__c != null && accRLoop.Contact.Segment2__c.Contains(accRLoop.Account.Segment2__c)){
                con.Segment2__c =  accRLoop.Contact.Segment2__c.remove(accRLoop.Account.Segment2__c);
            }
            
            if(accRLoop.Account.Segment3__c != null && accRLoop.Contact.Segment3__c != null && accRLoop.Contact.Segment3__c.Contains(accRLoop.Account.Segment3__c)){
                con.Segment3__c =  accRLoop.Contact.Segment3__c.remove(accRLoop.Account.Segment3__c);
            }
            contactRemoveMap.put(con.Id, con);
        }
        
        for(AccountContactRelation accRLoop : [SELECT ID, ContactId, AccountId, Account.Segment1__c, Account.Segment2__c, Account.Segment3__c, Contact.Segment1__c, Contact.Segment2__c, Contact.Segment3__c FROM AccountContactRelation WHERE ContactId In:contactRemoveMap.Keyset() and Id not In :acccontOldMap.keySet()]){
            Contact con = new Contact();
            if(contactRemoveMap.ContainsKey(accRLoop.ContactId)){
                con = contactRemoveMap.get(accRLoop.ContactId);
            }
            if(accRLoop.Account.Segment1__c != null && con.Segment1__c != null && !con.Segment1__c.Contains(accRLoop.Account.Segment1__c)){
                List<String> segmentList = new List<String>();
                segmentList.add(con.Segment1__c);
                segmentList.add(accRLoop.Account.Segment1__c);
                String Str = String.join(segmentList,';').removeEnd(';'); 
                con.Segment1__c =  Str;
            }else if(accRLoop.Account.Segment1__c != null && con.Segment1__c == null){
                con.Segment1__c = accRLoop.Account.Segment1__c;
            }else{
                con.Segment1__c = con.Segment1__c;
            }
            
            if(accRLoop.Account.Segment2__c != null && con.Segment2__c != null && !con.Segment2__c.Contains(accRLoop.Account.Segment2__c)){
                List<String> segmentList = new List<String>();
                segmentList.add(con.Segment2__c);
                segmentList.add(accRLoop.Account.Segment2__c);
                String Str = String.join(segmentList,';').removeEnd(';'); 
                con.Segment2__c =  Str;
            }else if(accRLoop.Account.Segment2__c != null && con.Segment2__c == null){
                con.Segment2__c = accRLoop.Account.Segment2__c;
            }else{
                con.Segment2__c = con.Segment2__c;
            }
            
            if(accRLoop.Account.Segment3__c != null && con.Segment3__c != null && !con.Segment3__c.Contains(accRLoop.Account.Segment3__c)){
                List<String> segmentList = new List<String>();
                segmentList.add(con.Segment3__c);
                segmentList.add(accRLoop.Account.Segment3__c);
                String Str = String.join(segmentList,';').removeEnd(';'); 
                con.Segment3__c =  Str;
            }else if(accRLoop.Account.Segment3__c != null && con.Segment3__c == null){
                con.Segment3__c = accRLoop.Account.Segment3__c;
            }else{
                con.Segment3__c = con.Segment3__c;
            }
            contactUpdateMap.Put(con.Id, con);
        }
        if(!contactUpdateMap.isEmpty()){
            update contactUpdateMap.values();
        }
    }
    //7028 End
}