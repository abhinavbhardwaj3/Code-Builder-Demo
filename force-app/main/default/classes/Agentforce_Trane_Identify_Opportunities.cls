public without sharing class Agentforce_Trane_Identify_Opportunities {

    @InvocableMethod(label='Agentforce - Trane - Closed Case List' description='Retrieve all closed cases based on user input')
    public static List<Response> getClosedCases(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            // Use userInput to filter closed cases
            List<Case> closedCases = [SELECT Id, CaseNumber, Subject, Status
                                      FROM Case
                                      WHERE Status = 'Closed'];

            Response res = new Response();
            if (!closedCases.isEmpty()) {
                List<String> caseDetails = new List<String>();
                for (Case c : closedCases) {
                    caseDetails.add('CaseNumber: ' + c.CaseNumber + ', Subject: ' + c.Subject);
                }
                res.Prompt = String.join(caseDetails, '\n');
            } else {
                res.Prompt = 'No closed cases found matching the input.';
            }
            responses.add(res);
        }

        return responses;
    }

    public class Request {
        @InvocableVariable(required=true)
        public String userInput; // Free-text input
    }

    public class Response {
        @InvocableVariable
        public String Prompt; // List of closed cases as a string
    }
}