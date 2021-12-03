Class {
	#name : #ZtSchema,
	#superclass : #Object,
	#instVars : [
		'itemTypes',
		'creatorFields'
	],
	#category : #'Zotero-Zotero'
}

{ #category : #accessing }
ZtSchema >> cacheFile [
	| directory |
	directory := FileLocator home / '.cache' / 'GT-Zotero'.
	directory ensureCreateDirectory.
	^ directory / 'schema.ston'
]

{ #category : #accessing }
ZtSchema >> creatorFields [
	^ creatorFields
]

{ #category : #initialization }
ZtSchema >> getCreatorFields [
	creatorFields :=
		((ZtApiClient new
			beOneShot;
			path: 'creatorFields';
			get) collect: [ :each |
				(each at: #field)
				-> (Dictionary with:
					#localized -> (each at: #localized))])
			asDictionary
]

{ #category : #initialization }
ZtSchema >> getItemTypeCreatorTypes [
	itemTypes keysAndValuesDo: [ :eachItemType :eachDictionary |
		(ZtApiClient new
			beOneShot;
			path: 'itemTypeCreatorTypes?itemType=', eachItemType;
			get) do: [ :eachFieldData |
				eachDictionary
					at: #creatorTypes
					put: (Dictionary
							with: #creatorType -> (eachFieldData at: #creatorType)
							with: #localized -> (eachFieldData at: #localized)) ] ]
]

{ #category : #initialization }
ZtSchema >> getItemTypes [
	itemTypes :=
		((ZtApiClient new
			beOneShot;
			path: 'itemTypes';
			get) collect: [ :each |
				(each at: #itemType)
				-> (Dictionary with:
					#localized -> (each at: #localized))])
			asDictionary
]

{ #category : #initialization }
ZtSchema >> getTypeItemFields [
	itemTypes keysAndValuesDo: [ :eachItemType :eachDictionary |
		| validFields |
		validFields := OrderedCollection new.
		eachDictionary at: #validFields put: validFields.
		(ZtApiClient new
			beOneShot;
			path: 'itemTypeFields?itemType=', eachItemType;
			get) do: [ :eachFieldData |
				validFields add:
					(Dictionary
						with: #field -> (eachFieldData at: #field)
						with: #localized -> (eachFieldData at: #localized) ) ] ]
]

{ #category : #initialization }
ZtSchema >> initialize [
	self loadFromCache.
	itemTypes ifNil: [
		self getItemTypes.
		self getTypeItemFields.
		self getItemTypeCreatorTypes.
		self getCreatorFields.
		self storeInCache ]
]

{ #category : #accessing }
ZtSchema >> itemTypes [
	^ itemTypes
]

{ #category : #persistence }
ZtSchema >> loadFromCache [
	| file schema |
	file := self cacheFile.
	file exists ifTrue: [
		schema := file readStreamDo: [ :s |
			STON fromStream: s ].
		itemTypes := schema at: #itemTypes.
		creatorFields := schema at: #creatorFields ]
]

{ #category : #persistence }
ZtSchema >> storeInCache [
	| schema |
	schema := Dictionary
				with: #itemTypes -> itemTypes
				with: #creatorFields -> creatorFields.	
	self cacheFile writeStreamDo: [ :s |
		STON put: schema onStream: s ]
]
