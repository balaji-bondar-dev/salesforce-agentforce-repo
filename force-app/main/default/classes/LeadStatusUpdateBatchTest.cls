/**
 * Test class for LeadStatusUpdateBatch
 * Validates batch processing of Lead status updates from 'Open - Not Contacted' to 'Working - Contacted'
 */
@isTest
private class LeadStatusUpdateBatchTest {

    private static final String SOURCE_STATUS = 'Open - Not Contacted';
    private static final String TARGET_STATUS = 'Working - Contacted';
    private static final Integer BULK_TEST_SIZE = 251;

    // ─── Test Setup ──────────────────────────────────────────────────────

    @TestSetup
    static void setupTestData() {
        // Create bulk test data with source status
        List<Lead> leads = TestDataFactory.createLeads(BULK_TEST_SIZE, SOURCE_STATUS, true);
        
        // Create some leads with different statuses to verify they are not updated
        List<Lead> otherStatusLeads = TestDataFactory.createLeads(5, 'Qualified', true);
    }

    // ─── Positive Tests ──────────────────────────────────────────────────

    @isTest
    static void shouldUpdateAllLeads_WhenBatchExecutes() {
        // Given
        List<Lead> leadsBeforeBatch = [SELECT Id, Status FROM Lead WHERE Status = :SOURCE_STATUS];
        Assert.areEqual(BULK_TEST_SIZE, leadsBeforeBatch.size(), 
            'Should have ' + BULK_TEST_SIZE + ' leads with Open - Not Contacted status');

        // When
        Test.startTest();
        Id jobId = Database.executeBatch(new LeadStatusUpdateBatch(), BULK_TEST_SIZE);
        Test.stopTest();

        // Then
        List<Lead> updatedLeads = [SELECT Id, Status FROM Lead WHERE Status = :TARGET_STATUS];
        Assert.areEqual(BULK_TEST_SIZE, updatedLeads.size(), 
            'All ' + BULK_TEST_SIZE + ' leads should be updated to Working - Contacted');
        
        List<Lead> remainingSourceLeads = [SELECT Id FROM Lead WHERE Status = :SOURCE_STATUS];
        Assert.areEqual(0, remainingSourceLeads.size(), 
            'No leads should remain with Open - Not Contacted status');
    }

    @isTest
    static void shouldNotUpdateOtherStatuses_WhenBatchExecutes() {
        // Given
        List<Lead> qualifiedLeads = [SELECT Id, Status FROM Lead WHERE Status = 'Qualified'];
        Assert.areEqual(5, qualifiedLeads.size(), 
            'Should have 5 leads with Qualified status');

        // When
        Test.startTest();
        Id jobId = Database.executeBatch(new LeadStatusUpdateBatch(), BULK_TEST_SIZE);
        Test.stopTest();

        // Then
        List<Lead> qualifiedLeadsAfter = [SELECT Id, Status FROM Lead WHERE Status = 'Qualified'];
        Assert.areEqual(5, qualifiedLeadsAfter.size(), 
            'Leads with Qualified status should remain unchanged');
    }


    @isTest
    static void shouldHandleEmptyScope_WhenNoLeadsMatch() {
        // Given - delete all leads with source status
        delete [SELECT Id FROM Lead WHERE Status = :SOURCE_STATUS];
        
        List<Lead> leadsBeforeBatch = [SELECT Id FROM Lead WHERE Status = :SOURCE_STATUS];
        Assert.areEqual(0, leadsBeforeBatch.size(), 
            'Should have no leads with Open - Not Contacted status');

        // When
        Test.startTest();
        Id jobId = Database.executeBatch(new LeadStatusUpdateBatch(), 200);
        Test.stopTest();

        // Then
        Assert.isNotNull(jobId, 'Batch job should execute even with empty scope');
        
        List<Lead> updatedLeads = [SELECT Id FROM Lead WHERE Status = :TARGET_STATUS];
        Assert.areEqual(0, updatedLeads.size(), 
            'No leads should be updated when scope is empty');
    }

    // ─── Stateful Tracking Tests ─────────────────────────────────────────

    @isTest
    static void shouldTrackProcessedRecords_WhenBatchCompletes() {
        // Given
        List<Lead> leadsBeforeBatch = [SELECT Id FROM Lead WHERE Status = :SOURCE_STATUS];
        Integer expectedCount = leadsBeforeBatch.size();

        // When
        Test.startTest();
        LeadStatusUpdateBatch batch = new LeadStatusUpdateBatch();
        Id jobId = Database.executeBatch(batch, BULK_TEST_SIZE);
        Test.stopTest();

        // Then
        List<Lead> updatedLeads = [SELECT Id FROM Lead WHERE Status = :TARGET_STATUS];
        Assert.areEqual(expectedCount, updatedLeads.size(), 
            'All leads should be successfully processed and tracked');
    }

    // ─── Batch Context Tests ─────────────────────────────────────────────

    @isTest
    static void shouldReturnQueryLocator_WhenStartMethodCalled() {
        // Given
        LeadStatusUpdateBatch batch = new LeadStatusUpdateBatch();

        // When
        Test.startTest();
        Database.QueryLocator queryLocator = batch.start(null);
        Test.stopTest();

        // Then
        Assert.isNotNull(queryLocator, 'QueryLocator should not be null');
    }
}