Class {
	#name : #ZtCreator,
	#superclass : #Object,
	#instVars : [
		'rawData'
	],
	#category : #Zotero
}

{ #category : #accessing }
ZtCreator >> creatorType [
	^ rawData at: #creatorType
]

{ #category : #inspecting }
ZtCreator >> gtJsonDataFor: aView [
	<gtView>
	^ aView forward
		title: 'JSON Data';
		priority: 10;
		object: [ rawData ];
		view: #gtTreeFor:;
		yourself
]

{ #category : #accessing }
ZtCreator >> isAuthor [
	^ self creatorType = #author
]

{ #category : #accessing }
ZtCreator >> name [
	^ rawData at: #name
		ifAbsent: [ (rawData at: #lastName), ', ', (rawData at: #firstName) ]
]

{ #category : #accessing }
ZtCreator >> printOn: aStream [
	super printOn: aStream.
	aStream
		<< $(;
		<< (rawData at: #creatorType);
		<< ': ';
		<< self name;
		<< $)
]

{ #category : #accessing }
ZtCreator >> rawData [
	^ rawData
]

{ #category : #accessing }
ZtCreator >> rawData: aDictionary [
	rawData := aDictionary 
]
