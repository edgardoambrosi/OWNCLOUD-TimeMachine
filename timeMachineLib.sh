#!/bin/bash
#DOCUMENTAZIONE:
#CARATTERISTICA:ridirezionare, formattare e filtrare opportunamente i log sia di inotify che di unison
#CARATTERISTICA:utilizzare completamente le informazioni presenti nel profilo unison per estrapolare i parametri anche per inotifywait,

#DIPENDENZE: 
#inotify, unison, ansi-color, csync-owncloud

#UTILIZZO: esempio di come si esegue il presente script è il seguente:
#		-	/home/ambrosi/Desktop/DROPBOX/Dropbox/Scripts/timeMachineLib.sh alfrescodev /home/ambrosi/Desktop/AmbienteSviluppo/AlfrescoDev/ 30
#ATTENZIONE: Per usare questo script bisogna aver prima creato opportuni profili unison

#ROADMAP:
#OBIETTIVO: finale è quello di realizzare una time machine per owncloud, ma forse anche per altri cloud-storage
#TODO:usare logrotate per settare la rotazione dei log di unison. vedere i profili per sapere dove sono scritti i log.
#TODO:creare una interfaccia grafica per le impostazioni, ad esempio una utile opzione potrebbe essere la seguente:
#			  - quando unison dice che non riesce a sincronizzare un file, si potrebbe offrire la possibilità con un click di metterlo fra quelli non monitorati da inotify e non sincronizzati da unison
#TODO:Scrivere una documentazione accurata su come sono combinati unison e inotifywait e sulla logica dello script,

#NOTA: La seguente linea significa che ridirieziono lo stderr su lo stdout 2>&1 e lo stout 1> del presente script sul processo di subshell che apro con () e che ha in esecuzione il comando cat dallo stdinput - che appende sul file /var/log/timeMachine/timemachine.log.
#Questo comando unito con la sintassi >/dev/null 2>&1 appesa alla escuzione del presente script es:
#/path/to/timeMachineLib.sh alfrescodev /home/ambrosi/Desktop/AmbienteSviluppo/AlfrescoDev/ 30 >/dev/null 2>&1
#fa si che tutto il logging venga ridirottato sul file specificato.
#http://urbanautomaton.com/blog/2014/09/09/redirecting-bash-script-output-to-syslog/
#prelevo il nome di questo script e lo passo allo script di logging che lo usera come TAG


BASENAME=$(dirname $0)
THIS_NAME=$(echo $(basename $0))
if [ ! -z "$1" ]
then
	exec 1> >($BASENAME/logging/loggingLib $THIS_NAME $1) 2>&1
else
	echo 'Utilizzo: "/path/to/timemachineLib.sh \"profilo\"'
	exit
fi

echo PID OF $THIS_NAME is: $$

#*****************UTILITA' PER FORMATTARE IL TESTO******************************
#http://code.google.com/p/ansi-color/
#examples: 
#warn "EDGARDO"
#err "EDGARDO"
#info "EDGARDO"
####################################################
source $BASENAME/ansi-color/echoColor.sh

unset pipe
unset PID_INTERVALLO
unset profilo 
unset path
unset owncloud_path
unset force
unset interval
unset excludeWatch

profilo=$1
path=""
owncloud_path=""
force=""
interval="" 
excludeWatch=""

UNISON_COMMAND="$(which unison) $profilo"
CSYNC_OWNCLOUD_COMMAND="$(which csync)"
SYNC_TOOL=""

pipe=/tmp/$profilo'_pipe'
trap "rm -f $pipe" EXIT
PID_INTERVALLO=""

function checkParameters {
	if [ -z "$profilo" ];
	then 
		info 'Utilizzo: "/path/to/timemachineLib.sh \"profilo\"'
		exit
	fi
	if [ -z "$force" ];
	then
		info 'Utilizzo: parametro \"force\" deve essere presente nel profilo unison'
		exit
	fi
	if [ -z "$interval" ];
	then
		info 'Utilizzo: parametro \"repeat\" deve essere presente e commentato nel profilo unison'
		exit
	fi
}

function readingUnisonProfile {
	SYNC_TOOL=$UNISON_COMMAND
	for i in `cat $(locate $profilo.prf)|grep ignore|sed 's/\(.*Path\)//g'`;
	do 
		excludeWatch=$excludeWatch' --exclude '$i
	done
	for i in `cat $(locate $profilo.prf)|grep ignore|sed 's/\(.*Name\)//g'`;
	do 
		excludeWatch=$excludeWatch' --exclude '$i
	done
	for i in `cat $(locate $profilo.prf)|grep force|sed 's/\(.*force\s*=\s*\)//g'`;
	do 
		force=$i
		path=$i
		break
	done
	for i in `cat $(locate $profilo.prf)|grep owncloud|sed 's/\(.*root\s*=\s*\)//g'`;
	do
		owncloud_path=$i
		SYNC_TOOL=$CSYNC_OWNCLOUD_COMMAND  -v $force $owncloud_path
	done
	for i in `cat $(locate $profilo.prf)|grep repeat|sed 's/\(.*repeat\s*=\s*\)//g'`;
	do 
		interval=$i
		break
	done
}

function clear_pipe {
	if [[ ! -p $pipe ]]; then
		echo
	else 
		rm $pipe
	fi
}

function pipe_exists {
	if [[ ! -p $pipe ]]; then
		#sostituisce il return
		echo false
	fi
}

function setInterval {
	last_event=$1
	last_event_date=$(date -d @$last_event)
	info "Chiusura sincronizzazione resettata da nuovo evento avvenuto il $last_event_date"
	survival_time="0"
	while [ "$survival_time" -lt "$interval" ];do
		survival_time=$(expr $(date +"%s") - $last_event|tr -d -)
		echo -ne "attendo $(warn $interval) secondi prima di sincronizzare ultimo evento: $(err $survival_time)...\r"
	done
	#arrivato il timeout di n secondi eseguo il comando
	echo 
	info "...avvio chiusura sincronizzazione."
	$SYNC_TOOL
}

function clearInterval {
	PID=$1
	if [ "$PID" == "" ];then return;fi
	kill $PID	
}

#la funzione attua serve a leggere dalla pipe il timestamp dell'evento rilevato da inotify ed avviare la sincronizzazione
#la funzione esce quando legge dalla pipe "quit"
function attua {

	if [[ $(pipe_exists) == false ]]
	then
		mkfifo $pipe
	fi

	echo -ne "Avvio fase di sincronizzazione sul path: " $(warn "$path...")'\n'
	
	unset time_ev 
	unset time_ev_pre
	unset last_sync
	unset line 
	unset timespent

	#inizializzo timestamp	ultima sincronizzazione
	last_sync=$(date +"%s")

	while true
	do
		if read line <$pipe; then
		    if [[ "$line" == 'quit' ]]; then
		        break
		    fi
			#calcolo il timestamp attuale
			time_ev=$line
	        #con tr -d - tolgo il segno - se c'e'
  		    timespent=$(expr $time_ev - $last_sync|tr -d -)

 			if [ "$timespent" -gt "$interval" ];then 
				echo "Sono trascorsi  $(err $timespent) secondi dalla ultima sincronizzazione"
				$SYNC_TOOL
				last_sync=$(date +"%s")
				continue
			fi
			
			#avvio intervallo per sincronizzare ultimo evento
			clearInterval $PID_INTERVALLO
			#setInterval $time_ev>/dev/null 2>&1&
			setInterval $time_ev &  
			PID_INTERVALLO=$!
		fi	
	done
	rm $pipe	
}


#la funzione di notifica serve a immettere nella pipe il timestamp dell'evento sul FS rilelevato da inotify
function notifica {
	echo $BASHPID
	echo -ne "Avvio monitoraggio FS: " $(warn "$path...")'\n'

	if [[ $(pipe_exists) == false ]]
	then 
		echo Monitoraggio FS: $(err $path) non avviato, quindi esco!
		exit
	fi
	
	exclude=$excludeWatch

	#attenzione lo switch -r in inotifywait deve essere tolto quando si usa lo swith --exclude. la semantica di exclude quando viene utilizzato è:
	#guarda tutto tranne quello che viene escluso.
	if [ ! -z "$exclude" ];then 
		inotifywait -m $exclude  $path|
		while read event
		do
				if [[ $(pipe_exists) == false ]]
				then 
					err "Fine monitoraggio FS!"
					break
				else
					timestamp=$(date +"%s")
					echo $timestamp >$pipe
				fi
		done 
	fi
	if [ -z "$exclude" ];then 
		inotifywait -m -r  $path|
		while read event
		do
				if [[ $(pipe_exists) == false ]]
				then 
					err "Fine monitoraggio FS!"
					break
				else
					timestamp=$(date +"%s")
					echo $timestamp >$pipe
				fi
		done 
	fi

}


clear_pipe
readingUnisonProfile
checkParameters
attua&
sleep 5
notifica




