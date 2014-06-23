SRB2Terminal
============

A netplay enhancement mod for SRB2. See http://mb.srb2.org/showthread.php?t=39392

This is considered the "working branch" of Terminal, and may contain errors. Use this version at your own risk. The latest stable version will always be available in the MB release thread, and is the recommended version to use or base changes on.

**This branch has been modified to use functions that are unavailable in the current SRB2 release. Do not attempt to use this for your dedicated servers until 2.1.9 or the next update comes out.**

Instructions
============

Dedicated Servers
-----------------

Odds are you're hosting a dedicated server on Linux. Sweet! Too bad the current builds are broken for dedicated servers. If you wanna host a dedicated server on Linux, you should probably use [this build if anything](http://lightdash.org/SRB2/misc/lsdlsrb2), since we've fixed the SDL code here (tested on Debian 7/Wheezy 32-bit and 64-bit - [source code here.](http://lightdash.org/SRB2/misc/linuxsrb2-fixed.zip))

1. Extract the file above into any directory of your choosing, remember to set proper permissions on it as well (I recommend using chmod -R 775 on the whole folder)
6. Make sure all of SRB2's content files (srb2.srb, rings.dta, player.dta, patch.dta) are in that same directory.
9. Bring all of Terminal's files, including the txt files, into the directory as well.
36. <code>cd</code> to the directory and run the game using <code>./lsdlsrb2 -dedicated</code>
2. <code>exec loadall.txt</code>, or manually load whichever modules you want (make sure to load Terminal_Core.lua first)
8. If logins aren't working, use the console command <code>iamtheserver</code> to remind Terminal that you're hosting dedicated, or alternatively, wait a minute.

If you're hosting on a Windows dedicated server, the process will be similar to that of non-dedicated servers. Make sure to use <code>iamtheserver</code> after the files are loaded, as Terminal dedicated servers don't work without it.

Non-dedicated Servers
---------------------

1. Extract Terminal files to your SRB2 folder
2. Host the server
3. <code>exec loadall.txt</code> in the console, or manually load whichever modules you want(make sure to load Terminal_Core.lua first)

If you find any issues with hosting, make sure to tell us about them. After Terminal is up and running, you can use <code>term_help</code> in the console to bring up a help dialog that will cover basic use of the mod.
