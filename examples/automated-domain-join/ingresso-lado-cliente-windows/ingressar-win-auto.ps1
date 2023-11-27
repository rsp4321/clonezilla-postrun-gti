# Script para ingressar a máquina por um arquivo de conf.

function Emitir-Log {
    param (
        $sufixo_arquivo,
        $msg
    )

    # verificando se existe a pasta de logs e criando ela
    if (!(Test-Path c:\logs-gti)) {

        New-Item -Path "c:\" -Name "logs-gti" -ItemType "directory"
        #Get-Acl -Path "C:\Program Files" | Set-Acl -Path "C:\logs-gti"
    }

    $saida_log = ('[' + $(get-date -Format "dd/MM/yyyy HH:mm") + '] ' + $msg )
    echo $saida_log >> ('c:\logs-gti\script-' + $sufixo_arquivo + $(get-date -Format yyyyMMdd) + '.log')
}

$SUFIXO_ARQUIVO = "ingressar-win-auto_"

$DOMINIO="SEU_DOMINIO"
$DOMINIO_COMPLETO="SEU_DOMINIO_FQDN"
$SENHA = "SUA_SENHA"
#$SENHA = "123abc"
# o usuário é o "script.ingresso" só pra constar

Emitir-Log -sufixo_arquivo $SUFIXO_ARQUIVO -msg "Iniciando a execução do script..."


# verificar se já foi ingressado por uma flag de conf.

if (Test-Path 'C:\conf-gti\ingressado.conf-flag') {
    
    Emitir-Log -sufixo_arquivo $SUFIXO_ARQUIVO -msg "Micro já ingressado. Abortando..."
    exit
}


Emitir-Log -sufixo_arquivo $SUFIXO_ARQUIVO -msg "Lendo o hostname no arquivo de configuração..."


if ( !(Test-Path 'C:\conf-gti\hostname.conf') ) {
    
    Emitir-Log -sufixo_arquivo $SUFIXO_ARQUIVO -msg "Arquivo c:\conf-gti\hostname.conf não encontrado. Abortando..."
    exit
}

$HOSTNAME = Get-Content -Path C:\conf-gti\hostname.conf

# verificar se já foi renomeado por um arquivo de conf.

if ( !(Test-Path 'C:\conf-gti\renomeado.conf-flag') ) {
    
    #Emitir-Log -sufixo_arquivo $SUFIXO_ARQUIVO -msg "Micro não renomeado. Abortando..."
    #exit

    Emitir-Log -sufixo_arquivo $SUFIXO_ARQUIVO -msg "Micro não renomeado. Renomeando e reiniciando..."
    
    Rename-Computer $HOSTNAME

    New-Item -Path "c:\conf-gti" -ItemType File -Name "renomeado.conf-flag"

    shutdown /r /t 0

}


# fazer um loop com um delay de 10 min pra subir a rede

do {

    Emitir-Log -sufixo_arquivo $SUFIXO_ARQUIVO -msg "Fazendo um delay de 1 min para subir a rede..."
    Start-Sleep -Seconds 60


    # ingressar a máquina e verificar o ingresso
    # caso negativo continuar o loop

    Emitir-Log -sufixo_arquivo $SUFIXO_ARQUIVO -msg "Ingressando no domínio..."


    # código sugerido pelo artigo de suporte da microsoft: 
    # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/add-computer?view=powershell-5.1

    #$joinCred = New-Object pscredential -ArgumentList ([pscustomobject]@{
        
    #    UserName = "script.ingresso"
        #UserName = "DOMINIO\script.ingresso"
        #UserName = $null

        #Password = (ConvertTo-SecureString -String $SENHA -AsPlainText -Force)[0]
        #Password = (ConvertTo-SecureString -String "$SENHA" -AsPlainText -Force)[0]
    #    Password = (ConvertTo-SecureString -String '$SENHA' -AsPlainText -Force)[0]
    #})

    #$joinCred = New-Object System.Management.Automation.PsCredential("script.ingresso", (ConvertTo-SecureString -String $SENHA -AsPlainText -Force) )

    #Add-Computer -Domain "Domain03" -Options UnsecuredJoin,PasswordPass -Credential $joinCred
    #Add-Computer -Domain "DOMINIO" -Options UnsecuredJoin,PasswordPass -Credential $joinCred
    #$resultado_ingresso = Add-Computer -Domain DOMINIO -Options UnsecuredJoin,PasswordPass -Credential $joinCred -PassThru
    #$resultado_ingresso = Add-Computer "DOMINIO" -Options UnsecuredJoin,PasswordPass -Credential $joinCred
    #$resultado_ingresso = Add-Computer "DOMINIO_COMPLETO" -Options UnsecuredJoin,PasswordPass -Credential $joinCred

    #$resultado_ingresso = Add-Computer "DOMINIO_COMPLETO" -Options UnsecuredJoin -Credential $joinCred

    #$resultado_ingresso = Add-Computer "DOMINIO" -Options UnsecuredJoin -Credential $joinCred -PassThru
    #$resultado_ingresso = Add-Computer -Credential $joinCred -DomainName "DOMINIO" -Options UnsecuredJoin -PassThru
    #$resultado_ingresso = Add-Computer "DOMINIO" -Unsecure -Credential $joinCred -PassThru
    #$resultado_ingresso = Add-Computer "DOMINIO" -Options UnsecuredJoin -Unsecure -Credential $joinCred -PassThru
    #$resultado_ingresso = Add-Computer -Credential $joinCred -DomainName "DOMINIO" -Unsecure -Options UnsecuredJoin -PassThru

    # Criando uma string mais segura necessária para criar o objeto da credencial
    #$secure_password = ConvertTo-SecureString -String '$SENHA' -AsPlainText -Force
    $secure_password = ConvertTo-SecureString -String "$SENHA" -AsPlainText -Force

    #$joinCred = New-Object System.Management.Automation.PSCredential ("DOMINIO\script.ingresso", $secure_password)
    $joinCred = New-Object System.Management.Automation.PSCredential (( $DOMINIO + '\script.ingresso' ), $secure_password)

    # Para usar credenciais de usuário, não é necessário fazer um ingresso considerado não seguro (unsecured join)
    #$resultado_ingresso = Add-Computer "DOMINIO_COMPLETO" -Credential $joinCred -PassThru

    # Usando o parâmetro -NewName para já renomear automaticamente sem precisar de um novo reboot
    #$resultado_ingresso = Add-Computer "DOMINIO_COMPLETO" -Credential $joinCred -PassThru -NewName $HOSTNAME

    # Ingressando já com o micro renomeado e reiniciado para corrigir um bug do samba a princípio
    # onde ele registra alguns campos da conta de máquina com o hostname atual da máquina gerando falhas de acesso ao BD de segurança ao logar com usuário de rede
    $resultado_ingresso = Add-Computer $DOMINIO_COMPLETO -Credential $joinCred -PassThru


    # Com o parâmetro "-PassThru", o comando retorna um objeto que possui a propriedade "HasSucceded" booleana para indicar se houve sucesso no ingresso
    # Logo, fazendo a verificação para ver se mantém no loop
    if ( !($resultado_ingresso.HasSucceeded) ) {
        Emitir-Log -sufixo_arquivo $SUFIXO_ARQUIVO -msg "Falha ao ingressar. Tentando novamente..."
    }

} while ( !($resultado_ingresso.HasSucceeded) )

Emitir-Log -sufixo_arquivo $SUFIXO_ARQUIVO -msg "Ingressado com sucesso! Desativando a execução automática desse script..."

# caso positivo, criar uma flag de ingresso e remover da autoexecução se possível
New-Item -Path "c:\conf-gti" -ItemType File -Name "ingressado.conf-flag"

# Tentar desativar a tarefa agendada de execução no boot da máquina se possível
Disable-ScheduledTask -TaskName "ingressar-win-auto" -TaskPath "\gti\"


Emitir-Log -sufixo_arquivo $SUFIXO_ARQUIVO -msg "Desativada a execução automática com sucesso!"


# Tem que ver se é melhor já mandar desligar direto pra ligar apenas a amostra de testes ou deixar ligada.
# decidi desligar pois tem menos risco no final do expediente, uma vez que ele dificilmente desligará quando terminado

Emitir-Log -sufixo_arquivo $SUFIXO_ARQUIVO -msg "Desligando..."
#shutdown /r /t 0
shutdown /s /t 0
