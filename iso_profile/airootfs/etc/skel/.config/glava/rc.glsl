/* ╔══════════════════════════════════════════════════════════════════════╗
   ║  SPIDER'S LAB — GLava Main Config                                  ║
   ║  Tactical sonar embedded in the desktop background                 ║
   ╚══════════════════════════════════════════════════════════════════════╝ */

/* Request a specific module: radial */
#request mod radial

/* Audio source — PulseAudio default monitor */
#request setpulseaudio default

/* Window hints for Hyprland background embedding */
#request setdecorated  false
#request setfloating   true
#request setgeometry   0 0 1920 1080
#request setxwintype   "desktop"
#request setframerate  30
#request setsupersampling 1

/* Transparent background — we embed into the wallpaper */
#request setbg #00000000

/* Force behind other windows */
#request setforcegeometry true
