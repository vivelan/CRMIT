import { LightningElement, api, track, wire } from 'lwc';
import ManageChecklist from '@salesforce/label/c.ManageChecklist';
import visitcss from "@salesforce/resourceUrl/VisitCSS";
import getChecklists from "@salesforce/apex/VisitReportUtility.getChecklists";
import { loadStyle } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createChecklistQuestionResponses from '@salesforce/apex/VisitReportUtility.createChecklistQuestionResponses';
import AddChecklist from '@salesforce/label/c.AddChecklist';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubSub';
import { CurrentPageReference } from 'lightning/navigation';
import EmailPreferencesStayInTouchReminder from '@salesforce/schema/User.EmailPreferencesStayInTouchReminder';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class ManageChecklists extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    @track checklistIds = [];

    @api isOpen = false;
    @api recordId;
    @api visitReportName;
    @track listOfChecklist;
    auxListOfChecklist;
    searchKey = '';
    displayTable = true;
    displayMessage = false;
    hasRows = true;
    isSmallFormFactor = false;
    isMediumFormFactor = false;
    isLargeFormFactor = false;


    visitReport;
    title;
    checklistSearchKey;
    checkboxIds = [];

    AddTitle = ManageChecklist.split(";")[0];
    SearchText = ManageChecklist.split(";")[1];
    ChecklistName = ManageChecklist.split(";")[2];
    AddButton = ManageChecklist.split(";")[3];
    CancelButton = ManageChecklist.split(";")[4];
    ChecklistMessage = ManageChecklist.split(";")[5];

    selectionEmptyTitleLabel = AddChecklist.split(';')[0];
    selectionEmptyBodyLabel = AddChecklist.split(';')[1];
    successTitleLabel = AddChecklist.split(';')[2];
    successBodyLabel = AddChecklist.split(';')[3];
    noRowsMessage = ManageChecklist.split(';')[6];

    @track showSpinner = false;

    @api
    openModalManageChecklists() {
        this.isOpen = true;
        this.title = this.AddTitle + ' (' + this.visitReportName + ')';
        this.showSpinner = true;
        this.connectedCallback();
    }

    @api
    closeModalManageChecklists() {
        this.isOpen = false;
        this.hasRows = true;
    }

    connectedCallback() {
        this.searchKey = '';
        getChecklists({ visitReportId: this.recordId, searchKey: this.searchKey }).then(result => {
            this.showSpinner = false;
            if (result != null) {
                if (result.length > 0) {
                    this.listOfChecklist = result;
                    this.listOfChecklist.forEach(element => {
                        element.Checked = false;
                    });
                    this.auxListOfChecklist = this.listOfChecklist;
                    this.displayTable = true;
                    this.displayMessage = false;
                } else {
                    this.listOfChecklist = false;
                    this.displayTable = false;
                    this.displayMessage = true;
                }
                this.isLoading = false;
            } else {
                this.listOfChecklist = false;
                this.displayTable = false;
                this.displayMessage = true;
            }
        });
    }

    handleKeyChange(event) {
        this.listOfChecklist = this.auxListOfChecklist;
        const searchKey = event.target.value;
        var auxList = [];
        this.listOfChecklist.forEach(element => {
            if (element.Name.toLowerCase().includes(searchKey.toLowerCase())) {
                auxList.push(element);
            }
        });
        if(auxList.length > 0){
            this.hasRows = true;
            this.listOfChecklist = auxList;
            var allChecked = false;
            this.listOfChecklist.forEach(element => {
                if(element.Checked){
                    allChecked = true;
                }
            });
            if(this.template.querySelector('[data-name="mainCheckbox"]') != null){
                this.template.querySelector('[data-name="mainCheckbox"]').checked = allChecked;
            }
        }else{
            this.hasRows = false;
        }
        
    }

    renderedCallback() {
        Promise.all([
            loadStyle(
                this,
                visitcss + "/css/C4MC_ManageChecklists.css"
            ),
        ]);

        if(FORM_FACTOR == 'Small'){ 
            this.isSmallFormFactor = true;
        } else if(FORM_FACTOR == 'Medium') {
            this.isMediumFormFactor = true;
        } else {
            this.isLargeFormFactor = true;
        }
    }

    allChecked(event) {
        this.listOfChecklist.forEach(element => {
            element.Checked = event.target.checked;
            this.auxListOfChecklist.forEach(element2 => {
                if(element.Id == element2.Id){
                    element2.Checked = element.Checked;
                }
            });
        });
    }

    eventChecked(event) {

        let checkboxId = event.target.getAttribute("data-id");
        this.auxListOfChecklist.forEach(element => {
            if (element.Id == checkboxId) {
                element.Checked = event.target.checked;
            }
        });

        if (event.target.checked) {
            this.template.querySelector('[data-name="mainCheckbox"]').checked = true;
        } else {
            let i;
            let checkboxes = this.template.querySelectorAll('[data-name="checkbox"]');
            let allUnchecked = true;
            for (i = 0; i < checkboxes.length; i++) {
                if (checkboxes[i].checked) {
                    allUnchecked = false;
                }
            }
            if (allUnchecked) {
                this.template.querySelector('[data-name="mainCheckbox"]').checked = false;
            }
        }
    }

    addChecklist() {
        this.checklistIds = [];
        this.auxListOfChecklist.forEach(element => {
            if(element.Checked){
                this.checklistIds.push(element.Id);
            }
        });

        if (this.checklistIds.length > 0) {
            createChecklistQuestionResponses({ visitReportId: this.recordId, checklistIds: this.checklistIds })
                .then(result => {
                    this.isOpen = false;

                    this.dispatchEvent(new ShowToastEvent({
                        title: this.successTitleLabel,
                        variant: 'success',
                        message: this.successBodyLabel
                    }));

                    fireEvent(this.pageRef, 'showChecklists', 'showChecklistsParam');

                }).catch(error => {
                    console.log('Error when creating question responses: ' + JSON.stringify(error));
                });
        } else {
            this.dispatchEvent(new ShowToastEvent({
                title: this.selectionEmptyTitleLabel,
                variant: 'info',
                message: this.selectionEmptyBodyLabel
            }));
        }

    }

}