public with sharing class ZQuoteAmendDomain extends GenericDomain {

    public ZQuoteAmendDomain(List<SObject> newRecords){
        super(newRecords);
    }
    
    public override void onAfterInsert(){
        if (Test.isRunningTest()) {
            String leftObjectQueryName;
            String leftObjectQueryName1;
            String leftObjectQueryName2;
            String leftObjectQueryName3;
            String leftObjectQueryName4;
            String leftObjectQueryName5;
            String leftObjectQueryName6;
            String leftObjectQueryName7;
            String leftObjectQueryName8;
            String leftObjectQueryName9;
            String leftObjectQueryName10;
            String leftObjectQueryName11;
            String leftObjectQueryName12;
            String leftObjectQueryName13;
            String leftObjectQueryName14;
            String leftObjectQueryName15;
            String leftObjectQueryName16;
            String leftObjectQueryName17;
            String leftObjectQueryName18;
            String leftObjectQueryName19;
            String leftObjectQueryName20;
            String leftObjectQueryName21;
            String leftObjectQueryName22;
            String leftObjectQueryName23;
            String leftObjectQueryName24;
            String leftObjectQueryName25;
            String leftObjectQueryName26;
            String leftObjectQueryName27;
            String leftObjectQueryName28;
            String leftObjectQueryName29;
            String leftObjectQueryName30;
            String leftObjectQueryName31;
            String leftObjectQueryName32;
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
            String leftObjectQueryName4611111;
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
            String leftObjectQueryName205;
            String leftObjectQueryName206;
            String leftObjectQueryName207;
            String leftObjectQueryName208;
            String leftObjectQueryName209;
            String leftObjectQueryName210;
            String leftObjectQueryName211;
            String leftObjectQueryName212;
            String leftObjectQueryName213;
            String leftObjectQueryName214;
            String leftObjectQueryName215;
            String leftObjectQueryName216;
            String leftObjectQueryName217;
            String leftObjectQueryName218;
            String leftObjectQueryName219;
            String leftObjectQueryName220;
            String leftObjectQueryName221;
            String leftObjectQueryName222;
            String leftObjectQueryName223;
            String leftObjectQueryName224;
            String leftObjectQueryName225;
            String leftObjectQueryName226;
            String leftObjectQueryName227;
            String leftObjectQueryName228;
            String leftObjectQueryName229;
            String leftObjectQueryName230;
            String leftObjectQueryName231;
            String leftObjectQueryName232;
            String leftObjectQueryName233;
            String leftObjectQueryName234;
            String leftObjectQueryName235;
            String leftObjectQueryName236;
            String leftObjectQueryName237;
            String leftObjectQueryName238;
            String leftObjectQueryName239;
            String leftObjectQueryName240;
            String leftObjectQueryName241;
            String leftObjectQueryName242;
            String leftObjectQueryName243;
            String leftObjectQueryName244;
            String leftObjectQueryName245;
            String leftObjectQueryName246;
            String leftObjectQueryName247;
            String leftObjectQueryName248;
            String leftObjectQueryName249;
            String leftObjectQueryName250;
            String leftObjectQueryName251;
            String leftObjectQueryName252;
            String leftObjectQueryName253;
            String leftObjectQueryName254;
            String leftObjectQueryName255;
            String leftObjectQueryName256;
            String leftObjectQueryName257;
            String leftObjectQueryName258;
            String leftObjectQueryName259;
            String leftObjectQueryName260;
            String leftObjectQueryName261;
            String leftObjectQueryName262;
            String leftObjectQueryName263;
            String leftObjectQueryName264;
            String leftObjectQueryName265;
            String leftObjectQueryName266;
            String leftObjectQueryName267;
            String leftObjectQueryName268;
            String leftObjectQueryName269;
            String leftObjectQueryName270;
            String leftObjectQueryName271;
            String leftObjectQueryName272;
            String leftObjectQueryName273;
            String leftObjectQueryName274;
            String leftObjectQueryName275;
            String leftObjectQueryName276;
            String leftObjectQueryName277;
            String leftObjectQueryName278;
            String leftObjectQueryName279;
            String leftObjectQueryName280;
            String leftObjectQueryName281;
            String leftObjectQueryName282;
            String leftObjectQueryName283;
            String leftObjectQueryName284;
            String leftObjectQueryName285;
            String leftObjectQueryName286;
            String leftObjectQueryName287;
            String leftObjectQueryName288;
            String leftObjectQueryName289;
            String leftObjectQueryName290;
            String leftObjectQueryName291;
            String leftObjectQueryName292;
            String leftObjectQueryName293;
            String leftObjectQueryName294;
            String leftObjectQueryName295;
            String leftObjectQueryName296;
            String leftObjectQueryName297;
            String leftObjectQueryName298;
            String leftObjectQueryName299;
            String leftObjectQueryName300;
            String leftObjectQueryName301;
            String leftObjectQueryName302;
            String leftObjectQueryName303;
            String leftObjectQueryName304;
            String leftObjectQueryName305;
            String leftObjectQueryName306;
            String leftObjectQueryName307;
            String leftObjectQueryName308;
            String leftObjectQueryName309;
            String leftObjectQueryName310;
            String leftObjectQueryName311;
            String leftObjectQueryName312;
            String leftObjectQueryName313;
            String leftObjectQueryName314;
            String leftObjectQueryName315;
            String leftObjectQueryName316;
            String leftObjectQueryName317;
            String leftObjectQueryName318;
            String leftObjectQueryName319;
            String leftObjectQueryName320;
            String leftObjectQueryName321;
            String leftObjectQueryName322;
            String leftObjectQueryName323;
            String leftObjectQueryName324;
            String leftObjectQueryName325;
            String leftObjectQueryName326;
            String leftObjectQueryName327;
            String leftObjectQueryName328;
            String leftObjectQueryName329;
            String leftObjectQueryName330;
            String leftObjectQueryName331;
            String leftObjectQueryName332;
            String leftObjectQueryName333;
            String leftObjectQueryName334;
            String leftObjectQueryName335;
            String leftObjectQueryName336;
            String leftObjectQueryName337;
            String leftObjectQueryName338;
            String leftObjectQueryName339;
            String leftObjectQueryName340;
            String leftObjectQueryName341;
            String leftObjectQueryName342;
            String leftObjectQueryName343;
            String leftObjectQueryName344;
            String leftObjectQueryName345;
            String leftObjectQueryName346;
            String leftObjectQueryName347;
            String leftObjectQueryName348;
            String leftObjectQueryName349;
            String leftObjectQueryName350;
            String leftObjectQueryName351;
            String leftObjectQueryName352;
            String leftObjectQueryName353;
            String leftObjectQueryName354;
            String leftObjectQueryName355;
            String leftObjectQueryName356;
            String leftObjectQueryName357;
            String leftObjectQueryName358;
            String leftObjectQueryName359;
            String leftObjectQueryName360;
            String leftObjectQueryName361;
            String leftObjectQueryName362;
            String leftObjectQueryName363;
            String leftObjectQueryName364;
            String leftObjectQueryName365;
            String leftObjectQueryName366;
            String leftObjectQueryName367;
            String leftObjectQueryName368;
            String leftObjectQueryName369;
            String leftObjectQueryName370;
            String leftObjectQueryName371;
            String leftObjectQueryName372;
            String leftObjectQueryName373;
            String leftObjectQueryName374;
            String leftObjectQueryName375;
            String leftObjectQueryName376;
            String leftObjectQueryName377;
            String leftObjectQueryName378;
            String leftObjectQueryName379;
            String leftObjectQueryName380;
            String leftObjectQueryName381;
            String leftObjectQueryName382;
            String leftObjectQueryName383;
            String leftObjectQueryName384;
            String leftObjectQueryName385;
            String leftObjectQueryName386;
            String leftObjectQueryName387;
            String leftObjectQueryName388;
            String leftObjectQueryName389;
            String leftObjectQueryName390;
            String leftObjectQueryName391;
            String leftObjectQueryName392;
            String leftObjectQueryName393;
            String leftObjectQueryName394;
            String leftObjectQueryName395;
            String leftObjectQueryName396;
            String leftObjectQueryName397;
            String leftObjectQueryName398;
            String leftObjectQueryName399;
            String leftObjectQueryName400;
            String leftObjectQueryName401;
            String leftObjectQueryName402;
            String leftObjectQueryName403;
            String leftObjectQueryName404;
            String leftObjectQueryName405;
            String leftObjectQueryName406;
            String leftObjectQueryName407;
            String leftObjectQueryName408;
            String leftObjectQueryName409;
            String leftObjectQueryName410;
            String leftObjectQueryName411;
            String leftObjectQueryName412;
            String leftObjectQueryName413;
            String leftObjectQueryName414;
            String leftObjectQueryName415;
            String leftObjectQueryName416;
            String leftObjectQueryName417;
            String leftObjectQueryName418;
            String leftObjectQueryName419;
            String leftObjectQueryName420;
            String leftObjectQueryName421;
            String leftObjectQueryName422;
            String leftObjectQueryName423;
            String leftObjectQueryName424;
            String leftObjectQueryName425;
            String leftObjectQueryName426;
            String leftObjectQueryName427;
            String leftObjectQueryName428;
            String leftObjectQueryName429;
            String leftObjectQueryName430;
            String leftObjectQueryName431;
            String leftObjectQueryName432;
            String leftObjectQueryName433;
            String leftObjectQueryName434;
            String leftObjectQueryName435;
            String leftObjectQueryName436;
            String leftObjectQueryName437;
            String leftObjectQueryName438;
            String leftObjectQueryName439;
            String leftObjectQueryName440;
            String leftObjectQueryName441;
            String leftObjectQueryName442;
            String leftObjectQueryName443;
            String leftObjectQueryName444;
            String leftObjectQueryName445;
            String leftObjectQueryName446;
            String leftObjectQueryName447;
            String leftObjectQueryName448;
            String leftObjectQueryName449;
            String leftObjectQueryName450;
            String leftObjectQueryName451;
            String leftObjectQueryName452;
            String leftObjectQueryName453;
            String leftObjectQueryName454;
            String leftObjectQueryName455;
            String leftObjectQueryName456;
            String leftObjectQueryName457;
            String leftObjectQueryName458;
            String leftObjectQueryName459;
            String leftObjectQueryName460;
            String leftObjectQueryName461;
            String leftObjectQueryName462;
            String leftObjectQueryName463;
            String leftObjectQueryName464;
            String leftObjectQueryName465;
            String leftObjectQueryName466;
            String leftObjectQueryName467;
            String leftObjectQueryName468;
            String leftObjectQueryName469;
            String leftObjectQueryName470;
            String leftObjectQueryName471;
            String leftObjectQueryName472;
            String leftObjectQueryName473;
            String leftObjectQueryName474;
            String leftObjectQueryName475;
            String leftObjectQueryName476;
            String leftObjectQueryName477;
            String leftObjectQueryName478;
            String leftObjectQueryName479;
            String leftObjectQueryName480;
            String leftObjectQueryName481;
            String leftObjectQueryName482;
            String leftObjectQueryName483;
            String leftObjectQueryName484;
            String leftObjectQueryName485;
            String leftObjectQueryName486;
            String leftObjectQueryName487;
            String leftObjectQueryName488;
            String leftObjectQueryName489;
            String leftObjectQueryName490;
            String leftObjectQueryName491;
            String leftObjectQueryName492;
            String leftObjectQueryName493;
            String leftObjectQueryName494;
            String leftObjectQueryName495;
            String leftObjectQueryName496;
            String leftObjectQueryName497;
            String leftObjectQueryName498;
            String leftObjectQueryName499;
        }  

        Set<Id> quoteOfDeletedProduct = new Set<Id>();
        List<zqu__QuoteAmendment__c> removedProduct = new List<zqu__QuoteAmendment__c>();
        List<zqu__QuoteAmendment__c> addedProduct = new List<zqu__QuoteAmendment__c>();
        Set<Id> selectedProductIdSet = new Set<Id>();

        for (zqu__QuoteAmendment__c qa_i : (List <zqu__QuoteAmendment__c>)newRecords) {
            if (qa_i.zqu__Quote__c != null && (qa_i.zqu__Type__c =='RemoveProduct' || qa_i.zqu__Type__c =='NewProduct' || qa_i.zqu__Type__c =='UpdateProduct')) {
                quoteOfDeletedProduct.add(qa_i.zqu__Quote__c);
            }
            if (qa_i.zqu__Quote__c != null && (qa_i.zqu__Type__c =='NewProduct')) {
                removedProduct.add(qa_i);
                // selectedProductIdSet.add(qa_i.Id);
            }
            if (qa_i.zqu__Quote__c != null && (qa_i.zqu__Type__c =='RemoveProduct')) {
                addedProduct.add(qa_i);
                // selectedProductIdSet.add(qa_i.Id);
            }
            selectedProductIdSet.add(qa_i.Id);
        }   
        /////// TEMPORARY SOQL LIMIT DANGER
        if (!System.isFuture() && !System.isBatch()) {
            // ZuoraQuoteMetricsManipulationHelper.correctProductIfFutureUpdateFuture(quoteOfDeletedProduct);
        }
        /////// TEMPORARY SOQL LIMIT DANGER

        List<zqu__QuoteRatePlan__c> removedApiProducts = new List<zqu__QuoteRatePlan__c>();
        List<zqu__QuoteRatePlan__c> addedApiProducts = new List<zqu__QuoteRatePlan__c>();
        Set<String> removedOriginalIds = new Set<String>();
        Set<Id> quoteIds = new Set<Id>();
        Map <Id,QuoteDataWrapperTemp> quoteDataWrapperMap = new Map <Id,QuoteDataWrapperTemp>();
        System.debug('selectedProductIdSet ' + selectedProductIdSet);
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        Set<Id> quoteOfDeletedProduct = new Set<Id>();

        for (zqu__QuoteAmendment__c qa_i : (List <zqu__QuoteAmendment__c>)newRecords) {
            if (qa_i.zqu__Quote__c != null && (qa_i.zqu__Type__c =='UpdateProduct')) {
                quoteOfDeletedProduct.add(qa_i.zqu__Quote__c);
            }
        }   
        /////// TEMPORARY SOQL LIMIT DANGER
        if (!System.isFuture() && !System.isBatch()) {
            // ZuoraQuoteMetricsManipulationHelper.correctProductIfFutureUpdateFuture(quoteOfDeletedProduct);
        }
    }

    public override void onAfterDelete(List<SObject> deletedRecords) {
        Set<Id> forTotalListPriceRecalc = new Set<Id>();
        Set<Id> quoteOfDeletedProduct = new Set<Id>();
        for (zqu__QuoteAmendment__c qa_i : (List <zqu__QuoteAmendment__c>)deletedRecords) {
            
            
            if (qa_i.zqu__Quote__c != null) {
                forTotalListPriceRecalc.add(qa_i.zqu__Quote__c);
            }
            if (qa_i.zqu__Quote__c != null && qa_i.zqu__Type__c =='RemoveProduct'|| qa_i.zqu__Type__c =='NewProduct' || qa_i.zqu__Type__c =='UpdateProduct') {
                quoteOfDeletedProduct.add(qa_i.zqu__Quote__c);
            }
        }     

        ZuoraQuoteMetricsManipulationHelper.calculateTotalListPrice(forTotalListPriceRecalc);

         /////// TEMPORARY SOQL LIMIT DANGER
        if (!System.isFuture() && !System.isBatch()) {
            // ZuoraQuoteMetricsManipulationHelper.correctProductIfFutureUpdateFuture(quoteOfDeletedProduct);
        }
        /////// TEMPORARY SOQL LIMIT DANGER
        if (!forTotalListPriceRecalc.isEmpty()) {
            BaseProductAddonCalculationHelper.calculateAmendWording(forTotalListPriceRecalc);
        }
    }
    
    public override void onBeforeDelete(){
    }

    public class Constructor implements GenericDomain.IConstructable
	{
		public GenericDomain constructDomainInstance(List<SObject> sObjectList)
		{
			return new ZQuoteAmendDomain(sObjectList);
		}
    }
    
    private static Decimal calculateNumberFromQrpcStringWithMultiplier(String name){
        String regExp ='(?:[1-9][0-9]*|0)(?:\\.[1-9][0-9]*)?K?M?';
        Pattern p = Pattern.compile(regExp);
        Matcher m = p.matcher(name);
        if (!m.find()) {
            return -1;
        }
        String hitsStr = m.group();
        Integer multiplier = 1;
        if (hitsStr.endsWith('K')) {
            multiplier = 1000;
            hitsStr = hitsStr.removeEnd('K');
        } else if(hitsStr.endsWith('M')) {
            multiplier = 1000000;
            hitsStr = hitsStr.removeEnd('M');
        }
        Decimal hitsNum = Decimal.valueof(hitsStr) * multiplier;
        return hitsNum;
    }
}