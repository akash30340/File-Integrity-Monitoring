 $baselineFilePath="C:\Users\Anjali Prajapati\OneDrive\Desktop\File Integrity\baselines.csv"


##add a file to baseline.csv
$fileToMonitorPath="C:\Users\Anjali Prajapati\OneDrive\Desktop\File Integrity\Files\text1.txt"
$hash=Get-FileHash -Path $fileToMonitorPath

"$($fileToMonitorPath),$($hash.hash)" | Out-File -FilePath $baselineFilePath -Append

## monitor a file 
$baselineFiles= Import-Csv -Path $baselineFilePath -Delimiter ","

foreach($file in $baselineFiles){
    if(test-Path -Path $file.path){
        $currenthash=Get-FileHash -Path $file.path
        if($currenthash.Hash -eq $file.hash){
            Write-Output "$($file.path) is still the same"
        }
        else{
            Write-Output "$($file.path) hash is different something has changed"
        } 
    }
    else{
        Write-Output "$($file.path) is not found"
    }
    $baselineFilePath="C:\Users\Anjali Prajapati\OneDrive\Desktop\File Integrity\baselines.csv"
}  

    ##add a file to baseline.csv
    $fileToMonitorPath="C:\Users\Anjali Prajapati\OneDrive\Desktop\File Integrity\Files\text1.txt"
    $hash=Get-FileHash -Path $fileToMonitorPath
    
    "$($fileToMonitorPath),$($hash.hash)" | Out-File -FilePath $baselineFilePath -Append
    
    ## monitor a file 
    $baselineFiles= Import-Csv -Path $baselineFilePath -Delimiter ","
    
    foreach($file in $baselineFiles){
        if(test-Path -Path $file.path){
            $currenthash=Get-FileHash -Path $file.path
            if($currenthash.Hash -eq $file.hash){
                Write-Output "$($file.path) is still the same"
            }
            else{
                Write-Output "$($file.path) hash is different something has changed"
            } 
        }
        else{
            Write-Output "$($file.path) is not found"
        }
    }