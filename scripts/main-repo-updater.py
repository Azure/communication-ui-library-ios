#!/usr/bin/env python3
import sys, getopt
import plistlib

# parse argument from command line
new_Version = ''

# Start of the script
# gloabl constants
acs_UI_library_Path = '../'
info_plist_path = 'AzureCommunicationUI/sdk/AzureCommunicationUICalling/Sources/Info.plist'
telemetry_Tag_path = 'AzureCommunicationUI/sdk/AzureCommunicationUICalling/Tests/CallCompositeOptions/DiagnosticConfigTests.swift'
pbx_path = 'AzureCommunicationUI/sdk/AzureCommunicationUICalling/AzureCommunicationUICalling.xcodeproj/project.pbxproj'
main_readme_path = 'README.md'
pattern_pod = "pod 'AzureCommunicationUICalling', '%s'"
pattern_telemetry = 'aci110/%s'
pattern_pbx = 'MARKETING_VERSION = %s'

def getCurrentVersion():
	if new_Version == '':
		sys.exit('new version is required for this script.' + 
			' Usage: main-repo-updater.py -v NEW_VERSION')
	with open(acs_UI_library_Path + info_plist_path, 'rb') as fi_info:
		pList = plistlib.load(fi_info)
	oldVersion = pList['UILibrarySemVersion']
	if new_Version == oldVersion:
		print('update skipped, new version and old version are the same')
		sys.exit(0)
	else:
		print("current version is " + oldVersion + 
			", will upgrade it to new version " + new_Version)
	return [pList, oldVersion]

def update(path, replaceFrom, replaceTo):
	with open(path, 'r') as fi:
		s = fi.read()
	with open(path, "w") as fo:
		s = s.replace(replaceFrom, replaceTo)
		fo.write(s)

def main(argv):
	try:
		opts, args = getopt.getopt(argv, "hv:", ["help", "version="])
	except getopt.GetoptError:
		sys.exit('require new version for this script. ' +
			'Usage: main-repo-updater.py -v NEW_VERSION or main-repo-updater.py --version NEW_VERSION')
	for opt, arg in opts:
		if opt == '-h':
			sys.exit('Usage: main-repo-updater.py -v NEW_VERSION or ' + 
				' main-repo-updater.py --version NEW_VERSION')
		elif opt in ('-v', '--version'):
			global new_Version 
			new_Version = arg
	result = getCurrentVersion()
	pList = result[0]
	oldVersion = result[1]
	# telemetry update
	update(acs_UI_library_Path + telemetry_Tag_path, 
		pattern_telemetry % oldVersion, 
		pattern_telemetry % new_Version)
	print("telemetry - done, 1 of 4")
	
	# Readme in main repo
	update(acs_UI_library_Path + main_readme_path, 
		pattern_pod % oldVersion, 
		pattern_pod % new_Version)
	print("readme - done, 2 of 4")
	
	# xcodeproj update
	update(acs_UI_library_Path + pbx_path, 
		pattern_pbx % oldVersion, 
		pattern_pbx % new_Version)
	print("pbxproj - done, 3 of 4")
	
	# Info.plist update
	pList['UILibrarySemVersion'] = new_Version
	with open(acs_UI_library_Path + info_plist_path, 'wb') as fo_info:
		plistlib.dump(pList, fo_info)
	print("plist - done, 4 of 4")

main(sys.argv[1:])

