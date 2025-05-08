public without sharing class Agentforce_HealthCare_GetAppointments {
    @InvocableMethod(label = 'Agentforce - HealthCare - Apex - Get Appointments' description = 'Get all scheduled appointments for a patient')
    public static List<AppointmentDetails> getAppointments(List<AppointmentRequest> requests) {
        List<AppointmentDetails> results = new List<AppointmentDetails>();
        
        for (AppointmentRequest req : requests) {
            // Get all appointments for the patient
            List<Scheduled_Appointment__c> appointments = [
                SELECT Id, Appointment_status__c, Appointment_Date__c, Patient_Comment__c, Patient__c, Healthcare_Provider__r.Name, Patient__r.Name 
                FROM Scheduled_Appointment__c 
                WHERE Patient__c = :req.patientId
            ];
            
            // Add appointment details to results
            for (Scheduled_Appointment__c appointment : appointments) {
                results.add(new AppointmentDetails(appointment));
            }
        }
        
        return results;
    }
    
    // Define the data structure for input variables
    public class AppointmentRequest {
        @InvocableVariable(required=true)
        public Id patientId;
    }
    
    // Define the data structure for output variables
    public class AppointmentDetails {
        @InvocableVariable
        public Id appointmentId;
        
        @InvocableVariable
        public String appointmentStatus;
        
        @InvocableVariable
        public DateTime appointmentDate;
        
        @InvocableVariable
        public String patientComment;
        
        @InvocableVariable
        public String patientName;
        
        @InvocableVariable
        public String providerName;
        
        public AppointmentDetails(Scheduled_Appointment__c appointment) {
            this.appointmentId = appointment.Id;
            this.appointmentStatus = appointment.Appointment_status__c;
            this.appointmentDate = appointment.Appointment_Date__c;
            this.patientComment = appointment.Patient_Comment__c;
            this.patientName = appointment.Patient__r.Name;
            this.providerName = appointment.Healthcare_Provider__r.Name;
        }
    }
}