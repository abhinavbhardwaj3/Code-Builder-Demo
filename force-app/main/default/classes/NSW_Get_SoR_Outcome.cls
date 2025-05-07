public without sharing class NSW_Get_SoR_Outcome {
    @InvocableMethod(label='NSW Get SoR Outcome' description='Search for the most relevant record based on the provided input fields.')
    public static List<NSW_ResultWrapper> getSoROutcome(List<NSW_Input> inputs) {
        List<NSW_ResultWrapper> results = new List<NSW_ResultWrapper>();
        
        for (NSW_Input input : inputs) {
            List<NSW_FINAL_CRM_SCRIPTING__c> queryResults;
            
            if (input.Scripting_Id != null) {
                queryResults = [SELECT CRM_SCRIPTING_ID__c, COMPONENT_CODE__c, COMPONENT_NAME__c, COMPONENT_TYPE_CODE__c, COMPONENT_TYPE__c, SUB_COMPONENT_CODE__c, SUB_COMPONENT_NAME__c, SCRIPTING_OCCUPANT_QUESTION__c, Outcome__c 
                                FROM NSW_FINAL_CRM_SCRIPTING__c 
                                WHERE CRM_SCRIPTING_ID__c = :input.Scripting_Id OR Name = :input.Scripting_Id];
            } else {
                queryResults = new List<NSW_FINAL_CRM_SCRIPTING__c>();
            }
            
            for (NSW_FINAL_CRM_SCRIPTING__c record : queryResults) {
                NSW_ResultWrapper result = new NSW_ResultWrapper();
                result.CRM_SCRIPTING_ID = record.CRM_SCRIPTING_ID__c;
                result.COMPONENT_CODE = record.COMPONENT_CODE__c;
                result.COMPONENT_NAME = record.COMPONENT_NAME__c;
                result.COMPONENT_TYPE_CODE = record.COMPONENT_TYPE_CODE__c;
                result.COMPONENT_TYPE = record.COMPONENT_TYPE__c;
                result.SUB_COMPONENT_CODE = record.SUB_COMPONENT_CODE__c;
                result.SUB_COMPONENT_NAME = record.SUB_COMPONENT_NAME__c;
                result.SCRIPTING_OCCUPANT_QUESTION = record.SCRIPTING_OCCUPANT_QUESTION__c;
                result.Outcome = record.Outcome__c;
                results.add(result);
            }
        }
        
        return results;
    }
    
    public class NSW_Input {
        @InvocableVariable(required=true)
        public String Scripting_Id;
    }
    
    public class NSW_ResultWrapper {
        @InvocableVariable
        public String CRM_SCRIPTING_ID;
        @InvocableVariable
        public String COMPONENT_CODE;
        @InvocableVariable
        public String COMPONENT_NAME;
        @InvocableVariable
        public String COMPONENT_TYPE_CODE;
        @InvocableVariable
        public String COMPONENT_TYPE;
        @InvocableVariable
        public String SUB_COMPONENT_CODE;
        @InvocableVariable
        public String SUB_COMPONENT_NAME;
        @InvocableVariable
        public String SCRIPTING_OCCUPANT_QUESTION;
        @InvocableVariable
        public String Outcome;
    }
}