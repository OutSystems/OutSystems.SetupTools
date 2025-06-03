Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Publish-OSPlatformSolution Tests' {

        # Global mocks
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }

        Context 'When the solution file does not exist' {

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $Solution = 'C:\Solution.osp'

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution $Solution -Credential $Credential

            It 'Should return the right result' {
                $Result.Success | Should Be $false
                $Result.ExitCode | Should Be -1
                $Result.Message | Should Be "Cant find the solution file $Solution"
            }

        }

        Context 'When StartSecondStep switch was enabled but UseTwoStepMode was not' {

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential -StartSecondStep -UseTwoStepMode:$false

            It 'Should return the right result' {
                $Result.Success | Should Be $false
                $Result.ExitCode | Should Be -1
                $Result.Message | Should Be 'Error in parameters provided'
            }

        }

        Context 'When there is an error launching the solution publish' {

            Mock Publish-OSPlatformSolution { return [pscustomobject]@{ Success = $false
                                                                     ExitCode = -1
                                                                     Message = 'Error while starting to compile the solution'}
                                          }
            
            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential

            It 'Should return the right result' {
                $Result.Success | Should Be $false
                $Result.ExitCode | Should Be -1
                $Result.Message | Should Be 'Error while starting to compile the solution'
            }

        }

        Context 'When solution publish is launched sucessfully and we do not wait for the result' {

            Mock Publish-OSPlatformSolution { return [pscustomobject]@{ Success = $false
                                                                     PublishId = 567
                                                                     Message = 'Solution successfully uploaded. Compilation started on the deployment controller'}
                                          }

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential

            It 'Should return the right result' {
                $Result.Success | Should Be $false
                $Result.PublishId | Should Be 567
                $Result.Message | Should Be 'Solution successfully uploaded. Compilation started on the deployment controller'
            }

        }

        Context 'When errors occur checking the status of the solution publish' {
            
            Mock Publish-OSPlatformSolution { return [pscustomobject]@{ Success = $false
                                                                     PublishId = 567
                                                                     ExitCode = -1
                                                                     Message = 'Error checking the publication status'}
                                          }

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential

            It 'Should return the right result' {
                $Result.Success | Should Be $false
                $Result.ExitCode | Should Be -1
                $Result.PublishId | Should Be 567
                $Result.Message | Should Be 'Error checking the publication status'
            }

        }

        Context 'When errors occur compiling the solution' {
            
            Mock Publish-OSPlatformSolution { return [pscustomobject]@{ Success = $false
                                                                     PublishId = 567
                                                                     ExitCode = 2
                                                                     Message = 'Errors found while compiling the solution'}
                                          }

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential

            It 'Should return the right result' {
                $Result.Success | Should Be $false
                $Result.ExitCode | Should Be 2
                $Result.PublishId | Should Be 567
                $Result.Message | Should Be 'Errors found while compiling the solution'
            }

        }

        Context 'When warnings occur compiling the solution and StopOnWarnings is enabled' {
            
            Mock Publish-OSPlatformSolution { return [pscustomobject]@{ Success = $false
                                                                     PublishId = 567
                                                                     ExitCode = 2
                                                                     Message = 'Warnings found while compiling the solution'}
                                          }

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential -StopOnWarnings

            It 'Should return the right result' {
                $Result.Success | Should Be $false
                $Result.ExitCode | Should Be 2
                $Result.PublishId | Should Be 567
                $Result.Message | Should Be 'Warnings found while compiling the solution'
            }

        }

        Context 'When solution publishes successfully in one step' {

            Mock Publish-OSPlatformSolution { return [pscustomobject]@{ Success = $false
                                                                     ExitCode = -1
                                                                     Message = 'Solution successfully uploaded. Compilation started on the deployment controller'}
                                          }

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential

            It 'Should return the right result' {
                $Result.Success | Should Be $false
                $Result.ExitCode | Should Be -1
                $Result.Message | Should Be 'Solution successfully uploaded. Compilation started on the deployment controller'
            }

        }

        Context 'When solution publishes successfully but with warnings' {

            Mock Publish-OSPlatformSolution { return [pscustomobject]@{ Success = $false
                                                                     ExitCode = 1
                                                                     PublishId = 567
                                                                     Message = 'Solution successfully published with warnings!!'}
                                          }

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential

            It 'Should return the right result' {
                $Result.Success | Should Be $false
                $Result.ExitCode | Should Be 1
                $Result.PublishId | Should Be 567
                $Result.Message | Should Be 'Solution successfully published with warnings!!'
            }

        }

        Context 'When errors occur in the solution publish' {

            Mock Publish-OSPlatformSolution { return [pscustomobject]@{ Success = $false
                                                                     PublishId = 567
                                                                     ExitCode = 2
                                                                     Message = 'Error publishing the solution'}
                                          }

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential

            It 'Should return the right result' {
                $Result.Success | Should Be $false
                $Result.ExitCode | Should Be 2
                $Result.PublishId | Should Be 567
                $Result.Message | Should Be 'Error publishing the solution'
            }

        }

    }
}