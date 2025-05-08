public without sharing class Agentforce_Health_CaseTaskTriggerHandler {
    public static Map<Id, Id> createCaseAndTask(List<Provider_Details__c> providerDetailsList) {
        List<Case> casesToInsert = new List<Case>();
        List<Task> tasksToInsert = new List<Task>();
        Map<Id, Id> providerToCaseMap = new Map<Id, Id>(); // Map to link Provider ID to Case ID
        
        // Get System Administrator profile ID
        User systemAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        
        for (Provider_Details__c providerDetails : providerDetailsList) {
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
                OwnerId = systemAdmin.Id
            );
            casesToInsert.add(newCase);
        }
        
        // Insert Cases
        insert casesToInsert;
        
        for (Integer i = 0; i < providerDetailsList.size(); i++) {
            Provider_Details__c providerDetails = providerDetailsList[i];
            Case newCase = casesToInsert[i];
            
            // Map the Case ID to the Provider record
            providerToCaseMap.put(providerDetails.Id, newCase.Id);
            
            // Create Task
            Task newTask = new Task(
                Subject = 'Verify Provider Details and Register',
                Description = 'Please check the provider details record and verify the details. If all looks good, register the user as a provider.',
                Priority = 'High',
                Status = 'Not Started',
                WhatId = newCase.Id,
                OwnerId = systemAdmin.Id,
                ActivityDate = Date.today().addDays(3) // Set due date to 3 days from today
            );
            tasksToInsert.add(newTask);
        }
        
        // Insert Tasks
        insert tasksToInsert;
        
        // Return the map of Provider to Case IDs
        return providerToCaseMap;
    }
    
    public static void updateProviderDetailsWithCaseIds(List<Provider_Details__c> providerDetailsList, Map<Id, Id> providerToCaseMap) {
        List<Provider_Details__c> providerDetailsToUpdate = new List<Provider_Details__c>();
        
        for (Provider_Details__c providerDetails : providerDetailsList) {
            if (providerToCaseMap.containsKey(providerDetails.Id)) {
                Provider_Details__c updatedProviderDetails = new Provider_Details__c(
                    Id = providerDetails.Id,
                    Case_ID__c = providerToCaseMap.get(providerDetails.Id)
                );
                providerDetailsToUpdate.add(updatedProviderDetails);
            }
        }
        
        // Perform the update
        update providerDetailsToUpdate;
    }
}