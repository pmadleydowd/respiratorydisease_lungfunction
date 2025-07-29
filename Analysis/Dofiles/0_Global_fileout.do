********************************************************************************
* Author: 		Paul Madley-Dowd 
* Date: 		14 Feb 2025
* Description: 	Define file paths and create folders
********************************************************************************
* Set project directory 
global Projectdir "PROJECTDIRECTORY"

* Set other directories	
global Datadir 	 "$Projectdir\Data"
global Rawdatdir "ORIGINALDATADIRECTORY"
global Dodir 	 "$Projectdir\Dofiles"
global Logdir 	 "$Projectdir\Logs"
global Graphdir  "$Projectdir\Graphs"
global Outdir    "$Projectdir\Output"


* Set working directory
cd "$Projectdir"