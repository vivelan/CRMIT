trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert,after update) {
    
    String objectName = 'ContentDocumentLink';
    ContentDocumentLinkTriggerHandler cdTriggerHandler = new ContentDocumentLinkTriggerHandler();
    cdTriggerHandler.run(objectName);
}