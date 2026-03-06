public class Utility {
  public static boolean isAfterDisabled = false;

  public static String hashCode(String name) {
    Integer result = 17;
    result = 31 * result + name.hashCode();
    return String.valueOf(result);
  }

  public static Datetime convertDateToDatetime(Date dateToConvert) {
    Integer d = dateToConvert.day();
    Integer mo = dateToConvert.month();
    Integer yr = dateToConvert.year();

    DateTime convertedDatetime = DateTime.newInstance(yr, mo, d);
    return convertedDatetime;
  }

  /* public static Id getRecordTypeIdForObject(SObject sObj, String recTypeDevName) {
        return sObj.getSObjectType().getDescribe()
            .getRecordTypeInfosByDeveloperName()
            .get(recTypeDevName)
            .getRecordTypeId();
    } */

  public static String getCronFromDateTime(Datetime executeTime) {
    return executeTime.second() +
      ' ' +
      executeTime.minute() +
      ' ' +
      executeTime.hour() +
      ' ' +
      executeTime.day() +
      ' ' +
      executeTime.month() +
      ' ? ' +
      executeTime.year();
  }

  public static Id getRecordTypeIdForObject(
    SObjectType objType,
    String recTypeDevName
  ) {
    return objType.getDescribe()
      .getRecordTypeInfosByDeveloperName()
      .get(recTypeDevName)
      .getRecordTypeId();
  }

  public static Id getRecordTypeIdForObject(
    String objName,
    String recTypeDevName
  ) {
    return ((SObject) Type.forName(objName).newInstance())
      .getSObjectType()
      .getDescribe()
      .getRecordTypeInfosByDeveloperName()
      .get(recTypeDevName)
      .getRecordTypeId();
  }

  public static String getDevNameForRecordTypeID(String objName, Id recTypeId) {
    return ((SObject) Type.forName(objName).newInstance())
      .getSObjectType()
      .getDescribe()
      .getRecordTypeInfosById()
      .get(recTypeId)
      .getDeveloperName();
  }

  public static String getDevNameForRecordTypeID(
    SObjectType objType,
    Id recTypeId
  ) {
    return objType.getDescribe()
      .getRecordTypeInfosById()
      .get(recTypeId)
      .getDeveloperName();
  }

  /* public static String getDevNameForRecordTypeID(SObject sObj, Id recTypeId) {
        return sObj.getSObjectType().getDescribe()
            .getRecordTypeInfosById()
            .get(recTypeId)
            .getDeveloperName();
    } */

  public static List<Object> replace(
    List<Object> itemList,
    Object replacedItem,
    Object newItem
  ) {
    Integer indexOfReplacedItem = itemList.indexOf(replacedItem);
    if (indexOfReplacedItem < 0) {
      throw new UtilityException(
        'Utility replace - replaced item not found - ' + replacedItem
      );
    } else {
      itemList[indexOfReplacedItem] = newItem;
    }
    return itemList;
  }

  public static DescribeFieldResult getFieldDescribe(
    String sObjectName,
    String fieldName
  ) {
    DescribeSObjectResult objResult = Schema.getGlobalDescribe()
      .get(sObjectName)
      .getDescribe();
    DescribeFieldResult fieldResult = objResult.fields.getMap()
      .get(fieldName)
      .getDescribe();
    return fieldResult;
  }

  public static Boolean isProductionOrg() {
    Organization org = [
      SELECT IsSandbox
      FROM Organization
      WHERE Id = :UserInfo.getOrganizationId()
    ];
    return (org.IsSandbox == true) ? false : true;
  }

  public static Integer getDaysInYear(Date input) {
    return Date.isLeapYear(input.year()) ? 366 : 365;
  }

  public static Integer getDaysBetween(Date startDate, Date dueDate) {
    Integer numberDaysDue = startDate.daysBetween(dueDate);
    return numberDaysDue;
  }

  public class UtilityException extends Exception {
  }
}
