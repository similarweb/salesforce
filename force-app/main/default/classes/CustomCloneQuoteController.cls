public with sharing class CustomCloneQuoteController {
  public zqu.CloneQuoteComponentOptions cloneQuoteOptions { get; set; }

  public CustomCloneQuoteController(ApexPages.StandardController controller) {
    cloneQuoteOptions = new zqu.CloneQuoteComponentOptions();
    cloneQuoteOptions.originalQuoteId = ApexPages.currentPage()
      .getParameters()
      .get('id');
    // cloneQuoteOptions.nextPageUrl = '/apex/c__CustomEditQuoteDetailsPage?id=' + ApexPages.currentPage().getParameters().get('id');
  }

  public void setNextUrl() {
    cloneQuoteOptions.nextPageUrl =
      '/apex/c__CustomEditQuoteDetailsPage?id=' +
      ApexPages.currentPage().getParameters().get('id');
  }
  public void removeNextUrl() {
    cloneQuoteOptions.nextPageUrl = null;
  }
}
