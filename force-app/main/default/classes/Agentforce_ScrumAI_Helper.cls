public without sharing class Agentforce_ScrumAI_Helper {
  public static void saveAIConversation(String conversationType, String message, String prompt, String aiResponse) {
      Scrum_AI_Conversation__c AIConversation = new Scrum_AI_Conversation__c();
      AIConversation.Conversation_type__c = conversationType;
      AIConversation.User_Request__c = message;
      AIConversation.Generated_Prompt__c = prompt;
      AIConversation.AI_Response__c = aiResponse;
      insert AIConversation;
  }

  public static String getAIResponse(String requestType, String userMessage, String prompt) {
      String Env = 'prod'; //prod // dev
      String aiResponse;
      if (Env == 'prod') {
          // Call AI model with the generated prompt
          aiResponse = callAIModel(prompt);
          // Save This response to Scrum AI Conversation
          saveAIConversation(requestType, userMessage, prompt, aiResponse);
          if (aiResponse == 'No response') {
              // ***** This is a temp response if we don't get response from AI
              aiResponse = ScrumAITempResponse.getTempResponse(requestType);
          }
      } else {
          // ***** This is a temporary code
          aiResponse = ScrumAITempResponse.getTempResponse(requestType);
      }
      return aiResponse;
  }

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
}