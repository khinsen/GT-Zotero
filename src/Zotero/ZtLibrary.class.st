Class {
	#name : #ZtLibrary,
	#superclass : #Object,
	#instVars : [
		'urlPrefix',
		'storage',
		'version',
		'versionFromLastRequest',
		'topLevelItems',
		'items',
		'collections',
		'collectionTree',
		'itemTree',
		'orphanedItemTree'
	],
	#category : #Zotero
}

{ #category : #configuration }
ZtLibrary class >> configurationFile [
	| directory file |
	directory := FileLocator preferences / 'GT-Zotero'.
	directory ensureCreateDirectory.
	file := directory / 'configuration.v1.ston'.
	file exists ifFalse: [
		file writeStreamDo: [ :s |
			STON put: (Dictionary new) onStream:  s] ].
	^ file
]

{ #category : #accessing }
ZtLibrary class >> configureStorage: aZtLocalStorage [
	| configuration |
	configuration := Dictionary
		with: #localStorage -> aZtLocalStorage directory fullName.
	self configurationFile writeStreamDo: [ :s |
		STON put: configuration onStream: s ]
]

{ #category : #accessing }
ZtLibrary >> buildTreeFor: entities [
	| treeIndex tree orphanTreeNode |
	treeIndex := Dictionary new.
	entities keysDo: [ :key |
		treeIndex at: key put: { key. OrderedCollection new } ].
	orphanTreeNode := { nil. OrderedCollection new }.
	tree := OrderedCollection new.
	entities keysAndValuesDo: [ :key :entity |
		| treeNode |
		treeNode := treeIndex at: key.
		entity parentKey
			ifNil: [ tree add: treeNode ]
			ifNotNil: [ :p |
				(treeIndex at: p ifAbsent: [ orphanTreeNode ])
					second add: treeNode ] ].
	tree do: [ :each |
		self replaceKeysIn: each from: entities ].
	orphanTreeNode second do: [ :each |
		self replaceKeysIn: each from: entities ].
	^ { tree. orphanTreeNode second }
]

{ #category : #accessing }
ZtLibrary >> cacheDirectory [
	self subclassResponsibility
]

{ #category : #persistence }
ZtLibrary >> cacheFile [
	^ self cacheDirectory / ('library-', version asString, '.ston')
]

{ #category : #accessing }
ZtLibrary >> childrenOfItem: anItemKey [
	^ (itemTree detect: [ :each | each first key = anItemKey ])
		second
]

{ #category : #accessing }
ZtLibrary >> clientForRequest: path start: firstIndex limit: anInteger [
	^ ZtApiClient new
		beOneShot;
		user: self user;
		path: self urlPrefix, path;
		queryAt: #start put: firstIndex asString;
		queryAt: #limit put: anInteger asString.
]

{ #category : #accessing }
ZtLibrary >> collectionWithKey: aCollectionKey [
	^ self collections at: aCollectionKey
]

{ #category : #accessing }
ZtLibrary >> collections [
	^ (self multiRequest: '/collections') collect: [ :each |
			ZtCollection new
				library: self;
				rawData: each ]
]

{ #category : #initializing }
ZtLibrary >> downloadFromServer [
	| collectionRawData itemRawData completeRawData |
	collectionRawData := self multiRequest: '/collections'.
	itemRawData := self multiRequest: '/items'.
	completeRawData := Dictionary
						with: #collections -> collectionRawData
						with:#items -> itemRawData.
	self initializeFromRawData: completeRawData.
	version := versionFromLastRequest.
	self saveToCache.
]

{ #category : #initializing }
ZtLibrary >> gtCollectionsFor: aView [
	<gtView>
	items ifEmpty: [ ^ aView empty ].
	^ aView columnedTree
		title: 'Collections';
		priority: 0;
		items: [ collectionTree ];
		column: #Collection text: [ :each | each first name ];
		column: 'Items' text: [ :each |
			| n |
			n := each first numberOfItems.
			n = 0 ifTrue: [ '' ] ifFalse: [ n printString ] ];
		children: #second;
		send: #first;
		yourself
]

{ #category : #inspecting }
ZtLibrary >> gtItemsFor: aView [
	<gtView>
	^ aView forward
		  title: 'Items';
		  priority: 1;
		  object: [ ZtItemGroup new itemTree: self itemTree ];
		  view: #gtItemsFor:;
		  yourself
]

{ #category : #inspecting }
ZtLibrary >> gtOrphanedItemsFor: aView [
	<gtView>
	orphanedItemTree ifEmpty: [ ^ aView empty ].
	^ aView forward
		  title: 'Orphaned Items';
		  priority: 2;
		  object: [ ZtItemGroup new itemTree: orphanedItemTree ];
		  view: #gtItemsFor:;
		  yourself
]

{ #category : #accessing }
ZtLibrary >> initialize [
	version := 0.
	collections := Dictionary new.
	items := Dictionary new.
	self loadConfiguration
]

{ #category : #initializing }
ZtLibrary >> initializeFromRawData: aDictionary [ 
	collections := ((aDictionary at: #collections) collect: [ :each |
			(each at: #key)
				-> (ZtCollection new
						library: self;
						rawData: each) ]) asDictionary.
	items := ((aDictionary at: #items) collect: [ :each |
			(each at: #key)
			-> (ZtItem new
					library: self;
					rawData: each) ]) asDictionary.
]

{ #category : #accessing }
ZtLibrary >> itemTree [
	^ itemTree
]

{ #category : #configuration }
ZtLibrary >> loadConfiguration [
	| configuration |
	configuration := self class configurationFile readStreamDo: [ :s |
		STON fromStream: s ].
	configuration at: #localStorage
		ifPresent: [ :path | storage := ZtLocalStorage directory:path asFileReference ]
]

{ #category : #initializing }
ZtLibrary >> loadData [
	| treeData |
	self loadFromCache
		ifTrue: [ self syncWithServer ]
		ifFalse: [ self downloadFromServer].
	treeData := self buildTreeFor: items.
	itemTree := treeData first.
	orphanedItemTree := treeData second.
	treeData := self buildTreeFor: collections.
	collectionTree := treeData first.
	self assert: treeData second size equals: 0
]

{ #category : #accessing }
ZtLibrary >> loadFromCache [
	| cache data |
	cache := self mostRecentCacheFile.
	cache second ifNil: [ ^ false ].
	data := cache second readStreamDo: [ :s | STON fromStream: s ].
	self assert: (data at: #version) equals: 1.
	self initializeFromRawData: data.
	version := cache first.
	^ true
]

{ #category : #persistence }
ZtLibrary >> mostRecentCacheFile [
	| cacheFiles maxVersion maxVersionFile |
	cacheFiles := self cacheDirectory children select: [ :each |
		(each basename beginsWith: 'library-')
		and: [ each basename endsWith: '.ston' ] ].
	maxVersion := 0.
	maxVersionFile := nil.
	cacheFiles do: [ :each |
		| cacheVersion |
		cacheVersion := ((each basename copyAfter: $-) copyUpTo: $.) asInteger.
		cacheVersion > maxVersion ifTrue: [
			maxVersion := cacheVersion.
			maxVersionFile := each ] ].
	^ { maxVersion. maxVersionFile }
]

{ #category : #accessing }
ZtLibrary >> multiRequest: path [
	| dataItems client itemCount |
	dataItems := OrderedCollection new.
	[
		Transcript nextPutAll: 'multiRequest: '; nextPutAll: path; cr.
		client := self clientForRequest: path start: dataItems size limit: 100.
		dataItems addAll: client get.
		itemCount := (client response headers at: 'Total-Results') asInteger.
		Transcript nextPutAll: 'itemCount: '; nextPutAll: itemCount asString; cr.
		Transcript nextPutAll: 'dataItems size: '; nextPutAll: (dataItems size) asString; cr.
		versionFromLastRequest :=
			(client response headers at: 'Last-Modified-Version')
				asInteger.
	dataItems size < itemCount ] whileTrue.
	^ dataItems
]

{ #category : #organizing }
ZtLibrary >> replaceKeysIn: aTreeNode from: entities [
	| entity |
	entity := entities at: aTreeNode first.
	aTreeNode at: 1 put: entity.
	"It seems that in group libraries, the number of children can be greater than
	 the number of child items actually present, so the test below fails."
	self
		assert: entity numberOfChildren
		equals: aTreeNode second size.
	aTreeNode second do: [ :each | self replaceKeysIn: each from: entities ]
]

{ #category : #persistence }
ZtLibrary >> saveToCache [ 
	| data |
	data := Dictionary
			with: #version->1
			with: #collections -> (collections values collect: #rawData)
			with: #items -> (items values collect: #rawData).
	self cacheFile writeStreamDo: [ :s |
		STON put: data onStream: s ]
]

{ #category : #accessing }
ZtLibrary >> storage [
	^ storage
]

{ #category : #accessing }
ZtLibrary >> storage: aZtStorage [
	storage := aZtStorage
]

{ #category : #syncing }
ZtLibrary >> syncWithServer [
	| currentVersions keysToUpdate updates |
	Transcript cr; nextPutAll: 'Collections'; cr.
	currentVersions := self versionsFromServerForPath: '/collections?'.
	Transcript nextPutAll: currentVersions asString; cr.
	keysToUpdate := self update: collections from: currentVersions.
	Transcript nextPutAll: 'Keys: '; nextPutAll: keysToUpdate asString; cr.
	keysToUpdate ifNotEmpty: [
		updates := self multiRequest: ('/collections?collectionKey=',( ',' join: keysToUpdate)).
		updates do: [ :each |
			| key entity |
			key := each at: #key.
			Transcript nextPutAll: 'Updating: '; nextPutAll: key asString; cr.
			entity := collections at: key
						ifAbsent: (ZtCollection new library: self).
			entity rawData: each ] ].

	Transcript cr; nextPutAll: 'Items'; cr.
	currentVersions := self versionsFromServerForPath: '/items?'.
	Transcript nextPutAll: currentVersions asString; cr.
	keysToUpdate := self update: items from: currentVersions.
	Transcript nextPutAll: 'Keys: '; nextPutAll: keysToUpdate asString; cr.
	keysToUpdate ifNotEmpty: [
		| requestPath |
		requestPath := '/items?itemKey=', (',' join: keysToUpdate).
		updates := self multiRequest: requestPath.
		updates do: [ :each |
			| key entity |
			key := each at: #key.
			Transcript nextPutAll: 'Updating: '; nextPutAll: key asString; cr.
			entity := items at: key
						ifAbsent: (ZtItem new library: self) .
			entity rawData: each ] ].

	versionFromLastRequest > version ifTrue: [
		version := versionFromLastRequest.
		self saveToCache ]
]

{ #category : #organizing }
ZtLibrary >> topLevelItemsInCollection: aCollectionKey [
	^ itemTree select: [ :each |
		 each first collectionKeys includes: aCollectionKey ]
]

{ #category : #syncing }
ZtLibrary >> update: entities from: versions [
	| keysToUpdate |
	keysToUpdate := OrderedCollection new.
	versions keysAndValuesDo: [ :key :newVersion |
		entities at: key
			ifPresent: [ :entity |
				entity version = newVersion
					ifFalse: [ keysToUpdate add: key ] ]
			ifAbsent: [ keysToUpdate add: key ] ].
	^ keysToUpdate
]

{ #category : #accessing }
ZtLibrary >> urlPrefix [
	self subclassResponsibility
]

{ #category : #accessing }
ZtLibrary >> user [
	self subclassResponsibility
]

{ #category : #syncing }
ZtLibrary >> versionsFromServerForPath: aString [
	| client versions |
	client :=  ZtApiClient new
		beOneShot;
		user: self user;
		path: self urlPrefix,
			aString, ('since=', version asString), '&format=versions'.
	versions := client get.
	versionFromLastRequest :=
			(client response headers at: 'Last-Modified-Version')
				asInteger.
	^ versions
]
