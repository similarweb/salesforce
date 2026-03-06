public with sharing class GroudonQueueable implements Queueable , Database.AllowsCallouts{
    private GroudonHandler handler;

    public GroudonQueueable(GroudonHandler handler){
        this.handler = handler;
    }

    public void execute(QueueableContext param1) {
        this.handler.process();
    }


    public interface GroudonHandler {
        void process();
    }

    public interface GroudonRequestGenerator {
        GroudonIntegrationService.GroudonRequest generate(SObject record);
    }

    public interface GroudonResponseGenerator {
        GroudonIntegrationService.GroudonResponse generate(List<GroudonIntegrationService.GroudonRequest> requestBodies);
    }
}