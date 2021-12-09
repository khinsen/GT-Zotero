Class {
	#name : #ZtUser,
	#superclass : #Object,
	#instVars : [
		'userId',
		'apiToken',
		'storage',
		'groups',
		'username',
		'library'
	],
	#category : #Zotero
}

{ #category : #'instance creation' }
ZtUser class >> username: aString [
	| user |
	user :=  ZtUser new
		username: aString;
		loadCredentials.
	user hasCredentials
		ifTrue: [ user syncGroupsWithServer].
	^ user
]

{ #category : #accessing }
ZtUser >> apiToken [
	^ apiToken
]

{ #category : #accessing }
ZtUser >> apiToken: aString [
	apiToken := aString
]

{ #category : #authentication }
ZtUser >> credentialFile [
	| directory file |
	directory := FileLocator preferences / 'GT-Zotero'.
	directory ensureCreateDirectory.
	file := directory / 'credentials.v1.ston'.
	file exists ifFalse: [
		file writeStreamDo: [ :s |
			STON put: (Dictionary new) onStream:  s] ].
	^ file
]

{ #category : #accessing }
ZtUser >> groupFromServer: anInteger [
	| rawData |
	rawData := ZtApiClient new
		beOneShot;
		user: self;
		path: 'groups/', anInteger asString;
		get.
	^ ZtGroup new
		accessingMember: self;
		rawData: rawData;
		yourself.
]

{ #category : #accessing }
ZtUser >> groupVersionsFromServer [
	^ (ZtApiClient new
		beOneShot;
		user: self;
		path: 'users/', userId asString, '/groups/?format=versions';
		get)
]

{ #category : #accessing }
ZtUser >> groups [
	^ groups
]

{ #category : #accessing }
ZtUser >> groupsFromServer [
	^ (ZtApiClient new
		beOneShot;
		user: self;
		path: 'users/', userId, '/groups';
		get) collect: [ :each |
			ZtGroup new
				accessingMember: self;
				rawData: each;
				yourself ].
]

{ #category : #inspecting }
ZtUser >> gtGroupsFor: aView [
	<gtView>
	groups ifEmpty: [ ^ aView empty ].
	^ aView list
		title: 'Groups';
		priority: 2;
		items: [ groups ];
		itemText: #name;
		yourself
]

{ #category : #inspecting }
ZtUser >> gtLibrariesFor: aView [
	<gtView>
	| libraries |
	libraries := OrderedCollection
		with: { 'User ', username. self }.
	libraries addAll:
		(groups collect: [ :each |
			{ 'Group ', each name. each } ]).
	^ aView list
		title: 'Libraries';
		priority: 1;
		items: [ libraries ];
		itemText: #first;
		send: [ :each | each second library ];
		yourself
]

{ #category : #testing }
ZtUser >> hasCredentials [
	^ userId isNotNil and: [ apiToken isNotNil ]
]

{ #category : #initializing }
ZtUser >> initialize [
	groups := OrderedCollection new
]

{ #category : #accessing }
ZtUser >> library [
	^ library ifNil: [ library := ZtUserLibrary user: self ]
]

{ #category : #authentication }
ZtUser >> loadCredentials [
	| credentials |
	credentials := self credentialFile readStreamDo: [ :s |
		STON fromStream: s ].
	credentials at: username
		ifPresent: [ :c |
			userId := c at: #userId.
			apiToken := c at: #apiToken ]
]

{ #category : #printing }
ZtUser >> printOn: aStream [
	super printOn: aStream.
	aStream
		<< $(;
		<< self username;
		<< $)
]

{ #category : #accessing }
ZtUser >> storeCredentials [
	| credentials |
	credentials := self credentialFile readStreamDo: [ :s |
		STON fromStream: s ].
	credentials
		at: username
		put: (Dictionary
				with: #userId -> userId
				with: #apiToken -> apiToken).
	self credentialFile writeStreamDo: [ :s |
		STON put: credentials onStream: s ]
]

{ #category : #syncing }
ZtUser >> syncGroupsWithServer [
	| versions forDeletion |
	Transcript cr; nextPutAll: 'Syncing groups for '; nextPutAll: self printString; cr.
	versions := self groupVersionsFromServer.
	forDeletion := OrderedCollection new.
	groups do: [ :each |
		versions at: (each groupId asString)
			ifPresent: [ :v |
				Transcript nextPutAll: 'Updating '; nextPutAll: each printString; cr.
				each syncWithServerAtVersion: v ]
			ifAbsent: [ forDeletion add: each ].
		versions removeKey: each groupId asString ].
	forDeletion do: [ :each |
		Transcript nextPutAll: 'Removing '; nextPutAll: each printString; cr.
		groups remove: each ].
	versions associationsDo: [ :each |
		| group |
		group := self groupFromServer: each key asInteger.
		Transcript nextPutAll: 'Adding '; nextPutAll: group printString; cr.
		groups add: group ]
]

{ #category : #accessing }
ZtUser >> userId [
	^ userId
]

{ #category : #accessing }
ZtUser >> userId: aString [
	userId := aString
]

{ #category : #accessing }
ZtUser >> username [
	^ username
]

{ #category : #accessing }
ZtUser >> username: aString [
	username := aString
]
