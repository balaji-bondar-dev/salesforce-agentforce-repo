/**
 * @description Centralized factory for creating test data with sensible defaults.
 *              All methods accept a doInsert flag for flexibility.
 *              Bulk methods create multiple records; single-record methods delegate to bulk.
 */
@isTest
public class TestDataFactory {

    // ─── Leads ────────────────────────────────────────────────────────────

    /**
     * Creates a list of Lead records with specified status
     * @param count Number of Leads to create
     * @param status Lead status value
     * @param doInsert Whether to insert records immediately
     * @return List of Lead records
     */
    public static List<Lead> createLeads(Integer count, String status, Boolean doInsert) {
        List<Lead> leads = new List<Lead>();
        String uniqueKey = String.valueOf(System.currentTimeMillis());
        for (Integer i = 0; i < count; i++) {
            leads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Lead ' + uniqueKey + i,
                Company = 'Test Company ' + uniqueKey + i,
                Email = 'testlead' + uniqueKey + i + '@example.com',
                Status = status,
                LeadSource = 'Web'
            ));
        }
        if (doInsert) {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(leads, dml);
        }
        return leads;
    }

    /**
     * Creates a single Lead record
     * @param status Lead status value
     * @param doInsert Whether to insert record immediately
     * @return Lead record
     */
    public static Lead createLead(String status, Boolean doInsert) {
        return createLeads(1, status, doInsert)[0];
    }

    // ─── Accounts ─────────────────────────────────────────────────────────

    public static List<Account> createAccounts(Integer count, Boolean doInsert) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                BillingCity = 'San Francisco',
                BillingState = 'CA',
                BillingCountry = 'USA',
                Industry = 'Technology',
                Type = 'Customer'
            ));
        }
        if (doInsert) {
            insert accounts;
        }
        return accounts;
    }

    public static Account createAccount(Boolean doInsert) {
        return createAccounts(1, doInsert)[0];
    }

    // ─── Contacts ─────────────────────────────────────────────────────────

    public static List<Contact> createContacts(List<Account> accounts, Integer countPerAccount, Boolean doInsert) {
        List<Contact> contacts = new List<Contact>();
        Integer idx = 0;
        for (Account acc : accounts) {
            for (Integer i = 0; i < countPerAccount; i++) {
                contacts.add(new Contact(
                    FirstName = 'Test',
                    LastName = 'Contact ' + idx,
                    Email = 'test.contact' + idx + '@example.com',
                    AccountId = acc.Id
                ));
                idx++;
            }
        }
        if (doInsert) {
            insert contacts;
        }
        return contacts;
    }

    // ─── Opportunities ────────────────────────────────────────────────────

    public static List<Opportunity> createOpportunities(List<Account> accounts, Integer countPerAccount, Boolean doInsert) {
        List<Opportunity> opps = new List<Opportunity>();
        Integer idx = 0;
        for (Account acc : accounts) {
            for (Integer i = 0; i < countPerAccount; i++) {
                opps.add(new Opportunity(
                    Name = 'Test Opportunity ' + idx,
                    AccountId = acc.Id,
                    StageName = 'Prospecting',
                    CloseDate = Date.today().addDays(30),
                    Amount = 10000 + (idx * 1000)
                ));
                idx++;
            }
        }
        if (doInsert) {
            insert opps;
        }
        return opps;
    }

    // ─── Users ────────────────────────────────────────────────────────────

    public static User createUser(String profileName, Boolean doInsert) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        String uniqueKey = String.valueOf(DateTime.now().getTime());

        User u = new User(
            FirstName = 'Test',
            LastName = 'User ' + uniqueKey,
            Email = 'testuser' + uniqueKey + '@example.com',
            Username = 'testuser' + uniqueKey + '@example.com.test',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        if (doInsert) {
            insert u;
        }
        return u;
    }

    // ─── Field Override Pattern ────────────────────────────────────────────

    public static Account createAccount(Map<String, Object> fieldOverrides, Boolean doInsert) {
        Account acc = new Account(
            Name = 'Test Account',
            Industry = 'Technology'
        );
        for (String fieldName : fieldOverrides.keySet()) {
            acc.put(fieldName, fieldOverrides.get(fieldName));
        }
        if (doInsert) {
            insert acc;
        }
        return acc;
    }
}