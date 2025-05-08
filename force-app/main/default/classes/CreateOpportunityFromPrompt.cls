public class CreateOpportunityFromPrompt {
    @InvocableMethod(label='Agentforce - Create Opportunity From Prompt' description='Creates opportunities from provided JSON data.')
    public static List<Response> createOpportunities(List<Request> requests) {
        if (requests == null || requests.isEmpty()) {
            throw new IllegalArgumentException('Input requests are required and cannot be null or empty.');
        }

        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        Integer totalRecords = 0;
        Integer successfullyCreated = 0;

        for (Request request : requests) {
            try {
                if (String.isBlank(request.userRequest)) {
                    throw new IllegalArgumentException('Each userRequest string must be non-blank.');
                }

                // Parse the JSON input
                Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(request.userRequest);
                if (parsedJson.containsKey('data') && parsedJson.get('data') != null) {
                    List<Object> dataList = (List<Object>) parsedJson.get('data');
                    totalRecords += dataList.size();

                    for (Object dataObj : dataList) {
                        Map<String, Object> data = (Map<String, Object>) dataObj;

                        Opportunity opp = new Opportunity();
                        opp.Name = data.containsKey('Subject') && String.isNotBlank((String) data.get('Subject'))
                            ? (String) data.get('Subject')
                            : 'Opportunity from case record'; // Default Name
                        opp.StageName = data.containsKey('StageName') && String.isNotBlank((String) data.get('StageName'))
                            ? (String) data.get('StageName')
                            : 'Qualification'; // Default StageName
                        opp.CloseDate = data.containsKey('CloseDate') && data.get('CloseDate') != null
                            ? Date.valueOf((String) data.get('CloseDate'))
                            : Date.today().addDays(5); // Default CloseDate
                        opp.Description = data.containsKey('Reason') ? (String) data.get('Reason') : null;

                        // Optional: Add other mandatory fields here if required
                        // opp.SomeMandatoryField__c = ...;

                        opportunitiesToInsert.add(opp);
                    }
                } else {
                    throw new IllegalArgumentException('JSON input must contain a "data" key with valid content.');
                }
            } catch (Exception e) {
                // Log or handle individual record errors if needed
                System.debug('Error processing JSON input: ' + e.getMessage());
            }
        }

        if (!opportunitiesToInsert.isEmpty()) {
            try {
                insert opportunitiesToInsert;
                successfullyCreated = opportunitiesToInsert.size();
            } catch (Exception e) {
                // Handle bulk insert errors
                System.debug('Error inserting opportunities: ' + e.getMessage());
            }
        }

        Response response = new Response();
        response.responseText = 'Out of ' + totalRecords + ' records, ' + successfullyCreated + ' opportunities were successfully created.';
        return new List<Response>{ response };
    }

    public class Request {
        @InvocableVariable(required=true)
        public String userRequest;
    }

    public class Response {
        @InvocableVariable
        public String responseText;
    }
}