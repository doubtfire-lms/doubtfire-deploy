import { Component, Input, Inject } from '@angular/core';
import { taskService } from '../../ajs-upgraded-providers';


@Component({
  selector: 'taskStatusSelector',
  templateUrl: 'task-status-selector.component.html',
  styleUrls: ['task-status-selector.component.scss']
})

export class TaskStatusSelectorComponent 
{
    task: "=task";
    assessingUnitRole: "=assessingUnitRole";
    inMenu: "=inMenu";
    triggerTransition: "=triggerTransition";

    private service: any;
    private studentTriggers: any;
    private tutorTriggers: any;


    constructor(@Inject(taskService) service: any)
    {
        this.service = taskService;
    }

    studentStatuses(){
        return this.service.switchableStates.student
    }

    tutorStatuses(){
        return this.service.switchableStates.tutor
    }

    taskEngagementConfiguration(){
        studentTriggers: this.studentStatuses.map; this.service.statusData
        tutorTriggers: this.tutorStatuses.map; this.service.statusData
    }
}