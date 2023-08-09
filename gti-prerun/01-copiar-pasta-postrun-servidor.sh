#!/bin/sh

# script para copiar os scripts da pasta /tftpboot/gti-postrun/ 
# para o diretório postrun no live filesystem nos clientes
# o clonezilla não faz isso automaticamente

# copiar arquivo compactado via TFTP usando o busybox
# O IP normalmente atribuído ao servidor é o 192.168.169.250
#busybox tftp -l /tmp/gti-postrun.tar.gz -r gti-postrun.tar.gz 192.168.169.250
busybox tftp -l /tmp/gti-postrun.zip -r gti-postrun.zip -g 192.168.169.250

# extrair o arquivo na pasta /usr/shar/drbl/postrun/ocs/
#tar -zxvf gti-postrun.tar.gz /tmp/gti-postrun/
#cp /tmp/gti-postrun/* /usr/shar/drbl/postrun/ocs/

#unzip gti-postrun.zip -d /usr/share/drbl/postrun/ocs/
unzip /tmp/gti-postrun.zip -d /usr/share/drbl/postrun/ocs/

#dar permissão de execução
chmod +x /usr/share/drbl/postrun/ocs/*