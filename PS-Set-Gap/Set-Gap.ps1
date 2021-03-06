<#
.SYNOPSIS
This script will go through gcode and modify the gap between stacked members.
Please note that this has only been tested with gcode produced from Cura slicer 
with no additional post processing (other than comment based). There is a very 
good chance that this will break any post processing that includes Z moves or 
movement speed changes (E values should be fine).

.DESCRIPTION
The script finds stacked members by evaluating the gap between a Zn-1 and Zn. 
It then flags all occurances of Z afterwards to be incremented by a multiplier
of the added height (original gap height + gap addition) if the difference is
greater than the defined gap height. The supporting 'awk' folder is required
and it must remain in the same directory as the powershell script file. New 
troubleshooting functionality has been added in: the awk script puts a line that
starts with `; PS-SET-GAP => <details>` before each modified line.

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

.PARAMETER $FirstLayerSpeed
Value is in mm/s (NOT mm/min AS IN RAW GCODE). This parameter is optional and
will only adjust the gcode if set. The awk script uses the same criteria to 
determine all the lines of the first layers of each stack member and updates 
the speed accordingly.

.EXAMPLE
Set-Gap.ps1 -Path ..\E3_Verkstan_NA_qty10.gcode `
  -GapHeight 0.32 `
  -GapAddition 0.18
# Produces files: 
# E3_Verkstan_NA_qty10.gcode 
# E3_Verkstan_NA_qty10.gcode.orig 

.EXAMPLE
Set-Gap.ps1 -Path ..\E3_Verkstan_NA_qty10.gcode `
  -GapHeight 0.32 `
  -GapAddition 0.18 `
  -FirstLayerSpeed 15
# Produces files: 
# E3_Verkstan_NA_qty10.gcode 
# E3_Verkstan_NA_qty10.gcode.orig 

#>

param (
  [Parameter(Mandatory=$true)]
  [string]$Path,

  [Parameter(Mandatory=$true)]
  [float]$GapHeight,

  [Parameter(Mandatory=$true)]
  [float]$GapAddition,

  [Parameter()]
  [int]$FirstLayerSpeed
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
If ($FirstLayerSpeed) {
  $FirstLayerSpeed = $FirstLayerSpeed * 60
  $ChangeFirstLayer = 1
} Else {
  $ChangeFirstLayer = 0
}

######################
# AWK Script Section #
######################
#

$AwkScript = @"
BEGIN {
  # FS = '\ '|'F'|'Z' - this is called from the cmdline because of weird here 
  # string behavior.
  PZ = 0;
  CZ = 0;
  MODEL = 0;
  LAYER_COUNT = 0;
  FIRST_MODEL_LAYER = 0;
}

/;LAYER_COUNT.*/ {
  LAYER_COUNT = 1;
}

# Z moves seem to be done by Cura in the following format: 
# G0 F300 X168.458 Y197.031 Z1.12
# `$1 = 'Gg'
# `$2 = '' (null)
# `$3 = 'f' (value of f only)
# `$4 = 'Xx'
# `$5 = 'Yy'
# `$6 = '' (null)
# `$7 = 'z' (value of z only)
LAYER_COUNT && /^G0.*Z/ {
  PZ = CZ
  CZ = `$7;
  if ( CZ - PZ > $GapHeight + 0.1 ) {
    MODEL = MODEL + 1
    FIRST_MODEL_LAYER = 1
  } else {
    FIRST_MODEL_LAYER = 0
  }
  
  ADDER = MODEL * $GapAddition
  NEW_Z = CZ + ADDER;
  print "; PS-SET-GAP => PZ: " PZ ", CZ: " CZ ", ADDER: " ADDER ", NEW_Z: " NEW_Z;
  GAP_LINE =`$1 " F" `$3 " " `$4 " " `$5 " Z" NEW_Z;
  print GAP_LINE;

  next;
}

# First layer speed lines seem to be in the following format: 
# G1 F900 X190.017 Y135.816 E982.01835
# `$1 = 'Gg'
# `$2 = '' (null)
# `$3 = 'f' (value of f only)
# `$4 = 'Xx'
# `$5 = 'Yy'
# `$6 = 'Ee'
$ChangeFirstLayer && FIRST_MODEL_LAYER && /^G1\ F.*X.*E/ {
  print "; PS-SET-GAP => Original speed: " `$3 ", New speed: " $FirstLayerSpeed
  FIRST_LAYER_LINE = `$1 " F" $FirstLayerSpeed " " `$4 " " `$5 " " `$6;
  print FIRST_LAYER_LINE;

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
    -ArgumentList '-F"[\ |F|Z]"',"-f $AwkFile",$Original.FullName `
    -RedirectStandardError ($ScriptDir + "\awk.error") `
    -RedirectStandardOutput $Path `
    -NoNewWindow -Wait

$EndTime = Get-Date

$ExecString = "Execution Time: {0:mm}:{0:ss}" -f ($EndTime - $StartTime)
Write-Host -BackgroundColor DarkBlue -ForegroundColor White $ExecString
