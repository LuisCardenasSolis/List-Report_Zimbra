#!/bin/bash

PATH_REPORT="/tmp/report_list"

if [ ! -d "$PATH_REPORT" ]; then
    mkdir $PATH_REPORT
fi

ZMPROV="/opt/zimbra/bin/zmprov"

LISTS=$($ZMPROV gadl)

for list_name in $LISTS
do
  echo  "============= LISTA : $list_name ============"

  CONTADOR=0

  ACCOUNTS=$($ZMPROV gdl $list_name members | grep -Ev '(^$|^#|members)')
  FILE_PATH="${PATH_REPORT}/${list_name%@*}-${list_name#*@}.csv"

  echo "#,Cuenta,Nombre y Apellidos" | tee -a $FILE_PATH
  for account in $ACCOUNTS
  do
    ((CONTADOR++))

    name_account=$( $ZMPROV ga $account displayName | grep -Ev '(^#|^$)'| sed 's/displayName: //')

    echo "${CONTADOR},${account},${name_account}" | tee -a $FILE_PATH
  done

  echo -e "\n"
done

echo "REPORTE GUARDADO EN : ${PATH_REPORT}/"