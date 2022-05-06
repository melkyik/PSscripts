function DownloadFtpDirectory($url, $credentials, $localPath)
{
if(!(Test-Path -Path $localPath )){
    New-Item -ItemType directory -Path $localPath
}
    $listRequest = [Net.WebRequest]::Create($url)
    $listRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectoryDetails
    $listRequest.Credentials = $credentials

    $lines = New-Object System.Collections.ArrayList
try{
    $listResponse = $listRequest.GetResponse()
    $listStream = $listResponse.GetResponseStream()
    $listReader = New-Object System.IO.StreamReader($listStream)
    while (!$listReader.EndOfStream)
    {
        $line = $listReader.ReadLine()
        $lines.Add($line) | Out-Null
    }
    $listReader.Dispose()
    $listStream.Dispose()
    $listResponse.Dispose()

    foreach ($line in $lines)
    {
        $tokens = $line.Split(" ", 9, [StringSplitOptions]::RemoveEmptyEntries)
        $name = $tokens[8]
        $permissions = $tokens[0]

        $localFilePath = Join-Path $localPath $name
        $fileUrl = ($url + $name)

        if ($permissions[0] -eq 'd')
        {
            if (!(Test-Path $localFilePath -PathType container))
            {
                Write-Host "Creating directory $localFilePath"
                New-Item $localFilePath -Type directory | Out-Null
            }

            DownloadFtpDirectory ($fileUrl + "/") $credentials $localFilePath
        }
        else
        {
            Write-Host "Downloading $fileUrl to $localFilePath"

            $downloadRequest = [Net.WebRequest]::Create($fileUrl)
            $downloadRequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
            $downloadRequest.Credentials = $credentials

            $downloadResponse = $downloadRequest.GetResponse()
            $sourceStream = $downloadResponse.GetResponseStream()
            $targetStream = [System.IO.File]::Create($localFilePath)
            $buffer = New-Object byte[] 10240
            while (($read = $sourceStream.Read($buffer, 0, $buffer.Length)) -gt 0)
            {
                $targetStream.Write($buffer, 0, $read);
            }
            $targetStream.Dispose()
            $sourceStream.Dispose()
            $downloadResponse.Dispose()
        }
    }
}#try
catch
{
 .\SendTelegram.ps1 -id 345821176 -message "Скрипт загрузки рецептов: 
 Ошибка загрузки $Url"
  Write-Host "Downloading $Url Failed!!"
}
}
$strdatetime =Get-Date -Format "yyyy-MM-dd HH-mm"

$credentials = New-Object System.Net.NetworkCredential("admin", "wago")
$credentials1 = New-Object System.Net.NetworkCredential("admin", "wago1")
$targetdir = "C:\BackupScripts\Recipes\"


$url = "ftp://10.10.9.29/PlcLogic/json/"
DownloadFtpDirectory $url $credentials1 $targetdir"vnukovobig"

$url = "ftp://10.10.5.30/PlcLogic/lcLogic/AllRecipes/"
DownloadFtpDirectory $url $credentials $targetdir"podval"

#$url = "ftp://10.10.1.30/PlcLogic/lcLogic/AllRecipes/"
#DownloadFtpDirectory $url $credentials $targetdir"lexus"

$url = "ftp://10.10.4.30/PlcLogic/lcLogic/AllRecipes/"
DownloadFtpDirectory $url $credentials $targetdir"fin"

$url = "ftp://10.10.8.30/PlcLogic/lcLogic/AllRecipes/"
DownloadFtpDirectory $url $credentials $targetdir"irk"

$url = "ftp://10.10.11.30/PlcLogic/json/"
DownloadFtpDirectory $url $credentials1 $targetdir"kras"

$url = "ftp://10.10.13.30/PlcLogic/json/"
DownloadFtpDirectory $url $credentials1 $targetdir"Berdsk"

$url = "ftp://10.10.12.30/PlcLogic/json/"
DownloadFtpDirectory $url $credentials1 $targetdir"Yasay"


$url = "ftp://10.10.7.30/PlcLogic/lcLogic/AllRecipes/"
DownloadFtpDirectory $url $credentials $targetdir"flakon"

$url = "ftp://10.10.20.30/PlcLogic/json/"
DownloadFtpDirectory $url $credentials1 $targetdir"Miass"

$url = "ftp://10.10.19.30/PlcLogic/json/"
DownloadFtpDirectory $url $credentials1 $targetdir"Etnomir FU1"

$url = "ftp://10.10.19.31/PlcLogic/json/"
DownloadFtpDirectory $url $credentials1 $targetdir"Etnomir FU2"


Compress-Archive -DestinationPath C:\ProjectsArchive\RecipesBackup_$strdatetime -Path $targetdir*
Remove-Item -Path $targetdir* -recurse