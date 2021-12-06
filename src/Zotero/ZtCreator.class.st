Class {
	#name : #ZtCreator,
	#superclass : #Object,
	#instVars : [
		'rawData',
		'name'
	],
	#category : #Zotero
}

{ #category : #comparing }
ZtCreator >> = anObject [
	^ anObject class == self class
		and: [ anObject creatorType = self creatorType
				and: [ anObject name = self name ] ]
]

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
ZtCreator >> hash [
	^ self name hash
]

{ #category : #accessing }
ZtCreator >> isAuthor [
	^ self creatorType = #author
]

{ #category : #accessing }
ZtCreator >> name [
	^ name ifNil: [
		name := rawData at: #name
			ifAbsent: [
				| firstName lastName |
				firstName := rawData at: #firstName.
				lastName := rawData at: #lastName.
				firstName
					ifNotEmpty: [ lastName , ', ' , firstName ]
					ifEmpty: [ lastName ] ] ]
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
