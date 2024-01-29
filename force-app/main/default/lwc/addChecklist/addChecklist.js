import { LightningElement, wire, api, track} from 'lwc';
import getChecklistWrapperList from '@salesforce/apex/VisitReportUtility.getChecklistWrapperList';
import { registerListener, unregisterAllListeners, fireEvent} from 'c/pubSub'
import { CurrentPageReference } from 'lightning/navigation';
import { loadStyle } from "lightning/platformResourceLoader";
import visitcss from "@salesforce/resourceUrl/VisitCSS";

export default class C4MC_AddChecklists extends LightningElement {
    @wire(CurrentPageReference) pageRef;//required by pubsub
    @track showSpinner = false;

    @api recordId;
    @track visitReportId;
    checklistList;
    checklistsExist; 

    connectedCallback(){
        this.visitReportId = this.recordId;
        this.getChecklistInfo();
        registerListener('showChecklists', this.setComponent, this);
    }

    renderedCallback() {
        Promise.all([
          loadStyle(
            this,
            visitcss + "/css/C4MC_AddChecklists.css"
          ),
        ]);
    }

    setComponent(paramm){
        if(paramm == 'showChecklistsParam'){
            this.showSpinner = true;
            this.getChecklistInfo();
        } 
    }

    getChecklistInfo(){
        getChecklistWrapperList({visitReportId: this.recordId})
        .then(result => {
            if(result){
                this.showSpinner = false;
                this.checklistList = result;
                var emptyChecklistEvent;
                if(result.length > 0){
                    this.checklistsExist = true;
                    emptyChecklistEvent = new CustomEvent('isemptychecklist', {detail: {isEmptyChecklist: false}});
                } else {
                    emptyChecklistEvent = new CustomEvent('isemptychecklist', {detail: {isEmptyChecklist: true}});
                }
                this.dispatchEvent(emptyChecklistEvent);
            }
        }).catch(error => {
            console.log('Error when retrieving checklists: ' + JSON.stringify(error));
        });
    }

    handleTheComponenentRefresh(){
        this.connectedCallback();
    }
}