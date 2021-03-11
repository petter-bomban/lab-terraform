# Download Terraform file, add to specified folder, set up alias
function Get-Terraform ($InstallPath, $File) {

    $ReturnObject = [PSCustomObject]@{
        InstallPath   = $InstallPath
        TerraformPath = $null
        Success       = $null
        Message       = $null
    }

    $Filename = Split-Path $File -Leaf
    $ZipPath = Join-Path -Path $InstallPath -ChildPath $Filename
    $TerraformPath = Join-Path -Path $InstallPath -ChildPath "terraform.exe"

    if (!(Test-Path $InstallPath)) {

        Write-Host "Creating install dir"
        New-Item -ItemType Directory -Path $InstallPath | Out-Null
    }

    if (Test-Path -Path $ZipPath) {
        Write-Host "Zip file already exists, will overwrite"
        Remove-Item -Path $ZipPath -Force -Confirm:$False | Out-Null
    }

    if (Test-Path -Path $TerraformPath) {
        Write-Host "terraform.exe already exists, will overwrite"
        Remove-Item -Path $TerraformPath -Force -Confirm:$False | Out-Null
    }

    try {
        Write-Host "Downloading Terraform zip"
        Invoke-WebRequest -Uri $File -OutFile $ZipPath -ErrorAction Stop
    }
    catch {
        $ReturnObject.Success = $False
        $ReturnObject.Message = "Unable to download Terraform Zip - $File"
        return $ReturnObject
    }
    
    try {
        Write-Host "Unzipping"
        Expand-Archive -LiteralPath $ZipPath -DestinationPath $InstallPath | Out-Null
        Write-Host "Removing zip file"
        Remove-Item -Path $ZipPath -Force -Confirm:$False | Out-Null
    }
    catch {
        $ReturnObject.Success = $False
        $ReturnObject.Message = "Unable to unzip Terraform file - $ZipPath"
        return $ReturnObject
    }

    if (Test-Path -Path $TerraformPath) {
        $ReturnObject.Success = $true
        $ReturnObject.TerraformPath = $TerraformPath
        $ReturnObject.Message = "Terraform installed - $TerraformPath"

        Write-Host "Terraform installed"
    }

    Write-Host "Setting alias 'terraform' for terraform.exe"
    Set-Alias -Name terraform -Value $TerraformPath -Confirm:$false -Force | Out-Null
    
    return $ReturnObject
}

$InstallPath = 'C:\Terraform'
$File = 'https://releases.hashicorp.com/terraform/0.14.7/terraform_0.14.7_windows_amd64.zip'

Get-Terraform -InstallPath $InstallPath -File $File
