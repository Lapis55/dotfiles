param(
    [switch]$DryRun,
    [switch]$Help,
    [string[]]$Package
)

$ErrorActionPreference = "Stop"

$DotfilesDir = Join-Path $HOME "dotfiles"
$DefaultPackages = @("bash", "vim", "mintty")

function Show-Usage {
    @"
Usage: powershell -ExecutionPolicy Bypass -File .\install.ps1 [-DryRun] [package...]

Packages:
  bash
  vim
  mintty
"@ | Write-Output
}

function Get-PackageTargets {
    param([string]$Name)

    switch ($Name) {
        "bash" {
            @(
                [pscustomobject]@{ RelativePath = ".bashrc"; Type = "File" }
            )
        }
        "vim" {
            @(
                [pscustomobject]@{ RelativePath = ".vimrc"; Type = "File" },
                [pscustomobject]@{ RelativePath = ".vim"; Type = "Directory" }
            )
        }
        "mintty" {
            @(
                [pscustomobject]@{ RelativePath = ".minttyrc"; Type = "File" }
            )
        }
        default {
            throw "Unknown package: $Name"
        }
    }
}

function Resolve-FullPath {
    param([string]$Path)

    $resolved = Resolve-Path -LiteralPath $Path -ErrorAction SilentlyContinue
    if ($resolved) {
        return $resolved.ProviderPath
    }

    return [System.IO.Path]::GetFullPath($Path)
}

function Test-CorrectLink {
    param(
        [string]$TargetPath,
        [string]$SourcePath
    )

    $item = Get-Item -LiteralPath $TargetPath -Force -ErrorAction SilentlyContinue
    if (-not $item) {
        return $false
    }

    if ($item.LinkType -notin @("SymbolicLink", "Junction")) {
        return $false
    }

    $actual = Resolve-FullPath $item.Target
    $expected = Resolve-FullPath $SourcePath
    return [System.String]::Equals($actual, $expected, [System.StringComparison]::OrdinalIgnoreCase)
}

function Backup-Conflict {
    param(
        [string]$TargetPath,
        [string]$BackupPath
    )

    $exists = Get-Item -LiteralPath $TargetPath -Force -ErrorAction SilentlyContinue
    if (-not $exists) {
        return
    }

    if ($DryRun) {
        Write-Output "would backup: $TargetPath -> $BackupPath"
        return
    }

    $backupParent = Split-Path -Parent $BackupPath
    New-Item -ItemType Directory -Force -Path $backupParent | Out-Null
    Move-Item -LiteralPath $TargetPath -Destination $BackupPath
    Write-Output "backup: $TargetPath -> $BackupPath"
}

function New-DotLink {
    param(
        [string]$SourcePath,
        [string]$TargetPath,
        [string]$Type
    )

    if ($DryRun) {
        Write-Output "would link: $TargetPath -> $SourcePath"
        return
    }

    $targetParent = Split-Path -Parent $TargetPath
    New-Item -ItemType Directory -Force -Path $targetParent | Out-Null

    try {
        New-Item -ItemType SymbolicLink -Path $TargetPath -Target $SourcePath | Out-Null
        Write-Output "link: $TargetPath -> $SourcePath"
        return
    }
    catch {
        if ($Type -eq "Directory") {
            New-Item -ItemType Junction -Path $TargetPath -Target $SourcePath | Out-Null
            Write-Output "junction: $TargetPath -> $SourcePath"
            return
        }

        throw "Failed to create symbolic link: $TargetPath -> $SourcePath. Enable Windows Developer Mode or run PowerShell as Administrator."
    }
}

function Test-FileSymlinkCapability {
    $testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("dotfiles-link-test-" + [guid]::NewGuid().ToString("N"))
    $source = Join-Path $testRoot "source.txt"
    $link = Join-Path $testRoot "link.txt"

    try {
        New-Item -ItemType Directory -Force -Path $testRoot | Out-Null
        Set-Content -LiteralPath $source -Value "test"
        New-Item -ItemType SymbolicLink -Path $link -Target $source | Out-Null
        return $true
    }
    catch {
        return $false
    }
    finally {
        Remove-Item -LiteralPath $testRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Test-RequiresFileSymlink {
    param([string[]]$Names)

    foreach ($name in $Names) {
        foreach ($entry in Get-PackageTargets $name) {
            if ($entry.Type -eq "File") {
                return $true
            }
        }
    }

    return $false
}

function Install-Package {
    param(
        [string]$Name,
        [string]$BackupRoot
    )

    $packageDir = Join-Path $DotfilesDir $Name
    if (-not (Test-Path -LiteralPath $packageDir -PathType Container)) {
        throw "Package directory not found: $packageDir"
    }

    foreach ($entry in Get-PackageTargets $Name) {
        $sourcePath = Join-Path $packageDir $entry.RelativePath
        $targetPath = Join-Path $HOME $entry.RelativePath
        $backupPath = Join-Path $BackupRoot $entry.RelativePath

        if (-not (Test-Path -LiteralPath $sourcePath)) {
            throw "Source path not found: $sourcePath"
        }

        if (Test-CorrectLink -TargetPath $targetPath -SourcePath $sourcePath) {
            Write-Output "ok: $targetPath already links to $sourcePath"
            continue
        }

        Backup-Conflict -TargetPath $targetPath -BackupPath $backupPath
        New-DotLink -SourcePath $sourcePath -TargetPath $targetPath -Type $entry.Type
    }
}

if ($Help) {
    Show-Usage
    exit 0
}

if (-not $Package -or $Package.Count -eq 0) {
    $Package = $DefaultPackages
}

if (-not (Test-Path -LiteralPath $DotfilesDir -PathType Container)) {
    throw "$DotfilesDir does not exist"
}

foreach ($name in $Package) {
    Get-PackageTargets $name | Out-Null
}

if (-not $DryRun -and (Test-RequiresFileSymlink -Names $Package) -and -not (Test-FileSymlinkCapability)) {
    throw "This PowerShell session cannot create file symbolic links. Enable Windows Developer Mode or run PowerShell as Administrator, then retry."
}

if (-not $DryRun) {
    New-Item -ItemType Directory -Force -Path `
        (Join-Path $DotfilesDir "vim\.vim\autoload"), `
        (Join-Path $DotfilesDir "vim\.vim\backup"), `
        (Join-Path $DotfilesDir "vim\.vim\swap"), `
        (Join-Path $DotfilesDir "vim\.vim\undo") | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupRoot = Join-Path $HOME ".dotfiles-backup\$timestamp"

foreach ($name in $Package) {
    Install-Package -Name $name -BackupRoot $backupRoot
}
