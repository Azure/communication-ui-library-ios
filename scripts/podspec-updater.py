#!/usr/bin/env python3
import sys, getopt, re, plistlib
from enum import Enum

class Composite(Enum):
	CHAT = 'chat'
	CALLING = 'calling'
	UNKNOWN = ''
	@classmethod
	def _missing_(cls, value):
		for member in cls:
			if member.value == value.lower():
				return member

new_version = ''
selectedComposite = Composite('')

# constants
acs_UI_library_Path = '../'
acs_version_pattern = re.compile(r"\d\.\d\.\d(-[a-zA-Z]+\.\d)?", re.IGNORECASE)
short_version_pattern = re.compile(r"[0-9]+\.[0-9]+", re.IGNORECASE)

# calling
calling_podspec = 'AzureCommunicationUI/sdk/AzureCommunicationUICalling/AzureCommunicationUICalling.podspec'
calling_pbx_path = 'AzureCommunicationUI/sdk/AzureCommunicationUICalling/AzureCommunicationUICalling.xcodeproj/project.pbxproj'

# chat
chat_podspec = 'AzureCommunicationUI/sdk/AzureCommunicationUICalling/AzureCommunicationUIChat.podspec'
chat_pbx_path = 'AzureCommunicationUI/sdk/AzureCommunicationUIChat/AzureCommunicationUIChat.xcodeproj/project.pbxproj'


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
	local_path_pbx = calling_pbx_path if selectedComposite == Composite.CALLING else chat_pbx_path
	local_path_pod = calling_podspec if selectedComposite == Composite.CALLING else chat_podspec
	with open(acs_UI_library_Path + local_path_pod, 'r') as fi_pod:
		s_pod = fi_pod.read()
	segment = extract_string(s_pod, 'spec.swift_version', '\n')
	current_version = short_version_pattern.search(segment).group()
	with open(acs_UI_library_Path + local_path_pbx, 'r') as fi_pbx:
		s_pbx = fi_pbx.read()
	segment = extract_string(s_pbx, 'SWIFT_VERSION', '\n')
	new_version = short_version_pattern.findall(segment)[0]
	update(acs_UI_library_Path + local_path_pod, current_version, new_version)
	print('Step 2 of 3, spec.swift_version updated to ' + new_version + ' from ' + current_version)

def update_platform():
	local_path_pbx = calling_pbx_path if selectedComposite == Composite.CALLING else chat_pbx_path
	local_path_pod = calling_podspec if selectedComposite == Composite.CALLING else chat_podspec
	with open(acs_UI_library_Path + local_path_pod, 'r') as fi_pod:
		s_pod = fi_pod.read()
	segment = extract_string(s_pod, 'spec.platform', '\n')
	current_version = short_version_pattern.search(segment).group()
	with open(acs_UI_library_Path + local_path_pbx, 'r') as fi_pbx:
		s1 = fi_pbx.read()
	segment = extract_string(s1, 'IPHONEOS_DEPLOYMENT_TARGET', '\n')
	new_version = short_version_pattern.findall(segment)[0]
	update(acs_UI_library_Path + local_path_pod, current_version, new_version)
	print('Step 3 of 3, spec.platform updated to ' + new_version + ' from ' + current_version)
	
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
			global new_version 
			new_version = arg
		elif opt in ('-c', '--composite'):
			global selectedComposite 
			selectedComposite = Composite(arg)
	if selectedComposite == Composite.UNKNOWN:
		sys.exit('Composite is Unknown. Supported Composites are \'calling\' and \'chat\'.')
	update_version()
	update_swift()
	update_platform()

main(sys.argv[1:])