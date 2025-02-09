Class {
	#name : #SpecProcessBrowserTest,
	#superclass : #TestCase,
	#instVars : [
		'browser'
	],
	#category : #'Tools-ProcessBrowser-Tests'
}

{ #category : #'set up' }
SpecProcessBrowserTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."

	browser := SpecProcessBrowser new
]

{ #category : #tests }
SpecProcessBrowserTest >> testProcessesAreArrangedAccordingToPriority [
	browser processList allButFirst
		inject: browser processList first
		into: [ :front :process | 
			self assert: front priority >= process priority.
			process ]
]

{ #category : #tests }
SpecProcessBrowserTest >> testRawProcessList [
	| processList oldProcessListSize semaphore newProcess oldProcessList |
	"Build the list of all the instances of Process"
	oldProcessList := Process allSubInstances
		reject: [ :each | each isTerminated ].
	"Store how many processes there are"
	oldProcessListSize := oldProcessList size.

	"Create a new process that will stay alive"
	semaphore := Semaphore new.
	newProcess := [ semaphore signal.
	Semaphore new wait ] fork.
	"Wait for the process above to have started, just to be sure"
	semaphore wait.

	"Rebuild the list of all instances of Process"
	processList := Process allSubInstances
		reject: [ :each | each isTerminated ].
	"Check that the size of this new process list is one greater than the stored value"
	self assert: processList size equals: oldProcessListSize + 1.
	"Check that the new process list does indeed include the new process we just created"
	self assert: (processList includes: newProcess).
]

{ #category : #tests }
SpecProcessBrowserTest >> testUpdateListButtonIsClicked [
	| newProcess oldProcessListSize semaphore oldProcessList |
	"Build the list of all the instances of Process"
	oldProcessList := browser processList.
	"Store how many processes there are"
	oldProcessListSize := oldProcessList size.

	"Create a new process that will stay alive"
	semaphore := Semaphore new.
	newProcess := [ semaphore signal.
	Semaphore new wait ] fork.
	"Wait for the process above to have started, just to be sure"
	semaphore wait.
	browser updateButton performAction.

	"Check that the size of this new process list is one greater than the stored value"
	self assert: browser processList size equals: oldProcessListSize + 1.
	"Check that the new process list does indeed include the new process we just created"
	self assert: (browser processList includes: newProcess)
]

{ #category : #tests }
SpecProcessBrowserTest >> testUpdateListButtonIsNotClicked [
	| newProcess oldProcessListSize semaphore oldProcessList nowProcessList |
	"Build the list of all the instances of Process"
	oldProcessList := browser processList.
	"Store how many processes there are"
	oldProcessListSize := oldProcessList size.

	"Create a new process that will stay alive"
	semaphore := Semaphore new.
	newProcess := [ semaphore signal.
	Semaphore new wait ] fork.
	"Wait for the process above to have started, just to be sure"
	semaphore wait.

	"The update List Button is not clicked, Process List is not updated."
	nowProcessList := Process allSubInstances
		reject: [ :each | each isTerminated ].
	"Check that the size of this new process list is equal to the stored value"
	self assert: browser processList size equals: oldProcessListSize.
	"Check that the new process list does not include the new process we just created"
	self assert: (browser processList includes: newProcess) equals: false
]
