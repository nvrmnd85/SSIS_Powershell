################### DESCRIPTION ###########
## DEVELOPER: AARON JACKSON
## GitHub: https://github.com/nvrmnd85/SSIS_Powershell/blob/master/SSIS_XML_Update_Version_Number.ps1
## Blog URL: http://www.barkingcat.com.au/index.php/ssis-versioning-powershell/
## DATE: 15/08/2014
## DESC: This script will update all the packages in a given directory and overwrite the version numbers. The helps track releases and bug tracking
## and gives all scripts consistent versions.
## 
## VERSION: 1.0.0
################## END DESCRIPTION ########

## TEST
# .\SSIS_XML_Update_Version_Number.ps1 -Version_Major 0 -Version_Minor 4 -Version_Build 0 -Version_Comments "Test" -Package_Dir "C:\Users\Aaron\Documents\"
##

################ VARIABLES #################
Param (
    [String]
    [ValidateScript({Test-Path $_ -PathType 'Container'})]
    [Parameter(Mandatory = $true)] 
    $Package_Dir,
    
    [String]
    #[Parameter(Mandatory = $true)] 
    $Package_Name,
    
    [Int]
    [Parameter(Mandatory = $true)] 
    $Version_Major,
    
    [Int]
    [Parameter(Mandatory = $true)] 
    $Version_Minor,
    
    [Int]
    [Parameter(Mandatory = $true)] 
    $Version_Build,
    
    [String]
    [Parameter(Mandatory = $true)] 
    $Version_Comments
)
################ END VARIABLES #################

Clear-Host

#Get List of all relevant SSIS Packages
$files = Get-ChildItem $Package_Dir -Filter *.dtsx

#initialise as false
[string]$Correct_Version = "3"
 
#process file by file
foreach($file in $files)
{

    Write-Host "Loading $file"
    ## TODO
    ## PARALLEL PROCESSING.. do each file in a seperate worker thread? - version 2 improvement perhaps

    #get the content of SSIS package as XML
    $dts = New-Object System.Xml.XmlDocument
    $dts.PreserveWhitespace = $true   
    $dts.Load($Package_Dir+$file)

    #create XmlNamespaceManager
    $mng = [System.Xml.XmlNamespaceManager]($dts.NameTable)
    #add a DTS namespace to the XmlNamespaceManager
    $mng.AddNamespace("DTS", "www.microsoft.com/SqlServer/Dts")

    ## Test package is correct version, i.e. SQL Server 2008 R2 format

    $SSIS_Version = $dts.SelectSingleNode("/DTS:Executable/DTS:Property[@DTS:Name='PackageFormatVersion']", $mng)
 
    if ($SSIS_Version.InnerText -eq $Correct_Version)
    {
        $update = $dts.SelectSingleNode("/DTS:Executable/DTS:Property[@DTS:Name='VersionComments']", $mng)    
        $update.InnerText = $Version_Comments  

        $update = $dts.SelectSingleNode("/DTS:Executable/DTS:Property[@DTS:Name='VersionMajor']", $mng)    
        $update.InnerText = $Version_Major 

        $update = $dts.SelectSingleNode("/DTS:Executable/DTS:Property[@DTS:Name='VersionMinor']", $mng)    
        $update.InnerText = $Version_Minor 
    
        $update = $dts.SelectSingleNode("/DTS:Executable/DTS:Property[@DTS:Name='VersionBuild']", $mng)    
        $update.InnerText = $Version_Build 
   
        try
        {
            $dts.Save($Package_Dir+$file)

            Write-Host "$file was updated successfully!"
        }
        catch [system.exception]
        {

            write-host "Exception raised!" -ForegroundColor Red
            write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
            write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red

            Write-Host "$file was not updated!"

        }
   }
   else
   {

        Write-Host "Incompatible version detected"
        Write-Host "$file was not updated!"
   }
    

}