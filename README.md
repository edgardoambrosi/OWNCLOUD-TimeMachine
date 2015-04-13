# OWNCLOUD-TimeMachine
The scrip scope is to realize a unix-bash-integrated software component to provide a live synchronization of a single one-level-folder and an entire partitions. The synch methods in the ROADMAP are ssh, davfs, owncloud.
Currently only ssh has been tested.

The script is just a very wrap-around for the basic thecnologies which are: 

inotify tool: https://github.com/rvoicilas/inotify-tools/wiki
unison file synchronizer: http://www.cis.upenn.edu/~bcpierce/unison/
ansi-color: https://github.com/ali5ter/ansi-color

Usage:
Mandatory: Configuraz
/path/to//OWNCLOUD-TimeMachine/timeMachineLib.sh "UNISON PROFILE"
