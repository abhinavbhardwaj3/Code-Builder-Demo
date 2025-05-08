public without sharing class Agentforce_ScrumAI_ProjectOverview {

    public class ProjectRequest {
        @InvocableVariable(required=true)
        public Id projectId;
    }

    public class ProjectResponse {
        @InvocableVariable
        public String overview;
    }

    @InvocableMethod(label='Agentforce - ScrumAI - Project Overview' 
                     description='Generate Full Project Overview including All Sprints, Stories, Task and Resources')
    public static List<ProjectResponse> getProjectOverview(List<ProjectRequest> projectRequests) {
        List<ProjectResponse> responses = new List<ProjectResponse>();
        
        for (ProjectRequest request : projectRequests) {
            ProjectResponse response = new ProjectResponse();
            Id projectId = request.projectId;

            // Query to get Project Details
            Scrum_AI_Project__c project = [
                SELECT Id, Project_Name__c, Project_Start_Date__c, Project_End_Date__c, Estimated_Project_Cost__c, 
                        Total_Project_Cost__c, Sprint_Count__c, Project_Manager__r.Name, Project_Manager__r.Per_Hour_Rate__c,
                        Project_Manager__r.Skills__c
                FROM Scrum_AI_Project__c
                WHERE Id = :projectId
                LIMIT 1
            ];
            
            String projectOverview = 'Project Details:\n\n' +
                                     '- Project Name: ' + project.Project_Name__c + '\n' +
                                     '- Project Start Date: ' + project.Project_Start_Date__c + '\n' +
                                     '- Project End Date: ' + project.Project_End_Date__c + '\n' +
                                     '- Project ID: ' + project.Id + '\n' +
                                     '- Estimated Project Cost: ' + project.Estimated_Project_Cost__c + '\n' +
                                     '- Total Project Cost: ' + project.Total_Project_Cost__c + '\n' +
                                     '- Sprint Count: ' + project.Sprint_Count__c + '\n' +
                                     '- Project Manager Name: ' + project.Project_Manager__r.Name + '\n' +
                                     '- Project Manager Per Hour Rate: ' + project.Project_Manager__r.Per_Hour_Rate__c + '\n' +
                                     '- Project Manager Skills: ' + project.Project_Manager__r.Skills__c + '\n\n';

            // Query to get Sprint Details
            List<Scrum_AI_Sprint__c> sprints = [
                SELECT Id, Sprint_Name__c, Sprint_Status__c, Sprint_Description__c, Sprint_Start_Date__c, 
                       Sprint_End_Date__c, Story_Count__c
                FROM Scrum_AI_Sprint__c
                WHERE Project__c = :projectId
            ];
            
            for (Scrum_AI_Sprint__c sprint : sprints) {
                projectOverview += 'Sprint Details:\n\n' +
                                   '- Sprint Name: ' + sprint.Sprint_Name__c + '\n' +
                                   '- Sprint Status: ' + sprint.Sprint_Status__c + '\n' +
                                   '- Sprint Description: ' + sprint.Sprint_Description__c + '\n' +
                                   '- Sprint Start Date: ' + sprint.Sprint_Start_Date__c + '\n' +
                                   '- Sprint End Date: ' + sprint.Sprint_End_Date__c + '\n' +
                                   '- Story Count: ' + sprint.Story_Count__c + '\n\n';

                // Query to get Story Details
                List<Scrum_AI_Story__c> stories = [
                    SELECT Id, Story_Name__c, Story_Status__c, Story_Description__c, Estimated_Hours__c, 
                           Priority__c, Tasks_Count__c, Total_Story_Cost__c, Story_Type__c
                    FROM Scrum_AI_Story__c
                    WHERE Sprint__c = :sprint.Id
                ];
                
                for (Scrum_AI_Story__c story : stories) {
                    projectOverview += 'Story Details:\n\n' +
                                       '- Story Name: ' + story.Story_Name__c + '\n' +
                                       '- Story Status: ' + story.Story_Status__c + '\n' +
                                       '- Story Description: ' + story.Story_Description__c + '\n' +
                                       '- Estimated Hours: ' + story.Estimated_Hours__c + '\n' +
                                       '- Priority: ' + story.Priority__c + '\n' +
                                       '- Tasks Count: ' + story.Tasks_Count__c + '\n' +
                                       '- Total Story Cost: ' + story.Total_Story_Cost__c + '\n' +
                                       '- Story Type: ' + story.Story_Type__c + '\n\n';

                    // Query to get Task Details
                    List<Scrum_AI_Story_Task__c> tasks = [
                        SELECT Id, Task_Name__c, Task_Type__c, Task_Status__c, Task_Start_Date__c, 
                               Task_End_Date__c, Task_Description__c, Task_Cost__c, Employee_Tasks__r.Name, 
                               Employee_Tasks__r.User_Name__c, Employee_Tasks__r.Total_Hours_Worked__c,
                               Employee_Tasks__r.Skills__c, Employee_Tasks__r.Role__c, Employee_Tasks__r.Per_Hour_Rate__c
                        FROM Scrum_AI_Story_Task__c
                        WHERE Story__c = :story.Id
                    ];

                    for (Scrum_AI_Story_Task__c task : tasks) {
                        projectOverview += 'Story Task Details:\n\n' +
                                           '- Task Name: ' + task.Task_Name__c + '\n' +
                                           '- Task Type: ' + task.Task_Type__c + '\n' +
                                           '- Task Status: ' + task.Task_Status__c + '\n' +
                                           '- Task Start Date: ' + task.Task_Start_Date__c + '\n' +
                                           '- Task End Date: ' + task.Task_End_Date__c + '\n' +
                                           '- Task Description: ' + task.Task_Description__c + '\n' +
                                           '- Task Cost: ' + task.Task_Cost__c + '\n\n';

                        // Assigned Resource Details
                        projectOverview += 'Assigned Resource Details:\n\n' +
                                           '- Employee Name: ' + task.Employee_Tasks__r.Name + '\n' +
                                           '- User Name: ' + task.Employee_Tasks__r.User_Name__c + '\n' +
                                           '- Total Hours Worked: ' + task.Employee_Tasks__r.Total_Hours_Worked__c + '\n' +
                                           '- Skills: ' + task.Employee_Tasks__r.Skills__c + '\n' +
                                           '- Role: ' + task.Employee_Tasks__r.Role__c + '\n' +
                                           '- Per Hour Rate: ' + task.Employee_Tasks__r.Per_Hour_Rate__c + '\n\n';
                    }
                }
            }
            
            response.overview = projectOverview;
            responses.add(response);
        }
        
        return responses;
    }
}