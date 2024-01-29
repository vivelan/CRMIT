import { LightningElement, api, wire , track } from 'lwc';
import { loadStyle } from "lightning/platformResourceLoader";
import visitCSS from "@salesforce/resourceUrl/VisitCSS";
import AddAttendees from '@salesforce/label/c.AddAttendees';
import EditCurrentAttendees from '@salesforce/label/c.EditCurrentAttendees';
import FORM_FACTOR from '@salesforce/client/formFactor';
export default class EditInternalAttendees extends LightningElement {
  @api title = 'Modal header'
  @api isOpen = false;
  addBtnClicked = false;
  isSelectView = true;
  isEditView = false;
  isSmallFormFactor = false;
  rowSelected = true;
  displayTable = true;
  @api recordId;
  allChecked = true;
  @api visitReportName = '';
  visitReport;
  @api visitReportAccount;
  @api internalAttendeeFromParent;
  @api externalAttendeeFromParent;
  @track externalTile = false;
  @track internalTile = false;

  addTitle = AddAttendees.split(';')[0];
  previousBtn = AddAttendees.split(';')[1];
  nextBtn = AddAttendees.split(';')[2];
  cancelBtn = AddAttendees.split(';')[3];
  saveBtn = AddAttendees.split(';')[4];
  newBtn = AddAttendees.split(';')[5];
  pContact = AddAttendees.split(';')[6];
  addNew = AddAttendees.split(';')[7];

  editTitle = EditCurrentAttendees.split(';')[5];

  @api isLoading;

  loadingHandler(event){
    this.isLoading = event.detail;
  }


  @api
  openModal() {
    if(this.template.querySelector('c-edit-current-internal-attendee') != null ){
      this.template.querySelector('c-edit-current-internal-attendee').loadData();
    }
    this.isOpen = true;
    this.title = this.editTitle + ' (' + this.visitReportName + ')';
  }
  @api
  closeModal() {
    this.isOpen = false;
  }
  handleCloseModal() {
    this.closeModal();
    if (this.addBtnClicked) {
      this.addBtnClicked = false;
      this.isSelectView = true;
      this.isEditView = false;
      this.rowSelected = true;
    }
    this.title = this.editTitle + ' (' + this.visitReportName + ')';
  }

  addNewAttendee() {
    this.addBtnClicked = true;
    this.title = this.addTitle + ' (' + this.visitReportName + ')';
  }

  connectedCallback() {
    this.title = this.editTitle + ' (' + this.visitReportName + ')';
  }

  renderedCallback() {
    Promise.all([
      loadStyle(
        this,
        visitCSS + "/css/C4MC_EditAttendees.css"
      ),
    ]);

    if(FORM_FACTOR == 'Small'){ 
      this.isSmallFormFactor = true;
    }
    this.externalTile = this.externalAttendeeFromParent;
    this.internalTile = this.internalAttendeeFromParent;
  }

  get isSelectViewVisible() {
    return this.addBtnClicked == true && this.isSelectView == true;
  }

  get isEditViewLoaded() {
    return this.addBtnClicked == true && this.isEditView == true;
  }

  backToEdit(){
    this.addBtnClicked = false;
    this.title = this.editTitle + ' (' + this.visitReportName + ')';
    this.rowSelected = true;
  }

  nextPage(){
    this.template.querySelector('c-add-internal-attendees').nextPageHandler();
    this.isSelectView = false;
    this.isEditView = true;
  }

  nextChanged(event){
    this.rowSelected = event.detail;
  }

  previousHanlder(){
    this.template.querySelector('c-add-internal-attendees').previousPageHandler();
    this.isSelectView = true;
    this.isEditView = false;
  }

  saveRecord(){
    this.template.querySelector('c-add-internal-attendees').addAttendeesToVisitReport();
  }

  displaySaveBtn(event){
    this.displayTable = event.detail;
  }

  editRecord(){
    this.template.querySelector('c-edit-current-internal-attendee').updateCurrentAttendees();
  }

}