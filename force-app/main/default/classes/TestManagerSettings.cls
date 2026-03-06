@isTest
private class TestManagerSettings{
	
@istest (seealldata=true)
	static void test1() {
	    ManagerSettingsController msc = new ManagerSettingsController();
	    msc.changeProfile();
	    //msc.createProfileOptions();
		msc.changeProfile();  
		//msc.saveSettings();
		msc.setToDefault();
	}
}