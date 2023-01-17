#!/usr/bin/env python3
import sys, getopt, re, plistlib
from composite import Composite

new_version = ''
swift_version = ''
platform_version = ''
selectedComposite = Composite('')

# constants
acs_UI_library_Path = '../'
acs_version_pattern = re.compile(r"\d\.\d\.\d(-[a-zA-Z]+\.\d)?", re.IGNORECASE)
short_version_pattern = re.compile(r"[0-9]+\.[0-9]+", re.IGNORECASE)

# calling
calling_podspec = 'AzureCommunicationUI/sdk/AzureCommunicationUICalling/AzureCommunicationUICalling.podspec'

# chat
chat_podspec = 'AzureCommunicationUI/sdk/AzureCommunicationUICalling/AzureCommunicationUIChat.podspec'


def update(path, replaceFrom, replaceTo):
	with open(path, 'r') as fi:
		s = fi.read()
	with open(path, "w") as fo:
		s = s.replace(replaceFrom, replaceTo)
		fo.write(s)

def extract_string(string, start, end):
	str = "(?s)(?<=%s).*?(?=%s)" % (start, end)
	return re.search(str, string).group()

def update_version():
	local_path = calling_podspec if selectedComposite == Composite.CALLING else chat_podspec
	with open(acs_UI_library_Path + local_path, 'r') as fi_pod:
		s_pod = fi_pod.read()
	segment = extract_string(s_pod, 'spec.version', '\n')
	current_version = acs_version_pattern.search(segment).group()
	update(acs_UI_library_Path + local_path, current_version, new_version)
	print('Step 1 of 3, spec.version updated to ' + new_version + ' from ' + current_version)

def update_swift():
	if swift_version == '':
		print('Step 2 of 3. Skipped')
		return
	local_path_pod = calling_podspec if selectedComposite == Composite.CALLING else chat_podspec
	with open(acs_UI_library_Path + local_path_pod, 'r') as fi_pod:
		s_pod = fi_pod.read()
	segment = extract_string(s_pod, 'spec.swift_version', '\n')
	current_version = short_version_pattern.search(segment).group()
	new_version = swift_version
	update(acs_UI_library_Path + local_path_pod, current_version, new_version)
	print('Step 2 of 3, spec.swift_version updated to ' + new_version + ' from ' + current_version)

def update_platform():
	if platform_version == '':
		print('Step 3 of 3. Skipped')
		return
	local_path_pod = calling_podspec if selectedComposite == Composite.CALLING else chat_podspec
	with open(acs_UI_library_Path + local_path_pod, 'r') as fi_pod:
		s_pod = fi_pod.read()
	segment = extract_string(s_pod, 'spec.platform', '\n')
	current_version = short_version_pattern.search(segment).group()
	new_version = platform_version
	update(acs_UI_library_Path + local_path_pod, current_version, new_version)
	print('Step 3 of 3, spec.platform updated to ' + new_version + ' from ' + current_version)
	
def main(argv):
	try:
		opts, args = getopt.getopt(argv, "hv:c:s:p:", ["help", "version=", "composite=", "swift=", "platform="])
	except getopt.GetoptError:
		sys.exit('Inputs are missing ' +
			'Usage: main-repo-updater.py -c COMPOSITE -v NEW_VERSION -s SWIFT_VERSION -p PLATFORM_VERSION, '+ 
			'where COMPOSITE should be either calling or chat. And -s and -p are optional.')
	for opt, arg in opts:
		if opt == '-h':
			sys.exit('Expected parameters: ' + 
				'1. -c or --composite of options of \'calling\' or \'chat\' ' + 
				'2. -v or --version ' + 
				'3. (optional) -s or --swift ' + 
				'4. (optional) -p or --platform ')
		elif opt in ('-v', '--version '):
			global new_version 
			new_version = arg
		elif opt in ('-c', '--composite'):
			global selectedComposite 
			selectedComposite = Composite(arg)
		elif opt in ('-s', '--swift'):
			global swift_version 
			swift_version = arg
		elif opt in ('-p', '--platform'):
			global platform_version 
			platform_version = arg
	if selectedComposite == Composite.UNKNOWN:
		sys.exit('Error: Composite is Unknown. Supported Composites are \'calling\' and \'chat\'.')
	if swift_version == '':
		print('Warning: No swift version given. Swift version update would be skipped.')
	if platform_version == '':
		print("Warning: No minimum platform version given. Platform update would be skipped. ")
	update_version()
	update_swift()
	update_platform()

main(sys.argv[1:])