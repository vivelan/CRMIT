trigger QuoteTrigger on Quote (before Insert,before Update, after Update) {
    String objectName = 'Quote';
        QuoteTriggerHandler quoteTriggerHandler = new QuoteTriggerHandler();
        quoteTriggerHandler.run(objectName);
}