/**
* @author Itzik Winograd
* @date 17/06/2021
* @description Test class for ExecuteDistibuteAccountValuesToCons
*/
@isTest
public class ExecuteDistibuteAccountValuesToConsTest {
	/**
    * @author Itzik Winograd
    * @date 17/06/2021
    * @description: Create and run an instance of this class.
    * @expected: the class will be created successfully and no errors will occure.
    */
    @istest
    public static void testImplementation(){
        String additionalProcessClassName ='ExecuteDistibuteAccountValuesToCons';
        Test.startTest();
        Type t = Type.forName(additionalProcessClassName);
        AdditionalLogicForAfterDML processHandler = (AdditionalLogicForAfterDML)t.newInstance();
        try{
            processHandler.handle(null, null);
        }
        catch(Exception ex){
            EventBus.Publish(LogEventUtils.createLogEventRecord(new List<Id>(), 'ExecuteDistibuteAccountValuesToConsTest', 'testImplementation', 
            '', 'Error executing additional logic: ' + additionalProcessClassName + ' -  ' + ex.getMessage(), 'Error',null,null));
        }
        Test.stopTest();
        System.assertEquals(0, 
                            [SELECT Id
                            FROM Apex_Event_Log__c
                            WHERE Apex_Class__c = 'ExecuteDistibuteAccountValuesToConsTest'].size(),
                           'Error occured during class run');
    }
}