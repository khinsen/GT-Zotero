Class {
	#name : #ZtApiClient,
	#superclass : #ZnClient,
	#instVars : [
		'ztUser'
	],
	#category : #Zotero
}

{ #category : #accessing }
ZtApiClient >> initialize [
	super initialize.
	self
		https;
		host: 'api.zotero.org';
		headerAt: 'Zotero-API-Version' put: '3';
		queryAt: 'format' put: 'json';
		contentReader: [ :entity | NeoJSONReader fromString: entity contents ].
]

{ #category : #accessing }
ZtApiClient >> user: aZtUser [
	ztUser := aZtUser.
	self headerAt: 'Zotero-API-Key' put: ztUser apiToken.
]
