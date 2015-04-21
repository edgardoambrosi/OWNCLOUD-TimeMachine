# OWNCLOUD-TimeMachine
Script aims to provide a unix-bash-integrated software component for a live synchronization (time-machine or mirroring) of a one-level folder and an entire partitions. The final synch method defined in the ROADMAP is a native synch with owncloud server.

At now we are in an initial developing phase, then it offer only ssh synch.

The script wants to be and remain just a wrapper over some basic thecnologies such as: 

inotify tool: https://github.com/rvoicilas/inotify-tools/wiki
unison file synchronizer: http://www.cis.upenn.edu/~bcpierce/unison/

and some very useful open source code, such as:
ansi-color: https://github.com/ali5ter/ansi-color

The script wants to be a stryctly integration between inotify+unison+csync vs OWNCLOUD server and all remote ssh/rsh storages. 

For such reason the name of a unison profile represents the script' parameter.

The unison profile is used more widely over the runtime of the script.

##Installation:

##settings:

##Usage:
Mandatory: Must be define and configure a Unison profile.
The unison parameter FORCE is mandatory as well as an IGNORE must be provided for the following files:
```
.csync_journal.db.ctmp and  .csync_journal.db
```
That is, when the sync activity is versus OWNCLOUD server we do not want to monitor and sync the above files.

```
/path/to//OWNCLOUD-TimeMachine/timeMachineLib.sh "UNISON PROFILE"
```
##Logging: 
The script writes on local file system 2 temporary files, which are:

A FIFO file type located in /tmp folder 
```
    /tmp/"UNISON PROFILE"_pipe 
```    
and a logging file 
```
    /var/log/timeMachine/timemachine_"UNISON PROFILE".log
```    
