/*
 * Made by Dmitry Trufanov from Synebo
 */
@isTest
public class PolyghraphMockImp implements System.HttpCalloutMock {
  public HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    if (
      req.getEndpoint()
        .contains('https://polygraph-test.similarweb.io/api/test')
    ) {
      res.setHeader('ContentType', 'application/json');

      CompanyWrapper cw = new CompanyWrapper();
      cw.countryCode = 'test';
      cw.countryName = 'test';
      cw.stateName = 'test';
      cw.stateCode = 'test';
      cw.city = 'test';
      cw.employeesEstimated = 'test';
      cw.employeesRange = '5001+';
      cw.name = 'test';
      cw.domain = 'test';
      cw.logo = 'test';
      cw.otherDomains = new List<String>{ 'test' };
      cw.linkedin = 'test';
      cw.twitter = 'test';
      cw.facebook = 'test';
      cw.annualRevenue = 'test';

      ContactWrapper conWr = new ContactWrapper();
      conWr.emailType = 'test';
      conWr.email = 'test';
      conWr.firstName = 'test';
      conWr.lastName = 'test';
      conWr.profilePic = 'test';
      conWr.countryCode = 'test';
      conWr.title = 'test';
      conWr.seniority = 'test';
      conWr.role = 'test';
      conWr.linkedin = 'test';
      conWr.twitter = 'test';
      conWr.additionalEmail = new List<String>{ 'test' };

      AttributesWrapper aw = new AttributesWrapper();
      aw.domainsComparison = 'test';

      PolygraphResponse pr = new PolygraphResponse();
      pr.contact = conWr;
      pr.attributes = aw;
      pr.company = cw;
      res.setBody(JSON.serialize(pr));
      res.setStatusCode(200);
    }
    return res;
  }
  public class PolygraphResponse {
    public ContactWrapper contact;
    public AttributesWrapper attributes;
    public CompanyWrapper company;
    public String Error;
  }

  public class ContactWrapper {
    public String emailType;
    public String email;
    public String firstName;
    public String lastName;
    public String profilePic;
    public String countryCode;
    public String countryName;
    public String title;
    public String seniority;
    public String role;
    public String linkedin;
    public String twitter;
    public List<String> additionalEmail;
  }

  public class AttributesWrapper {
    public String domainsComparison;
  }

  public class CompanyWrapper {
    public String countryCode;
    public String countryName;
    public String stateName;
    public String stateCode;
    public String city;
    public String employeesEstimated;
    public String employeesRange;
    public String name;
    public String domain;
    public String logo;
    public List<String> otherDomains;
    public String linkedin;
    public String twitter;
    public String facebook;
    public String annualRevenue;
  }
}
