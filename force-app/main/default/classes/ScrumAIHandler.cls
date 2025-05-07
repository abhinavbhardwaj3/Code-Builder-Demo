public without sharing class ScrumAIHandler {
    @AuraEnabled
    public static String handleUserRequest(String input) {
        // Deserialize input
        List<ChatMessage> messages = (List<ChatMessage>) JSON.deserialize(input, List<ChatMessage>.class);
        //Check the request type from user input string
        String responseText = processUserRequest(messages);
        return responseText;
    }

    // Get request Type from user String
    private static String processUserRequest(List<ChatMessage> messages){
        String Env = 'prod'; //prod // dev
        string responseText;
        String aiResponse;
        String userMessage;
        String prompt;
        String requestType = 'Generic';
        for (ChatMessage msg : messages) {
            userMessage = msg.message;
            if (msg.role == 'user') {
                if(ScrumAIStoryTaskHandler.isStoryCreateRequest(userMessage)){
                    requestType = 'Create Story';
                    // Check if it is a story creation request
                    prompt = ScrumAIStoryTaskHandler.createStoryTaskPrompt(userMessage);

                    aiResponse = getAIResponse(requestType, userMessage, prompt, Env);

                    responseText = 'A story has been created for you. \n\n Please take a look at the URL below and update the story and task as needed.\n\n';
                    // Format and create story from AI response
                    responseText += 'Story URL: ';
                    responseText += ScrumAIStoryTaskHandler.createTaskStoryFromResponse(aiResponse);
                    responseText += '\n\n';

                }
                else if(ScrumAIDevelopmentHandler.isDevelopmentRecommendationRequest(userMessage)){
                    // Create Deployment steps start
                    requestType = 'Create Deployment Steps';
                    // Check if it is a Create Deployment Steps request
                    prompt = ScrumAIDevelopmentHandler.createDevelopmentPrompt(userMessage);
                    if(String.isBlank(prompt)){
                        responseText = 'I can\'t find any completed story for which I can create Deployment steps.Could you please review your sprint/stories?';
                    }else{

                        aiResponse = getAIResponse(requestType, userMessage, prompt, Env);

                        //system.debug(aiResponse);
                        responseText = 'A Deployment record has been created for you. \n Please check the URL below and make changes to the scripts as per your needs.\n';
                        responseText += 'Also ,created  PDFs and attached them to the associated sprint .Please check that out.\n\n';
                        // Format and create story from AI response
                        responseText += 'Deployment Record URL: ';
                        responseText += ScrumAIDevelopmentHandler.createDevelopmentStepsFromResponse(aiResponse);
                        responseText += '\n\n';
                    }

                }
                else if(ScrumAIGeneralQueryHandler.isStoryStatusRequest(userMessage)){
                    requestType = 'Story Status';
                    responseText = ScrumAIGeneralQueryHandler.getCompletedStories();
                }
                else if(ScrumAIGeneralQueryHandler.isProjectStatusRequest(userMessage)){
                    requestType = 'Project Status';
                    responseText = ScrumAIGeneralQueryHandler.getProjectOverview();
                }
                else{
                    // For other Generic request
                    prompt = ScrumAIGenericHandler.createPrompt(userMessage);
                    aiResponse = getAIResponse(requestType, userMessage, prompt, Env);
                    responseText = aiResponse;
                }
            }
        }
        return responseText;
    }

    // Save user and AI Conversation for debug purpose
    private static void saveAIConversation(String conversationType, String message, String prompt, String aiResponse){
        Scrum_AI_Conversation__c AIConversation = new Scrum_AI_Conversation__c();
        AIConversation.Conversation_type__c = conversationType;
        AIConversation.User_Request__c = message;
        AIConversation.Generated_Prompt__c  = prompt;
        AIConversation.AI_Response__c  = aiResponse;
        insert AIConversation;
    }

    private static String getAIResponse(String requestType, String userMessage, String prompt, String Env) {
        String aiResponse;
        if(Env == 'prod'){
            // Call AI model with the generated prompt
            aiResponse = callAIModel(prompt);
            // Save This response to Scrum AI Conversation
            saveAIConversation(requestType, userMessage, prompt, aiResponse);
            if(aiResponse=='No response'){
                // ***** This is a temp response if we don't get response from AI
                aiResponse = ScrumAITempResponse.getTempResponse(requestType);
            }
        }
        else{
            // ***** This is a temporary code
            aiResponse = ScrumAITempResponse.getTempResponse(requestType);
        }
        return aiResponse;
    }

    // Calls AI model with the generated prompt
    private static String callAIModel(String prompt) {
        aiplatform.ModelsAPI modelsAPI = new aiplatform.ModelsAPI();
        aiplatform.ModelsAPI.createChatGenerations_Request request = new aiplatform.ModelsAPI.createChatGenerations_Request();
        aiplatform.ModelsAPI_ChatGenerationsRequest body = new aiplatform.ModelsAPI_ChatGenerationsRequest();

        // Set model and message
        request.modelName = 'sfdc_ai__DefaultOpenAIGPT4';
        aiplatform.ModelsAPI_ChatMessageRequest messageRequest = new aiplatform.ModelsAPI_ChatMessageRequest();
        messageRequest.content = prompt;
        messageRequest.role = 'user';

        body.messages = new List<aiplatform.ModelsAPI_ChatMessageRequest>{ messageRequest };
            request.body = body;
        try {
            // Call API and get response
            aiplatform.ModelsAPI.createChatGenerations_Response apiResponse = modelsAPI.createChatGenerations(request);
            if (apiResponse?.Code200?.generationDetails?.generations != null && !apiResponse.Code200.generationDetails.generations.isEmpty()) {
                return apiResponse.Code200.generationDetails.generations[0].content;
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        return 'No response';
    }

    public static List<Scrum_AI_Story__c> getStoriesByStatus(String status) {
        return [SELECT Story_Name__c, Story_Status__c, Sprint__r.Sprint_Name__c FROM Scrum_AI_Story__c WHERE Story_Status__c = :status];
    }
}