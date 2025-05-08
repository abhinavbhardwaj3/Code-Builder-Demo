public class Agentforce_Health_UpdateUserDetails {
    public static void updateUserPasswords() {
      
        // Query to get the Users with the specified Profile
        List<User> usersToUpdate = [SELECT Id, Name, Contact.Name, username, Profile.name FROM User where ContactId != '' and Profile.Name ='SDO-Customer Community Plus'];
        
        // Update the password for each user
        for (User user : usersToUpdate) {
            system.debug('Updating password for User ' + user.Name + ' with username ' + user.Username);
            try {
                System.setPassword(user.Id, 'SEI@1234');
            } catch (Exception ex) {
                System.debug('Error updating password for user ' + user.Id + ': ' + ex.getMessage());
            }
        }
    }
    
    public static void updateUserName() {
        // Query to get the Users with the specified Profile
        List<User> usersToUpdate = [SELECT Id, Name, FirstName, LastName, Email FROM User where ContactId != '' and Profile.Name ='SDO-Customer Community Plus'];
        
        // Update the username for each user
        for (User user : usersToUpdate) {
            String newUserName = user.FirstName + '_' + user.LastName + '_' + user.Id + '@agentforcedemo.com';
            system.debug('Updating Username for User ' + user.Name + ' to ' + newUserName);
            user.Username = newUserName;
            user.Email = newUserName; // Sync Email with Username
        }
        
        try {
            update usersToUpdate;
        } catch (DmlException ex) {
            System.debug('Error updating usernames: ' + ex.getMessage());
        }
    }
}