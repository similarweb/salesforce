/**
 * @author Itzik Winograd
 * @date 18/07/2021
 * @description:Test class for the CurrencyUtils class
 * --------------------------------------------------------------------------------------
 */
@isTest
public class CurrencyUtilsTest {
  /**
   * @author Itzik Winograd
   * @date day/month/2021
   * @Description: get a map of currencies.
   * @Expected: a map with currencies will be returned
   */
  @isTest
  public static void testExistingCurrencies() {
    Map<String, Currency__mdt> currencyCodeMap = CurrencyUtils.getCurrenciesByCodeMap();
    System.assert(
      currencyCodeMap != null,
      'Error: null currencies map was returned.'
    );
  }
}
