public without sharing class ScrumAIResourceHandler {
    public static List<Scrum_AI_Resource__c> getAvailableResources() {
        // Query to fetch resources that are available
        return [SELECT Id, Name, Role__c, Skills__c, Available__c  FROM Scrum_AI_Resource__c WHERE Available__c = 'Available'];
        //string allstring = string.join(resourceList,',');
        //system.debug(allstring);
    }

    // Generate a formatted list of available resources
    public static String generateResourceList() {
        List<Scrum_AI_Resource__c> resources = getAvailableResources();
        String resourceList = '';
        for (Scrum_AI_Resource__c resource : resources) {
            resourceList += 'Resource Detail: ResourceId: ' + resource.Id + ', Role: ' + resource.Role__c + ', Skills: ' + resource.Skills__c + ', \r\n';
        }
        return resourceList.substring(0, resourceList.length() - 4); // Remove last comma
    }
}