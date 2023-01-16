# Azure Communication UI Mobile Library Scripts

## Overview

This ```script``` folder contains a list of scripts that facilitates the release process for UI iOS team. In particular, these scripts are meant to update release version across different files such as README, info plist, pbxproj, etc.

| Name                 | Area        | Link |
|----------------------|-------------|------|
| main-repo-updater.py | Main Repo | [Go](main-repo-updater.py)     |
| podspec-updater.py                  | PodSpec  |[Go](podspec-updater.py)  |
| TBA                  | QuickStarts | TBA  |
| TBA                  | MS Doc      | TBA  |
| TBA                  | Hero Samples| TBA  |

## Main Repo Script
#### Details

The ```main-repo-updater.py ``` would perform version update for the following files:
- Info.plist
- DiagnosticConfigTests
- project.pbxproj
- README.md

The script would attempt to find current version from Info.plist by looking for key ```UILibrarySemVersion```. If current versions is identical to the new version, the version update would be skipped.

#### Usage:

1. make sure this script is located under ```communication-ui-library-ios/scripts``` folder
2. make sure you have ```python3``` installed
3. run the command:
    - ```python3 main-repo-updater.py -c <COMPOSITE> -v <NEW_VERSION>``` or 
    - ```python3 main-repo-updater.py --composite <COMPOSITE> --version <NEW_VERSION>``` in your terminal
    - where ```<NEW_VERSION>``` should be the upcoming release version and `<COMPOSITE>` should be the type of composite with options of `calling` and `chat` (case insensitive).
4. done!


## PodSpec Script
#### Details

The ```podspec-updater.py ``` would perform version update for the following files:
- AzureCommunicationUI/sdk/AzureCommunicationUICalling/AzureCommunicationUICalling.podspec
- AzureCommunicationUI/sdk/AzureCommunicationUICalling/AzureCommunicationUIChat.podspec

In addition, the script would update the following sections:
- spec.version
- spec.source
- spec.swift_version  
- spec.platform

#### Usage:

1. make sure this script is located under ```communication-ui-library-ios/scripts``` folder
2. make sure you have ```python3``` installed
3. run the command:
    - ```python3 podspec-updater.py -c <COMPOSITE> -v <NEW_VERSION> -s <SWIFT_VERSION> -p <PLATFORM_VERSION>``` or 
    - ```python3 podspec-updater.py --composite <COMPOSITE> --version <NEW_VERSION> --swift <SWIFT_VERSION> --platform <PLATFORM_VERSION>``` in your terminal
    - where ```<NEW_VERSION>``` should be the upcoming release version and `<COMPOSITE>` should be the type of composite with options of `calling` and `chat` (case insensitive). 
    - swift version and platform version are optional, if there are not given, then script would not update them. 
4. done!
