trigger TechnicalRequirementTrigger on TechnicalRequirement__c (before insert, before update,after update) {

    String objectName = 'TechnicalRequirement';
    TechnicalRequirementTriggerHandler trTriggerHandler = new TechnicalRequirementTriggerHandler();
    trTriggerHandler.run(objectName);
}
