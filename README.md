# OWNCLOUD-TimeMachine
The script's scope is to provide a unix-bash-integrated software component for a live synchronization (time-machine) of a single one-level-folder and an entire partitions. The synch method in the ROADMAP is owncloud.
But since we are in an initial developing phase, at now this offers only ssh.

The script is just a very wrap-around for the basic thecnologies which are: 

inotify tool: https://github.com/rvoicilas/inotify-tools/wiki
unison file synchronizer: http://www.cis.upenn.edu/~bcpierce/unison/
ansi-color: https://github.com/ali5ter/ansi-color

The script wants to be a stryctly integration between inotify and unison, the the only parameter passed to the script is the name of a unison profile.
Since the script wants to be a live mirror, the unison parameter FORCE is mandatory.

Usage:
Mandatory: configuration of a Unison Profile.

/path/to//OWNCLOUD-TimeMachine/timeMachineLib.sh "UNISON PROFILE"
