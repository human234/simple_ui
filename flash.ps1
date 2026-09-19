<#
.SYNOPSIS
    Flash the last build to the board via the Zephyr Docker image.
#>
param(
    [string]$Board = "nucleo_g474re"
)

& "$PSScriptRoot\build.ps1" -Flash @PSBoundParameters