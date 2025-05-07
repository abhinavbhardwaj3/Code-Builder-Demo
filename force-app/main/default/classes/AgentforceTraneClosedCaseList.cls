public without sharing class AgentforceTraneClosedCaseList {
 public static List<Response> getClosedCases(List<Request> requests) {
      List<Response> responses = new List<Response>();

      for (Request req : requests) {
          // Query closed cases based on userInput
          List<Case> closedCases = [SELECT Id, CaseNumber, Subject, Status
                                    FROM Case
                                    WHERE Status = 'Closed'];

          Response res = new Response();
          if (!closedCases.isEmpty()) {
              List<String> caseDetails = new List<String>();
              for (Case c : closedCases) {
                  caseDetails.add('CaseNumber: ' + c.CaseNumber + ', Subject: ' + c.Subject);
              }
              res.closedCaseList = String.join(caseDetails, '\n');
          } else {
              res.closedCaseList = 'No closed cases found matching the input.';
          }
          responses.add(res);
      }

      return responses;
  }

  public class Request {
      @InvocableVariable
      public String userInput; // Free-text input
  }

  public class Response {
      @InvocableVariable
      public String closedCaseList; // List of closed cases as a string
  }
}