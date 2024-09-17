Import-Module Pester

Describe "FileCreatedWatcher Tests" {
    BeforeAll {       
        $WatchedFolderPath = "$PSScriptRoot\test"
        $LogFilePath = "$PSScriptRoot\log\logoutput.log"
        $FileCreatorWatcherPath = "$([System.IO.Directory]::GetParent($PSScriptRoot).FullName)\Scripts\FileCreatedWatcher.ps1"
        New-Item -Path "$WatchedFolderPath" -ItemType Directory -Force
        Clear-Content -Path $LogFilePath -ErrorAction SilentlyContinue
        Remove-Item -Path "$WatchedFolderPath\*" -Recurse -Force -ErrorAction SilentlyContinue

        $job = Start-Job -ScriptBlock {
            param($folderPath, $logFilePath, $fileCreatorWatcherPath )
            . $fileCreatorWatcherPath
            Watch-File -t $folderPath -l $logFilePath
        } -ArgumentList @($WatchedFolderPath, $LogFilePath, $FileCreatorWatcherPath)
        Receive-Job -Id $job.Id
        Start-Sleep -Seconds 1
        $testFilePath = "$WatchedFolderPath\file.txt"
        New-Item -Path "$testFilePath" -ItemType File -Force
        Start-Sleep -Seconds 1
        Stop-Job -Job $job
        Remove-Job -Job $job
    }

    It "should start with a `"watching target folder`" message" {
        $capturedOutput = Get-Content -Path $LogFilePath
        $EXPECTED_MESSAGE = "Start Watching $WatchedFolderPath"
        $capturedOutput[0] | Should -Be $EXPECTED_MESSAGE
    }

    # It "should catch the file created event and respond with a message" {
    #     $EXPECTED_MESSAGE = "File event: C:\test\path\file.txt"
    # }
    
    # It "should respond to file creation event and run specific commands" {
    
    #     # Call the function that uses FileSystemWatcher
    #     Start-FileWatcher -Path "C:\test\path"
    
    #     # Simulate the file event
    #     $action = {
    #         param ($source, $eventArgs)
    #         Write-Host "File event detected: $($eventArgs.FullPath)"
    #         Write-Host "Running specific command..."
    #     }
    #     $action.Invoke($null, $mockEventArgs)
    
    #     # Check the captured output
    #     $global:CapturedOutput | Should -Contain "File event detected: C:\test\path\file.txt"
    #     $global:CapturedOutput | Should -Contain "Running specific command..."
    # }
    
    # It "should handle Ctrl+C and cleanup properly" {
    #     # Simulate Ctrl+C interrupt
    #     try {
    #         # Simulate Ctrl+C interrupt
    #         throw [System.Management.Automation.Host.HostCallFailedException]
    #     }
    #     catch [System.Management.Automation.Host.HostCallFailedException] {
    #         Write-Host "Goodbye!"
    #     }
    #     finally {
    #         # Ensure cleanup actions are performed if implemented
    #         # Example of cleanup check, if any
    #     }
    
    #     # Check for goodbye message
    #     $global:CapturedOutput | Should -Contain "Goodbye!"
    # }
    # AfterAll {
    # }
    AfterAll {
        # Remove-Item -Path "$WatchedFolderPath\*\" -Recurse -Force -ErrorAction SilentlyContinue
    }
}
