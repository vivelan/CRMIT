import { LightningElement, api, wire , track  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from "lightning/platformResourceLoader";
import visitcss from "@salesforce/resourceUrl/VisitCSS";
import labelCurrentAttendees from '@salesforce/label/c.EditCurrentAttendees';
import SystemAdministratorProfile from '@salesforce/label/c.SystemAdministratorProfile';
import getAttendees from "@salesforce/apex/VisitReportUtility.getAttendees";
import deleteAttendees from "@salesforce/apex/VisitReportUtility.deleteAttendees";
import updateAttendees from "@salesforce/apex/VisitReportUtility.updateAttendees";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import PROFILE_FIELD from '@salesforce/schema/User.Profile.Name';

export default class EditCurrentAttendees extends LightningElement {
  @api recordId;
  visitReport;
  @track visitExistingExternalAttendees;
  @track visitExistingIternalAttendees;
  @track DepartmentDH = false;
  @track DepartmentSAG = false;
  displayExternalAttendeeTable = false;
  isLoading = true;
  checkboxIds = [];
  @api valueFromChild;
  @api valueFromChildComponent;
  external;
  internal;
  label = {
    SystemAdministratorProfile
  }


  ContactName = labelCurrentAttendees.split(';')[0];
  Phone = labelCurrentAttendees.split(';')[1];
  accountName = labelCurrentAttendees.split(';')[2];
  emailLabel = labelCurrentAttendees.split(';')[3];
  commentLabel = labelCurrentAttendees.split(';')[4];
  noAttendeesMessage = labelCurrentAttendees.split(';')[6];
  successMessage = labelCurrentAttendees.split(';')[7];
  Mobile = labelCurrentAttendees.split(';')[9];
  Department = labelCurrentAttendees.split(';')[10];


  connectedCallback() {
    console.log('profileName'+this.userProfile);
    if(this.userProfile.startsWith('DH'))
      this.DepartmentDH = true;
    if(this.userProfile.startsWith('SAG'))
      this.DepartmentSAG = true;
    if(this.userProfile == SystemAdministratorProfile || this.userProfile == 'SHS Admin'){
     this.DepartmentDH = true;
     this.DepartmentSAG = true;
    }
    this.loadData();
    Promise.all([
      loadStyle(
        this,
        visitcss + "/css/C4MC_EditCurrentAttendees.css"
      ),
    ]); 
    
  }
  @api loadData() {
    const selectedEvent = new CustomEvent('loading', { detail: this.isLoading });
    this.dispatchEvent(selectedEvent);
    this.fetchVisitExistingAttendees();
  }
  @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_FIELD] })
    user;
    
    get userProfile() {
        return getFieldValue(this.user.data, PROFILE_FIELD);
    }
  fetchVisitExistingAttendees() {
        getAttendees({
        query: JSON.stringify({
            sObjectName: 'Visitor__c',
            //fields:['Contact__r.Name', 'Contact__r.Email', 'Contact__r.Phone' , 'Contact__r.MobilePhone', 'Contact__c', 'Contact__r.Account.Name', 'Comment__c','IsPrimaryContact__c'],
            fields:['Contact__r.Name', 'Contact__r.Email', 'Contact__r.Phone' , 'Contact__r.MobilePhone', 'Contact__c', 'Contact__r.Account.Name', 'Comment__c', 'Contact__r.Department','Contact__r.Department__c'],
            whereClause: `Visit__c='${this.recordId}' AND Contact__c!=null`,
        })
        }).then(result => {
        if (result) {
            console.log('Result for external------->'+result);
            result = result.map(attendee => ({
            ...attendee,
            AttendeeName__c : attendee.Contact__r.Name.replaceAll(/<\/?(a|A).*?>/g, '').trim(),
            AccountId: attendee.Contact__c ?  attendee.Contact__r.Account.Name: '-'
            }))

            result.sort((a,b) => a.AttendeeName__c.localeCompare(b.AttendeeName__c));

            this.visitExistingExternalAttendees = result;
            if (this.visitExistingExternalAttendees.length > 0) {
            this.displayExternalAttendeeTable = true;
            //this.displayIternalAttendeeTable = false;
            } else {
            this.displayExternalAttendeeTable = false;
            //this.displayIternalAttendeeTable = false;
            }
            const selectedEvent = new CustomEvent('displaybtn', { detail: this.displayExternalAttendeeTable });
            this.dispatchEvent(selectedEvent);
        }
        this.isLoading = false;
        const selectedEvent1 = new CustomEvent('loading', { detail: this.isLoading });
        this.dispatchEvent(selectedEvent1);
        }).catch(error => {
        console.log('Error when fetching attendees: ' + JSON.stringify(error));
        })
        /*getAttendees({
            query: JSON.stringify({
              sObjectName: 'Visitor',
              fields:['User__r.Name', 'User__r.Email' , 'User__r.Phone', 'User__r.MobilePhone', 'User__c', 'Comment__c', 'IsPrimaryContact__c'],
              whereClause: `VisitId='${this.recordId}'`,
            })
          }).then(result => {
            if (result) {
              console.log('Result for internal------->'+result);
              result = result.map(attendee => ({
                ...attendee,
                AttendeeName__c : attendee.User__r.Name.replaceAll(/<\/?(a|A).*?>/g, '').trim()
              }))
      
              result.sort((a,b) => a.AttendeeName__c.localeCompare(b.AttendeeName__c));
      
              this.visitExistingIternalAttendees = result;
              if (this.visitExistingIternalAttendees.length > 0) {
                this.displayIternalAttendeeTable = true;
                //this.displayExternalAttendeeTable = false;
              } else {
                this.displayIternalAttendeeTable = false;
                //this.displayExternalAttendeeTable = false;
              }
              const selectedEvent = new CustomEvent('displaybtn', { detail: this.displayIternalAttendeeTable });
              this.dispatchEvent(selectedEvent);
            }
            this.isLoading = false;
            const selectedEvent1 = new CustomEvent('loading', { detail: this.isLoading });
            this.dispatchEvent(selectedEvent1);
          }).catch(error => {
            console.log('Error when fetching attendees: ' + JSON.stringify(error));
          })*/
  }
  /*renderedCallback() {
    //this.external = this.valueFromChild;
    //this.internal = this.valueFromChildComponent;
    //console.log('internal'+this.internal);
    //console.log('this.external'+this.external);
      
  }*/

  allExternalChecked(event) {
    let checkboxes = this.template.querySelectorAll('[data-name="checkbox"]');
    for (let i = 0; i < checkboxes.length; i++) {
      checkboxes[i].checked = event.target.checked;
    }
    if (event.target.checked) {
      this.visitExistingExternalAttendees.forEach(element => {
        this.checkboxIds.push(element.Id);
      });
    } else {
      this.checkboxIds = [];
    }
  }
  allInternalChecked(event) {
    let checkboxes = this.template.querySelectorAll('[data-name="checkbox"]');
    for (let i = 0; i < checkboxes.length; i++) {
      checkboxes[i].checked = event.target.checked;
    }
    if (event.target.checked) {
      this.visitExistingIternalAttendees.forEach(element => {
        this.checkboxIds.push(element.Id);
      });
    } else {
      this.checkboxIds = [];
    }
  }

  eventChecked(event) {
    if (event.target.checked) {
      this.template.querySelector('[data-name="mainCheckbox"]').checked = true;
      this.checkboxIds.push(event.target.getAttribute("data-id"));
    } else {
      if (this.checkboxIds.includes(event.target.getAttribute("data-id"))) {
        for (let i = 0; i < this.checkboxIds.length; i++) {
          if (this.checkboxIds[i] == event.target.getAttribute("data-id")) {
            this.checkboxIds.splice(i, 1);
          }

        }
      }
      let checkboxes = this.template.querySelectorAll('[data-name="checkbox"]');
      let allUnchecked = true;
      for (let i = 0; i < checkboxes.length; i++) {
        if (checkboxes[i].checked) {
          allUnchecked = false;
        }
      }
      if (allUnchecked) {
        this.template.querySelector('[data-name="mainCheckbox"]').checked = false;

      }
    }
  }


  /*handleChangeCheckbox(event) {
    let rowId = event.target.getAttribute("data-id");
    this.visitExistingExternalAttendees.forEach(element => {
      if (element.Id == rowId) {
        element.IsPrimaryContact__c = event.currentTarget.checked;
      }else{
        element.IsPrimaryContact__c = false;
      }
    });
    
  }*/

  handleExternalChangeInput(event) {
    let rowId = event.target.getAttribute("data-id");
    this.visitExistingExternalAttendees.forEach(element => {
      if (element.Id == rowId) {
        element.Comment__c = event.currentTarget.value;
      }
    });
  }
  handleInternalChangeInput(event) {
    let rowId = event.target.getAttribute("data-id");
    this.visitExistingIternalAttendees.forEach(element => {
      if (element.Id == rowId) {
        element.Comment__c = event.currentTarget.value;
      }
    });
  }

  @api updateCurrentAttendees(event) {
    const selectedEvent = new CustomEvent('loading', { detail: this.isLoading });
    this.dispatchEvent(selectedEvent);
    let auxList = [];
    for (let i = 0; i < this.visitExistingExternalAttendees.length; i++) {
      if(!this.checkboxIds.includes(this.visitExistingExternalAttendees[i].Id)){
       // auxList.push({Id: this.visitExistingExternalAttendees[i].Id, Comment__c: this.visitExistingExternalAttendees[i].Comment__c, IsPrimaryContact__c: this.visitExistingExternalAttendees[i].IsPrimaryContact__c});
       auxList.push({Id: this.visitExistingExternalAttendees[i].Id, Comment__c: this.visitExistingExternalAttendees[i].Comment__c});
     
      }
    }
    updateAttendees({jsonInput: JSON.stringify(auxList)}).then(() => {
      this.isLoading = true;
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Success',
          message: this.successMessage,
          variant: 'success'
        })
      );
      this.isLoading = false;
      const selectedEvent1 = new CustomEvent('loading', { detail: this.isLoading });
      this.dispatchEvent(selectedEvent1);
      this.loadData();
      let aura$Object = window['$' + 'A'];
        if (aura$Object) {
          aura$Object.get('e.force:refreshView').fire();
        }
    }).catch(error => {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error',
          message: labelCurrentAttendees.split(',')[8] + ' ' + error.body.output.errors[0].message,
          variant: 'error'
        })
      );
    }); 

    if (this.checkboxIds.length > 0) {
      deleteAttendees({ attendeesIds: this.checkboxIds }).then(() => {
        this.isLoading = true;
        this.loadData();
        let aura$Object = window['$' + 'A'];
        if (aura$Object) {
          aura$Object.get('e.force:refreshView').fire();
        }
      }).catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: labelCurrentAttendees.split(',')[8] + ' ' + error.body.output.errors[0].message,
            variant: 'error'
          })
        );
  
      });  
    }
    if(this.displayExternalAttendeeTable){
      this.template.querySelector('[data-name="mainCheckbox"]').checked = false;
      let checkboxesList = this.template.querySelectorAll('[data-name="checkbox"]');
      for (let i = 0; i < checkboxesList.length; i++) {
        checkboxesList[i].checked = false;
      }
    }
  }
}