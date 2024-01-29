/**
 * @description       : Added with sharing to existing QuoteTriggerHandler class
 * @author            : Ashutosh Rao 
 * @group             : 
 * @last modified on  : 12-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class QuoteTriggerHandler extends TriggerHandler{
  
   public override void beforeUpdate() {
        if(!((Map<Id, Quote>) trigger.newMap).isEmpty()){
            QuoteTriggerHelper.updateQuoteOfferedDate((Map<Id, Quote>)trigger.oldMap,(Map<Id, Quote>) trigger.newMap);
        }
    }
   	public override void beforeInsert() {
        /* if(!((list<Quote>) trigger.new).isEmpty()){
            QuoteTriggerHelper.checkMandatoryFieldsOnCreation((list<Quote>) trigger.new,(Map<Id,Quote>)trigger.oldMap,(Map<Id,Quote>)trigger.NewMap);
        }*/
    }
    
}