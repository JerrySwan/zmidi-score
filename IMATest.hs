module Main where

import LocalMeter
import InnerMetricalAnalysis
import InnerMetricalAnalysisOld

import Data.IntMap                ( IntMap )
import qualified Data.IntMap as M ( fromList, map )
import Control.Arrow              ( first )
import Debug.Trace

-- testing
main :: IO ()
-- 1000
-- main = print $ getMetricWeight 1 [6,13,16,17,20,26,28,36,44,49,50,56,57,61,64,66,68,73,75,76,83,85,88,91,93,95,99,105,107,110,116,119,124,129,136,137,145,147,151,158,161,166,174,178,184,188,192,200,201,208,213,219,225,230,231,235,238,240,241,242,246,253,259,261,266,267,275,277,281,284,286,290,298,304,311,317,322,325,330,337,340,341,346,352,355,362,370,378,383,389,393,394,399,405,410,416,423,427,435,439,445,450,456,462,469,471,478,481,487,495,501,508,510,515,519,526,532,535,543,550,557,563,566,571,574,576,580,583,589,595,596,599,604,611,619,620,625,627,631,634,640,647,651,659,664,666,669,674,676,679,681,683,690,692,694,695,697,701,702,707,711,716,719,725,732,737,739,740,747,751,755,757,763,767,770,778,784,792,798,806,811,814,818,824,829,830,831,832,839,840,844,852,856,861,862,864,866,871,873,876,877,882,884,892,898,906,908,913,920,924,925,929,931,937,941,946,949,954,962,970,974,978,983,986,989,995,1002,1008,1012,1017,1019,1027,1029,1035,1042,1050,1055,1060,1061,1067,1073,1079,1081,1083,1091,1098,1105,1108,1112,1118,1121,1128,1132,1135,1143,1147,1150,1157,1160,1168,1174,1177,1185,1191,1198,1199,1204,1207,1214,1221,1222,1223,1231,1239,1243,1244,1251,1253,1259,1260,1262,1265,1270,1278,1281,1282,1285,1286,1293,1299,1303,1306,1311,1313,1317,1323,1326,1328,1332,1338,1345,1351,1352,1359,1361,1367,1372,1373,1378,1384,1392,1400,1408,1416,1422,1428,1436,1443,1450,1457,1458,1462,1468,1476,1477,1482,1487,1490,1491,1497,1502,1504,1510,1511,1513,1521,1526,1533,1534,1540,1543,1548,1555,1558,1561,1565,1573,1581,1587,1591,1598,1605,1607,1611,1616,1620,1628,1636,1641,1648,1652,1658,1665,1667,1668,1673,1678,1680,1687,1693,1698,1706,1708,1713,1721,1726,1731,1732,1737,1742,1748,1755,1761,1769,1770,1771,1778,1781,1784,1788,1789,1790,1793,1795,1802,1809,1813,1819,1826,1831,1839,1846,1849,1857,1858,1861,1868,1876,1878,1885,1888,1891,1893,1900,1905,1912,1914,1919,1920,1923,1930,1938,1940,1944,1951,1955,1959,1963,1965,1968,1976,1978,1982,1984,1991,1997,1998,1999,2005,2013,2014,2018,2023,2030,2038,2044,2048,2052,2054,2056,2064,2070,2076,2078,2084,2090,2095,2099,2100,2107,2113,2115,2116,2124,2132,2137,2140,2145,2150,2157,2165,2167,2175,2183,2189,2197,2201,2203,2209,2217,2222,2228,2231,2234,2238,2241,2244,2249,2255,2263,2271,2274,2277,2284,2285,2286,2290,2297,2300,2302,2304,2305,2313,2318,2325,2333,2341,2349,2356,2364,2367,2370,2377,2378,2379,2380,2386,2392,2394,2398,2405,2411,2418,2419,2423,2431,2436,2438,2444,2446,2454,2460,2466,2469,2473,2481,2487,2491,2496,2498,2503,2511,2512,2514,2518,2525,2532,2534,2537,2542,2543,2550,2555,2558,2563,2570,2572,2576,2583,2584,2592,2599,2606,2614,2619,2626,2631,2633,2636,2642,2643,2650,2652,2659,2666,2668,2672,2674,2676,2680,2685,2686,2691,2697,2703,2707,2709,2713,2721,2727,2728,2732,2733,2740,2744,2748,2751,2759,2764,2772,2778,2783,2791,2796,2800,2803,2809,2814,2821,2825,2832,2840,2841,2849,2851,2855,2856,2863,2864,2871,2877,2884,2892,2897,2903,2908,2916,2919,2925,2933,2940,2942,2947,2951,2956,2958,2964,2966,2970,2971,2974,2975,2980,2981,2986,2992,2997,3005,3008,3011,3018,3023,3024,3025,3032,3035,3040,3041,3043,3047,3054,3055,3061,3064,3072,3077,3079,3082,3090,3092,3094,3096,3099,3107,3115,3120,3127,3128,3130,3132,3139,3147,3148,3155,3158,3165,3171,3179,3186,3194,3196,3204,3210,3214,3220,3221,3224,3230,3233,3234,3236,3239,3247,3254,3259,3261,3264,3266,3270,3272,3277,3284,3289,3297,3299,3300,3305,3310,3312,3317,3320,3328,3334,3335,3343,3344,3345,3349,3355,3361,3367,3374,3380,3384,3388,3393,3394,3395,3398,3402,3407,3415,3422,3427,3432,3438,3442,3450,3453,3461,3462,3470,3473,3480,3487,3488,3491,3493,3501,3502,3505,3509,3517,3524,3531,3538,3539,3545,3549,3555,3559,3564,3569,3574,3581,3584,3585,3589,3592,3595,3600,3607,3608,3614,3622,3627,3634,3636,3639,3643,3651,3652,3657,3665,3672,3679,3686,3693,3700,3707,3714,3721,3723,3725,3727,3729,3730,3734,3738,3740,3745,3752,3755,3761,3767,3772,3779,3785,3793,3796,3802,3810,3818,3823,3830,3834,3836,3844,3848,3851,3853,3857,3859,3863,3867,3872,3874,3880,3885,3893,3898,3902,3909,3911,3912,3916,3917,3920,3922,3929,3934,3941,3944,3949,3955,3960,3965,3969,3975,3981,3985,3990,3993,3998,3999,4006,4011,4015,4019,4020,4021,4024,4025,4033,4036,4037,4042,4048,4050,4054,4056,4063,4068,4069,4075,4076,4084,4089,4096,4104,4107,4109,4116,4123,4125,4127,4133,4137,4144,4151,4152,4153,4154,4160,4166,4171,4173,4174,4177,4182,4189,4192,4198,4201,4205,4210,4213,4218,4221,4225,4226,4228,4235,4239,4241,4242,4245,4248,4252,4253,4256,4264,4270,4277,4285,4288,4296,4304,4311,4312,4314,4319,4324,4328,4329,4334,4337,4342,4350,4353,4355,4363,4367,4371,4377,4384,4390,4392,4396,4399,4400,4401,4405,4409,4416,4421,4429,4432,4434,4438,4439,4441,4448,4451,4453,4456,4461,4467,4471,4473,4477,4479,4485,4493,4501,4502,4506,4512,4514,4515,4517,4521,4522,4529,4530,4532,4539,4542,4548,4556]
-- 2000
main = print $ getSpectralWeight 1 [3,4,8,15,19,22,25,31,38,41,47,50,53,56,64,70,71,75,79,86,94,100,107,112,120,125,131,134,135,140,142,144,146,152,160,167,172,177,179,185,187,191,193,196,202,208,211,216,220,224,228,229,231,233,237,239,246,248,250,256,263,271,273,279,282,287,291,297,302,310,316,319,321,323,329,334,338,340,344,349,357,358,361,366,374,379,386,389,393,397,402,410,413,421,429,436,437,442,445,452,453,460,463,466,467,470,471,478,486,490,492,496,504,510,514,520,525,530,537,544,551,554,561,568,573,575,577,579,585,591,595,596,598,602,607,612,613,614,618,623,631,638,646,652,659,661,667,669,673,678,686,688,693,700,703,704,705,712,716,720,725,728,733,740,747,749,751,756,758,764,769,775,778,781,782,788,793,800,806,814,822,830,832,837,843,845,849,854,862,865,871,876,880,888,892,895,898,902,903,906,907,909,914,922,927,928,936,941,944,946,952,957,961,962,970,978,983,988,989,991,995,998,1006,1009,1017,1021,1028,1035,1042,1049,1054,1058,1066,1069,1070,1077,1085,1086,1094,1095,1100,1101,1102,1104,1110,1118,1120,1124,1130,1138,1139,1140,1144,1151,1156,1163,1169,1177,1179,1186,1193,1199,1201,1208,1211,1214,1219,1226,1233,1238,1242,1249,1250,1253,1261,1269,1276,1280,1284,1290,1295,1299,1301,1305,1306,1307,1314,1319,1323,1326,1327,1334,1337,1345,1349,1355,1363,1366,1373,1377,1384,1392,1394,1398,1402,1404,1409,1416,1419,1426,1433,1437,1441,1443,1451,1452,1456,1462,1466,1472,1476,1482,1483,1485,1486,1493,1499,1507,1509,1517,1521,1529,1534,1536,1544,1545,1548,1555,1560,1561,1569,1577,1583,1589,1590,1595,1598,1606,1613,1618,1624,1626,1630,1636,1644,1647,1655,1660,1668,1673,1679,1680,1683,1686,1690,1693,1700,1707,1709,1712,1717,1720,1726,1731,1736,1743,1750,1755,1758,1760,1761,1767,1768,1772,1773,1780,1787,1795,1799,1802,1810,1818,1819,1823,1827,1831,1836,1839,1840,1843,1845,1849,1853,1855,1863,1869,1871,1878,1881,1889,1891,1893,1901,1907,1911,1915,1922,1923,1929,1935,1942,1948,1952,1959,1960,1965,1972,1973,1975,1979,1983,1991,1993,1996,2004,2008,2014,2019,2020,2026,2029,2031,2032,2036,2042,2044,2052,2060,2068,2076,2083,2088,2094,2095,2102,2109,2111,2118,2121,2129,2137,2140,2141,2147,2152,2159,2162,2166,2170,2178,2180,2188,2193,2197,2203,2206,2213,2218,2224,2229,2237,2240,2245,2248,2251,2252,2254,2260,2266,2267,2269,2271,2275,2278,2279,2281,2287,2292,2295,2302,2306,2313,2319,2327,2328,2332,2340,2348,2356,2359,2367,2374,2379,2387,2388,2394,2399,2407,2413,2415,2417,2418,2419,2424,2425,2430,2434,2438,2439,2444,2450,2456,2463,2469,2473,2481,2484,2488,2496,2503,2505,2507,2512,2514,2521,2529,2537,2541,2542,2549,2551,2558,2561,2569,2577,2585,2591,2593,2596,2600,2606,2609,2613,2621,2622,2625,2633,2635,2642,2647,2651,2654,2662,2663,2671,2678,2679,2683,2686,2689,2696,2703,2706,2711,2714,2717,2721,2722,2723,2726,2732,2740,2743,2746,2750,2752,2757,2761,2763,2767,2774,2775,2778,2782,2784,2788,2795,2802,2804,2808,2815,2821,2822,2830,2832,2838,2843,2844,2846,2849,2853,2854,2859,2864,2870,2878,2881,2885,2892,2893,2899,2900,2907,2908,2916,2917,2925,2926,2933,2934,2935,2938,2940,2945,2949,2955,2961,2967,2973,2980,2984,2992,2998,2999,3006,3014,3017,3021,3023,3026,3027,3029,3032,3036,3037,3042,3050,3051,3058,3065,3067,3074,3078,3081,3085,3093,3095,3100,3107,3109,3111,3117,3120,3121,3126,3128,3132,3134,3141,3143,3146,3150,3158,3163,3164,3168,3172,3179,3183,3185,3193,3198,3206,3213,3220,3223,3226,3234,3237,3239,3247,3251,3256,3259,3266,3274,3275,3279,3285,3286,3292,3298,3302,3303,3310,3318,3320,3325,3330,3338,3340,3347,3354,3355,3357,3361,3365,3366,3371,3376,3383,3389,3397,3403,3405,3407,3415,3422,3430,3438,3445,3449,3453,3454,3457,3464,3465,3467,3468,3471,3478,3480,3485,3487,3488,3490,3494,3495,3500,3504,3507,3513,3519,3521,3522,3530,3534,3542,3545,3550,3554,3556,3561,3566,3570,3573,3575,3577,3582,3590,3594,3601,3607,3614,3619,3626,3631,3638,3646,3650,3651,3659,3665,3671,3677,3681,3682,3688,3689,3693,3699,3703,3707,3710,3716,3721,3724,3730,3731,3733,3739,3740,3742,3744,3746,3750,3757,3759,3765,3768,3769,3772,3779,3782,3786,3792,3795,3800,3803,3808,3810,3814,3815,3817,3824,3826,3832,3839,3840,3842,3846,3853,3860,3864,3870,3873,3878,3879,3887,3890,3895,3900,3904,3906,3908,3913,3916,3921,3924,3926,3929,3937,3938,3943,3944,3946,3947,3953,3956,3963,3967,3972,3976,3982,3988,3994,4001,4008,4009,4014,4020,4027,4033,4035,4040,4044,4051,4059,4066,4068,4075,4080,4082,4090,4094,4099,4103,4104,4109,4114,4118,4119,4124,4126,4129,4135,4141,4147,4148,4150,4152,4155,4162,4165,4173,4179,4183,4184,4187,4193,4194,4196,4197,4200,4206,4208,4216,4219,4226,4233,4234,4239,4243,4251,4259,4265,4268,4273,4278,4285,4291,4297,4301,4305,4309,4312,4318,4326,4327,4328,4331,4334,4337,4342,4346,4353,4356,4360,4366,4370,4371,4376,4379,4381,4383,4388,4392,4396,4398,4406,4411,4414,4417,4425,4427,4429,4435,4442,4449,4451,4454,4458,4466,4469,4477,4478,4479,4483,4487,4495,4503,4508,4513,4517,4519,4522,4524,4525,4533,4537,4538,4540,4541,4542,4548,4556,4563,4569,4571,4575,4582,4590,4596,4603,4605,4607,4613,4620,4626,4627,4629,4630,4631,4633,4640,4641,4644,4652,4654,4659,4661,4665,4669,4677,4681,4682,4689,4696,4703,4705,4712,4720,4727,4735,4743,4750,4752,4756,4760,4761,4769,4776,4780,4782,4788,4791,4795,4797,4798,4799,4804,4810,4816,4823,4825,4831,4836,4837,4841,4845,4851,4857,4863,4864,4867,4874,4876,4877,4880,4888,4890,4892,4899,4907,4908,4911,4917,4919,4923,4929,4937,4941,4945,4952,4959,4966,4968,4971,4973,4981,4986,4994,5002,5005,5008,5009,5011,5015,5021,5029,5037,5045,5046,5048,5053,5054,5055,5061,5065,5069,5071,5074,5077,5078,5083,5086,5093,5094,5095,5100,5101,5109,5110,5116,5120,5123,5126,5127,5130,5137,5139,5146,5149,5152,5160,5162,5168,5175,5178,5184,5191,5193,5194,5196,5198,5202,5207,5208,5214,5221,5229,5231,5234,5241,5244,5248,5253,5258,5263,5270,5275,5281,5283,5285,5289,5296,5303,5304,5307,5310,5311,5312,5315,5317,5318,5325,5333,5338,5343,5345,5347,5350,5351,5357,5362,5367,5375,5383,5386,5389,5390,5395,5398,5404,5408,5415,5416,5417,5421,5422,5429,5430,5431,5436,5443,5449,5457,5460,5463,5466,5473,5475,5477,5482,5488,5490,5497,5498,5503,5505,5506,5508,5511,5519,5523,5530,5532,5537,5539,5544,5549,5555,5556,5560,5561,5563,5565,5566,5571,5577,5582,5584,5591,5597,5598,5603,5607,5614,5615,5617,5620,5625,5631,5637,5640,5646,5654,5657,5658,5665,5668,5673,5676,5680,5688,5692,5693,5700,5704,5710,5716,5722,5724,5730,5731,5736,5743,5748,5753,5761,5764,5770,5773,5775,5783,5791,5797,5803,5807,5809,5811,5819,5826,5828,5832,5836,5838,5844,5851,5854,5859,5866,5869,5871,5879,5883,5888,5895,5898,5901,5909,5914,5915,5919,5925,5927,5931,5933,5937,5943,5951,5954,5957,5958,5965,5970,5977,5981,5983,5991,5999,6007,6008,6011,6016,6024,6025,6030,6033,6034,6039,6044,6047,6052,6056,6061,6062,6066,6067,6072,6079,6085,6093,6100,6103,6110,6118,6119,6121,6126,6133,6137,6142,6148,6152,6155,6157,6162,6164,6168,6174,6182,6183,6188,6192,6199,6205,6211,6217,6219,6226,6228,6229,6230,6231,6239,6247,6253,6254,6262,6265,6270,6278,6283,6287,6293,6298,6301,6302,6308,6314,6315,6323,6327,6332,6335,6342,6343,6344,6349,6356,6364,6370,6373,6379,6386,6391,6397,6399,6402,6407,6409,6417,6423,6428,6429,6430,6431,6437,6440,6443,6447,6450,6458,6462,6470,6474,6481,6487,6494,6496,6500,6506,6510,6511,6516,6523,6528,6536,6543,6548,6555,6562,6564,6565,6567,6572,6575,6583,6585,6592,6598,6605,6613,6616,6622,6629,6634,6641,6649,6652,6655,6661,6666,6667,6670,6673,6680,6685,6692,6700,6704,6709,6713,6716,6719,6724,6730,6738,6744,6750,6758,6759,6760,6766,6772,6780,6783,6791,6798,6799,6803,6811,6819,6820,6824,6826,6829,6834,6842,6850,6852,6858,6860,6867,6873,6880,6888,6893,6898,6905,6911,6915,6923,6930,6936,6937,6945,6949,6951,6959,6966,6968,6972,6974,6982,6984,6989,6993,6996,7004,7007,7014,7019,7024,7028,7030,7031,7033,7040,7046,7051,7058,7063,7065,7066,7069,7075,7076,7078,7082,7087,7089,7093,7095,7102,7107,7114,7121,7124,7131,7134,7141,7144,7149,7150,7151,7154,7160,7168,7176,7182,7188,7193,7200,7205,7211,7214,7218,7221,7229,7231,7237,7245,7250,7251,7254,7259,7267,7268,7275,7281,7289,7295,7301,7302,7303,7310,7311,7319,7321,7323,7331,7339,7341,7346,7352,7353,7356,7360,7362,7363,7370,7375,7378,7385,7391,7396,7402,7407,7412,7418,7421,7428,7431,7439,7442,7443,7450,7451,7452,7456,7463,7465,7468,7469,7474,7482,7485,7491,7493,7496,7504,7505,7509,7516,7518,7519,7525,7532,7536,7542,7545,7552,7559,7562,7568,7572,7578,7579,7586,7591,7595,7596,7600,7603,7607,7615,7621,7625,7628,7630,7632,7637,7642,7644,7651,7656,7660,7665,7671,7678,7679,7686,7688,7690,7691,7693,7695,7703,7706,7707,7714,7720,7724,7729,7736,7741,7744,7750,7751,7752,7758,7762,7763,7767,7774,7779,7781,7783,7791,7793,7800,7807,7814,7820,7822,7830,7837,7840,7843,7846,7853,7855,7862,7870,7878,7879,7882,7883,7887,7892,7894,7898,7904,7910,7915,7916,7918,7926,7930,7936,7941,7948,7954,7957,7958,7961,7962,7969,7970,7976,7981,7982,7990,7994,8002,8010,8017,8018,8026,8034,8036,8040,8046,8054,8062,8067,8073,8078,8083,8084,8085,8086,8088,8090,8096,8100,8101,8108,8115,8122,8124,8125,8130,8134,8135,8140,8147,8151,8158,8162,8167,8173,8176,8182,8187,8194,8202,8203,8204,8211,8219,8223,8228,8231,8233,8239,8244,8252,8254,8258,8261,8265,8273,8280,8287,8290,8296,8299,8304,8310,8318,8322,8329,8334,8337,8338,8342,8348,8355,8362,8364,8366,8371,8375,8379,8382,8385,8389,8394,8399,8406,8409,8415,8422,8423,8429,8434,8438,8439,8440,8447,8450,8455,8463,8465,8467,8472,8477,8480,8483,8488,8493,8497,8500,8501,8505,8510,8516,8521,8529,8531,8532,8536,8544,8550,8556,8557,8563,8565,8570,8571,8573,8579,8587,8594,8596,8604,8605,8612,8614,8621,8629,8634,8641,8645,8648,8654,8660,8663,8666,8674,8680,8682,8689,8692,8697,8699,8702,8705,8711,8715,8723,8726,8729,8730,8731,8732,8739,8746,8754,8755,8757,8761,8766,8768,8771,8776,8779,8780,8785,8792,8800,8801,8806,8810,8811,8813,8818,8826,8833,8836,8838,8845,8851,8853,8858,8861,8866,8873,8881,8882,8883,8891,8893,8895,8899,8903,8904,8908,8910,8911,8918,8923,8929,8934,8942,8950,8957]
-- 4000
-- main = print $ getSpectralWeight 1 [8,14,22,28,29,30,37,39,46,48,52,54,59,64,67,68,72,77,84,87,92,93,94,95,100,106,114,115,117,120,123,125,130,131,138,139,141,142,149,153,160,163,164,171,178,182,184,187,192,199,204,211,215,223,229,234,241,242,248,252,254,259,266,270,271,278,283,288,289,296,298,306,312,314,316,319,322,330,337,339,343,347,350,351,357,362,365,368,372,378,381,383,387,392,396,399,401,402,410,415,420,424,428,431,438,445,448,453,459,466,471,472,474,478,484,487,494,497,503,509,516,524,529,536,543,548,555,558,566,573,574,576,583,591,593,594,600,606,612,615,621,622,627,628,634,636,644,650,658,665,671,672,679,680,683,687,691,696,700,701,704,710,713,721,724,728,736,738,739,747,754,759,766,770,774,778,786,794,795,797,798,799,800,803,805,812,816,822,824,832,838,843,849,856,859,863,865,870,872,877,879,884,891,897,900,908,912,918,922,930,933,939,942,948,951,955,959,963,967,972,976,984,990,995,996,1004,1007,1012,1013,1021,1028,1029,1030,1031,1039,1045,1049,1051,1055,1057,1060,1062,1070,1075,1082,1086,1090,1096,1100,1104,1112,1114,1116,1119,1127,1133,1135,1142,1146,1147,1153,1155,1161,1165,1166,1172,1175,1178,1181,1184,1189,1193,1201,1203,1208,1211,1214,1218,1223,1230,1232,1233,1235,1237,1241,1244,1245,1249,1251,1258,1259,1264,1270,1276,1284,1292,1295,1299,1303,1305,1312,1315,1321,1327,1329,1332,1334,1336,1343,1349,1355,1359,1366,1367,1369,1370,1375,1376,1382,1387,1391,1395,1402,1409,1414,1416,1421,1424,1431,1438,1441,1445,1449,1457,1461,1464,1466,1471,1474,1476,1479,1485,1489,1492,1499,1507,1512,1514,1517,1519,1520,1525,1532,1537,1542,1550,1554,1561,1564,1565,1568,1576,1581,1589,1594,1596,1599,1606,1611,1619,1622,1626,1631,1638,1639,1640,1644,1645,1651,1652,1654,1662,1668,1675,1681,1683,1684,1689,1695,1702,1706,1711,1718,1721,1723,1728,1729,1733,1734,1742,1744,1746,1753,1754,1762,1767,1772,1778,1786,1793,1797,1803,1810,1812,1816,1819,1820,1821,1826,1832,1839,1843,1848,1855,1861,1868,1872,1877,1880,1886,1887,1890,1891,1895,1903,1906,1914,1918,1924,1928,1934,1937,1942,1946,1948,1953,1960,1962,1965,1966,1970,1976,1977,1979,1987,1990,1998,2000,2006,2011,2013,2021,2024,2030,2032,2036,2042,2047,2053,2054,2056,2059,2066,2070,2077,2080,2086,2093,2096,2100,2106,2114,2115,2118,2126,2127,2132,2138,2140,2144,2147,2151,2156,2164,2168,2175,2178,2180,2185,2193,2201,2203,2204,2207,2215,2221,2223,2231,2234,2239,2242,2249,2255,2259,2266,2269,2275,2278,2285,2290,2291,2293,2294,2297,2299,2306,2308,2312,2315,2317,2322,2326,2330,2337,2343,2348,2349,2352,2358,2361,2368,2371,2379,2385,2386,2390,2398,2400,2405,2410,2417,2420,2423,2425,2426,2428,2433,2441,2443,2444,2452,2456,2464,2470,2475,2479,2481,2485,2493,2495,2499,2507,2512,2514,2520,2528,2533,2535,2542,2547,2553,2557,2561,2566,2573,2574,2577,2580,2583,2587,2588,2591,2596,2602,2610,2615,2619,2627,2632,2638,2642,2647,2653,2658,2665,2670,2671,2674,2679,2681,2686,2688,2696,2703,2707,2715,2721,2722,2724,2732,2740,2741,2743,2746,2750,2758,2762,2766,2774,2778,2781,2782,2790,2792,2793,2796,2798,2801,2805,2806,2809,2812,2815,2821,2822,2830,2836,2837,2844,2845,2846,2849,2856,2862,2864,2871,2873,2881,2887,2889,2896,2904,2910,2915,2918,2919,2923,2925,2932,2940,2948,2953,2954,2958,2962,2966,2969,2975,2983,2990,2993,2999,3003,3006,3011,3012,3014,3021,3025,3033,3038,3045,3046,3050,3053,3055,3063,3067,3074,3078,3079,3084,3086,3092,3095,3103,3108,3113,3120,3125,3132,3138,3139,3144,3150,3151,3157,3161,3168,3172,3174,3178,3179,3183,3190,3192,3194,3202,3209,3214,3216,3219,3220,3228,3234,3235,3243,3251,3259,3264,3270,3277,3280,3288,3292,3293,3297,3298,3303,3308,3315,3321,3324,3325,3326,3328,3331,3334,3342,3347,3349,3351,3356,3360,3361,3368,3370,3374,3375,3380,3384,3389,3390,3397,3398,3406,3411,3417,3423,3431,3438,3445,3453,3459,3462,3465,3472,3479,3486,3494,3496,3503,3504,3505,3506,3512,3519,3525,3529,3535,3541,3543,3549,3555,3563,3567,3569,3574,3579,3582,3584,3592,3593,3599,3605,3607,3608,3613,3618,3621,3622,3625,3633,3635,3641,3645,3648,3654,3661,3668,3675,3678,3679,3680,3683,3684,3685,3691,3695,3701,3707,3712,3717,3718,3724,3732,3733,3734,3735,3743,3751,3752,3753,3759,3761,3768,3775,3777,3785,3786,3792,3797,3805,3809,3817,3824,3825,3832,3834,3835,3839,3844,3851,3854,3860,3867,3868,3875,3883,3885,3891,3899,3906,3912,3920,3927,3930,3934,3938,3939,3947,3948,3954,3956,3958,3964,3967,3969,3973,3978,3986,3989,3995,4002,4006,4014,4021,4026,4031,4034,4036,4044,4046,4048,4052,4057,4059,4067,4072,4076,4078,4086,4092,4093,4098,4106,4108,4114,4122,4128,4136,4141,4146,4149,4151,4153,4155,4160,4166,4167,4170,4173,4178,4181,4187,4194,4201,4203,4206,4211,4214,4217,4221,4226,4228,4231,4238,4240,4241,4243,4249,4256,4264,4268,4272,4275,4281,4285,4287,4295,4297,4303,4311,4317,4321,4328,4329,4332,4339,4347,4349,4356,4363,4371,4379,4380,4386,4391,4397,4400,4407,4414,4417,4419,4425,4430,4432,4435,4440,4445,4450,4454,4455,4460,4465,4467,4475,4479,4483,4487,4491,4492,4500,4502,4510,4518,4522,4527,4535,4537,4544,4549,4553,4558,4565,4569,4574,4581,4586,4591,4598,4600,4607,4612,4615,4616,4620,4625,4626,4634,4641,4649,4650,4655,4663,4667,4674,4676,4679,4687,4694,4702,4708,4713,4720,4728,4729,4734,4742,4750,4755,4761,4766,4770,4776,4779,4781,4787,4791,4799,4800,4808,4813,4821,4829,4837,4838,4843,4847,4849,4851,4855,4858,4865,4871,4876,4881,4885,4887,4894,4898,4905,4913,4917,4922,4928,4932,4939,4946,4952,4958,4959,4967,4971,4976,4983,4986,4994,5000,5006,5009,5014,5022,5026,5029,5037,5040,5044,5051,5057,5065,5069,5077,5079,5080,5081,5087,5089,5094,5102,5103,5107,5112,5118,5126,5127,5131,5137,5145,5147,5149,5154,5162,5169,5170,5176,5183,5185,5192,5197,5199,5207,5209,5217,5220,5224,5227,5232,5239,5242,5250,5257,5259,5262,5263,5265,5266,5268,5269,5272,5274,5278,5282,5286,5292,5294,5295,5301,5302,5306,5311,5315,5320,5326,5329,5331,5337,5344,5348,5356,5359,5363,5367,5373,5380,5381,5389,5394,5396,5397,5398,5403,5405,5413,5417,5418,5424,5432,5438,5446,5453,5460,5466,5468,5471,5475,5478,5485,5489,5496,5502,5503,5506,5513,5515,5517,5521,5526,5533,5536,5538,5541,5545,5551,5557,5559,5560,5562,5569,5576,5580,5584,5592,5593,5595,5601,5609,5611,5616,5617,5621,5623,5630,5636,5641,5647,5652,5654,5655,5659,5666,5674,5676,5678,5679,5681,5682,5686,5693,5694,5696,5703,5708,5715,5720,5723,5726,5727,5734,5741,5749,5757,5758,5759,5762,5766,5770,5773,5780,5786,5788,5791,5796,5801,5808,5816,5819,5824,5827,5835,5836,5838,5843,5850,5851,5853,5857,5859,5860,5861,5869,5870,5872,5875,5883,5885,5891,5896,5899,5905,5911,5918,5922,5929,5932,5938,5943,5947,5949,5957,5965,5969,5976,5982,5989,5995,6003,6005,6011,6015,6022,6029,6035,6042,6044,6047,6051,6052,6054,6058,6066,6069,6076,6077,6085,6086,6091,6097,6103,6104,6107,6109,6112,6120,6123,6129,6132,6135,6140,6141,6144,6149,6152,6158,6166,6174,6182,6186,6189,6192,6200,6206,6212,6220,6221,6226,6231,6235,6237,6244,6252,6260,6261,6268,6272,6275,6277,6283,6291,6292,6293,6299,6302,6310,6311,6314,6315,6320,6324,6329,6330,6333,6334,6339,6347,6348,6351,6355,6362,6367,6368,6370,6378,6383,6390,6395,6403,6407,6408,6410,6415,6422,6425,6430,6432,6434,6437,6438,6444,6452,6460,6468,6471,6476,6481,6489,6495,6499,6505,6507,6514,6519,6525,6531,6534,6536,6544,6551,6556,6559,6567,6573,6576,6578,6584,6586,6593,6600,6603,6610,6615,6622,6624,6631,6638,6643,6650,6653,6661,6662,6665,6666,6674,6680,6682,6685,6689,6692,6700,6702,6709,6715,6723,6728,6735,6741,6745,6753,6761,6767,6769,6775,6776,6783,6791,6793,6799,6804,6809,6816,6821,6826,6834,6835,6841,6848,6849,6855,6857,6860,6866,6874,6877,6883,6890,6895,6900,6902,6909,6916,6920,6923,6927,6929,6932,6937,6939,6941,6942,6945,6949,6955,6963,6965,6972,6979,6987,6990,6996,7001,7007,7009,7016,7019,7023,7027,7032,7034,7035,7037,7038,7042,7043,7045,7051,7053,7057,7065,7073,7078,7085,7091,7098,7102,7110,7116,7120,7122,7125,7128,7134,7135,7142,7143,7151,7155,7156,7157,7160,7163,7165,7168,7171,7179,7187,7188,7193,7197,7201,7205,7209,7216,7223,7230,7236,7239,7241,7244,7250,7252,7256,7262,7267,7268,7275,7280,7282,7283,7284,7287,7294,7299,7304,7312,7317,7320,7328,7330,7334,7342,7345,7353,7359,7365,7371,7377,7381,7389,7397,7401,7404,7406,7411,7418,7420,7424,7431,7435,7443,7450,7455,7459,7463,7465,7469,7476,7477,7485,7492,7496,7497,7498,7501,7509,7514,7518,7525,7531,7533,7538,7541,7549,7553,7554,7556,7558,7565,7566,7572,7575,7579,7582,7584,7592,7595,7602,7606,7613,7618,7622,7624,7632,7639,7641,7642,7646,7647,7648,7655,7658,7659,7661,7668,7672,7673,7681,7685,7689,7697,7701,7702,7708,7714,7720,7722,7724,7731,7733,7735,7737,7738,7739,7740,7748,7753,7759,7763,7764,7768,7769,7774,7779,7782,7790,7797,7802,7805,7806,7807,7809,7811,7813,7818,7822,7827,7828,7832,7840,7842,7845,7852,7853,7854,7855,7858,7865,7868,7874,7875,7878,7885,7886,7893,7895,7898,7905,7907,7908,7914,7921,7925,7927,7931,7938,7939,7944,7947,7953,7957,7965,7973,7977,7980,7985,7990,7997,8000,8005,8011,8017,8020,8026,8028,8029,8031,8032,8033,8036,8043,8047,8052,8060,8065,8071,8073,8081,8087,8094,8100,8106,8107,8111,8119,8122,8130,8138,8139,8140,8146,8154,8161,8168,8176,8184,8185,8188,8195,8202,8208,8216,8223,8224,8228,8233,8235,8240,8242,8250,8251,8257,8262,8265,8269,8271,8278,8285,8292,8297,8300,8304,8312,8320,8323,8325,8333,8338,8345,8349,8354,8358,8360,8365,8366,8373,8380,8388,8391,8397,8401,8408,8415,8422,8423,8425,8428,8435,8438,8442,8448,8456,8458,8462,8469,8477,8485,8487,8489,8492,8500,8506,8508,8514,8515,8516,8519,8523,8524,8525,8528,8532,8533,8540,8541,8547,8551,8555,8560,8565,8570,8572,8576,8578,8586,8588,8593,8598,8606,8607,8609,8614,8616,8619,8624,8627,8628,8635,8643,8649,8653,8661,8664,8667,8675,8681,8684,8686,8693,8701,8704,8708,8710,8718,8722,8730,8732,8736,8738,8746,8753,8755,8763,8764,8769,8776,8777,8781,8788,8796,8803,8806,8811,8819,8823,8829,8837,8842,8850,8853,8861,8866,8870,8877,8878,8885,8887,8890,8892,8894,8898,8903,8908,8913,8921,8929,8934,8938,8946,8948,8956,8959,8964,8969,8970,8973,8974,8975,8983,8984,8985,8988,8996,8997,9003,9008,9015,9017,9022,9028,9030,9036,9038,9043,9045,9053,9059,9062,9065,9068,9069,9071,9079,9083,9085,9090,9098,9106,9111,9115,9123,9125,9127,9133,9137,9143,9145,9149,9155,9163,9164,9168,9175,9178,9185,9188,9195,9202,9209,9212,9218,9220,9223,9226,9231,9237,9245,9246,9248,9250,9256,9260,9268,9269,9274,9280,9288,9296,9298,9299,9306,9309,9317,9324,9329,9333,9340,9342,9350,9351,9359,9366,9373,9379,9386,9391,9395,9399,9407,9408,9415,9422,9426,9428,9435,9443,9449,9451,9456,9459,9462,9469,9470,9471,9478,9483,9484,9488,9490,9497,9500,9505,9506,9513,9517,9524,9526,9534,9539,9541,9542,9546,9548,9556,9564,9566,9571,9579,9584,9591,9594,9596,9599,9605,9611,9612,9619,9621,9628,9635,9638,9646,9651,9656,9659,9666,9668,9669,9672,9678,9682,9687,9690,9691,9695,9702,9710,9716,9724,9725,9726,9729,9731,9737,9745,9750,9753,9758,9765,9770,9778,9780,9786,9788,9791,9793,9797,9804,9807,9808,9814,9818,9821,9825,9829,9837,9841,9845,9852,9853,9860,9863,9871,9878,9880,9884,9891,9894,9901,9909,9917,9921,9922,9930,9935,9937,9944,9952,9957,9958,9965,9969,9977,9984,9989,9995,9998,9999,10006,10013,10019,10025,10033,10037,10040,10041,10048,10056,10057,10060,10066,10069,10071,10075,10078,10080,10083,10087,10095,10099,10103,10111,10118,10126,10133,10137,10144,10152,10155,10163,10169,10177,10179,10180,10187,10188,10191,10194,10198,10202,10203,10210,10213,10217,10223,10231,10238,10246,10249,10256,10259,10265,10267,10270,10275,10281,10286,10291,10294,10299,10303,10309,10317,10322,10327,10328,10332,10336,10343,10347,10353,10358,10360,10363,10366,10367,10374,10379,10380,10388,10391,10396,10404,10409,10412,10420,10421,10424,10432,10439,10447,10449,10454,10458,10465,10468,10474,10478,10482,10483,10485,10489,10493,10498,10502,10503,10511,10515,10517,10518,10521,10529,10532,10533,10535,10537,10545,10546,10547,10553,10557,10559,10566,10573,10581,10588,10592,10595,10602,10610,10612,10618,10623,10625,10630,10638,10644,10646,10651,10658,10664,10671,10673,10676,10681,10683,10689,10690,10698,10705,10707,10713,10719,10725,10727,10728,10734,10736,10744,10746,10753,10761,10765,10772,10775,10783,10788,10790,10793,10799,10800,10802,10809,10811,10812,10815,10816,10819,10825,10830,10834,10839,10842,10849,10852,10860,10864,10870,10874,10879,10880,10881,10886,10887,10888,10895,10896,10902,10910,10913,10917,10918,10925,10926,10929,10930,10935,10938,10945,10946,10947,10952,10958,10959,10962,10969,10975,10982,10987,10992,10995,11002,11008,11011,11014,11018,11025,11028,11032,11039,11046,11053,11061,11068,11069,11070,11076,11079,11085,11089,11094,11096,11104,11107,11113,11120,11126,11132,11135,11141,11145,11153,11159,11162,11169,11170,11177,11184,11190,11193,11201,11206,11209,11215,11221,11226,11231,11234,11239,11246,11249,11256,11264,11270,11277,11278,11286,11292,11297,11300,11308,11310,11311,11318,11319,11324,11332,11339,11346,11351,11355,11356,11358,11363,11365,11367,11370,11371,11376,11379,11386,11393,11399,11407,11415,11422,11427,11435,11437,11445,11450,11457,11460,11467,11471,11476,11477,11484,11486,11493,11500,11505,11512,11516,11523,11530,11532,11535,11541,11545,11548,11555,11559,11561,11566,11570,11574,11575,11581,11586,11590,11595,11603,11606,11608,11610,11617,11618,11620,11625,11628,11634,11642,11650,11658,11663,11671,11678,11682,11687,11688,11692,11694,11697,11704,11705,11713,11719,11723,11725,11727,11734,11742,11749,11751,11753,11757,11764,11768,11769,11777,11778,11781,11786,11788,11795,11800,11806,11814,11822,11827,11834,11841,11845,11853,11861,11867,11870,11877,11881,11882,11883,11889,11894,11900,11904,11908,11912,11917,11920,11921,11922,11926,11932,11938,11940,11945,11946,11948,11956,11964,11968,11971,11975,11978,11984,11987,11994,11998,12001,12005,12010,12012,12018,12026,12034,12037,12045,12049,12055,12059,12063,12067,12072,12076,12082,12084,12088,12091,12097,12098,12104,12108,12116,12120,12121,12124,12131,12137,12141,12145,12150,12157,12161,12168,12175,12178,12179,12184,12189,12194,12201,12204,12211,12213,12219,12221,12227,12229,12237,12241,12242,12248,12254,12257,12263,12268,12274,12280,12281,12286,12292,12296,12302,12310,12316,12318,12323,12324,12328,12335,12343,12350,12357,12358,12364,12368,12373,12375,12383,12387,12392,12397,12401,12402,12410,12415,12418,12426,12429,12436,12437,12445,12453,12458,12462,12468,12474,12475,12478,12485,12493,12500,12507,12512,12517,12521,12522,12523,12526,12531,12533,12541,12543,12544,12549,12553,12554,12556,12557,12561,12565,12566,12569,12576,12584,12585,12587,12593,12600,12603,12604,12611,12614,12617,12624,12626,12632,12637,12644,12652,12654,12659,12665,12672,12680,12685,12688,12692,12699,12706,12709,12711,12713,12714,12719,12726,12730,12733,12734,12740,12743,12744,12745,12751,12754,12762,12766,12772,12777,12784,12787,12795,12802,12810,12816,12820,12822,12829,12832,12839,12847,12851,12853,12854,12860,12861,12865,12872,12876,12877,12880,12888,12891,12892,12898,12902,12910,12918,12920,12926,12929,12932,12936,12937,12941,12948,12954,12960,12965,12969,12973,12976,12980,12986,12992,12996,13001,13003,13004,13005,13011,13019,13026,13027,13035,13043,13048,13049,13057,13061,13063,13069,13073,13077,13085,13087,13089,13096,13099,13102,13104,13109,13112,13120,13126,13131,13139,13143,13148,13151,13153,13160,13162,13170,13172,13179,13183,13184,13185,13191,13197,13199,13203,13205,13212,13213,13217,13218,13225,13230,13232,13237,13241,13248,13253,13257,13261,13262,13265,13271,13274,13276,13278,13282,13288,13292,13299,13301,13305,13310,13313,13315,13320,13321,13324,13325,13330,13335,13336,13342,13346,13352,13360,13367,13369,13371,13375,13376,13377,13381,13389,13397,13399,13403,13407,13412,13414,13420,13428,13433,13439,13446,13454,13456,13460,13463,13470,13471,13478,13484,13490,13494,13500,13507,13510,13513,13518,13525,13529,13534,13538,13541,13549,13551,13557,13562,13570,13578,13579,13587,13589,13594,13599,13600,13607,13610,13618,13622,13629,13632,13637,13640,13642,13645,13652,13660,13668,13669,13676,13682,13687,13689,13696,13699,13701,13702,13710,13712,13717,13720,13726,13727,13728,13734,13742,13750,13757,13764,13765,13769,13774,13777,13779,13786,13788,13796,13800,13808,13815,13821,13826,13827,13834,13839,13840,13844,13846,13849,13854,13857,13864,13871,13874,13875,13877,13884,13889,13893,13898,13899,13907,13912,13918,13920,13926,13932,13939,13942,13943,13946,13952,13957,13962,13967,13969,13975,13982,13989,13991,13997,14003,14004,14011,14013,14014,14017,14024,14032,14037,14038,14039,14040,14048,14051,14055,14056,14061,14064,14070,14073,14078,14082,14084,14092,14100,14103,14108,14113,14117,14118,14119,14120,14125,14130,14132,14138,14141,14149,14157,14161,14164,14172,14175,14179,14183,14186,14194,14197,14199,14204,14212,14219,14220,14226,14229,14233,14236,14237,14240,14244,14251,14255,14262,14265,14272,14273,14274,14276,14284,14287,14288,14296,14299,14307,14312,14318,14319,14321,14326,14334,14338,14339,14344,14349,14351,14352,14357,14359,14361,14365,14366,14374,14377,14383,14387,14388,14395,14400,14408,14412,14417,14418,14424,14427,14434,14442,14446,14451,14452,14453,14455,14459,14461,14468,14470,14472,14478,14479,14480,14481,14489,14497,14503,14510,14514,14522,14527,14529,14537,14539,14543,14550,14558,14562,14565,14568,14569,14574,14577,14578,14580,14582,14583,14584,14586,14594,14599,14600,14604,14612,14614,14616,14619,14620,14623,14624,14631,14638,14643,14647,14650,14657,14659,14666,14674,14682,14687,14693,14697,14700,14701,14708,14715,14716,14721,14726,14727,14732,14737,14741,14748,14750,14755,14761,14767,14769,14772,14780,14786,14788,14789,14793,14794,14799,14801,14805,14808,14809,14811,14818,14821,14825,14827,14833,14836,14840,14841,14845,14851,14853,14857,14863,14866,14871,14876,14883,14886,14891,14898,14905,14909,14915,14917,14923,14928,14936,14943,14947,14955,14959,14964,14972,14979,14987,14989,14996,15003,15004,15005,15012,15013,15021,15022,15024,15025,15029,15030,15031,15038,15043,15045,15048,15053,15056,15064,15066,15073,15074,15076,15081,15084,15089,15090,15091,15093,15099,15101,15102,15104,15109,15111,15118,15120,15122,15127,15128,15130,15131,15136,15137,15139,15142,15150,15153,15154,15157,15164,15169,15177,15183,15190,15195,15196,15201,15206,15209,15213,15217,15221,15223,15226,15228,15229,15233,15238,15244,15252,15257,15263,15267,15271,15275,15281,15284,15288,15294,15298,15299,15300,15301,15309,15312,15317,15318,15320,15322,15330,15336,15338,15346,15352,15359,15366,15371,15373,15380,15384,15392,15398,15402,15407,15409,15413,15415,15419,15420,15425,15428,15433,15440,15447,15450,15455,15461,15466,15474,15476,15484,15487,15491,15497,15503,15511,15517,15522,15527,15530,15538,15542,15544,15545,15547,15555,15556,15559,15561,15567,15572,15577,15582,15586,15589,15595,15596,15602,15610,15611,15612,15614,15615,15621,15622,15626,15627,15632,15637,15643,15651,15654,15657,15660,15668,15675,15680,15681,15684,15686,15694,15700,15701,15703,15709,15714,15718,15723,15729,15737,15744,15747,15750,15751,15758,15760,15762,15770,15777,15781,15786,15789,15790,15793,15800,15802,15803,15807,15809,15814,15815,15820,15823,15828,15834,15840,15845,15846,15854,15860,15865,15871,15877,15885,15893,15896,15902,15903,15905,15909,15913,15915,15916,15918,15923,15930,15931,15934,15937,15938,15941,15949,15953,15958,15965,15968,15976,15981,15982,15988,15990,15998,16002,16004,16009,16011,16018,16023,16024,16026,16032,16034,16040,16048,16053,16059,16061,16069,16070,16074,16076,16080,16082,16084,16085,16087,16088,16092,16100,16104,16109,16117,16119,16124,16131,16134,16140,16144,16150,16153,16157,16165,16171,16177,16179,16183,16184,16191,16196,16202,16206,16208,16213,16219,16222,16227,16228,16233,16235,16238,16243,16249,16251,16259,16260,16262,16268,16275,16276,16280,16287,16293,16300,16307,16314,16315,16316,16319,16323,16329,16331,16336,16342,16345,16353,16354,16357,16364,16371,16378,16386,16389,16391,16398,16400,16402,16404,16407,16414,16420,16425,16430,16433,16440,16448,16456,16462,16465,16467,16474,16482,16486,16494,16498,16502,16506,16514,16519,16523,16526,16529,16533,16540,16542,16550,16552,16557,16558,16565,16573,16581,16582,16585,16589,16595,16600,16608,16611,16617,16621,16628,16630,16632,16636,16638,16642,16648,16655,16661,16667,16670,16671,16674,16681,16684,16686,16691,16692,16700,16703,16708,16711,16714,16716,16723,16731,16739,16740,16746,16754,16757,16759,16764,16769,16772,16779,16781,16788,16794,16798,16802,16808,16810,16811,16819,16825,16831,16837,16840,16842,16844,16852,16854,16858,16861,16864,16869,16874,16875,16878,16882,16888,16895,16898,16901,16907,16914,16918,16925,16930,16931,16939,16945,16946,16950,16954,16956,16961,16965,16970,16972,16976,16981,16986,16993,16997,17000,17001,17006,17009,17016,17024,17030,17032,17038,17046,17049,17053,17060,17066,17071,17078,17080,17086,17091,17096,17100,17107,17110,17113,17117,17124,17129,17131,17137,17139,17145,17147,17149,17157,17158,17165,17173,17176,17180,17187,17192,17197,17203,17207,17212,17216,17223,17229,17230,17233,17237,17243,17247,17250,17251,17259,17262,17266,17274,17282,17288,17295,17301,17305,17307,17309,17316,17317,17318,17319,17323,17327,17329,17333,17341,17346,17348,17354,17355,17357,17359,17366,17367,17372,17374,17377,17383,17386,17390,17391,17396,17398,17406,17409,17410,17414,17422,17428,17432,17439,17443,17445,17447,17449,17454,17458,17459,17463,17468,17470,17474,17479,17485,17492,17494,17497,17500,17503,17511,17516,17524,17529,17537,17541,17549,17551,17555,17559,17564,17567,17573,17581,17582,17583,17585,17588,17592,17593,17596,17603,17606,17614,17620,17625,17629,17630,17635,17640,17648,17650,17651,17655,17660,17666,17667,17672,17675,17678,17681,17687,17695,17702,17704,17709,17716,17724,17727,17730,17738,17744,17752,17753,17759,17760,17761,17768,17774,17781,17788,17796,17799,17806,17813,17817,17819,17821,17825,17832,17840,17844,17849,17856,17857,17863,17869,17873,17880,17883,17885,17891,17898,17903,17909,17913,17921,17925,17929,17937]
-- main = print $ getMetricWeight 1 [0..500]
-- main = do ons <- randomOnsets 2000 
          -- print (map time ons)
          -- print (getMetricWeight 1 ons)
               
--------------------------------------------------------------------------------
-- property testing
--------------------------------------------------------------------------------
pSpectralWeight :: Period -> [Time] -> Bool
pSpectralWeight l@(Period p) o = 
  let o'   = map (* Time p) o  
      test =  getSpectralWeightOld l o' 
           == map (sweight . snd) (getSpectralWeight l o')
  in traceShow (map ((* p) . time) o) test

pMetricWeight :: [Time] -> Bool
pMetricWeight ons =   getMetricWeightOld 1 ons 
                  == (map mweight $ getMetricWeight 1 ons)
        
pLocalMeter :: Period -> [Time] -> Bool
pLocalMeter l@(Period p) o = 
  let o'   = map (* Time p) o 
      test = toNewMeterMap (getLocalMetersOld l o') 
           == getLocalMeters l (maxPeriod o') o'
  in traceShow (map ((* p) . time) o) test
  
toNewMeterMap :: IntMap [(Time, Len)] -> IntMap (IntMap Len)
toNewMeterMap = M.map convert where
  
  convert :: [(Time, Len)] -> IntMap Len
  convert = M.fromList . map (first time)

jmrEx, testRes3 :: [Time]
jmrEx = [0,1,2,6,8,9,10,14,16,17,18,22,24,25,26,30]
-- metric weight should be: [17,13,65,57,25,21,65,57,33,21,65,57,25,13,65,57]

testRes3 = [12,21,36,48,60,78,81,93,99,117,129,135,147,150,153,156,162,171,189,204,216,237,243,261,273,282,291,312,324,345,360,378,390,408,411,417,435,453,459,474,495,498,516,522,543,558,567,573,576,582]
-- metric weight should be: [25,40,16,33,20,21,70,8,52,57,36,73,42,53,61,29,61,72,82,42,40,48,55,44,40,61,41,58,41,57,45,30,28,42,49,41,29,62,32,45,33,37,34,12,37,41,16,37,12,8]
-- spectral weight should be: [67,0,0,18,0,0,41,0,0,61,0,0,33,0,0,94,0,0,42,0,0,30,0,0,41,0,0,33,0,0,17,0,0,61,0,0,80,0,0,17,0,0,58,0,0,21,0,0,41,0,0,89,0,0,46,0,0,9,0,0,33,0,0,50,0,0,38,0,0,116,0,0,33,0,0,25,0,0,33,0,0,42,0,0,30,0,0,73,0,0,21,0,0,21,0,0,53,0,0,17,0,0,26,0,0,95,0,0,33,0,0,17,0,0,33,0,0,61,0,0,25,0,0,90,0,0,67,0,0,9,0,0,29,0,0,67,0,0,53,0,0,69,0,0,45,0,0,22,0,0,78,0,0,29,0,0,25,0,0,89,0,0,25,0,0,13,0,0,51,0,0,38,0,0,21,0,0,103,0,0,29,0,0,21,0,0,25,0,0,42,0,0,63,0,0,61,0,0,25,0,0,26,0,0,73,0,0,29,0,0,30,0,0,57,0,0,38,0,0,17,0,0,37,0,0,65,0,0,17,0,0,129,0,0,30,0,0,13,0,0,33,0,0,29,0,0,21,0,0,101,0,0,46,0,0,13,0,0,41,0,0,70,0,0,25,0,0,62,0,0,78,0,0,26,0,0,41,0,0,58,0,0,17,0,0,82,0,0,29,0,0,25,0,0,50,0,0,17,0,0,79,0,0,61,0,0,38,0,0,21,0,0,86,0,0,34,0,0,17,0,0,65,0,0,25,0,0,21,0,0,25,0,0,78,0,0,42,0,0,94,0,0,29,0,0,13,0,0,78,0,0,38,0,0,13,0,0,70,0,0,29,0,0,13,0,0,79,0,0,21,0,0,17,0,0,65,0,0,62,0,0,17,0,0,33,0,0,29,0,0,29,0,0,95,0,0,67,0,0,75,0,0,29,0,0,54,0,0,25,0,0,65,0,0,29,0,0,13,0,0,58,0,0,50,0,0,25,0,0,61,0,0,38,0,0,9,0,0,29,0,0,83,0,0,25,0,0,114,0,0,25,0,0,22,0,0,41,0,0,21,0,0,58,0,0,78,0,0,33,0,0,17,0,0,54,0,0,29,0,0,29,0,0,90,0,0,58,0,0,13,0,0,37,0,0,41,0,0,22,0,0,82,0,0,67,0,0,9,0,0,33,0,0,25,0,0,29,0,0,77,0,0,33,0,0,26,0,0,53,0,0,63,0,0,29,0,0,73,0,0,43,0,0,17,0,0,71,0,0,53,0,0,25,0,0,107,0,0,33,0,0,46,0,0,46,0,0,42,0,0,21]
