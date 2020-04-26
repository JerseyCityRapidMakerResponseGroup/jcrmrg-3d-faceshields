<#
.SYNOPSIS
This script will go through gcode and modify the gap between stacked members.

.DESCRIPTION
The script finds stacked members by evaluating the gap between a Zn-1 and Zn. 
It then flags all occurances of Z afterwards to be incremented by a multiplier
of the added height (original gap height + gap addition) if the difference is
greater than the defined gap height. The supporting 'awk' folder is required
and it must remain in the same directory as the powershell script file.

.PARAMETER $Path
This is the gcode file to be edited.  The original file will be unmodified and
renamed with '.orig' appended.  Subsequent calls of this script will overwrite,
without prompting, both the .orig and the .gcode files.

.PARAMETER $GapHeight
This is the gap height that the models were originally sliced with. The models
have to be sliced with a gap that is a multiplier of the layer height (at least
for Cura) otherwise the slicer will have gaps between some models and no gaps 
between others.

.PARAMETER $GapAddition
This is the additional gap height that you would like to add between stacked
models.  An original gap height of 0.32 with a gap addition of 0.18 will result
in the gcode having Z moves of 0.5 between models.

.EXAMPLE
Set-Gap.ps1 -Path ..\E3_Verkstan_NA_qty10.gcode -GapHeight 0.32 -GapAddition 0.18

#>

param (
  [Parameter(Mandatory=$true)]
  [string]$Path,

  [Parameter(Mandatory=$true)]
  [float]$GapHeight,

  [Parameter(Mandatory=$true)]
  [float]$GapAddition

  <# TO-DO
  [Parameter()]
  [float]$FirstLayerSpeed
  #>
)

##########
# Set Up #
##########

$StartTime = Get-Date

# We need this for relative paths
$ScriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

$Awk = $ScriptDir + "\awk\bin\awk.exe"
# $Awk = (Get-ChildItem -Path $Awk).FullName

# Start-process does somthing funny with the here strings and awk can't read
# it correctly, so it's going to get dumped into a file
$AwkFile = $ScriptDir + "\AwkScript.awk"

# Preserver original file
$OrigWorking = Get-ChildItem -Path $Path
$OrigName = $OrigWorking.FullName + ".orig"
Remove-Item -Path $OrigName -Force -ErrorAction Ignore
$Original = Rename-Item -Path $OrigWorking.FullName -NewName ($OrigName) -Force -Passthru

# Need to see if we're modifying the first layer speeds and set a value
# THIS IS A TO-DO
<#
If ($FirstLayerSpeed) {
  $ChangeFirstLayer = 1
} Else {
  $ChangeFirstLayer = 0
}
#>

# Obviously the awk script to find and replace the Z heights
$AwkScript = @"
BEGIN {
  PZ = 0;
  CZ = 0;
  MODEL = 0;
  LAYER_COUNT = 0;
}

/;LAYER_COUNT.*/ {
  LAYER_COUNT = 1;
}

LAYER_COUNT && /^G0.*Z/ {
  PZ = CZ
  CZ = `$2;
  if ( CZ - PZ > $GapHeight + 0.1 ) {
    MODEL = MODEL + 1
  }
  
  ADDER = MODEL * $GapAddition
  a = CZ + ADDER;
  b =`$1 FS a;
  print b;

  next;
}

1 {print}
"@

Set-Content -Path $AwkFile -Value $AwkScript

####################
# Start Processing #
####################

# Show our awk visibly for ease of use
Write-Host -BackgroundColor DarkBlue -ForegroundColor White `
            "Original File: $($Original.FullName)"
Write-Host -BackgroundColor DarkBlue -ForegroundColor White `
            "Generated Awk:`n$AwkScript"

# Actually make the substitutions
Start-Process -FilePath $Awk `
    -ArgumentList "-F","Z","-f $AwkFile",$Original.FullName `
    -RedirectStandardError ($ScriptDir + "\awk.error") `
    -RedirectStandardOutput $Path `
    -NoNewWindow -Wait

$EndTime = Get-Date

$ExecString = "Execution Time: {0:mm}:{0:ss}" -f ($EndTime - $StartTime)
Write-Host -BackgroundColor DarkBlue -ForegroundColor White $ExecString
