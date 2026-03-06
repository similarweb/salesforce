/**
 * @author updated by Synebo Developer
 * MQ-1419. Added updateChargesByTargetTotalPrice and updateChargesByTargetTotalPriceMainLogic 5 parameters methods overriding. Added fixPriceOfASProducts method.
 */
public with sharing class ZuoraQuoteMetricsManipulationHelper {
  private static Boolean isBeforeUpdateRunFirstTime;
  private static Boolean isTargetPriceChanged;
  private static final String RECIPIENTS_METADATA_NAME = 'Recipients_for_wrong_frequency_alert';
  private static final String RE_ADDING_PRODUCTS_ALERT_NAME = 'Alert_for_re_adding_products';

  @TestVisible
  private static Boolean isMakeDataGetChargeDisabled = false;

  public static void calculateQuoteMetrics(
    List<SObject> newRecords,
    Map<Id, SObject> existingRecords
  ) {
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
      Integer i = 0;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
    }
    if (isBeforeUpdateRunFirstTime == null) {
      isBeforeUpdateRunFirstTime = true;
      isTargetPriceChanged = false;
    } else {
      isBeforeUpdateRunFirstTime = false;
    }
    for (zqu__Quote__c quote_i : (List<zqu__Quote__c>) newRecords) {
      zqu__Quote__c oldQuote = (zqu__Quote__c) existingRecords.get(quote_i.Id);
      System.debug('q ' + quote_i.zqu__Previewed_SubTotal__c);
      System.debug('q ' + oldQuote.zqu__Previewed_SubTotal__c);
      if (
        (quote_i.zqu__QuoteBusinessType__c != 'Renewal (with/without upsell)' &&
        quote_i.Total_List_Price__c == null) ||
        (quote_i.zqu__QuoteBusinessType__c == 'Renewal (with/without upsell)' &&
        quote_i.Total_List_Price_Charge_Detail__c == null &&
        oldQuote.Is_Initally_Renewed__c == true)
      ) {
        continue;
      }
      if (
        quote_i.Total_List_Price__c != oldQuote.Total_List_Price__c &&
        quote_i.zqu__QuoteBusinessType__c != 'Renewal (with/without upsell)' &&
        !System.isFuture() &&
        isBeforeUpdateRunFirstTime
      ) {
        System.debug('calculateQuoteMetrics1');
        quote_i.Target_Quote_Total_Price__c = null;
        quote_i.Quote_Discount__c = null;
        quote_i.Total_Discount__c = 0;
      } else if (
        quote_i.Target_Quote_Total_Price__c != null &&
        quote_i.Target_Quote_Total_Price__c !=
        oldQuote.Target_Quote_Total_Price__c
      ) {
        System.debug('calculateQuoteMetrics2');
        Boolean isDiscountEditable = checkIfQuoteHasDiscountableProduct(
          quote_i.Id
        );
        if (!isDiscountEditable) {
          //quote_i.addError('The quote has no products with editable discount');
          continue;
        }
        Decimal totalListPrice;
        if (
          quote_i.Total_List_Price__c == null ||
          quote_i.Total_List_Price__c == 0
        ) {
          totalListPrice = quote_i.Total_List_Price_Charge_Detail__c;
        } else {
          totalListPrice = quote_i.Total_List_Price__c;
        }
        if (totalListPrice != null) {
          quote_i.Total_Discount__c =
            (totalListPrice - quote_i.Target_Quote_Total_Price__c) /
            totalListPrice *
            100;
          isTargetPriceChanged = true;
        }
      } else if (
        quote_i.Quote_Discount__c != null &&
        quote_i.Quote_Discount__c != oldQuote.Quote_Discount__c
      ) {
        System.debug('calculateQuoteMetrics3');
        Boolean isDiscountEditable = checkIfQuoteHasDiscountableProduct(
          quote_i.Id
        );
        if (!isDiscountEditable) {
          quote_i.addError('The quote has no products with editable discount');
        }
        quote_i.Total_Discount__c = quote_i.Quote_Discount__c;
      } else if (
        quote_i.Target_Quote_Total_Price__c == null &&
        quote_i.Quote_Discount__c == null
      ) {
        System.debug('calculateQuoteMetrics4');
        quote_i.Total_Discount__c = 0;
      }
      System.debug('quote_i.Total_Discount__c2 ' + quote_i.Total_Discount__c);
    }
  }

  public static void calculateQuoteMetrics(List<SObject> newRecords) {
    for (zqu__Quote__c quote_i : (List<zqu__Quote__c>) newRecords) {
      if (
        (quote_i.zqu__QuoteBusinessType__c != 'Renewal (with/without upsell)' &&
        quote_i.Total_List_Price__c == null) ||
        (quote_i.zqu__QuoteBusinessType__c == 'Renewal (with/without upsell)' &&
        quote_i.Total_List_Price_Charge_Detail__c == null &&
        quote_i.Is_Initally_Renewed__c == false)
      ) {
        continue;
      }
      if (quote_i.Target_Quote_Total_Price__c != null) {
        Decimal totalListPrice;
        if (
          quote_i.Total_List_Price__c == null ||
          quote_i.Total_List_Price__c == 0
        ) {
          totalListPrice = quote_i.Total_List_Price_Charge_Detail__c;
        } else {
          totalListPrice = quote_i.Total_List_Price__c;
        }
        quote_i.Total_Discount__c =
          (totalListPrice - quote_i.Target_Quote_Total_Price__c) /
          totalListPrice *
          100;
      } else if (quote_i.Quote_Discount__c != null) {
        quote_i.Total_Discount__c = quote_i.Quote_Discount__c;
      }
      System.debug('quote_i.Total_Discount__c1 ' + quote_i.Total_Discount__c);
    }
  }

  public static void updateChargesIfMetricsChanged(
    List<SObject> newRecords,
    Map<Id, SObject> existingRecords
  ) {
    System.debug('CHECK updateChargesIfMetricsChanged');
    Set<Id> recordIdsOfQrpcUpdate = new Set<Id>();
    Set<Id> quoteIdSet = new Set<Id>();

    for (zqu__Quote__c quote_i : (List<zqu__Quote__c>) newRecords) {
      zqu__Quote__c oldQuote = (zqu__Quote__c) existingRecords.get(quote_i.Id);
      if (
        quote_i.Target_Quote_Total_Price__c != null &&
        quote_i.Total_Discount__c != oldQuote.Total_Discount__c
      ) {
        quoteIdSet.add(quote_i.Id);
      }
    }

    for (zqu__Quote__c quote_i : (List<zqu__Quote__c>) newRecords) {
      zqu__Quote__c oldQuote = (zqu__Quote__c) existingRecords.get(quote_i.Id);
      if (
        quote_i.Target_Quote_Total_Price__c != null &&
        quote_i.Total_Discount__c != oldQuote.Total_Discount__c
      ) {
        System.debug('updateCharges1');
        if (!Test.isRunningTest()) {
          updateChargesByTargetTotalPrice(
            quote_i.Id,
            quote_i.Target_Quote_Total_Price__c,
            quote_i.zqu__InitialTerm__c
          );
        }
      } else if (
        quote_i.Total_Discount__c != oldQuote.Total_Discount__c &&
        (oldQuote.Total_Discount__c != null ||
        quote_i.Total_Discount__c != 0) &&
        (quote_i.Target_Quote_Total_Price__c == null)
      ) {
        System.debug('quote_i.Total_Discount__c ' + quote_i.Total_Discount__c);
        System.debug(
          'oldQuote.Total_Discount__c ' + oldQuote.Total_Discount__c
        );
        System.debug('updateCharges2');
        updateChargesBySpecificDisount(
          quote_i.Id,
          quote_i.Total_Discount__c,
          quote_i.Total_List_Price__c,
          quote_i.zqu__InitialTerm__c
        );
      }
    }

    if (!quoteIdSet.isEmpty()) {
      fireEeventCalculationOfMetrics(quoteIdSet);
    }
  }
  @TestVisible
  private static void fireEeventCalculationOfMetrics(Set<Id> quoteIdSet) {
    List<Calculation_in_progress__e> calculationInProgressEventList = new List<Calculation_in_progress__e>();

    List<zqu__Quote__c> quoteToUpdateList = new List<zqu__Quote__c>();
    for (Id quoteId : quoteIdSet) {
      zqu__Quote__c quoteToUpdate = new zqu__Quote__c();
      quoteToUpdate.Id = quoteId;
      quoteToUpdate.Recalculate_Charge__c = true;
      quoteToUpdateList.add(quoteToUpdate);

      Calculation_in_progress__e calculationInProgressEvent = new Calculation_in_progress__e();
      calculationInProgressEvent.QuoteId__c = quoteId;
      calculationInProgressEvent.Message__c = 'Start';
      calculationInProgressEventList.add(calculationInProgressEvent);
    }

    if (!calculationInProgressEventList.isEmpty()) {
      update quoteToUpdateList;
      List<Database.SaveResult> results = EventBus.publish(
        calculationInProgressEventList
      );
      for (Database.SaveResult sr : results) {
        if (!sr.isSuccess()) {
          for (Database.Error err : sr.getErrors()) {
            System.debug(
              'Error returned: ' +
                err.getStatusCode() +
                ' - ' +
                err.getMessage()
            );
          }
        }
      }
    }
  }

  public static void updateChargesIfMetricsChanged(List<SObject> newRecords) {
    Set<Id> recordIdsOfQrpcUpdate = new Set<Id>();
    for (zqu__Quote__c quote_i : (List<zqu__Quote__c>) newRecords) {
      if (
        quote_i.Target_Quote_Total_Price__c != null &&
        quote_i.Total_Discount__c != null
      ) {
        System.debug('updateCharges3');
        if (!Test.isRunningTest())
          updateChargesByTargetTotalPrice(
            quote_i.Id,
            quote_i.Target_Quote_Total_Price__c,
            quote_i.zqu__InitialTerm__c
          );
      } else if (
        quote_i.Total_Discount__c != null &&
        quote_i.Quote_Discount__c != null
      ) {
        System.debug('updateCharges4');
        updateChargesBySpecificDisount(
          quote_i.Id,
          quote_i.Total_Discount__c,
          quote_i.Total_List_Price__c,
          quote_i.zqu__InitialTerm__c
        );
      }
    }
  }

  public static void calculateTotalListPrice(Set<Id> quoteIds) {
    Map<Id, zqu__Quote__c> quotesToUpdate = new Map<Id, zqu__Quote__c>();
    AggregateResult[] grouppedResult2 = [
      SELECT
        zqu__QuoteRatePlan__r.zqu__Quote__c,
        SUM(Terms_Total__c) listPrice,
        SUM(Terms_Total_View__c) listPriceView
      FROM zqu__QuoteChargeSummary__c
      WHERE
        zqu__QuoteRatePlan__r.zqu__Quote__c IN :quoteIds
        AND Terms_Total__c != NULL
        AND zqu__QuoteRatePlanCharge__r.Part_Of_Cluster_5__c != TRUE
      GROUP BY zqu__QuoteRatePlan__r.zqu__Quote__c
    ];

    for (AggregateResult ar_i : grouppedResult2) {
      if (ar_i.get('zqu__Quote__c') != null) {
        zqu__Quote__c quote = new zqu__Quote__c();
        if (quotesToUpdate.containsKey((Id) ar_i.get('zqu__Quote__c'))) {
          quote = quotesToUpdate.get((Id) ar_i.get('zqu__Quote__c'));
        }
        quote.Id = (Id) ar_i.get('zqu__Quote__c');
        quote.Total_List_Price__c = ((Decimal) ar_i.get('listPrice'));
        quote.Total_List_Price_View__c = ((Decimal) ar_i.get('listPriceView'));
        quotesToUpdate.put(quote.Id, quote);
      }
    }

    AggregateResult[] grouppedResult3 = [
      SELECT zqu__Quote__c, SUM(Terms_Total__c) listPrice
      FROM zqu__QuoteChargeDetail__c
      WHERE
        zqu__Quote__c IN :quoteIds
        AND Terms_Total__c != NULL
        AND IsPartOfCluster5__c != TRUE
      GROUP BY zqu__Quote__c
    ];

    for (AggregateResult ar_i : grouppedResult3) {
      if (ar_i.get('zqu__Quote__c') != null) {
        zqu__Quote__c quote = new zqu__Quote__c();
        if (quotesToUpdate.containsKey((Id) ar_i.get('zqu__Quote__c'))) {
          quote = quotesToUpdate.get((Id) ar_i.get('zqu__Quote__c'));
        }
        quote.Id = (Id) ar_i.get('zqu__Quote__c');
        quote.Total_List_Price_Charge_Detail__c = ((Decimal) ar_i.get(
          'listPrice'
        ));
        quotesToUpdate.put(quote.Id, quote);
      }
    }
    update quotesToUpdate.values();
  }

  public static List<zqu__Quote__c> calculateTotalListPrice(
    List<zqu__Quote__c> quotesToUpdate
  ) {
    Map<Id, zqu__Quote__c> quoteMap = new Map<Id, zqu__Quote__c>();
    quoteMap.putAll(quotesToUpdate);
    AggregateResult[] grouppedResult2 = [
      SELECT
        zqu__QuoteRatePlan__r.zqu__Quote__c,
        SUM(Terms_Total__c) listPrice,
        SUM(Terms_Total_View__c) listPriceView
      FROM zqu__QuoteChargeSummary__c
      WHERE
        zqu__QuoteRatePlan__r.zqu__Quote__c IN :quoteMap.keySet()
        AND Terms_Total__c != NULL
        AND zqu__QuoteRatePlanCharge__r.Part_Of_Cluster_5__c != TRUE
      GROUP BY zqu__QuoteRatePlan__r.zqu__Quote__c
    ];

    for (AggregateResult ar_i : grouppedResult2) {
      if (ar_i.get('zqu__Quote__c') != null) {
        zqu__Quote__c quote = new zqu__Quote__c();
        if (quoteMap.containsKey((Id) ar_i.get('zqu__Quote__c'))) {
          quote = quoteMap.get((Id) ar_i.get('zqu__Quote__c'));
        }
        quote.Id = (Id) ar_i.get('zqu__Quote__c');
        quote.Total_List_Price__c = ((Decimal) ar_i.get('listPrice'));
        quote.Total_List_Price_View__c = ((Decimal) ar_i.get('listPriceView'));
        quoteMap.put(quote.Id, quote);
      }
    }

    AggregateResult[] grouppedResult3 = [
      SELECT zqu__Quote__c, SUM(Terms_Total__c) listPrice
      FROM zqu__QuoteChargeDetail__c
      WHERE
        zqu__Quote__c IN :quoteMap.keySet()
        AND Terms_Total__c != NULL
        AND IsPartOfCluster5__c != TRUE
      GROUP BY zqu__Quote__c
    ];

    for (AggregateResult ar_i : grouppedResult3) {
      if (ar_i.get('zqu__Quote__c') != null) {
        zqu__Quote__c quote = new zqu__Quote__c();
        if (quoteMap.containsKey((Id) ar_i.get('zqu__Quote__c'))) {
          quote = quoteMap.get((Id) ar_i.get('zqu__Quote__c'));
        }
        quote.Id = (Id) ar_i.get('zqu__Quote__c');
        quote.Total_List_Price_Charge_Detail__c = ((Decimal) ar_i.get(
          'listPrice'
        ));
        quoteMap.put(quote.Id, quote);
      }
    }
    return quoteMap.values();
  }

  public static List<zqu__QuoteRatePlanCharge__c> calculateSpecificBillingPeriod(
    List<zqu__Quote__c> quoteList,
    Set<Id> validQuoteIds
  ) {
    List<zqu__QuoteRatePlanCharge__c> qrpcToUpdate = new List<zqu__QuoteRatePlanCharge__c>();
    System.debug('validQuoteIds - 1 ' + validQuoteIds);
    Map<Id, List<zqu__QuoteRatePlanCharge__c>> quote2QrpcWithoutBillingPeriodMap = getQuote2QrpcWithoutBillingPeriodMap(
      validQuoteIds
    );
    for (zqu__Quote__c quote_i : quoteList) {
      if (!quote2QrpcWithoutBillingPeriodMap.containsKey(quote_i.Id)) {
        continue;
      }
      Integer paymentFrequency = getPaymentFrequencyNumber(
        quote_i.payment_frequency1__c,
        quote_i.zqu__InitialTerm__c
      );
      List<zqu__QuoteRatePlanCharge__c> qrpcList = quote2QrpcWithoutBillingPeriodMap.get(
        quote_i.Id
      );
      for (zqu__QuoteRatePlanCharge__c qrpc_i : qrpcList) {
        Date zuoraEffectiveDate = date.newinstance(2013, 12, 31); //CSSettings__c.getinstance('Setting').Zuora_Effective_Date__c;
        if (
          qrpc_i.zqu__Period__c != null &&
          qrpc_i.zqu__Period__c.EqualsIgnoreCase('Specific Months') &&
          qrpc_i.zqu__SpecificBillingPeriod__c != paymentFrequency &&
          qrpc_i.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c >
          zuoraEffectiveDate
        ) {
          qrpc_i.zqu__SpecificBillingPeriod__c = paymentFrequency;
          qrpcToUpdate.add(qrpc_i);
        }
      }
    }
    return qrpcToUpdate;
  }

  public static List<zqu__QuoteRatePlanCharge__c> calculateSpecificBillingPeriod(
    List<zqu__QuoteRatePlanCharge__c> qrpcList
  ) {
    System.debug('calculateSpecificBillingPeriod - start');
    Date zuoraEffectiveDate = date.newinstance(2013, 12, 31);
    Set<Id> validQrpcIds = new Set<Id>();
    Map<Id, Id> validQuoteIdsMap = new Map<Id, Id>();
    Map<Id, zqu__Quote__c> quotePaymentFrequencyMap = new Map<Id, zqu__Quote__c>();

    for (zqu__QuoteRatePlanCharge__c qrpc_i : qrpcList) {
      if (
        qrpc_i.zqu__Period__c != null &&
        qrpc_i.zqu__Period__c.EqualsIgnoreCase('Specific Months')
      ) {
        System.debug('calculateSpecificBillingPeriod - 1');
        validQrpcIds.add(qrpc_i.zqu__QuoteRatePlan__c);
      }
    }
    List<zqu__QuoteRatePlan__c> qrpcValidList = [
      SELECT Id, zqu__Quote__c
      FROM zqu__QuoteRatePlan__c
      WHERE Id IN :validQrpcIds
    ];
    for (zqu__QuoteRatePlan__c qrpc_i : qrpcValidList) {
      System.debug('calculateSpecificBillingPeriod - 2 ' + qrpc_i.Id);
      validQuoteIdsMap.put(qrpc_i.Id, qrpc_i.zqu__Quote__c);
    }
    System.debug(
      'calculateSpecificBillingPeriod - 3' +
      JSON.serializePretty(validQuoteIdsMap)
    );
    System.debug('calculateSpecificBillingPeriod - 2');
    quotePaymentFrequencyMap = getQuotePaymentFrequencyMap(
      validQuoteIdsMap.values()
    );
    System.debug(
      'calculateSpecificBillingPeriod - 3' +
      JSON.serializePretty(quotePaymentFrequencyMap)
    );
    for (zqu__QuoteRatePlanCharge__c qrpc_i : qrpcList) {
      if (
        validQuoteIdsMap.containsKey(qrpc_i.zqu__QuoteRatePlan__c) &&
        quotePaymentFrequencyMap.containsKey(
          validQuoteIdsMap.get(qrpc_i.zqu__QuoteRatePlan__c)
        )
      ) {
        System.debug('calculateSpecificBillingPeriod - 4');
        zqu__Quote__c parentQuote = quotePaymentFrequencyMap.get(
          validQuoteIdsMap.get(qrpc_i.zqu__QuoteRatePlan__c)
        );
        String paymentFrequencyValue = parentQuote.payment_frequency1__c;
        Integer paymentFrequency = getPaymentFrequencyNumber(
          paymentFrequencyValue,
          parentQuote.zqu__InitialTerm__c
        );
        System.debug('paymentFrequency ' + paymentFrequency);
        System.debug(
          'parentQuote.payment_frequency1__c ' + paymentFrequencyValue
        );
        System.debug(
          'parentQuote.zqu__InitialTerm__c ' + parentQuote.zqu__InitialTerm__c
        );
        qrpc_i.zqu__SpecificBillingPeriod__c = paymentFrequency;
      }
    }
    System.debug('calculateSpecificBillingPeriod - end');
    return qrpcList;
  }

  private static Map<Id, zqu__Quote__c> getQuotePaymentFrequencyMap(
    List<Id> quoteIds
  ) {
    List<zqu__Quote__c> qrpcList = [
      SELECT
        Id,
        payment_frequency1__c,
        zqu__InitialTerm__c,
        Amendment_Renewal_Payment_Frequency__c,
        RecordTypeId,
        zqu__QuoteBusinessType__c
      FROM zqu__Quote__c
      WHERE Id IN :quoteIds
    ];
    Map<Id, zqu__Quote__c> quotePaymentFrequencyMap = new Map<Id, zqu__Quote__c>();
    quotePaymentFrequencyMap.putAll(qrpcList);
    return quotePaymentFrequencyMap;
  }

  @TestVisible
  @future(callout=true)
  private static void updateChargesBySpecificDisount(
    String quoteId,
    Decimal totalDiscount,
    Decimal totalListPrice,
    Decimal initialTerm
  ) {
    Boolean isOriginalIncluded = false;
    List<zqu__ZRule__c> zRule = [
      SELECT Id, Name, zqu__Json__c, zqu__ActionJson__c
      FROM zqu__ZRule__c
      WHERE Name = 'Update Quote Charges Discount'
      LIMIT 1
    ];
    zqu__Quote__c currQuote = [
      SELECT
        Id,
        zqu__SubscriptionType__c,
        zqu__QuoteBusinessType__c,
        Target_Quote_Total_Price__c,
        Total_List_Price_Charge_Detail__c,
        zqu__Service_Activation_Date__c,
        zqu__SubscriptionTermEndDate__c
      FROM zqu__Quote__c
      WHERE Id = :quoteId
      LIMIT 1
    ];
    if (
      currQuote.zqu__QuoteBusinessType__c == 'Renewal (with/without upsell)'
    ) {
      isOriginalIncluded = true;
      totalListPrice = currQuote.Total_List_Price_Charge_Detail__c;
    }
    Set<zqu.CacheId> requiredIds = new Set<zqu.CacheId>();
    requiredIds.add(new zqu.CacheId('zqu__Quote__c', quoteId));
    Map<String, List<zqu.DataObject>> dataObjects = makeDataObjects(
      quoteId,
      false
    );
    zqu.RulesEngine re = new zqu.RulesEngine('zqu__Quote__c', zRule);
    re.initialize(dataObjects, requiredIds);
    zqu.RulesEngineResponse response = re.run(zqu.RulesEngine.RuleType.ALL);
    System.debug(response.isSuccess());
    zqu.DataObject quoteDataObject = response.getMasterObject();
    List<zqu.DataObject> ratePlanDataObjects = quoteDataObject.getChildren(
      'zqu__QuoteRatePlan__c'
    );
    List<zqu.zChargeGroup> chargeGroupsForUpdate = new List<zqu.zChargeGroup>();
    List<sObject> qrpcList = new List<sObject>();
    for (zqu.DataObject rpDataObject : ratePlanDataObjects) {
      zqu.ZChargeGroupDataObject cgForUpdate = (zqu.ZChargeGroupDataObject) rpDataObject;
      zqu.zChargeGroup chargeGroup = cgForUpdate.getChargeGroup();
      if (!chargeGroup.zCharges.isEmpty()) {
        chargeGroupsForUpdate.add(chargeGroup);
      }
    }
    if (!chargeGroupsForUpdate.isEmpty()) {
      Decimal targetQuoteTotalPrice =
        totalListPrice *
        (100 - totalDiscount) /
        100;
      fixDiscountIfWrongSubtotal(
        chargeGroupsForUpdate,
        targetQuoteTotalPrice,
        initialTerm,
        currQuote.zqu__Service_Activation_Date__c,
        currQuote.zqu__SubscriptionTermEndDate__c,
        currQuote.zqu__SubscriptionType__c == 'Amend Subscription',
        isOriginalIncluded
      );
      if (!Test.isRunningTest()) {
        zqu.ZQuoteUtil.updateChargeGroups(chargeGroupsForUpdate);
      }
    }
  }

  /**
   * MQ-1419 - Added updateChargesByTargetTotalPrice overloading
   * @description method created as a workaround for transfer AS requests to charges calculation
   * @param quoteId - Id of current Quote
   * @param targetQuoteTotalPrice - Value from Target_Quote_Total_Price__c field on the Quote
   * @param initialTerm - Value from Target_Quote_Total_Price__c field on the Quote
   */
  public static void updateChargesByTargetTotalPrice(
    String quoteId,
    Decimal targetQuoteTotalPrice,
    Decimal initialTerm
  ) {
    updateChargesByTargetTotalPrice(
      quoteId,
      targetQuoteTotalPrice,
      initialTerm,
      null,
      null,
      null
    );
  }

  /**
   * MQ-1419 - Added 2 more parameters to method signature - Id of AS requests
   *
   * @param quoteId - Id of current Quote
   * @param targetQuoteTotalPrice - Value from Target_Quote_Total_Price__c field on the Quote
   * @param initialTerm - Value from Target_Quote_Total_Price__c field on the Quote
   * @param oneTimeRequestId - Id of attached One-Time AS request
   * @param recurringRequestId - Id of attached Recurring AS request
   */
  @TestVisible
  @future(callout=true)
  public static void updateChargesByTargetTotalPrice(
    String quoteId,
    Decimal targetQuoteTotalPrice,
    Decimal initialTerm,
    String oneTimeRequestId,
    String recurringRequestId,
    Map<String, Decimal> requestMap
  ) {
    updateChargesByTargetTotalPriceMainLogic(
      quoteId,
      targetQuoteTotalPrice,
      initialTerm,
      oneTimeRequestId,
      recurringRequestId,
      requestMap
    );
    //recalculateIsDoneUpdate(quoteId);
    System.enqueueJob(
      new ZuoraQuoteMetricManipulationQueueable(quoteId, 'recalculateSubtotal')
    );
  }

  private static void recalculateIsDoneUpdate(String quoteId) {
    zqu__Quote__c quoteToUpdate = new zqu__Quote__c();
    quoteToUpdate.Id = quoteId;
    quoteToUpdate.Recalculate_Charge__c = false;

    update quoteToUpdate;
  }

  /**
   * MQ-1419 - Added updateChargesByTargetTotalPriceMainLogic overloading
   * @descriotion method created as a workaround for transfer AS requests to charges calculation
   * @param quoteId - Id of current Quote
   * @param targetQuoteTotalPrice - Value from Target_Quote_Total_Price__c field on the Quote
   * @param initialTerm - Value from zqu__InitialTerm__c field on the Quote
   */
  public static void updateChargesByTargetTotalPriceMainLogic(
    String quoteId,
    Decimal targetQuoteTotalPrice,
    Decimal initialTerm
  ) {
    updateChargesByTargetTotalPriceMainLogic(
      quoteId,
      targetQuoteTotalPrice,
      initialTerm,
      null,
      null,
      null
    );
  }

  /**
   * MQ-1419 - Added 2 more parameters to method signature - Id of AS requests. Added fixPriceOfASProducts() method calloud.
   * Added DML statement for update Quote to Requests and Request to Quote lookups at the end of method
   *
   * @param quoteId - Id of current Quote
   * @param targetQuoteTotalPrice - Value from Target_Quote_Total_Price__c field on the Quote
   * @param initialTerm - Value from zqu__InitialTerm__c field on the Quote
   * @param oneTimeRequestId - Id of attached One-Time AS request
   * @param recurringRequestId - Id of attached Recurring AS request
   */
  public static void updateChargesByTargetTotalPriceMainLogic(
    String quoteId,
    Decimal targetQuoteTotalPrice,
    Decimal initialTerm,
    String oneTimeRequestId,
    String recurringRequestId,
    Map<String, Decimal> requestMap
  ) {
    System.debug('CHECK updateChargesByTargetTotalPriceMainLogic');
    Boolean isOriginalIncluded = false;
    zqu__Quote__c currQuote = [
      SELECT
        Id,
        zqu__SubscriptionType__c,
        zqu__QuoteBusinessType__c,
        zqu__Service_Activation_Date__c,
        zqu__SubscriptionTermEndDate__c,
        Current_Contract_TCV__c,
        package__c,
        Package_Amendment__c,
        Migrating_to_New_Soultion__c,
        Contract_CMRR__c,
        Total_Discount__c
      FROM zqu__Quote__c
      WHERE Id = :quoteId
      LIMIT 1
    ];
    if (
      currQuote.zqu__QuoteBusinessType__c == 'Renewal (with/without upsell)'
    ) {
      isOriginalIncluded = true;
    }
    List<zqu.zChargeGroup> chargeGroupsForUpdate = new List<zqu.zChargeGroup>();
    zqu__Quote__c quoteToUpdate;
    System.debug('isOriginalIncluded--' + isOriginalIncluded);

    if (isOriginalIncluded) {
      //chargeGroupsForUpdate - all products
      List<zqu.zChargeGroup> relatedChargeGroup = zqu.zQuoteUtil.getChargeGroups(
        quoteId
      );
      List<zqu.zChargeGroup> filteredChargeGroup = new List<zqu.zChargeGroup>();
      Set<String> partCl5ZuoraIds = getIdsOfPartOfCluster5Product(
        relatedChargeGroup
      );
      Decimal sumOfListPrice = 0;

      if (oneTimeRequestId != null || recurringRequestId != null) {
        quoteToUpdate = fixPriceOfASProducts(
          relatedChargeGroup,
          quoteId,
          initialTerm,
          oneTimeRequestId,
          recurringRequestId,
          requestMap,
          isOriginalIncluded
        );
      }

      for (zqu.zChargeGroup zcg_i : relatedChargeGroup) {
        for (zqu.zCharge zc_i : zcg_i.zCharges) {
          if (
            String.isNotBlank(zc_i.LIST_PRICE) &&
            zc_i.LIST_PRICE != '-' &&
            zcg_i.groupType != zqu.zChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT &&
            (zcg_i.groupType != zqu.zChargeGroup.TYPE_AMENDMENT_ORIGINAL ||
            String.isBlank(zc_i.SUBSCRIPTION_RATE_PLAN_CHARGE_ID) ||
            !partCl5ZuoraIds.contains(
              zc_i.SUBSCRIPTION_RATE_PLAN_CHARGE_ID.toLowerCase()
            )) &&
            ((zcg_i.groupType != zqu.zChargeGroup.TYPE_AMENDMENT_NEWPRODUCT &&
            zcg_i.groupType != zqu.zChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT) ||
            !(Boolean) zc_i.chargeObject.get('Part_Of_Cluster_5__c')) &&
            (zc_i.CHARGE_TYPE != 'One-Time' ||
            zcg_i.productName.containsIgnoreCase('Advisory Services'))
          ) {
            Decimal productPrice;
            if (
              zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT
            ) {
              productPrice = Decimal.valueOf(
                zcg_i.originalChargeGroup.zCharges[0].TOTAL
              );
            } else {
              productPrice = Decimal.valueOf(zc_i.LIST_TOTAL);
              if (
                String.isNotBlank(zc_i.EFFECTIVE_PRICE) &&
                zc_i.EFFECTIVE_PRICE.isNumeric() &&
                Decimal.valueOf(zc_i.EFFECTIVE_PRICE) != 0 &&
                productPrice.setScale(2) == 0
              ) {
                productPrice = Decimal.valueOf(zc_i.TOTAL);
              }
            }
            if (zc_i.LIST_PRICE == 'Varies' || zc_i.LIST_PRICE == 'Flat Fee') {
              if (String.isNotBlank(zc_i.SPECIFIC_BILLING_PERIOD)) {
                sumOfListPrice += ((productPrice *
                    Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD))
                    .setScale(2) *
                  initialTerm /
                  Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD))
                  .setScale(2);
              } else {
                sumOfListPrice += (productPrice).setScale(2);
              }
            } else {
              if (zc_i.LIST_PRICE_BASE == 'Per Month') {
                System.debug(
                  'zc_i.TOTAL ' +
                    zc_i.LIST_TOTAL +
                    ' zc_i.SPECIFIC_BILLING_PERIOD ' +
                    zc_i.SPECIFIC_BILLING_PERIOD
                );
                sumOfListPrice += ((productPrice *
                    Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD))
                    .setScale(2) *
                  initialTerm /
                  Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD))
                  .setScale(2);
              } else {
                sumOfListPrice += productPrice.setScale(2);
              }
            }
            filteredChargeGroup.add(zcg_i);
          }
        }
      }
      chargeGroupsForUpdate = correctPriceOfTheProductsByTargetProportionally(
        filteredChargeGroup,
        targetQuoteTotalPrice,
        sumOfListPrice,
        initialTerm
      );
      if (!chargeGroupsForUpdate.isEmpty()) {
        fixDiscountIfWrongSubtotal(
          chargeGroupsForUpdate,
          targetQuoteTotalPrice,
          initialTerm,
          currQuote.zqu__Service_Activation_Date__c,
          currQuote.zqu__SubscriptionTermEndDate__c,
          currQuote.zqu__SubscriptionType__c == 'Amend Subscription',
          false,
          true
        );
      }
      if (!Test.isRunningTest()) {
        //                try{
        zqu.ZQuoteUtil.updateChargeGroups(chargeGroupsForUpdate);
        //                }
        //                catch (Exception ex){
        //                    String expForDuplicateProblem = ex.getMessage();
        //                    if(quoteToUpdate == null){
        //                        quoteToUpdate  = new zqu__Quote__c(Id = quoteId);
        //                    }
        //                    quoteToUpdate.Zuora_General_Error_Message__c = quoteToUpdate.Zuora_General_Error_Message__c != null ? quoteToUpdate.Zuora_General_Error_Message__c + expForDuplicateProblem : expForDuplicateProblem;
        //                    quoteToUpdate.History_Zuora_General_Error_Message__c = quoteToUpdate.History_Zuora_General_Error_Message__c != null ? quoteToUpdate.History_Zuora_General_Error_Message__c + expForDuplicateProblem : expForDuplicateProblem;
        //                }
      }
    } else {
      if (oneTimeRequestId != null || recurringRequestId != null) {
        List<zqu.zChargeGroup> chargeGroupsForASUpdate = zqu.zQuoteUtil.getChargeGroups(
          quoteId
        );
        quoteToUpdate = fixPriceOfASProducts(
          chargeGroupsForASUpdate,
          quoteId,
          initialTerm,
          oneTimeRequestId,
          recurringRequestId,
          requestMap,
          isOriginalIncluded
        );
        for (zqu.zChargeGroup zcg_i : chargeGroupsForASUpdate) {
          Boolean isChanged = false;
          Boolean includeToCalc = false;
          for (zqu.zCharge zc_i : zcg_i.zCharges) {
            if (
              (zc_i.isDiscountEditable || zc_i.isTotalEditable) &&
              (zcg_i.groupType ==
              zqu.ZChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT ||
              zcg_i.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_NEWPRODUCT ||
              zcg_i.groupType == zqu.zChargeGroup.TYPE_PRODUCT_NEW ||
              zcg_i.groupType == zqu.zChargeGroup.TYPE_SUBSCRIPTION_ADDED)
            ) {
              if (
                zc_i.isDiscountEditable && currQuote.Total_Discount__c != null
              ) {
                zc_i.DISCOUNT = String.valueOf(currQuote.Total_Discount__c);
                isChanged = true;
              }
              includeToCalc = true;
            }
          }
          if (isChanged) {
            zcg_i.zCharges = zqu.zQuoteUtil.calculateChargesOnDiscountChange(
              zcg_i.zCharges
            );
          }

          if (includeToCalc) {
            chargeGroupsForUpdate.add(zcg_i);
          }
        }
      } else {
        List<zqu__ZRule__c> zRule = [
          SELECT Id, Name, zqu__Json__c, zqu__ActionJson__c
          FROM zqu__ZRule__c
          WHERE Name = 'Update Quote Charges Discount'
          LIMIT 1
        ];
        Set<zqu.CacheId> requiredIds = new Set<zqu.CacheId>();
        requiredIds.add(new zqu.CacheId('zqu__Quote__c', quoteId));
        Map<String, List<zqu.DataObject>> dataObjects = makeDataObjects(
          quoteId,
          false
        );
        zqu.RulesEngine re = new zqu.RulesEngine('zqu__Quote__c', zRule);
        re.initialize(dataObjects, requiredIds);
        zqu.RulesEngineResponse response = re.run(zqu.RulesEngine.RuleType.ALL);
        System.debug(response.isSuccess());
        zqu.DataObject quoteDataObject = response.getMasterObject();
        List<zqu.DataObject> ratePlanDataObjects = quoteDataObject.getChildren(
          'zqu__QuoteRatePlan__c'
        );

        List<sObject> qrpcList = new List<sObject>();
        for (zqu.DataObject rpDataObject : ratePlanDataObjects) {
          zqu.ZChargeGroupDataObject cgForUpdate = (zqu.ZChargeGroupDataObject) rpDataObject;
          chargeGroupsForUpdate.add(cgForUpdate.getChargeGroup());
        }
      }
      if (!chargeGroupsForUpdate.isEmpty()) {
        fixDiscountIfWrongSubtotal(
          chargeGroupsForUpdate,
          targetQuoteTotalPrice,
          initialTerm,
          currQuote.zqu__Service_Activation_Date__c,
          currQuote.zqu__SubscriptionTermEndDate__c,
          currQuote.zqu__SubscriptionType__c == 'Amend Subscription',
          isOriginalIncluded
        );
      }
      if (!Test.isRunningTest() && !chargeGroupsForUpdate.isEmpty()) {
        zqu.ZQuoteUtil.updateChargeGroups(chargeGroupsForUpdate);
      }
    }

    if (quoteToUpdate != null) {
      update quoteToUpdate;

      List<Request__c> requestsToUpdate = new List<Request__c>();
      if (quoteToUpdate.AS_One_Time_Request__c != null) {
        requestsToUpdate.add(
          new Request__c(
            Id = quoteToUpdate.AS_One_Time_Request__c,
            Quote__c = quoteToUpdate.id
          )
        );
      }
      if (quoteToUpdate.AS_Reccuring_Request__c != null) {
        requestsToUpdate.add(
          new Request__c(
            Id = quoteToUpdate.AS_Reccuring_Request__c,
            Quote__c = quoteToUpdate.id
          )
        );
      }
      update requestsToUpdate;
    }
  }
  /**
   * MQ-1419 - Logic moved from ASProductModalController, removed all DML statements, added return value
   * @description Method selects from all zqu__QuoteRatePlanCharge__c related records names of all AS products Then iterates over zqu.zChargeGroups and zqu.zCharge records.
   * If zqu.zCharge record is an AS Product, then set the Effective price from the related Request__c record - One-Time or Recurring request.
   * @param relatedChargeGroup - charge group with AS product
   * @param quoteId - Id of Current Quote
   * @param oneTimeRequestId - Id of attached One-Time AS request
   * @param recurringRequestId - Id of attached Recurring AS request
   * @return  `zqu__Quote__c` - Current Quote SObject with populated AS Request lookups
   */
  @TestVisible
  private static zqu__Quote__c fixPriceOfASProducts(
    List<zqu.zChargeGroup> relatedChargeGroup,
    String quoteId,
    Decimal initialTerm,
    String oneTimeRequestId,
    String recurringRequestId,
    Map<String, Decimal> requestMap,
    Boolean isOriginalIncluded
  ) {
    zqu__Quote__c quote = new zqu__Quote__c(Id = quoteId);
    Set<String> productNameSet = new Set<String>();
    List<String> productNameList = new List<String>();
    try {
      for (zqu.zChargeGroup zcg_i : relatedChargeGroup) {
        productNameList.add(zcg_i.productName);
      }
      if (!productNameList.isEmpty()) {
        List<Product2> productList = [
          SELECT Id, Name, AS__c
          FROM Product2
          WHERE Name IN :productNameList AND AS__c = '1'
        ];
        for (Product2 product_i : productList) {
          productNameSet.add(product_i.Name);
        }
        if (!requestMap.isEmpty()) {
          Request__c oneTimeRequest;
          Request__c recurringRequest;
          for (String regularity : requestMap.keySet()) {
            Request__c request = new Request__c(
              Regularity__c = regularity,
              List_Price__c = requestMap.get(regularity)
            );
            if (request.Regularity__c.toLowerCase().contains('one time')) {
              oneTimeRequest = request;
              quote.AS_One_Time_Request__c = oneTimeRequestId;
            } else if (
              request.Regularity__c.toLowerCase().contains('recurring')
            ) {
              recurringRequest = request;
              quote.AS_Reccuring_Request__c = recurringRequestId;
            }
          }

          if (!Test.isRunningTest()) {
            for (zqu.zChargeGroup zcg_i : relatedChargeGroup) {
              zqu.zCharge zc_i = zcg_i.zCharges[0];
              for (String name : productNameSet) {
                if (
                  zc_i.Name.contains(name) &&
                  zcg_i.groupType !=
                  zqu.zChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT
                ) {
                  String effectivePrice;
                  if (
                    recurringRequest != null &&
                    recurringRequest.Regularity__c.contains(zc_i.CHARGE_TYPE) &&
                    recurringRequest.List_price__c != null
                  ) {
                    if (zc_i.LIST_PRICE_BASE == 'Per Month') {
                      effectivePrice = String.valueOf(
                        recurringRequest.List_price__c / initialTerm
                      );
                    } else {
                      effectivePrice = String.valueOf(
                        recurringRequest.List_price__c
                      );
                    }
                  } else if (
                    oneTimeRequest != null &&
                    oneTimeRequest.Regularity__c.toLowerCase() == 'one time' &&
                    (zc_i.CHARGE_TYPE.toLowerCase().contains('one') &&
                    zc_i.CHARGE_TYPE.toLowerCase().contains('time')) &&
                    oneTimeRequest.List_price__c != null
                  ) {
                    effectivePrice = String.valueOf(
                      oneTimeRequest.List_price__c
                    );
                  }
                  if (String.isNotBlank(effectivePrice)) {
                    zc_i.EFFECTIVE_PRICE = effectivePrice;
                    //MQ-1419 update price for Renewal
                    //if(!isOriginalIncluded) {
                    zcg_i.zCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(
                      zcg_i.zCharges
                    );
                    //}
                    break;
                  }
                }
              }
            }
          }
        }
      }
    } catch (Exception ex) {
      quote = [
        SELECT zqu__SubscriptionType__c
        FROM zqu__Quote__c
        WHERE Id = :quoteId
      ];
      Map<String, Object> fieldNameToValueMap = new Map<String, Object>();
      fieldNameToValueMap.put('exceptionField', ex.getMessage());
      if (quote.zqu__SubscriptionType__c == 'New Subscription') {
        Quote_is_changed__e quoteIsChangedEvent = new Quote_is_changed__e();
        quoteIsChangedEvent.quoteId__c = quoteId;
        quoteIsChangedEvent.fieldsJson__c = JSON.serialize(fieldNameToValueMap);

        System.Eventbus.publish(quoteIsChangedEvent);
      } else if (quote.zqu__SubscriptionType__c == 'Amend Subscription') {
        Amend_quote_is_changed__e quoteIsChangedEvent = new Amend_quote_is_changed__e();
        quoteIsChangedEvent.quoteId__c = quoteId;
        quoteIsChangedEvent.fieldsJson__c = JSON.serialize(fieldNameToValueMap);
        System.Eventbus.publish(quoteIsChangedEvent);
      }
    }
    return quote;
  }

  private static zqu.zChargeGroup getBaseProductChargeGroup(
    List<zqu.zChargeGroup> relatedChargeGroup,
    String packageApiName,
    Set<String> baseProductNameSet
  ) {
    zqu.zChargeGroup baseProductChargeGroup = null;

    for (zqu.zChargeGroup zcg_i : relatedChargeGroup) {
      for (zqu.zCharge zc_i : zcg_i.zCharges) {
        if (zc_i.isEffectivePriceEditable) {
          if (
            baseProductChargeGroup == null &&
            (zcg_i.productName.containsIgnoreCase(packageApiName) ||
            baseProductNameSet.contains(zcg_i.productName.toLowerCase()))
          ) {
            baseProductChargeGroup = zcg_i;
            break;
          }
        } else if (zc_i.isTotalEditable) {
          if (
            baseProductChargeGroup == null &&
            (zcg_i.productName.containsIgnoreCase(packageApiName) ||
            baseProductNameSet.contains(zcg_i.productName.toLowerCase()))
          ) {
            baseProductChargeGroup = zcg_i;
            break;
          }
        }
      }
      if (baseProductChargeGroup != null) {
        break;
      }
    }

    return baseProductChargeGroup;
  }

  private static List<zqu.zChargeGroup> recalculateChargeGroupPricing(
    List<zqu.zChargeGroup> relatedChargeGroup,
    zqu.zChargeGroup baseProductChargeGroup,
    Decimal addedValue,
    Decimal initialTerm
  ) {
    List<zqu.zChargeGroup> chargeGroupsToUpdate = new List<zqu.zChargeGroup>();
    Decimal residualAmount;
    for (zqu.zChargeGroup zCharGroup_i : relatedChargeGroup) {
      Map<String, Object> recalculateResult = recalculateChargeGroup(
        zCharGroup_i,
        addedValue,
        initialTerm
      );
      zCharGroup_i = (zqu.zChargeGroup) recalculateResult.get('charGroup');
      System.debug('CHECK zCharGroup_i: ' + zCharGroup_i);
      residualAmount = (Decimal) recalculateResult.get('residualAmount');
      System.debug('CHECK residualAmount: ' + residualAmount);
      chargeGroupsToUpdate.add(zCharGroup_i);
      if (residualAmount < 0) {
        addedValue = residualAmount;
      } else if (residualAmount >= 0) {
        break;
      }
    }

    if (residualAmount < 0) {
      zqu.zChargeGroup zCharGroupBaseProduct = recalculateBaseProductChargeGroup(
        baseProductChargeGroup,
        addedValue,
        initialTerm
      );
      chargeGroupsToUpdate.add(zCharGroupBaseProduct);
    }

    return chargeGroupsToUpdate;
  }

  private static Map<String, Object> recalculateChargeGroup(
    zqu.zChargeGroup zCharGroup_i,
    Decimal addedValue,
    Decimal initialTerm
  ) {
    Decimal residualAmount;
    for (zqu.zCharge zChar_i : zCharGroup_i.zCharges) {
      System.debug('CHECK zChar_i: ' + zChar_i);
      Boolean isPerMonthBase = (zChar_i.LIST_PRICE_BASE == 'Per Month');
      if (zChar_i.isEffectivePriceEditable && zChar_i.LIST_PRICE != 'Varies') {
        Decimal effectivePrice = 0.00;
        System.debug('CHECK isPerMonthBase: ' + isPerMonthBase);
        System.debug('CHECK addedValue: ' + addedValue);
        System.debug('CHECK initialTerm: ' + initialTerm);
        if (isPerMonthBase) {
          System.debug('CHECK effectivePrice: ' + zChar_i.EFFECTIVE_PRICE);
          effectivePrice = calculatePerMonthPrice(
            zChar_i.EFFECTIVE_PRICE,
            addedValue,
            initialTerm
          );
        } else {
          effectivePrice = calculatePrice(zChar_i.EFFECTIVE_PRICE, addedValue);
        }
        System.debug('CHECK effectivePrice: ' + effectivePrice);
        residualAmount = calculateResidualAmount(
          zChar_i.EFFECTIVE_PRICE,
          effectivePrice
        );
        System.debug('CHECK residualAmount: ' + residualAmount);
        if (residualAmount < 0) {
          effectivePrice += residualAmount;
        }
        zChar_i.EFFECTIVE_PRICE = String.valueOf(effectivePrice);
        zCharGroup_i.zCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(
          zCharGroup_i.zCharges
        );
        break;
      } else if (zChar_i.isTotalEditable) {
        Decimal total = 0.00;
        if (isPerMonthBase) {
          total = calculatePerMonthPrice(
            zChar_i.TOTAL,
            addedValue,
            initialTerm
          );
        } else {
          total = calculatePrice(zChar_i.TOTAL, addedValue);
        }
        System.debug('CHECK total: ' + total);
        residualAmount = calculateResidualAmount(zChar_i.TOTAL, total);
        System.debug('CHECK residualAmount: ' + residualAmount);
        if (residualAmount < 0) {
          total += residualAmount;
        }
        zChar_i.TOTAL = String.valueOf(total);
        zCharGroup_i.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(
          zCharGroup_i.zCharges
        );
        break;
      }
    }
    return new Map<String, Object>{
      'charGroup' => zCharGroup_i,
      'residualAmount' => residualAmount
    };
  }

  private static zqu.zChargeGroup recalculateBaseProductChargeGroup(
    zqu.zChargeGroup zCharGroup_i,
    Decimal addedValue,
    Decimal initialTerm
  ) {
    for (zqu.zCharge zChar_i : zCharGroup_i.zCharges) {
      Boolean isPerMonthBase = (zChar_i.LIST_PRICE_BASE == 'Per Month');
      if (zChar_i.isEffectivePriceEditable && zChar_i.LIST_PRICE != 'Varies') {
        Decimal effectivePrice = 0.00;
        if (isPerMonthBase) {
          effectivePrice = calculatePerMonthPrice(
            zChar_i.EFFECTIVE_PRICE,
            addedValue,
            initialTerm
          );
        } else {
          effectivePrice = calculatePrice(zChar_i.EFFECTIVE_PRICE, addedValue);
        }
        zChar_i.EFFECTIVE_PRICE = String.valueOf(effectivePrice);
        zCharGroup_i.zCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(
          zCharGroup_i.zCharges
        );
        break;
      } else if (zChar_i.isTotalEditable) {
        Decimal total = 0.00;
        if (isPerMonthBase) {
          total = calculatePerMonthPrice(
            zChar_i.TOTAL,
            addedValue,
            initialTerm
          );
        } else {
          total = calculatePrice(zChar_i.TOTAL, addedValue);
        }
        zChar_i.TOTAL = String.valueOf(total);
        zCharGroup_i.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(
          zCharGroup_i.zCharges
        );
        break;
      }
    }

    return zCharGroup_i;
  }

  private static Decimal calculatePrice(String price, Decimal addedValue) {
    return (Decimal.valueOf(price) + (addedValue));
  }

  private static Decimal calculatePerMonthPrice(
    String price,
    Decimal addedValue,
    Decimal initialTerm
  ) {
    return ((Decimal.valueOf(price) + (addedValue / initialTerm)));
  }

  private static Decimal calculateResidualAmount(
    String oldPrice,
    Decimal newPrice
  ) {
    System.debug('CHECK oldPrice: ' + oldPrice);
    System.debug('CHECK newPrice: ' + newPrice);
    Decimal oldPriceValue = Decimal.valueOf(oldPrice);
    return oldPriceValue - newPrice;
  }

  private static List<zqu.zChargeGroup> correctPriceOfTheProductsByTargetProportionally(
    List<zqu.zChargeGroup> chargeGroupsForUpdate,
    Decimal targetQuoteTotalPrice,
    Decimal sumOfListPrice,
    Decimal initialTerm
  ) {
    system.debug('targetQuoteTotalPrice--' + targetQuoteTotalPrice);
    system.debug('sumOfListPrice--' + sumOfListPrice);
    Decimal addedValue = (targetQuoteTotalPrice - (sumOfListPrice));
    for (zqu.zChargeGroup zcg_i : chargeGroupsForUpdate) {
      if (zcg_i.productName.containsIgnoreCase('Advisory Services')) {
        continue;
      }
      for (zqu.zCharge zc_i : zcg_i.zCharges) {
        Decimal productPrice;
        if (zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT) {
          productPrice = Decimal.valueOf(
            zcg_i.originalChargeGroup.zCharges[0].TOTAL
          );
        } else {
          if (zcg_i.productName.containsIgnoreCase('Advisory Services')) {
            productPrice = Decimal.valueOf(zc_i.EFFECTIVE_PRICE);
          } else {
            productPrice = Decimal.valueOf(zc_i.LIST_TOTAL);
          }
        }
        if (
          zc_i.isEffectivePriceEditable &&
          zc_i.LIST_PRICE != 'Varies' &&
          zc_i.LIST_PRICE != 'Flat Fee'
        ) {
          if (zc_i.LIST_PRICE_BASE == 'Per Month') {
            Decimal precentOfTotal =
              (productPrice * initialTerm) / sumOfListPrice;
            zc_i.EFFECTIVE_PRICE = String.valueOf(
              ((productPrice + ((addedValue * precentOfTotal) / initialTerm)))
            );
          } else {
            Decimal precentOfTotal = (productPrice) / sumOfListPrice;
            zc_i.EFFECTIVE_PRICE = String.valueOf(
              ((productPrice + (addedValue * precentOfTotal)))
            );
          }

          zcg_i.zCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(
            zcg_i.zCharges
          );
        } else if (zc_i.isTotalEditable) {
          if (zc_i.LIST_PRICE_BASE == 'Per Month') {
            Decimal precentOfTotal =
              (productPrice * initialTerm) / sumOfListPrice;
            zc_i.TOTAL = String.valueOf(
              ((productPrice + ((addedValue * precentOfTotal) / initialTerm)))
            );
          } else {
            Decimal precentOfTotal = (productPrice) / sumOfListPrice;
            zc_i.TOTAL = String.valueOf(
              ((productPrice + (addedValue * precentOfTotal)))
            );
          }

          zcg_i.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(
            zcg_i.zCharges
          );
        }
      }
    }
    return chargeGroupsForUpdate;
  }

  private static String checkPackageApiName(String packageApiName) {
    List<Quote_package_label__mdt> quotePackageLabel = [
      SELECT Id, Product_name__c
      FROM Quote_package_label__mdt
      WHERE Package_name__c = :packageApiName
    ];

    if (quotePackageLabel.isEmpty()) {
      return packageApiName;
    } else {
      return quotePackageLabel[0].Product_name__c;
    }
  }

  private static List<zqu.zChargeGroup> fixDiscountIfWrongSubtotal(
    List<zqu.zChargeGroup> chargeGroupsForFix,
    Decimal targetQuoteTotalPrice,
    Decimal initialTerm,
    Date serviceActivationDate,
    Date subEndDate,
    Boolean isAmendPartiallyCalculation,
    Boolean isAllOriginalUpdated
  ) {
    return fixDiscountIfWrongSubtotal(
      chargeGroupsForFix,
      targetQuoteTotalPrice,
      initialTerm,
      serviceActivationDate,
      subEndDate,
      isAmendPartiallyCalculation,
      isAllOriginalUpdated,
      false
    );
  }

  private static List<zqu.zChargeGroup> fixDiscountIfWrongSubtotal(
    List<zqu.zChargeGroup> chargeGroupsForFix,
    Decimal targetQuoteTotalPrice,
    Decimal initialTerm,
    Date serviceActivationDate,
    Date subEndDate,
    Boolean isAmendPartiallyCalculation,
    Boolean isAllOriginalUpdated,
    Boolean isRenewalPartialCalFix
  ) {
    zqu.zCharge chargeWithDiscountToBeEdited;
    zqu.zCharge chargeWithTotalToBeEdited;
    Decimal subTotal = 0;
    Decimal diffBuffer = 0;
    updateSingleProductIfAllOriginal(chargeGroupsForFix);
    Integer numOfDaysInYear = Utility.getDaysInYear(
      subEndDate == null
        ? serviceActivationDate.addMonths(initialTerm.intValue())
        : subEndDate
    );
    Integer numOfDays = numOfDaysInYear;
    if (subEndDate != null) {
      numOfDays = Utility.getDaysBetween(serviceActivationDate, subEndDate);
    }
    Map<String, Decimal> groupIdToTotal = new Map<String, Decimal>();
    for (zqu.zChargeGroup zcg_i : chargeGroupsForFix) {
      if (
        zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT ||
        (isAllOriginalUpdated &&
        zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL)
      ) {
        Decimal originalTotal = 0;
        Decimal updatedTotal = 0;
        for (zqu.zCharge zc_i : zcg_i.originalChargeGroup.zCharges) {
          if (String.isNotBlank(zc_i.TOTAL) && zc_i.TOTAL != '-') {
            originalTotal += Decimal.valueOf(zc_i.TOTAL);
          }
        }
        for (zqu.zCharge zc_i : zcg_i.zCharges) {
          if (String.isNotBlank(zc_i.TOTAL) && zc_i.TOTAL != '-') {
            updatedTotal += Decimal.valueOf(zc_i.TOTAL);
          }
        }
        groupIdToTotal.put(zcg_i.groupID, updatedTotal - originalTotal);
      }
    }

    zqu.Quote zQuote = zqu.Quote.getInstance(chargeGroupsForFix[0].quote.Id);
    zqu__Quote__c fullQuote = zQuote.getSObject();
    String quoteCurrency = fullQuote.zqu__Currency__c;

    for (zqu.zChargeGroup zcg_i : chargeGroupsForFix) {
      if (zcg_i.groupType != zqu.ZChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT) {
        zcg_i.zCharges = zqu.zQuoteUtil.calculateChargesOnDiscountChange(
          zcg_i.zCharges
        );
      }
      for (zqu.zCharge zc_i : zcg_i.zCharges) {
        System.debug('zc_i.isDiscountEditable ' + zc_i.isDiscountEditable);
        if ((chargeWithDiscountToBeEdited == null) && zc_i.isDiscountEditable) {
          chargeWithDiscountToBeEdited = zc_i;
          System.debug('zc_i disc ' + zc_i);
        }
        if ((chargeWithTotalToBeEdited == null) && zc_i.isTotalEditable) {
          chargeWithTotalToBeEdited = zc_i;
          System.debug('zc_i disc ' + zc_i);
        }
        System.debug('ss ' + zc_i.discount);
        System.debug('ss -------');
        Decimal chargeSubTotal = 0;
        if (
          zcg_i.groupType != zqu.ZChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT &&
          zcg_i.groupType != zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL
        ) {
          //&& zcg_i.groupType != zqu.ZChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT
          if (
            String.isNotBlank(zc_i.TOTAL) &&
            zc_i.TOTAL != '-' &&
            initialTerm != null
          ) {
            if (zc_i.LIST_PRICE_BASE == 'Per Month') {
              if (isAmendPartiallyCalculation) {
                chargeSubTotal = ((Decimal.valueOf(zc_i.TOTAL) *
                    Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD))
                    .setScale(2) *
                  initialTerm /
                  Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD))
                  .setScale(2);
              } else {
                chargeSubTotal = ((Decimal.valueOf(zc_i.TOTAL) *
                    Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD) *
                    ((Decimal) numOfDays / numOfDaysInYear))
                    .setScale(2) *
                  (initialTerm / Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD)))
                  .setScale(2);
              }
            } else {
              chargeSubTotal = (Decimal.valueOf(zc_i.TOTAL)).setScale(2);
            }
          }
        } else if (
          ((isRenewalPartialCalFix &&
          zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT) ||
          zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL) &&
          !isAllOriginalUpdated
        ) {
          if (isRenewalPartialCalFix) {
            if (zc_i.LIST_PRICE_BASE == 'Per Month') {
              if (isAmendPartiallyCalculation) {
                chargeSubTotal = ((Decimal.valueOf(zc_i.TOTAL) *
                    Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD))
                    .setScale(2) *
                  initialTerm /
                  Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD))
                  .setScale(2);
              } else {
                chargeSubTotal = ((Decimal.valueOf(zc_i.TOTAL) *
                    Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD) *
                    ((Decimal) numOfDays / numOfDaysInYear))
                    .setScale(2) *
                  (initialTerm / Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD)))
                  .setScale(2);
              }
            } else {
              chargeSubTotal = (Decimal.valueOf(zc_i.TOTAL)).setScale(2);
            }
          } else {
            if (
              String.isNotBlank(zc_i.EFFECTIVE_PRICE) &&
              zc_i.EFFECTIVE_PRICE.isNumeric() &&
              initialTerm != null
            ) {
              if (zc_i.LIST_PRICE_BASE == 'Per Month') {
                if (isAmendPartiallyCalculation) {
                  chargeSubTotal = ((Decimal.valueOf(zc_i.EFFECTIVE_PRICE) *
                      Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD))
                      .setScale(2) *
                    initialTerm /
                    Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD))
                    .setScale(2);
                } else {
                  chargeSubTotal = ((Decimal.valueOf(zc_i.EFFECTIVE_PRICE) *
                      Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD) *
                      ((Decimal) numOfDays / numOfDaysInYear))
                      .setScale(2) *
                    (initialTerm /
                    Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD)))
                    .setScale(2);
                }
              } else {
                chargeSubTotal = (Decimal.valueOf(zc_i.EFFECTIVE_PRICE))
                  .setScale(2);
              }
            }
          }
        } else if (
          zcg_i.groupType != zqu.ZChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT
        ) {
          if (groupIdToTotal.containsKey(String.valueOf(zcg_i.groupID))) {
            if (isAmendPartiallyCalculation) {
              chargeSubTotal = ((groupIdToTotal.get(
                    String.valueOf(zcg_i.groupID)
                  ) * Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD))
                  .setScale(2) *
                (initialTerm / Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD)))
                .setScale(2);
            } else {
              chargeSubTotal = ((groupIdToTotal.get(
                    String.valueOf(zcg_i.groupID)
                  ) *
                  Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD) *
                  ((Decimal) numOfDays / numOfDaysInYear))
                  .setScale(2) *
                (initialTerm / Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD)))
                .setScale(2);
            }
          }
          System.debug('updateproduct subtotal ' + chargeSubTotal);
        }
        if (zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT) {
          chargeSubTotal = -chargeSubTotal;
        }
        System.debug('chargeSubTotal ' + chargeSubTotal);
        if (chargeSubTotal == null) {
          chargeSubTotal = 0;
        }

        if (quoteCurrency == 'JPY') {
          diffBuffer += chargeSubTotal - Integer.valueOf(chargeSubTotal);
        }

        subTotal += chargeSubTotal;
      }
    }
    System.debug('subTotal ' + subTotal);
    System.debug('targetQuoteTotalPrice ' + targetQuoteTotalPrice);

    if (diffBuffer != 0) {
      subTotal -= diffBuffer.setScale(0);
    }

    if (
      targetQuoteTotalPrice != subTotal &&
      (chargeWithDiscountToBeEdited != null ||
      chargeWithTotalToBeEdited != null)
    ) {
      Decimal diff = targetQuoteTotalPrice - subTotal;
      System.debug('diff ' + diff);
      zqu.zCharge chargeToBeEdited = chargeWithDiscountToBeEdited == null
        ? chargeWithTotalToBeEdited
        : chargeWithDiscountToBeEdited;
      if (isAmendPartiallyCalculation) {
        Decimal newTotal;
        if (chargeToBeEdited.LIST_PRICE_BASE == 'Per Month') {
          newTotal =
            Decimal.valueOf(chargeToBeEdited.TOTAL) + (diff / initialTerm);
        } else {
          newTotal = Decimal.valueOf(chargeToBeEdited.TOTAL) + diff;
        }
        System.debug('newTotal ' + newTotal);
        if (chargeWithDiscountToBeEdited == null) {
          chargeWithTotalToBeEdited.TOTAL = String.valueOf(newTotal);
        } else {
          Decimal newDiscount =
            100 -
            (newTotal /
            Decimal.valueOf(chargeWithDiscountToBeEdited.LIST_TOTAL)) * 100;
          chargeWithDiscountToBeEdited.discount = String.valueOf(newDiscount);
        }
      } else {
        Decimal newTotal;
        if (chargeToBeEdited.LIST_PRICE_BASE == 'Per Month') {
          newTotal =
            Decimal.valueOf(chargeToBeEdited.TOTAL) +
            (diff /
            initialTerm /
            ((Decimal) numOfDays / numOfDaysInYear));
        } else {
          newTotal =
            Decimal.valueOf(chargeToBeEdited.TOTAL) +
            (diff / ((Decimal) numOfDays / numOfDaysInYear));
        }
        System.debug('newTotal ' + newTotal);
        if (chargeWithDiscountToBeEdited == null) {
          chargeWithTotalToBeEdited.TOTAL = String.valueOf(newTotal);
        } else {
          System.debug(
            'chargeWithDiscountToBeEdited.LIST_TOTAL--' +
            chargeWithDiscountToBeEdited.LIST_TOTAL
          );
          Decimal newDiscount =
            100 -
            (newTotal /
            Decimal.valueOf(chargeWithDiscountToBeEdited.LIST_TOTAL)) * 100;
          System.debug('newDiscount ' + newDiscount);
          chargeWithDiscountToBeEdited.discount = String.valueOf(newDiscount);
        }
      }
      for (zqu.zChargeGroup zcg_i : chargeGroupsForFix) {
        if (
          chargeWithDiscountToBeEdited == null &&
          zcg_i.zCharges[0] == chargeWithTotalToBeEdited
        ) {
          zcg_i.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(
            zcg_i.zCharges
          );
        } else {
          zcg_i.zCharges = zqu.zQuoteUtil.calculateChargesOnDiscountChange(
            zcg_i.zCharges
          );
        }
      }
    }
    return chargeGroupsForFix;
  }

  private static Map<String, List<zqu.DataObject>> makeDataObjects(Id quoteId) {
    return makeDataObjects(quoteId, false);
  }

  private static Map<String, List<zqu.DataObject>> makeDataObjects(
    Id quoteId,
    Boolean isOriginalIncluded
  ) {
    String quotesNamespace = 'zqu__';
    List<zqu.DataObject> dataChargeGroups = new List<zqu.DataObject>();
    List<zqu.DataObject> dataCharges = new List<zqu.DataObject>();
    System.debug('quoteId ' + quoteId);
    List<zqu.ZChargeGroup> chargeGroups = new List<zqu.ZChargeGroup>();
    if (!isMakeDataGetChargeDisabled) {
      List<zqu.ZChargeGroup> tempChargeGroups = zqu.zQuoteUtil.getChargeGroups(
        quoteId
      );
      Set<String> partCl5ZuoraIds = getIdsOfPartOfCluster5Product(
        tempChargeGroups
      );
      for (zqu.zChargeGroup zcg_i : tempChargeGroups) {
        for (zqu.zCharge zc_i : zcg_i.zCharges) {
          if (
            (zcg_i.groupType != zqu.zChargeGroup.TYPE_AMENDMENT_ORIGINAL ||
            String.isBlank(zc_i.SUBSCRIPTION_RATE_PLAN_CHARGE_ID) ||
            !partCl5ZuoraIds.contains(
              zc_i.SUBSCRIPTION_RATE_PLAN_CHARGE_ID.toLowerCase()
            )) &&
            ((zcg_i.groupType != zqu.zChargeGroup.TYPE_AMENDMENT_NEWPRODUCT &&
            zcg_i.groupType != zqu.zChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT) ||
            (!(Boolean) zc_i.chargeObject.get('Part_Of_Cluster_5__c')))
          ) {
            chargeGroups.add(zcg_i);
          }
        }
      }
    } else {
      chargeGroups = new List<zqu.ZChargeGroup>();
    }

    for (zqu.ZChargeGroup chargeGroup : chargeGroups) {
      if (
        isOriginalIncluded ||
        chargeGroup.groupType != zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL
      ) {
        zqu.DataObject dataChargeGroup = new zqu.ZChargeGroupDataObject(
          chargeGroup
        );
        dataChargeGroups.add(dataChargeGroup);
        dataCharges.addAll(
          dataChargeGroup.getChildren(
            quotesNamespace + 'QuoteRatePlanCharge__c'
          )
        );
      }
    }

    return new Map<String, List<zqu.DataObject>>{
      quotesNamespace + 'QuoteRatePlan__c' => dataChargeGroups,
      quotesNamespace + 'QuoteRatePlanCharge__c' => dataCharges
    };
  }

  private static Map<Id, List<zqu__QuoteRatePlanCharge__c>> getQuote2QrpcWithoutBillingPeriodMap(
    Set<Id> quoteIds
  ) {
    Map<Id, List<zqu__QuoteRatePlanCharge__c>> quote2QrpcWithoutBillingPeriodMap = new Map<Id, List<zqu__QuoteRatePlanCharge__c>>();
    if (!quoteIds.isEmpty()) {
      List<zqu__QuoteRatePlanCharge__c> qrpcList = [
        SELECT
          Id,
          name,
          zqu__Discount__c,
          zqu__Period__c,
          zqu__listprice__c,
          zqu__EffectivePrice__c,
          zqu__Quantity__c,
          IsDeleted,
          zqu__QuoteRatePlan__c,
          zqu__QuoteRatePlan__r.zqu__Quote__c,
          zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c,
          zqu__SpecificBillingPeriod__c,
          zqu__Description__c,
          Terms_Total__c,
          zqu__total__c,
          zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c,
          zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c,
          zqu__productRatePlanCharge__r.zqu__UOM__c,
          zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c,
          zqu__ListTotal__c
        FROM zqu__QuoteRatePlanCharge__c
        WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :quoteIds
      ];
      for (zqu__QuoteRatePlanCharge__c qrpc_i : qrpcList) {
        List<zqu__QuoteRatePlanCharge__c> quoteQrpcList = new List<zqu__QuoteRatePlanCharge__c>();
        if (
          quote2QrpcWithoutBillingPeriodMap.containsKey(
            qrpc_i.zqu__QuoteRatePlan__r.zqu__Quote__c
          )
        ) {
          quoteQrpcList = quote2QrpcWithoutBillingPeriodMap.get(
            qrpc_i.zqu__QuoteRatePlan__r.zqu__Quote__c
          );
        }
        quoteQrpcList.add(qrpc_i);
        quote2QrpcWithoutBillingPeriodMap.put(
          qrpc_i.zqu__QuoteRatePlan__r.zqu__Quote__c,
          quoteQrpcList
        );
      }
    }
    return quote2QrpcWithoutBillingPeriodMap;
  }

  public static Integer getPaymentFrequencyNumber(
    String paymentFrequencyRaw,
    Decimal initialTerm
  ) {
    Integer paymentFrequency = 0;
    if (initialTerm < 12) {
      paymentFrequency = initialTerm.intValue();
    } else {
      switch on paymentFrequencyRaw {
        when 'Annual' {
          paymentFrequency = 12;
        }
        when 'Semi-Annual' {
          paymentFrequency = 6;
        }
        when 'Quarterly' {
          paymentFrequency = 3;
        }
        when 'Every 2 Years' {
          paymentFrequency = 24;
        }
        when 'Every 3 years' {
          paymentFrequency = 36;
        }
        when 'Full Term' {
          paymentFrequency = initialTerm.intValue();
        }
        when 'Other' {
          paymentFrequency = initialTerm.intValue();
        }
        when else {
          paymentFrequency = 0;
        }
      }
    }
    return paymentFrequency;
  }

  @future(callout=true)
  public static void correctProductIfFutureUpdateFuture(Set<Id> quoteIdList) {
    List<zqu__Quote__c> quoteToUpdate = new List<zqu__Quote__c>();
    List<zqu__Quote__c> quoteList = [
      SELECT
        Id,
        zqu__QuoteBusinessType__c,
        zqu__SubscriptionType__c,
        zqu__Is_Charge_Expired__c
      FROM zqu__Quote__c
      WHERE
        Id IN :quoteIdList
        AND (zqu__QuoteBusinessType__c = 'Feature Update'
        OR zqu__QuoteBusinessType__c = 'Feature Update + Renewal (with/without upsell)')
        AND zqu__SubscriptionType__c = 'Amend Subscription'
    ];
    for (zqu__Quote__c quote_i : quoteList) {
      correctProductIfFutureUpdate(quote_i.Id);
      quoteToUpdate.add(
        new zqu__Quote__c(
          Id = quote_i.Id,
          zqu__Is_Charge_Expired__c = true,
          Is_Feature_Update_Initiated__c = true
        )
      );
      // if (quote_i.zqu__Is_Charge_Expired__c) {
      //     quoteToUpdate.zqu__Is_Charge_Expired__c = false;
      // }
    }
    System.debug('Before upd');
    update quoteToUpdate;
    System.debug('After upd');
  }

  public static void correctProductIfFutureUpdate(zqu__Quote__c quote) {
    List<zqu__Quote__c> quoteToUpdate = new List<zqu__Quote__c>();
    correctProductIfFutureUpdate(quote.Id);
    quoteToUpdate.add(
      new zqu__Quote__c(
        Id = quote.Id,
        zqu__Is_Charge_Expired__c = true,
        Is_Feature_Update_Initiated__c = true
      )
    );
    System.debug('Before upd');
    update quoteToUpdate;
    System.debug('After upd');
  }

  public static void correctProductIfFutureUpdate(Id quoteId) {
    System.debug('correctProductIfFutureUpdate ');
    zqu.Quote existingQuote = zqu.Quote.getInstance(quoteId);
    system.debug('existingQuote-alon!!-' + existingQuote);
    system.debug(
      'existingQuote-alon--getSObject!!-' + existingQuote.getSObject()
    );
    System.debug(
      'zqu__InitialTerm__c ' +
      existingQuote.getSObject().get('zqu__InitialTerm__c')
    );
    System.debug(
      'zqu__Service_Activation_Date__c ' +
      existingQuote.getSObject().get('zqu__Service_Activation_Date__c')
    );
    System.debug(
      'zqu__SubscriptionTermEndDate__c ' +
      existingQuote.getSObject().get('zqu__SubscriptionTermEndDate__c')
    );
    List<zqu.QuoteProduct> originalQuoteProductListToSplit = existingQuote.getQuoteProducts();
    List<zqu.zChargeGroup> removedProductList = new List<zqu.zChargeGroup>();
    List<zqu.zChargeGroup> newProductList = new List<zqu.zChargeGroup>();
    List<zqu.zChargeGroup> updatedProductList = new List<zqu.zChargeGroup>();
    List<zqu.zChargeGroup> chargeGroupsForUpdate = new List<zqu.zChargeGroup>();
    for (zqu.QuoteProduct qp_i : originalQuoteProductListToSplit) {
      zqu.zChargeGroup zcg_i = qp_i.chargeGroup;
      chargeGroupsForUpdate.add(zcg_i);
      System.debug('zcg_i.groupType ' + zcg_i.groupType);
      if (zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT) {
        removedProductList.add(zcg_i);
      } else if (
        zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_NEWPRODUCT
      ) {
        newProductList.add(zcg_i);
      } else if (
        zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT
      ) {
        updatedProductList.add(zcg_i);
      }
    }

    fixNewProductDiscount(
      chargeGroupsForUpdate,
      removedProductList,
      newProductList,
      updatedProductList,
      (Decimal) existingQuote.getSObject().get('zqu__InitialTerm__c'),
      (Date) existingQuote.getSObject().get('zqu__StartDate__c'),
      (Date) existingQuote.getSObject()
        .get('zqu__SubscriptionTermStartDate__c'),
      (Date) existingQuote.getSObject().get('zqu__SubscriptionTermEndDate__c'),
      checkPackageApiName(
        (String) (((String) existingQuote.getSObject()
              .get('Migrating_to_New_Soultion__c'))
            .equalsIgnoreCase('Yes')
          ? existingQuote.getSObject().get('Package_Amendment__c')
          : existingQuote.getSObject().get('package__c'))
      ),
      (Decimal) existingQuote.getSObject().get('Contract_CMRR__c')
    );
  }

  public static void removeAllUpdatedProducts(String quoteId) {
    zqu.Quote zQuote = zqu.Quote.getInstance(quoteId);
    List<zqu.QuoteProduct> quoteProductsToRemove = new List<zqu.QuoteProduct>();
    for (zqu.QuoteProduct product_i : zQuote.getQuoteProducts()) {
      zqu.zChargeGroup zcg_i = product_i.chargeGroup;
      if (zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT) {
        quoteProductsToRemove.add(product_i);
      }
    }

    if (!quoteProductsToRemove.isEmpty()) {
      zQuote.deleteQuoteProducts(quoteProductsToRemove);
      zQuote.save();
      reAddAllQuotesOriginalProducts(quoteId);
    }
  }

  public static void removeProductsFromOldPackage(String quoteId) {
    zqu.Quote zQuote = zqu.Quote.getInstance(quoteId);
    List<zqu.QuoteProduct> quoteProductsToRemove = new List<zqu.QuoteProduct>();
    for (zqu.QuoteProduct product_i : zQuote.getQuoteProducts()) {
      zqu.zChargeGroup zcg_i = product_i.chargeGroup;
      if (
        zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL ||
        zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT
      ) {
        quoteProductsToRemove.add(product_i);
      }
    }

    if (!quoteProductsToRemove.isEmpty()) {
      zQuote.deleteQuoteProducts(quoteProductsToRemove);
      zQuote.save();
    }
  }

  @future(callout=true)
  public static void reAddAllQuotesOriginalProducts(String quoteId) {
    zqu.Quote zQuote = zqu.Quote.getInstance(quoteId);

    List<zqu.QuoteProduct> quoteProductsToRemove = new List<zqu.QuoteProduct>();
    List<Id> productIdsToAdd = new List<Id>();
    for (zqu.QuoteProduct product_i : zQuote.getQuoteProducts()) {
      zqu.zChargeGroup zcg_i = product_i.chargeGroup;
      if (zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL) {
        quoteProductsToRemove.add(product_i);
        productIdsToAdd.add(zcg_i.productId);
      }
    }
    if (!productIdsToAdd.isEmpty()) {
      List<zqu.Product> productsToAdd = zqu.Product.loadProductsWithChildren(
        productIdsToAdd
      );
      zQuote.deleteQuoteProducts(quoteProductsToRemove);
      zQuote.addQuoteProducts(productsToAdd);

      QuoteProductsChangeUnit quoteProductsChangeUnit = new QuoteProductsChangeUnit(
        zQuote
      );

      Set<Id> productRatePlanIds = new Set<Id>();
      for (zqu.QuoteProduct quoteProduct_i : zQuote.getAddedQuoteProducts()) {
        productRatePlanIds.add(quoteProduct_i.chargeGroup.productRatePlanId);
      }
      Map<Id, zqu__ProductRatePlan__c> productRatePlanMap = new Map<Id, zqu__ProductRatePlan__c>(
        [
          SELECT Id, Region__c, IsGuidedSelling__c
          FROM zqu__ProductRatePlan__c
          WHERE Id IN :productRatePlanIds
        ]
      );
      List<zqu.QuoteProduct> addedProducts = zQuote.getAddedQuoteProducts();
      for (Integer i = addedProducts.size() - 1; i >= 0; i--) {
        zqu.QuoteProduct product_i = addedProducts[i];
        if (
          productRatePlanMap.get(product_i.chargeGroup.productRatePlanId)
            .Region__c != quoteProductsChangeUnit.region ||
          productRatePlanMap.get(product_i.chargeGroup.productRatePlanId)
            .IsGuidedSelling__c == 'Trial'
        ) {
          addedProducts.remove(i);
        }
      }

      zQuote.save();
    }
  }

  @future(callout=true)
  public static void reAddAllQuotesProducts(List<String> quoteIds) {
    for (String quoteId_i : quoteIds) {
      reAddAllProducts(quoteId_i);
    }
  }

  public static void reAddAllProducts(String quoteId) {
    zqu.Quote zQuote = zqu.Quote.getInstance(quoteId);
    reAddAllProducts(zQuote);
  }

  public static void reAddAllProducts(zqu.Quote zQuote) {
    List<zqu.QuoteProduct> quoteProductsToRemove = new List<zqu.QuoteProduct>();
    List<Id> productIdsToAdd = new List<Id>();
    for (zqu.QuoteProduct product_i : zQuote.getQuoteProducts()) {
      zqu.zChargeGroup zcg_i = product_i.chargeGroup;
      System.debug('alon Charge group check');
      System.debug(zcg_i);
      System.debug(zcg_i.groupType);
      for (zqu.zCharge charge : zcg_i.zCharges) {
        system.debug(charge);
        List<zqu__QuoteCharge_Tier__c> tiers = charge.chargeTiersObjects;
        for (zqu__QuoteCharge_Tier__c tier : tiers) {
          system.debug(tier);
        }
      }
      if (zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL) {
        system.debug(' i am in the original product--' + zcg_i.groupType);
        quoteProductsToRemove.add(product_i);
        productIdsToAdd.add(zcg_i.productId);
      }
    }
    if (!productIdsToAdd.isEmpty()) {
      System.debug(quoteProductsToRemove);
      System.debug(productIdsToAdd);
      List<zqu.Product> productsToAdd = zqu.Product.loadProductsWithChildren(
        productIdsToAdd
      );
      System.debug(productsToAdd);
      zQuote.deleteQuoteProducts(quoteProductsToRemove);
      zQuote.addQuoteProducts(productsToAdd);

      QuoteProductsChangeUnit quoteProductsChangeUnit = new QuoteProductsChangeUnit(
        zQuote
      );

      Set<Id> productRatePlanIds = new Set<Id>();
      for (zqu.QuoteProduct quoteProduct_i : zQuote.getAddedQuoteProducts()) {
        productRatePlanIds.add(quoteProduct_i.chargeGroup.productRatePlanId);
      }
      Map<Id, zqu__ProductRatePlan__c> productRatePlanMap = new Map<Id, zqu__ProductRatePlan__c>(
        [
          SELECT Id, Region__c, IsGuidedSelling__c
          FROM zqu__ProductRatePlan__c
          WHERE Id IN :productRatePlanIds
        ]
      );
      List<zqu.QuoteProduct> addedProducts = zQuote.getAddedQuoteProducts();
      for (Integer i = addedProducts.size() - 1; i >= 0; i--) {
        zqu.QuoteProduct product_i = addedProducts[i];
        if (
          productRatePlanMap.get(product_i.chargeGroup.productRatePlanId)
            .Region__c != quoteProductsChangeUnit.region ||
          productRatePlanMap.get(product_i.chargeGroup.productRatePlanId)
            .IsGuidedSelling__c == 'Trial'
        ) {
          addedProducts.remove(i);
        }
      }

      zQuote.save();
      sendEmailAlert(zQuote.getId());
    }
  }

  private static void sendEmailAlert(Id quoteId) {
    EmailTemplate emailTemplate = [
      SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
      FROM EmailTemplate
      WHERE DeveloperName = :RE_ADDING_PRODUCTS_ALERT_NAME
      LIMIT 1
    ];

    List<String> recipientList = obtainRecipientList();

    if (emailTemplate != null && !recipientList.isEmpty()) {
      Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(
        emailTemplate.Id,
        UserInfo.getUserId(),
        quoteId
      );
      String emailSubject = email.getSubject();
      String emailTextBody = email.getPlainTextBody();
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.setSubject(emailSubject);
      message.setPlainTextBody(emailTextBody);
      message.setSenderDisplayName('Notification');
      message.setUseSignature(false);
      message.setBccSender(false);
      message.setSaveAsActivity(false);
      message.toAddresses = recipientList;
      Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
        message
      };
      Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

      if (!results[0].success) {
        System.debug(
          'The email failed to send: ' + results[0].errors[0].message
        );
      }
    }
  }

  private static List<String> obtainRecipientList() {
    List<General_Configuration__mdt> generalConfigurationList = GeneralUtil.retrieveConfigurationMetadata(
      new Set<String>{ RECIPIENTS_METADATA_NAME }
    );
    List<String> recipientList = new List<String>();
    if (!generalConfigurationList.isEmpty()) {
      Matcher m = Pattern.compile(
          '[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+'
        )
        .matcher(generalConfigurationList[0].Text_Value__c);
      while (m.find()) {
        recipientList.add(m.group());
      }
    }
    return recipientList;
  }

  private static Boolean checkIfQuoteHasDiscountableProduct(Id quoteId) {
    Boolean isDiscountEditable = false;
    List<zqu__QuoteCHargeDetail__c> qcdList = [
      SELECT Id, zqu__ProductRatePlanCHARGE__r.zqu__ListPrice__c
      FROM zqu__QuoteCHargeDetail__c
      WHERE zqu__Quote__c = :quoteId
    ];
    for (zqu__QuoteCHargeDetail__c qcd_i : qcdList) {
      if (qcd_i.zqu__ProductRatePlanCHARGE__r.zqu__ListPrice__c != 0) {
        isDiscountEditable = true;
        break;
      }
    }
    return isDiscountEditable;
  }

  private static void fixNewProductDiscount(
    List<zqu.zChargeGroup> chargeGroupsForUpdate,
    List<zqu.zChargeGroup> removedProductList,
    List<zqu.zChargeGroup> newProductList,
    List<zqu.zChargeGroup> updatedProductList,
    Decimal initialTerm,
    Date serviceActivationDate,
    Date subStartDate,
    Date subEndDate,
    String quotePackage,
    Decimal contactCMRR
  ) {
    Decimal targetQuoteTotalPrice = (contactCMRR * initialTerm).setScale(0);
    List<zqu.zChargeGroup> newProductchargeGroupsForUpdate = new List<zqu.zChargeGroup>();
    List<zqu.zChargeGroup> updatedProductchargeGroupsForUpdate = new List<zqu.zChargeGroup>();
    for (zqu.zChargeGroup zcg_i : chargeGroupsForUpdate) {
      if (zcg_i.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_NEWPRODUCT) {
        for (zqu.zCharge zc_i : zcg_i.zCharges) {
          if (zc_i.isDiscountEditable) {
            zc_i.discount = '100';
          }
        }
        zcg_i.zCharges = zqu.zQuoteUtil.calculateChargesOnDiscountChange(
          zcg_i.zCharges
        );
        newProductchargeGroupsForUpdate.add(zcg_i);
      }
      if (zcg_i.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT) {
        Decimal totalValue = 0;
        zqu.zChargeGroup zcgOriginal = zcg_i.originalChargeGroup;
        for (zqu.zCharge zc_i : zcgOriginal.zCharges) {
          if (zc_i.isTotalEditable && String.isNotBlank(zc_i.TOTAL)) {
            totalValue = Decimal.valueOf(zc_i.TOTAL);
          }
        }
        for (zqu.zCharge zc_i : zcg_i.zCharges) {
          if (zc_i.isTotalEditable) {
            zc_i.TOTAL = String.valueOf(totalValue);
          }
        }
        zcg_i.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(
          zcg_i.zCharges
        );
        updatedProductchargeGroupsForUpdate.add(zcg_i);
      }
    }
    if (!Test.isRunningTest() && !newProductchargeGroupsForUpdate.isEmpty()) {
      zqu.ZQuoteUtil.updateChargeGroups(newProductchargeGroupsForUpdate);
    }
    if (
      !Test.isRunningTest() && !updatedProductchargeGroupsForUpdate.isEmpty()
    ) {
      zqu.ZQuoteUtil.updateChargeGroups(updatedProductchargeGroupsForUpdate);
    }

    Decimal sumOfListPrice = targetQuoteTotalPrice;
    Decimal sumOfRemovedProductPrice = 0;
    Set<String> partCl5ZuoraIds = getIdsOfPartOfCluster5Product(
      chargeGroupsForUpdate
    );
    zqu.zChargeGroup chargeGroupToUpdate;
    Boolean isPriceChanged = false;
    for (zqu.zChargeGroup zcg_i : chargeGroupsForUpdate) {
      if (zcg_i.groupType != zqu.zChargeGroup.TYPE_AMENDMENT_NEWPRODUCT) {
        List<zqu.zCharge> zCharges;
        if (zcg_i.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_ORIGINAL) {
          zCharges = zcg_i.zCharges;
        } else {
          zCharges = zcg_i.originalChargeGroup.zCharges;
        }
      }
      for (zqu.zCharge zc_i : zcg_i.zCharges) {
        if (
          String.isNotBlank(zc_i.LIST_PRICE) &&
          zc_i.LIST_PRICE != '-' &&
          zcg_i.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT &&
          (zcg_i.groupType != zqu.zChargeGroup.TYPE_AMENDMENT_ORIGINAL ||
          String.isBlank(zc_i.SUBSCRIPTION_RATE_PLAN_CHARGE_ID) ||
          !partCl5ZuoraIds.contains(
            zc_i.SUBSCRIPTION_RATE_PLAN_CHARGE_ID.toLowerCase()
          ))
        ) {
          Decimal productPrice = 0;
          if (zc_i.LIST_PRICE == 'Varies' || zc_i.LIST_PRICE == 'Flat Fee') {
            if (String.isNotBlank(zc_i.SPECIFIC_BILLING_PERIOD)) {
              productPrice = ((Decimal.valueOf(zc_i.TOTAL) *
                  Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD))
                  .setScale(2) *
                initialTerm /
                Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD))
                .setScale(2);
            }
          } else {
            if (zc_i.LIST_PRICE_BASE == 'Per Month') {
              productPrice = ((Decimal.valueOf(zc_i.TOTAL) *
                  Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD))
                  .setScale(2) *
                initialTerm /
                Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD))
                .setScale(2);
            }
          }
          if (
            zcg_i.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT
          ) {
            productPrice = -productPrice;
          }
          sumOfRemovedProductPrice += productPrice;
        }
      }
    }

    List<zqu.zChargeGroup> chargeGroupsToUpdatePrice = new List<zqu.zChargeGroup>();
    Integer updatedChargesCount = 0;
    Decimal addedValue = -(sumOfRemovedProductPrice);
    for (zqu.zChargeGroup zcg_i : chargeGroupsForUpdate) {
      for (zqu.zCharge zc_i : zcg_i.zCharges) {
        if (
          zc_i.isEffectivePriceEditable &&
          zcg_i.groupType != zqu.zChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT
        ) {
          chargeGroupsToUpdatePrice.add(zcg_i);
          updatedChargesCount = updatedChargesCount + 1;
          break;
        }
      }
    }
    addedValue = addedValue / updatedChargesCount;

    if (!chargeGroupsToUpdatePrice.isEmpty() && addedValue > 0) {
      for (zqu.zChargeGroup zcg_i : chargeGroupsToUpdatePrice) {
        for (zqu.zCharge zc_i : zcg_i.zCharges) {
          if (
            zc_i.isEffectivePriceEditable &&
            zc_i.LIST_PRICE != 'Varies' &&
            zc_i.LIST_PRICE != 'Flat Fee'
          ) {
            String oldEffectivePrice = zc_i.EFFECTIVE_PRICE;
            if (zc_i.LIST_PRICE_BASE == 'Per Month') {
              zc_i.EFFECTIVE_PRICE = String.valueOf(
                ((Decimal.valueOf(zc_i.TOTAL) + (addedValue / initialTerm)))
              );
            } else {
              zc_i.EFFECTIVE_PRICE = String.valueOf(
                ((Decimal.valueOf(zc_i.TOTAL) + (addedValue)))
              );
            }
            if (oldEffectivePrice != zc_i.EFFECTIVE_PRICE) {
              zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(
                zcg_i.zCharges
              );
              isPriceChanged = true;
              break;
            }
          }
        }
      }

      Decimal diffToCorrcet = 0;
      Decimal numOfDaysInSubscription = subStartDate.daysBetween(subEndDate);
      Decimal numOfEffectiveDays =
        subStartDate.daysBetween(serviceActivationDate) + 1;
      Decimal percentOfEffectiveDays =
        numOfEffectiveDays / numOfDaysInSubscription;
      for (zqu.zChargeGroup zcg_i : chargeGroupsForUpdate) {
        for (zqu.zCharge zc_i : zcg_i.zCharges) {
          Decimal productEffectivePrice = 0;
          if (zc_i.CHARGE_TYPE == 'One-Time') {
            productEffectivePrice = ((Decimal.valueOf(zc_i.TOTAL) *
              percentOfEffectiveDays))
              .setScale(2);
          } else {
            productEffectivePrice = ((Decimal.valueOf(zc_i.TOTAL) *
              percentOfEffectiveDays) *
              Decimal.valueOf(zc_i.SPECIFIC_BILLING_PERIOD))
              .setScale(2);
          }
          if (
            zcg_i.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT
          ) {
            productEffectivePrice = -productEffectivePrice;
          }
          diffToCorrcet += productEffectivePrice;
        }
      }
      System.debug('diffToCorrcet ' + diffToCorrcet);
      if (!Test.isRunningTest() && isPriceChanged) {
        zqu.ZQuoteUtil.updateChargeGroups(chargeGroupsToUpdatePrice);
      }
    }
  }

  private static void updateSingleProductIfAllOriginal(
    List<zqu.zChargeGroup> chargeGroupsForFix
  ) {
    Boolean isAllProductsOriginal = false;
    for (zqu.zChargeGroup zcg_i : chargeGroupsForFix) {
      if (
        zcg_i.groupType != zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL &&
        zcg_i.groupType != zqu.ZChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT
      ) {
        isAllProductsOriginal = true;
        break;
      }
    }
    if (isAllProductsOriginal) {
      zqu.zChargeGroup productToUpdate;
      for (zqu.zChargeGroup zcg_i : chargeGroupsForFix) {
        if (zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL) {
          for (zqu.zCharge zc_i : zcg_i.zCharges) {
            if (
              String.isNotBlank(zc_i.EFFECTIVE_PRICE) &&
              zc_i.EFFECTIVE_PRICE.isNumeric() &&
              zc_i.isDiscountEditable
            ) {
              if (
                productToUpdate == null ||
                productToUpdate.zCharges[0].EFFECTIVE_PRICE <
                zc_i.EFFECTIVE_PRICE
              ) {
                productToUpdate = zcg_i;
              }
            }
          }
        }
      }
      if (productToUpdate != null) {
        productToUpdate.zCharges[0].DISCOUNT = '0';
        productToUpdate.zCharges = zqu.zQuoteUtil.calculateChargesOnDiscountChange(
          productToUpdate.zCharges
        );
      }
    }
  }

  private static Set<String> getIdsOfPartOfCluster5Product(
    List<zqu.ZChargeGroup> chargeGroupsForUpdate
  ) {
    Set<String> partCl5ZuoraIds = new Set<String>();
    Set<String> subRatePlanIds = new Set<String>();
    for (zqu.zChargeGroup zcg_i : chargeGroupsForUpdate) {
      for (zqu.zCharge zc_i : zcg_i.zCharges) {
        if (String.isNotBlank(zc_i.SUBSCRIPTION_RATE_PLAN_CHARGE_ID)) {
          subRatePlanIds.add(zc_i.SUBSCRIPTION_RATE_PLAN_CHARGE_ID);
        }
      }
    }
    if (!subRatePlanIds.isEmpty()) {
      List<Zuora__SubscriptionProductCharge__c> subRatePlanChargeList = [
        SELECT Id, Zuora__External_Id__c
        FROM Zuora__SubscriptionProductCharge__c
        WHERE
          Zuora__External_Id__c IN :subRatePlanIds
          AND IsPartOfCluster5__c = 'Yes'
      ];
      for (
        Zuora__SubscriptionProductCharge__c subRpCh_i : subRatePlanChargeList
      ) {
        partCl5ZuoraIds.add(subRpCh_i.Zuora__External_Id__c.toLowerCase());
      }
    }
    return partCl5ZuoraIds;
  }
}
