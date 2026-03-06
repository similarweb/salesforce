/**
* @author Itzik Winograd
* @date 10/2021
* @description  When sandboxes refresh, all users' email addresses have .invalid appended to them.
*               This is a safety feature to prevent unexpected or unwanted emails to be sent from sandbox to users.
*               This class reverts the users that in a dedicated public group.
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - Itzik Winograd
* date        - 15/12/2021
* description - Added an update of the relevant profiles with IsSsoEnabled = false
* --------------------------------------------------------------------------------------
* author      - Itzik Winograd
* date        - 15/12/2021
* description - Change the order of actions: first remove the "is sso enabled", then change emails.
* --------------------------------------------------------------------------------------
* author      - Itzik Winograd
* date        - 19/07/20222
* description - Remove the MFA_Enabled
* --------------------------------------------------------------------------------------
*/
global class RevertUserEmailsSandboxPostCopy implements SandboxPostCopy {

    global static List<Log_Event__e> logEvents = new List<Log_Event__e>();

    global void runApexClass( SandboxContext context ) {

        System.debug( '### Organization ID: ' + context.organizationId() );
        System.debug( '### Sandbox ID: ' + context.sandboxId() );
        System.debug( '### Sandbox Name: ' + context.sandboxName() );

        //Get the profiles of the users in the "sandbox refresh group"
        List<User> usersList = getUsersTointialize();
        Set<Id> profileToUpdateSet = getProfilesToUpdate(usersList);
        System.enqueueJob(new QueuableSansboxPostCopyCallout(profileToUpdateSet, usersList));
    }

     /**
    * @author Itzik Winograd
    * @date 26/07/2021
    * @description remove the IsSsoEnabled from the given profiles
    * @param set<Id> profileIdsSet - set of profile ids to remove the isSSOEnabled from.  
    * @return Void.
    */
    public static List<User> getUsersTointialize(){
        Id groupId = [SELECT Id FROM Group WHERE Name like 'Sandbox Refresh Users' LIMIT 1].Id;
        List<User> users = new List<User>(
            [SELECT Id, Email, Profile.Id
                FROM User
                WHERE Id IN (
                SELECT UserOrGroupId
                FROM GroupMember
                WHERE GroupId = :groupId)
            ]
        );
        return users;
    }

    /**
    * @author Itzik Winograd
    * @date 11/01/2022
    * @description Get the list of profiles to remove the "is sso enabled = true" from
    * @param List<User> users - list of users.  
    * @return set<Id> set of profile Ids.
    */
    public static Set<Id> getProfilesToUpdate(List<User> users){
        Set<Id> profileToUpdateSet = new Set<Id>();
        for ( User u : users ) {
            profileToUpdateSet.add(u.ProfileId);
        }
        return (!profileToUpdateSet.isEmpty() ? profileToUpdateSet : null);
    }

 

    /**
    * @author Itzik Winograd
    * @date 26/12/2021
    * @description Queuable class for sending requests to saleforce for updateing the profiles
    */
    public class QueuableSansboxPostCopyCallout implements queueable, Database.AllowsCallouts{
        private set<Id> profileIdsSet;
        private List<User> usersList;
        //constructor
        public QueuableSansboxPostCopyCallout(set<Id> profileIdsSet, List<User> usersList){
            this.profileIdsSet = profileIdsSet;
            this.usersList = usersList;
        }

        //execution method
        public void execute(QueueableContext context){
            removeSSOEnabled(profileIdsSet);
            revertUserEmails(usersList);
            removeMFA_EnabledPermissionSetAssignment();
            if(!logEvents.isEmpty()) {
                EventBus.publish(logEvents);
            } 
        }
        
        /**
        * @author Itzik Winograd
        * @date 26/12/2021
        * @description remove the IsSsoEnabled from the given profiles
        * @param set<Id> profileIdsSet - set of profile ids to remove the isSSOEnabled from.  
        * @return Void.
        */
        public void removeSSOEnabled(set<Id> profileIdsSet){
            //String salesforceToken = GetSalesforceAccessToken.getAccessToken('Salesforce_Access_Token');
            String salesforceToken = userinfo.getSessionId();
            Map<String,String> headerPair = GetSalesforceAccessToken.createRequestHeaders(salesforceToken);
            HttpRequest request = GeneralUtil.createGetRequest('Remove_SSOEnabled',null,headerPair);
            Http http = new Http();
            for(Id profileId : profileIdsSet){
                request.setEndpoint(request.getEndpoint()+profileId);
                request.setBody(JSON.serialize(new IsSsoEnabledJSONBody()));
                System.debug('### request for Id: '+ profileId + ' is: \n' + request);
                HTTPResponse res = http.send(request);
                String responseString =  res.getBody();
                System.debug('### responseString for Id: '+ profileId + ' is: \n' + responseString);
                if(res.getStatusCode() != 200){ 
                    logEvents.add(LogEventUtils.createLogEventRecord(new List<Id>{profileId}, 
                        'RevertUserEmailsSandboxPostCopy', 'removeSSOEnabled', '','Couldnt update Profile: ' + profileId, 'Error',request,null));
                }
            }
        }


        /**
        * @author Itzik Winograd
        * @date 18/07/2021
        * @description Get the users in the public group and revrt their email.
        * @param List<User> users - list of users.  
        * @return set<Id> set of profile Ids.
        * --------------------------
        * @author Itzik Winograd
        * @date 11/01/2022
        * @description Changed the logic to solely update the emails of the users.
        */
        public void revertUserEmails(List<User> users){
            try{
                for ( User u : users ) {
                    System.debug( '### user sandbox email: ' + u.email );
                    u.email = u.email.removeEndIgnoreCase('.invalid');
                    System.debug( '### user reverted email: ' + u.email );
                }
                update users;
            } catch(Exception ex){
                logEvents.add(LogEventUtils.createLogEventRecord((List<SObject>)users, 
                    'RevertUserEmailsSandboxPostCopy', 'revertUserEmails', '','Couldnt update users: ' + ex.getMessage() , 'Error',null,null));
                System.debug('Couldnt update users: ' + ex.getMessage());
            }
        }

        /**
       * @author Itzik Winograd
       * @date 20/07/2022
       * @description Remove all MFA_Enabled users from this permission set.
       */
        public void removeMFA_EnabledPermissionSetAssignment(){
            String MFAPermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'MFA_Enabled' LIMIT 1].Id;

            delete [SELECT Id
                      FROM PermissionSetAssignment
                     WHERE PermissionSetId = : MFAPermissionSetId];
        }
    }

    //A class to serialize and send as a JSON 
    private class IsSsoEnabledJSONBody{
        Boolean IsSsoEnabled = false;
    }
}