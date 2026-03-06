public with sharing class UserHistoryService {
	public static void handleAfterInsert(List<User> newUsers) {
		Map<String, String> jsonInput = new Map<String, String>{
			'newList' => JSON.serialize(newUsers), 'oldMap' => JSON.serialize(new Map<Id, User>())};

		processChanges(JSON.serialize(jsonInput));
	}

	public static void handleAfterUpdate(List<User> newList, Map<Id, User> oldMap) {
		Map<String, String> jsonInput = new Map<String, String>{'newList' => JSON.serialize(newList), 'oldMap' => JSON.serialize(oldMap)};

		processChanges(JSON.serialize(jsonInput));
	}

	@future
	private static void processChanges(String jsonInput) {
		Map<String, String> input = (Map<String, String>) JSON.deserialize(jsonInput, Map<String, String>.class);
		List<User> newList = (List<User>) JSON.deserialize(input.get('newList'), List<User>.class);
		Map<Id, User> oldMap = (Map<Id, User>) JSON.deserialize(input.get('oldMap'), Map<Id, User>.class);

		if (oldMap.size() == 0) {
			oldMap = null;
		}

		Schema.FieldSet fs = SObjectType.User.fieldSets.getMap().get('User_History_Tracked_Fields');
		if (fs == null) return;
		List<Schema.FieldSetMember> members = fs.getFields();
		if (members.isEmpty()) return;

		List<User_History__c> histories = new List<User_History__c>();

		Map<String, Set<Id>> refsByType = new Map<String, Set<Id>>();
		List<PendingNameEntry> pendingNameEntries = new List<PendingNameEntry>();

		Map<String, Schema.SObjectField> userFields = Schema.SObjectType.User.fields.getMap();

		for (User newU : newList) {
			User oldU = (oldMap != null) ? oldMap.get(newU.Id) : null;
			for (Schema.FieldSetMember fsm : members) {
				String fieldApi = fsm.getFieldPath();
				if (!userFields.containsKey(fieldApi)) continue;
				Schema.DescribeFieldResult dfr = userFields.get(fieldApi).getDescribe();

				Object oldVal = (oldU == null) ? null : oldU.get(fieldApi);
				Object newVal = newU.get(fieldApi);

				if (areEqual(oldVal, newVal)) continue;

				if (dfr.getType() == Schema.DisplayType.REFERENCE) {
					User_History__c idHist = new User_History__c(
							Date__c = System.now(),
							Field__c = fieldApi + ' (Id)',
							Old_Value__c = (oldVal == null) ? null : String.valueOf(oldVal),
							New_Value__c = (newVal == null) ? null : String.valueOf(newVal),
							User__c = newU.Id
					);
					histories.add(idHist);

					PendingNameEntry p = new PendingNameEntry();
					p.userId = newU.Id;
					p.fieldApi = fieldApi;
					p.oldId = (oldVal == null) ? null : (Id)oldVal;
					p.newId = (newVal == null) ? null : (Id)newVal;
					pendingNameEntries.add(p);

					List<Schema.SObjectType> refTo = dfr.getReferenceTo();
					if (!refTo.isEmpty()) {
						String refType = refTo[0].getDescribe().getName();
						if (p.oldId != null) {
							if (!refsByType.containsKey(refType)) refsByType.put(refType, new Set<Id>());
							refsByType.get(refType).add(p.oldId);
						}
						if (p.newId != null) {
							if (!refsByType.containsKey(refType)) refsByType.put(refType, new Set<Id>());
							refsByType.get(refType).add(p.newId);
						}
					}
				} else {
					User_History__c hist = new User_History__c(
							Date__c = System.now(),
							Field__c = fieldApi,
							Old_Value__c = (oldVal == null) ? null : convertToString(oldVal),
							New_Value__c = (newVal == null) ? null : convertToString(newVal),
							User__c = newU.Id
					);
					histories.add(hist);
				}
			}
		}

		Map<String, Map<Id, String>> namesByTypeAndId = new Map<String, Map<Id, String>>();
		for (String sObjectTypeName : refsByType.keySet()) {
			Set<Id> ids = refsByType.get(sObjectTypeName);
			if (ids == null || ids.isEmpty()) continue;
			String q = 'SELECT Id, Name FROM ' + sObjectTypeName + ' WHERE Id IN :ids';
			try {
				List<SObject> rows = Database.query(q);
				Map<Id, String> subMap = new Map<Id, String>();
				for (SObject r : rows) subMap.put((Id)r.get('Id'), String.valueOf(r.get('Name')));
				namesByTypeAndId.put(sObjectTypeName, subMap);
			} catch (Exception e) {
				namesByTypeAndId.put(sObjectTypeName, new Map<Id,String>());
			}
		}

		for (PendingNameEntry p : pendingNameEntries) {
			Schema.DescribeFieldResult dfr = userFields.get(p.fieldApi).getDescribe();
			List<Schema.SObjectType> refTo = dfr.getReferenceTo();
			String refType = (!refTo.isEmpty()) ? refTo[0].getDescribe().getName() : null;

			String oldName = null;
			String newName = null;
			if (refType != null && namesByTypeAndId.containsKey(refType)) {
				Map<Id, String> sub = namesByTypeAndId.get(refType);
				if (p.oldId != null) oldName = sub.get(p.oldId);
				if (p.newId != null) newName = sub.get(p.newId);
			}

			if (oldName == null && p.oldId != null) oldName = String.valueOf(p.oldId);
			if (newName == null && p.newId != null) newName = String.valueOf(p.newId);

			User_History__c nameHist = new User_History__c(
					Date__c = System.now(),
					Field__c = p.fieldApi,
					Old_Value__c = oldName,
					New_Value__c = newName,
					User__c = p.userId
			);
			histories.add(nameHist);
		}

		if (!histories.isEmpty()) {
			try {
				insert histories;
			} catch (Exception e) {
				System.debug('UserHistoryHandler insert error: ' + e.getMessage());
			}
		}
	}

	private static Boolean areEqual(Object a, Object b) {
		if (a == null && b == null) return true;
		if (a == null || b == null) return false;
		return String.valueOf(a).equals(String.valueOf(b));
	}

	private static String convertToString(Object val) {
		if (val == null) return null;
		if (val instanceof Date) return ((Date)val).format();
		if (val instanceof Datetime) return ((Datetime)val).format();
		return String.valueOf(val);
	}

	private class PendingNameEntry {
		public Id userId;
		public String fieldApi;
		public Id oldId;
		public Id newId;
	}
}