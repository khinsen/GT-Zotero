Class {
	#name : #ZtLocalStorage,
	#superclass : #ZtStorage,
	#instVars : [
		'directory'
	],
	#category : #Zotero
}

{ #category : #accessing }
ZtLocalStorage class >> directory: aFileReference [
	^ self new
		directory: aFileReference;
		yourself
]

{ #category : #accessing }
ZtLocalStorage >> directory [
	^ directory
]

{ #category : #accessing }
ZtLocalStorage >> directory: aFileReference [
	directory := aFileReference
]

{ #category : #accessing }
ZtLocalStorage >> directoryForKey: aString [
	^ directory / aString
]

{ #category : #inspecting }
ZtLocalStorage >> gtActionWebBrowseFor: anAction [
	<gtAction>
	|  button |
	^ anAction explicit stencil: [
		button := BrButton new.
		button
			aptitude: BrGlamorousButtonWithIconAptitude;
			action:  [ WebBrowser openOn: directory fullName ];
			icon: BrGlamorousIcons go asElement;
			label: 'Open in OS' translated ]
]

{ #category : #inspecting }
ZtLocalStorage >> gtFileTreeFor: aView [
	<gtView>
	^ aView forward
		title: 'Files';
		priority: 0;
		object: [ directory ];
		view: #gtTreeFor:;
		yourself
]

{ #category : #accessing }
ZtLocalStorage >> printOn: aStream [
	super printOn: aStream.
	aStream
		<< $(;
		<< self directory fullName;
		<< $)
]
