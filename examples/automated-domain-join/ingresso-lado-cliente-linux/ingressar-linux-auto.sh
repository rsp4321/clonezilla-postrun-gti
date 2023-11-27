#!/bin/bash
# Usando o bash para ter suporte ao comando nativo "read"

# script para ingressar automaticamente o linux

# senha da credencial "script.ingresso" para ingresso automático no domínio
# lembrando que deve ser desativada a credencial depois do uso aqui
senha="SUA_SENHA"

# gerar um log avisando o delay

incluiNoLog( ) {

    #read   # para fazer um breakpoint para debug

    #if ![ -d /tmp/logs-gti/ ]; then
    #if [![ -d /tmp/logs-gti/ ]]; then
    #if  !-d /tmp/logs-gti/; then
    #if ![[ -d /tmp/logs-gti/ ]]; then
    #if [[![[ -d /tmp/logs-gti/ ]]]]; then
    if [ ! -d "/tmp/logs-gti" ]; then
    #if !( -d /tmp/logs-gti/ ); then

        mkdir /tmp/logs-gti/
    fi

    #echo $1 + \n > /tmp/modelo_hosts
    #echo "${1}\n" >> /tmp/modelo_hosts
    echo "[`date`] " >> /tmp/logs-gti/ingressar-linux-auto.log
    #echo -e "[`date`] " >> /tmp/logs-gti/ingressar-linux-auto.log
    
    #echo $1\n >> /tmp/logs-gti/ingressar-linux-auto.log
    #echo '$1\n' >> /tmp/logs-gti/ingressar-linux-auto.log
    #echo -e $1\n >> /tmp/logs-gti/ingressar-linux-auto.log
    #echo -e "$1\n\n" >> /tmp/logs-gti/ingressar-linux-auto.log
    echo -e "$1\n" >> /tmp/logs-gti/ingressar-linux-auto.log

    #echo $2 >> /tmp/modelo_hosts
}

#set -x  # para tentar habilitar debugging

incluiNoLog "Iniciando a execução do script..."
#pause

# Verificando se o script já está sendo executado
if [ -f /tmp/executando-ingresso-auto.conf-flag ]; then

    incluiNoLog "Script de ingresso já em execução. Saindo..."
    exit
fi


# Verificando se já tá ingressado pela flag
if [ -f /etc/conf-gti/ingressado.conf-flag ]; then

    incluiNoLog "Micro já ingressado. Saindo..."
    exit
fi

# Criando a flag de execução pra impedir execução repetida do mesmo pelo cron
touch /tmp/executando-ingresso-auto.conf-flag 

#set +x # para desabilitar o debugging

#incluiNoLog "Começando o delay de 10 min para subir a rede..."
#sleep 600

# verificando se o servidor samba tá on
#ping=`ping 172.16.50.43`
#
#if (ping)   # como o ping 

# como dá pra verificar se foi ingressado e dá fail logo se não conseguir comunicar com o samba,
# vamos ingressar direto

# fazer um loop para tentar ingressar e fazer um delay caso não consiga
# tem que sair do loop somente quando ingressar 
# ou talvez em x tentativas (para não parar um possível processamento de outros scripts agendados)


#resultado_ingresso="Joined"    # para debug apenas


#while saida_ingresso; do
#while $saida_ingresso; do
#while [ ! saida_ingresso ]; do
#while [ saida_ingresso ]; do
#while [ $saida_ingresso ]; do
#while [ ! -v resultado_ingresso ]; do
#while [ resultado_ingresso ]; do
#while [ $resultado_ingresso ]; do

# O resultado do ingresso é enviado ao terminal pela mensagem "Joined..."
# Logo, dentro do loop, vamos pegar a saída do comando de ingresso e verificar se há a palavra
# Se não tiver, a string será vazia. Daí, estamos usando como flag de saída do loop
# enquant a var. resultado_ingresso estiver vazia, refaça o loop tentando um novo ingresso
# Usando o operador "$var" para ele processar a string armazenada
#while [ -z $resultado_ingresso ]; do
while [ -z "$resultado_ingresso" ]; do

    incluiNoLog "Começando o delay de 1 min para subir a rede..."
    sleep 60

    # ingressando direto e guardando a saída para verificar
    incluiNoLog "Fazendo o ingresso no domínio..."
    saida_ingresso=`net ads join -U script.ingresso%$senha`

    # como ele mostra a palavra "Joined" para confirmar, filtrando com grep
    resultado_ingresso=`echo $saida_ingresso | grep "Joined"`

done

# Se houver ingresso, a saída filtrada não deverá ser vazia
# verificando isso
#if resultado_ingresso; then

# ingresso com sucesso
incluiNoLog "Ingressado com sucesso. Alterando a ordem do menu do grub..."


# alterando a ordem de boot do menu do GRUB
mv /etc/grub.d/21_os-prober /etc/grub.d/08_os-prober
update-grub

# criando a flag pra indicar o ingresso
if [ ! -d "/etc/conf-gti/" ]; then
    mkdir /etc/conf-gti
fi

touch /etc/conf-gti/ingressado.conf-flag

incluiNoLog "Ordem de boot alterada. Retirando da execução automática do cron..."

#if [ -f /etc/cron.daily/ingressar-linux-auto.sh ]; then
#    mv /etc/cron.daily/ingressar-linux-auto.sh /etc/cron.daily/ingressar-linux-auto.sh.disabled
#    chmod -x /etc/cron.daily/ingressar-linux-auto.sh.disabled

#if [ -f /etc/cron.hourly/ingressar-linux-auto ]; then
#    mv /etc/cron.hourly/ingressar-linux-auto /etc/cron.hourly/ingressar-linux-auto.disabled
#    chmod -x /etc/cron.hourly/ingressar-linux-auto.disabled
#fi

rm /etc/cron.d/gti-ingresso-auto-dominio

incluiNoLog "Desativada a execução automática do script no cron. Reiniciando..."

# excluindo a flag de execução
rm /tmp/executando-ingresso-auto.conf-flag 

systemctl reboot
#systemctl poweroff

#fi     # if resultado_ingresso;
