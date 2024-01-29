/****************************************************************************
* Name: AccountTriggerHelper
* Author: Naina Butle
* Created Date: 07/12/2022
* Description: Helper class for Account Trigger
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
****************************************************************************/
public with sharing class AccountTriggerHelper {
    /****************************************************************************
* Author Name: Naina Butle
* Description: Customer master data can currently only be changed in SAP, with the exception of the customer-specific margin and visit recommendation.
* Created Date: 07/12/2022
* Last Modified Date: 
****************************************************************************/
    public static void preventUpdatingAccount(List<Account> accountList, Map<Id, Account> accountOldmap){
        User user = [SELECT ID, Profile.Name From User WHERE ID = :UserInfo.getUserId() LIMIT 1];
        Map<String,Schema.SObjectField> fieldAccountMap = Account.SobjectType.getDescribe().fields.getMap();
        if(user.Profile.Name != ConstantClass.INTERGRATION_PROFILE && user.Profile.Name != ConstantClass.SYSTEMADMIN_PROFILE && user.Profile.Name != ConstantClass.SYSTEMADMIN_PROFILEGERMAN)  
        {
            Set<String> fieldsetSet = new Set<String>();
            for(Schema.FieldSetMember fieldSetMemberObj : SObjectType.Account.FieldSets.AccountFieldSet.getFields())
            {
                fieldsetSet.add(fieldSetMemberObj.getFieldPath());
            }           
            for(Account newAccountLoop : accountList){
                if(newAccountLoop.SAPAccountNumber__c != null){
                    Account oldAccount = accountOldmap.get(newAccountLoop.Id);
                    for(Schema.SObjectField fmMap : fieldAccountMap.values()){
                        if(oldAccount.get(String.valueOf(fmMap)) != newAccountLoop.get(String.valueOf(fmMap)) && !fieldsetSet.contains(String.valueOf(fmMap))){
                            newAccountLoop.addError(System.Label.AccounReadOnlyErrorMsg);
                            break;
                        }
                    }
                }
            }
        }
        if(user.Profile.Name == ConstantClass.DH_MARKETING_PROFILE || user.Profile.Name == ConstantClass.DH_SALES_PROFILE)
        {
            for(Account newAccountLoop : accountList){
                if(newAccountLoop.Type == 'Customer'){
                    Account oldAccount = accountOldmap.get(newAccountLoop.Id);
                    for(Schema.SObjectField fmMap : fieldAccountMap.values()){
                        if(oldAccount.get(String.valueOf(fmMap)) != newAccountLoop.get(String.valueOf(fmMap)) && (String.valueOf(fmMap) != 'Email__c') && (String.valueOf(fmMap) != 'Phone') && (String.valueOf(fmMap) != 'Website') && (String.valueOf(fmMap) != 'Type')){
                            newAccountLoop.addError(System.Label.AccountTypeError);
                            break;
                        }
                    }
                }
            }
        }
    } 
    public static void updateLastUpdatedCommentsFields(List<Account> accountList, Map<Id, Account> accountOldmap){
        if(accountOldmap==null || accountOldmap.isEmpty()){
            for(Account newAccount : accountList){
                if(newAccount.CommentOverdraft__c != null){
                    newAccount.LastUpdatedCommentOverdraft__c=system.now();
                }
                if(newAccount.CommentOverdueInvoice__c !=null){
                    newAccount.LastUpdatedCommentOverdueInvoice__c=system.now();
                }
            }
        }
        else{
            for(Account newAccount : accountList){
                if(newAccount.CommentOverdraft__c != accountOldmap.get(newAccount.Id).CommentOverdraft__c){
                    newAccount.LastUpdatedCommentOverdraft__c=system.now();
                }
                if(newAccount.CommentOverdueInvoice__c != accountOldmap.get(newAccount.Id).CommentOverdueInvoice__c){
                    newAccount.LastUpdatedCommentOverdueInvoice__c=system.now();
                }
            }
        }
    }
    
    //7028 Start
    public static void updateSegmentFieldonContact(Map<Id, Account> accountNewmap, Map<Id, Account> accountOldmap){
        Map<Id, Contact> contactAccountMap = new Map<Id, Contact>();
        Map<Id, Contact> contactUpdateMap = new Map<Id, Contact>();
        Map<Id, List<AccountContactRelation>> accoudIdVsAccConRel = new Map<Id, List<AccountContactRelation>>();
        for(AccountContactRelation accRLoop : [SELECT ID, ContactId, IsDirect, AccountId, Account.Segment1__c, Account.Segment2__c, Account.Segment3__c, Contact.Segment1__c, Contact.Segment2__c, Contact.Segment3__c FROM AccountContactRelation WHERE AccountId In:accountNewmap.Keyset()]){
            
            if(!accoudIdVsAccConRel.ContainsKey(accRLoop.AccountId)){
                accoudIdVsAccConRel.put(accRLoop.AccountId, new List<AccountContactRelation>());
            }
            accoudIdVsAccConRel.get(accRLoop.AccountId).add(accRLoop);
        }
        
        for(Account acc : accountNewmap.values()){
            List<AccountContactRelation> accContList = accoudIdVsAccConRel.ContainsKey(acc.Id) ? accoudIdVsAccConRel.get(acc.Id) : null;
            if(accContList != null){
                Account accOld = accountOldmap.ContainsKey(acc.Id) ? accountOldmap.get(acc.Id) : null;
                for(AccountContactRelation accCon : accContList){
                    Contact con = new Contact();
                    con.Id = accCon.ContactId;
                    if(acc.Segment1__c != null && accCon.Contact.Segment1__c != null && !accCon.Contact.Segment1__c.Contains(acc.Segment1__c)){
                        List<String> segmentList = new List<String>();
                        if(accOld != null && accOld.Segment1__c != null && acc.Segment1__c != null && accOld.Segment1__c != acc.Segment1__c){
                            if(accCon.Contact.Segment1__c != null){
                                string conOldvalue = accCon.Contact.Segment1__c.remove(accOld.Segment1__c);
                                segmentList.add(conOldvalue);   
                            }
                        }
                        segmentList.add(acc.Segment1__c);
                        String Str = String.join(segmentList,';').removeEnd(';'); 
                        con.Segment1__c =  Str;
                    }else if(acc.Segment1__c != null && accCon.Contact.Segment1__c == null){
                        con.Segment1__c = acc.Segment1__c;
                    }else{
                        List<String> segmentList = new List<String>();
                        if(accOld != null && accOld.Segment1__c != null && accCon.Contact.Segment1__c != null && acc.Segment1__c != null && accOld.Segment1__c != acc.Segment1__c){
                            string conOldvalue = accCon.Contact.Segment1__c.remove(accOld.Segment1__c);
                            segmentList.add(conOldvalue);
                            if(!conOldvalue.Contains(acc.Segment1__c)){
                                segmentList.add(acc.Segment1__c); 
                            }
                        }else if(acc.Segment1__c != null){
                            segmentList.add(accCon.Contact.Segment1__c);
                            if(!accCon.Contact.Segment1__c.Contains(acc.Segment1__c)){
                                segmentList.add(acc.Segment1__c);  
                            }
                        }
                        String Str = String.join(segmentList,';').removeEnd(';'); 
                        con.Segment1__c =  Str;
                    }
                    if(acc.Segment2__c != null && accCon.Contact.Segment2__c != null && !accCon.Contact.Segment2__c.Contains(acc.Segment2__c)){
                        List<String> segmentList = new List<String>();
                        if(accOld != null && accOld.Segment2__c != null && accOld.Segment2__c != acc.Segment2__c){
                            string conOldvalue = accCon.Contact.Segment2__c.remove(accOld.Segment2__c);
                            segmentList.add(conOldvalue);
                        }
                        segmentList.add(acc.Segment2__c);
                        String Str = String.join(segmentList,';').removeEnd(';'); 
                        con.Segment2__c =  Str;
                    }else if(acc.Segment2__c != null && accCon.Contact.Segment2__c == null){
                        con.Segment2__c = acc.Segment2__c;
                    }else{
                        List<String> segmentList = new List<String>();
                        if(accOld != null && accOld.Segment2__c != null && acc.Segment2__c!= null && accCon.Contact.Segment2__c != null && accOld.Segment2__c != acc.Segment2__c){
                            string conOldvalue = accCon.Contact.Segment2__c.remove(accOld.Segment2__c);
                            segmentList.add(conOldvalue);
                            if(!conOldvalue.Contains(acc.Segment2__c)){
                                segmentList.add(acc.Segment2__c); 
                            }
                        }else if(acc.Segment2__c != null){
                            segmentList.add(accCon.Contact.Segment2__c);
                            if(!accCon.Contact.Segment2__c.Contains(acc.Segment2__c)){
                                segmentList.add(acc.Segment2__c);  
                            }
                        }
                        String Str = String.join(segmentList,';').removeEnd(';'); 
                        con.Segment2__c =  Str;
                    } 
                    if(acc.Segment3__c != null && accCon.Contact.Segment3__c != null && !accCon.Contact.Segment3__c.Contains(acc.Segment3__c)){
                        List<String> segmentList = new List<String>();
                        if(accOld != null && accOld.Segment3__c != null && accOld.Segment3__c != acc.Segment3__c){
                            string conOldvalue = accCon.Contact.Segment3__c.remove(accOld.Segment3__c);
                            segmentList.add(conOldvalue);
                        }
                        segmentList.add(acc.Segment3__c);
                        String Str = String.join(segmentList,';').removeEnd(';'); 
                        con.Segment3__c =  Str;
                    }else if(acc.Segment3__c != null && accCon.Contact.Segment3__c == null){
                        con.Segment3__c = acc.Segment3__c;
                    }else{
                        List<String> segmentList = new List<String>();
                        if(accOld != null && accOld.Segment3__c != null && acc.Segment3__c != null && accCon.Contact.Segment3__c != null && accOld.Segment3__c != acc.Segment3__c){
                            string conOldvalue = accCon.Contact.Segment3__c.remove(accOld.Segment3__c);
                            segmentList.add(conOldvalue);
                            if(!conOldvalue.Contains(acc.Segment3__c)){
                                segmentList.add(acc.Segment3__c); 
                            }
                        }else if(acc.Segment3__c != null){
                            segmentList.add(accCon.Contact.Segment3__c);
                            if(!accCon.Contact.Segment3__c.Contains(acc.Segment3__c)){
                                segmentList.add(acc.Segment3__c);  
                            }
                        }
                        String Str = String.join(segmentList,';').removeEnd(';'); 
                        con.Segment3__c =  Str;
                    } 
                    contactAccountMap.put(con.Id, con);
                }
            }
        }
        for(AccountContactRelation accRLoop : [SELECT ID, ContactId, AccountId, Account.Segment1__c, Account.Segment2__c, Account.Segment3__c, Contact.Segment1__c, Contact.Segment2__c, Contact.Segment3__c FROM AccountContactRelation WHERE ContactId In:contactAccountMap.Keyset()]){
            Contact con = new Contact();
            if(contactAccountMap.ContainsKey(accRLoop.ContactId)){
                con = contactAccountMap.get(accRLoop.ContactId);
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
            update contactUpdateMap.Values();
        }
    }

    public static void removeSegmentFieldonContact(Map<Id, Account> accountOldmap){
        Map<Id, Contact> contactRemoveMap = new Map<Id, Contact>();
        Map<Id, Contact> contactUpdateMap = new Map<Id, Contact>();

        for(AccountContactRelation accRLoop : [SELECT ID, ContactId, AccountId, Account.Segment1__c, Account.Segment2__c, Account.Segment3__c, Contact.Segment1__c, Contact.Segment2__c, Contact.Segment3__c FROM AccountContactRelation WHERE AccountId In : accountOldmap.Keyset()]){
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
        
        for(AccountContactRelation accRLoop : [SELECT ID, ContactId, AccountId, Account.Segment1__c, Account.Segment2__c, Account.Segment3__c, Contact.Segment1__c, Contact.Segment2__c, Contact.Segment3__c FROM AccountContactRelation WHERE ContactId In:contactRemoveMap.Keyset() and AccountId not In :accountOldmap.keySet()]){
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
}