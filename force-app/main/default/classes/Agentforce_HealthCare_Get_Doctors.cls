public without sharing class Agentforce_HealthCare_Get_Doctors {
    @InvocableMethod(label = 'Agentforce - HealthCare - Apex- Get Healthcare Doctors' description = 'Get All Available Healthcare Service providers')
    public static List<List<HealthcareProviderWrapper>> getHealthcareDoctors(List<Request> requestList) {
        List<List<HealthcareProviderWrapper>> result = new List<List<HealthcareProviderWrapper>>();

        for (Request request : requestList) {
            List<HealthcareProviderWrapper> providers = new List<HealthcareProviderWrapper>();

            // Query to get the HealthcareProviderSpecialty records
            List<HealthcareProviderSpecialty> specialties = [SELECT AccountId, PractitionerId, Id FROM HealthcareProviderSpecialty WHERE Name LIKE :('%' + request.specilityName + '%')];

            Set<Id> practitionerIds = new Set<Id>();
            for (HealthcareProviderSpecialty specialty : specialties) {
                practitionerIds.add(specialty.PractitionerId);
            }

            // Query to get the HealthcareProvider records
            if (!practitionerIds.isEmpty()) {
                List<HealthcareProvider> healthcareProviders = [SELECT Id, Name FROM HealthcareProvider WHERE PractitionerId IN :practitionerIds];

                for (HealthcareProvider provider : healthcareProviders) {
                    providers.add(new HealthcareProviderWrapper(provider.Id, provider.Name));
                }
            }

            result.add(providers);
        }

        return result;
    }

    public class Request {
        @InvocableVariable(required = true)
        public String specilityName;
    }

    public class HealthcareProviderWrapper {
        @InvocableVariable
        public Id providerId;
        @InvocableVariable
        public String providerName;

        public HealthcareProviderWrapper(Id providerId, String providerName) {
            this.providerId = providerId;
            this.providerName = providerName;
        }
    }
}