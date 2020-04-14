# jcrmrg-3d-faceshields
## Overview
Jersey City Rapid Makers Response Group - 3D printing files for faceshields  
The JCRMRG is printing faceshields for the local medical establishments to help bolster supplies.

---

### Additional Information
These faceshields can be printed on most 3d printers.  **Please be aware that gcode may not work on, and may possibly damage, other printers**.

<details>
  <summary>Learn how to contribute</summary>

  ## Contribution Instructions

  ### Requirements:
  * Git
  * Cura
  * Write access to the repo (contact @timothyjryan)

  ### Get the repository
  ```
  cd <where to keep local copy>
  git clone https://github.com/JerseyCityRapidMakerResponseGroup/jcrmrg-3d-faceshields
  ```
  ### Edit projects
  *gcode and zips are ignored by git intentionally*
  **Make sure to pull the repository before doing any work**

  `git pull`

  Use Cura to open a project in the projects folder or save a new project to that folder.
  Then push it to the repo.
  
  ```
  git add . # adds everything, alternatively git add <file>
  git commit -m "Some description about the change made to the file"
  git push
  ```

  ### Upload gcode
  Go to the [Releases](https://github.com/JerseyCityRapidMakerResponseGroup/jcrmrg-3d-faceshields/releases) page.  
  Add a new draft. The uploaded file should be a zip of the gcode and the Cura project.  
  **Please be sure that different files have different major version numbers (v1.x, v2.x, etc.).
  This is not exactly how versioning should be used, but it will be the easiest to maintain for our purposes.**

</details>

## Faceshield Models
[Verkstan](https://3dprint.nih.gov/discover/3dpx-013306)  
[Prusa](https://www.prusa3d.com/covid19/)

## File table
All gcode files are in the [Releases](https://github.com/timothyjryan/jcrmrg-3d-faceshields/releases).
Cura project files and gcodes are zipped, but Cura projects can also be found in the projects directory.
The gcodes are set up as releases due to file size restrictions (the gcode files are pretty big).
Please pay attention to the bed size, material type and nozzle size when using Cura projects from this repository.

### Naming Convention

Names will be \<Printer Designation\>\_\<Material\>\_\<Model\>\_\<Model details\>\_qty\<stack quantity\>.\<filetype\>

| Acronym | Type     | Full Name     |
|-------- |--------- |-------------- |
|E3       | Printer  | Ender 3 (Pro) |
|PLA      | Material | PLA           |
|PETG     | Material | PETG          |
  
### Files
*Information below reflects the latest version of the files*
<details>
  <summary>E3_PLA_Verkstan_NA_Stacked_noz0.4mm_qty20</summary>
  
  1. **Description:** #JCRMRG branded 2x10 stack of Verkstan NA 6 hole punch using PLA
  1. **Estimated Time:** 18H37M
  1. **Actual Time:** 
  1. **Additional Notes:**
      1. No slowdown on 1st layer of stacks
      1. 0.4mm Nozzle gcode
      1. Concentric floor        
</details>
