import { LightningElement, wire, track } from 'lwc';
import getColumnNames from '@salesforce/apex/SalesForecastingController.getColumnNames';
import getSoldAmount from '@salesforce/apex/SalesForecastingController.getSoldAmount';
import getMarketingUsers from '@salesforce/apex/SalesForecastingController.getMarketingUsers';
import getSalesPlanningLog from '@salesforce/apex/SalesForecastingController.getSalesPlanningLog';
import updateSalesPlanningLog from '@salesforce/apex/SalesForecastingController.updateSalesPlanningLog';
import upsertSPForecaste from '@salesforce/apex/SalesForecastingController.upsertSPForecaste';
import uploadFile from '@salesforce/apex/SalesForecastingController.uploadFile';
import EditButtonForSalesForecasting from '@salesforce/label/c.EditButtonForSalesForecasting';
import SaveButtonForSalesForecasting from '@salesforce/label/c.SaveButtonForSalesForecasting';
import LastSavedOnLabel from '@salesforce/label/c.LastSavedOnLabel';
import LastSubmittedOnLabel from '@salesforce/label/c.LastSubmittedOnLabel';
import MessageForSubmit from '@salesforce/label/c.MessageForSubmit';
import LastRolledupfromAccountlevelLabel from '@salesforce/label/c.LastRolledupfromAccountlevelLabel';
import LastRolledupAnnualPlanningLabel from '@salesforce/label/c.LastRolledupAnnualPlanningLabel';
import SubmitButtonForSalesForecasting from '@salesforce/label/c.SubmitButtonForSalesForecasting';
import RollupfromAccountlevelButtonForSF from '@salesforce/label/c.RollupfromAccountlevelButtonForSF';
import RollupAnnualPlanningButtonForSF from '@salesforce/label/c.RollupAnnualPlanningButtonForSF';
import SubmitPopupMsgForSF from '@salesforce/label/c.SubmitPopupMsgForSF';
import RollUpPopupMsgForSF from '@salesforce/label/c.RollUpPopupMsgForSF';
import ExportForSalesPlanning from '@salesforce/label/c.ExportForSalesPlanning';
import SaveFinalVersion from '@salesforce/label/c.SaveFinalVersion';
import TotalDrawingGradesSoldAmounts from '@salesforce/label/c.TotalDrawingGradesSoldAmounts';
import TotalDrawingGradesNetProceeds from '@salesforce/label/c.TotalDrawingGradesNetProceeds';
import TotalSoldAmounts from '@salesforce/label/c.TotalSoldAmounts';
import AverageNetProceeds from '@salesforce/label/c.AverageNetProceeds';
import CancelForSalesPlanning from '@salesforce/label/c.CancelForSalesPlanning';
import RollAccountPlanPopupMsgForSF from '@salesforce/label/c.RollAccountPlanPopupMsgForSF';
import DrawingGradeLabel from '@salesforce/label/c.DrawingGradeLabel'; //3911
import SoldAmount from '@salesforce/label/c.SoldAmount'; //4023
import NetProceeds from '@salesforce/label/c.NetProceeds'; //4023
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import RollupFromAccountLevelCal from '@salesforce/apex/RollupFromAccountLevelController.rollupFromAccountLevelCal'; //US-2510
import SubmitSPPlanning from '@salesforce/apex/SalesForecastingController.SubmitBAPlanning';
import updateSalesPlanningLogForEdit from '@salesforce/apex/SalesForecastingController.updateSalesPlanningLogForEdit';
import Id from '@salesforce/user/Id';

import RollupAnnualPlanningCal from '@salesforce/apex/RollupFromAccountLevelController.rollupAnnualPlanningCal'; //US-3586
export default class BusinessPlanning extends LightningElement {
  
  columnNames = [];
    @track months = [];
    @track soldamountBusinessArea = [];
    @track NetProceedBusinessArea = [];
    @track oldSoldamountBusinessArea = [];
    @track oldNetProceedBusinessArea = [];
    @track soldCalculation = [];
    @track netProceedCalculation = [];
    @track drawingSoldCalculation = [];
    @track drawingnetProceedCalculation = [];
    //3911 - Start
    @track drawingSoldTable = []; 
    @track drawingNetTable = []; 
     //3911 - End
    
    @track isEditing = false;
    @track disabledBtn = false;
    @track isModalOpen = false;
    @track isModalRollUpOpen = false;
    @track isModalAnnualPlanOpen = false;
    @track SalesPlanningLog;
    @track LastSavedOnDate;
    @track LastSubmittedOnDate;
    @track LastRolledUpOnDate;
    @track LastRolledupAnnualPlanningLabel;
    @track isLoading = false;
    @track isRollUpAnnualPlanning=false;
    @track showSaveFinalVersionModal=false;
    @track editbutton = false;
    @track EditedBy;
    @track isValidProfile;
    fileData;

    label = {
      EditButtonForSalesForecasting,
      SaveButtonForSalesForecasting,
      LastSavedOnLabel,
      LastSubmittedOnLabel,
      LastRolledupfromAccountlevelLabel,
      LastRolledupAnnualPlanningLabel,
      SubmitButtonForSalesForecasting,
      RollupfromAccountlevelButtonForSF,
      RollupAnnualPlanningButtonForSF,
      SubmitPopupMsgForSF,
      RollUpPopupMsgForSF,
      RollAccountPlanPopupMsgForSF,
      ExportForSalesPlanning,
      SaveFinalVersion,
      TotalDrawingGradesSoldAmounts,
      TotalSoldAmounts,
      AverageNetProceeds,
      CancelForSalesPlanning,
      TotalDrawingGradesNetProceeds,
      DrawingGradeLabel,
      SoldAmount,
      NetProceeds,
      MessageForSubmit
    }
    @track drawingGradeLabel =  DrawingGradeLabel;
    connectedCallback(){
      this.getTableData();
      this.getSalesPlanningLog();
      this.getMarketingUsers();
      window.addEventListener('beforeunload', this.refreshPage.bind(this));
      this.disableButtons();
    }
    disconnectedCallback(){
      window.removeEventListener('beforeunload', this.refreshPage.bind(this));
    }
    refreshPage(event){
      var editedBy;
      event.preventDefault();
      event.returnValue = '';
      getSalesPlanningLog()
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
    disableButtons(){
      getSalesPlanningLog()
        .then(result => {
          if(this.isValidProfile === true){
            if(result.InEditMode__c === true && result.EditedBy__c!=Id)
              this.disabledBtn = true;
            else{
              this.disabledBtn = false;
            }
          }
          else{
            this.disabledBtn = true;
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
            console.log(result);
          if(result === true){
             this.isValidProfile = true;
          }else{
            this.isValidProfile = false;
          }
        })
        .catch(error => {
            this.errors = error;
            this.handleIsLoading(false);
        });
    }

    getSalesPlanningLog(){
      this.handleIsLoading(true);
      getSalesPlanningLog()
        .then(result => {
          this.handleIsLoading(false);
            console.log(result);
            if(result != null){
            this.SalesPlanningLog = result;
            this.LastSavedOnDate = this.SalesPlanningLog.LastSavedOn__c;
            this.LastSubmittedOnDate = this.SalesPlanningLog.LastSubmittedOn__c;
            this.LastRolledUpOnDate = this.SalesPlanningLog.LastRolledUpOn__c;
            this.LastRolledupAnnualPlanningLabel = this.SalesPlanningLog.LastRolledUpAnnualPlanning__c;
          }
        })
        .catch(error => {
            this.errors = error;
            this.handleIsLoading(false);
        });
    }
    handleEdit() {
      this.editbutton = true;
      getSalesPlanningLog()
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
      updateSalesPlanningLogForEdit({IsEdit : isEditing,
                                     editbutton : editbutton
                                    })
      .then(result => {
          if(result ==Id)
           this.disabledBtn = false;
           else if(Id==this.UserID)
           this.disabledBtn = false;
           else
           this.disabledBtn = true;
      })
      .catch(error => {
          this.errors = error;
      });
    }
    @wire(getColumnNames) 
    wiredColumnNames({ error, data }) {
      if (data) {
        this.columnNames = data;
      } else if (error) {
        console.error(error);
      }
    }
  getTableData() {
      this.handleIsLoading(true);
      getSoldAmount()
      .then(data => {
        this.handleIsLoading(false);
        if (data) {
          this.oldSoldamountBusinessArea = data.getSoldAmount;
          for(let i = 0; i < this.oldSoldamountBusinessArea.length; i++) {
           let str = this.oldSoldamountBusinessArea[i].BusinessArea;
            if(str.includes(this.drawingGradeLabel)){
               this.drawingSoldTable.push(this.oldSoldamountBusinessArea[i]);
            }else{
              this.soldamountBusinessArea.push(this.oldSoldamountBusinessArea[i]);
                }
          }

          this.drawingSoldTable = this.drawingSoldTable.map((row, index) => ({ ...row, index }));
          this.soldamountBusinessArea = this.soldamountBusinessArea.map((row, index) => ({ ...row, index }));
          console.log('getting arr data :::', this.drawingSoldTable);
          
          this.oldNetProceedBusinessArea = data.ForecastNetProceeds;
          for(let i = 0; i < this.oldNetProceedBusinessArea.length; i++) {
            let str = this.oldNetProceedBusinessArea[i].BusinessArea;
             if(str.includes(this.drawingGradeLabel)){
                this.drawingNetTable.push(this.oldNetProceedBusinessArea[i]);
             }else{
              this.NetProceedBusinessArea.push(this.oldNetProceedBusinessArea[i]);
             }
           }

          this.drawingNetTable = this.drawingNetTable.map((row, index) => ({ ...row, index }));
          this.NetProceedBusinessArea = this.NetProceedBusinessArea.map((row, index) => ({ ...row, index }));
          
          this.soldCalculation = data.soldCalculation;
          this.netProceedCalculation = data.netProceedCalculation;
          this.drawingSoldCalculation = data.drawingSoldCalculation;
          this.drawingnetProceedCalculation = data.drawingnetProceedCalculation;
        } else if (error) {
          console.error(error);
        }
      })
      .catch(error => {
          this.errors = error;
          this.handleIsLoading(false);
      });
        
    }
    handleNameChange(event) {
      if(event.target.value !== null && event.target.value !== ''){
      this.soldamountBusinessArea[event.target.dataset.index][event.target.name] = event.target.value;
      }else{
      this.soldamountBusinessArea[event.target.dataset.index][event.target.name] = 0;
        
      }
      console.log(JSON.parse(JSON.stringify(this.soldamountBusinessArea)));
      
  }
  //3911 - start
  handleDwSoldChange(event){
    if(event.target.value !== null && event.target.value !== ''){
    this.drawingSoldTable[event.target.dataset.index][event.target.name] = event.target.value;
    }else{
    this.drawingSoldTable[event.target.dataset.index][event.target.name] = 0 ;
    }
    console.log('drawingSoldTable::', JSON.parse(JSON.stringify(this.drawingSoldTable)));
  }

  handleDwNetChange(event){
    if(event.target.value !== null && event.target.value !== ''){
    this.drawingNetTable[event.target.dataset.index][event.target.name] = event.target.value;
    }else{
    this.drawingNetTable[event.target.dataset.index][event.target.name] = 0;  
    }
    console.log('drawingNetTable::', JSON.parse(JSON.stringify(this.drawingNetTable)));
  }

   //3911 - end
  handleNameNetPChange(event) {
    if(event.target.value !== null && event.target.value !== ''){
    this.NetProceedBusinessArea[event.target.dataset.index][event.target.name] = event.target.value;
    }else{
    this.NetProceedBusinessArea[event.target.dataset.index][event.target.name] = 0;   
    }
    console.log(JSON.parse(JSON.stringify(this.NetProceedBusinessArea)));
    
  }
 
  handleSaveClick(){
    if(this.isEditing === true){
      this.handleIsLoading(true);
    let editedData;
    let editedNetPData;
    this.soldamountBusinessArea = this.soldamountBusinessArea.map(({ index, ...rest }) => rest);
    this.drawingSoldTable = this.drawingSoldTable.map(({ index, ...rest }) => rest);
    editedData =  this.soldamountBusinessArea.concat(this.drawingSoldTable);
    console.log('editedData',JSON.stringify(editedData));

    this.NetProceedBusinessArea = this.NetProceedBusinessArea.map(({ index, ...rest }) => rest);
    this.drawingNetTable = this.drawingNetTable.map(({ index, ...rest }) => rest); // 3911
    editedNetPData =  this.NetProceedBusinessArea.concat(this.drawingNetTable);

    upsertSPForecaste({ newBussAreaSoldWrapper:  JSON.stringify(editedData),
                        oldBussAreaSoldWrapper: JSON.stringify(this.oldSoldamountBusinessArea),
                        newBussAreaNetWrapper: JSON.stringify(editedNetPData),
                        oldBussAreaNetWrapper: JSON.stringify(this.oldNetProceedBusinessArea)
                     })
  .then(result => {
    this.handleIsLoading(false);
    console.log(result);
       if(result === 'Success'){
      this.getSaveDate();
      //this.getTableData();
      this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: result,
                    variant: 'Success'
                })
            );
        }else{
           this.dispatchEvent(new CloseActionScreenEvent());
           this.dispatchEvent(
          new ShowToastEvent({
              title: 'Error',
              message: result,
              variant: 'Error'
                })
           ); 
         }
    this.isEditing = false;
    this.UserID = Id;
    console.log('User ID--->'+this.UserID);
    this.editbutton = false;
    this.updateSalesPlanningLogForEdit(this.isEditing,this.editbutton);
    window.location.reload();
  })
  .catch(error => {
      this.errors = error;
      this.dispatchEvent(new CloseActionScreenEvent());
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
   getSaveDate(){
    this.handleIsLoading(true);
    updateSalesPlanningLog({logDetails : 'LastSavedOn'})
  .then(result => {
    this.handleIsLoading(false);
      console.log(result);
      this.getSalesPlanningLog();
  })
  .catch(error => {
      this.errors = error;
      this.handleIsLoading(false);
  });
   }
  handleClickCancle(){
    this.isEditing = false;
    this.UserID = Id;
    this.editbutton = false;
    this.updateSalesPlanningLogForEdit(this.isEditing,this.editbutton);
  }

  handleSubmitClick(){
    this.isModalOpen = true;
  }
  closeModal() {
    // to close modal set isModalOpen tarck value as false
    this.isModalOpen = false;
}
submitDetails() {
  this.handleIsLoading(true);
  SubmitSPPlanning();
  updateSalesPlanningLog({logDetails : 'LastSubmittedOn'})
  .then(result => {
      this.getSalesPlanningLog();
      this.handleIsLoading(false);
      this.isModalOpen = false;
  })
  .catch(error => {
      this.errors = error;
      this.isModalOpen = false;
      this.handleIsLoading(false);
  });
    
}


handleROLLUPAccountClick(){
  this.isModalRollUpOpen = true;
}
rOLLUPAccountcloseModal() {
  // to close modal set isModalOpen tarck value as false
  this.isModalRollUpOpen = false;
}
//2510 - Start
rOLLUPAccountsubmitDetails() {
  this.handleIsLoading(true);
  //this.getLastRolledUpOnDate();
  RollupFromAccountLevelCal()
  .then(result => {
    this.handleIsLoading(false);
    if(result === 'Success'){
      this.getLastRolledUpOnDate();
      this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: result,
                    variant: 'Success'
                })
            );
        }else{
           this.dispatchEvent(new CloseActionScreenEvent());
           this.dispatchEvent(
          new ShowToastEvent({
              title: 'Error',
              message: result,
              variant: 'Error'
                })
           ); 
         }
    this.isModalRollUpOpen = false;
    window.location.reload()
    
  })
  .catch(error => {
      this.errors = error;
      this.dispatchEvent(new CloseActionScreenEvent());
      this.dispatchEvent(
     new ShowToastEvent({
         title: 'Error',
         message: this.errors,
         variant: 'Error'
           })
      ); 
      this.isModalRollUpOpen = false;
      this.handleIsLoading(false);
  });
  
}

getLastRolledUpOnDate(){
  this.handleIsLoading(true);
  updateSalesPlanningLog({logDetails : 'LastRolledUpOn'})
  .then(result => {
    this.handleIsLoading(false);
      console.log(result);
  })
  .catch(error => {
      this.errors = error;
      this.handleIsLoading(false);
  });
}
//2510 - end
   //show/hide spinner
   handleIsLoading(isLoading) {
    this.isLoading = isLoading;
}

//3586 - Start
submitRollupAnnualPlanningClick(){
  this.handleIsLoading(true);
  RollupAnnualPlanningCal()
  .then(result => {
    this.handleIsLoading(false);
    if(result === 'Success'){
      this.RollupAnnualPlanningsDateDetails();
      this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: result,
                    variant: 'Success'
                })
            );
        }else{
           this.dispatchEvent(new CloseActionScreenEvent());
           this.dispatchEvent(
          new ShowToastEvent({
              title: 'Error',
              message: result,
              variant: 'Error'
                })
           ); 
         }
    this.isModalAnnualPlanOpen = false;
    window.location.reload()
    
  })
  .catch(error => {
      this.errors = error;
      this.dispatchEvent(new CloseActionScreenEvent());
      this.dispatchEvent(
     new ShowToastEvent({
         title: 'Error',
         message: this.errors,
         variant: 'Error'
           })
      ); 
      this.isModalAnnualPlanOpen = false;
      this.handleIsLoading(false);
  });
  
}

//3586 - Start
handleRollupAnnualPlanningClick(){
  this.isModalAnnualPlanOpen = true;
}
RollupAnnualPlanningcloseModal() {
  // to close modal set isModalOpen tarck value as false
  this.isModalAnnualPlanOpen = false;
}
RollupAnnualPlanningsDateDetails() {
  this.handleIsLoading(true);
  updateSalesPlanningLog({logDetails : 'LastRollAccountPlan'})
  .then(result => {
    this.handleIsLoading(false);
      console.log(result);
      this.getSalesPlanningLog();
      this.isModalAnnualPlanOpen = false;
  })
  .catch(error => {
      this.errors = error;
      this.isModalAnnualPlanOpen = false;
      this.handleIsLoading(false);
  });
  
}
//3911 Start
  closeSaveFinalVersionModal(){
    this.showSaveFinalVersionModal=false;
    this.fileData=null;
  }

    openfileUpload() {
      let postfix = this.template.querySelector('.filenameEnter').value;
      var filename = postfix +'.csv';
  // Generate the CSV file from the table view
  const csvContent = this.generateCsvFromTableView();

  // Convert the CSV file to a Blob object
  const file1 = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })

this.readerFile(file1, filename);
    }

    generateCsvFromTableView() {
      const rows = this.template.querySelectorAll('table tbody tr');
    const headerRow = this.template.querySelector('table thead tr');
    const headers = [...headerRow.children].map((cell) => `"${cell.innerText}"`).join(',');
    const lines = [...rows].map((row) => {
      const cells = [...row.children].map((cell) => {
        if (cell.querySelector('lightning-formatted-number')) {
          let rowValue ;
          if(cell.querySelector('lightning-formatted-number').value){
            rowValue = `"${cell.querySelector('lightning-formatted-number').value}"`;
          }else{
            rowValue = '';
          }
          return  rowValue; 
        }else if (cell.innerText.trim() === '') {
          return '';
        }
        if(cell.innerText.includes('€')){
          return `"${cell.innerText.replace('€', '&euro;')}"`;
        }
        return `"${cell.innerText}"`;
      });
      return cells.join(',');
    });
    return `${headers}\n${lines.join('\n')}`;
    }

    handleFileUpload(){
      const {base64, filename} = this.fileData;
        console.log(this.fileData);
      uploadFile({ base64, filename }).then(result=>{
        if(result === 'Success'){
          this.fileData = null
          let title = `${filename} uploaded successfully!!`
          this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: title,
                variant: 'Success'
            })
        );
        this.showSaveFinalVersionModal=false;
        }
        else{
          console.log('####'+this.fileData);
          this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Try Again! Upload Failed',
                variant: 'Error'
            })
        );
        }
          
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
    });
  

}
handleSaveFinalVersionClick(){
  this.showSaveFinalVersionModal=true;
}

 readerFile(file1, filename){
  const fileInput = file1; 
  const file = fileInput;
   const reader = new FileReader();
    reader.onload = () => {
        // Use a regex to remove data url part
        const base64 = reader.result
            .replace('data:', '')
            .replace(/^.+,/, '');
            this.fileData = {
              'filename': filename,
              'base64': base64
          }
    };
    reader.readAsDataURL(file);
 }
 //3911 End
//2966 Start
handleExportClick(){

  var dt = new Date();
        var day = dt.getDate();
        var month = dt.getMonth() + 1;
        var year = dt.getFullYear();
        var hour = dt.getHours();
        var mins = dt.getMinutes();
        var postfix = day + "." + month + "." + year + "_" + hour + "." + mins;
        var filename = postfix?postfix +'.csv':'excel_data.csv';
        const csvContent = this.generateCsvFromTableView();
        var dataType = 'text/csv;charset=utf-8;'; 
        const link = document.createElement('a');
  link.href =  'data:' + dataType + ', ' + csvContent; //URL.createObjectURL(blob);
  link.download = filename;
  link.target = '_self';
  document.body.appendChild(link);
  link.click();
 
}
//2966 - End
}