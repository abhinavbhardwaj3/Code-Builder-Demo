public without sharing class ScrumAISprintHandler {
    public static List<Scrum_AI_Sprint__c> getActiveSprint() {
        // Query to fetch Sprint that is active
        return [SELECT id, Sprint_Start_Date__c, Sprint_End_Date__c  from Scrum_AI_Sprint__c where Sprint_Status__c ='In Progress' LIMIT 1];
    }

    public static ID getActiveSprintId() {
        // Query to fetch Sprint that is active
        return [SELECT id from Scrum_AI_Sprint__c where Sprint_Status__c ='In Progress' LIMIT 1].id;
    }

    // Generate a formatted list of active Sprint
    public static String generateActiveSprintList() {
        List<Scrum_AI_Sprint__c> sprints = getActiveSprint();
        String sprintList = '';
        for (Scrum_AI_Sprint__c sprint : sprints) {
            sprintList += 'Sprint Detail: SprintId: ' + sprint.Id + ',Start Date: ' + sprint.Sprint_Start_Date__c + ', End Date: ' + sprint.Sprint_End_Date__c + ', \r\n';
        }
        return sprintList.substring(0, sprintList.length() - 4); // Remove last comma
    }
}