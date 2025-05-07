public without sharing class Agentforce_ScrumAI_DeploymentHandler {
    public class Request {
        @InvocableVariable(required=true)
        public Id projectId;

        @InvocableVariable(required=true)
        public Id sprintId;
    }

    public class Response {
        @InvocableVariable
        public String responseText;
    }

    @InvocableMethod(label='Agentforce - ScrumAI - Deployment Handler' description='Generate Deployment script and pipeline')
    public static List<Response> generateDeployment(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();

            // Prepare input parameters for AI
            Map<String, String> projectMap = new Map<String, String>();
            projectMap.put('id', String.valueOf(req.projectId));
            ConnectApi.WrappedValue projectIdValue = new ConnectApi.WrappedValue();
            projectIdValue.value = projectMap;

            Map<String, String> sprintMap = new Map<String, String>();
            sprintMap.put('id', String.valueOf(req.sprintId));
            ConnectApi.WrappedValue sprintIdValue = new ConnectApi.WrappedValue();
            sprintIdValue.value = sprintMap;

            Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
            inputParams.put('Input:projectID', projectIdValue);
            inputParams.put('Input:sprintD', sprintIdValue);

            // Configure invocation parameters
            ConnectApi.EinsteinPromptTemplateGenerationsInput executeTemplateInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            executeTemplateInput.inputParams = inputParams;
            executeTemplateInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            executeTemplateInput.additionalConfig.applicationName = 'PromptBuilderPreview';
            executeTemplateInput.isPreview = false;
            executeTemplateInput.citationMode = 'off';
            executeTemplateInput.outputLanguage = 'en_US';

            try {
                // Call the AI service
                ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
                    'Agentforce_ScrumAI_Deployment_Prompt',
                    executeTemplateInput
                );

                if (generationsOutput.generations != null && !generationsOutput.generations.isEmpty()) {
                    ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];

                    // Clean JSON response
                    String cleanedJsonResponse = cleanJson(response.text);
                    System.debug('****** Response Text *****');
                    System.debug(cleanedJsonResponse);

                    // Parse JSON response
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(cleanedJsonResponse);

                    // Create the Deployment record
                    Scrum_AI_Deployment__c newDeployment = new Scrum_AI_Deployment__c();
                    newDeployment.Deployment_Name__c = (String) responseMap.get('Deployment_Name');
                    newDeployment.Related_Sprint__c = (String) responseMap.get('Related_Sprint');
                    newDeployment.Related_Project__c = (String) responseMap.get('Related_Project');
                    newDeployment.SFDX_Script__c = formatScript(responseMap.get('SFDX_Script'));
                    newDeployment.SF_Script__c = formatScript(responseMap.get('SF_Script'));
                    newDeployment.GIT_Script__c = formatScript(responseMap.get('GIT_Script'));
                    newDeployment.YML_Script__c = (String) responseMap.get('YML_Script');
                    newDeployment.Deployment_Status__c = 'Ready'; // Set initial status to 'Ready'

                    insert newDeployment; // Insert Deployment record

                    // Generate deployment URL (Optional)
                    String deploymentUrl = '/' + newDeployment.Id;

                    res.responseText = 'A deployment has been created for you. Please take a look at the URL below and update as needed.\n\n';
                    res.responseText += 'Deployment URL: ' + deploymentUrl + '\n\n';
                } else {
                    System.debug(generationsOutput.generationErrors);
                    res.responseText = 'No deployment generated.';
                }
            } catch (Exception e) {
                System.debug('Error: ' + e.getMessage());
                res.responseText = 'An unexpected error occurred: ' + e.getMessage();
            }

            responses.add(res);
        }

        return responses;
    }

    // Helper method to format script arrays into rich text
    private static String formatScript(Object scriptObj) {
        if (scriptObj == null) {
            return null;
        }

        List<Object> scriptList = (List<Object>) scriptObj;
        String formattedScript = '';
        for (Object item : scriptList) {
            String line = (String) item;
            formattedScript += line + '<br/>';
        }
        return formattedScript;
    }

    // Helper method to clean JSON response
    private static String cleanJson(String jsonResponse) {
        jsonResponse = jsonResponse.replace('```json', '').replace('```', '').trim();
        jsonResponse = jsonResponse.replace('‘', '\'').replace('’', '\''); // Replace any curly quotes with straight quotes
        jsonResponse = jsonResponse.replaceAll('[^\\x00-\\x7F]', ''); // Remove non-ASCII characters
        return jsonResponse;
    }
}