@echo off
cd FW_KENSC-v0.3
echo Compressing music...
saxcmp ../sound_u/Boss_93.unc ../sound/Boss_93.sax
saxcmp ../sound_u/CNz_89.unc ../sound/CNz_89.sax
saxcmp ../sound_u/CNzVs_88.unc ../sound/CNzVs_88.sax
saxcmp ../sound_u/Cont_9C.unc ../sound/Cont_9C.sax
saxcmp ../sound_u/CPz_8E.unc ../sound/CPz_8E.sax
saxcmp ../sound_u/DEz_8A.unc ../sound/DEz_8A.sax
saxcmp ../sound_u/DEzFB_94.unc ../sound/DEzFB_94.sax
saxcmp ../sound_u/DHzVs_83.unc ../sound/DHzVs_83.sax
saxcmp ../sound_u/EndSq_95.unc ../sound/EndSq_95.sax
saxcmp ../sound_u/GHz_82.unc ../sound/GHz_82.sax
saxcmp ../sound_u/GHzVs_8C.unc ../sound/GHzVs_8C.sax
saxcmp ../sound_u/HPz_90.unc ../sound/HPz_90.sax
saxcmp ../sound_u/HTz_86.unc ../sound/HTz_86.sax
saxcmp ../sound_u/Invcb_97.unc ../sound/Invcb_97.sax
saxcmp ../sound_u/Menu_91.unc ../sound/Menu_91.sax
saxcmp ../sound_u/Mz_85.unc ../sound/Mz_85.sax
saxcmp ../sound_u/NGHz_87.unc ../sound/NGHz_87.sax
saxcmp ../sound_u/OOz_84.unc ../sound/OOz_84.sax
saxcmp ../sound_u/Pnc_9F.unc ../sound/Pnc_9F.sax
saxcmp ../sound_u/RScr_9A.unc ../sound/RScr_9A.sax
saxcmp ../sound_u/SCz_8D.unc ../sound/SCz_8D.sax
saxcmp ../sound_u/SFz_8F.unc ../sound/SFz_8F.sax
saxcmp ../sound_u/SpSnc_96.unc ../sound/SpSnc_96.sax
saxcmp ../sound_u/SS_92.unc ../sound/SS_92.sax
saxcmp ../sound_u/TScr_99.unc ../sound/TScr_99.sax
saxcmp ../sound_u/VsRes_81.unc ../sound/VsRes_81.sax
saxcmp -S ../sound_u/z80.unc ../sound/z80.sax
echo Compressing level tiles...
koscmp ../artkos_u/CNz_8.unc ../artkos/CNz_8.kos
koscmp ../artkos_u/CPz_8.unc ../artkos/CPz_8.kos
koscmp ../artkos_u/DHz_8.unc ../artkos/DHz_8.kos
koscmp ../artkos_u/GHz_8.unc ../artkos/GHz_8.kos
koscmp ../artkos_u/mz_8.unc ../artkos/mz_8.kos
koscmp ../artkos_u/NGHz_8.unc ../artkos/NGHz_8.kos
koscmp ../artkos_u/OOz_8.unc ../artkos/OOz_8.kos
koscmp ../artkos_u/SFz_8.unc ../artkos/SFz_8.kos
echo Compressing level blocks...
koscmp ../map16_u/CNz_16.unc ../map16/CNz_16.kos
koscmp ../map16_u/CPz_16.unc ../map16/CPz_16.kos
koscmp ../map16_u/DHz_16.unc ../map16/DHz_16.kos
koscmp ../map16_u/GHz_16.unc ../map16/GHz_16.kos
koscmp ../map16_u/mz_16.unc ../map16/mz_16.kos
koscmp ../map16_u/NGHz_16.unc ../map16/NGHz_16.kos
koscmp ../map16_u/OOz_16.unc ../map16/OOz_16.kos
koscmp ../map16_u/SFz_16.unc ../map16/SFz_16.kos
echo Compressing level chunks...
koscmp ../map128_u/CNz_128.unc ../map128/CNz_128.kos
koscmp ../map128_u/CPz_128.unc ../map128/CPz_128.kos
koscmp ../map128_u/DHz_128.unc ../map128/DHz_128.kos
koscmp ../map128_u/GHz_128.unc ../map128/GHz_128.kos
koscmp ../map128_u/mz_128.unc ../map128/mz_128.kos
koscmp ../map128_u/NGHz_128.unc ../map128/NGHz_128.kos
koscmp ../map128_u/OOz_128.unc ../map128/OOz_128.kos
koscmp ../map128_u/SFz_128.unc ../map128/SFz_128.kos
echo Compressing level layouts...
koscmp ../levels_u/CNz_Map1.unc ../levels/CNz_Map1.kos
koscmp ../levels_u/CNz_Map2.unc ../levels/CNz_Map2.kos
koscmp ../levels_u/CPz_Map1.unc ../levels/CPz_Map1.kos
koscmp ../levels_u/CPz_Map2.unc ../levels/CPz_Map2.kos
koscmp ../levels_u/DEz_Map.unc ../levels/DEz_Map.kos
koscmp ../levels_u/DHz_Map1.unc ../levels/DHz_Map1.kos
koscmp ../levels_u/DHz_Map2.unc ../levels/DHz_Map2.kos
koscmp ../levels_u/GHz_Map1.unc ../levels/GHz_Map1.kos
koscmp ../levels_u/GHz_Map2.unc ../levels/GHz_Map2.kos
koscmp ../levels_u/HTz_Map1.unc ../levels/HTz_Map1.kos
koscmp ../levels_u/HTz_Map2.unc ../levels/HTz_Map2.kos
koscmp ../levels_u/Mz_Map1.unc ../levels/Mz_Map1.kos
koscmp ../levels_u/Mz_Map2.unc ../levels/Mz_Map2.kos
koscmp ../levels_u/Mz_Map3.unc ../levels/Mz_Map3.kos
koscmp ../levels_u/NGHz_Map1.unc ../levels/NGHz_Map1.kos
koscmp ../levels_u/NGHz_Map2.unc ../levels/NGHz_Map2.kos
koscmp ../levels_u/OOz_Map1.unc ../levels/OOz_Map1.kos
koscmp ../levels_u/OOz_Map2.unc ../levels/OOz_Map2.kos
koscmp ../levels_u/SCz_Map.unc ../levels/SCz_Map.kos
koscmp ../levels_u/SFz_Map.unc ../levels/SFz_Map.kos
echo Compressing screen mappings...
enicmp ../mapeni_u/sega.unc ../mapeni/sega.eni
enicmp ../mapeni_u/SS_Map_0.unc ../mapeni/SS_Map_0.eni
enicmp ../mapeni_u/SS_Map_1.unc ../mapeni/SS_Map_1.eni
enicmp ../mapeni_u/titlescr.unc ../mapeni/titlescr.eni
enicmp ../mapeni_u/titscrb2.unc ../mapeni/titscrb2.eni
enicmp ../mapeni_u/titscrbg.unc ../mapeni/titscrbg.eni
enicmp ../mapeni_u/Vs_Menu.unc ../mapeni/Vs_Menu.eni
enicmp ../mapeni_u/Vs_SSRes.unc ../mapeni/Vs_SSRes.eni
enicmp ../mapeni_u/VsActRes.unc ../mapeni/VsActRes.eni
enicmp ../mapeni_u/VsAll_SS.unc ../mapeni/VsAll_SS.eni
enicmp ../mapeni_u/VsGblRes.unc ../mapeni/VsGblRes.eni
enicmp ../mapeni_u/VsLvlRes.unc ../mapeni/VsLvlRes.eni
enicmp ../mapeni_u/VsMenu2.unc ../mapeni/VsMenu2.eni
enicmp ../mapeni_u/VsMenuBg.unc ../mapeni/VsMenuBg.eni
cd..