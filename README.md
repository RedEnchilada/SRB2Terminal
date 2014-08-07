SRB2Terminal
============

A netplay enhancement mod for SRB2. See http://mb.srb2.org/showthread.php?t=39392

This is considered the "working branch" of Terminal, and may contain errors. Use this version at your own risk. The latest stable version will always be available in the MB release thread, and is the recommended version to use or base changes on.


Instructions
============

Dedicated Servers
-----------------

Odds are you're hosting a dedicated server on Linux. Sweet! 2.1.10's Linux builds haven't been compiled yet, so it might be a good idea to compile it yourself using [this guide.](http://wiki.srb2.org/wiki/Source_code_compiling)

1. Extract the file above into any directory of your choosing, remember to set proper permissions on it as well (I recommend using <code>chmod -R 775</code> on the whole folder)
6. Make sure all of SRB2's content files (srb2.srb, rings.dta, player.dta, patch.dta) are in that same directory.
9. Bring all of Terminal's files, including the txt files, into the directory as well.
36. <code>cd</code> to the directory and run the game using <code>./lsdlsrb2 -dedicated</code>
2. <code>exec loadall.txt</code>, or manually load whichever modules you want (make sure to load Terminal_Core.lua first)

If you're hosting on a Windows dedicated server, the process will be similar to that of non-dedicated servers. 

Non-dedicated Servers
---------------------

1. Extract Terminal files to your SRB2 folder
2. Host the server
3. <code>exec loadall.txt</code> in the console, or manually load whichever modules you want(make sure to load Terminal_Core.lua first)

If you find any issues with hosting, make sure to tell us about them. After Terminal is up and running, you can use <code>term_help</code> in the console to bring up a help dialog that will cover basic use of the mod.
