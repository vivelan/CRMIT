import { LightningElement, api, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import ManagingVisitReports from "@salesforce/label/c.ManagingVisitReports";
import visitcss from "@salesforce/resourceUrl/VisitCSS";
import getRecords from "@salesforce/apex/VisitReportUtility.getRecords";
import displayTiles from "@salesforce/apex/VisitReportController.displayManageVisitReportTiles";
import VR_FIELD_NAME from "@salesforce/schema/Visit__c.Name";
import VR_ACCOUNT_NAME from "@salesforce/schema/Visit__c.Account__c";
import { getRecord, getFieldValue, createRecord, updateRecord } from "lightning/uiRecordApi";
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';

const Views = Object.freeze({
  SELECT: 1,
  EDIT: 2,
});
const MODAL_EDIT = "c-edit-attendees";
const CHECKLIST_MODAL_MANAGE = "c-manage-checklist";

export default class ManageVisitRecords extends NavigationMixin(LightningElement) {
  Attendees;
  ManageAttendees;
  Checklists;
  ChecklistsHelpText;
  accountRecord;
  displayManageInternalAttendees = false;
  displayManageExternalAttendees = false;
  displayManageChecklists = false;
  displayBackButton = false;
  smallDevice = false;
  externalAttendee = false;
  internalAttendee = false;

  visitReport;
  visitReportExistingAttendees = false;
  visitReportExistingAssets = false;
  isLoading = false;
  formFactor = formFactorPropertyName;
  @api recordId;

  @wire(getRecord, { recordId: '$recordId', fields: [VR_FIELD_NAME, VR_ACCOUNT_NAME] })
  getVisitReportRecordCallback({ data, error }) {
    if (!error) {
      this.visitReport = data;
    } else {
      //show error notification via tost message
    }
  }

  

  @api
  get visitReportName() {
    return getFieldValue(this.visitReport, VR_FIELD_NAME);
  }

  @api
  get visitReportAccount() {
    return getFieldValue(this.visitReport, VR_ACCOUNT_NAME);
  }
  

  connectedCallback() {
    let splitLabels = ManagingVisitReports.split(";");
    this.ExternalAttendees = splitLabels[0];
    this.ManageAttendees = splitLabels[1];
    this.Checklists = splitLabels[2];
    this.ChecklistsHelpText = splitLabels[3];
    this.InternalAttendees = splitLabels[4];
    this.isLoading = true;

    getRecords({
      visitReportId: this.recordId,
    })
      .then((result) => {
        if (result.length > 0) {
          this.visitReportExistingAttendees = result;
        } else {
          this.visitReportExistingAttendees = false;
        }
      })
      .catch((error) => {
        console.log(
          "Error when fetching visitor values: " + JSON.stringify(error)
        );
      });

      displayTiles({})
      .then((result) => {
        this.displayManageInternalAttendees = result['Manage_Internal_Attendees'];
        this.displayManageExternalAttendees = result['Manage_External_Attendees'];
        this.displayManageChecklists = result['Manage_Checklists'];
      });

      if(this.formFactor == 'Medium' || this.formFactor == 'Small'){
        this.displayBackButton = true;
        this.smallDevice = true;
     } 
  }
  openExternalModal() {
    this.externalAttendee = true;
    this.template.querySelector(MODAL_EDIT).openModal();
  }
  openIternalModal() {
    this.internalAttendee = true;
    this.template.querySelector(MODAL_EDIT).openModal();
  }
  openModalManageChecklists() {
    this.template.querySelector(CHECKLIST_MODAL_MANAGE).openModalManageChecklists();
  }
  handleClose() {
    this.template.querySelector(MODAL_EDIT).closeModal();
    this.template.querySelector(CHECKLIST_MODAL_MANAGE).closeModalManageChecklists();
  }

  closeQuickAction() {
    const closeQA = new CustomEvent('close');
    this.dispatchEvent(closeQA);
  }
  
  renderedCallback() {
    Promise.all([
      loadStyle(
        this,
        visitcss + "/css/C4MC_ManageVisitReportRecords.css"
      ),
    ]);
  }
}