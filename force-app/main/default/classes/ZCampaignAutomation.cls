/*
 * @Update 2020-11-27
 * @Update 2021-02-11 - Developer Synebo
 *
 * @Author: ZedXagE 
 * @Date: 2019-02-28 11:06:41 
 * @Last Modified by: ZedXagE
 * @Last Modified time: 2019-02-28 16:00:23
 */

public class ZCampaignAutomation {
	public static String getCleanName(String s){
		if(s!=null)	return s.tolowercase().replaceAll('[^a-zA-Z0-9]','');
		return null;
	}
	public class objcheck{
		public String obj;
		public String recid;
		public String formname;
		public String subj;
		public objcheck(String ob, String rec, String form, String sub){
			obj = ob;
			recid = rec;
			formname = form;
			subj = sub;
		}
	}
	public static void Handler(List <objcheck> objs) {
		List <CampaignMember> campmems4up = new List <CampaignMember>();
		List <Campaign> camps4up = new List <Campaign>();
		for(objcheck rec:objs){
			String obj = rec.obj, recid = rec.recid, formname = rec.formname, subj = rec.subj;
			if(subj!=null&&subj!=''&&(formname.contains('Webinar Recorded')|| formname.contains('Report') || (formname.contains('Zoom') && (formname.contains('Registered') || formname.contains('Attended')) ))){
				Map <String,String> dict = new Map <String,String>();
				for(Website_SF_Associated_Campaign__c  wsa:[select Website__c,Campaign__c from Website_SF_Associated_Campaign__c])
					dict.put(wsa.Website__c!=null?getCleanName(wsa.Website__c):null, wsa.Campaign__c!=null?getCleanName(wsa.Campaign__c):null);
				Campaign camp = null;
				CampaignMember campmem = null;
				//try translated
				String CleanSubj = subj!=null?getCleanName(subj):null;
				if(dict.containsKey(CleanSubj)){
					List <Campaign> camps = [select id,Status,(select id,Status from CampaignMembers where LeadOrContactId=:recid limit 1) from Campaign where Clean_Name__c=:dict.get(CleanSubj) limit 1];
					if(camps.size()>0){
						camp = camps[0];
						if(camp.CampaignMembers.size()>0)	campmem = camp.CampaignMembers[0];
					}
				}
				//try name
				if(camp == null){
					subj = subj.left(80);
					CleanSubj = subj!=null?getCleanName(subj):null;
					List <Campaign> camps = [select id,Status,(select id,Status from CampaignMembers where LeadOrContactId=:recid limit 1) from Campaign where Clean_Name__c=:CleanSubj limit 1];
					if(camps.size()>0){
						camp = camps[0];
						if(camp.CampaignMembers.size()>0)	campmem = camp.CampaignMembers[0];
					}
				}
				//not found camp
				if(camp == null)
					camp = createCamp(formname, subj);
				//check completed
				else if(formname.contains('Webinar Recorded')&&camp.Status=='In Progress')
					camps4up.add(camp);
				//not found campmember
				if(camp!=null){
					if(campmem == null){
						campmem = new CampaignMember(CampaignId=camp.id);
						if(obj=='Lead')	campmem.LeadId = recid;
						else			campmem.ContactId = recid;
						if(formname.contains('Webinar Recorded'))	campmem.Status = 'Watched on Demand';
						else if(formname.contains('Report'))		campmem.Status = 'Sent';
						else if(formname.contains('Zoom')){
							if(formname.contains('Registered'))		campmem.Status = 'Registered';
							else if(formname.contains('Attended'))	campmem.Status = 'Attended';
						}
						campmems4up.add(campmem);
					}
					else{
						String oldstat = campmem.Status;
						if(formname.contains('Webinar Recorded')){
							if(oldstat == 'No Show' || oldstat == 'Registered')	campmem.Status = 'Watched on Demand';
						}
						else if(formname.contains('Zoom') && formname.contains('Attended')){
							if(oldstat == 'Registered')				campmem.Status = 'Attended';
						}
						if(campmem.Status != oldstat)	campmems4up.add(campmem);
					}
				}
			}
		}
		if(campmems4up.size()>0) upsert campmems4up;
		//check comleted to campign
		try{
			for(Campaign camp:camps4up)
				camp.Status='Completed';
			update camps4up;
		}	catch(exception e){}
	}

	public static Campaign createCamp(String formname, String subj) {
		Campaign camp = new Campaign(Name=subj, IsActive=true, Department__c='Marketing');
		if(formname.contains('Webinar Recorded')){
			camp.Status = 'Completed';
			camp.Type = 'Webinar';
		}
		else if(formname.contains('Report')){
			camp.Status = 'In Progress';
			camp.Type = 'White Paper';
		}
		else if(formname.contains('Zoom')){
			camp.Status = 'In Progress';
			camp.Type = 'Webinar';
		}
		insert camp;
		return camp;
	}

	/*
	*  The method creates a company if Campaign does not exist with the same name and creates a CampaignMember for it.
	*  Or it finds an existing Campaign and creates a CampaignMember for it.named
	*
	* @param: objectIdToCampaignNameMap - Map with ID of the object (Contact \ Lead) and the name of the Campaign
	* @param: newMap - Trigger.newMap
	*/

	public static Id createCampaignFromLeadCapture(LeadCaptureService.CampaignAndMemberLeadCaptureWrapper captureWrapper){ // test with class LeadCaptureServiceTest
		System.debug('captureWrapper--'+captureWrapper);
		// last request 30.10.23
		Id defaultCampaignId;
		List<General_Key_Value_pair__mdt> gnSetting = [SELECT Value__c FROM General_Key_Value_pair__mdt WHERE ProcessName__c = 'ZCampaignAutomation' AND Key__c = 'Default Campaign' AND Value__c != null];
		if(!gnSetting.isEmpty()){
			defaultCampaignId = gnSetting[0].Value__c;
		}
		// last request 30.10.23


		String campaignWrapperName = '';
		campaignWrapperName += String.isNotBlank(captureWrapper.campaignName) ? captureWrapper.campaignName : '';
//		campaignWrapperName += String.isNotBlank(captureWrapper.campaign_Source_UTM) ? ' - '+captureWrapper.campaign_Source_UTM : '';
//		campaignWrapperName += String.isNotBlank(captureWrapper.campaign_Medium_UTM) ? ' - '+ captureWrapper.campaign_Medium_UTM : ' - Organic';
		campaignWrapperName += String.isNotBlank(captureWrapper.asset_type) ? ' - '+captureWrapper.asset_type : ' - Null';
		if(campaignWrapperName.length()>80){
			campaignWrapperName = campaignWrapperName.substring(0, 80);

			//Removes space characters at the start and end of a string. For the correct execution of query.
			campaignWrapperName = campaignWrapperName.trim();
		}
		String sfCampIdFromLeadCapture = captureWrapper.campaignId;
		String query = 'SELECT Id FROM Campaign';
		query += ' WHERE Name =: campaignWrapperName';
		query += isValidId(captureWrapper.campaignId) ? ' OR Id =: sfCampIdFromLeadCapture' : '';
		query += defaultCampaignId != null ? ' OR Id =:defaultCampaignId' : '';
		List<Campaign> campaignList = Database.query(query);
		Map<Id,Campaign> campaignMap = new Map<Id, Campaign>(campaignList);
		Id campaignId;
		System.debug('campaignMap--'+campaignMap);
		System.debug('captureWrapper.campaignId--'+captureWrapper.campaignId);
		System.debug('query--'+query);
		System.debug('defaultCampaignId--'+defaultCampaignId);

		if(captureWrapper.campaignId != null){
			System.debug('campaignMap--'+campaignMap);
			if(isValidId(captureWrapper.campaignId) && campaignMap.containsKey(captureWrapper.campaignId)){
				System.debug('isValidId + contains');
				campaignId = captureWrapper.campaignId;
			}else {
				System.debug('not valid or not contains');
				campaignId = campaignMap.isEmpty() ? createCampaign(captureWrapper,campaignWrapperName) : defaultCampaignId;
			}
		}else{
			if(defaultCampaignId != null){
				if(campaignMap.size() == 2){
					for(Id foundCampaignId : campaignMap.keySet()){
						if(foundCampaignId != defaultCampaignId){
							campaignId = foundCampaignId;
						}
					}
				}else{
					campaignId = createCampaign(captureWrapper,campaignWrapperName);
				}
			}else{
				if(campaignMap.isEmpty()){
					campaignId = createCampaign(captureWrapper,campaignWrapperName);
				}else{
					campaignId = new List<Campaign>(campaignMap.values())[0].Id;
				}
			}
		}
		createCampaignMember(captureWrapper,campaignId);
		return campaignId;
	}

	private static boolean isValidId(String campIdFromLeadCapture){

		if(campIdFromLeadCapture != null){
			if (campIdFromLeadCapture.length() == 15 || campIdFromLeadCapture.length() == 18) {
				if(campIdFromLeadCapture.startsWith('701')){
					String regexPattern = '^[a-zA-Z0-9\\+/=]*$';
					Pattern pattern = Pattern.compile(regexPattern);
					Matcher matcher = pattern.matcher(campIdFromLeadCapture);
					return matcher.find();
				}
			}
		}
		return false;
	}

	private static void createCampaignMember(LeadCaptureService.CampaignAndMemberLeadCaptureWrapper captureWrapper ,Id campaignId){
		System.debug('campaignId--'+campaignId);
		CampaignMember campaignMemberToUpsert;
		List<CampaignMember> existingCampaignMembers = [SELECT Id,CampaignId,LeadId,ContactId,Email
		FROM CampaignMember
		WHERE CampaignId = :campaignId
		AND Email =:captureWrapper.Email];

		Map<String,CampaignMember> keyToCampaignMemberMap = new Map<String, CampaignMember>();
		System.debug('existingCampaignMembers--'+existingCampaignMembers);
		for(CampaignMember existing : existingCampaignMembers){
			String key = existing.CampaignId;
			key += existing.Email;
			keyToCampaignMemberMap.put(key.toLowercase(),existing);
		}
		System.debug('keyToCampaignMemberMap--'+keyToCampaignMemberMap);

		String wrapperKey = (campaignId +''+ captureWrapper.Email).toLowerCase();
		if(!keyToCampaignMemberMap.containsKey(wrapperKey)){
			campaignMemberToUpsert = new CampaignMember();
			campaignMemberToUpsert.CampaignId = campaignId;
		}else {
			campaignMemberToUpsert = keyToCampaignMemberMap.get(wrapperKey);
		}
		fillBasicCampaignMemberData(campaignMemberToUpsert, captureWrapper);
		System.debug('campaignMemberToUpsert--'+campaignMemberToUpsert);

		upsert campaignMemberToUpsert;

	}

	private static void fillBasicCampaignMemberData(CampaignMember campaignMemberToUpsert, LeadCaptureService.CampaignAndMemberLeadCaptureWrapper captureWrapper) {
		System.debug('captureWrapper.objectId--'+captureWrapper.objectId);
		if(captureWrapper.typeOfParent == 'Lead'){
			if(String.isBlank(campaignMemberToUpsert.LeadId)){
				campaignMemberToUpsert.LeadId = captureWrapper.objectId;
			}
		}else{
			if(String.isBlank(campaignMemberToUpsert.ContactId)){
				campaignMemberToUpsert.ContactId = captureWrapper.objectId;
			}
		}
		campaignMemberToUpsert.SfCmpid_from_leadCapture__c = captureWrapper.campaignId;
		campaignMemberToUpsert.Campaign_name_from_leadcapture__c = captureWrapper.campaignName;
		campaignMemberToUpsert.Status = captureWrapper.status;
		campaignMemberToUpsert.Referrer__c = captureWrapper.referrer;
		campaignMemberToUpsert.Landing_Page__c = captureWrapper.landingPage;
		campaignMemberToUpsert.Affiliate_id__c = captureWrapper.affiliate_id;
		campaignMemberToUpsert.Asset_Type__c = captureWrapper.asset_type;
		campaignMemberToUpsert.Call_Id__c = captureWrapper.call_Id;
		campaignMemberToUpsert.Campaign_Content_UTM__c = captureWrapper.campaign_Content_UTM;
		campaignMemberToUpsert.Campaign_Name_UTM__c = captureWrapper.campaign_Name_UTM;
		campaignMemberToUpsert.Campaign_Medium_UTM__c = String.isNotBlank(captureWrapper.campaign_Medium_UTM) ? captureWrapper.campaign_Medium_UTM : 'Organic';
		campaignMemberToUpsert.Campaign_Source_UTM__c = captureWrapper.campaign_Source_UTM;
		campaignMemberToUpsert.Campaign_Term_UTM__c = captureWrapper.campaign_Term_UTM;
		//campaignMemberToUpsert.Country = captureWrapper.country;
		campaignMemberToUpsert.Form_URL__c = captureWrapper.form_URL;
		campaignMemberToUpsert.External_Campaign_Id__c = captureWrapper.external_campaign_id;
		campaignMemberToUpsert.Browser_Language__c = captureWrapper.Browser_Language;
		campaignMemberToUpsert.Form_File_Name__c = captureWrapper.form_file_name;
		campaignMemberToUpsert.Form_File_URL__c = captureWrapper.form_file_URL;
//		campaignMemberToUpsert.LeadSource = captureWrapper.leadSource;
		System.debug('campaignMemberToUpsert--'+campaignMemberToUpsert.LeadId);
		System.debug('campaignMemberToUpsert--'+campaignMemberToUpsert.ContactId);
		System.debug('campaignMemberToUpsert--'+campaignMemberToUpsert.Campaign_Name_UTM__c);
		System.debug('campaignMemberToUpsert--'+campaignMemberToUpsert.Campaign_Medium_UTM__c);
		System.debug('campaignMemberToUpsert--'+campaignMemberToUpsert.Campaign_Source_UTM__c);
		System.debug('campaignMemberToUpsert--'+campaignMemberToUpsert.Campaign_Term_UTM__c);
		System.debug('campaignMemberToUpsert--'+campaignMemberToUpsert);
	}
	private static Id createCampaign(LeadCaptureService.CampaignAndMemberLeadCaptureWrapper captureWrapper,String campaignWrapperName){
		Campaign camp = new Campaign();
		camp.Name = campaignWrapperName;
		camp.Department__c = 'Marketing';
		camp.IsActive = true;
		camp.Campain_Name_UTM__c = captureWrapper.campaign_Name_UTM;
		camp.Campaign_Source_UTM__c = captureWrapper.campaign_Source_UTM;
		camp.Type = captureWrapper.asset_type;
		camp.Solution__c = captureWrapper.campaign_Solution;
		camp.Landing_page__c = captureWrapper.form_URL;
		camp.Campaign_CTA__c = captureWrapper.button_Caption;
		camp.Campaign_Medium_UTM__c = String.isNotBlank(captureWrapper.campaign_Medium_UTM) ? captureWrapper.campaign_Medium_UTM : 'Organic';
		camp.Asset_Type__c = String.isNotBlank(captureWrapper.asset_type) ? captureWrapper.asset_type : 'Null';
		System.debug('camp--'+camp);
		insert camp;
		return camp.Id;
	}

}