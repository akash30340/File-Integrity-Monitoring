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

        $hash=Get-FileHash -Path $targetFilePath
        "$($targetFilePath),$($hash.hash)" | Out-File -FilePath $baselineFilePath -Append

        Write-Output "Entry successfully added into baseline "
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


$baselineFilePath="C:\Users\Anjali Prajapati\OneDrive\Desktop\File Integrity\baselines.csv"

#Create-BaseLine -baselineFilePath $baselineFilePath

Add-FileToBaseline -baselineFilePath $baselineFilePath -targetFilePath "C:\Users\Anjali Prajapati\OneDrive\Desktop\File Integrity\Files\text3.txt"

Verify-Baseline -baselineFilePath $baselineFilePath



