﻿# Overview
This script will go through gcode and modify the gap between stacked members.  
**Please note that this has only been tested with gcode produced from Cura slicer 
with no additional post processing (other than comment based). There is a very 
good chance that this will break any post processing that includes Z moves or 
movement speed changes (E values should be fine).**

## Description
The script finds stacked members by evaluating the gap between a Z<sub>n-1</sub> and Z<sub>n</sub>. 
**Your gcode must already have a gap in it (gap created in Cura) with a non-zero 
value to work. The script won't be able to differentiate between the stack members 
if there isn't a gap already created by the slicer.** It then flags all occurances of Z afterwards to be incremented by a multiplier of the added height (original gap height + gap addition) if the difference is
greater than the defined gap height. The supporting 'awk' folder is required
and it must remain in the same directory as the powershell script file. **New 
troubleshooting functionality has been added in: the awk script puts a line that
starts with `; PS-SET-GAP => <details>` before each modified line.**

---

### Parameter $Path
This is the gcode file to be edited.  The original file will be unmodified and
renamed with '.orig' appended.  Subsequent calls of this script will overwrite,
without prompting, both the .orig and the .gcode files.

### Parameter $GapHeight
This is the gap height that the models were originally sliced with. The models
have to be sliced with a gap that is a multiplier of the layer height (at least
for Cura) otherwise the slicer will have gaps between some models and no gaps 
between others.

### Parameter $GapAddition
This is the additional gap height that you would like to add between stacked
models.  An original gap height of 0.32 with a gap addition of 0.18 will result
in the gcode having Z moves of 0.5 between models.

### Parameter $FirstLayerSpeed
Value is in mm/s (NOT mm/min AS IN RAW GCODE). This parameter is optional and
will only adjust the gcode if set. The awk script uses the same criteria to 
determine all the lines of the first layers of each stack member and updates 
the speed accordingly.

### Examples
```PowerShell
Set-Gap.ps1 -Path ..\E3_Verkstan_NA_qty10.gcode `
  -GapHeight 0.32 `
  -GapAddition 0.18
# Produces files:
# *E3_Verkstan_NA_qty10.gcode*
# *E3_Verkstan_NA_qty10.gcode.orig* 
```

```PowerShell
Set-Gap.ps1 -Path ..\E3_Verkstan_NA_qty10.gcode `
  -GapHeight 0.32 `
  -GapAddition 0.18 `
  -FirstLayerSpeed 15
# Produces files:
# *E3_Verkstan_NA_qty10.gcode*
# *E3_Verkstan_NA_qty10.gcode.orig* 
```

