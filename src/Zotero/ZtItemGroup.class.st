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
