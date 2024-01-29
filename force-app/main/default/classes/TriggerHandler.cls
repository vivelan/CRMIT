/****************************************************************************
* Name: TriggerHandler
* Author: Priyanka Kumari
* Test Class: TriggerHandlerTest
* Created Date: 16/08/2022
* Description: Trigger Framework class which will be used by all the trigger for the implementation
*****************************************************************************
* Modification log
* Name		Date	           		Description
*  
****************************************************************************/

public virtual without sharing class TriggerHandler {
    
    private static Map<String, LoopCount> loopCountMap;
    private static List<TriggerConfiguration__mdt> triggerConfigurationList;
    
    @TestVisible
    private TriggerContext context;
    
    @TestVisible
    private Boolean isTriggerExecuting;
    
    static {
        loopCountMap = new Map<String, LoopCount>();
    }
    
    public TriggerHandler() {
        this.setTriggerContext();
    }
    
    /****************************************************************************
    * Author Name: Priyanka Kumari
    * Description: Main method that will be called during execution from the trigger
    * Created Date: 16/08/2022
    * Last Modified Date: 19/08/2022
    ****************************************************************************/
    
    public void run(String objName) {
        if(!validateRun()) {
            return;
        }
        addToLoopCount(objName);         
        
        TriggerConfiguration__mdt triggerConfiguration;
        if(triggerConfigurationList == null){            
        	triggerConfigurationList  = [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, AfterDelete__c, AfterInsert__c, 
                                         AfterUndelete__c, AfterUpdate__c, BeforeDelete__c, BeforeUpdate__c, ByPassedProfiles__c, 
                                         BeforeInsert__c, ObjectApiName__c, ByPassedUsers__c, MaxCount__c
                                         FROM TriggerConfiguration__mdt
                                         WHERE DeveloperName =: objName];
        }
        
        if(!triggerConfigurationList.isEmpty()){
            triggerConfiguration = triggerConfigurationList[0];
            String byPassedUserIds = triggerConfiguration.ByPassedUsers__c != null ? triggerConfiguration.ByPassedUsers__c : '';
            String byPassedProfileIds = triggerConfiguration.ByPassedProfiles__c != null ? triggerConfiguration.ByPassedProfiles__c : '';            
           
            if(byPassedUserIds.contains(UserInfo.getUserId()) || byPassedProfileIds.contains(UserInfo.getProfileId()))
                return;
            
            if(triggerConfiguration.MaxCount__c > 0)
            	this.setMaxLoopCount(Integer.valueOf(triggerConfiguration.MaxCount__c), objName);
        }
        else
        {
            throw new TriggerHandlerException('Trigger Custom Metadata Configuration missing for ' + objName);
        }        
        
        switch on this.context {
            when BEFORE_INSERT {
                if(triggerConfiguration.BeforeInsert__c)
                    this.beforeInsert();
            }
            when BEFORE_UPDATE {
                if(triggerConfiguration.BeforeUpdate__c)
                    this.beforeUpdate();
            }
            when BEFORE_DELETE {
                if(triggerConfiguration.BeforeDelete__c)
                    this.beforeDelete();
            }
            when AFTER_INSERT {
                if(triggerConfiguration.AfterInsert__c)
                    this.afterInsert();
            }
            when AFTER_UPDATE {
                if(triggerConfiguration.AfterUpdate__c)
                    this.afterUpdate();
            }
            when AFTER_DELETE {
                if(triggerConfiguration.AfterDelete__c)
                    this.afterDelete();
            }
            when AFTER_UNDELETE {
                if(triggerConfiguration.AfterUndelete__c)
                    this.afterUndelete();
            }
        }            
    }
    
    /****************************************************************************
    * Author Name: Priyanka Kumari
    * Description: Setting the value of maximum number of loop count for a particular trigger object
    * Created Date: 16/08/2022
    * Last Modified Date: 19/08/2022
    *****************************************************************************/
    
    public void setMaxLoopCount(Integer max, String objectName){
        if(!TriggerHandler.loopCountMap.containsKey(objectName)){ 
            TriggerHandler.loopCountMap.put(objectName, new LoopCount());
        }
        TriggerHandler.loopCountMap.get(objectName).setMax(max);        
    }
    
    /****************************************************************************
    * Author Name: Priyanka Kumari
    * Description: Setting context in which trigger will run
    * Created Date: 16/08/2022
    * Last Modified Date: 19/08/2022
    ****************************************************************************/
    
    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }
    
    @TestVisible
    private void setTriggerContext(String ctx,Boolean testMode) {
        if(!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } 
        else {
            this.isTriggerExecuting = true;
        }
        
        if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert)|| (ctx != null && ctx == 'before insert')) {
            this.context = TriggerContext.BEFORE_INSERT;
        }
        else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate)|| (ctx != null && ctx == 'before update')){
            this.context = TriggerContext.BEFORE_UPDATE;
        }
        else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete)|| (ctx != null && ctx == 'before delete')) {
            this.context = TriggerContext.BEFORE_DELETE;
        }
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert)|| (ctx != null && ctx == 'after insert')) {
            this.context = TriggerContext.AFTER_INSERT;
        }
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate)|| (ctx != null && ctx == 'after update')) {
            this.context = TriggerContext.AFTER_UPDATE;
        }
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete)|| (ctx != null && ctx == 'after delete')) {
            this.context = TriggerContext.AFTER_DELETE;
        }
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete)|| (ctx != null && ctx == 'after undelete')) {
            this.context = TriggerContext.AFTER_UNDELETE;
        }
    }
    
    
    /****************************************************************************
    * Author Name: Priyanka Kumari
    * Description: Checking if the value of max loop count has exceeded or not
    * Created Date: 16/08/2022
    * Last Modified Date: 19/08/2022
    ****************************************************************************/
    
    @TestVisible
    private void addToLoopCount(String objectName) {
        if(TriggerHandler.loopCountMap.containsKey(objectName)) {
            Boolean exceeded = TriggerHandler.loopCountMap.get(objectName).increment();
            if(exceeded) {
                Integer max = TriggerHandler.loopCountMap.get(objectName).max;
                throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + objectName);
            }
        }
    }
    
    /****************************************************************************
    * Author Name: Priyanka Kumari
    * Description: Validating if the trigger is in executing mode
    * Created Date: 16/08/2022
    * Last Modified Date: 19/08/2022
    ****************************************************************************/
    
   @TestVisible
    private Boolean validateRun() {
       if(!this.isTriggerExecuting || this.context == null) {
            throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
        }        
        ByPassLogic__c byPassSettingForUserId = ByPassLogic__c.getInstance(UserInfo.getUserId());        
        ByPassLogic__c byPassSettingForUserProfile = ByPassLogic__c.getInstance(UserInfo.getProfileId());
        return !(byPassSettingForUserId.ByPassTrigger__c || byPassSettingForUserProfile.ByPassTrigger__c); 
        
    }
    
    
    /***************************************
    * context methods
    ***************************************/
    
    @TestVisible
    protected virtual void beforeInsert(){}
    @TestVisible
    protected virtual void beforeUpdate(){}
    @TestVisible
    protected virtual void beforeDelete(){}
    @TestVisible
    protected virtual void afterInsert(){}
    @TestVisible
    protected virtual void afterUpdate(){}
    @TestVisible
    protected virtual void afterDelete(){}
    @TestVisible
    protected virtual void afterUndelete(){}
    
    
    @TestVisible
    private class LoopCount {
        private Integer max;
        private Integer count;
        
        public LoopCount() {
            this.max = 5;
            this.count = 0;
        }
        
        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }
        
        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }
        
        public Boolean exceeded() {
            return this.max >= 0 && this.count > this.max;
        }
        
        public Integer getMax() {
            return this.max;
        }
        
        public Integer getCount() {
            return this.count;
        }
        
        public void setMax(Integer max) {
            this.max = max;
        }
    }
    
    @TestVisible
    private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
            AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
            AFTER_UNDELETE
            }
    
    public class TriggerHandlerException extends Exception {}
    
}