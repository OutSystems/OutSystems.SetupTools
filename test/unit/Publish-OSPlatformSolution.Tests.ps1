Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Publish-OSPlatformSolution Tests' {

        # Global mocks
        Mock GetServerInstallDir { return 'C:\Program Files\OutSystems\Platform Server' }

        Context 'When the solution file does not exist' {

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            # Path to solution that doesn't exist
            $Solution = 'C:\Solution.osp'

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution $Solution -Credential $Credential

            It 'Should return the right result' {
                $Result.Success | Should Be $false
                $Result.ExitCode | Should Be -1
                $Result.Message | Should Be "Cant find the solution file $Solution"
            }

        }

        Context 'When the StartSecondStep switch was enabled but UseTwoStepMode was not' {

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

        Context 'When the solution publish fails to launch' {

            Mock AppMgmt_SolutionPublish { throw }
            
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

        Context 'When the solution publish is launched sucessfully and we do not wait for the results' {

            Mock AppMgmt_SolutionPublish { return @{ publishId = 567 } }

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential

            It 'Should return the right result' {
                $Result.Success | Should Be $true
                $Result.PublishId | Should Be 567
                $Result.Message | Should Be 'Solution successfully uploaded. Compilation started on the deployment controller'
            }

        }

        Context 'When errors occur checking the status of the solution publish' {
            
            Mock AppMgmt_SolutionPublish { return @{ publishId = 567 } }
            Mock AppMgmt_GetPublishResults { throw }

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential -Wait

            It 'Should return the right result' {
                $Result.Success | Should Be $false
                $Result.ExitCode | Should Be -1
                $Result.PublishId | Should Be 567
                $Result.Message | Should Be 'Error checking the publication status'
            }

        }

        Context 'When errors occur in the solution publish' {
            
            Mock AppMgmt_SolutionPublish { return @{ publishId = 567 } }
            Mock AppMgmt_GetPublishResults { return @{ Warnings = 0; Errors = 1 } }
            Mock AppMgmt_SolutionPublishStop { return $true }

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential -Wait

            It 'Should return the right result' {
                $Result.Success | Should Be $false
                $Result.ExitCode | Should Be 2
                $Result.PublishId | Should Be 567
                $Result.Message | Should Be 'Errors found while compiling the solution'
            }

        }

        Context 'When warnings occur in the solution publish and StopOnWarnings is enabled' {
            
            Mock AppMgmt_SolutionPublish { return @{ publishId = 567 } }
            Mock AppMgmt_GetPublishResults { return @{ Warnings = 1; Errors = 0 } }
            Mock AppMgmt_SolutionPublishStop { return $true }

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential -StopOnWarnings -Wait

            It 'Should return the right result' {
                $Result.Success | Should Be $false
                $Result.ExitCode | Should Be 2
                $Result.PublishId | Should Be 567
                $Result.Message | Should Be 'Warnings found while compiling the solution'
            }

        }

        Context 'When the solution publish is sucessfull' {
            
            Mock AppMgmt_SolutionPublish { return @{ publishId = 567 } }
            Mock AppMgmt_GetPublishResults { return @{ Warnings = 0; Errors = 0 } }
            Mock AppMgmt_SolutionPublishStop { return $true }

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential -Wait

            It 'Should return the right result' {
                $Result.Success | Should Be $true
                $Result.ExitCode | Should Be 0
                $Result.PublishId | Should Be 567
                $Result.Message | Should Be 'Solution successfully published'
            }

        }

        Context 'When the first step of solution publish ends successfully and the second step is not started' {

            Mock AppMgmt_SolutionPublish { return @{ publishId = 567 } }
            Mock AppMgmt_GetPublishResults { return @{ Warnings = 0; Errors = 0 } }

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential -Wait -UseTwoStepMode:$true -StartSecondStep:$false

            It 'Should return the right result' {
                $Result.Success | Should Be $true
                $Result.PublishId | Should Be 567
                $Result.Message | Should Be 'First step of solution publish successfully completed. Will wait for second step to be be started in Service Center to finish deployment.'
            }

        }

        Context 'When the first step of solution publish ends successfully and the second step fails to start.' {

            Mock AppMgmt_SolutionPublish { return @{ publishId = 567 } }
            Mock AppMgmt_GetPublishResults { return @{ Warnings = 0; Errors = 0 } }
            Mock AppMgmt_SolutionPublishContinue { throw }

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential -Wait -UseTwoStepMode:$true -StartSecondStep:$true

            It 'Should return the right result' {
                $Result.Success | Should Be $false
                $Result.ExitCode | Should Be -1
                $Result.PublishId | Should Be 567
                $Result.Message | Should Be 'Error while starting to deploy the solution'
            }

        }

        Context 'When the second step of solution publish finishes successfully' {

            Mock AppMgmt_SolutionPublish { return @{ publishId = 567 } }
            Mock AppMgmt_GetPublishResults { return @{ Warnings = 0; Errors = 0; LastMessageId = 230 } }
            Mock AppMgmt_SolutionPublishContinue { return $true }
            Mock AppMgmt_GetPublishResults { return @{ Warnings = 0; Errors = 0 } } -ParameterFilter { $AfterMessageId.Equals(230) }

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential -Wait -UseTwoStepMode:$true -StartSecondStep:$true

            It 'Should return the right result' {
                $Result.Success | Should Be $true
                $Result.ExitCode | Should Be 0
                $Result.PublishId | Should Be 567
                $Result.Message | Should Be 'Solution successfully published'
            }

        }

        Context 'When the second step of solution publish finishes successfully but with warnings' {

            Mock AppMgmt_SolutionPublish { return @{ publishId = 567 } }
            Mock AppMgmt_GetPublishResults { return @{ Warnings = 0; Errors = 0; LastMessageId = 230 } }
            Mock AppMgmt_SolutionPublishContinue { return $true }
            Mock AppMgmt_GetPublishResults { return @{ Warnings = 1; Errors = 0 } } -ParameterFilter { $AfterMessageId.Equals(230) }

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential -Wait -UseTwoStepMode:$true -StartSecondStep:$true

            It 'Should return the right result' {
                $Result.Success | Should Be $true
                $Result.ExitCode | Should Be 1
                $Result.PublishId | Should Be 567
                $Result.Message | Should Be 'Solution successfully published with warnings!!'
            }

        }

        Context 'When the second step of solution publish fails with errors' {

            Mock AppMgmt_SolutionPublish { return @{ publishId = 567 } }
            Mock AppMgmt_GetPublishResults { return @{ Warnings = 0; Errors = 0; LastMessageId = 230 } }
            Mock AppMgmt_SolutionPublishContinue { return $true }
            Mock AppMgmt_GetPublishResults { return @{ Warnings = 0; Errors = 1 } } -ParameterFilter { $AfterMessageId.Equals(230) }

            $Password = ConvertTo-SecureString 'admin' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('admin', $Password)

            $PSInstallPath = Get-OSServerInstallDir

            $Result = Publish-OSPlatformSolution -ServiceCenterHost "localhost" -Solution "$PSInstallPath\System_Components.osp" -Credential $Credential -Wait -UseTwoStepMode:$true -StartSecondStep:$true

            It 'Should return the right result' {
                $Result.Success | Should Be $false
                $Result.ExitCode | Should Be 2
                $Result.PublishId | Should Be 567
                $Result.Message | Should Be 'Error publishing the solution'
            }

        }

    }
}