/**
* @author Itzik Winograd
* @date 24/12/2020
* @description General Account functions that can help us throughout the code base
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        -  
* description - 
* --------------------------------------------------------------------------------------                     
*/
 
public with sharing class AccountUtils {

    /**
    * @author Itzik Winograd
    * @date 24/12/2020
    * @description Create an account
    * @param None.  
    * @return List<Account> - list of accounts null if none requested
    */
    public static List<Account>  getAccounts(Integer numOfAccounts){
        List<Account> lst_Account = new List<Account>();
        if (numOfAccounts > 0){
            for (Integer i = 0; i < numOfAccounts; i++){
                lst_Account.add(New Account(
                	Name = 'Test Account ' + i,
                    Website = 'https://www.test'+i+'.com',
                    Employees_Min__c = i
                ));
            }
            return lst_Account;
        }
        return null;
    }
}