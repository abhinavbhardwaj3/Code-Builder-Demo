public without sharing class ScrumAIGeneralQueryHandler {
    // Define keywords to identify if request is to provide story status
    public static Set<String> storyStatusKeywords = new Set<String>{
        'story status',
            'stories status',
            'story current status',
            'stories current status',
            'all stories',
            'all story'
            };

                // Define keywords to identify if request is to provide project Status
                public static Set<String> projectStatusKeywords = new Set<String>{
                    'project status',
                        'project current status',
                        'project overview',
                        'project stage',
                        'project current stage'
                        };

                            // Check if the user request contains Stroy status keywords
                            public static boolean isStoryStatusRequest(String userRequest) {
                                for (String keyword : storyStatusKeywords) {
                                    if (userRequest.toLowerCase().contains(keyword)) {
                                        return true;
                                    }
                                }
                                return false;
                            }

    // Check if the user request contains Project status keywords
    public static boolean isProjectStatusRequest(String userRequest) {
        for (String keyword : projectStatusKeywords) {
            if (userRequest.toLowerCase().contains(keyword)) {
                return true;
            }
        }
        return false;
    }

    public static String getCompletedStories() {
        integer completedStories = 0;
        list<Scrum_AI_Story__c> storyList = [SELECT ID, Story_Name__c, Story_Status__c, Sprint__c, Total_Story_Cost__c from Scrum_AI_Story__c];
        String response = 'Story Name               	| Status       |  Sprint       | Cost\n' ;
        response += '----------------------------------------------------------\n' ;
        for(Scrum_AI_Story__c str : storyList) {
            if (str.Story_Status__c == 'Completed') {
                completedStories++;
            }
            String storyName = str.Story_Name__c;
            String sprintName = str.Sprint__r != null ? str.Sprint__r.Sprint_Name__c : 'N/A';
            String status = str.Story_Status__c;
            Decimal storyCost = str.Total_Story_Cost__c;
            String cost = '$' + String.valueOf(storyCost);
            response += String.format('{0}          | {1}  | {2}  | {3}\n', new List<String>{storyName, status, sprintName, cost});
        }
        response += '----------------------------------------------------------\n' ;
        if (completedStories > 0) {
            response += 'I found that you have completed ' + completedStories + ' out of ' + storyList.size() + ' stories, \n ';
            response += ' so would you like me to generate deployment suggestions for them?  Kindly type: \n\n   Generate deployment steps';
        }

        // Display the response
        System.debug('Total story count');
        System.debug(storyList.size());
        System.debug('completedStories========');
        System.debug(completedStories);
        return response;
    }

    public static String getProjectOverview() {
        // Fetch project details
        Scrum_AI_Project__c projectDetail = [SELECT Id, Project_Name__c, Project_Start_Date__c, Project_End_Date__c,
                                    Project_Manager__r.Name, Estimated_Project_Cost__c, Total_Project_Cost__c,
                                    Sprint_Count__c, Project_Status__c
                                    FROM Scrum_AI_Project__c
                                    WHERE Project_Status__c = 'In Progress' LIMIT 1];

        // Fetch active and completed sprints
        List<Scrum_AI_Sprint__c> activeSprints = [SELECT Id, Name, Sprint_Status__c
                                         FROM Scrum_AI_Sprint__c
                                         WHERE Project__c = :projectDetail.Id AND Sprint_Status__c = 'In Progress'];
        List<Scrum_AI_Sprint__c> completedSprints = [SELECT Id, Name
                                            FROM Scrum_AI_Sprint__c
                                            WHERE Project__c = :projectDetail.Id AND Sprint_Status__c = 'Completed'];

        // Fetch stories related to active sprint
        List<Scrum_AI_Story__c> activeSprintStories = [SELECT Id, Story_Name__c, Story_Status__c, Tasks_Count__c, Total_Story_Cost__c
                                              FROM Scrum_AI_Story__c
                                              WHERE Sprint__c IN :activeSprints];

        // Calculate project budget status
        Decimal estimatedCost = projectDetail.Estimated_Project_Cost__c;
        Decimal actualCost = projectDetail.Total_Project_Cost__c;
        Decimal costDifference = estimatedCost - actualCost;
        String budgetStatus = (costDifference >= 0) ? 'In Budget' : 'Over Budget';

        // Prepare story statistics
        Integer storiesCompleted = 0;
        Integer storiesInProgress = 0;
        Integer storiesPlanned = 0;
        Decimal totalTasks = 0;
        Integer totalStories = activeSprintStories.size();

        for (Scrum_AI_Story__c story : activeSprintStories) {
            if (story.Story_Status__c == 'Completed') {
                storiesCompleted++;
            } else if (story.Story_Status__c == 'In Progress') {
                storiesInProgress++;
            } else if (story.Story_Status__c == 'Not Started') {
                storiesPlanned++;
            }
            totalTasks += story.Tasks_Count__c;
        }

        // Build the project overview text
        String response = 'Here is the current overview of your project: \n\n';
        response += 'Project Name: ' + projectDetail.Project_Name__c + '\n';
        response += 'Start Date: ' + String.valueOf(projectDetail.Project_Start_Date__c) + '\n';
        response += 'End Date: ' + String.valueOf(projectDetail.Project_End_Date__c) + '\n';
        response += 'Project Manager: ' + projectDetail.Project_Manager__r.Name + '\n';
        response += 'Estimated Project Cost: USD ' + String.valueOf(estimatedCost) + '\n';
        response += 'Actual Project Cost: USD ' + String.valueOf(actualCost) + '\n';
        response += 'Cost Difference: USD ' + String.valueOf(costDifference) + '\n';
        response += 'Project Status: ' + budgetStatus + '\n';
        response += 'Active Sprint: ' + (activeSprints.size() > 0 ? activeSprints[0].Name : 'None') + '\n';
        response += 'Completed Sprints: ' + completedSprints.size() + '\n';
        response += 'Stories Completed: ' + storiesCompleted + '\n';
        response += 'Stories In Progress: ' + storiesInProgress + '\n';
        response += 'Stories Planned: ' + storiesPlanned + '\n';
        response += 'Tasks in current Sprint: ' + totalTasks + '\n';

        // Check if there are completed stories in the active sprint and provide deployment suggestion
        if (storiesCompleted > 0) {
            response += '\nI noticed that you have completed ' + storiesCompleted + ' out of ' + totalStories +
                        ' stories in the current sprint. Would you like me to generate deployment suggestions for them? Kindly type: \n\n   Generate deployment steps';
        }

        return response;
    }

    public static List<Scrum_AI_Story__c> getStoriesByStatus(String status) {
        return [SELECT Story_Name__c, Story_Status__c, Sprint__r.Sprint_Name__c FROM Scrum_AI_Story__c WHERE Story_Status__c = :status];
    }

    public static List<Scrum_AI_Sprint__c> getSprintsByProjectId(Id projectId) {
        return [SELECT Id, Name FROM Scrum_AI_Sprint__c WHERE Project__c = :projectId];
    }

    public static List<Scrum_AI_Story__c> getStoriesBySprintId(Id sprintId) {
        return [SELECT Id, Name, Sprint__c FROM Scrum_AI_Story__c WHERE Sprint__c = :sprintId];
    }

}