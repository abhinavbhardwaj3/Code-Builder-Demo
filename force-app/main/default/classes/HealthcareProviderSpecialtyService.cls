public without sharing class HealthcareProviderSpecialtyService {
    @InvocableMethod(label = 'Agentforce - HealthCare - Apex- Get Healthcare Services' description = 'Get All Available Healthcare Services')
    public static List<List<String>> getSpecialtyNames(List<Id> recordIds) {
        Set<String> uniqueNames = new Set<String>();
        List<List<String>> result = new List<List<String>>();

        // Query to get the Specialty Names
        List<HealthcareProviderSpecialty> specialties = [SELECT Name FROM HealthcareProviderSpecialty WHERE Id IN :recordIds];

        for (HealthcareProviderSpecialty specialty : specialties) {
            List<String> names = specialty.Name.split(';');
            for (String name : names) {
                uniqueNames.add(name.trim());
            }
        }

        result.add(new List<String>(uniqueNames));
        return result;
    }
}