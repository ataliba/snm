#!/bin/bash 
#set -x 
# SNM - Simple Network Monitor
# Versão 0.4a
# Mantenedor : Ataliba Teixeira < ataliba@ataliba.eti.br >  
####################################################
# Uso : 
# Script baseado em dica constante no site http://www.vivaolinux.com.br
# Inserir no seu crontab para testar de x em x minutos os servicos
# na sua rede de computadores. 
# Um aviso sera gerado todas as vezes que houver um servico estiver 
# offline no momento do teste 
# Ha dois modos de aviso, email e SMS, voce pode usar ambos ou somente
# um deles. 
####################################################
# Changelog : 
#
# 28/11/2008 
#  - Primeira versao publica do Software
#
####################################################
# LICENSA : GPLv2
####################################################
# 
# 


# LOCALIZACAO DOS COMANDOS ( MODIFICAR PARA OS PATHS DO SEU SISTEMA ) 
DATE=/bin/date
NETCAT=/bin/netcat
# Configure estas variáveis para os locais do seu sistema 
SNMDIR=./etc
CONFIG=$SNMDIR/snm.conf
ARQUIVO_LOOP=$SNMDIR/loop.lp
LOG=~/db/snm/monitoring.log
CEL="seunumero@suapoeradora.com.br"
EMAIL="seuemail@seudominio.com.brr"

# Nao modificar 
VERSAO="0.04a"
OPTIONS="-z -w 20 "

# funcoes principais do programa 

configura()
 {
    cd $SNMDIR
    for i in $(cat snm.conf); do 
	 HOST=$(echo $i | awk -F"|" '{print $1}')
     SERVICES=$(echo $i | awk -F"|" '{print $2}')

	 echo 1 > "$HOST-$SERVICES" 
	done
 }

SEND_MAIL () {
  
	echo -e "$TEXTO" | mail -s"$SUBJECT" $DISPARO

 }


run()
 {
   for i in $(cat $CONFIG); do
       
	   IMP=0
	   HOST=`echo $i | awk -F"|" '{print $1}'`
	   SERVICES=`echo $i | awk -F"|" '{print $2}'`
	   ARQUIVO_LOOP="$SNMDIR/$HOST-$SERVICES"
	   ARQUIVO_HORA="$SNMDIR/$HOST-$SERVICES-HORA"

	   $NETCAT $OPTIONS $HOST $SERVICES > /dev/null 2>&1
           
	   if [ $? != 0 ] ; then
              SUBJECT="$HOST OFFLINE"
              TEXTO="$HOST $SERVICES OFFLINE"
			  echo $TEXTO >> $LOG
			  

			  LOOP_ATUAL=$(cat $ARQUIVO_LOOP) 

			  ACTUAL_LOOP=$(expr $LOOP_ATUAL + 1)

			  echo $ACTUAL_LOOP > $ARQUIVO_LOOP
			  
			  if [ $LOOP_ATUAL -eq 1 ]; then 
				
				THORA=$($DATE +"%Y-%m-%d %H:%M:%S" )

				$DATE +%s -d "$THORA" >  $ARQUIVO_HORA

			    if [ -n "$CEL" ]; then
			      DISPARO=$CEL
			      SEND_MAIL
		        fi

			    if [ -n "$EMAIL" ]; then
			      DISPARO=$EMAIL
				  SEND_MAIL
		        fi
			  fi	

	   else
		  SUBJECT="$HOST ONLINE"
		  LOOP_ONLINE=$(cat $ARQUIVO_LOOP)
#		  MINUTOS=$(echo "$LOOP_ONLINE * $CRONTIME" | bc)
          
		  TTEXTO="$HOST $SERVICES ONLINE"

		  if [ $LOOP_ONLINE -gt 1 ]; then
		     
			 TT1=$(cat $ARQUIVO_HORA)
			 TTT2=$($DATE  +"%Y-%m-%d %H:%M:%S")
			 TT2=$($DATE  +%s -d "$TTT2")
			
			 IMP=1

			 SEC=$(expr $TT2 - $TT1)
			 
			 MIN=$(($SEC/60))
			 SEC=$(($SEC-$MIN*60))
			 HOR=$(($MIN/60))
			 MIN=$(($MIN-$HOR*60))

			 TEMPO="$HOR:$MIN:$SEC"

			 TEXTO="$TTEXTO ( OFFLINE POR $TEMPO )"

		     if [ -n "$CEL" ]; then
			   DISPARO=$CEL
			   SEND_MAIL
			 fi
			 if [ -n "$EMAIL" ]; then
			   DISPARO=$EMAIL
			   SEND_MAIL
			 fi
			echo 1 > $ARQUIVO_LOOP
			echo $TEXTO >> $LOG
		  fi
		  
		  if [ $IMP -eq 0 ]; then
		    echo $TTEXTO >> $LOG
		  fi	
       fi

		   
   done
 }	 
	 

# corpo principal do programa 

case $1 in 
 configura)
   configura
   ;;
 *)
   run
   ;;
esac   

########################
#  EOF #################
########################

