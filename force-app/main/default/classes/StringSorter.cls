/**
 * Created by Alon.Shalev on 10/5/2023.
 */

public class StringSorter {
  public class StringWrapper implements Comparable {
    public String originalString;
    public Integer sortValue;

    public StringWrapper(String originalString) {
      this.originalString = originalString;
    }

    public Integer compareTo(Object obj) {
      StringWrapper other = (StringWrapper) obj;
      Decimal compareNumber = extractLeadingNumber(other.originalString);
      Decimal currentNumber = extractLeadingNumber(originalString);
      if (currentNumber != null && compareNumber != null) {
        if (currentNumber > compareNumber) {
          return 1;
        } else if (currentNumber < compareNumber) {
          return -1;
        } else {
          return 0;
        }
      }
      if (currentNumber != null)
        return -1; // Current string starts with a number, so it comes first
      if (compareNumber != null)
        return 1; // String to compare starts with a number, so it comes after
      return this.originalString.compareTo(other.originalString);
    }

    private Decimal extractLeadingNumber(String s) {
      Pattern p = Pattern.compile('^([0-9,]+)');
      Matcher m = p.matcher(s);
      if (m.find()) {
        String matchedNumber = m.group(1).replaceAll(',', ''); // Remove commas
        return Decimal.valueOf(matchedNumber);
      }
      return null;
    }
  }

  public List<String> customSort(List<String> inputStrings) {
    List<StringWrapper> wrappers = new List<StringWrapper>();
    for (String s : inputStrings) {
      wrappers.add(new StringWrapper(s));
    }

    wrappers.sort();

    List<String> sortedStrings = new List<String>();
    for (StringWrapper wrapper : wrappers) {
      sortedStrings.add(wrapper.originalString);
    }

    return sortedStrings;
  }
}
