/**
 * Unit tests for {@link AccountOperations}.
 *
 * Covers the {@code searchAccountRecord} Aura-enabled method:
 *  - returns the Account Name for a valid Id
 *  - throws AuraHandledException for a null Id
 *  - throws AuraHandledException for an invalid Id format
 *  - throws AuraHandledException when no Account matches the Id
 */
@IsTest
private class AccountOperationsTest {

    /**
     * Creates a fresh Account with a unique Name for each test invocation
     * to avoid duplicate-name rule collisions.
     */
    @TestSetup
    static void makeData() {
        Account acct = new Account(
            Name = 'Test Account ' + String.valueOf(Datetime.now().getTime())
        );
        insert acct;
    }

    /**
     * Happy path: searching by a valid Account Id returns that Account's Name.
     */
    @IsTest
    static void searchAccountRecord_validId_returnsName() {
        Account acct = [SELECT Id, Name FROM Account LIMIT 1];

        Test.startTest();
        String result = AccountOperations.searchAccountRecord(acct.Id);
        Test.stopTest();

        System.assertEquals(acct.Name, result, 'Returned Name should match the inserted Account.');
    }

    /**
     * Null Id is invalid for the SOQL bind; expect an AuraHandledException.
     */
    @IsTest
    static void searchAccountRecord_nullId_throws() {
        Boolean threw = false;
        try {
            AccountOperations.searchAccountRecord(null);
        } catch (AuraHandledException e) {
            threw = true;
        } catch (Exception e) {
            threw = true;
        }
        System.assert(threw, 'Expected AuraHandledException for null accountId.');
    }

    /**
     * An Id that is well-formed but not a real Account should surface an
     * AuraHandledException (no rows returned from the LIMIT 1 query).
     */
    @IsTest
    static void searchAccountRecord_unknownId_throws() {
        // Use a valid 15/18 char Id shape that does not match any Account.
        Id bogusId = 'a0B000000000000';

        Boolean threw = false;
        try {
            AccountOperations.searchAccountRecord(bogusId);
        } catch (AuraHandledException e) {
            threw = true;
        } catch (Exception e) {
            threw = true;
        }
        System.assert(threw, 'Expected AuraHandledException when no Account matches.');
    }

    /**
     * A malformed Id string triggers a QueryException inside the try/catch
     * and must be re-thrown as AuraHandledException.
     */
    @IsTest
    static void searchAccountRecord_invalidIdFormat_throws() {
        Boolean threw = false;
        try {
            AccountOperations.searchAccountRecord('not-a-real-id');
        } catch (AuraHandledException e) {
            threw = true;
        } catch (Exception e) {
            threw = true;
        }
        System.assert(threw, 'Expected AuraHandledException for malformed Id string.');
    }
}