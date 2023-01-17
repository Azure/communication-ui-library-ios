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

