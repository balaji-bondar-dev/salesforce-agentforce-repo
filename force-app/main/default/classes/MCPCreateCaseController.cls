@RestResource(urlMapping='/mcp/createCase')
global with sharing class MCPCreateCaseController {
   
    global class ResponseWrapper{
        String recordNumber;
        String message;
        public ResponseWrapper(String recordNumber, String message){
            this.recordNumber = recordNumber;
            this.message = message;
        }
    }

    @HttpPost 
    global static ResponseWrapper createCaseRecord(String subject,String description, String priority) {
        Case caseObj = new Case();
        caseObj.subject = subject;
        caseObj.description = description;
        caseObj.priority = priority;
        insert caseObj;
        Case newCaseObj = [select Id,caseNumber,subject,description,priority FROM Case where Id=:caseObj.Id limit 1];
        return new ResponseWrapper(newCaseObj.CaseNumber, 'Case created successfully.');
    }
}