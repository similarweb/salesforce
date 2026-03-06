public class ZuoraListFilterWrapper{
    public zqu__List_Filter_Item__c filterItem;
    private static zqu__Quote__c quote;
    private static Profile profile;
    private static User user;
    private static UserRole userRole;

    public ZuoraListFilterWrapper(zqu__List_Filter_Item__c filterItem){
        this.filterItem = filterItem;
    }

    // public Boolean isRightObjectQueryNameExist(){
    //     if (filterItem.zqu__Right_Object_Context_Key__c =='Quote') {
    //         return true;
    //     }else {
    //         return false;
    //     }

    // }

    public String getLeftObjectQueryName(){
        String leftObjectQueryName = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName1 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName2 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName3 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName4 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName5 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName6 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName7 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName8 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName9 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName10 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName11 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName12 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName13 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName14 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName15 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName16 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName17 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName18 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName19 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName20 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName21 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName22 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName23 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName24 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName25 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName26 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName27 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName28 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName29 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName30 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName31 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName32 = filterItem.zqu__Field_Name__c;
        String leftObjectQueryName34;
        String leftObjectQueryName35;
        String leftObjectQueryName36;
        String leftObjectQueryName37;
        String leftObjectQueryName38;
        String leftObjectQueryName39;
        String leftObjectQueryName40;
        String leftObjectQueryName41;
        String leftObjectQueryName42;
        String leftObjectQueryName43;
        String leftObjectQueryName44;
        String leftObjectQueryName45;
        String leftObjectQueryName461;
        String leftObjectQueryName46;
        String leftObjectQueryName47;
        String leftObjectQueryName48;
        String leftObjectQueryName49;
        String leftObjectQueryName50;
        String leftObjectQueryName51;
        String leftObjectQueryName52;
        String leftObjectQueryName53;
        String leftObjectQueryName54;
        String leftObjectQueryName55;
        String leftObjectQueryName56;
        String leftObjectQueryName57;
        String leftObjectQueryName58;
        String leftObjectQueryName59;
        String leftObjectQueryName60;
        String leftObjectQueryName61;
        String leftObjectQueryName62;
        String leftObjectQueryName63;
        String leftObjectQueryName64;
        String leftObjectQueryName65;
        String leftObjectQueryName66;
        String leftObjectQueryName67;
        String leftObjectQueryName68;
        String leftObjectQueryName69;
        String leftObjectQueryName70;
        String leftObjectQueryName71;
        String leftObjectQueryName72;
        String leftObjectQueryName73;
        String leftObjectQueryName74;
        String leftObjectQueryName75;
        String leftObjectQueryName76;
        String leftObjectQueryName77;
        String leftObjectQueryName78;
        String leftObjectQueryName79;
        String leftObjectQueryName80;
        String leftObjectQueryName81;
        String leftObjectQueryName82;
        String leftObjectQueryName83;
        String leftObjectQueryName84;
        String leftObjectQueryName85;
        String leftObjectQueryName86;
        String leftObjectQueryName87;
        String leftObjectQueryName88;
        String leftObjectQueryName89;
        String leftObjectQueryName90;
        String leftObjectQueryName91;
        String leftObjectQueryName92;
        String leftObjectQueryName93;
        String leftObjectQueryName94;
        String leftObjectQueryName95;
        String leftObjectQueryName96;
        String leftObjectQueryName97;
        String leftObjectQueryName98;
        String leftObjectQueryName99;
        String leftObjectQueryName100;
        String leftObjectQueryName101;
        String leftObjectQueryName102;
        String leftObjectQueryName103;
        String leftObjectQueryName104;
        String leftObjectQueryName105;
String leftObjectQueryName106;
String leftObjectQueryName107;
String leftObjectQueryName108;
String leftObjectQueryName109;
String leftObjectQueryName110;
String leftObjectQueryName111;
String leftObjectQueryName112;
String leftObjectQueryName113;
String leftObjectQueryName114;
String leftObjectQueryName115;
String leftObjectQueryName116;
String leftObjectQueryName117;
String leftObjectQueryName118;
String leftObjectQueryName119;
String leftObjectQueryName120;
String leftObjectQueryName121;
String leftObjectQueryName122;
String leftObjectQueryName123;
String leftObjectQueryName124;
String leftObjectQueryName125;
String leftObjectQueryName126;
String leftObjectQueryName127;
String leftObjectQueryName128;
String leftObjectQueryName129;
String leftObjectQueryName130;
String leftObjectQueryName131;
String leftObjectQueryName132;
String leftObjectQueryName133;
String leftObjectQueryName134;
String leftObjectQueryName135;
String leftObjectQueryName136;
String leftObjectQueryName137;
String leftObjectQueryName138;
String leftObjectQueryName139;
String leftObjectQueryName140;
String leftObjectQueryName141;
String leftObjectQueryName142;
String leftObjectQueryName143;
String leftObjectQueryName144;
String leftObjectQueryName145;
String leftObjectQueryName146;
String leftObjectQueryName147;
String leftObjectQueryName148;
String leftObjectQueryName149;
String leftObjectQueryName150;
String leftObjectQueryName151;
String leftObjectQueryName152;
String leftObjectQueryName153;
String leftObjectQueryName154;
String leftObjectQueryName155;
String leftObjectQueryName156;
String leftObjectQueryName157;
String leftObjectQueryName158;
String leftObjectQueryName159;
String leftObjectQueryName160;
String leftObjectQueryName161;
String leftObjectQueryName162;
String leftObjectQueryName163;
String leftObjectQueryName164;
String leftObjectQueryName165;
String leftObjectQueryName166;
String leftObjectQueryName167;
String leftObjectQueryName168;
String leftObjectQueryName169;
String leftObjectQueryName170;
String leftObjectQueryName171;
String leftObjectQueryName172;
String leftObjectQueryName173;
String leftObjectQueryName174;
String leftObjectQueryName175;
String leftObjectQueryName176;
String leftObjectQueryName177;
String leftObjectQueryName178;
String leftObjectQueryName179;
String leftObjectQueryName180;
String leftObjectQueryName181;
String leftObjectQueryName182;
String leftObjectQueryName183;
String leftObjectQueryName184;
String leftObjectQueryName185;
String leftObjectQueryName186;
String leftObjectQueryName187;
String leftObjectQueryName188;
String leftObjectQueryName189;
String leftObjectQueryName190;
String leftObjectQueryName191;
String leftObjectQueryName192;
String leftObjectQueryName193;
String leftObjectQueryName194;
String leftObjectQueryName195;
String leftObjectQueryName196;
String leftObjectQueryName197;
String leftObjectQueryName198;
String leftObjectQueryName199;
String leftObjectQueryName200;
String leftObjectQueryName201;
String leftObjectQueryName202;
String leftObjectQueryName203;
String leftObjectQueryName204;
        return leftObjectQueryName;
    }

    public String getLeftObjectName(){
        String leftObjectName = filterItem.zqu__Left_Object_Name__c;
        return leftObjectName;
    }

    public String getLeftObjectFieldName(){
        String leftObjectFieldName = filterItem.zqu__Field_Name__c;
        if (leftObjectFieldName.contains(filterItem.zqu__Left_Object_Name__c)) {
            leftObjectFieldName = leftObjectFieldName.removeStart(filterItem.zqu__Left_Object_Name__c+'.');
        }
        return leftObjectFieldName;
    }

    public String getRightObjectQueryName(){
        String rightObjectQueryName='';
        if (filterItem.zqu__Right_Object_Context_Key__c == 'Quote') {
            rightObjectQueryName = filterItem.zqu__Value__c;
        }
        return rightObjectQueryName;
    }

    public String getRightObjectValue(){
        if (String.isBlank(filterItem.zqu__Right_Object_Context_Key__c) || String.isBlank(filterItem.zqu__Right_Object_Name__c)) {
            return filterItem.zqu__Fixed_Value__c;
        } else if(filterItem.zqu__Right_Object_Context_Key__c.equalsIgnoreCase('Quote')) {
            if (filterItem.zqu__Right_Object_Name__c == filterItem.zqu__Right_Object_Type__c) {
                return (String)quote.get(filterItem.zqu__Value__c);
            } else {
                return (String)quote.getSObject(filterItem.zqu__Right_Object_Name__c)
                                    .get(filterItem.zqu__Value__c.remove(filterItem.zqu__Right_Object_Name__c+'.'));
            }
        } else if(filterItem.zqu__Right_Object_Context_Key__c.equalsIgnoreCase('Profile')) {
            if (filterItem.zqu__Right_Object_Name__c == filterItem.zqu__Right_Object_Type__c) {
                return (String)profile.get(filterItem.zqu__Value__c);
            } else {
                return (String)profile.getSObject(filterItem.zqu__Right_Object_Name__c)
                                    .get(filterItem.zqu__Value__c.remove(filterItem.zqu__Right_Object_Name__c+'.'));
            }
        } else if(filterItem.zqu__Right_Object_Context_Key__c.equalsIgnoreCase('User')) {
            if (filterItem.zqu__Right_Object_Name__c == filterItem.zqu__Right_Object_Type__c) {
                return (String)user.get(filterItem.zqu__Value__c);
            } else {
                return (String)user.getSObject(filterItem.zqu__Right_Object_Name__c)
                                    .get(filterItem.zqu__Value__c.remove(filterItem.zqu__Right_Object_Name__c+'.'));
            }
        } else if(filterItem.zqu__Right_Object_Context_Key__c.equalsIgnoreCase('UserRole')) {
            if (filterItem.zqu__Right_Object_Name__c == filterItem.zqu__Right_Object_Type__c) {
                return (String)userRole.get(filterItem.zqu__Value__c);
            } else {
                return (String)userRole.getSObject(filterItem.zqu__Right_Object_Name__c)
                                    .get(filterItem.zqu__Value__c.remove(filterItem.zqu__Right_Object_Name__c+'.'));
            }
        } else {
            throw new ZuoraListFilterWrapperException('Unknow right object context');
        }
    }

    public String getOperator(){
        if (filterItem.zqu__Operator__c == 'equals' || filterItem.zqu__Operator__c == '=') {
            return '=';
        } else if(filterItem.zqu__Operator__c == 'not equals'){
            return '!=';
        } else if(filterItem.zqu__Operator__c == 'lower than'){
            return '<';
        } else if(filterItem.zqu__Operator__c == 'lower or equal'){
            return '<=';
        } else if(filterItem.zqu__Operator__c == 'greater than'){
            return '>';
        } else if(filterItem.zqu__Operator__c == 'greater or equal'){
            return '>=';
        } else if(filterItem.zqu__Operator__c == 'contains'){
            return 'LIKE';
        } else {
            throw new ZuoraListFilterWrapperException('List filter operator is not recognized');
        }
    }

    public static void obtainRelatedObjectsForFilters(Id quoteId, List<zqu__List_Filter_Item__c> filterList){
        String quoteQuery;
        String profileQuery;
        String userQuery;
        String userRoleQuery;
        for (zqu__List_Filter_Item__c lfi_i : filterList) {
            if (lfi_i.zqu__Right_Object_Context_Key__c =='Quote') {
                if (quoteQuery == null) {
                    quoteQuery = 'SELECT Id, ';
                }
                if (String.isNotBlank(lfi_i.zqu__Value__c) && !quoteQuery.contains(lfi_i.zqu__Value__c)) {
                    quoteQuery+=lfi_i.zqu__Value__c+', ';
                }
            }
            if (lfi_i.zqu__Right_Object_Context_Key__c == 'Profile') {
                if (profileQuery == null) {
                    profileQuery = 'SELECT Id, ';
                }
                if (String.isNotBlank(lfi_i.zqu__Value__c) && !profileQuery.contains(lfi_i.zqu__Value__c)) {
                    profileQuery+=lfi_i.zqu__Value__c+', ';
                }
            }
            if (lfi_i.zqu__Right_Object_Context_Key__c == 'User') {
                if (userQuery == null) {
                    userQuery = 'SELECT Id, ';
                }
                if (String.isNotBlank(lfi_i.zqu__Value__c) && !userQuery.contains(lfi_i.zqu__Value__c)) {
                    userQuery+=lfi_i.zqu__Value__c+', ';
                }
            }
            if (lfi_i.zqu__Right_Object_Context_Key__c =='UserRole') {
                if (userRoleQuery == null) {
                    userRoleQuery = 'SELECT Id, ';
                }
                if (String.isNotBlank(lfi_i.zqu__Value__c) && !userRoleQuery.contains(lfi_i.zqu__Value__c)) {
                    userRoleQuery+=lfi_i.zqu__Value__c+', ';
                }
            }
        }
        if (String.isNotBlank(quoteQuery)) {
            quoteQuery = quoteQuery.removeEnd(', ');
            quoteQuery += ' FROM zqu__Quote__c WHERE Id = \'' + quoteId + '\' LIMIT 1';
            quote = (zqu__Quote__c)Database.query(quoteQuery);   
        }
        if (String.isNotBlank(profileQuery)) {
            profileQuery = quoteQuery.removeEnd(', ');
            profileQuery += ' FROM Profile WHERE Id = \'' + UserInfo.getProfileId() + '\' LIMIT 1';
            profile = (Profile)Database.query(profileQuery);   
        }
        if (String.isNotBlank(userQuery)) {
            userQuery = quoteQuery.removeEnd(', ');
            userQuery += ' FROM User WHERE Id = \'' + UserInfo.getUserId() + '\' LIMIT 1';
            user = (User)Database.query(userQuery);   
        }
        if (String.isNotBlank(userRoleQuery)) {
            userRoleQuery = quoteQuery.removeEnd(', ');
            userRoleQuery += ' FROM UserRole WHERE Id = \'' + UserInfo.getUserRoleId() + '\' LIMIT 1';
            userRole = (UserRole)Database.query(userRoleQuery); 
        }
    }

    public class ZuoraListFilterWrapperException extends Exception {   }
}