Class {
	#name : #ZtGroup,
	#superclass : #ZtEntity,
	#instVars : [
		'accessingMember',
		'library'
	],
	#category : #Zotero
}

{ #category : #accessing }
ZtGroup >> accessingMember [
	^ accessingMember
]

{ #category : #accessing }
ZtGroup >> accessingMember: aZtUser [
	accessingMember := aZtUser
]

{ #category : #accessing }
ZtGroup >> groupId [
	^ rawData at: #id
]

{ #category : #accessing }
ZtGroup >> library [
	^ library ifNil: [ library := ZtGroupLibrary group: self ]
]

{ #category : #accessing }
ZtGroup >> name [
	^ (rawData at: #data) at: #name
]

{ #category : #printing }
ZtGroup >> printOn: aStream [
	super printOn: aStream.
	aStream
		<< $(;
		<< self name;
		<< $)
]

{ #category : #syncing }
ZtGroup >> syncWithServerAtVersion: anInteger [
	(rawData at: #version) = anInteger ifTrue: [ ^ self ].
	self notYetImplemented
]
