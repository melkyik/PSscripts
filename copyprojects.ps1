#скрипт копирует средствами PS. ничего расшаривать не надо. Пароли в переменных могут повторятся 
#обязательные команды на удаленной машине
#выполнить на удаленной машине
#Enable-PSRemoting
#set-item wsman:localhost\client\trustedhosts -value 10.10.0.252
#строчка выше не обязательна иногда
#Set-PSSessionConfiguration -Name Microsoft.PowerShell -showSecurityDescriptorUI необязательно но может пригодится.

#выполнить у нас под админской PS нижеприведенный скрипт. Он делает set-item wsman:localhost\client\trustedhosts -value  но с добавлением в конец. 
#на основной машине должно быть много ИП разрешенных на удаленной не обязательно.
#.\Add-TrustedHost.ps1 10.10.9.20
#проверка Enter-PSSession -ComputerName 10.10.9.21 -Credential (Get-Credential)
#или
#$cn = read-host 'ip?';  Enter-PSSession -ComputerName $cn -Credential (Get-Credential)

function DownloadProjectDirectory($inName, $url, $inlogin, $inPassword, $localpath, $targetpath)
{ 
$fPass = convertto-securestring -AsPlainText -Force -String $inPassword 
$fcred = new-object -typename System.Management.Automation.PSCredential -argumentlist $inlogin,$fPass


try {
if(!(Test-Path -Path $targetpath )){
    New-Item -ItemType directory -Path $targetpath
} 
Write-Host "Connecting $inName ip: $url"
$fsession = new-pssession -computername $url -credential $fCred
Write-Host "Downloading $inName ip: $url"
Copy-Item   $localpath -Destination $targetpath -Recurse -force  -FromSession $fsession  
}
catch {
.\SendTelegram.ps1 -message "Скрипт загрузки Проектов: 
 Ошибка загрузки проекта $inName ip: $Url"

Write-Host "COPY FAIL! $inName ip: $url"
}
}#конец функции

$pathcopyto="C:\BackupScripts\Projects\"


#вызов функции параметры  имя        ип          юзер    пароль       путь удаленной машины                 наш путь
#DownloadProjectDirectory "Внуково" 10.10.9.20 "admin" "123456789" "D:\Simple-Scada 2\Projects\vnukovo" $pathcopyto
DownloadProjectDirectory "Внуково BIG" 10.10.9.21 "iFarm" "123456789" "C:\Users\iFarm\Documents\Simple-Scada 2\Projects\vnukovo_big" $pathcopyto
#DownloadProjectDirectory "Николаева" 10.10.5.20 "iFarm" "123456789" "D:\Server\Simple-Scada 2\Projects\GreenSCADA" $pathcopyto
#DownloadProjectDirectory "Арбузова" 10.10.5.20 "iFarm" "123456789" "D:\Server\Simple-Scada 2\Projects\Arbuzova" $pathcopyto
DownloadProjectDirectory "Красноярск" 10.10.11.20 "iFarm" "123456789" "C:\Users\iFarm\Documents\Simple-Scada 2\Projects\kras200" $pathcopyto
#DownloadProjectDirectory "Подвал" 10.10.5.20 "iFarm" "123456789" "D:\Server\Simple-Scada 2\Projects\podval" $pathcopyto
DownloadProjectDirectory "Флакон" 10.10.7.20 "iFarm" "123456789" "C:\Users\iFarm\Documents\Simple-Scada 2\Projects\Msk" $pathcopyto
DownloadProjectDirectory "Иркутск" 10.10.8.20 "iFarm" "123456789" "C:\Users\iFarm\Documents\Simple-Scada 2\Projects\Irk" $pathcopyto
DownloadProjectDirectory "Финляндия" 10.10.4.20 "iFarm" "123456789" "C:\Users\iFarm\Documents\Simple-Scada 2\Projects\Fin" $pathcopyto
DownloadProjectDirectory "Швейцария" 10.10.12.20 "iFarm" "123456789" "C:\Users\iFarm\Documents\Simple-Scada 2\Projects\yasai" $pathcopyto
DownloadProjectDirectory "Миасс" 10.10.20.20 "iFarm" "123456789" "C:\Users\iFarm\Documents\Simple-Scada 2\Projects\miass" $pathcopyto
DownloadProjectDirectory "Этномир" 10.10.19.20 "iFarm" "123456789" "C:\Users\iFarm\Documents\Simple-Scada 2\Projects\Etnomir" $pathcopyto
#DownloadProjectDirectory "Лексус" 10.10.1.20 "operator" "123456789" "C:\Users\Operator\Documents\Simple-Scada 2\Projects\Lexus" $pathcopyto
#DownloadProjectDirectory "Лаба" 10.10.4.20 "iFarm" "123456789" "C:\Users\iFarm\Documents\Simple-Scada 2\Projects\Fin" $pathcopyto

#копируем исходники проектов
#DownloadProjectDirectory "ПЛК Арбузова" 192.168.88.237 "iFarm" "123456789" "D:\do_not_toch\IFarm\IFarmPrg\Source\codesys\*\*.pro"  "$pathcopyto\Codesys\Arbuzova"
DownloadProjectDirectory "ПЛК Николаева" 10.10.5.20 "iFarm" "123456789" "D:\!Project\Podval\*\*.pro" "$pathcopyto\Codesys\podval"

Write-Host "Downloading Cloud"  
if(!(Test-Path -Path "$pathcopyto\Cloud\" )){
   New-Item -ItemType directory -Path "$pathcopyto\Cloud\"
} 
Copy-Item  'C:\Users\Администратор.SERVER\Documents\Simple-Scada 2\Projects\' -Destination "$pathcopyto\Cloud\" -Recurse -force #локальный проект

$strdatetime =Get-Date -Format "yyyy-MM-dd HH-mm"
Compress-Archive -DestinationPath C:\ProjectsArchive\ProjectScada_$strdatetime -Path $pathcopyto\*



Remove-Item -Path $pathcopyto\* -recurse

