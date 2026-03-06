/**
 * Created by zohar.sinay on 18/01/2024.
 */

@isTest
private class ZAddBasePackageCustomActionPluginTest {

    @isTest
    static void test(){
        new ZuoraAddBasePackageCustomActionPlugin().perform(null,null,null);
    }
}