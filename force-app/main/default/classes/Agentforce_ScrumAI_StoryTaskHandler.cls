public without sharing class Agentforce_ScrumAI_StoryTaskHandler {
    public class Request {
        @InvocableVariable(required=true)
        public String userRequest;
    }

    public class Response {
        @InvocableVariable
        public String responseText;
    }

    @InvocableMethod(label='Agentforce - ScrumAI - Story Task Handler' description='Generate Story and Task and assign those tasks to available resources')
    public static List<Response> generateStoryAndTasks(List<Request> userRequests) {
        List<Response> responses = new List<Response>();

        for (Request req : userRequests) {
            Response res = new Response();

            // Prepare input parameters for AI
            ConnectApi.WrappedValue inputParamsValue = new ConnectApi.WrappedValue();
            inputParamsValue.value = req.userRequest;
            Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
            inputParams.put('Input:UserRequest', inputParamsValue);

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
                    'Agentforce_ScrumAI_Story_Prompt',
                    executeTemplateInput
                );

                if (generationsOutput.generations != null && !generationsOutput.generations.isEmpty()) {
                    ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];

                    // Clean JSON response
                    String cleanedJsonResponse = response.text.replace('```json', '').replace('```', '').trim();
                    system.debug('****** response.text *****');
                    system.debug(response.text);
                    // Parse JSON response
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(cleanedJsonResponse);
                    Map<String, Object> storyMap = (Map<String, Object>) responseMap.get('Story');
                    List<Object> tasksList = (List<Object>) storyMap.get('Tasks');

                    // Create the Story record
                    Scrum_AI_Story__c newStory = new Scrum_AI_Story__c();
                    newStory.Story_Name__c = (String) storyMap.get('StoryName');
                    newStory.Story_Description__c = (String) storyMap.get('StoryDescription');
                    newStory.Story_Type__c = (String) storyMap.get('StoryType');
                    newStory.Priority__c = (String) storyMap.get('Priority');
                    newStory.Metadata_Details__c = (String) storyMap.get('MetadataDetails');
                    newStory.Estimated_Hours__c = Integer.valueOf(storyMap.get('EstimatedHours').toString());
                    newStory.Sprint__c = (String) responseMap.get('SprintId'); 

                    insert newStory; // Insert Story record
                    
                    // List to store task records
                    List<Scrum_AI_Story_Task__c> tasksToInsert = new List<Scrum_AI_Story_Task__c>();
                    
                    for (Object taskObj : tasksList) {
                        Map<String, Object> taskMap = (Map<String, Object>) taskObj;
                        Scrum_AI_Story_Task__c newTask = new Scrum_AI_Story_Task__c();
                        newTask.Story__c = newStory.Id;
                        newTask.Task_Name__c = (String) taskMap.get('TaskName');
                        newTask.Task_Description__c = (String) taskMap.get('TaskDescription');
                        newTask.Task_Type__c = (String) taskMap.get('TaskType');
                        newTask.Employee_Tasks__c = (String) taskMap.get('AssignedEmployee'); 
                        newTask.Task_Start_Date__c = parseDate((String) taskMap.get('TaskStartDate'));
                        newTask.Task_End_Date__c = parseDate((String) taskMap.get('TaskEndDate'));

                        tasksToInsert.add(newTask);
                    }
                    
                    // Insert tasks in bulk
                    if (!tasksToInsert.isEmpty()) {
                        insert tasksToInsert;
                    }

                    // Generate story URL
                    String storyUrl = '/' + newStory.Id;
                    
                    //res.responseText = 'A story has been created for you. \n\n Please take a look at the URL below and update the story and task as needed.\n\n';
                    //res.responseText += 'Story URL: ' + storyUrl + '\n\n';
                    res.responseText += storyUrl;
                } else {
                    System.debug(generationsOutput.generationErrors);
                    res.responseText = 'No story generated.';
                }
            } catch (Exception e) {
                System.debug(e.getMessage());
                res.responseText = 'An unexpected error occurred: ' + e.getMessage();
            }

            responses.add(res);
        }
        
        return responses;
    }

    private static Date parseDate(String dateStr) {
        List<String> dateParts = dateStr.split('/');
        Integer month = Integer.valueOf(dateParts[0]);
        Integer day = Integer.valueOf(dateParts[1]);
        Integer year = Integer.valueOf(dateParts[2]);
        return Date.newInstance(year, month, day);
    }
}