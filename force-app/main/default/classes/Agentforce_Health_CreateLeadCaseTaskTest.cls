@isTest
private class Agentforce_Health_CreateLeadCaseTaskTest {
@IsTest
    static void testCreateProviderWork() {
        // Create a test Provider Details record
        Provider_Details__c testProviderDetails = new Provider_Details__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@example.com',
            Lead_ID__c = '12345',
            Phone_Number__c = '1234567890'
        );
        insert testProviderDetails;
        
        // Create a request object
        Agentforce_Health_CreateLeadCaseTask.CreateProviderWorkRequest request = new Agentforce_Health_CreateLeadCaseTask.CreateProviderWorkRequest();
        request.providerDetailsId = testProviderDetails.Id;
        
        // Call the invocable method
        List<Agentforce_Health_CreateLeadCaseTask.CreateProviderWorkResponse> responses = Agentforce_Health_CreateLeadCaseTask.createProviderWork(new List<Agentforce_Health_CreateLeadCaseTask.CreateProviderWorkRequest>{request});
        
        // Assert that the response is not empty
        System.assert(!responses.isEmpty());
        
        // Assert that the Case and Task were created successfully
        System.assert(responses[0].caseId != null);
        System.assert(responses[0].taskId != null);
        
        // Verify that the Case and Task were created with the correct details
        Case createdCase = [SELECT Id, Subject, Description, OwnerId FROM Case WHERE Id = :responses[0].caseId];
        Task createdTask = [SELECT Id, Subject, Description, Priority, Status, WhatId, OwnerId, ActivityDate FROM Task WHERE Id = :responses[0].taskId];
        
        System.assertEquals('Verify and Register Provider: John Doe', createdCase.Subject);
        System.assertEquals('Verify Provider Details and Register', createdTask.Subject);
    }

}