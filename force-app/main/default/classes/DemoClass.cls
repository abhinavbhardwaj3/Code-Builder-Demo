public class DemoClass {
    // Fetched from org at 1pm. from desktop
    /**
 * Returns the number of opportunities for a given Account ID.
 *
 * @param demoAccountId The ID of the Account for which to count opportunities.
 * @return The number of opportunities associated with the specified Account.
 */
public static Integer demoGetNumberOfOpportunities(Id demoAccountId) {
    // Query the number of opportunities for the specified Account ID using user-mode data operations.
    Integer demoNumberOfOpportunities = [
        SELECT COUNT()
        FROM Opportunity
        WHERE AccountId = :demoAccountId
        WITH USER_MODE
    ];
    }
    return demoNumberOfOpportunities;
}