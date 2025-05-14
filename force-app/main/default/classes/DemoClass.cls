public class DemoClass {
    public static void sendEmail() {
        List<User> adminUsers = [SELECT Id, Email FROM User WHERE Profile.Name = 'System Administrator'];
        
        if (adminUsers.isEmpty()) {
            System.debug('No admin users found.');
            return;
        }
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (User adminUser : adminUsers) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{adminUser.Email});
            email.setSubject('Email Subject');
            email.setPlainTextBody('Email Body');
            emails.add(email);
        }
        
        try {
            Messaging.sendEmail(emails);
            System.debug('Emails sent successfully.');
        } catch (Exception e) {
            System.debug('Error sending emails: ' + e.getMessage());
        }
    }
}