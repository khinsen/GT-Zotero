Class {
	#name : #ZtEntity,
	#superclass : #Object,
	#instVars : [
		'rawData',
		'timeStamp'
	],
	#category : #Zotero
}

{ #category : #accessing }
ZtEntity >> gtJsonDataFor: aView [
	<gtView>
	^ aView forward
		title: 'JSON Data';
		priority: 10;
		object: [ rawData ];
		view: #gtTreeFor:;
		yourself
]

{ #category : #accessing }
ZtEntity >> key [
	^ rawData at: #key
]

{ #category : #initializing }
ZtEntity >> key: aString [
	"Initialize an entity to be filled with data later."
	self rawData:
		(Dictionary
			with: #key -> aString
			with: #version -> 0)
]

{ #category : #accessing }
ZtEntity >> rawData [
	^ rawData
]

{ #category : #initializing }
ZtEntity >> rawData: aDictionary [
	rawData := aDictionary.
	timeStamp := DateAndTime now
]

{ #category : #accessing }
ZtEntity >> version [
	^ rawData at: #version
]
