import { LightningElement, api, wire} from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import FORM_FACTOR from '@salesforce/client/formFactor';
import VR_FIELD_NAME from "@salesforce/schema/Visit__c.Name";
import VR_FIELD_ACCOUNT from "@salesforce/schema/Visit__c.Account__c";
import c4M_static_resource from "@salesforce/resourceUrl/VisitCSS";
import formFactorPropertyName from '@salesforce/client/formFactor'

import { loadStyle } from "lightning/platformResourceLoader";
import AddAttendeesMessages from '@salesforce/label/c.AddAttendeesMessages';
import EditCurrentAttendees from '@salesforce/label/c.EditCurrentAttendees';
import AddAttendee from '@salesforce/label/c.AddAttendees';
import AddAttendeeNoResults from '@salesforce/label/c.AddAttendeeNoResults';


import getAttendees from "@salesforce/apex/VisitReportUtility.getAttendees";
import insertAttendees from "@salesforce/apex/VisitReportController.insertAttendees";
import getExtendedFieldsValue from "@salesforce/apex/VisitReportController.getExtendedFieldsValue";

const Views = Object.freeze({
  SELECT: 1,
  EDIT: 2,
});

const MAX_PAGE_COUNT = Object.keys(Views).length; // allowed page count

export default class AddInternalAttendees extends LightningElement {
  @api title = "Modal header";
  @api recordId;
  saveCount = 0;

  @api visitReportAccountId;

  toastHeader = AddAttendeesMessages.split(';')[0];
  toastMessage = AddAttendeesMessages.split(';')[1];
  contactsSearchKey = AddAttendeesMessages.split(';')[2];
  contactsSearchAccount = AddAttendeesMessages.split(';')[3];
  contactsSearchVR = AddAttendeesMessages.split(';')[4];
  successAttendee = AddAttendeesMessages.split(';')[5];
  errorAttendee = AddAttendeesMessages.split(';')[6];
  noResultsMessage = AddAttendeeNoResults;


  newAttendee = AddAttendee.split(';')[5];
  primaryContactLabel = AddAttendee.split(';')[6];
  commentLabel = EditCurrentAttendees.split(';')[4];
  formFactor = formFactorPropertyName;
  
  displayTable = true;
  isExtendedContacts = false;
  isExtendedUsers = false;
  isSmallFormFactor = false;

  connectedCallback() {
    getExtendedFieldsValue({})
    .then((result) => {
      this.isExtendedContacts = result['Extended_Contacts'];
      this.isExtendedUsers = result['Extended_Users'];
    });

    this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    await this.fetchVisitReportExistingAttendees();
    await this.fetchContacts();

    this.isLoading = false;
  }

  visitReport;
  visitReportExistingAttendees;
  currentPage = Views.SELECT;

  contactSelectDataTableColumns = [
    {
      label: "User Name",
      fieldName: "Name",
      cellAttributes: {
        class: { fieldName: "styleClass" },
        iconName: { fieldName: "statusIcon" },
      },
    },
    { label: "Email", fieldName: "Email", type: "email" },
  ];

  attendeesDataTableColumns = [
    { label: "Contact Name", fieldName: "name" },
    {
      label: "Primary Contact",
      fieldName: "isPrimaryContact",
      type: "boolean",
      editable: true,
    },
    {
      label: "Comment",
      fieldName: "detailedComment",
      type: "text",
      editable: true,
      wrapText: true,
    },
  ];

  userSelectDataTableColumns = [
    {
      label: "Contact Name",
      fieldName: "Name",
      cellAttributes: {
        class: { fieldName: "styleClass" },
        iconName: { fieldName: "statusIcon" },
      },
    },
    { label: "Account Name", fieldName: "-" },
    { label: "Email", fieldName: "Email", type: "email" },
  ];

  isLoading = false;

  contactSearchKey;
  filteredContacts;
  filteredUsers;

  selectedContacts = {};

  @api
  nextPageHandler() {
    if (this.currentPage < MAX_PAGE_COUNT)
      this.currentPage = this.currentPage + 1;
  }

  @api
  previousPageHandler() {
    if (this.currentPage > 1) {
      this.currentPage = this.currentPage - 1;
    }
    Object.keys(this.selectedContacts).map((key) => {
      this.selectedContacts[key].detailedComment = '';
      this.selectedContacts[key].isPrimaryContact = false;
    });
  }

  @api
  get isSelectViewVisible() {
    return this.currentPage == Views.SELECT;
  }

  @api
  get isEditViewVisible() {
    return this.currentPage == Views.EDIT;
  }

  @api
  get computeNextPageButtonIsDisabled() {
    return this.selectedContactIds.length == 0;
  }

  @api
  get computePreviousPageButtonIsDisabled() {
    return this.isLoading;
  }

  @api
  get computeSaveButtonIsDisabled() {
    return this.isLoading || this.selectedContactIds.length == 0;
  }

  async fetchVisitReportExistingAttendees() {
    try {
      let attendees = await getAttendees({
        query: JSON.stringify({
            sObjectName: 'Visitor__c',
           // fields:['User__r.Name', 'User__r.Email' , 'User__r.Phone', 'User__r.MobilePhone', 'User__c', 'Comment__c', 'IsPrimaryContact__c'],
           fields:['User__r.Name', 'User__r.Email' , 'User__r.Phone', 'User__r.MobilePhone', 'User__c', 'Comment__c'],
           whereClause: `Visit__c='${this.recordId}'`,
          })
      });
      this.visitReportExistingAttendees = {};
      attendees.forEach((attendee) => {
        if (attendee.User__c == undefined) {
          attendee.isUser = false;
          this.visitReportExistingAttendees[attendee.Contact__c] = attendee;
        }
        else {
          attendee.isUser = true;
          this.visitReportExistingAttendees[attendee.User__c] = attendee;
        }
      });

    } catch (error) {
      console.log('Error when fetching attendees: ' + JSON.stringify(error));
    }
  }

  @wire(getRecord, { recordId: '$recordId', fields: [VR_FIELD_NAME, VR_FIELD_ACCOUNT] })
  getVisitReportRecordCallback({ data, error }) {
    if (!error) {
      this.visitReport = data;
    } else {
      
    }
  }

  get isVisitReportInfoNotLoaded() {
    return !this.visitReport;
  }

  _resolveObjectPath(obj, path) {
    return path.split('.').reduce(function (outerObj, currPath) {
      return outerObj ? outerObj[currPath] : null
    }, obj)
  }

  _flattenDataRow(row, cols) {
    return cols.reduce((datarow, col) => {
      datarow[col.fieldName] = this._resolveObjectPath(row, col.fieldName);
      return datarow;
    }, { Id: row.Id, rawData: row });
  }

  handleSearchInputUpkey(e) {
    const isEnterKey = e.keyCode === 13;
    if (isEnterKey) {
      this.contactSearchKey = e.target.value.trim();
      this.fetchContacts();
    }

  }

  get searchResultLabel() {
    return !this.contactSearchKey ? this.contactsSearchVR : this.contactsSearchAccount
  }

  get selectedContactInfo() {
    let items = Object.keys(this.selectedContacts).map((key) => {
      let record = this.selectedContacts[key].rawData;
      if (record.Username == undefined) {
        return {
          id: record.Id,
          type: 'avatar',
          href: '',
          label: `${record.Name} (${record.Account.Name})`,
          src: 'https://www.lightningdesignsystem.com/assets/images/avatar2.jpg',
          fallbackIconName: 'standard:user',
          variant: 'circle',
          alternativeText: 'User avatar',
        }
      }
      else {
        return {
          id: record.Id,
          type: 'avatar',
          href: '',
          label: `${record.Name}`,
          src: 'https://www.lightningdesignsystem.com/assets/images/avatar2.jpg',
          fallbackIconName: 'standard:user',
          variant: 'circle',
          alternativeText: 'User avatar',
        }
      }
    }).sort(function (a, b) {
      if ( a.label.toLowerCase() < b.label.toLowerCase() ){
        return -1;
      }
      if ( a.label.toLowerCase() > b.label.toLowerCase() ){
        return 1;
      }
      return 0;
    });

    return items;
  }

  get selectedContactIds() {
    return Object.keys(this.selectedContacts);
  }


  get selectedAttendees() {
    let items = Object.keys(this.selectedContacts).map((key) => {
      let record = this.selectedContacts[key];
      if (record.rawData != null) {
        if (record.rawData.Username == undefined) {
          return {
            id: record.Id,
            name: record.Name,
            isPrimaryContact: record.isPrimaryContact,
            detailedComment: record.detailedComment,
            isUser: false
          }
        } else {
          return {
            id: record.Id,
            name: record.Name,
            isPrimaryContact: record.isPrimaryContact,
            detailedComment: record.detailedComment,
            isUser: true
          }
        }
      }
      else {
        return {
          id: record.Id,
          name: record.Name,
          isPrimaryContact: record.isPrimaryContact,
          detailedComment: record.detailedComment
        }
      }
    }).sort(function (a, b) {
      if ( a.name.toLowerCase() < b.name.toLowerCase() ){
        return -1;
      }
      if ( a.name.toLowerCase() > b.name.toLowerCase() ){
        return 1;
      }
      return 0;
    });
    
    return items;
  }

  renderedCallback() {
    Promise.all([
      loadStyle(
        this,
        c4M_static_resource + "/css/C4MC_AddAttendees.css"
      ),
    ]);
    if(FORM_FACTOR == 'Small'){ 
      this.isSmallFormFactor = true;
    }
  }

  handleSelectedAttendeeRemove(e) {
    delete this.selectedContacts[e.detail.item.id];
    this.selectedContacts = { ...this.selectedContacts };
    const evt = new CustomEvent('nextchanged', { detail: this.selectedContactIds.length == 0 });
    this.dispatchEvent(evt);
  }

  handleContactSelectionChange(e) {
    const selectedRows = e.detail.selectedRows;
    let selectedContacts = this.selectedContacts;
    this.filteredUsers.forEach((c) => {
      if (selectedContacts[c.Id]) {
        delete selectedContacts[c.Id];
      }
    })
    let nonSelectableContacts = [];
    let nonAccountContacts = [];
    selectedRows.forEach((r) => {
      if (r.rawData.Account == undefined && r.rawData.Username == undefined) {
        nonAccountContacts.push(r.Name);
      } else {
        if (this.visitReportExistingAttendees[r.Id]) {
          nonSelectableContacts.push(r.Name);
        } else {
          selectedContacts[r.Id] = r;
        }
      }
    });

    this.selectedContacts = { ...selectedContacts };

    if (nonSelectableContacts.length > 0) {
      this.showToastMessage(this.toastHeader,
        `${nonSelectableContacts.join(', ')}` + this.toastMessage,
        'warning'
      )
    } else if (nonAccountContacts.length > 0) {
      this.showToastMessage(this.toastHeader,
        `${nonAccountContacts.join(', ')}` + " doesn't have an associated account.",
        'warning'
      )
    }

    const evt = new CustomEvent('nextchanged', { detail: this.selectedContactIds.length == 0 });
    this.dispatchEvent(evt);

  }


  showToastMessage(title, message, variant) {

    this.dispatchEvent(new ShowToastEvent({
      title: title,
      variant: variant ? variant : 'success',
      message: message
    }));
  }

  async fetchContacts() {
    try {
      /*let query = {
        sObjectName: 'Contact',
        fields: ['Name', 'Account.Name', 'Email'],
        whereClause: `AccountId='${this.visitReportAccountId}'`,
        orderbyClause: 'Name',
        rowCount: 100
      };*/
      this.isLoading = true;
      this.filteredUsers = [];
      this.fetchUsers();
      console.log('this.filteredUsers'+this.filteredUsers);
      if (this.contactSearchKey) {
        if (this.isExtendedUsers) {
          await this.fetchUsers();
        }

        /*if (this.isExtendedContacts) {
          query.whereClause = ['Name', 'Email', 'Account.Name'].map((field) => {
            return `${field} LIKE '%${this.contactSearchKey}%'`
          }).join(' OR ');
        }

        else if (!this.isExtendedContacts) {
          query.whereClause += ' AND ('+ (['Name', 'Email', 'Account.Name'].map((field) => {
            return `${field} LIKE '%${this.contactSearchKey}%'`
          }).join(' OR ')) +')';
        }*/
      }
      //console.log('this.filteredUsers'+this.filteredUsers);
      //console.log('this.displayTable'+this.displayTable);
      /*let contacts = await getAttendees({ query: JSON.stringify(query)});
      this.filteredContacts = [];
      contacts.forEach((row) => {
        let flattendRecordData = this._flattenDataRow(row, this.contactSelectDataTableColumns);
       if(this.formFactor == 'Large' || this.formFactor == 'Small'){
          flattendRecordData.statusIcon = this.visitReportExistingAttendees[row.Id] ? 'utility:privately_shared' : 'utility:people';
       } else if(this.formFactor == 'Medium'){
          flattendRecordData.statusIcon = this.visitReportExistingAttendees[row.Id] ? '' : '';;
       }
        flattendRecordData.styleClass = this.visitReportExistingAttendees[row.Id] ? 'slds-text-color_error ' : '';
        //this.filteredContacts.push(flattendRecordData);
      });
      if (this.filteredUsers != undefined) {
        this.filteredUsers.push(...this.filteredContacts);
        this.filteredContacts = this.filteredUsers.sort(function(a,b){
          if (a.rawData.Name.toUpperCase() < b.rawData.Name.toUpperCase()) return -1;
          if (a.rawData.Name.toUpperCase() > b.rawData.Name.toUpperCase() ) return 1;
          return 0;
        });
      }*/
      
    } catch (e) {
      console.log('Error while getting contacts: ' + JSON.stringify(e.message));
    }
  } 


  async fetchUsers() {
    try {
      let query = {
        sObjectName: 'User',
        fields: ['Name', 'Email', 'Username'],
        whereClause: `IsActive IN (TRUE, FALSE)`,
        orderbyClause: 'Name',
        rowCount: 100
      };
      if (this.contactSearchKey) {
        query.whereClause += ' AND ('+ (['Name', 'Email'].map((field) => {
            return `${field} LIKE '%${this.contactSearchKey}%'`
          }).join(' OR ')) +')';
      }

      let users = await getAttendees({ query: JSON.stringify(query)});
      this.filteredUsers= [];
      users.forEach((row) => {
        let flattendRecordData = this._flattenDataRow(row, this.userSelectDataTableColumns);
       if(this.formFactor == 'Large' || this.formFactor == 'Small'){
          flattendRecordData.statusIcon = this.visitReportExistingAttendees[row.Id] ? 'utility:privately_shared' : 'utility:people';
       } else if(this.formFactor == 'Medium'){
          flattendRecordData.statusIcon = this.visitReportExistingAttendees[row.Id] ? '' : '';
       }
        flattendRecordData.styleClass = this.visitReportExistingAttendees[row.Id] ? 'slds-text-color_error ' : '';
        this.filteredUsers.push(flattendRecordData);
      });
      console.log('this.filteredUsers length'+this.filteredUsers.length);
      if (this.filteredUsers.length > 0) {
        this.displayTable = true;
        this.isLoading = false;
      } else {
        this.displayTable = false;
        this.isLoading = false;
      }
         console.log('this.displayTable'+this.displayTable);
    } catch (e) {
      console.log('Error while getting users: ' + JSON.stringify(e.body.message));
    }
  }

  handleClose() {
    this.filteredContacts = [];
    this.selectedContacts = {};
    this.filteredUsers = [];
    this.currentPage = Views.SELECT;
  }


  handleAttendeesDataChange(event) {
    let target = event.target;
    let state = false;

    let attendee = this.selectedContacts[target.dataset.key];
    if (target.dataset.field === 'primaryContact') {
      if (target.checked) {
        state = true;
      }

      let checkboxes = this.template.querySelectorAll('[data-field="primaryContact"]');
      checkboxes.forEach(checkbox => {
        checkbox.checked = false;
      });
      target.checked = state;

      Object.keys(this.selectedContacts).forEach((key) => {
        let contact = this.selectedContacts[key];
        contact.isPrimaryContact = false;
      });

      attendee.isPrimaryContact = target.checked;

    } else if (target.dataset.field === 'detailedComment') {
      let value = target.value;
      attendee.detailedComment = value;
    }

    this.selectedContacts = { ...this.selectedContacts };
  }

  @api
  addAttendeesToVisitReport() {
    if (this.saveCount == 0) {
        console.log('saveCount--->'+this.saveCount);
      if (this.selectedContactIds.length > 0) {
        this.isLoading = true;
        let attendeesList = [];
        Object.keys(this.selectedContacts).forEach((key) => {
          let contact = this.selectedContacts[key];
          contact.rawData = null;
          attendeesList.push(contact);
        });
        insertAttendees({
          jsonInput: JSON.stringify(attendeesList),
          vrId: this.recordId
        }).then(result => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Success',
              message: this.successAttendee,
              variant: 'success'
            })
          );
          this.isLoading = false;
          this.handleClose();
          this.dispatchEvent(new CustomEvent("closemodal", {}));
          let aura$Object = window['$' + 'A'];
          if (aura$Object) {
            aura$Object.get('e.force:refreshView').fire();
          }
        }).catch(error => {
          console.log('Error: ' + JSON.stringify(error));
          this.showToastMessage('Error Occurred!',
            this.errorAttendee,
            'error'
          );
        });
      }
      this.saveCount++;
    }
  }
}