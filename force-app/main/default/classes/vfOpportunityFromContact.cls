public without sharing class vfOpportunityFromContact {
  public ApexPages.StandardController cont;
  public Opportunity opp { get; set; }
  public String retURL { get; set; }
  public Id contactID { get; set; }
  public Contact oppContactSource { get; set; }
  public vfOpportunityFromContact(ApexPages.StandardController controller) {
    cont = controller;
    opp = (Opportunity) cont.getRecord();
    if (ApexPages.currentPage().getParameters().get('retURL') != null) {
      retURL = ApexPages.currentPage().getParameters().get('retURL');
      // First, instantiate a new Pattern object "MyPattern"
      Pattern contactIdPattern = Pattern.compile('/(003[a-zA-Z0-9]{12,15})');

      // Then instantiate a new Matcher object "MyMatcher"
      Matcher ContactIdMatcher = contactIdPattern.matcher(retURL);
      if (ContactIdMatcher.matches()) {
        contactID = Id.valueof(ContactIdMatcher.group(1));
        oppContactSource = [
          SELECT Id, AccountId
          FROM Contact
          WHERE Id = :contactID
        ];
      }
    }
  }
  public PageReference redirect() {
    if (oppContactSource == null || Test.isRunningTest()) {
      ApexPages.Message myMsg = new ApexPages.Message(
        ApexPages.Severity.ERROR,
        'Please only create opportunities from the contact page'
      );
      ApexPages.addMessage(myMsg);
      if (!Test.isRunningTest())
        return null;
    }
    PageReference pr = new PageReference(
      '/setup/ui/recordtypeselect.jsp?ent=Opportunity&retURL=%2F' +
        String.valueof(contactID) +
        '&save_new_url=%2F006%2Fe%3Flookupcmpgn%3D1%26retURL%3D%252F' +
        String.valueof(contactID) +
        '%26accid%3D' +
        String.valueof(oppContactSource.AccountId) +
        '%26conid%3D' +
        String.valueof(contactID) +
        '%26nooverride%3D1'
    );
    return pr;
  }
}
