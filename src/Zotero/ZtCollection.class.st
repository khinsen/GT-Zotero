Class {
	#name : #ZtCollection,
	#superclass : #ZtEntity,
	#instVars : [
		'library'
	],
	#category : #Zotero
}

{ #category : #converting }
ZtCollection >> asItemGroup [
	^ ZtItemGroup new
		itemTree: self itemTree
]

{ #category : #inspecting }
ZtCollection >> gtItemsFor: aView [
	<gtView>
	^ aView forward
		  title: 'Items';
		  priority: 1;
		  object: [ self asItemGroup ];
		  view: #gtItemsFor:;
		  yourself
]

{ #category : #inspecting }
ZtCollection >> gtSpotterForCreatorsFor: aStep [
	<gtSearch>
	^ self asItemGroup gtSpotterForCreatorsFor: aStep
]

{ #category : #inspecting }
ZtCollection >> gtSpotterForTitlesFor: aStep [
	<gtSearch>
	^ self asItemGroup gtSpotterForTitlesFor: aStep
]

{ #category : #inspecting }
ZtCollection >> gtSpotterForYearsFor: aStep [
	<gtSearch>
	^ self asItemGroup gtSpotterForYearsFor: aStep
]

{ #category : #inspecting }
ZtCollection >> itemTree [
	^ self library topLevelItemsInCollection: self key
]

{ #category : #accessing }
ZtCollection >> library [
	^ library
]

{ #category : #accessing }
ZtCollection >> library: aZtLibrary [
	library := aZtLibrary
]

{ #category : #accessing }
ZtCollection >> name [
	^ (rawData at: #data) at: #name
]

{ #category : #accessing }
ZtCollection >> numberOfChildren [
	^ self numberOfCollections
]

{ #category : #accessing }
ZtCollection >> numberOfCollections [
	^ (rawData at: #meta) at: #numCollections
]

{ #category : #accessing }
ZtCollection >> numberOfItems [
	^ (rawData at: #meta) at: #numItems
]

{ #category : #accessing }
ZtCollection >> parentKey [
	^ (rawData at: #data) at: #parentCollection
		ifPresent: [ :p | p = false ifTrue: [ nil ] ifFalse: [ p ] ]
		ifAbsent: [ nil ]
]

{ #category : #printing }
ZtCollection >> printOn: aStream [
	super printOn: aStream.
	aStream
		<< $(;
		<< self name;
		<< ', ';
		<< self numberOfItems printString;
		<< ' items)'
]

{ #category : #accessing }
ZtCollection >> summary [
	^ self name
]
