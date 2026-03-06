/*
 * @Author: ZedXagE - ITmyWay 
 * @Date: 2018-12-25 09:50:43 
 * @Last Modified by: ZedXagE
 * @Last Modified time: 2019-02-28 15:02:17
 */

public class ITmyWayEngagementController {
    //For Triggers
    public static void createTask(Map <String,List<String>> ups){
        List <Task> tasks = new List <Task>();
        for(String recid:ups.keySet())
            for(String subj:ups.get(recid)){
                Task tas = new Task(Whoid=recid,Subject=subj,Status='Completed');
                tasks.add(tas);
            }
        insert tasks;
    }
    public class oauthres{
        public String api_key;
    }
    public class prospectres{
        public result result;
    }
    public class result{
        @AuraEnabled
        public integer total_results;
        @AuraEnabled
        public List <visitor_activity> visitor_activity;
    }
    public class emailres{
        public email email;
    }
    public class email{
        public String name;
    }
    public static Map <String,String> formnames = new Map <String,String>{
        '64k8mj'=>'Webinar Upcoming',
        '64k8ml'=>'Webinar Recorded',
        '64k8mn'=>'Report',
        '64dgkj'=>'Registration',
        '64k8mg'=>'Fro Hooks',
        '64dgkn'=>'Contact Support',
        '64k8md'=>'Contact Sales',
        '64k8mb'=>'Contact Pricing',
        '64k8m8'=>'Contact API'
    };
    public static Map <String,String> icons = new Map <String,String>{
        'Email Tracker'=>'standard:link',
        'Landing Page'=>'standard:contract',
        'Form Handler'=>'standard:task',
        'Visit'=>'standard:business_hours',
        'Email'=>'standard:email',
        'New Opportunity'=>'standard:opportunity',
        'Email2'=>'standard:email_chatter',
        'Default'=>'standard:survey',
        'Opportunity Associated'=>'standard:opportunity',
        'Visitor'=>'standard:business_hours',
        'Custom Redirect'=>'standard:link'
    };
    public static Map <String,String> headers = new Map <String,String>{
        'Email Tracker Click'=>'Tracked Link Clicked',
        'Visit'=>'Website Visit',
        'Visitor'=>'Website Visit'
    };
    public static Map <Integer,String> addtype = new Map <Integer,String>{
        1=>' Click',
        2=>' View',
        4=>' Success',
        6=>' Sent',
        11=>' Open'
    };
    public class visitor_activity{
        @AuraEnabled    
        public Long id;
        @AuraEnabled    
        public Integer type;
        @AuraEnabled    
        public String type_name;
        @AuraEnabled    
        public String grpname;
        @AuraEnabled    
        public String header;
        @AuraEnabled    
        public String details;
        @AuraEnabled    
        public String icon;
        @AuraEnabled    
        public String created_at;
        @AuraEnabled    
        public Datetime created_at_new;
        @AuraEnabled    
        public Boolean init;
        @AuraEnabled    
        public Boolean showmore;
        @AuraEnabled
        public Long email_id;
        @AuraEnabled
        public Long list_email_id;
        @AuraEnabled
        public Long visit_id;
        @AuraEnabled
        public List <visit> visits;
    }
    public class visit implements Comparable {
        @AuraEnabled    
        public String url;
        @AuraEnabled    
        public String title;
        @AuraEnabled    
        public String created_at;
        @AuraEnabled    
        public Datetime created_at_new;
        public Integer compareTo(Object compareTo) {
            visit compareToEmp = (visit)compareTo;
            if (created_at_new == compareToEmp.created_at_new) return 0;
            if (created_at_new < compareToEmp.created_at_new) return 1;
            return -1;       
        }

    }
    public static final integer loadnum = 10;
    @AuraEnabled
    public static String getProspectId(String recid, String sobjectname){
        List <sobject> sobs =Database.query('select Pardot_id__c from '+sobjectname+' where id=\''+recid+'\' limit 1');
        if(sobs.size()==1)
            return (String) sobs[0].get('Pardot_id__c');
        else
            return null;
    }
    @AuraEnabled
    public static String getParams(){
        List <Pardot_API__c> cred = [select Username__c, Password__c, User_Key__c from Pardot_API__c where name='Default' limit 1];
        if(cred.size()>0){
            HttpResponse oauth = zedHTTP('https://pi.pardot.com/api/login/version/4?format=json','POST', 'email='+cred[0].Username__c+'&password='+cred[0].Password__c+'&user_key='+cred[0].User_Key__c,null);
            if(Test.isRunningTest()){
                oauth = new HttpResponse();
                oauth.setBody('{"@attributes": {"stat": "ok","version": 1},"api_key": "5b5f2f43fb8cfe0d3238223af4cad00e","version": 4}');
            }
            if(oauth!=null){
                System.debug(oauth.getBody());
                if(oauth.getBody()!=null){
                    oauthres oauthres = (oauthres) JSON.deserialize(oauth.getBody(), oauthres.class);
                    if(oauthres.api_key!=null)
                        return 'api_key='+oauthres.api_key+'&user_key='+cred[0].User_Key__c;
                }
            }
        }
        return null;
    }
    public static datetime getdat(String dattim){
        String dat = dattim.split(' ')[0];
        String tim = dattim.split(' ')[1];
        String [] datspl = dat.split('-');
        String [] timspl = tim.split(':');
        Datetime newdat = Datetime.newInstance(Integer.valueof(datspl[0]),Integer.valueof(datspl[1]),Integer.valueof(datspl[2]),Integer.valueof(timspl[0]),Integer.valueof(timspl[1]),Integer.valueof(timspl[2]));
        return newdat;
    }
    public static String checkUrl(String str){
        if(str!=null&&str.left(4)=='http'){
            return '<a href="'+str+'" target="_blank">'+str+'</a>';
        }
        return str;
    }
    @AuraEnabled
    public static result getVisitors(String recid, String prospectid, String params){
        result result = new result();
        HttpResponse res = zedHTTP('https://pi.pardot.com/api/visitorActivity/version/4/do/query','POST', 'prospect_id='+prospectid+'&format=json&sort_by=created_at&sort_order=descending&'+params,params);
        if(Test.isRunningTest()){
            res = new HttpResponse();
            res.setBody('{"@attributes": {"stat": "ok","version": 1},"result": {"total_results": 153,"visitor_activity": [{"id": 1303819326,"visitor_id": 267998706,"prospect_id": 97972912,"type": 15,"type_name": null,"created_at": "2018-09-27 12:05:09"},{"id": 1320934807,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "4 page views","visit_id": 336215707,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-10-18 12:27:28"},{"id": 1323765903,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "2 page views","visit_id": 337338183,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-10-22 10:11:17"},{"id": 1323964655,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "4 page views","visit_id": 337432955,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-10-22 16:12:33"},{"id": 1324765479,"visitor_id": 272874353,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "15 page views","visit_id": 337740279,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-10-23 11:16:21"},{"id": 1326482369,"visitor_id": 272874353,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "1 page views","visit_id": 338247005,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-10-24 15:40:30"},{"id": 1327485085,"visitor_id": 272874353,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "3 page views","visit_id": 338621775,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-10-25 13:35:56"},{"id": 1330300211,"visitor_id": 272874353,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "6 page views","visit_id": 339480033,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-10-28 12:16:35"},{"id": 1330842383,"visitor_id": 272874353,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "2 page views","visit_id": 339709443,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-10-29 10:14:27"},{"id": 1330860133,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "1 page views","visit_id": 339719059,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-10-29 10:53:40"},{"id": 1333915903,"visitor_id": 272874353,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "6 page views","visit_id": 340512883,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-10-31 10:42:43"},{"id": 1347935756,"prospect_id": 97972912,"type": 6,"type_name": "Email","details": "B2B test","email_id": 545445946,"list_email_id": 545445944,"email_template_id": 42121,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-11-12 09:13:09"},{"id": 1347936222,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "B2B test","email_id": 545445946,"list_email_id": 545445944,"email_template_id": 42121,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-11-12 09:15:16"},{"id": 1347936266,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://www.facebook.com/SimilarWeb/","email_id": 545445946,"list_email_id": 545445944,"email_template_id": 42121,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-11-12 09:15:22"},{"id": 1347950162,"prospect_id": 97972912,"type": 6,"type_name": "Email","details": "Subject","email_id": 545445958,"list_email_id": 545445956,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-11-12 09:50:38"},{"id": 1347959118,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Subject","email_id": 545445958,"list_email_id": 545445956,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-11-12 10:14:36"},{"id": 1347970936,"prospect_id": 97972912,"type": 6,"type_name": "Email","details": "Subject b2b","email_id": 545446358,"list_email_id": 545446356,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-11-12 10:39:33"},{"id": 1347971280,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Subject b2b","email_id": 545446358,"list_email_id": 545446356,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-11-12 10:41:35"},{"id": 1347971282,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%CTA_URL%%","email_id": 545446358,"list_email_id": 545446356,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-11-12 10:41:35"},{"id": 1348023392,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "2 page views","visit_id": 344328948,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-11-12 12:05:15"},{"id": 1348023770,"visitor_id": 272874353,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "1 page views","visit_id": 344329140,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-11-12 12:05:35"},{"id": 1348033586,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "B2B test","email_id": 545445946,"list_email_id": 545445944,"email_template_id": 42121,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-11-12 12:22:00"},{"id": 1348034152,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "B2B test","email_id": 545445946,"list_email_id": 545445944,"email_template_id": 42121,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-11-12 12:23:17"},{"id": 1348035414,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "B2B test","email_id": 545445946,"list_email_id": 545445944,"email_template_id": 42121,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-11-12 12:26:25"},{"id": 1349064994,"prospect_id": 97972912,"type": 6,"type_name": "Email","details": "Subject","email_id": 545732080,"list_email_id": 545732078,"email_template_id": 42127,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-11-13 11:19:26"},{"id": 1351237558,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "2 page views","visit_id": 345333386,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-11-14 16:50:34"},{"id": 1351239394,"visitor_id": 272874353,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "3 page views","visit_id": 345334274,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-11-14 16:52:36"},{"id": 1352839832,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "1 page views","visit_id": 345783898,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-11-15 17:33:22"},{"id": 1355455972,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "9 page views","visit_id": 346527694,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-11-18 11:31:31"},{"id": 1355456112,"visitor_id": 272874353,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "3 page views","visit_id": 346527768,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-11-18 10:46:15"},{"id": 1355473864,"visitor_id": 272874353,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "1 page views","visit_id": 346536466,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-11-18 12:08:10"},{"id": 1357278427,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "3 page views","visit_id": 347138391,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-11-20 10:08:15"},{"id": 1373314923,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "1 page views","visit_id": 351286139,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-11-28 15:56:36"},{"id": 1374583627,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "2 page views","visit_id": 351838005,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-11-29 10:16:54"},{"id": 1379811059,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "2 page views","visit_id": 353540161,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-02 08:52:47"},{"id": 1379916739,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "1 page views","visit_id": 353592957,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-02 12:09:31"},{"id": 1400079717,"visitor_id": 288731915,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "7 page views","visit_id": 360227589,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-12 15:52:07"},{"id": 1400103445,"visitor_id": 288731915,"prospect_id": 97972912,"type": 21,"type_name": "Custom Redirect","details": "google test","campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-12 14:19:31"},{"id": 1408976339,"visitor_id": 288731915,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "1 page views","visit_id": 363048539,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-17 10:34:18"},{"id": 1408985249,"visitor_id": 272874353,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "4 page views","visit_id": 363053199,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-17 10:48:33"},{"id": 1409380933,"visitor_id": 272874353,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "3 page views","visit_id": 363158987,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-17 15:18:29"},{"id": 1409400361,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "12 page views","visit_id": 363165839,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-17 16:52:21"},{"id": 1411109963,"visitor_id": 288731915,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "6 page views","visit_id": 363705547,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-18 10:07:08"},{"id": 1411190419,"visitor_id": 272874353,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "3 page views","visit_id": 363736923,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-18 11:05:15"},{"id": 1411198487,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "4 page views","visit_id": 363740833,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-18 11:18:00"},{"id": 1411255043,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "2 page views","visit_id": 363767545,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-18 12:31:07"},{"id": 1413348093,"prospect_id": 97972912,"type": 6,"type_name": "Email","details": "Subject","email_id": 566634497,"list_email_id": 566634495,"email_template_id": 42133,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-19 08:54:57"},{"id": 1415340681,"visitor_id": 288731915,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "7 page views","visit_id": 364986137,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-20 10:55:38"},{"id": 1415394951,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "1 page views","visit_id": 365014921,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-20 10:54:41"},{"id": 1415554769,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "5 page views","visit_id": 365093099,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-20 14:40:07"},{"id": 1419411577,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "6 page views","visit_id": 366325849,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-23 10:05:30"},{"id": 1419528165,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "4 page views","visit_id": 366384959,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-23 14:47:41"},{"id": 1420635829,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "1 page views","visit_id": 366647947,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-24 08:20:42"},{"id": 1420665357,"visitor_id": 272874353,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "2 page views","visit_id": 366663083,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-24 09:23:27"},{"id": 1420716745,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "4 page views","visit_id": 366689857,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-24 11:20:30"},{"id": 1421484877,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "8 page views","visit_id": 366997563,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-25 08:42:44"},{"id": 1421485225,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Contact Sales","form_handler_id": 3867,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-25 08:33:14"},{"id": 1421486219,"visitor_id": 267998706,"prospect_id": 97972912,"type": 21,"type_name": "Custom Redirect","details": "google test","campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-25 08:35:30"},{"id": 1421488369,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Report","form_handler_id": 3875,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-25 08:40:00"},{"id": 1421489649,"visitor_id": 267998706,"prospect_id": 97972912,"type": 2,"type_name": "Landing Page","details": "Landing Page Test","landing_page_id": 18893,"campaign": {"id": 63305,"name": "Landing Page"},"created_at": "2018-12-25 08:42:42"},{"id": 1421493125,"prospect_id": 97972912,"type": 6,"type_name": "Email","details": "Subject","email_id": 568960665,"list_email_id": 568960663,"email_template_id": 42127,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-25 08:48:23"},{"id": 1421493759,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Subject","email_id": 568960665,"list_email_id": 568960663,"email_template_id": 42127,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-25 08:51:58"},{"id": 1421493761,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "http://bit.ly/2V80FkU","email_id": 568960665,"list_email_id": 568960663,"email_template_id": 42127,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-25 08:51:58"},{"id": 1421504981,"visitor_id": 267998706,"prospect_id": 97972912,"type": 4,"type_name": "Landing Page","details": "Landing Page Test","landing_page_id": 18893,"campaign": {"id": 63305,"name": "Landing Page"},"created_at": "2018-12-25 09:09:04"},{"id": 1421536731,"prospect_id": 97972912,"type": 6,"type_name": "Email","details": "Subject","email_id": 568964675,"list_email_id": 568964671,"email_template_id": 43599,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-25 10:21:33"},{"id": 1421539501,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Subject","email_id": 568964675,"list_email_id": 568964671,"email_template_id": 43599,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-25 10:28:51"},{"id": 1421539995,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://www.linkedin.com/company/similarweb","email_id": 568964675,"list_email_id": 568964671,"email_template_id": 43599,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-25 10:30:07"},{"id": 1421540485,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Subject","email_id": 568964675,"list_email_id": 568964671,"email_template_id": 43599,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-25 10:31:15"},{"id": 1421541523,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Subject","email_id": 568964675,"list_email_id": 568964671,"email_template_id": 43599,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-25 10:33:41"},{"id": 1421552187,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Subject","email_id": 568964675,"list_email_id": 568964671,"email_template_id": 43599,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-25 10:58:46"},{"id": 1421579637,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Subject","email_id": 568964675,"list_email_id": 568964671,"email_template_id": 43599,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-25 12:06:51"},{"id": 1421580211,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Subject","email_id": 568964675,"list_email_id": 568964671,"email_template_id": 43599,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-25 12:08:20"},{"id": 1421584431,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Subject","email_id": 568964675,"list_email_id": 568964671,"email_template_id": 43599,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-25 12:18:25"},{"id": 1421587559,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Subject","email_id": 568964675,"list_email_id": 568964671,"email_template_id": 43599,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-25 12:26:24"},{"id": 1421613921,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Subject","email_id": 568964675,"list_email_id": 568964671,"email_template_id": 43599,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-25 13:34:06"},{"id": 1421621147,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Subject","email_id": 568964675,"list_email_id": 568964671,"email_template_id": 43599,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-25 13:52:11"},{"id": 1421625555,"visitor_id": 272874353,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "7 page views","visit_id": 367070553,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-25 14:45:00"},{"id": 1421640949,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Subject","email_id": 568964675,"list_email_id": 568964671,"email_template_id": 43599,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-25 14:39:22"},{"id": 1421643645,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Contact Sales","form_handler_id": 3867,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-25 14:45:48"},{"id": 1422603937,"visitor_id": 288731915,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "16 page views","visit_id": 367365639,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-26 12:05:26"},{"id": 1422605737,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Webinar Recorded","form_handler_id": 3873,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-26 11:18:30"},{"id": 1422617469,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Webinar Recorded","form_handler_id": 3873,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-26 11:43:22"},{"id": 1422620299,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Webinar Recorded","form_handler_id": 3873,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-26 11:49:45"},{"id": 1422629627,"visitor_id": 293761189,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "7 page views","visit_id": 367379327,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-26 12:14:26"},{"id": 1422632571,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Contact Support","form_handler_id": 3855,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-26 12:15:12"},{"id": 1422830323,"visitor_id": 288731915,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "4 page views","visit_id": 367413269,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-26 14:22:13"},{"id": 1423041923,"prospect_id": 97972912,"type": 6,"type_name": "Email","details": "Subject","email_id": 569539675,"list_email_id": 569539671,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 17:33:07"},{"id": 1423042959,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Subject","email_id": 569539675,"list_email_id": 569539671,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 17:35:37"},{"id": 1423042961,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%CTA_URL%%","email_id": 569539675,"list_email_id": 569539671,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 17:35:37"},{"id": 1423047067,"prospect_id": 97972912,"type": 6,"type_name": "Email","details": "Subject","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 17:38:21"},{"id": 1423049319,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Subject","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 17:42:27"},{"id": 1423049323,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 17:42:27"},{"id": 1423050489,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 17:44:04"},{"id": 1423055287,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 17:49:05"},{"id": 1423063831,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 17:59:07"},{"id": 1423095267,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 18:29:08"},{"id": 1423118645,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 18:59:09"},{"id": 1423141359,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 19:29:10"},{"id": 1423191527,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 19:59:12"},{"id": 1423213843,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 20:29:13"},{"id": 1423234091,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 20:59:15"},{"id": 1423278631,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 21:29:16"},{"id": 1423300247,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 21:59:17"},{"id": 1423322989,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 22:29:19"},{"id": 1423343575,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 22:59:20"},{"id": 1423368079,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 23:29:22"},{"id": 1423386889,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-26 23:59:23"},{"id": 1423404985,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 00:29:24"},{"id": 1423422673,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 00:59:25"},{"id": 1423440175,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 01:29:26"},{"id": 1423474725,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 01:59:28"},{"id": 1423508213,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 02:29:29"},{"id": 1423530773,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 02:59:30"},{"id": 1423548705,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 03:29:31"},{"id": 1423565989,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 03:59:32"},{"id": 1423585169,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 04:29:34"},{"id": 1423604511,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 04:59:35"},{"id": 1423627023,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 05:29:36"},{"id": 1423643951,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 05:59:37"},{"id": 1423660167,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 06:29:38"},{"id": 1423675533,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 06:59:39"},{"id": 1423690827,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 07:29:41"},{"id": 1423705657,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 07:59:42"},{"id": 1423719873,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 08:29:43"},{"id": 1423736505,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://%%Calendly_Link%%","email_id": 569540945,"list_email_id": 569540943,"email_template_id": 42145,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-27 08:59:44"},{"id": 1424324235,"visitor_id": 288731915,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "4 page views","visit_id": 367921135,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-27 17:51:17"},{"id": 1424325037,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Webinar Recorded","form_handler_id": 3873,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-27 17:51:49"},{"id": 1427410229,"visitor_id": 294925811,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "13 page views","visit_id": 368941545,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-30 11:01:52"},{"id": 1427432313,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Webinar Recorded","form_handler_id": 3873,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-30 09:58:59"},{"id": 1427442829,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Webinar Recorded","form_handler_id": 3873,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-30 10:23:23"},{"id": 1427450403,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Report","form_handler_id": 3875,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-30 10:40:13"},{"id": 1427457945,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Report","form_handler_id": 3875,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-30 10:58:24"},{"id": 1427459831,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Report","form_handler_id": 3875,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-30 11:02:25"},{"id": 1427504185,"prospect_id": 97972912,"type": 6,"type_name": "Email","details": "Subject","email_id": 570877279,"list_email_id": 570877273,"email_template_id": 42143,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-30 13:02:30"},{"id": 1427504417,"visitor_id": 294925811,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "2 page views","visit_id": 368989653,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-30 13:08:13"},{"id": 1427505137,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Subject","email_id": 570877279,"list_email_id": 570877273,"email_template_id": 42143,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-30 13:06:46"},{"id": 1427505139,"visitor_id": 294966743,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://www.similarweb.com/corp/contact/","email_id": 570877279,"list_email_id": 570877273,"email_template_id": 42143,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-30 13:06:46"},{"id": 1427505261,"visitor_id": 294966743,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "2 page views","visit_id": 368990107,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-30 14:05:06"},{"id": 1427505855,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Webinar Upcoming","form_handler_id": 3871,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-30 13:08:55"},{"id": 1428374677,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "11 page views","visit_id": 369300203,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-31 12:01:43"},{"id": 1428406057,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Webinar Recorded","form_handler_id": 3873,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-31 10:53:27"},{"id": 1428416593,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Report","form_handler_id": 3875,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-31 11:19:29"},{"id": 1428489673,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "3 page views","visit_id": 369358165,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-31 14:09:29"},{"id": 1428491887,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Webinar Recorded","form_handler_id": 3873,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-31 14:11:58"},{"id": 1428741351,"prospect_id": 97972912,"type": 6,"type_name": "Email","details": "Re: Test A ","email_id": 571274347,"list_email_id": 571274341,"email_template_id": 43331,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-31 16:16:47"},{"id": 1428754037,"prospect_id": 97972912,"type": 11,"type_name": "Email","details": "Re: Test A ","email_id": 571274347,"list_email_id": 571274341,"email_template_id": 43331,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-31 16:33:07"},{"id": 1428754041,"visitor_id": 267998706,"prospect_id": 97972912,"type": 1,"type_name": "Email Tracker","details": "https://www.similarweb.com/corp/chat-with-us/","email_id": 571274347,"list_email_id": 571274341,"email_template_id": 43331,"campaign": {"id": 58110,"name": "Email Plug-in"},"created_at": "2018-12-31 16:33:07"},{"id": 1428754127,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "1 page views","visit_id": 369402171,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2018-12-31 16:33:17"},{"id": 1432362437,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "3 page views","visit_id": 370528851,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2019-01-03 08:49:16"},{"id": 1432605565,"visitor_id": 267998706,"prospect_id": 97972912,"type": 20,"type_name": "Visit","details": "12 page views","visit_id": 370621993,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2019-01-03 14:44:26"},{"id": 1432610173,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Contact Support","form_handler_id": 3855,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2019-01-03 14:10:15"},{"id": 1432618379,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Contact API","form_handler_id": 3863,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2019-01-03 14:19:28"},{"id": 1432625739,"prospect_id": 97972912,"type": 4,"type_name": "Form Handler","details": "Contact Sales","form_handler_id": 3867,"campaign": {"id": 58108,"name": "Website Tracking"},"created_at": "2019-01-03 14:26:55"}]}}');
        }
        if(res!=null){
            System.debug(res.getBody());
            if(res.getBody()!=null){
                prospectres prospectres = (prospectres) JSON.deserialize(res.getBody(), prospectres.class);
                if(prospectres!=null&&prospectres.result!=null)
                    result = prospectres.result;
            }
        }
        //connect task
        List <Task> tasks = [select Subject,CreatedDate from Task where Whoid=:recid and Subject like: '%Form Handler:%' Order by CreatedDate DESC];
        Set <String> used = new Set <String>();
        Map <String, List <visit>> visitids = new Map <String, List <visit>>();
        if(result.visitor_activity!=null){
            for(integer i=0;i<result.visitor_activity.size();i++){
                if(result.visitor_activity[i].details!=null && result.visitor_activity[i].type_name!=null){
                    result.visitor_activity[i].init = false;
                    result.visitor_activity[i].details = checkUrl(result.visitor_activity[i].details);
                    result.visitor_activity[i].header = result.visitor_activity[i].type_name;
                    if(addtype.containsKey(result.visitor_activity[i].type))
                        result.visitor_activity[i].header += addtype.get(result.visitor_activity[i].type);
                    if(headers.containsKey(result.visitor_activity[i].header))
                        result.visitor_activity[i].header = headers.get(result.visitor_activity[i].header);
                    if(result.visitor_activity[i].header=='Landing Page Success')
                        result.visitor_activity[i].header = 'Form Success';
                    result.visitor_activity[i].created_at_new = getdat(result.visitor_activity[i].created_at);
                    if(icons.containsKey(result.visitor_activity[i].type_name)){
                        String emailopen = (result.visitor_activity[i].type_name=='Email'&&result.visitor_activity[i].type==11?'2':'');
                        result.visitor_activity[i].icon = icons.get(result.visitor_activity[i].type_name+emailopen);
                    }
                    else
                        result.visitor_activity[i].icon = icons.get('Default');
                    if(result.visitor_activity[i].visit_id!=null)
                        visitids.put(String.valueof(result.visitor_activity[i].visit_id), new List <visit>());
                    if(result.visitor_activity[i].type_name=='Visit'||result.visitor_activity[i].type_name=='Visitor'||result.visitor_activity[i].type_name=='Email'||result.visitor_activity[i].type_name=='Email Tracker'){
                        result.visitor_activity[i].showmore = true;
                        if(result.visitor_activity[i].type_name=='Email')
                            result.visitor_activity[i].details = 'Subject: '+result.visitor_activity[i].details;
                        else if(result.visitor_activity[i].type_name=='Email Tracker')
                            result.visitor_activity[i].details = 'Link: '+result.visitor_activity[i].details;
                    }
                    else{
                        result.visitor_activity[i].showmore = false;
                        result.visitor_activity[i].details = result.visitor_activity[i].type_name + ': '+ result.visitor_activity[i].details;
                    }
                    //task
                    result.visitor_activity[i].grpname = result.visitor_activity[i].header;
                    if(result.visitor_activity[i].type_name == 'Form Handler'){
                        for(task tas:tasks){
                            if(!used.contains(tas.id)&&tas.CreatedDate>=result.visitor_activity[i].created_at_new&&tas.CreatedDate<=result.visitor_activity[i].created_at_new.addMinutes(5)){
                                System.debug('Match: '+tas.subject+' form handler'+result.visitor_activity[i].details);
                                result.visitor_activity[i].details = tas.Subject;
                                used.add(tas.id);
                                break;
                            }
                        }
                        result.visitor_activity[i].grpname = result.visitor_activity[i].details;
                    }
                }
                else{
                    result.total_results--;
                    result.visitor_activity.remove(i);
                    i--;
                }
            }
        }
        System.debug(visitids);
        if(visitids.size()>0){
            String visitsstr = '';
            for(String s:visitids.keySet())
                visitsstr += s+',';
            visitsstr = visitsstr.left(visitsstr.length()-1);
            HttpResponse visres = zedHTTP('https://pi.pardot.com/api/visit/version/4/do/query','POST', 'ids='+visitsstr+'&format=json&'+params,params);
            if(Test.isRunningTest()){
                visres = new HttpResponse();
                visres.setBody('{"@attributes": {"stat": "ok","version": 1},"result": {"total_results": 1,"visit": {"id": 367413269,"visitor_id": 288731915,"prospect_id": 97972912,"visitor_page_view_count": 4,"first_visitor_page_view_at": "2018-12-26 14:21:37","last_visitor_page_view_at": "2018-12-26 14:22:13","duration_in_seconds": 36,"campaign_parameter": null,"medium_parameter": null,"source_parameter": null,"content_parameter": null,"term_parameter": null,"created_at": "2018-12-26 14:21:37","updated_at": "2018-12-27 17:50:50","visitor_page_views": {"visitor_page_view": [{"id": 1185759317,"url": "https://www.similarweb.ninja/corp/webinars/travel-beyond-booking-hotel-brands-new-players-changing-online-travel/","title": "Travel Beyond Booking: How Hotel Brands and New Players Are Changing Online Travel - Similarweb","created_at": "2018-12-26 14:21:37"},{"id": 1185759475,"url": "https://www.similarweb.ninja/corp/webinars/","title": "SEO, PPC and Marketing Strategy Webinars","created_at": "2018-12-26 14:21:49"},{"id": 1185759615,"url": "https://www.similarweb.ninja/corp/webinars/travel-beyond-booking-hotel-brands-new-players-changing-online-travel/","title": "Travel Beyond Booking: How Hotel Brands and New Players Are Changing Online Travel - Similarweb","created_at": "2018-12-26 14:21:59"},{"id": 1185759767,"url": "https://www.similarweb.ninja/corp/webinars/","title": "SEO, PPC and Marketing Strategy Webinars","created_at": "2018-12-26 14:22:13"}]}}}}');
            }
            if(visres!=null){
                System.debug(visres.getBody());
                if(visres.getBody()!=null){
                    JSONParser parser = JSON.createParser(visres.getBody());
                    String visid=null;
                    String url=null;
                    String title=null;
                    String created_at=null;
                    //get every visit id
                    while (parser.nextToken() != null){
                        if (parser.getCurrentToken() == JSONToken.FIELD_NAME&&parser.getText()=='id'){
                            parser.nextToken();
                            if(visitids.containsKey(parser.getText()))
                                visid = parser.getText();
                        }
                        if(parser.getCurrentToken() == JSONToken.FIELD_NAME&&parser.getText()=='url'&&visitids.containsKey(visid)){
                            parser.nextToken();
                            url = parser.getText();
                        }
                        if(parser.getCurrentToken() == JSONToken.FIELD_NAME&&parser.getText()=='title'&&visitids.containsKey(visid)){
                            parser.nextToken();
                            title = parser.getText();
                        }
                        if(parser.getCurrentToken() == JSONToken.FIELD_NAME&&parser.getText()=='created_at'&&visitids.containsKey(visid)){
                            parser.nextToken();
                            created_at = parser.getText();
                        }
                        if(created_at!=null&&title!=null&&url!=null&&visitids.containsKey(visid)){
                            visit vis = new visit();
                            vis.url = url;
                            vis.title = title;
                            vis.created_at = created_at;
                            vis.created_at_new = getdat(created_at);
                            visitids.get(visid).add(vis);
                            url = null;
                            title = null;
                            created_at = null;
                        }
                    }
                    for(visitor_activity va:result.visitor_activity){
                        if(va.visit_id!=null&&visitids.containsKey(String.valueof(va.visit_id))){
                            visitids.get(String.valueof(va.visit_id)).sort();
                            va.visits = visitids.get(String.valueof(va.visit_id));
                        }
                    }
                }
            }
        }

        System.debug(tasks);
        return setInitMore(JSON.serialize(result), params);
    }
    public static HttpResponse zedHTTP(String endpoint,String method,String data,String header){
        Http http=new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req=new HttpRequest();
        req.setmethod(method);
        if(method=='POST'){
            req.setendpoint(endpoint);
            req.setbody(data);
            if(header!=null){
                req.setHeader('Authorization', 'Pardot '+header.replaceAll('&',','));
            }
        }
        else{
            String con = endpoint.contains('?')?'&':'?';
            req.setendpoint(endpoint+con+data);
        }
        if(!Test.isRunningTest()){
            try{
                res = http.send(req);
                return res;
            }
            catch(exception e){
                return null;
            }
        }
        else
            return null;
    }
    @AuraEnabled
    public static result setInitMore(String vasstr, String params){
        result result = (result) JSON.deserialize(vasstr, result.class);
        if(result.visitor_activity!=null){
            for(integer i=0;i<loadnum;i++){
                for(visitor_activity vat:result.visitor_activity)
                    if(!vat.init){
                        vat.init = true;
                        break;
                    }
            }
        }
        return result;
    }
    @AuraEnabled
    public static Map <String,String> getEmailData(String emailid, String params, string curmap){
        Map <String,String> emmap = (Map <String,String>) JSON.deserialize(curmap, Map <String,String>.class);
        if(emailid!=null){
            HttpResponse emres = zedHTTP('https://pi.pardot.com/api/email/version/4/do/read/id/'+emailid,'POST', 'format=json&'+params,params);
            if(emres!=null){
                System.debug(emres.getBody());
                if(emres.getBody()!=null){
                    emailres emailres = (emailres) JSON.deserialize(emres.getBody(), emailres.class);
                    if(emailres!=null&&emailres.email!=null)
                        emmap.put(emailid,emailres.email.name);
                }
            }
        }
        return emmap;
    }
    @AuraEnabled
    public static Map <String, integer> setSummary(String vasstr){
        Map <String, integer> grps = new Map <String, integer>();
        result result = (result) JSON.deserialize(vasstr, result.class);
        if(result.visitor_activity!=null){
            for(visitor_activity va:result.visitor_activity)
                if(grps.containsKey(va.grpname))
                    grps.put(va.grpname, grps.get(va.grpname)+1);
                else
                    grps.put(va.grpname, 1);
        }
        System.debug(grps);
        return grps;
    }
}