#!/bin/bash

PATH_REPORT="/tmp/report_list_$(date +%s)"

mkdir $PATH_REPORT

ZMPROV="/opt/zimbra/bin/zmprov"

if [ -z "$1" ]; then
	LISTS=$($ZMPROV gadl)	
elif [ $1 = "-l" ];then
	shift
	LISTS=$(echo "$1" | tr -d '[[:space:]]' | sed 's/,/ /g')
else
	echo "Parametros invalidos"
	exit 1
fi

for list_name in $LISTS;
do
echo  "============= LISTA : $list_name ============"

CONTADOR=0

ACCOUNTS=$($ZMPROV gdl $list_name members | grep -Ev '(^$|^#|members)')
FILE_PATH="${PATH_REPORT}/${list_name}.csv"

echo "#,Cuenta,Nombre y Apellidos,Tipo" | tee -a $FILE_PATH
	for account in $ACCOUNTS; 
	do
	CONTADOR=$((CONTADOR+1))
	
	name_account=$( $ZMPROV ga $account displayName 2>/dev/null | grep -Ev '(^#|^$)'| sed 's/displayName: //')
	if [ -z "${name_account}" ];then
		# Comprobar si es una lista
		$ZMPROV gdl $account &> /dev/null
		if [ $? != 0 ];then
		echo "${CONTADOR},${account},,CUENTA O LISTA NO EXISTENTE" | tee -a $FILE_PATH
		else
		echo "${CONTADOR},${account},,LISTA DE CORREO" | tee -a $FILE_PATH
		fi
	else
	echo "${CONTADOR},${account},${name_account},CUENTA DE CORREO" | tee -a $FILE_PATH
	fi
	
	done

echo -e "\n"
done

echo "REPORTE GUARDADO : ${PATH_REPORT}"
