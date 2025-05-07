public without sharing class Agentforce_HealthCare_ModifyAppointment {
    @InvocableMethod(label = 'Agentforce - HealthCare - Apex - Modify Appointment' description = 'Modify appointment for patient with a doctor, cancel it or provide feedback')
    public static List<AppointmentModificationResult> modifyAppointment(List<AppointmentModificationRequest> requests) {
        List<AppointmentModificationResult> results = new List<AppointmentModificationResult>();

        for (AppointmentModificationRequest req : requests) {
            try {
                // Get the appointment record
                Scheduled_Appointment__c appointment = [
                    SELECT Id, Appointment_status__c, Appointment_Date__c, Patient_Comment__c, Patient__r.Email, Patient__r.Name
                    FROM Scheduled_Appointment__c
                    WHERE Id = :req.appointmentId
                    LIMIT 1
                ];

                // Update fields based on input
                if (req.appointmentDate != null) {
                    appointment.Appointment_Date__c = req.appointmentDate;
                }
                if (req.appointmentStatus != null && req.appointmentStatus == 'Cancelled') {
                    appointment.Appointment_status__c = req.appointmentStatus;
                }
                if (req.appointmentFeedback != null) {
                    appointment.Patient_Comment__c = req.appointmentFeedback;
                }

                update appointment;

                // Add updated appointment to results
                results.add(new AppointmentModificationResult(appointment));

                // Send email to the patient
                if (appointment.Patient__r.Email != null) {
                    String subject = 'Appointment Modified';
                    String body = 'Dear ' + appointment.Patient__r.Name + ',\n\n' +
                                  'Your appointment has been modified. Here are the details:\n' +
                                  'Appointment Date: ' + (req.appointmentDate != null ? req.appointmentDate.format('yyyy-MM-dd HH:mm:ss', 'IST') : appointment.Appointment_Date__c.format('yyyy-MM-dd HH:mm:ss', 'IST')) + '\n' +
                                  'Status: ' + appointment.Appointment_status__c + '\n' +
                                  'Feedback: ' + (req.appointmentFeedback != null ? req.appointmentFeedback : appointment.Patient_Comment__c) + '\n\n' +
                                  'Best regards,\nHealthCare Team';

                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[] { appointment.Patient__r.Email });
                    email.setSubject(subject);
                    email.setPlainTextBody(body);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                }

            } catch (Exception ex) {
                // Log error and add null to results
                System.debug('Error modifying appointment: ' + ex.getMessage());
                results.add(new AppointmentModificationResult(null));
            }
        }

        return results;
    }

    // Define the data structure for input variables
    public class AppointmentModificationRequest {
        @InvocableVariable(required=true)
        public Id appointmentId;

        @InvocableVariable
        public DateTime appointmentDate;

        @InvocableVariable
        public String appointmentFeedback;

        @InvocableVariable
        public String appointmentStatus;
    }

    // Define the data structure for output variables
    public class AppointmentModificationResult {
        @InvocableVariable
        public Scheduled_Appointment__c appointment;

        public AppointmentModificationResult(Scheduled_Appointment__c appointment) {
            this.appointment = appointment;
        }
    }
}