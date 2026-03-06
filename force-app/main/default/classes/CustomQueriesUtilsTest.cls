/**
* @author Itzik Winograd
* @date 05/10/2021
* @description Test class for the class "CustomQueriesUtilsTest"
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        - 
* description - 
* --------------------------------------------------------------------------------------
*/
@isTest
public class CustomQueriesUtilsTest {
	/**
    * @author Itzik Winograd
    * @date 05/10/2021
    * @description Test the main custom query with dedicated "test" records
    * @Expected the received test query is equel 'SELECT Id FROM User LIMIT 1'
    */
    @isTest
    public static void testCustomQueryCreateion () {
        System.assertEquals(Database.query('SELECT Id FROM User LIMIT 1'), Database.query(CustomQueriesUtils.getCustomQuery('test')), 'CustomQueriesUtilsTest Mismatch with metadata!');
    }
}