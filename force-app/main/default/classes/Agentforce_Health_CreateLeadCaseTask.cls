public without sharing class Agentforce_Health_CreateLeadCaseTask {
    
    // Request class for input
    public class CreateProviderWorkRequest {
        @InvocableVariable(required = true)
        public Id providerDetailsId; // Provider Details record ID
    }
    
    // Response class for output
    public class CreateProviderWorkResponse {
        @InvocableVariable
        public Id caseId; // ID of the created Case
        
        @InvocableVariable
        public Id taskId; // ID of the created Task
    }
    
    // Invocable Method to create Case and Task
    @InvocableMethod(label = 'Agentforce - Health - Apex - CreateCaseTask' description = 'Creates a Case and Task for provider registration.')
    public static List<CreateProviderWorkResponse> createProviderWork(List<CreateProviderWorkRequest> requests) {
        List<CreateProviderWorkResponse> responses = new List<CreateProviderWorkResponse>();
        
        // Get System Administrator profile ID
        User systemAdminProfile = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        
        for (CreateProviderWorkRequest request : requests) {
            CreateProviderWorkResponse response = new CreateProviderWorkResponse();
            
            try {
                // Fetch Provider Details record
                Provider_Details__c providerDetails = [
                    SELECT Id, First_Name__c, Last_Name__c, Email__c, Lead_ID__c, Phone_Number__c, Case_ID__c
                    FROM Provider_Details__c
                    WHERE Id = :request.providerDetailsId
                    LIMIT 1
                ];
                
                // Create Case
                Case newCase = new Case(
                    Subject = 'Verify and Register Provider: ' + providerDetails.First_Name__c + ' ' + providerDetails.Last_Name__c,
                    Description = 'Please check the provider details record and verify the details. If all looks good, register the user as a provider.\n\n' +
                                  'Provider Details:\n' +
                                  'First Name: ' + providerDetails.First_Name__c + '\n' +
                                  'Last Name: ' + providerDetails.Last_Name__c + '\n' +
                                  'Phone: ' + providerDetails.Phone_Number__c + '\n' +
                                  'Email: ' + providerDetails.Email__c + '\n' +
                                  'Lead ID: ' + providerDetails.Lead_ID__c,
                    OwnerId = systemAdminProfile.Id
                );
                insert newCase;
                
                // Update Provider_Details__c with Case ID
                providerDetails.Case_ID__c = newCase.Id;
                update providerDetails;
                
                // Create Task
                Task newTask = new Task(
                    Subject = 'Verify Provider Details and Register',
                    Description = 'Please check the provider details record and verify the details. If all looks good, register the user as a provider.',
                    Priority = 'High',
                    Status = 'Not Started',
                    WhatId = newCase.Id,
                    OwnerId = systemAdminProfile.Id,
                    ActivityDate = Date.today().addDays(3) // Set due date to 3 days from today
                );
                insert newTask;
                
                // Populate response
                response.caseId = newCase.Id;
                response.taskId = newTask.Id;
                
            } catch (Exception e) {
                System.debug('Error creating records: ' + e.getMessage());
            }
            
            responses.add(response);
        }
        
        return responses;
    }
}