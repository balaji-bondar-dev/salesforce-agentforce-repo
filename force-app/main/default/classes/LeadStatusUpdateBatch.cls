/**
 * Batch Apex class for updating Lead status from 'Open - Not Contacted' to 'Working - Contacted'.
 * Processes Lead records in configurable batch sizes.
 * Implements Database.Stateful to track cumulative results across chunks.
 *
 * @example
 * // Execute with default batch size
 * Database.executeBatch(new LeadStatusUpdateBatch());
 *
 * // Execute with custom batch size
 * Database.executeBatch(new LeadStatusUpdateBatch(), 100);
 */
public with sharing class LeadStatusUpdateBatch implements Database.Batchable<SObject>, Database.Stateful {

    // ─── Constants ───────────────────────────────────────────────────────
    private static final Integer DEFAULT_BATCH_SIZE = 200;
    private static final String SOURCE_STATUS = 'Open - Not Contacted';
    private static final String TARGET_STATUS = 'Working - Contacted';

    // ─── Stateful Tracking ───────────────────────────────────────────────
    private Integer totalProcessed = 0;
    private Integer totalErrors = 0;
    private List<String> errorMessages = new List<String>();

    // ─── Constructor ─────────────────────────────────────────────────────

    /**
     * Default constructor
     */
    public LeadStatusUpdateBatch() {
        // Default configuration
    }

    // ─── Batchable Interface ─────────────────────────────────────────────

    /**
     * Defines the scope of records to process.
     * Uses Database.QueryLocator for efficient large-dataset processing.
     * @param bc The batch context
     * @return QueryLocator for the Lead records to process
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Status
            FROM Lead
            WHERE Status = :SOURCE_STATUS
            WITH USER_MODE
        ]);
    }

    /**
     * Processes each batch of Lead records.
     * Uses Database.update with allOrNone=false for partial success handling.
     * @param bc The batch context
     * @param scope List of Lead records in the current batch
     */
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        // Guard clause for empty scope
        if (scope == null || scope.isEmpty()) {
            return;
        }

        List<Lead> leadsToUpdate = new List<Lead>();

        for (Lead lead : scope) {
            // Only update if status hasn't changed
            if (lead.Status == SOURCE_STATUS) {
                lead.Status = TARGET_STATUS;
                leadsToUpdate.add(lead);
            }
        }

        if (!leadsToUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(leadsToUpdate, false, AccessLevel.USER_MODE);
            processResults(results);
        }
    }

    /**
     * Performs post-processing after all batches complete.
     * Logs a summary of the batch execution.
     * @param bc The batch context
     */
    public void finish(Database.BatchableContext bc) {
        String summary = String.format(
            '{0} completed. Processed: {1}, Errors: {2}',
            new List<Object>{
                LeadStatusUpdateBatch.class.getName(),
                totalProcessed,
                totalErrors
            }
        );

        System.debug(LoggingLevel.INFO, summary);

        if (!errorMessages.isEmpty()) {
            System.debug(LoggingLevel.ERROR, 'Error details: ' + String.join(errorMessages, '\n'));
        }
    }

    // ─── Private Helpers ─────────────────────────────────────────────────

    /**
     * Processes Database.SaveResult list, tracking successes and failures
     * @param results List of SaveResult from a DML operation
     */
    private void processResults(List<Database.SaveResult> results) {
        for (Database.SaveResult result : results) {
            if (result.isSuccess()) {
                totalProcessed++;
            } else {
                totalErrors++;
                for (Database.Error err : result.getErrors()) {
                    errorMessages.add(
                        'Record ' + result.getId() + ': ' +
                        err.getStatusCode() + ' - ' + err.getMessage()
                    );
                }
            }
        }
    }

    // ─── Static Helpers ──────────────────────────────────────────────────

    /**
     * Convenience method to execute with default batch size
     * @return The batch job Id
     * @example
     * Id jobId = LeadStatusUpdateBatch.run();
     */
    public static Id run() {
        return Database.executeBatch(new LeadStatusUpdateBatch(), DEFAULT_BATCH_SIZE);
    }
}