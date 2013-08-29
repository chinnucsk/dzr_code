-module(data_yun_biao).

-compile(export_all).



%% 根据吉星等级获取其升到下一级需要的运势点
get_up_need_yunshipoint(1) -> {1,1.1};

get_up_need_yunshipoint(2) -> {3,1.2};

get_up_need_yunshipoint(3) -> {6,1.3};

get_up_need_yunshipoint(4) -> {10,1.4};

get_up_need_yunshipoint(5) -> {15,1.5};

get_up_need_yunshipoint(6) -> {25,1.6};

get_up_need_yunshipoint(7) -> {40,1.7};

get_up_need_yunshipoint(8) -> {60,1.8};

get_up_need_yunshipoint(9) -> {80,1.9};

get_up_need_yunshipoint(10) -> {100,2}.


%%================================================
%% 根据玩家等级获取其镖车数据:{{白车银币,白车军功},{绿车银币,绿车军功},{蓝车银币,蓝车军功},{紫车银币,紫车军功},{橙车银币,橙车军功}}
get_biaoche_data(1) -> [{8951,5},{13427,8},{19395,10},{26854,15},{44757,25}];

get_biaoche_data(2) -> [{9015,5},{13522,8},{19532,10},{27044,15},{45073,25}];

get_biaoche_data(3) -> [{9078,5},{13617,8},{19669,10},{27234,15},{45390,25}];

get_biaoche_data(4) -> [{9142,5},{13713,8},{19808,10},{27426,15},{45710,25}];

get_biaoche_data(5) -> [{9207,5},{13810,8},{19947,10},{27620,15},{46033,25}];

get_biaoche_data(6) -> [{9271,5},{13907,8},{20088,10},{27814,15},{46357,25}];

get_biaoche_data(7) -> [{9337,5},{14005,8},{20230,10},{28010,15},{46684,25}];

get_biaoche_data(8) -> [{9403,5},{14104,8},{20372,10},{28208,15},{47013,25}];

get_biaoche_data(9) -> [{9469,5},{14203,8},{20516,10},{28407,15},{47344,25}];

get_biaoche_data(10) -> [{9536,5},{14303,8},{20661,10},{28607,15},{47678,25}];

get_biaoche_data(11) -> [{9603,5},{14404,8},{20806,10},{28809,15},{48014,25}];

get_biaoche_data(12) -> [{9671,5},{14506,8},{20953,10},{29012,15},{48353,25}];

get_biaoche_data(13) -> [{9739,5},{14608,8},{21101,10},{29216,15},{48694,25}];

get_biaoche_data(14) -> [{9807,5},{14711,8},{21249,10},{29422,15},{49037,25}];

get_biaoche_data(15) -> [{9877,5},{14815,8},{21399,10},{29630,15},{49383,25}];

get_biaoche_data(16) -> [{9946,5},{14919,8},{21550,10},{29838,15},{49731,25}];

get_biaoche_data(17) -> [{10016,5},{15024,8},{21702,10},{30049,15},{50081,25}];

get_biaoche_data(18) -> [{10087,5},{15130,8},{21855,10},{30261,15},{50434,25}];

get_biaoche_data(19) -> [{10158,5},{15237,8},{22009,10},{30474,15},{50790,25}];

get_biaoche_data(20) -> [{10230,5},{15344,8},{22164,10},{30689,15},{51148,25}];

get_biaoche_data(21) -> [{10302,5},{15453,8},{22320,10},{30905,15},{51508,25}];

get_biaoche_data(22) -> [{10374,5},{15561,8},{22478,10},{31123,15},{51872,25}];

get_biaoche_data(23) -> [{10447,5},{15671,8},{22636,10},{31342,15},{52237,25}];

get_biaoche_data(24) -> [{10521,5},{15782,8},{22796,10},{31563,15},{52605,25}];

get_biaoche_data(25) -> [{10595,5},{15893,8},{22956,10},{31786,15},{52976,25}];

get_biaoche_data(26) -> [{10670,5},{16005,8},{23118,10},{32010,15},{53350,25}];

get_biaoche_data(27) -> [{10745,5},{16118,8},{23281,10},{32235,15},{53726,25}];

get_biaoche_data(28) -> [{10821,5},{16231,8},{23445,10},{32463,15},{54105,25}];

get_biaoche_data(29) -> [{10897,5},{16346,8},{23611,10},{32692,15},{54486,25}];

get_biaoche_data(30) -> [{10974,5},{16461,8},{23777,10},{32922,15},{54870,25}];

get_biaoche_data(31) -> [{11051,5},{16577,8},{23945,10},{33154,15},{55257,25}];

get_biaoche_data(32) -> [{11129,6},{16694,9},{24113,12},{33388,18},{55646,30}];

get_biaoche_data(33) -> [{11208,6},{16812,9},{24283,12},{33623,18},{56039,30}];

get_biaoche_data(34) -> [{11287,7},{16930,11},{24455,14},{33860,21},{56434,35}];

get_biaoche_data(35) -> [{11366,7},{17049,11},{24627,14},{34099,21},{56831,35}];

get_biaoche_data(36) -> [{11446,8},{17170,12},{24801,16},{34339,24},{57232,40}];

get_biaoche_data(37) -> [{11527,8},{17291,12},{24975,16},{34581,24},{57636,40}];

get_biaoche_data(38) -> [{11608,9},{17413,14},{25151,18},{34825,27},{58042,45}];

get_biaoche_data(39) -> [{11690,9},{17535,14},{25329,18},{35071,27},{58451,45}];

get_biaoche_data(40) -> [{11773,10},{17659,15},{25507,20},{35318,30},{58863,50}];

get_biaoche_data(41) -> [{11856,10},{17783,15},{25687,20},{35567,30},{59278,50}];

get_biaoche_data(42) -> [{11939,11},{17909,17},{25868,22},{35817,33},{59696,55}];

get_biaoche_data(43) -> [{12023,11},{18035,17},{26051,22},{36070,33},{60117,55}];

get_biaoche_data(44) -> [{12108,12},{18162,18},{26234,24},{36324,36},{60540,60}];

get_biaoche_data(45) -> [{12193,12},{18290,18},{26419,24},{36580,36},{60967,60}];

get_biaoche_data(46) -> [{12279,13},{18419,20},{26605,26},{36838,39},{61397,65}];

get_biaoche_data(47) -> [{12366,13},{18549,20},{26793,26},{37098,39},{61830,65}];

get_biaoche_data(48) -> [{12453,14},{18680,21},{26982,28},{37359,42},{62266,70}];

get_biaoche_data(49) -> [{12541,14},{18811,21},{27172,28},{37623,42},{62705,70}];

get_biaoche_data(50) -> [{12629,16},{18944,24},{27364,31},{37888,47},{63147,78}];

get_biaoche_data(51) -> [{12718,16},{19078,24},{27556,31},{38155,47},{63592,78}];

get_biaoche_data(52) -> [{12808,19},{19212,28},{27751,37},{38424,56},{64040,93}];

get_biaoche_data(53) -> [{12898,19},{19347,28},{27946,37},{38695,56},{64491,93}];

get_biaoche_data(54) -> [{12989,22},{19484,33},{28143,43},{38968,65},{64946,108}];

get_biaoche_data(55) -> [{13081,22},{19621,33},{28342,43},{39242,65},{65404,108}];

get_biaoche_data(56) -> [{13173,25},{19759,37},{28541,49},{39519,74},{65865,123}];

get_biaoche_data(57) -> [{13266,25},{19899,37},{28743,49},{39798,74},{66329,123}];

get_biaoche_data(58) -> [{13359,28},{20039,42},{28945,55},{40078,83},{66797,138}];

get_biaoche_data(59) -> [{13454,28},{20180,42},{29149,55},{40361,83},{67268,138}];

get_biaoche_data(60) -> [{13548,31},{20323,46},{29355,61},{40645,92},{67742,153}];

get_biaoche_data(61) -> [{13644,31},{20466,46},{29562,61},{40932,92},{68219,153}];

get_biaoche_data(62) -> [{13922,34},{20884,51},{30165,67},{41767,101},{69612,168}];

get_biaoche_data(63) -> [{14206,34},{21310,51},{30781,67},{42619,101},{71032,168}];

get_biaoche_data(64) -> [{14496,37},{21745,55},{31409,73},{43489,110},{72482,183}];

get_biaoche_data(65) -> [{14792,37},{22188,55},{32050,73},{44377,110},{73961,183}];

get_biaoche_data(66) -> [{15094,40},{22641,60},{32704,79},{45282,119},{75471,198}];

get_biaoche_data(67) -> [{15402,40},{23103,60},{33371,79},{46206,119},{77011,198}];

get_biaoche_data(68) -> [{15716,43},{23575,64},{34052,85},{47149,128},{78582,213}];

get_biaoche_data(69) -> [{16037,43},{24056,64},{34747,85},{48112,128},{80186,213}];

get_biaoche_data(70) -> [{16365,45},{24547,67},{35456,89},{49094,134},{81823,223}];

get_biaoche_data(71) -> [{16698,45},{25048,67},{36180,89},{50095,134},{83492,223}];

get_biaoche_data(72) -> [{17039,47},{25559,70},{36918,93},{51118,140},{85196,233}];

get_biaoche_data(73) -> [{17387,47},{26081,70},{37672,93},{52161,140},{86935,233}];

get_biaoche_data(74) -> [{17742,49},{26613,73},{38441,97},{53226,146},{88709,243}];

get_biaoche_data(75) -> [{18104,49},{27156,73},{39225,97},{54312,146},{90520,243}];

get_biaoche_data(76) -> [{18473,51},{27710,76},{40026,101},{55420,152},{92367,253}];

get_biaoche_data(77) -> [{18850,51},{28276,76},{40843,101},{56551,152},{94252,253}];

get_biaoche_data(78) -> [{19235,53},{28853,79},{41676,105},{57705,158},{96176,263}];

get_biaoche_data(79) -> [{19628,53},{29442,79},{42527,105},{58883,158},{98138,263}];

get_biaoche_data(80) -> [{20028,55},{30042,82},{43395,109},{60085,164},{100141,273}];

get_biaoche_data(81) -> [{20437,55},{30655,82},{44280,109},{61311,164},{102185,273}];

get_biaoche_data(82) -> [{20854,57},{31281,85},{45184,113},{62562,170},{104270,283}];

get_biaoche_data(83) -> [{21280,57},{31919,85},{46106,113},{63839,170},{106398,283}];

get_biaoche_data(84) -> [{21714,59},{32571,88},{47047,117},{65142,176},{108570,293}];

get_biaoche_data(85) -> [{22157,59},{33236,88},{48007,117},{66471,176},{110785,293}];

get_biaoche_data(86) -> [{22609,61},{33914,91},{48987,121},{67828,182},{113046,303}];

get_biaoche_data(87) -> [{23071,61},{34606,91},{49986,121},{69212,182},{115353,303}];

get_biaoche_data(88) -> [{23542,63},{35312,94},{51007,125},{70625,188},{117708,313}];

get_biaoche_data(89) -> [{24022,63},{36033,94},{52048,125},{72066,188},{120110,313}];

get_biaoche_data(90) -> [{24512,65},{36768,97},{53110,129},{73537,194},{122561,323}];

get_biaoche_data(91) -> [{25012,65},{37519,97},{54194,129},{75037,194},{125062,323}];

get_biaoche_data(92) -> [{25523,67},{38284,100},{55300,133},{76569,200},{127614,333}];

get_biaoche_data(93) -> [{26044,67},{39066,100},{56428,133},{78131,200},{130219,333}];

get_biaoche_data(94) -> [{26575,69},{39863,103},{57580,137},{79726,206},{132876,343}];

get_biaoche_data(95) -> [{27118,69},{40676,103},{58755,137},{81353,206},{135588,343}];

get_biaoche_data(96) -> [{27671,71},{41507,106},{59954,141},{83013,212},{138355,353}];

get_biaoche_data(97) -> [{28236,71},{42354,106},{61177,141},{84707,212},{141179,353}];

get_biaoche_data(98) -> [{28812,73},{43218,109},{62426,145},{86436,218},{144060,363}];

get_biaoche_data(99) -> [{29400,73},{44100,109},{63700,145},{88200,218},{147000,363}];

get_biaoche_data(100) -> [{30000,75},{45000,112},{65000,149},{90000,224},{150000,373}].


%%================================================
%% 根据玩家当前镖车品质刷新镖车:
get_refresh_probility(1) -> 60;

get_refresh_probility(2) -> 60;

get_refresh_probility(3) -> 60;

get_refresh_probility(4) -> 50.


%%================================================
%% 获取转运需要的金币数
get_goldcount_cost(Num)->%%转运需要的金币
Goldcount = 200*(Num+1),
Goldcount.

%%================================================
%% 获取最高镖车类型
get_the_high_biaoche_type()-> 5.

%%================================================
%% 获取发奖时间
get_send_award_time()-> {24,0,0}.

%%================================================