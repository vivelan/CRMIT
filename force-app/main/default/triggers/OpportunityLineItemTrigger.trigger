trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert, before update, before insert) {

    String objectName = 'OpportunityLineItem';
    OpportunityLineItemTriggerHandler oliTriggerHandler = new OpportunityLineItemTriggerHandler();
    oliTriggerHandler.run(objectName);
}
