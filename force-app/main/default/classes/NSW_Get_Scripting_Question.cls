public without sharing class NSW_Get_Scripting_Question {
    @InvocableMethod(label='NSW Get Scripting Question' description='Search for the most relevant record based on the provided input fields.')
    public static List<NSW_ResultWrapper> getScriptingQuestion(List<NSW_Input> inputs) {
        List<NSW_ResultWrapper> results = new List<NSW_ResultWrapper>();
        
        for (NSW_Input input : inputs) {
            List<NSW_ALL_COMPONENT__c> queryResults;
            
            if (input.Component_Id != null && input.Component_Id != 'NA') {
                String soqlQuery = 'SELECT ID__c, LOCATION_COMPONENT__c, Location_COMPONENT_TYPE__c, SCRIPTING_QUESTION__c, Action_Outcome__c, NEXT_PROCESS__c, SoR_Outcome__c ' +
                                   'FROM NSW_ALL_COMPONENT__c ' +
                                   'WHERE Name = :input.Component_Id';
                System.debug('SOQL Query: ' + soqlQuery);
                queryResults = Database.query(soqlQuery);
            } else {
                String query = 'SELECT ID__c, LOCATION_COMPONENT__c, Location_COMPONENT_TYPE__c, SCRIPTING_QUESTION__c, Action_Outcome__c, NEXT_PROCESS__c, SoR_Outcome__c FROM NSW_ALL_COMPONENT__c WHERE ';
                List<String> conditions = new List<String>();
                
                if (input.Component_Type_Code != null && input.Component_Type_Code != 'NA') {
                    conditions.add('COMPONENT_TYPE_CODE__c = \'' + input.Component_Type_Code + '\'');
                }
                if (input.Component_Code != null && input.Component_Code != 'NA') {
                    conditions.add('COMPONENT_CODE__c = \'' + input.Component_Code + '\'');
                }
                if (input.Component_Name != null && input.Component_Name != 'NA') {
                    conditions.add('COMPONENT_NAME__c = \'' + input.Component_Name + '\'');
                }
                
                if (conditions.size() > 0) {
                    query += String.join(conditions, ' AND ');
                    System.debug('SOQL Query: ' + query);
                    queryResults = Database.query(query);
                } else {
                    queryResults = new List<NSW_ALL_COMPONENT__c>();
                }
            }
            
            for (NSW_ALL_COMPONENT__c record : queryResults) {
                NSW_ResultWrapper result = new NSW_ResultWrapper();
                result.ID = record.ID__c;
                result.LOCATION_COMPONENT = record.LOCATION_COMPONENT__c;
                result.LOCATION_COMPONENT_TYPE = record.Location_COMPONENT_TYPE__c;
                result.SCRIPTING_QUESTION = record.SCRIPTING_QUESTION__c;
                result.Action_Outcome = record.Action_Outcome__c;
                result.NEXT_PROCESS = record.NEXT_PROCESS__c;
                result.SoR_Outcome = record.SoR_Outcome__c;
                results.add(result);
            }
        }
        
        return results;
    }
    
    public class NSW_Input {
        @InvocableVariable(required=true)
        public String Component_Type_Code;
        @InvocableVariable(required=true)
        public String Component_Code;
        @InvocableVariable(required=true)
        public String Component_Name;
        @InvocableVariable(required=false)
        public String Component_Id;
    }
    
    public class NSW_ResultWrapper {
        @InvocableVariable
        public String ID;
        @InvocableVariable
        public String LOCATION_COMPONENT;
        @InvocableVariable
        public String LOCATION_COMPONENT_TYPE;
        @InvocableVariable
        public String SCRIPTING_QUESTION;
        @InvocableVariable
        public String Action_Outcome;
        @InvocableVariable
        public String NEXT_PROCESS;
        @InvocableVariable
        public String SoR_Outcome;
    }
}