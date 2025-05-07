public without sharing class Agentforce_SmartSupport_SendOtpMail {
    
    @InvocableMethod(label='Agentforce - SmartSupport - Apex - Send OTP Mail' description='Send a mail with OTP to given Email address')
    public static List<Response> sendOtpMail(List<Request> requests) {
        List<Response> results = new List<Response>();
        for (Request req : requests) {
            Boolean isSuccess = sendEmail(req.EmailAddress, req.OTPValue);
            results.add(new Response(isSuccess));
        }
        return results;
    }

    private static Boolean sendEmail(String emailAddress, String otpValue) {
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { emailAddress });
            mail.setSubject('Your One-Time Password (OTP)');
            mail.setPlainTextBody('Dear User,\n\nAs per your request, please use the following One-Time Password (OTP) to proceed with your Philips support request:\n\n' + otpValue + '\n\nIf you did not request this, please ignore this email.\n\nThank you,\nPhilips Support Team');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            return true;
        } catch (Exception e) {
            System.debug('Error sending email: ' + e.getMessage());
            return false;
        }
    }

    public class Request {
        @InvocableVariable(required=true)
        public String EmailAddress;
        
        @InvocableVariable(required=true)
        public String OTPValue;
    }

    public class Response {
        @InvocableVariable
        public Boolean isSuccess;

        public Response(Boolean isSuccess) {
            this.isSuccess = isSuccess;
        }
    }
}