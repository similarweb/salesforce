public with sharing class AccountDomain extends GenericDomain {
  private AccountDomain instance;

  public AccountDomain(List<SObject> newRecords) {
    super(newRecords);
  }

  public class Constructor implements GenericDomain.IConstructable {
    public GenericDomain constructDomainInstance(List<SObject> sObjectList) {
      return new AccountDomain(sObjectList);
    }
  }
}
