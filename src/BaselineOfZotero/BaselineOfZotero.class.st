Class {
	#name : #BaselineOfZotero,
	#superclass : #BaselineOf,
	#category : #BaselineOfZotero
}

{ #category : #accessing }
BaselineOfZotero >> baseline: spec [
	<baseline>

	spec for: #'common' do: [

		spec
			baseline: 'OpenAlex' 
			with: [ spec repository: 'github://khinsen/GT-OpenAlex:main/src' ].

		spec 
			package: #'Zotero'
			with: [ spec requires:
						#('OpenAlex') ] ].
]
