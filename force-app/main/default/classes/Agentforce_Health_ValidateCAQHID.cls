public without sharing class Agentforce_Health_ValidateCAQHID {

    // Request Class
    public class CAQHIDValidationRequest {
        @InvocableVariable(required = true)
        public String caqhId; // Input CAQH Identifier
    }

    // Response Class
    public class CAQHIDValidationResponse {
        @InvocableVariable
        public Boolean isValidCAQHID; // True if CAQH Identifier is unique, False otherwise
    }

    // Invocable Method
    @InvocableMethod(label = 'Agentforce - Health - Apex - Validate CAQH Identifier' description = 'Validates the uniqueness of a CAQH Identifier in HealthcareProvider object.')
    public static List<CAQHIDValidationResponse> validateCAQHID(List<CAQHIDValidationRequest> requests) {
        List<CAQHIDValidationResponse> responses = new List<CAQHIDValidationResponse>();

        // Iterate through each request
        for (CAQHIDValidationRequest request : requests) {
            CAQHIDValidationResponse response = new CAQHIDValidationResponse();

            // Query to check if CAQH Identifier exists in HealthcareProvider object
            Integer existingRecordsCount = [
                SELECT COUNT() 
                FROM HealthcareProvider 
                WHERE CaqhIdentifier = :request.caqhId
            ];

            // Set the response based on existence
            response.isValidCAQHID = (existingRecordsCount == 0);
            responses.add(response);
        }
        return responses;
    }
}