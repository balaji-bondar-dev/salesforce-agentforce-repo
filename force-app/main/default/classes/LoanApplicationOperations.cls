public with sharing class LoanApplicationOperations {
    public with sharing class RequestWrapper {
        @InvocableVariable(label='Loan Application Id' description='This is the loan application id passed by user.' required='true')
        public String loanApplicationId;
        
        @InvocableVariable(label='Loan Type' description='This is the loan type passed by user.' required='true')
        public String loanType;

        @InvocableVariable(label='Interest Rate(APR)' description='This is the  interest rate passed by Agentforce Data Library' required='true')  
        public String interestRateAPR;

        @InvocableVariable(label='Maximum Tenure' description='This is the  maximum tenure passed by Agentforce Data Library' required='true')  
        public String maximumTenure;

        @InvocableVariable(label='Eligiblity Criteria' description='This is the  eligiblity criteria passed by Agentforce Data Library' required='true')  
        public String eligiblityCriteria;

        @InvocableVariable(label='Doucument Checklist' description='This is the  doucument checklist passed by Agentforce Data Library' required='true')  
        public String documentChecklist;
    }
    
    public with sharing class ResponseWrapper {
         @InvocableVariable(label='Updated Loan Appliction Record' 
                                description='updates Loan Application record from the values passed by Agentforce Data Library' 
                                        required='true')  
        public Loan_Application__c updatedLoanApplicationRecord;

    }

    @InvocableMethod (label='Update Loan Application Record' description='updates Loan Application record from the values passed by Agentforce Data Library') 
    public static List<ResponseWrapper> updateLoanApplicationRecord(List<RequestWrapper> requesWrappertList) {
        List<ResponseWrapper> responseWrappertList = new List<ResponseWrapper>();
        ResponseWrapper localResponseWrapperObj = new ResponseWrapper();
        

        Loan_Application__c loanApplicationObj = [select Id,Loan_Type__c,Maximum_Tenure__c,Interest_Rate__c,Processing_Fees__c,Eligibility_Criteria__c,  Document_Checklist__c from Loan_Application__c
                                                  where Id=:requesWrappertList[0].loanApplicationId LIMIT 1];
    
        loanApplicationObj.Loan_Type__c = requesWrappertList[0].loanType;
        loanApplicationObj.Maximum_Tenure__c = requesWrappertList[0].maximumTenure;
        loanApplicationObj.Interest_Rate__c = requesWrappertList[0].interestRateAPR;
        loanApplicationObj.Eligibility_Criteria__c = requesWrappertList[0].eligiblityCriteria;
        loanApplicationObj.Document_Checklist__c = requesWrappertList[0].documentChecklist;
        update loanApplicationObj;
        localResponseWrapperObj.updatedLoanApplicationRecord = loanApplicationObj;
        responseWrappertList.add(localResponseWrapperObj);
        return responseWrappertList;
        }
}