@isTest
public with sharing class ZRemoveOriginalProductsActionPluginTest {
    @isTest
    static void test(){
        new ZuoraRemoveOriginalProductsActionPlugin().perform(null,null,null);
    }
}