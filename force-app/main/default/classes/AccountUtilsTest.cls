/*
* @author Itzik Winograd
* @date 04/01/2021
* @description Test class for AccountUtils Class
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        - 
* description - 
* --------------------------------------------------------------------------------------
*/


@isTest
global class AccountUtilsTest {
    @isTest
    /**
    * @author Itzik Winograd
    * @date 04/01/2021
    * @description - Create Test Accounts
    * @Desired - NUMBER_OF_ACCOUNTS Accounts will be returned fron the AccountUtilsClass
    */
    public static void createAccountsWithUtils(){

        Integer NUMBER_OF_ACCOUNTS = 5;
        //create accounts with the utils, no insertion
        List<Account> accountsList = AccountUtils.getAccounts(NUMBER_OF_ACCOUNTS);
         
        //Assert for  5 accounts and for 
        System.assertEquals(NUMBER_OF_ACCOUNTS,accountsList.size(), 'Error in getAccounts - ' + NUMBER_OF_ACCOUNTS);
        System.assertEquals(AccountUtils.getAccounts(0), null, 'Error in getAccounts - 0!');
    }

}