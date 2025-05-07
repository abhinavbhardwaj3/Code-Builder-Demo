public without sharing class Agentforce_ScrumAI_PdfController {
    public Scrum_AI_Deployment__c deployment { get; set; }

    public Agentforce_ScrumAI_PdfController() {
        // Fetch the deployment record using the Id passed in the URL
        Id deploymentId = ApexPages.currentPage().getParameters().get('id');
        if (deploymentId != null) {
            // Retrieve the deployment record
            deployment = [SELECT Deployment_Name__c , GIT_Script__c, SF_Script__c, SFDX_Script__c, YML_Script__c
                          FROM Scrum_AI_Deployment__c WHERE Id = :deploymentId];
            // Clean the fields by removing <pre> and <code> tags
            deployment.GIT_Script__c = removeTags(deployment.GIT_Script__c);
            deployment.SF_Script__c = removeTags(deployment.SF_Script__c);
            deployment.SFDX_Script__c = removeTags(deployment.SFDX_Script__c);
            deployment.YML_Script__c = removeTags(deployment.YML_Script__c);
        }
    }

    // Method to remove <pre> and <code> tags
    private String removeTags(String input) {
        if (input == null) {
            return null;
        }
        return input.replaceAll('<pre>', '').replaceAll('</pre>', '').replaceAll('<code>', '').replaceAll('</code>', '').replaceAll('&#39;', '\n');
    }
}