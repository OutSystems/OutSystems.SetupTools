Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'New-OSPlatformFullFactorySolution Tests' {

        # Global mocks
        Mock GetSolutionsWS {
            $obj = [pscustomobject]@{}
            $obj | Add-Member -MemberType ScriptMethod -Name 'CreateAllSolution' -Force -Value {
                param( [string]$SolutionName, [string]$ServiceCenterUser, [string]$ServiceCenterPass )

                if ($ServiceCenterUser -eq 'SuperUser' -and $ServiceCenterPass -eq 'SuperPass') {
                    return 100
                } else {
                    throw "Big error"
                }
            }

            return $obj
        }

        Mock GetHashedPassword { return $SCPass }

        $password = ConvertTo-SecureString "SuperPass" -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential ("SuperUser", $password)

        Context 'When cannot connect to service center or the webservice returns an error' {

            Mock GetSolutionsWS { throw "Error" }

            It 'Should throw an error' {
                { New-OSPlatformFullFactorySolution -ServiceCenterHost 255.255.255.255 -SolutionName 'MySolution' } | Should throw "Error creating the solution. Check in the OutSystems database if you have EnableCloudServicesAPI=True on the ossys.parameter table"
            }

        }

        Context 'When the solution name is null or empty' {

            It 'Should throw an error' {
                { New-OSPlatformFullFactorySolution -ServiceCenterHost 255.255.255.255 -SolutionName '' } | Should throw
                { New-OSPlatformFullFactorySolution -ServiceCenterHost 255.255.255.255 -SolutionName } | Should throw
            }

        }

        Context 'When can connect and create a solution' {

            It 'Should not throw' {
                { New-OSPlatformFullFactorySolution -ServiceCenterHost 255.255.255.255 -SolutionName 'MySolution' -Credential $Credential } | Should Not throw
            }

            It 'Should passthru an object' {

                $result = New-OSPlatformFullFactorySolution -PassThru -ServiceCenterHost 255.255.255.255 -SolutionName 'MySolution' -Credential $Credential

                $result.SolutionId | Should Be 100
                $result.SolutionName | Should Be 'MySolution'
                $result.ServiceCenterHost | Should Be '255.255.255.255'
            }

        }

    }
}
