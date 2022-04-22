package sequence_execution

import (
	"encoding/json"
	keptnv2 "github.com/keptn/go-utils/pkg/lib/v0_2_0"
	"github.com/keptn/keptn/shipyard-controller/models"
)

type SequenceExecution struct {
	ID string `json:"_id" bson:"_id"`
	// Sequence contains the complete sequence definition
	Sequence keptnv2.Sequence        `json:"sequence" bson:"sequence"`
	Status   SequenceExecutionStatus `json:"status" bson:"status"`
	Scope    models.EventScope       `json:"scope" bson:"scope"`
	// InputProperties contains properties of the event which triggered the task sequence
	InputProperties string `json:"inputProperties" bson:"inputProperties"`
}

type SequenceExecutionStatus struct {
	State string `json:"state" bson:"state"` // triggered, waiting, suspended (approval in progress), paused, finished, cancelled, timedOut
	// StateBeforePause is needed to keep track of the state before a sequence has been paused. Example: when a sequence has been paused while being queued, and then resumed, it should not be set to started immediately, but to the state it had before
	StateBeforePause string `json:"stateBeforePause" bson:"stateBeforePause"`
	// PreviousTasks contains the results of all completed tasks of the sequence
	PreviousTasks []TaskExecutionResult `json:"previousTasks" bson:"previousTasks"`
	// CurrentTask represents the state of the currently active task
	CurrentTask TaskExecutionState `json:"currentTask" bson:"currentTask"`
}

type TaskExecutionResult struct {
	Name        string             `json:"name" bson:"name"`
	TriggeredID string             `json:"triggeredID" bson:"triggeredID"`
	Result      keptnv2.ResultType `json:"result" bson:"result"`
	Status      keptnv2.StatusType `json:"status" bson:"status"`
	// Properties contains the aggregated results of the task's executors
	Properties string `json:"properties" bson:"properties"`
}

type TaskExecutionState struct {
	Name        string      `json:"name" bson:"name"`
	TriggeredID string      `json:"triggeredID" bson:"triggeredID"`
	Events      []TaskEvent `json:"events" bson:"events"`
}

type TaskEvent struct {
	EventType  string             `json:"eventType" bson:"eventType"`
	Source     string             `json:"source" bson:"source"`
	Result     keptnv2.ResultType `json:"result" bson:"result"`
	Status     keptnv2.StatusType `json:"status" bson:"status"`
	Time       string             `json:"time" bson:"time"`
	Properties string             `json:"properties" bson:"properties"`
}

func FromSequenceExecution(se models.SequenceExecution) (*SequenceExecution, error) {
	inputPropertiesJsonString, err := json.Marshal(se.InputProperties)
	if err != nil {
		return nil, err
	}
	newSE := &SequenceExecution{
		ID:              se.ID,
		Sequence:        se.Sequence,
		Status:          SequenceExecutionStatus{},
		Scope:           se.Scope,
		InputProperties: string(inputPropertiesJsonString),
	}

	status, err :=

	return newSE, nil
}
