/****************************************************************************
* Name: RepeatingSchedulerDHUserUpdate
* Author: Naina B
* Created Date: 22/12/2023
* Description: The automation needs to be a scheduled class (in every 5 minutes) and collects such portal users from SF, where the username mismatches.
               If the update results in a User record to be updated to a User name already existing, create then a case:
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
****************************************************************************/
public with sharing class RepeatingSchedulerDHUserUpdate {
    
    public void updateUserName()
    {
        List<User> allUsers = new List<User>();
        List<String> userIds = new List<String>();
        Map<String, User> usersToBeUpdated = new  Map<String, User>();
        List<String> existingUserName = new List<String>();
        Map<String, List<User>> newUserNameMap = new Map<String, List<User>>();
        List<Case> caseToBeUpdated = new List<Case>();
        
        String queueId = [Select Id , Name, Type  FROM Group  Where Name =:ConstantClass.SYSTEMADMINS_QUEUE AND Type =: ConstantClass.QUEUE LIMIT 1].Id;
        String recordTypeId = [select id, Name, DeveloperName from RecordType Where DeveloperName =:ConstantClass.USER_REG_RECORDTYPE].Id;
        
        
        List<PermissionSetAssignment> permissionSet = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name, Assignee.Profile.Name FROM PermissionSetAssignment WHERE PermissionSet.Name =: ConstantClass.DH_CUSTOMER_PORTALACCESS_PERMISSION];
        for(PermissionSetAssignment per : permissionSet){ 
            userIds.add(per.AssigneeId);
        }
        
        for(User us : [SELECT Id, Name, Email, Username, IsPortalEnabled, ContactId, Contact.AccountId, Profile.Name from User WHERE ContactId != Null AND Contact.AccountId != null]){
            
            if( (!userIds.isEmpty() && userIds.contains(us.Id)) || us.Profile.Name == ConstantClass.DH_CUSTOMER_COMMUNITY_USER || us.Profile.Name == ConstantClass.DH_CUSTOMER_RESTRICTED_USER){
                allUsers.add(us);
            }
            existingUserName.add(us.Username);
        }
       
        for(User u: allUsers){
            String withoutAdditional = u.username.replaceAll('\\d*(?=\\.dillinger)', '');
            String expectedUsername =  withoutAdditional.split('.dillinger')[0];
            boolean checkUsername =  u.username.contains(u.email);
            
            if( (expectedUsername != u.email && !checkUsername) || (checkUsername && !withoutAdditional.contains('.dillinger')) ){
                string newUserName = u.email+'.dillinger';
                if(!existingUserName.isEmpty() && !existingUserName.Contains(newUserName)){
                    if(!usersToBeUpdated.ContainsKey(newUserName)){
                        u.username = newUserName;
                        usersToBeUpdated.put(newUserName, u); 
                    }else{
                        if(!newUserNameMap.ContainsKey(newUserName)){
                            newUserNameMap.put(newUserName, new List<User>());
                        }
                        newUserNameMap.get(newUserName).add(u); 
                    }
                }else{
                    Case caseNew = new Case();
                    caseNew.Status = 'User Creation';
                    caseNew.OwnerId = queueId;
                    caseNew.ContactId = u.ContactId; 
                    caseNew.AccountId = u.Contact.AccountId; 
                    caseNew.RecordTypeId = recordTypeId;
                    caseNew.Comments = 'The email address of this contact / related portal user got updated. This resulted in an update of the portal user name as well. However, this user name already exists in this org, or a different org. Please update the user name to an accepted, unique format. Inform the customer of the new user name.';
                    caseToBeUpdated.add(caseNew);
                }
            }
        }
        for(String uName : newUserNameMap.keySet()){
            List<User> userList = newUserNameMap.containsKey(uName) ? newUserNameMap.get(uName) : null;
            if(userList != null)
                for(User userLoop: userList){
                    Case caseNew = new Case();
                    caseNew.OwnerId = queueId;
                    caseNew.ContactId = userLoop.ContactId; 
                    caseNew.AccountId = userLoop.Contact.AccountId; 
                    caseNew.RecordTypeId = recordTypeId;
                    caseNew.Status = 'User Creation';
                    caseNew.Comments = 'The email address of this contact / related portal user got updated. This resulted in an update of the portal user name as well. However, this user name already exists in this org, or a different org. Please update the user name to an accepted, unique format. Inform the customer of the new user name.';
                    caseToBeUpdated.add(caseNew);
                }
        }
        
        if(!usersToBeUpdated.isEmpty()){
            update usersToBeUpdated.values();
        }
        if(!caseToBeUpdated.isEmpty()){
            String jsonString = json.serialize(caseToBeUpdated);
            insertCase(jsonString);
        }
    }
    
    @future
    public static void insertCase(String jsonString) {
        List<Case> caseToBeUpdated = (List<Case>)Json.deserialize(jsonString, List<Case>.class);
        insert caseToBeUpdated;
    }
}