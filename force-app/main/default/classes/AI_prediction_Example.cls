public without sharing class AI_prediction_Example {
    public class Response {
        @InvocableVariable
        public String responseText;
    }
    
    // @InvocableMethod(label='AI prediction Example' description='Get all object data and pass this to prompt',)
    // @InvocableMethod(label='Generate Sales Email', description='Create a sales email draft', CapabilityType='PromptTemplateType://einstein_gpt__salesEmail') 

    public static List<Response> handleUserQueries() {
        List<Response> responses = new List<Response>();
        Response res = new Response();
        
        // Get all object data
        List<Toy__c> records = [SELECT Name, Age__c, Churn__c, City__c, Gender__c, Salary__c, Product__c FROM Toy__c LIMIT 5000];
        
        // Create inputs
        String inputParamsValue = '';
        for (Toy__c record : records) {
            inputParamsValue += 'Name: ' + record.Name + '\n';
            inputParamsValue += 'Age: ' + record.Age__c + '\n';
            inputParamsValue += 'Churn: ' + record.Churn__c + '\n';
            inputParamsValue += 'City: ' + record.City__c + '\n';
            inputParamsValue += 'Gender: ' + record.Gender__c + '\n';
            inputParamsValue += 'Salary: ' + record.Salary__c + '\n';
            inputParamsValue += 'Product: ' + record.Product__c + '\n';
            inputParamsValue += '\n';
        }
        
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
        ConnectApi.WrappedValue inputValue = new ConnectApi.WrappedValue();
        inputValue.value = inputParamsValue;
        inputParams.put('Input:UserRequest', inputValue);
        
        // Configure invocation parameters for speed optimization
        ConnectApi.EinsteinPromptTemplateGenerationsInput executeTemplateInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        executeTemplateInput.inputParams = inputParams;
        executeTemplateInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        executeTemplateInput.additionalConfig.applicationName = 'PromptBuilderPreview';
        executeTemplateInput.isPreview = false;
        executeTemplateInput.citationMode = 'off';
        executeTemplateInput.outputLanguage = 'en_US';
        
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
        
        return responses;
    }
}