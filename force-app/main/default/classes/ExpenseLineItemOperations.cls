public with sharing class ExpenseLineItemOperations {
    //inner wrapper class
    public with sharing class ResponseWrapper {
            @InvocableVariable(label='Newly created ExpenseLineItem Record' 
                                description='Newly created ExpenseLineItem Record')  
        public Expense__c newExpenseLineItemRecord;
    }
    //invocable method with JSON as input parameter   
    @InvocableMethod(label='Create ExpenseLineItem  Record' description='Create ExpenseLineItem  Record after parsing data from input JOSN String input.') 
    public static List<ResponseWrapper> createExpenseLineItem(List<String> JSONSting) {
        System.debug('@@@@@@@@JSONSting'+JSON.serialize(JSONSting));
        
        List<ResponseWrapper> responseWrappertList = new List<ResponseWrapper>();
        ResponseWrapper localResponseWrapperObj = new ResponseWrapper();
        List<Expense__c> insertExpenseLineItemList = new List<Expense__c>();
        
        
        // Deserialize into a List of the wrapper class
        List<Expense__c> expenseLineItemList = (List<Expense__c>)JSON.deserialize(JSONSting.get(0), List<Expense__c>.class);
        
        for(Integer count=0;count<expenseLineItemList.size();count++){
            localResponseWrapperObj.newExpenseLineItemRecord = expenseLineItemList.get(count);
            localResponseWrapperObj.newExpenseLineItemRecord.Case__c='500dM00003FuQYwQAN';
            responseWrappertList.add(localResponseWrapperObj);
            insertExpenseLineItemList.add(localResponseWrapperObj.newExpenseLineItemRecord);
        }
        System.debug('@@@@@@@@responseWrappertList-->>'+responseWrappertList);
        System.debug('@@@@@@@@insertExpenseLineItemList-->>'+insertExpenseLineItemList);
        
        insert insertExpenseLineItemList;     
        return responseWrappertList;
    }
}