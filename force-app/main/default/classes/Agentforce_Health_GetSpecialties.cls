public without sharing class Agentforce_Health_GetSpecialties {

    @InvocableMethod(label = 'Agentforce - Health - Get All Specialties' description = 'Returns all unique specialties from the Specialty picklist field on the Lead object.')
    public static List<SpecialtyResult> getSpecialties(List<Request> requests) {
        // Validate input
        if (requests == null || requests.isEmpty()) {
            throw new IllegalArgumentException('Messaging session ID is required.');
        }

        // Extract the messaging session ID (not used in logic, but required as input)
        for (Request request : requests) {
            System.debug('Messaging Session ID: ' + request.messagingSessionId);
        }

        // Prepare results
        List<SpecialtyResult> results = new List<SpecialtyResult>();

        // Get the picklist values
        Schema.DescribeFieldResult fieldResult = Lead.Specialty.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

        // Add each specialty to the result
        for (Schema.PicklistEntry entry : picklistEntries) {
            results.add(new SpecialtyResult(entry.getLabel()));
        }

        return results;
    }

    // Inner class to structure the response
    public class SpecialtyResult {
        @InvocableVariable(label = 'Specialty' description = 'The specialty name' required = true)
        public String specialty;

        public SpecialtyResult(String specialty) {
            this.specialty = specialty;
        }
    }

    // Input class to accept messaging session ID
    public class Request {
        @InvocableVariable(label = 'Messaging Session ID' description = 'The ID of the current messaging session' required = true)
        public Id messagingSessionId;
    }
}