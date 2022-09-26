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
ZtItemGroup >> gtSpotterForCreatorsFor: aSearch [
	<gtSearch>
	^ aSearch list
		priority: 2;
		title: 'Creators';
		items: [ | byCreator |
			byCreator := Dictionary new.
			itemTree
				do: [ :eachNode | 
					eachNode first creators
						do: [ :eachCreator | 
							(byCreator at: eachCreator name ifAbsentPut: [ OrderedCollection new ])
								add: eachNode ] ].
			byCreator associations
				collect: [ :each | 
					ZtItemGroup new
						itemTree: each value;
						label: each key;
						yourself ] ];
		filterBySubstring;
		itemName: #label
]

{ #category : #inspecting }
ZtItemGroup >> gtSpotterForTitlesFor: aSearch [
	<gtSearch>
	^ aSearch list
		priority: 1;
		title: 'Titles';
		items: [ itemTree collect: #first ];
		filterBySubstring;
		itemName: #title;
		filter: (GtSpotterSubstringFilter new itemString: #title)
]

{ #category : #inspecting }
ZtItemGroup >> gtSpotterForYearsFor: aSearch [
	<gtSearch>
	^ aSearch list
		priority: 3;
		title: 'Years';
		items: [ (itemTree groupedBy: [ :each | each first year ]) associations
				collect: [ :each | 
					ZtItemGroup new
						itemTree: each value;
						label: each key asString;
						yourself ] ];
		filterBySubstring;
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
