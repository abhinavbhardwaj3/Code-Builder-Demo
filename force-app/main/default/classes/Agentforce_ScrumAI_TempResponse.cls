public without sharing class Agentforce_ScrumAI_TempResponse {
    public static String convertToPlainText(String htmlString) {
        if (htmlString == null ) {
            return '';
        }

        // Replace all HTML tags with an empty string
        String plainText = htmlString.replaceAll('<[^>]*>', '');

        // Optional: Decode common HTML entities like &amp;, &lt;, etc.
        plainText = plainText.replace('&amp;', '&');
        plainText = plainText.replace('&lt;', '<');
        plainText = plainText.replace('&gt;', '>');
        plainText = plainText.replace('&quot;', '"');
        plainText = plainText.replace('&apos;', '\'');
        plainText = plainText.replace('&#39;', '\'');

        return plainText;
    }
    public static String getTempResponse(String requestType){
        String Response = [SELECT Id,AI_Response__c from Scrum_AI_Conversation__c where Conversation_type__c =:requestType and Use_as_Temp_Response__c = true LIMIT 1].AI_Response__c;
        if(requestType=='Generic'){
            Response = Agentforce_ScrumAI_TempResponse.convertToPlainText(Response);
        }
        return Response;
    }
}