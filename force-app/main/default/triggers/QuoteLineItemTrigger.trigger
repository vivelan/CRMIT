trigger QuoteLineItemTrigger on QuoteLineItem (after insert) {
    String objectName = 'QuoteLineItem';
    QuoteLineItemTriggerHandler qliTriggerHandler = new QuoteLineItemTriggerHandler();
    qliTriggerHandler.run(objectName);
}