Class {
	#name : #ZtItemGroup,
	#superclass : #Object,
	#instVars : [
		'itemTree',
		'label'
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

{ #category : #inspecting }
ZtItemGroup >> gtSpotterForTitlesFor: aStep [
	<gtSearch>
	^ aStep listProcessor
		priority: 1;
		title: 'Titles';
		allCandidates: [ itemTree collect: #first ];
		filter: GtFilterSubstring;
		candidatesLimit: 10;
		itemName: #title
]

{ #category : #inspecting }
ZtItemGroup >> gtSpotterForYearsFor: aStep [
	<gtSearch>
	^ aStep listProcessor
		priority: 2;
		title: 'Years';
		allCandidates: [
			(itemTree groupedBy: [ :each | each first year ])
				associations collect: [ :each |
					ZtItemGroup new
						itemTree: each value;
						label: each key asString;
						yourself ] ];
		filter: GtFilterSubstring;
		candidatesLimit: 5;
		itemName: #label
]

{ #category : #accessing }
ZtItemGroup >> itemTree [
	^ itemTree
]

{ #category : #accessing }
ZtItemGroup >> itemTree: aSequenceableCollection [
	itemTree := aSequenceableCollection
]

{ #category : #accessing }
ZtItemGroup >> label [
	^ label
]

{ #category : #accessing }
ZtItemGroup >> label: aString [
	label := aString
]

{ #category : #printing }
ZtItemGroup >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	self label ifNotNil: [ :aString |
		aStream nextPutAll: aString.
		aStream nextPutAll: ', ' ].
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
