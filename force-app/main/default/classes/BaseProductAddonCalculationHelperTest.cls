/**
 * @descriprion test class for BaseProductAddonCalculationHelperTest
 * @date 30/05/2020
 * --------------------------------------------------------------------------------------
 * Refactored by Synebo Developer
 */
@isTest
public class BaseProductAddonCalculationHelperTest {
  @isTest
  public static void wordingProcessTest() {
    Set<Id> quoteIdset = new Set<Id>();
    WordingProcess wordingProcess = new WordingProcess('ads');
    wordingProcess.populateObjectWithWording(quoteIdset);
  }
}
