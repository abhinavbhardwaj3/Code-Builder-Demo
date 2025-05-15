public class DemoClass {
    // Query all profiles with the 'PermissionsModifyAllData' permission set to true
    // This will give us a list of profiles that have administrative privileges
    List<Profile> adminProfiles = [SELECT Id, Name FROM Profile WHERE PermissionsModifyAllData = true];

    // Query all users whose profile Ids are in the list of admin profiles
    // This will give us a list of users who have administrative privileges
    List<User> adminUsers = [SELECT Id, Email FROM User WHERE ProfileId IN :adminProfiles];

    // Create an empty list to store the email addresses of the admin users
    List<String> adminEmails = new List<String>();

    // Iterate over the list of admin users and add their email addresses to the list
    for (User user : adminUsers) {
        adminEmails.add(user.Email);
    }

    // Create a new email message
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

    // Set the email addresses of the recipients (admin users)
    email.setToAddresses(adminEmails);

    // Set the subject of the email
    email.setSubject('Your Subject');

    // Set the plain text body of the email
    email.setPlainTextBody('Your Message');

    // Send the email to the list of recipients
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
}
