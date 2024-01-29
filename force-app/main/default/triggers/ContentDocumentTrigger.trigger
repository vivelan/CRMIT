trigger ContentDocumentTrigger on ContentDocument (after update, before delete) {
	
    String objectName = 'ContentDocument';
    ContentDocumentTriggerHandler cdTriggerHandler = new ContentDocumentTriggerHandler();
    cdTriggerHandler.run(objectName);
}