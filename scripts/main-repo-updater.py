#!/usr/bin/env python3
import sys, getopt, re
import plistlib
from composite import Composite

# parse argument from command line
new_Version = ''
selectedComposite = Composite('')

# Start of the script
# gloabl constants
acs_UI_library_Path = '../'

# Calling (Swift Package Manager)
calling_version_path = 'AzureCommunicationUI/sdk/AzureCommunicationUICalling/Sources/CallCompositeOptions/CallCompositeVersion.swift'
calling_telemetry_Tag_path = 'AzureCommunicationUI/sdk/AzureCommunicationUICalling/Tests/CallCompositeOptions/DiagnosticConfigTests.swift'
calling_main_readme = 'AzureCommunicationUI/sdk/AzureCommunicationUICalling/README.md'
calling_pattern_version = 'static let semVersion = "%s"'
calling_pattern_spm = 'from: "%s"'
calling_pattern_telemetry = 'aci110/%s'

# Chat
chat_info_plist_path = 'AzureCommunicationUI/sdk/AzureCommunicationUIChat/Sources/Info.plist'
chat_telemetry_Tag_path = 'AzureCommunicationUI/sdk/AzureCommunicationUIChat/Tests/ChatCompositeOptions/DiagnosticConfigTests.swift'
chat_pbx_path = 'AzureCommunicationUI/sdk/AzureCommunicationUIChat/AzureCommunicationUIChat.xcodeproj/project.pbxproj'
chat_main_readme = 'AzureCommunicationUI/sdk/AzureCommunicationUIChat/README.md'
chat_pattern_pod = "pod 'AzureCommunicationUIChat', '%s'"
chat_pattern_telemetry = 'aci120/%s'

# Common
pattern_pbx = 'MARKETING_VERSION = %s'

def getCurrentVersion():
	if new_Version == '':
		sys.exit('new version is required for this script.' + 
			' Usage: main-repo-updater.py -v NEW_VERSION')
	if selectedComposite == Composite.CALLING:
		pList = None
		with open(acs_UI_library_Path + calling_version_path, 'r') as fi_version:
			oldVersion = re.search(calling_pattern_version % '(.*)', fi_version.read()).group(1)
	else:
		with open(acs_UI_library_Path + chat_info_plist_path, 'rb') as fi_info:
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
	with open(path, 'r+') as f:
		s = f.read()
		f.seek(0)
		s = s.replace(replaceFrom, replaceTo)
		f.write(s)
		f.truncate()

def main(argv):
	try:
		opts, args = getopt.getopt(argv, "hv:c:", ["help", "version=", "composite="])
	except getopt.GetoptError:
		sys.exit('Inputs are missing ' +
			'Usage: main-repo-updater.py -c COMPOSITE -v NEW_VERSION, where COMPOSITE should be either calling or chat.')
	for opt, arg in opts:
		if opt == '-h':
			sys.exit('Expected parameters: 1. -c or --composite of options of CALLING or CHAT 2. -v or --version')
		elif opt in ('-v', '--version'):
			global new_Version 
			new_Version = arg
		elif opt in ('-c', '--composite'):
			global selectedComposite 
			selectedComposite = Composite(arg)
	if selectedComposite == Composite.UNKNOWN:
		sys.exit('Composite is Unknown. Supported Composites are \'calling\' and \'chat\'.')
	result = getCurrentVersion()
	pList = result[0]
	oldVersion = result[1]

	# telemetry update, supports '-beta.1' syntax
	telemetry = calling_telemetry_Tag_path if selectedComposite == Composite.CALLING else chat_telemetry_Tag_path
	telemetry_pattern = calling_pattern_telemetry if selectedComposite == Composite.CALLING else chat_pattern_telemetry
	update(acs_UI_library_Path + telemetry, 
		telemetry_pattern % oldVersion, 
		telemetry_pattern % new_Version)
	print("telemetry - done, 1 of %d" % (3 if selectedComposite == Composite.CALLING else 4))

	if selectedComposite == Composite.CALLING:
		# readme update, only the Swift Package Manager dependency snippet
		update(acs_UI_library_Path + calling_main_readme,
			calling_pattern_spm % oldVersion,
			calling_pattern_spm % new_Version)
		print("readme - done, 2 of 3")

		# version constant update, supports '-beta.1' syntax
		update(acs_UI_library_Path + calling_version_path,
			calling_pattern_version % oldVersion,
			calling_pattern_version % new_Version)
		print("CallCompositeVersion.swift - done, 3 of 3")
		return

	# readme update, supports '-beta.1' syntax
	update(acs_UI_library_Path + chat_main_readme, 
		oldVersion, 
		new_Version)
	print("readme - done, 2 of 4")
	
	# xcodeproj update, does not support '-beta.1' syntax
	# need to remove '-beta.1'
	release_tag_pattern = '-beta'
	oldVersion_stripped = oldVersion.split(release_tag_pattern, 1)[0]
	newVersion_stripped = new_Version.split(release_tag_pattern, 1)[0]
	update(acs_UI_library_Path + chat_pbx_path, 
		pattern_pbx % oldVersion_stripped, 
		pattern_pbx % newVersion_stripped)
	print("pbxproj - done, 3 of 4")
	
	# Info.plist update, supports '-beta.1' syntax
	pList['UILibrarySemVersion'] = new_Version
	with open(acs_UI_library_Path + chat_info_plist_path, 'wb') as fo_info:
		plistlib.dump(pList, fo_info)
	print("plist - done, 4 of 4")

main(sys.argv[1:])

