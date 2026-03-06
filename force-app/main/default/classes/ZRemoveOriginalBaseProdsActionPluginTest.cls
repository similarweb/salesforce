/**
 * Created by zohar.sinay on 21/08/2023.
 */

@isTest
public with sharing class ZRemoveOriginalBaseProdsActionPluginTest {
    @isTest
    static void test(){
        new ZuoraRemoveOriginalBaseProdsActionPlugin().perform(null,null,null);
    }
}