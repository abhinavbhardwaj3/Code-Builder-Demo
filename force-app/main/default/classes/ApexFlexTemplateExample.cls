//No need of CapabilityType on the InvocableMethod annotation
public class ApexFlexTemplateExample {
    @InvocableMethod(label='Open Cases')
    public static List<Response> getPrompt(List<Request> requests) {
        List<Response> responses = new List<Response>();
        List<Case> closedCases = [SELECT Id, Subject FROM Case WHERE IsClosed = true];
        
        for (Case c : closedCases) {
            Response res = new Response();
            res.Prompt = 'Case ID : ' + c.Id + '\nCase Subject : ' + c.Subject;
            responses.add(res);
        }
        
        return responses;
    }

    public class Request {
        // Ensure the Type and API Name of all variables match the template
        @InvocableVariable(required=true)
        public Contact Contact_Details;
    }
    public class Response {
        @InvocableVariable
        public String Prompt;
    }
}