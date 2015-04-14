# OWNCLOUD-TimeMachine
Script aims to provide a unix-bash-integrated software component for a live synchronization (time-machine or mirroring) of a one-level folder and an entire partitions. The final synch method defined in the ROADMAP is a native synch with owncloud server.

At now we are in an initial developing phase, then it offer only ssh synch.

The script wants to be and remain just a wrapper over some basic thecnologies such as: 

inotify tool: https://github.com/rvoicilas/inotify-tools/wiki
unison file synchronizer: http://www.cis.upenn.edu/~bcpierce/unison/

and some very useful open source code, such as:
ansi-color: https://github.com/ali5ter/ansi-color

The script wants to be a stryctly integration between inotify+unison vs OWNCLOUD server. 

For such reason the name of a unison profile represents the script' parameter.


##Installation:

##settings:

##Usage:
Mandatory: define and configure a Unison profile.
The unison parameter FORCE is mandatory.
```
/path/to//OWNCLOUD-TimeMachine/timeMachineLib.sh "UNISON PROFILE"
```
##Logging: 
The script at now write on local File system 2 temporary files, which are:

A FIFO file type in 
```
    /tmp/"UNISON PROFILE"_pipe 
```    
and a logging file 
```
    /var/log/timeMachine/timemachine_"UNISON PROFILE".log
```    
