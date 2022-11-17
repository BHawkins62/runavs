### 	Runavs : Julia program to launch avatars in Second Life

######     ***This program has been written and tested for Microsoft Windows only***

Main Features:    setup feature to choose a single environmental variable for a common password for all avatars (or not) and directories for the SL viewers (SecondLifeViewer and Radegast viewer);   menu to choose manually entry or read from csv files;   ability to delay launch to a specific time

------

Requirements:

- Both Second Life and Radegast viewers installed.
- Install the Julia Language:   ***https://julialang.org/downloads/***
- Clone or download all the source code for the program
- Add the ***ConfParser*** Julia package into the same directory you have downloaded the ***runavs.jl*** program.   In a terminal:  change to the correct directory;  type ***julia*** to start the Julia REPL program; press the ***]*** to go into the Julia package manager, then type ***add ConfParser***.  After it's installed, you can press ***ESC*** then ***Ctrl-D*** to exit the Julia REPL.
- If you have only one password for all your avatars, you can set an environmental variable in Windows with the password (default is ***SLP***, but you can use a name of your preference)
- Run setup to view and change if necessary the following, by typing in a terminal:  ***julia runavs.jl setup***  All settings require ***Y*** to change or ***N*** to not change 
  - current setting to use an environment variable (default: ***true***)
  - current key for environment variable (default: ***SLP***)
  - current directory of secondlifeviewer.exe (default: ***C:/Program Files/SecondLifeViewer/***)
  - current directory of radegast.exe (default: ***C:/Program Files/Radegast/***)
- If you are going load csv files to load multiple avatars, then make sure to
  - create your csv files with one column of avatar names (therefore one avatar name per line) if you are using a common password supplied by the environment variable, or
  - create your csv files with two columns, one of avatar names and the other of passwords(therefore each line will have an avatar name followed by a password separated by a comma, for example: ***Myname, mypassword***)
  - Note: If your avatar name has a last name of ***Resident***, you can chose not to enter ***Resident*** and the program will take add it if required)

To run this program:

- Set environment variable "SLP" to your one password 
- Install the Julia Language:   https://julialang.org/downloads/
- Run  the script in a terminal as follows:  *julia runavs.jl*  

![](menu.JPG)

The script also has a command-line switch if you need to delay the launch of your avatars.   It takes a 5 digit code for hour:minute based upon the 24 hour clock of your location.

Examples:

***julia runavs.jl 11:33***

***julia runavs.jl 18:09***

***julia runavs.jl 09:55***



**Caution:   Do not exit the program until you are ready to logoff your avatars.  If you want to open additional avatars, open another instance of a terminal. (Microsoft Windows Terminal allows this with addition tabs)**

