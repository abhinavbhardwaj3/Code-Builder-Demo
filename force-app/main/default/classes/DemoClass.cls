public with sharing class DemoClass {
   /**
     * Retrieves a list of Opportunity from the database
     */
    @AuraEnabled
    public static List<Opportunity> demoOpps() {
        List<Opportunity> demoOpp = [SELECT Id, Name  FROM Opportunity];
        return demoOpp;
    }
}