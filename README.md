# Preprocess fnirs data with homer3 without GUI

Script collection intended to faciliate preprossing nirs data (in snirf files) with homer3 functions without the use of homer3 gui. Current implementation is in fetal state and limited to our specific pipeline/setting, though it can be modified to use another pipeline.

## How to use

The fnirs data should be stored in the standard homer3 folder structure containing .snirf files (for having compatibility with the homer3 gui), ie a group folder that contains subfolders for each subject, each containing snirf files, one for each run of that subject. The output folder is advised to be called homerOutput (or can be renamed after or the data copied there after) if homer3 gui is to be used to visualise the processed data after.

The main preprocessing file is `fnirsPreproc.m` which is called with a `settings` structure with project-specific settings. For details see the demo in the parent folder.

Of course, homer3 has to be installed (preferably on a folder next to the folder containing this repository). "Setpath.m" needs to be called. **Tested and working with Homer3 version 1.36.8 of the development branch ** (though hopefully updating to newer  homer3 version will not break things).

## Why to use

Advantages compared to stantard preprocessing through homer3 GUI:
- Better control of the pipeline
- Better ability to visualise specific steps in the pipeline
- Parallel processing implementation for speeding up computations significantly in modern CPUs.
- Improved compatibility to use with high performance cloud computing services.

## Compatibility of output with homer3 gui

The output is exported in the standared homerOutput file/folder structure, and can be easily used in Homer3 gui to visualise the data after preprocessing (though always be mindful of possibility of bugs in homer3 gui plotting).

## Current limitations

- Currently there is a specific pipeline (basically in the run level) called through `runPreproc.m`, the only we currently use in our lab. However, this can be modified or used as a base for implementing different pipelines.
- The preprocessing on "session" level of homer3 is not really supported, though it could be included if needed with some reasonably simple modifications on the code.


## Future to-do plan

- Adding visualisation options between preprocessing steps.
- Adding a more generalised way to implement pipelines than rewriting the base code.
- Adding a "settings" class with specific fields instead of using a general matlab structure.
- Better documentation

## Note from author

Contributions/pull requests/coauthorship/suggestions/issue reports etc all welcome. Imo a complete and easy to re-use, non-graphical homer3 preprocessing implementation would be useful for many, esp as certain lengthy computations (like wavelet transformation) on large datasets can be only reasonably exectured on a high performance cloud computing service.


© 2022 Dimitris Askitis

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.