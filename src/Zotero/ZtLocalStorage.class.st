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
