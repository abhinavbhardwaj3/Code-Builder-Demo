public without sharing class NSW_Get_Service_Item {
    @InvocableMethod(label='NSW Get Service Item' description='Search for records based on the provided Service Item Code.')
    public static List<NSW_ResultWrapper> getServiceItem(List<NSW_Input> inputs) {
        List<NSW_ResultWrapper> results = new List<NSW_ResultWrapper>();
        
        for (NSW_Input input : inputs) {
            List<NSW_SUI_Service_Catalogue__c> queryResults;
            
            if (input.Service_Item_Code != null) {
                queryResults = [SELECT Activity_Type__c, Component_Name__c, Component_Type__c, Finance_Category__c, Service_Item_Code__c, Service_Item_Long_Description__c, Service_Item_Short_Description__c, Name, Trade_Name__c, Work_Classification__c, Work_Priority__c, Work_Program__c 
                                FROM NSW_SUI_Service_Catalogue__c 
                                WHERE Service_Item_Code__c = :input.Service_Item_Code];
            } else {
                queryResults = new List<NSW_SUI_Service_Catalogue__c>();
            }
            
            for (NSW_SUI_Service_Catalogue__c record : queryResults) {
                NSW_ResultWrapper result = new NSW_ResultWrapper();
                result.Activity_Type = record.Activity_Type__c;
                result.Component_Name = record.Component_Name__c;
                result.Component_Type = record.Component_Type__c;
                result.Finance_Category = record.Finance_Category__c;
                result.Service_Item_Code = record.Service_Item_Code__c;
                result.Service_Item_Long_Description = record.Service_Item_Long_Description__c;
                result.Service_Item_Short_Description = record.Service_Item_Short_Description__c;
                result.SUI_Service_Catalogue_Id = record.Name;
                result.Trade_Name = record.Trade_Name__c;
                result.Work_Classification = record.Work_Classification__c;
                result.Work_Priority = record.Work_Priority__c;
                result.Work_Program = record.Work_Program__c;
                results.add(result);
            }
        }
        
        return results;
    }
    
    public class NSW_Input {
        @InvocableVariable(required=true)
        public String Service_Item_Code;
    }
    
    public class NSW_ResultWrapper {
        @InvocableVariable
        public String Activity_Type;
        @InvocableVariable
        public String Component_Name;
        @InvocableVariable
        public String Component_Type;
        @InvocableVariable
        public String Finance_Category;
        @InvocableVariable
        public String Service_Item_Code;
        @InvocableVariable
        public String Service_Item_Long_Description;
        @InvocableVariable
        public String Service_Item_Short_Description;
        @InvocableVariable
        public String SUI_Service_Catalogue_Id;
        @InvocableVariable
        public String Trade_Name;
        @InvocableVariable
        public String Work_Classification;
        @InvocableVariable
        public String Work_Priority;
        @InvocableVariable
        public String Work_Program;
    }
}