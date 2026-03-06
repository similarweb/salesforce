public virtual with sharing class GenericDomain {
  public List<SObject> newRecords { get; private set; }
  public Schema.DescribeSObjectResult sObjectDescribe { get; private set; }

  public GenericDomain(List<SObject> sObjectList) {
    this(sObjectList, sObjectList.getSObjectType());
  }

  public GenericDomain(List<SObject> sObjectList, SObjectType sObjectType) {
    newRecords = sObjectList;
    SObjectDescribe = sObjectType.getDescribe();
  }

  public static void triggerHandler(Type dominInstanceType) {
    triggerHandler(
      Trigger.isBefore,
      Trigger.isAfter,
      Trigger.isInsert,
      Trigger.isUpdate,
      Trigger.isDelete,
      Trigger.isUndelete,
      Trigger.new,
      Trigger.oldMap,
      dominInstanceType
    );
  }

  @TestVisible
  private static void triggerHandler(
    Boolean isBefore,
    Boolean isAfter,
    Boolean isInsert,
    Boolean isUpdate,
    Boolean isDelete,
    Boolean isUndelete,
    List<SObject> newRecords,
    Map<Id, SObject> oldRecordsMap,
    Type dominInstanceType
  ) {
    List<SObject> records;
    if (isDelete) {
      records = oldRecordsMap.values();
    } else {
      records = newRecords;
    }
    GenericDomain domainInstance;
    // if (Test.isRunningTest()) {
    // 	domainInstance = new GenericDomain(records);
    // } else {
    IConstructable domainInstacneConstructor = (IConstructable) (Type.forName(
        (dominInstanceType.getName()) + '.Constructor'
      ))
      .newInstance();
    domainInstance = domainInstacneConstructor.constructDomainInstance(records);
    // }
    if (isBefore) {
      if (isInsert)
        domainInstance.handleBeforeInsert();
      else if (isUpdate)
        domainInstance.handleBeforeUpdate(oldRecordsMap);
      else if (isDelete)
        domainInstance.handleBeforeDelete();
    } else if (isAfter) {
      if (isInsert)
        domainInstance.handleAfterInsert();
      else if (isUpdate)
        domainInstance.handleAfterUpdate(oldRecordsMap);
      else if (isDelete)
        domainInstance.handleAfterDelete(Trigger.old);
      else if (isUndelete)
        domainInstance.handleAfterUndelete();
    }
  }

  /* public List<SObject> getChangedRecords(Set<String> fieldNames, Map<Id, SObject> oldMap)
	{
		List<SObject> changedRecords = new List<SObject>();
		for (SObject newRecord : newRecords)
		{
			Id recordId = (Id) newRecord.get('Id');
			if (oldMap == null || !oldMap.containsKey(recordId))
			{
				continue;
			}

			SObject oldRecord = oldMap.get(recordId);
			for (String fieldName : fieldNames)
			{
				if (oldRecord.get(fieldName) != newRecord.get(fieldName))
				{
					changedRecords.add(newRecord);
					break;  // prevents the records from being added multiple times
				}
			}
		}
		return changedRecords;
	}

    public List<SObject> getRecordsWithNotEmptyFields(Set<String> fieldNames)
	{
		List<SObject> passedRecords = new List<SObject>();
		for (SObject newRecord : newRecords)
		{
			for (String fieldName : fieldNames)
			{
				if (newRecord.get(fieldName) != null)
				{
					passedRecords.add(newRecord);
					break;  // prevents the records from being added multiple times
				}
			}
		}
		return passedRecords;
	} */

  public virtual void onValidate() {
  }

  public virtual void onValidate(Map<Id, SObject> oldRecordsMap) {
  }

  public virtual void handleBeforeInsert() {
    onBeforeInsert();
  }

  public virtual void handleBeforeUpdate(Map<Id, SObject> existingRecords) {
    onBeforeUpdate(existingRecords);
  }

  public virtual void handleBeforeDelete() {
    onBeforeDelete();
  }

  public virtual void handleAfterInsert() {
    onValidate();
    onAfterInsert();
  }

  public virtual void handleAfterUpdate(Map<Id, SObject> existingRecords) {
    onValidate(existingRecords);
    onAfterUpdate(existingRecords);
  }

  public virtual void handleAfterDelete(List<SObject> deletedRecords) {
    onAfterDelete(deletedRecords);
  }

  public virtual void handleAfterUndelete() {
    onAfterUndelete();
  }

  public virtual void onBeforeInsert() {
  }

  public virtual void onBeforeUpdate(Map<Id, SObject> oldRecordsMap) {
  }

  public virtual void onBeforeDelete() {
  }

  public virtual void onAfterInsert() {
  }

  public virtual void onAfterUpdate(Map<Id, SObject> oldRecordsMap) {
  }

  public virtual void onAfterDelete(List<SObject> deletedRecords) {
  }

  public virtual void onAfterUndelete() {
  }

  public interface IConstructable {
    GenericDomain constructDomainInstance(List<SObject> sObjectList);
  }
}
