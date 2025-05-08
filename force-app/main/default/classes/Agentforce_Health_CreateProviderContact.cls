public without sharing class Agentforce_Health_CreateProviderContact {
    public List<String> validSpecialties { get; private set; }
    
    public Agentforce_Health_CreateProviderContact() {
        validSpecialties = getSpecialtyPicklistValues();
    }
    
    private List<String> getSpecialtyPicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Lead.Specialty.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.add(entry.getLabel());
        }
        
        return picklistValues;
    }
    
    public class CreateProviderRequest {
        @InvocableVariable(required = true)
        public String firstName;
        
        @InvocableVariable(required = true)
        public String lastName;
        
        @InvocableVariable(required = true)
        public String phone;
        
        @InvocableVariable(required = true)
        public String email;
        
        @InvocableVariable(required = true)
        public String npi;
        
        @InvocableVariable(required = true)
        public String caqhId;
        
        @InvocableVariable(required = true)
        public String specialty;
        
        @InvocableVariable(required = true)
        public String specialtyRole;
    }
    
    public class CreateProviderResponse {
        @InvocableVariable
        public Id leadId;
        
        @InvocableVariable
        public Id providerDetailsId;
    }
    
    @InvocableMethod(label = 'Agentforce - Health - Create Provider Records' description = 'Creates a Lead and Provider record.')
    public static List<CreateProviderResponse> createProvider(List<CreateProviderRequest> requests) {
        List<CreateProviderResponse> responses = new List<CreateProviderResponse>();
        
        Agentforce_Health_CreateProviderContact handler = new Agentforce_Health_CreateProviderContact();
        
        for (CreateProviderRequest request : requests) {
            CreateProviderResponse response = new CreateProviderResponse();
            
            try {
                // Step 1: Handle Lead
                Lead leadRecord;
                List<Lead> existingLeads = [
                    SELECT Id, FirstName, LastName, Phone, Email, Specialty
                    FROM Lead
                    WHERE Email = :request.email LIMIT 1
                ];
                if (!existingLeads.isEmpty()) {
                    leadRecord = existingLeads[0];
                } else {
                    String validSpecialty = '';
                    if (String.isNotBlank(request.specialty)) {
                        List<String> specialties = request.specialty.split(',');
                        for (String specialty : specialties) {
                            if (handler.validSpecialties.contains(specialty.trim())) {
                                validSpecialty += (String.isBlank(validSpecialty) ? '' : ';') + specialty.trim();
                            }
                        }
                    }
                    
                    leadRecord = new Lead(
                        FirstName = request.firstName,
                        LastName = request.lastName,
                        Phone = request.phone,
                        Email = request.email,
                        Company = 'Individual Provider',
                        Status = 'Open - Not Contacted',
                        Specialty = validSpecialty
                    );
                    insert leadRecord;
                }
                response.leadId = leadRecord.Id;
                
                // Step 2: Create Provider_Details__c
                Provider_Details__c providerDetails = new Provider_Details__c(
                    CAQH_ID__c = request.caqhId,
                    Lead_ID__c = response.leadId,
                    Email__c = request.email,
                    NPI__c = request.npi,
                    Phone_Number__c = request.phone,
                    First_Name__c = request.firstName,
                    Last_Name__c = request.lastName,
                    Provider_Name__c = request.firstName + ' ' + request.lastName,
                    Specialty__c = request.specialty,
                    Specialty_Role__c = request.specialtyRole,
                    Status__c = 'Pending'
                );
                insert providerDetails;
                response.providerDetailsId = providerDetails.Id;
                
            } catch (Exception e) {
                System.debug('Error creating records: ' + e.getMessage());
            }
            
            responses.add(response);
        }
        
        return responses;
    }
}