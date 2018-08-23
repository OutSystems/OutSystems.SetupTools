Function LogMessage([string]$Function, [int]$Phase, [int]$Stream, [string]$Message, [object]$Exception){

    # Log types
    switch ($Phase) {
        0 { $PhaseMessage += ' [BEGIN  ]' }
        1 { $PhaseMessage += ' [PROCESS]' }
        2 { $PhaseMessage += ' [END    ]' }
    }

    $LogLineTemplate = $((get-date).TimeOfDay.ToString()) + " [" + $Function.PadRight(40) + "] $PhaseMessage "

    switch ($Stream) {
        0 {
            Write-Verbose  "$LogLineTemplate $Message"
            If($script:OSLogFile -and ($script:OSLogFile -ne "")){
                Add-Content -Path $script:OSLogFile -Value "VERBOSE : $LogLineTemplate $Message"
            }
        }
        1 {
            Write-Warning  "$LogLineTemplate $Message"
            If($script:OSLogFile -and ($script:OSLogFile -ne "")){
                Add-Content -Path $script:OSLogFile -Value "WARNING : $LogLineTemplate $Message"
            }
        }
        2 {
            Write-Debug  "$LogLineTemplate $Message"
            If($script:OSLogFile -and ($script:OSLogFile -ne "") -and $script:OSLogDebug){
                Add-Content -Path $script:OSLogFile -Value "DEBUG   : $LogLineTemplate $Message"
            }
        }
        3 {
            Write-Verbose "$LogLineTemplate $Message"

            # Exception info
            If ($Exception){
                $E = $Exception
                Write-Verbose "$LogLineTemplate $($E.Message)"
                If($script:OSLogFile -and ($script:OSLogFile -ne "")){
                    Add-Content -Path $script:OSLogFile -Value "ERROR   : $LogLineTemplate $Message"
                    Add-Content -Path $script:OSLogFile -Value "InnerException:"
                    Add-Content -Path $script:OSLogFile -Value $($E.Message)
                    Add-Content -Path $script:OSLogFile -Value $($E.StackTrace)
                }

                # Drill down to show the full exception chain
                While ($E.InnerException) {
                    $E = $E.InnerException
                    Write-Verbose "$LogLineTemplate $($E.Message)"
                    If($script:OSLogFile -and ($script:OSLogFile -ne "")){
                        Add-Content -Path $script:OSLogFile -Value $($E.Message)
                        Add-Content -Path $script:OSLogFile -Value $($E.StackTrace)
                    }
                }
            }
        }
    }
}
