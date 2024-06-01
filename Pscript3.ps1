Import-Module "C:\Users\Anjali Prajapati\OneDrive\Desktop\File Integrity\Mail.psm1"

$Creds=Get-Credential
$Creds | Export-Clixml -Path "C:\Users\Anjali Prajapati\OneDrive\Desktop\File Integrity\EmailCred.xml"



$EmailCredentialsPath = "C:\Users\Anjali Prajapati\OneDrive\Desktop\File Integrity\New folder\EmailCred.xml"
$EmailCredentials = Import-Clixml -Path $EmailCredentialsPath
$EmailServer="smtp-mail.outlook.com"
$EmailPort="587"

function Add-FileToBaseLine{
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory)]$baselineFilePath,
        [Parameter(Mandatory)]$targetFilePath
    )
    try{
        if((test-Path -Path $baselineFilePath) -eq $false){
            Write-Error -Message "$baselineFilePath does not exist" -ErrorAction Stop 
        }
        if((test-Path -Path $targetFilePath) -eq $false){
            Write-Error -Message "$targetFilePath does not exist" -ErrorAction Stop
        }

        $currentBaseline = Import-Csv -Path $baselineFilePath -Delimiter ","

        if($targetFilePath -in $currentBaseline.path){
            Write-Output "File path detected in baseline file"
            do{$overwrite=Read-Host -Prompt "Path exits already in the baseline file, would you like to overwrite it {Y/N}"
            if($overwrite -in @('y','yes','Y')){
                Write-Output "Path will be overwritten."

                $currentBaseline | Where-Object path -ne $targetFilePath | Export-Csv -Path $baselineFilePath

                $hash=Get-FileHash -Path $targetFilePath

                "$($targetFilePath),$($hash.hash)" | Out-File -FilePath $baselineFilePath - Append
        
                Write-Output "Entry successfully added into baseline "

            }elseif($overwrite -in @('n','no','N')){
                Write-Output "File path will not be overwritten."
            }else{
                Write-Output "Invalid entry, please enter y to overwrite or n to not overwrite"
            }
        }while($overwrite -notin @('yes','y','Y','no','n','N'))
            
        }else {
            
        $hash=Get-FileHash -Path $targetFilePath

        "$($targetFilePath),$($hash.hash)" | Out-File -FilePath $baselineFilePath -Append

        Write-Output "Entry successfully added into baseline "
    }
    $currentBaseline = Import-Csv -Path $baselineFilePath -Delimiter ","
    $currentBaseline | Where-Object path -ne $targetFilePath | Export-Csv -Path $baselineFilePath

    }catch{
        Write-Error $_.Expection.Message
    }
}

function Verify-BaseLine {
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory)]$baselineFilePath,
        [Parameter(Mandatory)]$emailTo

    )

    try{
        if((test-Path -Path $baselineFilePath) -eq $false){
            Write-Error -Message "$baselineFilePath does not exist" -ErrorAction Stop
        }

        if($baselineFilePath.Substring($baselineFilePath.Length-4,4) -ne ".csv"){
            Write-Output -Message "$baselineFilePath need to be .csv file " -ErrorAction Stop
        }


        $baselineFiles= Import-Csv -Path $baselineFilePath -Delimiter ","

     foreach($file in $baselineFiles){
        if(test-Path -Path $file.path){
            $currenthash=Get-FileHash -Path $file.path
            if($currenthash.Hash -eq $file.hash){
                Write-Output "$($file.path) is still the same"
            }else{
                Write-Output "$($file.path) hash is different something has changed"
                if($EmailTo){
                    Send-MailKitMessage -To $emailTo -From $EmailCredentials.UserName -Subject "File Monitor, file has changed" -Body "$($file.path) hash is different something has changed" -SMTPServer $EmailServer -Port $EmailPort -Credential $EmailCredentials
                }
            } 
        } else {
            Write-Output "$($file.path) is not found"
        }
    }
    }catch{
        Write-Error $_.Expection.Message
    }
}

function Create-BaseLine{
    [cmdletBinding()]
    Param( 
        [Parameter(Mandatory)] $baselineFilePath
    )

    try{

        if((test-Path -Path $baselineFilePath)){
            Write-Output -Message "$baselineFilePath already exist with this name " -ErrorAction Stop
        }

        if($baselineFilePath.Substring($baselineFilePath.Length-4,4) -ne ".csv"){
            Write-Output -Message "$baselineFilePath need to be .csv file " -ErrorAction Stop
        }

        "path,hash" | Out-File -FilePath $baselineFilePath -Force 
    }catch{
        Write-Error $_.Expection.Message
    }
}


$baselineFilePath="C:\Users\Anjali Prajapati\OneDrive\Desktop\File Integrity\New folder\baselines1.csv" 

Write-Output "File Monitor System Vers 1.00"-ForegroundColor Green
 do{
    Write-Host "Please select one of the following options or enter q or quit to quit" -ForegroundColor Green
    Write-Host "1. Set Baseline file ; Current set Baseline $($baselineFilePath)" -ForegroundColor Green
    Write-Host "2. Add path to baseline" -ForegroundColor Green
    Write-Host "3. Check files against baseline" -ForegroundColor Green
    Write-Host "4. Check files against baseline" -ForegroundColor Green
    Write-Host "5. Create a new File" -ForegroundColor Green
    $entry=Read-Host -Prompt "Please enter a selection"

    switch ($entry) {
        "1" { $baselineFilePath=Read-Host -Prompt "Enter the baseline file path"
                if(Test-path -Path $baselineFilePath ){
                    if($baselineFilePath.Substring($baselineFilePath.Length-4,4) -eq ".csv"){

                    }else {
                        $baselineFilePath=""
                        Write-Host "Invalid file needs to a .csv file" -ForegroundColor Red
                    }
                }else {
                    $baselineFilePath=""
                    Write-Host "Invalid file path for baseline"  -ForegroundColor Red
                } 
            }
        "2" { 
            $targetFilePath=Read-Host -Prompt "Enter the path of the file you want to monitor"
            Add-FileToBaseline -baselineFilePath $baselineFilePath -targetFilePath $targetFilePath
         }
        "3" { Verify-Baseline -baselineFilePath $baselineFilePath }
        "4" {
            $email=Read-Host -Prompt "Enter your email " 
            Verify-Baseline -baselineFilePath $baselineFilePath -emailTo $email 
         }
        "5" { 
            $newBaselineFilePath=Read-Host -Prompt "Enter path for now baseline file"
            Create-BaseLine -baselineFilePath $newBaselineFilePath
        }
        "q" {}  
        "quit" {}
        Default {
            Write-Host "Invalid entry" -ForegroundColor Red
        }
    }


 }while($entry -notin @('q','quit'))

#Create-BaseLine -baselineFilePath $baselineFilePath
# Add-FileToBaseLine -baselineFilePath $baselineFilePath -targetFilePath "C:\Users\Anjali Prajapati\OneDrive\Desktop\File Integrity\New folder\Files\text1.txt"

# Verify-BaseLine -baselineFilePath $baselineFilePath -emailTo "anjal2@outlook.com"
