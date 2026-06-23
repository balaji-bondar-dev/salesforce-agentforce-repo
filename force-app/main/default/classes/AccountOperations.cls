/**
 * Contains operations against the Account sObject.
 */
public without sharing class AccountOperations {

    @AuraEnabled
    public static String searchAccountRecord(String accountId) {
        try {
            Account account = [
                SELECT Id, Name, AccountNumber, Type
                FROM Account
                WHERE Id = :accountId
                LIMIT 1
            ];
            return account.Name;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}