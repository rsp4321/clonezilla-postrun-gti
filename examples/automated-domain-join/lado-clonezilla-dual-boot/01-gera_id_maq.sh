#!/bin/sh

# script para gerar o nº da máquina pelo hostname
# e exportar num arquivo de config.

#ip=`hostname -I`    # isso pega só os IPs atribuídos sem o localhost

# jogando num arquivo para facilitar o uso do sed
arq_ip=/tmp/arq_ip.conf
hostname -I > /tmp/arq_ip.conf

# Extrair o octeto usando o sed ou o awk


# substituir o '.' por \n e dar um "tail -1" para filtrar

#ip=`sed s/./\n/ $ip | tail -1`
#ip=`sed s/./\n/ $arq_ip | tail -1`
#sed s/"."/"\n"/ $arq_ip
#sed s/"*.*.*.*"/"*\n*\n*\n*"/ $arq_ip
#sed s/"\.*\.*\.*"/" * * *"/ $arq_ip

# Fonte: https://www.baeldung.com/linux/find-replace-text-in-file
#sed s/"\."/" "/g $arq_ip
num_maq=`sed s/"\."/"\n"/g $arq_ip | tail -1`

echo $num_maq > /tmp/num_maq.conf
