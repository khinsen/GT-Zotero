Class {
	#name : #ZtItemGroup,
	#superclass : #Object,
	#instVars : [
		'itemTree'
	],
	#category : #Zotero
}

{ #category : #inspecting }
ZtItemGroup >> gtItemsFor: aView [
	<gtView>
	^ aView columnedTree
		  title: 'Items';
		  priority: 1;
		  items: [ self itemTree ];
		  column: #Item text: [ :each | each first summary ];
		  children: #second;
		  send: #first;
		  yourself
]

{ #category : #accessing }
ZtItemGroup >> itemTree [
	^ itemTree
]

{ #category : #accessing }
ZtItemGroup >> itemTree: aSequenceableCollection [
	itemTree := aSequenceableCollection
]

{ #category : #printing }
ZtItemGroup >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	self itemTree size printOn: aStream.
	aStream nextPutAll: ' items)'
]

{ #category : #selecting }
ZtItemGroup >> reject: aBlock [
	^ ZtItemGroup new
		itemTree: (self itemTree reject: [ :each |
						aBlock value: each first ])
]

{ #category : #selecting }
ZtItemGroup >> select: aBlock [
	^ ZtItemGroup new
		itemTree: (self itemTree select: [ :each |
						aBlock value: each first ])
]
