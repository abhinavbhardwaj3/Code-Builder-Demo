public without sharing class ScrumAIDevelopmentHandler {

    // Define keywords to identify if request is to provide deployment suggestions
    public static Set<String> developmentKeywords = new Set<String>{
            'deployment step',
            'deployment script',
            'sf command',
            'sfdx command',
            'git command',
            'yml script',
            'yml command',
            'yml step',
            'ci/cd command',
            'ci/cd step'
            };

    // Check if the user request contains Development creation keywords
    public static boolean isDevelopmentRecommendationRequest(String userRequest) {
        for (String keyword : developmentKeywords) {
            if (userRequest.toLowerCase().contains(keyword)) {
                return true;
            }
        }
        return false;
    }

    // Create prompt for story creation
    public static String createDevelopmentPrompt(String userRequest) {
        Scrum_AI_Prompt_Template__c promptTemplate = ScrumAIGenericHandler.getPromptTemplate('deployment');
        // Get story details specially story metadata type
        Map<String, String> storyProjectDetail = ScrumAIStoryTaskHandler.generateStoryDetail('Completed');
        if(storyProjectDetail.size() == 0){
            return null;
        }
        String storyDetails = storyProjectDetail.containsKey('storyDetails') ? storyProjectDetail.get('storyDetails') : 'Not Available';
        String sourceOrgUrl = storyProjectDetail.containsKey('sourceOrgUrl') ? storyProjectDetail.get('sourceOrgUrl') : 'Not Available';
        String targetOrgUrl = storyProjectDetail.containsKey('targetOrgUrl') ? storyProjectDetail.get('targetOrgUrl') : 'Not Available';
        String gitRepoUrl = storyProjectDetail.containsKey('gitRepoUrl') ? storyProjectDetail.get('gitRepoUrl') : 'Not Available';
        String userPrompt = promptTemplate.Role_User__c.replace('{storyDetails}', storyDetails).replace('{sourceOrgUrl}', sourceOrgUrl).replace('{targetOrgUrl}', targetOrgUrl).replace('{gitRepoUrl}', gitRepoUrl);
        return 'role: system,\n Content:' + promptTemplate.Role_System__c + '\n\n' +
            'role: assistant,\n Content:' + promptTemplate.Role_Assistant__c + '\n\n' +
            'role: user,\n Content:' + userPrompt;
    }

    public static String createDevelopmentStepsFromResponse(String AIResponse) {
        //system.debug(AIResponse);
        // Get Sprint Id
        ID sprintId = ScrumAISprintHandler.getActiveSprintId();
        //AIResponse = AIResponse.replace('[CODE]', '<pre><code>');
		//AIResponse = AIResponse.replace('[/CODE]', '</code></pre>');

        String Deployment_Script = ScrumAIGenericHandler.extractValue(AIResponse, 'Deployment Name');
        String GIT_Script = ScrumAIGenericHandler.extractValue(AIResponse, 'GIT Script');
        String SF_Script = ScrumAIGenericHandler.extractValue(AIResponse, 'SF Script');
        String SFDX_Script = ScrumAIGenericHandler.extractValue(AIResponse, 'SFDX Script');
        String YML_Script = ScrumAIGenericHandler.extractValue(AIResponse, 'YML Script');
        // get deploymnet Name : Deployment_Name__c
        // Upsert Development record
        system.debug('----sprintId----'+sprintId);
       // List<Scrum_AI_Deployment__c> deploymentList = [SELECT Id FROM Scrum_AI_Deployment__c WHERE Related_Sprint__c =:sprintId LIMIT 1];
        Scrum_AI_Deployment__c deployment =  new Scrum_AI_Deployment__c();
        /*
        if(deploymentList.isEmpty()){
        deployment = new Scrum_AI_Deployment__c();
        }else{
        deployment = deploymentList[0];
        }
        */
        deployment.Related_Sprint__c = sprintId;
        deployment.Deployment_Status__c = 'Ready';
        deployment.Deployment_Name__c = Deployment_Script.trim();
        deployment.GIT_Script__c = GIT_Script.trim();
        deployment.SF_Script__c = SF_Script.trim();
        deployment.SFDX_Script__c = SFDX_Script.trim();
        deployment.YML_Script__c  = YML_Script.trim();

         insert deployment;
       // upsert deployment;
        system.debug('Deployment with ID ****: ');
        system.debug(deployment.Id);
        // Call the asynchronous job (Queueable Job)
    	ScrumAIDevelopmentPDFHandler.generateDeploymentPDFsAsync(deployment.Id);
        // Create Story link as reponse
        return ScrumAIGenericHandler.generateLink(deployment.Id);
    }
}