trigger PrakulaTrigger on Praekula__c (before insert, before update, after insert, after update) {
    String prakula = 'Prakula';
    PrakulaTriggerHandler prakulaTriggerHandler = new PrakulaTriggerHandler();
    prakulaTriggerHandler.run(prakula);

}