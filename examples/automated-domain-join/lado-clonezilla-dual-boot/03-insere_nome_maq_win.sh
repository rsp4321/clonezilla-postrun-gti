#!/bin/bash

# script para inserir o nome da máquina num arquivo de configuração dentro do windows (na c:\conf-gti)
# para ser lido pelo script de renomeação quando dar boot no windows

# gerar o nome da máquina

# definindo o prefixo a partir de um arquivo de config.
#prefixo=l4
prefixo=`cat /usr/share/drbl/postrun/ocs/prefixo.conf`

# o ID será gerado pelo script 01-gera_id_maq
id_maquina=`cat /tmp/num_maq.conf`

# Isolando o nº da partição raíz para facilitar a mudança na matriz
#id_particao=4 # para matriz dual boot
id_particao=3 # para matriz single boot

# montar a partição do windows

# Verificando se está usando um SSD NVMe pois o device é diferente
#if [ -f /dev/nvme0n1p$id_particao ]; then

# Por ser um arquivo especial de dispositivo de bloco, o parâmetro de comparação é diferente
if [ -b /dev/nvme0n1p$id_particao ]; then

	#echo "entrou no if do nvme"
	#read


    mount -t ntfs-3g /dev/nvme0n1p$id_particao /mnt/

else
	#echo "entrou no else"
	#read

    mount -t ntfs-3g /dev/sda$id_particao /mnt/
fi

#mount -t ntfs-3g /dev/sda$id_particao /mnt/

# definindo o hostname
echo "${prefixo}m${id_maquina}" > /mnt/conf-gti/hostname.conf

umount -l /mnt/
