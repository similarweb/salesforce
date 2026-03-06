public class WSVATService {
  private String WSVAT_SETTING_NAME = 'WSVAT_VALIDATION_ON_FAIL';

  public WSVATService() {
  }

  /** Method for synchronous call of Web Service */
  public String checkVat(String countryCode, String vatNumber) {
    system.debug('TESTING checkVat run: ' + countrycode + ' ' + vatNumber);
    String country = String.valueOf(countryCode);
    String vat = String.valueOf(vatNumber);
    CheckVatViesService.checkVatPort checkVat = new CheckVatViesService.checkVatPort();
    CheckVatTypesService.checkVatResponse_element checkVatResponse = checkVat.checkVat(
      country,
      vat
    );
    system.debug(JSON.serializePretty(checkVatResponse));
    return String.valueOf(checkVatResponse);
  }

  /** Method for synchronous call of Web Service (secound method) */
  public String checkVatAprox(
    String countryCode,
    String vatNumber,
    String traderName,
    String traderCompanyType,
    String traderStreet,
    String traderPostCode,
    String traderCity,
    String requesterCountryCode,
    String requesterVatNumber
  ) {
    String country = String.valueOf(countryCode);
    String vat = String.valueOf(vatNumber);
    String tName = String.valueOf(traderName);
    String tCompanyType = String.valueOf(traderCompanyType);
    String tStreet = String.valueOf(traderStreet);
    String tPostCode = String.valueOf(traderPostCode);
    String tCity = String.valueOf(traderCity);
    String rCountryCode = String.valueOf(requesterCountryCode);
    String rVatNumber = String.valueOf(requesterVatNumber);

    CheckVatViesService.checkVatPort checkVat = new CheckVatViesService.checkVatPort();
    CheckVatTypesService.checkVatApproxResponse_element checkVatResponse = checkVat.checkVatApprox(
      country,
      vat,
      tName,
      tCompanyType,
      tStreet,
      tPostCode,
      tCity,
      rCountryCode,
      rVatNumber
    );
    return String.valueOf(checkVatResponse);
  }

  public Boolean checkIsVatValid(String countryCode, String vatNumber) {
    List<General_Configuration__mdt> generalConfigurationList = GeneralUtil.retrieveConfigurationMetadata(
      new Set<String>{ WSVAT_SETTING_NAME }
    );
    if (
      !generalConfigurationList.isEmpty() &&
      generalConfigurationList[0].Text_Value__c.equalsIgnoreCase('False')
    ) {
      return true;
    }
    Boolean validationResult;
    try {
      System.debug('countryCode ' + countryCode);
      System.debug('vatNumber ' + vatNumber);
      CheckVatViesService.checkVatPort checkVat = new CheckVatViesService.checkVatPort();
      CheckVatTypesService.checkVatResponse_element checkVatResponse = checkVat.checkVat(
        countryCode,
        vatNumber
      );
      system.debug(JSON.serializePretty(checkVatResponse));
      validationResult = parseWsvatResponse(String.valueOf(checkVatResponse));
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      System.debug(ex.getStackTraceString());
      validationResult = false;
    }
    return validationResult;
  }

  public Boolean checkIsVatValid(String vatNumber) {
    List<String> certificateIdWithIso = vatNumber.split(' ');
    if (certificateIdWithIso.size() < 2) {
      throw new WSVATServiceException(
        'The Certificate Id you inserted is not valid, the format is: 2 letters, space, and numbers. Please update it in the Quote Details tab and try to generate the contract again (recall the quote if needed)'
      );
    }
    return checkIsVatValid(certificateIdWithIso[0], certificateIdWithIso[1]);
  }

  private static Boolean parseWsvatResponse(String wsvatResponse) {
    Boolean isVatNumberValid = false;
    if (wsvatResponse.startswith('checkVatResponse_element')) {
      //Successfull answer starts with checkVATresponse_element
      integer validi = wsvatResponse.indexof('valid=');
      if (validi != -1) {
        integer resulti = wsvatResponse.indexof(',', validi);
        if (resulti != -1) {
          string results = wsvatResponse.substring(validi + 6, resulti);
          if (results.EqualsIgnoreCase('True'))
            isVatNumberValid = true;
          if (results.EqualsIgnoreCase('false'))
            isVatNumberValid = false;
        }
      }
    }
    return isVatNumberValid;
  }
  public class WSVATServiceException extends Exception {
  }
}
