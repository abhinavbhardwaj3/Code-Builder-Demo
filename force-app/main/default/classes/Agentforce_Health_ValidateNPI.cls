public without sharing class Agentforce_Health_ValidateNPI {
    // Wrapper class to handle input and output for InvocableMethod
    public class NPIValidationRequest {
        @InvocableVariable(
            required = true 
            description='10 digit numrical NPI value which need to be unique in the system'
        )
        public String npi; // Input NPI value
    }
    
    public class NPIValidationResponse {
         @InvocableVariable(
            description='boolean value, False if we allreay have this NPI in ORG else true for valid'
        )
        public Boolean isValidNPI; // Output boolean indicating NPI validity
    }
    
    @InvocableMethod(label='Agentforce - Health - Apex - Validate NPI' description='Check if the provided NPI exists in HealthcareProviderNpi object')
    public static List<NPIValidationResponse> validateNPI(List<NPIValidationRequest> requests) {
        // List to hold responses
        List<NPIValidationResponse> responses = new List<NPIValidationResponse>();
        
        // Iterate through each request
        for (NPIValidationRequest request : requests) {
            NPIValidationResponse response = new NPIValidationResponse();
            response.isValidNPI = true; // Default to true
            
            // Query the HealthcareProviderNpi object
            List<HealthcareProviderNpi> existingRecords = [
                SELECT Id 
                FROM HealthcareProviderNpi 
                WHERE Npi = :request.npi
                LIMIT 1
            ];
            
            // If a record exists, mark as invalid
            if (!existingRecords.isEmpty()) {
                response.isValidNPI = false;
            }
            
            // Add response to the list
            responses.add(response);
        }
        
        return responses;
    }
}