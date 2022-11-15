# Azure Communication UI Mobile Library Scripts

## Overview

This folder contains a series of scripts that facilitates the release process for UI iOS team. In particular, these scripts are meant to update release version across different files such as README, info plist, pbxproj, etc.


| Name                 | Area        | Link |
|----------------------|-------------|------|
| main-repo-updater.py | Main Repo   | [Go](https://github.com/Azure/communication-ui-library-ios/blob/feature/script-version-update/scripts/main-repo-updater.py)     |
| TBA                  | CocoaPods   | TBA  |
| TBA                  | QuickStarts | TBA  |
| TBA                  | MS Doc      | TBA  |

## Details
#### Main Repo

The ```main-repo-updater.py ``` would perform version update for the following files:
- Info.plist
- DiagnosticConfigTests
- project.pbxproj
- README.md

The script would attempt to find current version from Info.plist by looking for key ```UILibrarySemVersion```. If current versions is identical to the new version, the version update would be skipped.

## Usage:

#### Main Repo

1. make sure this script is located under ```communication-ui-library-ios/scripts``` folder
2. make sure you have ```python3``` installed
3. run ```python3 main-repo-updater.py -v NEW_VERSION``` on your terminal where ```NEW_VERSION``` should be the upcoming release version or ```python3 main-repo-updater.py --version NEW_VERSION```
4. done!
