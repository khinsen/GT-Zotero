Class {
	#name : #ZtUserLibrary,
	#superclass : #ZtLibrary,
	#instVars : [
		'user'
	],
	#category : #Zotero
}

{ #category : #'instance creation' }
ZtUserLibrary class >> user: aZtUser [
	^ self new
		user: aZtUser;
		loadData;
		yourself
]

{ #category : #accessing }
ZtUserLibrary >> cacheDirectory [
	| directory |
	directory := FileLocator home / '.cache' / 'GT-Zotero' / self userId asString.
	directory ensureCreateDirectory.
	^ directory
]

{ #category : #accessing }
ZtUserLibrary >> urlPrefix [
	^ urlPrefix ifNil: [ urlPrefix := 'users/', user userId asString ]
]

{ #category : #accessing }
ZtUserLibrary >> user [
	^ user
]

{ #category : #accessing }
ZtUserLibrary >> user: aZtUser [
	user := aZtUser
]

{ #category : #accessing }
ZtUserLibrary >> userId [
	^ self user userId
]
