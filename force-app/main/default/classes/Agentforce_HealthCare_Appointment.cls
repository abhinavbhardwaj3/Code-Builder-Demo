public without sharing class Agentforce_HealthCare_Appointment {
    @InvocableMethod(label = 'Agentforce - HealthCare - Apex - Get Healthcare Scheduled Appointment' description = 'Scheduled appointment for patient with a doctor (healthcare specialist)')
    public static List<AppointmentResult> createScheduledAppointment(List<AppointmentRequest> requests) {
        List<AppointmentResult> results = new List<AppointmentResult>();

        // Validate input
        if (requests == null || requests.isEmpty()) {
            throw new IllegalArgumentException('Request list cannot be null or empty.');
        }

        for (AppointmentRequest req : requests) {
            try {
                // Validate individual request fields
                if (req.patientId == null || req.providerId == null || req.appointmentDate == null || req.symptomsTime == null) {
                    throw new IllegalArgumentException('Missing required fields in AppointmentRequest.');
                }

                // Get Patient Info
                User patient = [SELECT Id, Name, Contact.Email FROM User WHERE Id = :req.patientId LIMIT 1];
                system.debug('SELECT Id, Name, Contact.Email FROM User WHERE Id = :req.patientId LIMIT 1'  + req.patientId);
                // Get Doctor Info
                HealthcareProvider provider = [SELECT Id, Name, PractitionerId FROM HealthcareProvider WHERE Id = :req.providerId LIMIT 1];
                system.debug('SELECT Id, Name, PractitionerId FROM HealthcareProvider WHERE Id = :req.providerId LIMIT 1'  + req.providerId);
                // Get Service Info
                HealthcareProviderSpecialty specialty = [
                    SELECT Id, Name
                    FROM HealthcareProviderSpecialty
                    WHERE PractitionerId = :provider.PractitionerId
                    LIMIT 1
                ];
                system.debug('SELECT Id, Name FROM HealthcareProviderSpecialty WHERE PractitionerId = :provider.PractitionerId  LIMIT 1'  + provider.PractitionerId);

                // Create Scheduled_Appointment__c record
                Scheduled_Appointment__c appointment = new Scheduled_Appointment__c();
                appointment.Appointment_Date__c = req.appointmentDate;
                appointment.Description__c = String.format(
                    '{0} has been experiencing issues since {1} and has scheduled an appointment with {2} for {3}.',
                    new List<String>{patient.Name, req.symptomsTime, provider.Name, specialty.Name}
                );
                appointment.Healthcare_Provider_Specialty__c = specialty.Id;
                appointment.Healthcare_Provider__c = req.providerId;
                appointment.Patient__c = req.patientId;
                appointment.Appointment_status__c = 'Scheduled';

                insert appointment;
                /*
                    // Create Task for the provider
                    Task providerTask = new Task();
                    providerTask.Subject = 'New Appointment Scheduled';
                    providerTask.WhatId = appointment.Id;
                    providerTask.OwnerId = provider.PractitionerId;
                    providerTask.Description = String.format(
                    'Appointment scheduled for patient {0} with You (Dr. {1}) on {2}. Symptoms started since {3}.',
                    new List<String>{patient.Name, provider.Name, req.appointmentDate.format(), req.symptomsTime}
                    );
                    providerTask.Status = 'Not Started';
                    providerTask.Priority = 'Normal';

                    insert providerTask;
                    */

                // Add result to the list
                results.add(new AppointmentResult(appointment.Id, null));

                // Convert appointment date to IST
                DateTime appointmentDateIST = req.appointmentDate.addHours(5).addMinutes(30);
                String appointmentDateISTFormatted = appointmentDateIST.format('yyyy-MM-dd HH:mm:ss', 'IST');

                // Send email to the patient
                system.debug('Sending mail to patient'  + patient.Contact.Email);

                if (patient.Contact.Email != null) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[] { patient.Contact.Email });
                    email.setSubject('Appointment Scheduled');
                    email.setPlainTextBody(String.format(
                        'Dear {0},\n\nYour appointment with Dr. {1} has been scheduled for {2}.\n\nBest regards,\nHealthCare Team',
                        new List<String>{patient.Name, provider.Name, appointmentDateISTFormatted}
                    ));
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                }

            } catch (Exception ex) {
                // Log error for debugging and continue processing other request
                System.debug('Error creating appointment for request: ' + req + ' - ' + ex.getMessage());
            }
        }

        return results;
    }

    // Define the data structure for input variables
    public class AppointmentRequest {
        @InvocableVariable(required=true)
        public DateTime appointmentDate;

        @InvocableVariable(required=true)
        public Id patientId;

        @InvocableVariable(required=true)
        public Id providerId;

        @InvocableVariable(required=true)
        public String symptomsTime;
    }

    // Define the data structure for output variables
    public class AppointmentResult {
        @InvocableVariable
        public Id appointmentId;

        @InvocableVariable
        public Id taskId;

        public AppointmentResult(Id appointmentId, Id taskId) {
            this.appointmentId = appointmentId;
            this.taskId = taskId;
        }
    }
}