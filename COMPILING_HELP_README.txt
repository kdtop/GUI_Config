==================================
WorldVista Configuration Utility
-Notes about compiling the source
==================================
By Kevin Toppenberg
August 2008

This program was compiled with Delphi 7.

One of the most difficult things about getting someone else's project compiling in Delphi is getting all of the required components installed into Delphi first, and then getting all of the search paths and include paths set up properly.  Here are some general steps to get things running.  

1. Ensure that all the various CPRS controls are installed into Delphi 7.  These are the .dpk files found in the CPRS-Lib directory.  I will note here that I compiled this with a Delphi using older controls (those used for version 1.0.23.15).  You may get some complaints from Delphi about units being compiled with different version.  If so, you will have to work resolve these differences.  I can't tell you exactly how to do that.  I will note that we don't use any advanced features of the controls, so there should be no reason that this code can't be compiled with the new controls.

2. There are always problems with paths when moving a project from one computer to another.  You should review the Project Options --> Directories and convert any bad paths to the relevant path on your computer.  On our system, the project was stored at:
P:\Vista\GUI-config\
The files 'GUI_config.cfg', 'GUI_config.dof' are text files.  When I look at them, I see absolute file paths that won't be valid on another system.  I supposed they could be edited directly, though I supposed there is another way from inside Delphi that this is supposed to be done.

3. This program makes use of some propriatary code modules to allow skinning of the application (i.e. changing the appearance.)  The binaries are in *.dcu files.  These are stored in a .zip file in the SkinStuff folder.  See readme there.  NOTE: if you wish to remove this functionality from the program (and thus removing that aspect of the license and making it fully LGPL'd), then the compiler directive USE_SKINS should be removed from the Project Options --> Compiler directives.

4. I am on the message board at http://groups.google.com/group/Hardhats and will do what I can to help.
