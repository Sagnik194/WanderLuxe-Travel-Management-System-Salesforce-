global class TravelerEscalationScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        TravelerEscalationBatch batchJob = new TravelerEscalationBatch();
        Database.executeBatch(batchJob, 200);
    }
}