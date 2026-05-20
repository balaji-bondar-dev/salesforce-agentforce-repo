public with sharing class MCPAccountOperations {
    @AuraEnabled
    public static string searchAccountRecord(String accountId){
        try {
            Account account =[SELECT Id, Name, AccountNumber, Type FROM Account WHERE Id = :accountId LIMIT 1];
            return account.Name;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}