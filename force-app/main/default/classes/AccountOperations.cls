// AccountOperationsController.cls
// This class contains a method to search for an public without sharing class AccountOperations {
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