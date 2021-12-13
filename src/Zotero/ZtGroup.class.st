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

{ #category : #persistence }
ZtGroup >> cacheDirectory [
	| directory |
	directory := FileLocator home / '.cache' / 'GT-Zotero' / self groupId asString.
	directory ensureCreateDirectory.
	^ directory
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

{ #category : #accessing }
ZtGroup >> version [
	^ (rawData at: #version) asInteger
]
