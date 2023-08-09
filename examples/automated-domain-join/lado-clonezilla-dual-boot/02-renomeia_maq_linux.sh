#!/bin/sh

# script para colocar o prefixo do lab. nos arquivos de conf. para ingresso no domínio

# colocando temporariamente o prefixo e id da máquina para avançar nos testes
# tem que implementar o método depois
#$prefixo = 'l4'
#$id_maquina = '01'

#prefixo=l4
#prefixo=`cat /tmp/prefixo-lab.conf`
prefixo=`cat /usr/share/drbl/postrun/ocs/prefixo.conf`

#id_maquina=01
id_maquina=`cat /tmp/num_maq.conf`
#id_maquina=`cat /usr/share/drbl/postrun/ocs/num_maq.conf`

# Isolando o nº da partição raíz para facilitar a mudança na matriz linux
id_particao=5 # para matriz dual boot
#id_particao=2 # para matriz single boot

# função para adicionar no modelo de conf.
incluiNoModeloConf( ) {

    #echo $1 + \n > /tmp/modelo_hosts
    #echo "${1}\n" >> /tmp/modelo_hosts
    echo $1 >> /tmp/modelo_hosts
    #echo $2 >> /tmp/modelo_hosts
}

# Será usado o último octeto do IP atribuído temporariamente no clonezilla
#gerarIdMaquina() {

    # obter o mac da placa cabeada
    # pegar os 2 octetos finais
#}

# método para gerar um id único pra máquina a partir do mac

#colocar a conf. fixa antes
echo "127.0.0.1	localhost\n" > /tmp/modelo_hosts




#echo "127.0.1.1	rppc-teste.DOMINIO_COMPLETO rppc-teste" > /tmp/modelo_hosts
#incluiNoModeloConf ("127.0.1.1	" + $prefixo + "m" + $id_maquina + ".DOMINIO_COMPLETO" + $prefixo + "m" + $id_maquina)

#linha="127.0.1.1" + $prefixo + "m" + $id_maquina + ".DOMINIO_COMPLETO" + $prefixo + "m" + $id_maquina
#linha=("127.0.1.1" + $prefixo + "m" + $id_maquina + ".DOMINIO_COMPLETO" + $prefixo + "m" + $id_maquina)
linha="127.0.1.1 ${prefixo}m${id_maquina}-linux.DOMINIO_COMPLETO ${prefixo}m${id_maquina}-linux"
#linha="127.0.1.1\ ${prefixo}m${id_maquina}.DOMINIO_COMPLETO\ ${prefixo}m${id_maquina}"
#linha="127.0.1.1\b${prefixo}m${id_maquina}.DOMINIO_COMPLETO\b${prefixo}m${id_maquina}"
#linha="127.0.1.1\e${prefixo}m${id_maquina}.DOMINIO_COMPLETO\e${prefixo}m${id_maquina}"
#linha='127.0.1.1 ${prefixo}m${id_maquina}.DOMINIO_COMPLETO ${prefixo}m${id_maquina}'


# Para o interpretador não reconhecer os espaços como delimitadores de parâmetros pra função,
# tem que "envolver" dentro de uma string para formatar certinho

#incluiNoModeloConf $linha
#incluiNoModeloConf $(printf %q $linha)
#incluiNoModeloConf ${printf %q $linha}
#incluiNoModeloConf `printf %q ${linha}`
incluiNoModeloConf "$linha"


# final da conf. padrão
#echo "\# The following lines are desirable for IPv6 capable hosts" + \n > /tmp/modelo_hosts
#echo "::1     ip6-localhost ip6-loopback" + \n > /tmp/modelo_hosts

incluiNoModeloConf "\n\n# The following lines are desirable for IPv6 capable hosts"
incluiNoModeloConf "::1     ip6-localhost ip6-loopback"
incluiNoModeloConf "fe00::0 ip6-localnet"
incluiNoModeloConf "ff00::0 ip6-mcastprefix"
incluiNoModeloConf "ff02::1 ip6-allnodes"
incluiNoModeloConf "ff02::2 ip6-allrouters"


# fazendo a montagem da partição raíz para copiar as configs.
#mount -t ext4 /dev/sda$id_particao /mnt/

if [ -b /dev/nvme0n1p$id_particao ]; then

	#echo "entrou no if do nvme"
	#read


    mount -t ntfs-3g /dev/nvme0n1p$id_particao /mnt/

else
	#echo "entrou no else"
	#read

    mount -t ntfs-3g /dev/sda$id_particao /mnt/
fi

# copiando o arquivo hosts pronto pra partição 
cp /tmp/modelo_hosts /mnt/etc/hosts

# definindo o hostname
echo "${prefixo}m${id_maquina}-linux" > /mnt/etc/hostname

# desmontando para permitir montagem por outros scripts
umount -l /mnt/