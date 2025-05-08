public without sharing class Agentforce_Health_UpdateProviderDetails {
    @InvocableMethod(label = 'Agentforce - Health - Update Provider Record' description = 'Update provider details record with status and feedback provided by Credential Specialist')
    public static List<Boolean> updateProvider(List<Request> requests) {
        List<Boolean> results = new List<Boolean>();
        for (Request req : requests) {
            try {
                Provider_Details__c provider = [SELECT Id, Status__c, Case_ID__c, Credential_Specialist_Feedback__c, Email__c, First_Name__c FROM Provider_Details__c WHERE Id = :req.providerId LIMIT 1];
                provider.Status__c = req.status;
                provider.Credential_Specialist_Feedback__c = req.feedback;
                update provider;
                results.add(true);

                // Update the Case status based on the provider status
                Case caseRecord = [SELECT Id, Status FROM Case WHERE Id = :provider.Case_ID__c LIMIT 1];
                if (req.status == 'Verified') {
                    caseRecord.Status = 'Closed Verified';
                    sendEmail(provider.Email__c, provider.First_Name__c, 'Verified', req.feedback);
                } else if (req.status == 'Rejected') {
                    caseRecord.Status = 'Closed Rejected';
                    sendEmail(provider.Email__c, provider.First_Name__c, 'Rejected', req.feedback);
                }
                update caseRecord;
            } catch (Exception e) {
                results.add(false);
            }
        }
        return results;
    }

    private static void sendEmail(String email, String firstName, String status, String feedback) {
        String subject = 'Important Update Regarding Your Registration Status';
        String body = 'Dear ' + firstName + ',\n\n';
        
        if (status == 'Verified') {
            body += 'We are pleased to inform you that your registration has been successfully verified. You are now officially registered in our portal. ';
            body += 'You can now access all the features and benefits available to registered members.\n\n';
        } else if (status == 'Rejected') {
            body += 'We regret to inform you that your registration request has been rejected. ';
            body += 'Unfortunately, you did not meet the necessary criteria for registration at this time.\n\n';
        }
        
        if (feedback != null && feedback != '') {
            body += 'Feedback from Credential Specialist: ' + feedback + '\n\n';
        } else {
            body += 'Status: ' + status + '\n\n';
        }
        
        body += 'If you have any questions or need further assistance, please do not hesitate to contact us.\n\n';
        body += 'Best regards,\nYour Company';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { email });
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public class Request {
        @InvocableVariable(label = 'Provider Id' description = 'Id of the Provider_Details__c record')
        public Id providerId;

        @InvocableVariable(label = 'Status' description = 'Status of the provider (Verified, Rejected, On-Hold)')
        public String status;

        @InvocableVariable(label = 'Credential Specialist Feedback' description = 'Feedback provided by the Credential Specialist')
        public String feedback;
    }
}