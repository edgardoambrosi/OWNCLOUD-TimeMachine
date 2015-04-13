#*****************UTILITA' PER FORMATTARE IL TESTO******************************
#http://code.google.com/p/ansi-color/
#examples: 
# echo "$(color ul)Underlined text$(color off)"
# echo "Make $(color rv)this$(color nm) reverse video text"
# echo "$(color white blue) White text on a blue background $(color)"
# echo "$(color ltyellow green) lt prefix on the yellow text text $(color off)"
# echo "$(color bold red yellow blink) Blinking bold red text on a yellow background $(color)"
# IL COMANDO color deve essere linkato al seguente script /home/ambrosi/Desktop/DROPBOX/Dropbox/Scripts/ansi-color/color, nella /usr/sbin/color
####################################################

function colorList() { 
	color list
}

function err() { 
	echo `color bold red yellow ` $1 `color`
}
function info() {
	echo "$(color bold green ) $1 $(color)"
}
function warn() {
	 echo "$(color bold cyan ) $1 $(color)"
}

