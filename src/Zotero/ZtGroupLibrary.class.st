Class {
	#name : #ZtGroupLibrary,
	#superclass : #ZtLibrary,
	#instVars : [
		'group'
	],
	#category : #Zotero
}

{ #category : #'instance creation' }
ZtGroupLibrary class >> group: aZtGroup [
	^ self new
		group: aZtGroup;
		loadData;
		yourself
]

{ #category : #accessing }
ZtGroupLibrary >> cacheDirectory [
	| directory |
	directory := FileLocator home / '.cache' / 'GT-Zotero' / self groupId asString.
	directory ensureCreateDirectory.
	^ directory
]

{ #category : #accessing }
ZtGroupLibrary >> group [
	^ group
]

{ #category : #accessing }
ZtGroupLibrary >> group: aZtGroup [
	group := aZtGroup
]

{ #category : #accessing }
ZtGroupLibrary >> groupId [
	^ self group groupId
]

{ #category : #accessing }
ZtGroupLibrary >> name [
	^ self group name
]

{ #category : #accessing }
ZtGroupLibrary >> urlPrefix [
	^ urlPrefix ifNil: [ urlPrefix := 'groups/', group groupId asString ]
]

{ #category : #accessing }
ZtGroupLibrary >> user [
	^ self group accessingMember
]
