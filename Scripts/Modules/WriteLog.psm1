function Write-Log {
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("m")]
        [string]$LogMessage,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(0, 2)]
        [Alias("l")]
        [int]$LogLevel = 0,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias("o")]
        [string]$LogFilePath
    )

    $script:Info = [PSCustomObject]@{
        Name            = "Info"
        TextColor       = "green"
        BackgroundColor = "yellow"
    }
        
    $script:Warning = [PSCustomObject]@{
        Name            = "Warning"
        TextColor       = "yellow"
        BackgroundColor = "black"
    }
        
    $script:Err = [PSCustomObject]@{
        Name            = "Error"
        TextColor       = "black"
        BackgroundColor = "red"
    }
        
    $script:LogTypesList = @($Info, $Warning, $script:Err)
    $script:currentLogtype = $script:LogTypesList[$LogLevel]

    if ($PSBoundParameters.ContainsKey('LogFilePath')) {
        $script:currentLogFilePath = $LogFilePath
    }
    else {
        if ($global:LogFilePath -eq $null) {
            Write-Host "Log file path couldnt be found" -ForegroundColor $script:Err.TextColor -BackgroundColor $script:Err.BackgroundColor
            return
        }
        $script:currentLogFilePath = $global:LogFilePath
    }

    if (-not $(Test-Path -Path $script:currentLogFilePath -IsValid)) {
        Write-Host "Log file path isnt valid" -ForegroundColor $script:Err.TextColor -BackgroundColor $script:Err.BackgroundColor
        return
    }

    Write-Host "$LogMessage" -ForegroundColor $script:currentLogtype.TextColor -BackgroundColor $script:currentLogtype.BackgroundColor
    Add-Content -Path $script:currentLogFilePath -Value "$($script:currentLogtype.Name) - $(Get-Date) - $LogMessage"
    return

}