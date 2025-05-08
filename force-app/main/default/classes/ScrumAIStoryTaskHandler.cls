public without sharing class ScrumAIStoryTaskHandler {

    // Define keywords to identify if request is for create story
    public static Set<String> storyKeywords = new Set<String>{
        	'create story',
            'make a new story',
            'create a story',
            'new story',
            'create new story',
            'start story',
            'begin story',
            'initiate story'
            };

    // Check if the user request contains story creation keywords
    public static boolean isStoryCreateRequest(String userRequest) {
        for (String keyword : storyKeywords) {
            if (userRequest.toLowerCase().contains(keyword)) {
                return true;
            }
        }
        return false;
    }

    // Create prompt for story creation
    public static String createStoryTaskPrompt(String userRequest) {
        Scrum_AI_Prompt_Template__c promptTemplate = ScrumAIGenericHandler.getPromptTemplate('story');
        String resourceList = ScrumAIResourceHandler.generateResourceList();
        String sprintList = ScrumAISprintHandler.generateActiveSprintList();
        system.debug('Getting resource List ********');
        system.debug(resourceList);
        system.debug('Getting Sprint List ********');
        system.debug(sprintList);
        String userPrompt = promptTemplate.Role_User__c.replace('{userRequest}', userRequest).replace('{resourcesList}', resourceList).replace('{sprintDetail}', sprintList);
        return 'role: system,\n Content:' + promptTemplate.Role_System__c + '\n\n' +
            'role: assistant,\n Content:' + promptTemplate.Role_Assistant__c + '\n\n' +
            'role: user,\n Content:' + userPrompt;
    }

    public static String createTaskStoryFromResponse(String AIResponse) {
        // Get Sprint Id
        ID sprintId = ScrumAISprintHandler.getActiveSprintId();
        system.debug('sprintId ****: ');
        system.debug(sprintId);
        // Create Story__c record
        Scrum_AI_Story__c story = new Scrum_AI_Story__c();
        story.Story_Name__c = ScrumAIGenericHandler.extractValue(AIResponse, 'Story Name');
        story.Story_Description__c = ScrumAIGenericHandler.extractValue(AIResponse, 'Story Description');
        story.Story_Type__c = ScrumAIGenericHandler.extractValue(AIResponse, 'Story Type');
        story.Priority__c = ScrumAIGenericHandler.extractValue(AIResponse, 'Priority');
        story.Metadata_Details__c = ScrumAIGenericHandler.extractValue(AIResponse, 'Metadata Details');
        story.Estimated_Hours__c = Integer.valueOf(ScrumAIGenericHandler.extractValue(AIResponse, 'Estimated Hours'));
        story.Sprint__c = sprintId;
        insert story;

        system.debug('Stroy create with ID ****: ');
        system.debug(story.Id);
        // Extract tasks data (There may be multiple tasks)
        List<Scrum_AI_Story_Task__c> tasks = new List<Scrum_AI_Story_Task__c>();

        // Loop to extract multiple tasks
        Integer taskIndex = 1;
        Integer totalTaskCount = Integer.valueOf(ScrumAIGenericHandler.extractValue(AIResponse, 'Tasks Count'));
        system.debug('Tasks Count in int ****: ');
        system.debug(totalTaskCount);
        while (taskIndex < totalTaskCount+1) {
            String taskName = ScrumAIGenericHandler.extractValue(AIResponse, 'Task Name '+taskIndex);
            if (taskName == null) break; // If no more tasks, exit loop

            Scrum_AI_Story_Task__c task = new Scrum_AI_Story_Task__c();
            task.Story__c = story.Id;  // Link to the created story
            task.Task_Name__c = taskName;
           	task.Task_Description__c = ScrumAIGenericHandler.extractValue(AIResponse, 'Task Description '+taskIndex);
            task.Task_Type__c = ScrumAIGenericHandler.extractValue(AIResponse, 'Task Type '+taskIndex);
            task.Employee_Tasks__c = ScrumAIGenericHandler.extractValue(AIResponse, 'Assigned Employee '+taskIndex);
            task.Task_Start_Date__c = Date.valueOf(ScrumAIGenericHandler.extractValue(AIResponse, 'Task Start Date '+taskIndex));
            task.Task_End_Date__c = Date.valueOf(ScrumAIGenericHandler.extractValue(AIResponse, 'Task End Date '+taskIndex));

            tasks.add(task);
            taskIndex++;
        }

        if (tasks.size() > 0) {
            insert tasks;  // Insert all the tasks related to the story
        }
        // Create Story link as reponse
        return ScrumAIGenericHandler.generateLink(story.Id);
    }

    public static List<Scrum_AI_Story__c> getStoryList(string storyStatus) {
        // Query to fetch resources that are available
        return [SELECT id, Metadata_Details__c, Name, Sprint__c, Story_Status__c, Sprint__r.Project__r.Git_Repository_URL__c, Sprint__r.Project__r.Prod_Org__c, Sprint__r.Project__r.Dev_Org__c FROM Scrum_AI_Story__c WHERE Story_Status__c = :storyStatus];
    }

    // Generate a formatted list of available stories
    public static Map<String, String> generateStoryDetail(string storyStatus) {
        List<Scrum_AI_Story__c> stories = getStoryList(storyStatus);
        Map<String, String> projectInfo = new Map<String, String>();
        if(!stories.isEmpty()) { // check if we have some stories ot not
            projectInfo.put('gitRepoUrl', stories[0].Sprint__r.Project__r.Git_Repository_URL__c);
            projectInfo.put('targetOrgUrl', stories[0].Sprint__r.Project__r.Prod_Org__c);
            projectInfo.put('sourceOrgUrl', stories[0].Sprint__r.Project__r.Dev_Org__c);
            String storyList = '';
            for (Scrum_AI_Story__c story : stories) {
                storyList += 'Story Detail: Story Id: ' + story.Id + ', Name: ' + story.Name + ', Metadata Details: ' + story.Metadata_Details__c + ', \r\n';
            }
            storyList.substring(0, storyList.length() - 4); // Remove last comma
            projectInfo.put('storyDetails', storyList);
        }
        return projectInfo;
    }
}