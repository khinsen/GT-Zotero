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
			package: #'Zotero'. ].
]
