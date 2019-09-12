
function Get-CUser
{
    <#
    .SYNOPSIS
    Gets *local* users.

    .DESCRIPTION
    `Get-CUser` gets all *local* users. Use the `UserName` parameter to get a specific user by its username.

    The objects returned by `Get-CUser` are instances of `System.DirectoryServices.AccountManagement.UserPrincipal`. These objects use external resources, which, if they are disposed of correctly, will cause memory leaks. When you're done using the objects returne by `Get-CUser`, call `Dispose()` on each one to clean up its external resources.

    `Get-CUser` is new in Carbon 2.0.

    .OUTPUTS
    System.DirectoryServices.AccountManagement.UserPrincipal.

    .LINK
    Install-CUser

    .LINK
    Test-CUser

    .LINK
    Uninstall-CUser

    .EXAMPLE
    Get-CUser

    Demonstrates how to get all local users.

    .EXAMPLE
    Get-CUser -Username LSkywalker 

    Demonstrates how to get a specific user.
    #>
    [CmdletBinding()]
    [OutputType([System.DirectoryServices.AccountManagement.UserPrincipal])]
    param(
        [ValidateLength(1,20)]
        # The username for the user.
        [string]$UserName 
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    # Tee-Object won't set its variable if WhatIfPreference is $true.
    $WhatIfPreference = $false

    Write-Timing 'Get-CUser  Start'
    
    Write-Timing ('           Creating searcher')
    $ctx = New-Object 'DirectoryServices.AccountManagement.PrincipalContext' ([DirectoryServices.AccountManagement.ContextType]::Machine)
    $query = New-Object 'DirectoryServices.AccountManagement.UserPrincipal' $ctx
    $searcher = New-Object 'DirectoryServices.AccountManagement.PrincipalSearcher' $query
    try
    {
        $users = @()

        Write-Timing ('           FindAll()  Start')
        $searcher.FindAll() |
            Where-Object {
                if( $UserName )
                {
                    return $_.SamAccountName -eq $UserName
                }
                return $true
            } |
            Tee-Object -Variable 'users'
        Write-Timing ('           FindAll()  Done')

        if( $UserName )
        {
            $usersCount = $users | Measure-Object | Select-Object -ExpandProperty 'Count'
            if( $usersCount -gt 1 )
            {
                Write-Error -Message ('Found {0} users with username "{1}".' -f $userCount,$UserName) -ErrorAction $ErrorActionPreference
            }
            if( $usersCount -eq 0 )
            {
                Write-Error -Message ('Local user "{0}" not found.' -f $Username) -ErrorAction:$ErrorActionPreference
            }
        }
    }
    finally
    {
        Write-Timing ('           Finally')
        $searcher.Dispose()
        $query.Dispose()
    }
    Write-Timing ('Get-CUser  Done')
}
