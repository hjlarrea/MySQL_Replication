param(
    [parameter(mandatory=$true)][string]$ResourceGroup,
    [parameter(mandatory=$true)][string]$StorageAccountName,
    [parameter(mandatory=$true)][string]$ContainerName,
    [parameter(mandatory=$true)][string]$SASToken
)

$filesToUpload=Get-ChildItem -Path $PSScriptRoot\scripts

#Azure Login
$sessionContext=Get-AzureRmContext
if( $sessionContext ) {
    Write-Output "User is already logged on."
} else {
    Write-Output "Login in..."
    Login-AzureRmAccount
}

#Storage Account detection
#$storageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
#New-AzureStorageContainer -Name $ContainerName -Context $storageContext -Permission Blob

#File uploads
foreach ($file in $filesToUpload) {
    #uploadFiles
}