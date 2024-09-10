Describe "FileCreatedWatcher Tests" {
    BeforeAll {       
        $global:testDirPath = [System.IO.Directory]::GetParent($PSScriptRoot).FullName + "\test"
        $global:logFilePath = [System.IO.Directory]::GetParent($PSScriptRoot).FullName + "\logoutput.log"
        $global:fileCreatorWatcherPath = [System.IO.Directory]::GetParent($PSScriptRoot).FullName + "\Scripts\FileCreatedWatcher.ps1"
        New-Item -Path "$global:testDirPath" -ItemType Directory -Force
        # Create a variable to capture Write-Host output
        $global:capturedOutput = @()
        Clear-Content -Path $global:logFilePath -ErrorAction SilentlyContinue
        Remove-Item -Path "$global:testDirPath\*" -Recurse -Force -ErrorAction SilentlyContinue
        $global:job = Start-Job -ScriptBlock {
            param($path)
            . $path
        } -ArgumentList $global:fileCreatorWatcherPath
        Start-Sleep -Seconds 1
        $testFilePath = "$global:testDirPath\file.txt"
        New-Item -Path "$testFilePath" -ItemType File -Force
        Start-Sleep -Seconds 1
        Stop-Job -Job $global:job
        Remove-Job -Job $global:job
        $global:capturedOutput = Get-Content -Path $global:logFilePath
    }

    It "should start with a `"watching target folder`" message" {
        $EXPECTED_MESSAGE = "Start Watching $global:testDirPath"
        $global:capturedOutput[0] | Should -Be $EXPECTED_MESSAGE
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
        $global:CapturedOutput = @()
        Remove-Item -Path "$global:testDirPath" -Recurse -Force -ErrorAction SilentlyContinue
    }
}
