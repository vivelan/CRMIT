import { LightningElement, wire,track } from 'lwc';
import showtabledata from '@salesforce/apex/AccountSalesPlanningController.showtabledata';
import getMarketingUsers from '@salesforce/apex/AccountSalesPlanningController.getMarketingUsers';
import toCalculateDeltaNet from '@salesforce/apex/AccountSalesPlanningController.toCalculateDeltaNet';
import getAccountPlanningColumnNames from '@salesforce/apex/AccountSalesPlanningController.getAccountPlanningColumnNames';
import upsertSPForecaste from '@salesforce/apex/AccountSalesPlanningController.upsertSPForecaste';
import updateSalesPlanningLog from '@salesforce/apex/AccountSalesPlanningController.updateSalesPlanningLog';
import updateSalesPlanningLogForEdit from '@salesforce/apex/AccountSalesPlanningController.updateSalesPlanningLogForEdit';
import getSalesPlanningLogForEdit from '@salesforce/apex/AccountSalesPlanningController.getSalesPlanningLogForEdit';
import overrideCalulation from '@salesforce/apex/AccountSalesPlanningController.overrideCalulation';
import EditButtonForSalesForecasting from '@salesforce/label/c.EditButtonForSalesForecasting';
import SaveButtonForSalesForecasting from '@salesforce/label/c.SaveButtonForSalesForecasting';
import CancelForSalesPlanning from '@salesforce/label/c.CancelForSalesPlanning';
import BusinessAreaProductGroupForPlanning from '@salesforce/label/c.BusinessAreaProductGroupForPlanning';
import Total from '@salesforce/label/c.Total';
import DeltaNetProceeds from '@salesforce/label/c.DeltaNetProceeds';
import SoldAmount from '@salesforce/label/c.SoldAmount';
import SaveAndSubmit from '@salesforce/label/c.SaveAndSubmit';
import ActualValuesFromTheLast12Months from '@salesforce/label/c.ActualValuesFromTheLast12Months';
import Average from '@salesforce/label/c.Average';
import PreviousPage from '@salesforce/label/c.PreviousPage';
import NextPage from '@salesforce/label/c.NextPage';
import TotalRecords from '@salesforce/label/c.TotalRecords';
import Recordsperpage from '@salesforce/label/c.Recordsperpage';
import Page from '@salesforce/label/c.Page';
import OF from '@salesforce/label/c.OF';
import NetProceeds from '@salesforce/label/c.NetProceeds';
import Sorting from '@salesforce/label/c.Sorting';
import Sorting1 from '@salesforce/label/c.Sorting1';
import Sorting2 from '@salesforce/label/c.Sorting2';
import Sorting3 from '@salesforce/label/c.Sorting3';
import Sorting4 from '@salesforce/label/c.Sorting4';
import Sorting5 from '@salesforce/label/c.Sorting5';
import Sorting6 from '@salesforce/label/c.Sorting6';
import SaveSubmitpopUpMsg from '@salesforce/label/c.SaveSubmitpopUpMsg';
import EditDeltaNetProceeds from '@salesforce/label/c.EditDeltaNetProceeds';
import LastSavedOnLabel from '@salesforce/label/c.LastSavedOnLabel';
import PercentageChangeLabel from '@salesforce/label/c.PercentageChangeLabel';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import BUSINESSAREA_FIELD from '@salesforce/schema/SalesPlanning__c.BusinessArea__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
export default class AccountPlanning extends LightningElement {
    @track columnNames = [];
    @track columnNamesForActualValue = [];
    @track options;
    @track disableSort = true;
    @track sortingorder='';
    @track bussArea;
    @track data = [];
    @track error;
    @track showdata = false;
    @track showActualdata = false;
    @track soldamountlist =[];
    @track NetProceeds =[];
    @track rolledupsoldamt =[];
    @track rolledupNetProceeds =[];
    @track isEditing= false;
    @track currentPageNumber = 1;
    @track rowsPerPage = 20;
    @track rowsTotalCount;
    @track isLoading = false;
    @track combinedList = [];
    @track withoutExtraRowList = []; //9881
    @track excludedItems =[];
    @track withoutExtraRowListNew =[];
    @track excludedItemsAverage;
    @track NewexcludedItems =[];
    @track exitValueArray = [];
    @track filterList = [];
    @track LastSubmittedOn;
    @track disabledBtn;
    @track disabledDeltaBtn = false;
    @track UserID;
    @track timeoutInMiliseconds = 30000;
    @track editbutton = false;
    @track editedbyId;
    @track isValidProfile;
    @track editButtonDelta = false;
    @track actualSoldAmountList = [];
    @track actualNetProceedsList = [];
    @track combinedActualList = [];
    @track rolledupActualsoldamt = [];
    @track rolledupActualNetProceeds = [];
    @track showSaveAndSubmit= false;
    @track deltaNetProceeds = [];
    label = {
      EditButtonForSalesForecasting,
      SaveButtonForSalesForecasting,
      LastSavedOnLabel,
      CancelForSalesPlanning,
      BusinessAreaProductGroupForPlanning,
      Total,
      Average,
      PreviousPage,
      NextPage,
      TotalRecords,
      Recordsperpage,
      Page,
      OF,
      DeltaNetProceeds,
      SaveAndSubmit,
      ActualValuesFromTheLast12Months,
      SaveSubmitpopUpMsg,
      EditDeltaNetProceeds,
      SoldAmount,
      NetProceeds,
      PercentageChangeLabel,
      Sorting,
      Sorting1,
      Sorting2,
      Sorting3,
      Sorting4,
      Sorting5,
      Sorting6
    }
    sortingOptions = [
      { label: Sorting1 , value: Sorting1 },
      { label: Sorting2 , value: Sorting2 },
      { label: Sorting3, value: Sorting3 },
      { label: Sorting4, value: Sorting4 },
      { label: Sorting5, value: Sorting5 },
      { label: Sorting6, value: Sorting6}
    ];
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: BUSINESSAREA_FIELD})
    setPicklistOptions({error, data}) {
      if (data) {
          this.options = data.values;
      }
      else if (error) {
        console.error(error);
      }
    }
    @wire(getAccountPlanningColumnNames) 
    wiredColumnNames({ error, data }) {
      if (data) {
        this.columnNames = data;
      } else if (error) {
        console.error(error);
      }
    } 
   
    connectedCallback(){
      this.getSaveDate();
      this.getMarketingUsers();
      window.addEventListener('beforeunload', this.refreshPage.bind(this));
    }

    disconnectedCallback(){
      window.removeEventListener('beforeunload', this.refreshPage.bind(this));
    }
    handleSort(event){
      this.sortingorder = event.detail.value;
      this.showtabledata();
    }
    refreshPage(event){
      var editedBy;
      event.preventDefault();
      event.returnValue = '';
      getSalesPlanningLogForEdit()
        .then(result => {
           editedBy = result.EditedBy__c;
                if(editedBy==Id){
                  this.updateSalesPlanningLogForEdit(false,false); 
                }                  
        })
        .catch(error => {
            this.errors = error;
        });
    }
   getMarketingUsers(){
      this.handleIsLoading(true);
      getMarketingUsers()
        .then(result => {
          this.handleIsLoading(false);
          if(result === true){
              this.disableButtons()
              this.disabledDeltaBtn =false;
          }else{
            this.disabledBtn = true;
            this.disabledDeltaBtn =true;
          }
        })
        .catch(error => {
            this.errors = error;
            this.handleIsLoading(false);
        });
    }
    get totalPages() {
      var lengthOfTable = this.withoutExtraRowList.length; //this.combinedList.length;
      return Math.ceil(lengthOfTable / this.rowsPerPage);
    }
    get disablePrevious() {
      return this.currentPageNumber === 1;
    }
    get disableNext() {
      return this.currentPageNumber === this.totalPages;
    }
    get displayedData() {
      this.withoutExtraRowListNew = [];
      this.NewexcludedItems = [];
      this.exitValueArray = [];
      this.combinedList = [];
      const startIndex = (this.currentPageNumber - 1) * this.rowsPerPage;
      const endIndex = startIndex + this.rowsPerPage;
     
        this.rowsTotalCount = this.withoutExtraRowList.slice(startIndex, endIndex).length;
        this.withoutExtraRowListNew = this.withoutExtraRowList.slice(startIndex, endIndex);

        
       
      for(let i = 0 ; i < this.excludedItems.length; i++){
        for(let j = startIndex; j <= endIndex; j++){
          if(this.excludedItems[i].index === j && !this.exitValueArray.includes(this.excludedItems[i].index)){
            this.NewexcludedItems.push(this.excludedItems[i]);
            this.exitValueArray.push(this.excludedItems[i].index);
          }
        }
      }

      for(let i = 0 ; i < this.withoutExtraRowListNew.length; i++){
          if(this.withoutExtraRowListNew[i].Account != null && this.withoutExtraRowListNew[i].Account === "Average of not planned Accounts"){
            this.NewexcludedItems.push(this.excludedItemsAverage);
          }
      }
      this.combinedList = [...this.withoutExtraRowListNew, ...this.NewexcludedItems];
      this.combinedList.sort((a, b) => a.index - b.index); 
      return this.combinedList; 
      }
      
    handlePrevious() {
      this.exitValueArray = [];
      if(!this.isEditing)
      {
        if (this.currentPageNumber > 1) {
          this.currentPageNumber -= 1;
        }
      }
      else{
        const evt = new ShowToastEvent({
          title: 'Warning',
          message: 'Please Save the Edited Content before proceeding',
          variant: 'Warning',
          mode: 'dismissable'
      });
      this.dispatchEvent(evt);
      }
    }
    handleNext() {
      if(!this.isEditing)
      {
        if (this.currentPageNumber < this.totalPages) {
            this.currentPageNumber += 1;
        }
      }
      else{
        const evt = new ShowToastEvent({
          title: 'Warning',
          message: 'Please Save the Edited Content before proceeding',
          variant: 'Warning',
          mode: 'dismissable'
      });
      this.dispatchEvent(evt);
      }
    }  
    showtabledata(){
      this.handleIsLoading(true);
      showtabledata({businessArea : this.bussArea,
                     sortOrder : this.sortingorder})
            .then(result => {
              this.handleIsLoading(false);
              console.log('showtabledata',result)
              if(result){
                    this.soldamountlist = result.getSoldAmount;
                    this.NetProceeds =result.ForecastNetProceeds;
                    this.rolledupsoldamt = result.soldCalculation;
                    this.rolledupNetProceeds =result.netProceedCalculation;
                    this.deltaNetProceeds = result.deltacalculation;
                    this.showdata = true;
                    for(let i = 0; i < this.soldamountlist.length; i++) {
                      this.soldamountlist[i].source = 'list1';  
                    }
                    this.combinedList = [...this.soldamountlist];
                    for(let i = 0; i < this.rolledupsoldamt.length; i++) {
                      this.rolledupsoldamt[i].source = 'Total';
                    }
                    this.combinedList.push(...this.rolledupsoldamt);
                    for(let i = 0; i < this.deltaNetProceeds.length; i++) {
                      this.deltaNetProceeds[i].source = 'Delta';
                    }
                    this.combinedList.push(...this.deltaNetProceeds);
                    for(let i = 0; i < this.NetProceeds.length; i++) {
                      this.NetProceeds[i].source = 'list2';
                    }
                    this.combinedList.push(...this.NetProceeds);
                    this.combinedList.push(...this.rolledupNetProceeds);
                    this.combinedList = this.combinedList.map((row, index) => ({ ...row, index }));
                    
                    this.withoutExtraRowList = [];
                    this.excludedItems = [];
                    this.exitValueArray = [];
                    for(let i = 0; i < this.combinedList.length; i++) {
                      if(!this.combinedList[i].isSoldAmount && !this.combinedList[i].isPerRow && !this.combinedList[i].isTotal
                      && !this.combinedList[i].deltaNetProceed && !this.combinedList[i].blankline && !this.combinedList[i].isNetProceed && !this.combinedList[i].isAverage) { 
                      this.withoutExtraRowList.push(this.combinedList[i]);
                      }else{
                        if(!this.combinedList[i].isAverage){
                          this.excludedItems.push(this.combinedList[i]);
                        }else{
                          this.excludedItemsAverage = this.combinedList[i];
                        }
                        
                      }
                    }

                  }
              else{
                    console.log('Error');
                }
            })
            .catch(error => {
                this.error = error;
                this.handleIsLoading(false);
            })
    }
    handleChange(event){
     this.isEditing =false;
     this.disableSort = false;
     this.withoutExtraRowList = [];
     this.excludedItems = [];
     this.exitValueArray = [];
     
     if(!this.isEditing)
      {
        if (this.currentPageNumber > 1) {
           this.currentPageNumber = 1;
        }
      }
     //this.handlePrevious();
     this.bussArea = event.detail.value;
     this.showtabledata(); 
    }
    disableButtons(){
      this.handleIsLoading(true);
      getSalesPlanningLogForEdit()
        .then(result => {
          this.handleIsLoading(false);
            if(result.InEditMode__c === true && result.EditedBy__c!=Id)
              this.disabledBtn = true;
            else{
              this.disabledBtn = false;
            }
         
        })
        .catch(error => {
            this.errors = error;
            this.handleIsLoading(false);
        });   
    }
    handleDeltaEdit(){
      this.editButtonDelta = true;
      this.disabledBtn = true;
      
    }
    handleEdit() {
     this.disabledDeltaBtn = true;
     this.editbutton = true;
   
      getSalesPlanningLogForEdit()
        .then(result => {
            if(result.InEditMode__c === true && result.EditedBy__c!=Id){             
              this.isEditing = false;
            }
            else{
              this.isEditing = true;
             
            }
            this.updateSalesPlanningLogForEdit(this.isEditing,this.editbutton);           
        })
        .catch(error => {
            this.errors = error;
        });        
    }

    updateSalesPlanningLogForEdit(isEditing,editbutton)
    { 
      this.handleIsLoading(true);
      updateSalesPlanningLogForEdit({IsEdit : isEditing,
                                     editbutton : editbutton
                                    })
      .then(result => {
        this.handleIsLoading(false);
          if(result ==Id)
           this.disabledBtn = false;
           else if(Id==this.UserID)
           this.disabledBtn = false;
           else
           this.disabledBtn = true;
      })
      .catch(error => {
          this.errors = error;
          this.handleIsLoading(false);
      });
    }
    handleSaveAndSubmit(){
      if(this.editButtonDelta===true)
       this.showSaveAndSubmit=true;
    }    
    closeSaveAndSubmit(){
      this.showSaveAndSubmit=false;
    }
    CancelModal() {
      this.showSaveAndSubmit = false;
    }
    SaveAndSubmitModal(){
      if(this.editButtonDelta === true){
        this.handleIsLoading(true);
         toCalculateDeltaNet({newAccDeltaWrapper:  JSON.stringify(this.deltaNetProceeds),
                              bussinessArea : this.bussArea 
                            })
                            .then(result => {
                            this.handleIsLoading(false);
                             if(result === 'Success'){
                                  this.dispatchEvent(
                                      new ShowToastEvent({
                                          title: 'Success',
                                          message: result,
                                          variant: 'Success'
                                      })
                                  );
                                  this.disabledBtn = false;
                                  this.showSaveAndSubmit=false;
                                  this.showtabledata();
                              }else{
                                 this.dispatchEvent(
                                  new ShowToastEvent({
                                    title: 'Error',
                                    message: result,
                                    variant: 'Error'
                                      })
                                  ); 
                               }
                               this.editButtonDelta = false;
                            })
                            .catch(error => {
                              this.errors = error;
                              this.dispatchEvent(
                              new ShowToastEvent({
                                 title: 'Error',
                                 message: this.errors,
                                 variant: 'Error'
                                   })
                              ); 
                              this.editButtonDelta = false;
                              this.handleIsLoading(false);
                            });
       }    
    }
    handleSave(){
      if(this.isEditing === true){
        this.handleIsLoading(true);
        upsertSPForecaste({ newAccSoldWrapper:  JSON.stringify(this.soldamountlist),
                            newAccNetWrapper: JSON.stringify(this.NetProceeds),
                            bussinessArea : this.bussArea 
                        })
      .then(result => {
        this.handleIsLoading(false);
       if(result === 'Success'){
          this.getSaveDate();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: result,
                    variant: 'Success'
                })
            );
            this.isEditing = false;
            this.UserID = Id;
            this.editbutton = false;
            this.updateSalesPlanningLogForEdit(this.isEditing,this.editbutton);
            //window.location.reload();,
            this.disabledDeltaBtn = false;
            this.showtabledata();
        }else{
           this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: result,
              variant: 'Error'
                })
            ); 
         }
         this.isEditing = false;
      })
      .catch(error => {
        this.errors = error;
        this.dispatchEvent(
        new ShowToastEvent({
           title: 'Error',
           message: this.errors,
           variant: 'Error'
             })
        ); 
        this.isEditing = false;
        this.handleIsLoading(false);
      });
    }
  }
  handleDeltaCancel(){
    this.editButtonDelta = false;
    this.disabledBtn = false;
  }
  handleCancel(){
    this.isEditing = false;
    this.UserID = Id;
    this.editbutton = false;
    this.disabledDeltaBtn = false;
    this.updateSalesPlanningLogForEdit(this.isEditing,this.editbutton);
  }
  handleNameChange(event) {
    let data = this.combinedList.filter(
      element => element.index === parseInt(event.target.dataset.index));
    let unwrappedData = JSON.parse(JSON.stringify(data));
   
    if(unwrappedData[0].source != null && unwrappedData[0].source === 'list1'){
      for(let i = 0; i < this.soldamountlist.length; i++){
        
      if(this.soldamountlist[i].accountId != null && this.soldamountlist[i].accountId === unwrappedData[0].accountId){
        if(event.target.value !== null && event.target.value !== ''){
          this.soldamountlist[i][event.target.name] = event.target.value; 
        }else{
          this.soldamountlist[i][event.target.name] = 0;  
        }
      }else if(this.soldamountlist[i].accountId == null && this.soldamountlist[i].Account === unwrappedData[0].Account){
        if(event.target.value !== null && event.target.value !== ''){
          this.soldamountlist[i][event.target.name] = event.target.value; 
        }else{
          this.soldamountlist[i][event.target.name] = 0;  
        }
      }
      
      }  
    }
    if(unwrappedData[0].source === 'list2'){
      for(let i = 0; i < this.NetProceeds.length; i++){
      if(this.NetProceeds[i].accountId!= null && this.NetProceeds[i].accountId === unwrappedData[0].accountId){
        if(event.target.value !== null && event.target.value !== ''){
          this.NetProceeds[i][event.target.name] = event.target.value;
        }else{
          this.NetProceeds[i][event.target.name] = 0;
        }
      }else if(this.NetProceeds[i].accountId == null && this.NetProceeds[i].accountId === unwrappedData[0].accountId){
        if(event.target.value !== null && event.target.value !== ''){
          this.NetProceeds[i][event.target.name] = event.target.value;
        }else{
          this.NetProceeds[i][event.target.name] = 0;
        }
      }
        
        
      }
    }
    if(unwrappedData[0].source === 'Delta'){
      for(let i = 0; i < this.deltaNetProceeds.length; i++){
      //if(this.deltaNetProceeds[i].Account == this.combinedList[event.target.dataset.index].Account)
      if(event.target.value !== null && event.target.value !== ''){
        this.deltaNetProceeds[i][event.target.name] = event.target.value; 
      }else{
        this.deltaNetProceeds[i][event.target.name] = 0; 
      }
      }  
    }
    
  }
  getSaveDate(){
    this.handleIsLoading(true);
    updateSalesPlanningLog()
    .then(result => {
      this.handleIsLoading(false);
       this.LastSubmittedOn = result.LastSubmittedOn__c;
    })
    .catch(error => {
        this.errors = error;
        this.handleIsLoading(false);
    });
  }
   handleIsLoading(isLoading) {
    this.isLoading = isLoading;
  }


  handleOV(event){
   let previousMonth = event.currentTarget.title;
   console.log(previousMonth);
   let oVMonth = event.currentTarget.name;
   console.log(oVMonth);
   this.handleIsLoading(true);
   overrideCalulation({oVMonth : oVMonth, previousMonth: previousMonth, bussinessArea : this.bussArea})
       .then(result => {
            this.handleIsLoading(false);
          if(result === 'Success'){
              this.dispatchEvent(
              new ShowToastEvent({
                title: 'Success',
                message: result,
                variant: 'Success'
              })
          );
            this.showtabledata();
          }else{
            this.dispatchEvent(
            new ShowToastEvent({
            title: 'Error',
            message: result,
             variant: 'Error'
            }) ); 
          }
  })
  .catch(error => {
            this.errors = error;
            this.dispatchEvent(
            new ShowToastEvent({
            title: 'Error',
            message: this.errors,
            variant: 'Error'
         })); 
    this.handleIsLoading(false);
    });

  }
}