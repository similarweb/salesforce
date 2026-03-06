public class Utils {
  public static boolean isZuora = false;
  public static boolean CodeOff = false;
  public static boolean isTest = false;
  public static boolean IsTestSeeAll = false;

  // Check if there's a match betwee a quote record type to the quote template quote type
  public static Boolean QuoteRecordTypeMatchesTemplateQuoteType(
    String quoteRtName,
    String quoteTemplateType
  ) {
    map<string, Quote_Record_Type_Template_Map__c> templateMap = Quote_Record_Type_Template_Map__c.getall();
    return templateMap.containsKey(quoteRtName) &&
      templateMap.get(quoteRtName).Val__c.equalsIgnoreCase(quoteTemplateType);
  }

  // Convert null string to empty string
  public static String SafeValue(string str) {
    return str == null ? '' : str;
  }

  public static Contact[] ValidateList(Contact[] Clist) {
    set<id> CidSet = new Set<id>();
    list<Contact> newList = new List<Contact>();
    for (Contact c : Clist) {
      if (!cidSet.Contains(c.id)) {
        newlist.add(c);
        CidSet.add(c.id);
      }
    }
    return newList;
  }

  public static string DateFormat(integer year, integer month, integer day) {
    string s = string.valueof(year) + '-';
    if (month < 10)
      s += '0';
    s += string.valueof(month) + '-';
    if (day < 10)
      s += '0';
    s += string.valueof(day);
    return s;
  }
}
