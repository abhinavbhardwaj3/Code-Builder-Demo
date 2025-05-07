public without sharing class ScrumAIDevelopmentPDFHandler implements Queueable, Database.AllowsCallouts {

    private Id deploymentId;

    // Constructor to pass deployment IDs
    public ScrumAIDevelopmentPDFHandler(Id deploymentId) {
        this.deploymentId = deploymentId;
    }

    // Queueable execute method
    public void execute(QueueableContext context) {
        // Query all the deployment records
        List<Scrum_AI_Deployment__c> deployments = [SELECT Id, Deployment_Name__c, GIT_Script__c, SF_Script__c, SFDX_Script__c, YML_Script__c, Related_Sprint__c
                                           FROM Scrum_AI_Deployment__c WHERE Id =:deploymentId];

        // Iterate through each deployment and generate the PDFs
        for (Scrum_AI_Deployment__c deployment : deployments) {
            if (deployment.Related_Sprint__c != null) {
                // Generate and attach the PDFs
                generateAndAttachPDFs(deployment);
            }
        }
    }

    // Method to generate and attach PDFs
    private static void generateAndAttachPDFs(Scrum_AI_Deployment__c deployment) {
        // Generate first PDF with GIT, SF, and SFDX scripts using Visualforce page
        Blob pdf1Blob = generatePdfFromVisualforce(deployment.Id, 'DeploymentPdfPage');

        // Generate second PDF with YML script
        Blob pdf2Blob = generatePdfFromYmlVisualforce(deployment.Id);

        // Attach the PDFs to the related sprint
        attachPDFToSprint(deployment.Deployment_Name__c + '_Scripts.pdf', pdf1Blob, deployment.Related_Sprint__c);
        attachPDFToSprint(deployment.Deployment_Name__c + '_YML_Script.pdf', pdf2Blob, deployment.Related_Sprint__c);
    }

    // Helper method to generate a PDF from a Visualforce page
    private static Blob generatePdfFromVisualforce(Id deploymentId, String pageName) {
        PageReference pageRef = Page.ScrumAIDeploymentPdfPage;  // Specify the Visualforce page
        pageRef.getParameters().put('id', deploymentId);
        return pageRef.getContentAsPDF();
    }

    // Helper method to generate a YML PDF from a separate Visualforce page
    private static Blob generatePdfFromYmlVisualforce(Id deploymentId) {
        PageReference pageRef = Page.ScrumAIDeploymentYmlPdfPage;  // Specify a separate Visualforce page for YML
        pageRef.getParameters().put('id', deploymentId);
        return pageRef.getContentAsPDF();
    }

     // Helper method to attach PDF to the sprint
    private static void attachPDFToSprint(String fileName, Blob pdfBlob, Id sprintId) {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = fileName;
        contentVersion.PathOnClient = fileName;
        contentVersion.VersionData = pdfBlob;
        insert contentVersion;

        // Fetch the ContentDocumentId from the inserted ContentVersion
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.LinkedEntityId = sprintId;
        contentDocumentLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
        contentDocumentLink.ShareType = 'V'; // Visible to all users
        contentDocumentLink.Visibility = 'AllUsers';
        insert contentDocumentLink;
    }

    // Static method to call the Queueable job from the trigger
    @future(callout=true)
    public static void generateDeploymentPDFsAsync(Id deploymentId) {
        System.enqueueJob(new ScrumAIDevelopmentPDFHandler(deploymentId));
    }
}