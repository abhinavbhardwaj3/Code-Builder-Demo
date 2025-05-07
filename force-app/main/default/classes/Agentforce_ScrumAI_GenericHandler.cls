public without sharing class Agentforce_ScrumAI_GenericHandler {
    public class Request {
        @InvocableVariable(required=true)
        public String userRequest;
    }
    
    public class Response {
        @InvocableVariable
        public String responseText;
    }
    
    @InvocableMethod(label='Agentforce - ScrumAI - Generic Handler' description='Handle all user technical or non-technical queries')
    public static List<Response> handleUserQueries(List<Request> userRequests) {
        List<Response> responses = new List<Response>();
        for (Request req : userRequests) {
            Response res = new Response();
            
            // Create inputs
            ConnectApi.WrappedValue inputParamsValue = new ConnectApi.WrappedValue();
            inputParamsValue.value = req.userRequest;
            Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
            inputParams.put('Input:UserRequest', inputParamsValue);
            
            // Configure invocation parameters for speed optimization
            ConnectApi.EinsteinPromptTemplateGenerationsInput executeTemplateInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            executeTemplateInput.inputParams = inputParams;
            executeTemplateInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            executeTemplateInput.additionalConfig.applicationName = 'PromptBuilderPreview';
            executeTemplateInput.isPreview = false;  // Ensures response generation
            executeTemplateInput.citationMode = 'off'; // Disables citation to speed up response
            executeTemplateInput.outputLanguage = 'en_US'; // Reduces language processing overhead
            
            try {
                // Call the service
                ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
                    'Agentforce_ScrumAI_General_Query',
                    executeTemplateInput
                );
                if (generationsOutput.generations != null && !generationsOutput.generations.isEmpty()) {
                    ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];
                    res.responseText = response.text;
                    responses.add(res);
                } else {
                    System.debug(generationsOutput.generationErrors);
                    res.responseText = 'No response generated.';
                    responses.add(res);
                }
            } catch (Exception e) {
                System.debug('Error: ' + e.getMessage());
                res.responseText = 'An unexpected error occurred: ' + e.getMessage();
                responses.add(res);
            }
        }
        return responses;
    }
}