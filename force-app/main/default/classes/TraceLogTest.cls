@isTest
private class TraceLogTest {

    @isTest
    static void testTraceLogLogic() {
        Opportunity opp = new Opportunity(
            Name = 'Original Name',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 1000
        );
        insert opp;
        test.startTest();
        opp.Name = 'New Name'; 
        opp.Amount = 2000;
        update opp;
        test.stopTest();
    }
}