public without sharing class ScrumAIGenericHandler {
    // Create prompt for Generic work
    public static String createPrompt(String userRequest) {
        Scrum_AI_Prompt_Template__c promptTemplate = getPromptTemplate('generic');
        String userPrompt = promptTemplate.Role_User__c.replace('{userRequest}', userRequest);
        return 'role: system,\n Content:' + promptTemplate.Role_System__c + '\n\n' +
            'role: assistant,\n Content:' + promptTemplate.Role_Assistant__c + '\n\n' +
            'role: user,\n Content:' + userPrompt;
    }

    // Fetch the prompt template from the database
    public static Scrum_AI_Prompt_Template__c getPromptTemplate(String promptType) {
        return [SELECT Role_User__c, Role_System__c, Role_Assistant__c FROM Scrum_AI_Prompt_Template__c WHERE Prompt_Type__c = :promptType LIMIT 1];
    }

    public static String generateLink(Id recordId) {
        // Get the base URL of the Salesforce org
        String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();

        // Generate the record detail page URL
        String storyUrl = baseUrl + '/' + recordId;
        // Return the URL as the response
        return storyUrl;
    }

    // Helper method to extract values from AI response using the consistent delimiter '*-*'
    public static String extractValue(String response, String fieldName) {
        String startDelimiter = '*-*' + fieldName + '*-*:'; // Start delimiter
        String endDelimiter = '- *-*'; // End delimiter to match the pattern used in the string

        Integer startIndex = response.indexOf(startDelimiter);
        if (startIndex == -1) return null;

        Integer endIndex = response.indexOf(endDelimiter, startIndex + startDelimiter.length());
        if (endIndex == -1) {
            // For the last field without a trailing end delimiter
            return response.substring(startIndex + startDelimiter.length()).trim();
        }

        return response.substring(startIndex + startDelimiter.length(), endIndex).trim();
    }
}