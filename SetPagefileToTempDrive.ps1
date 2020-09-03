Function Remove-Pagefile($path)
{
    Get-CIMInstance Win32_PageFileSetting | Where-Object { $_.Name -eq $path } | Remove-CIMInstance
}

Function Get-Pagefile($path)
{
    Get-CIMInstance Win32_PageFileSetting | Where-Object { $_.Name -eq $path }
}

$currentPageFiles = Get-CIMInstance Win32_PageFileSetting
if ($null -ne $currentPageFiles) {
    $currentPageFiles | Remove-CIMInstance > $null
}

try {
    $computerSystem = Get-CIMInstance -Class win32_computersystem
} catch {
    return "Failed to query WMI computer system object $($_.Exception.Message)"
}

if ($computerSystem.AutomaticManagedPagefile -ne $automatic) {
    if (-not $check_mode) {
        try {
            $computerSystem | Set-CimInstance -Property @{automaticmanagedpagefile=$true} > $null
        } catch {
            return "Failed to set AutomaticManagedPagefile $($_.Exception.Message)"
        }
    }
}

$fullPath = "D:\pagefile.sys"

if ($null -ne (Get-Pagefile $fullPath)) {
    try {
        Remove-Pagefile $fullPath
    }
    catch {
        return "Failed to remove current pagefile $($_.Exception.Message)"
    }
}

$curPagefile = Get-Pagefile $fullPath
if ($null -eq $curPagefile) {
    try {
        New-CIMInstance -Class Win32_PageFileSetting -Arguments @{name = $fullPath; }
        return "Correctly set pagefile to D (Temporary) drive."
    }
    catch {
        return "Failed to create pagefile $($_.Exception.Message)"
    }
}
