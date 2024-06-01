
function Add-FileToBaseline{
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
        return $_.Expection.Message
    }
}

function Verify-Baseline{
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory)]$baselineFilePath
    )

    try{
        if((test-Path -Path $baselineFilePath) -eq $false){
            Write-Error -Message "$baselineFilePath does not exist" -ErrorAction Stop
        }

        $baselineFiles= Import-Csv -Path $baselineFilePath -Delimiter ","

    foreach($file in $baselineFiles){
       if(test-Path -Path $file.path){
            $currenthash=Get-FileHash -Path $file.path
            if($currenthash.Hash -eq $file.hash){
                Write-Output "$($file.path) is still the same"
            }else{
                Write-Output "$($file.path) hash is different something has changed"
            } 
        }else{
            Write-Output "$($file.path) is not found"
        }
    }
    }catch{
        return $_.Expection.Message
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

        "path,hash" | Out-File -FilePath $baselineFilePath -Force
        

    }catch{
        return $_.Expection.Message
    }

}


$baselineFilePath="C:\Users\Anjali Prajapati\OneDrive\Desktop\File Integrity\baselines1.csv" 

Create-BaseLine -baselineFilePath $baselineFilePath

Add-FileToBaseline -baselineFilePath $baselineFilePath -targetFilePath "C:\Users\Anjali Prajapati\OneDrive\Desktop\File Integrity\Files\text1.txt"

Verify-Baseline -baselineFilePath $baselineFilePath
