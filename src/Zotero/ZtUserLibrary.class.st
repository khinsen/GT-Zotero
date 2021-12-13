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

{ #category : #persistence }
ZtUserLibrary >> cacheDirectory [
	^ self user cacheDirectory
]

{ #category : #accessing }
ZtUserLibrary >> name [
	^ self user username
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
