public class ZSendQuote implements Queueable, Database.AllowsCallouts {
    private list <Id> qIds;

    public ZSendQuote(list <Id> p_qIds) {
        this.qIds = p_qIds;
    }

    public void execute(QueueableContext context) {
        for (Id quoteId: this.qIds) {
            ZuoraSubmitQuoteService.submitQuote(quoteId);   
        }
    }
}