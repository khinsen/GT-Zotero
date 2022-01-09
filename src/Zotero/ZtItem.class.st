Class {
	#name : #ZtItem,
	#superclass : #ZtEntity,
	#instVars : [
		'library'
	],
	#category : #Zotero
}

{ #category : #accessing }
ZtItem >> children [
	^ (self library childrenOfItem: self key)
		collect: #first
]

{ #category : #accessing }
ZtItem >> collectionKeys [
	^ (rawData at: #data) at: #collections ifAbsent: [ Array new ]
]

{ #category : #accessing }
ZtItem >> creators [
	^ (rawData at: #data) at: #creators
		ifPresent: [ :creators | creators collect: [ :each |
						ZtCreator new rawData: each ] ]
		ifAbsent: [ Array new ]
]

{ #category : #accessing }
ZtItem >> date [
	^ (rawData at: #data) at: #date ifAbsent: [ nil ]
]

{ #category : #accessing }
ZtItem >> doi [
	^ (rawData at: #data) at: #DOI
		ifPresent: [ :doi | doi ifEmpty: [ nil ] ifNotEmpty: [ doi ] ]
		ifAbsent: [ nil ]
]

{ #category : #accessing }
ZtItem >> fileDirectory [
	| directory |
	self library storage ifNil: [ ^ nil ].
	directory := self library storage directoryForKey: self key.
	directory exists ifFalse: [ ^ nil ].
	^ directory
]

{ #category : #inspecting }
ZtItem >> gtActionOpenAlexFor: anAction [
	<gtAction>
	| button |
	self doi ifNil: [ ^ anAction noAction ].
	^ anAction explicit stencil: [
		button := BrButton new.
		button
			aptitude: BrGlamorousButtonWithIconAptitude;
			action:  [ button phlow spawnObject:
						(OAClient new doi: self doi) ];
			icon: OAClient new oaIcon asElement;
			label: 'OpenAlex record' ]
]

{ #category : #inspecting }
ZtItem >> gtActionWebBrowseFor: anAction [
	<gtAction>
	|  button |
	^ self uniqueFileOrDirectory
		ifNil: [ self numberOfChildren = 0
					ifTrue: [ anAction noAction ]
					ifFalse: [ self children first gtActionWebBrowseFor: anAction ] ]
		ifNotNil: [ :fileReference |
			anAction explicit stencil: [
			button := BrButton new.
			button
				aptitude: BrGlamorousButtonWithIconAptitude;
				action:  [ WebBrowser openOn: fileReference fullName ];
				icon: BrGlamorousIcons go asElement;
				label: 'Open in OS' translated ] ]
]

{ #category : #inspecting }
ZtItem >> gtAttachmentsFor: aView [
	<gtView>
	self numberOfChildren = 0 ifTrue: [ ^ aView empty ].
	^ aView forward
		title: 'Attachments';
		priority: 5;
		object: [ ZtItemGroup new itemTree:
					(self library childrenOfItem: self key) ];
		view: #gtItemsFor:;
		yourself
]

{ #category : #inspecting }
ZtItem >> gtCollectionsFor: aView [
	<gtView>
	| collectionKeys |
	collectionKeys := self collectionKeys.
	collectionKeys ifEmpty: [ ^ aView empty ].
	^ aView list
		title: 'Collections';
		priority: 7;
		items: [ collectionKeys collect: [ :each |
				 	self library collectionWithKey:  each ] ];
		itemText: #name;
		yourself
]

{ #category : #inspecting }
ZtItem >> gtCreatorsFor: aView [
	<gtView>
	^ self creators
		ifEmpty: [ aView empty ]
		ifNotEmpty: [ :creators |
			aView list
				title: 'Creators';
				priority: 6;
				items: [ creators ];
				itemText: #name;
				yourself ]
]

{ #category : #inspecting }
ZtItem >> gtFilesFor: aView [
	<gtView>
	^ self fileDirectory
		ifNil: [ aView empty ]
		ifNotNil: [ :directory |
			aView forward
				title: 'Files';
				priority: 5;
				object: [ directory ];
				view: #gtTreeFor:;
				yourself ]
]

{ #category : #inspecting }
ZtItem >> gtSummaryFor: aView [
	<gtView>
	^ aView explicit
		title: 'Summary';
		priority: 0;
		disableAsync;
		stencil: [
			(LeTextSnippet new string: self markdownSummary)
				asPreviewElement ];
			yourself
]

{ #category : #accessing }
ZtItem >> itemType [
	^ (rawData at: #data) at: #itemType
]

{ #category : #accessing }
ZtItem >> library [
	^ library
]

{ #category : #accessing }
ZtItem >> library: aZtLibrary [
	library := aZtLibrary
]

{ #category : #inspecting }
ZtItem >> markdownSummary [
	^ String streamContents: [ :stream |
		self title isEmptyOrNil ifFalse: [
			stream
				<< '**Title:**'; cr; << self title;  cr ].
		stream cr.
		self creators isEmptyOrNil ifFalse: [
			(self creators groupedBy: #creatorType) keysAndValuesDo: [ :type :creators |
				stream << '**'; << type capitalized; << '(s):**'; cr.
				creators do: [ :each | stream << each name; cr ] ].
			stream cr ].
		self date isEmptyOrNil ifFalse: [
			stream << '**Date:** ' << self date; cr ].
		stream cr.
		self doi ifNotNil: [ :doi |
			stream
				<< '**DOI:** [';
				<< doi;
				<< '](http://dx.doi.org/';
				<< doi urlEncoded;
				<< ')';
				cr ].
		self url ifNotNil: [ :url |
			stream
				<< '**URL:** [';
				<< url;
				<< '](';
				<< url;
				<< ')';
				cr ].
		stream cr.
		stream << '**Item type:** ' << self itemType; cr.
		]
]

{ #category : #accessing }
ZtItem >> numberOfChildren [
	^ (rawData at: #meta) at: #numChildren ifAbsent: [ 0 ]
]

{ #category : #accessing }
ZtItem >> parentKey [
	^ (rawData at: #data) at: #parentItem ifAbsent: [ nil ]
]

{ #category : #printing }
ZtItem >> printOn: aStream [
	super printOn: aStream.
	aStream
		<< $(;
		<< self key;
		<< ', ';
		<< self itemType;
		<< $)
]

{ #category : #accessing }
ZtItem >> summary [
	^ self title ifNil: [ self itemType ]
]

{ #category : #accessing }
ZtItem >> title [
	^ (rawData at: #data) at: #title ifAbsent: [ nil ]
]

{ #category : #accessing }
ZtItem >> uniqueFileOrDirectory [
	^ self fileDirectory
		ifNil: [ nil ]
		ifNotNil: [ :directory|
			| files |
			files := directory files reject: [ :each |
				each basename beginsWith: '.' ].
			files size = 1
				ifTrue: [ files first ]
				ifFalse: [ directory ] ]
]

{ #category : #accessing }
ZtItem >> url [
	^ (rawData at: #data) at: #url
		ifPresent: [ :url | url ifEmpty: [ nil ] ifNotEmpty: [ url ] ]
		ifAbsent: [ nil ]
]

{ #category : #accessing }
ZtItem >> year [
	"Very heuristic: the first four-digit sequence in the date is interpreted as a year."
	| digitParser yearParser year |
	^ self date ifNotNil: [ :date |
		digitParser := #digit asPParser.
		yearParser := (digitParser, digitParser, digitParser, digitParser)
					==> [ :node | ('' join: node) asInteger ].
		year := yearParser sea parse: date.
		year isPetit2Failure ifTrue: [ nil ] ifFalse: [ year second ] ]
]
