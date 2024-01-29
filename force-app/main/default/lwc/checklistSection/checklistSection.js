import { LightningElement, api, track } from 'lwc';
import AddChecklist from '@salesforce/label/c.AddChecklist';
import { loadStyle } from "lightning/platformResourceLoader";
import visitCSS from "@salesforce/resourceUrl/VisitCSS";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import SaveChecklistQuestionResponseSuccess from '@salesforce/label/c.SaveChecklistQuestionResponseSuccess';
import saveChecklistQuestionResponses from '@salesforce/apex/VisitReportUtility.saveChecklistQuestionResponses';
import ManageChecklistRemoveButtons from '@salesforce/label/c.ManageChecklistRemoveButtons';
import ManageChecklistRemovePopup from '@salesforce/label/c.ManageChecklistRemovePopup';
import RemoveChecklistSuccessToast from '@salesforce/label/c.RemoveChecklistSuccessToast';
import getRemoveChecklistPopupMessage from '@salesforce/apex/VisitReportUtility.getRemoveChecklistPopupMessage';
import getChecklistNameById from '@salesforce/apex/VisitReportUtility.getChecklistNameById';
import getVisitReportNameById from '@salesforce/apex/VisitReportUtility.getVisitReportNameById';
import deleteChecklistQuestionResponses from '@salesforce/apex/VisitReportUtility.deleteChecklistQuestionResponses';

export default class ChecklistSection extends LightningElement {
    @api checklistitem;

    enterInputTextLabel = AddChecklist.split(';')[4];
    enterInputNumberLabel = AddChecklist.split(';')[5];
    selectOptionLabel = AddChecklist.split(';')[6];
    saveButtonLabel = AddChecklist.split(';')[7];

    successTitleLabel = SaveChecklistQuestionResponseSuccess.split(';')[0];
    successBodyLabel = SaveChecklistQuestionResponseSuccess.split(';')[1];

    showRemoveMessage = false;

    @api visitreportid;

    removeButtonLabel = ManageChecklistRemoveButtons.split(';')[0];
    removeChecklistYesButtonLabel = ManageChecklistRemoveButtons.split(';')[1];
    removeChecklistNoButtonLabel = ManageChecklistRemoveButtons.split(';')[2];
    removeChecklistPopupTileLabel = ManageChecklistRemovePopup.split(';')[0];
    removeChecklistPopupMessageLabel;
    removeChecklistSuccesToastTileLabel = RemoveChecklistSuccessToast.split(';')[0];
    removeChecklistSuccesToastMessageLabel = RemoveChecklistSuccessToast.split(';')[1];
    @track checklistId;

    renderedCallback() {
        Promise.all([
          loadStyle(
            this,
            visitCSS + "/css/C4MC_ChecklistSection.css"
          ),
        ]);
    }

    handleSaveButton(event){  
      let checklistQuestionResponseList = [];
      let checklistId = event.target.dataset.id;
      let i;
      //1.Get checkbox
        let checkboxes = this.template.querySelectorAll('[data-type="checkbox"]')
        for (i = 0; i < checkboxes.length; i++) {
          let checkboxOptions = [];
          checkboxOptions = checkboxes[i].value;
          for(let j = 0; j < checkboxOptions.length; j++){
            let pos =  this.findElementInList(checklistQuestionResponseList, 'questionResponseId', checkboxes[i].getAttribute("data-name"));
            if(pos > -1){
              let tempActualResponseList = [];
              
              tempActualResponseList = checklistQuestionResponseList[pos].actualResponseList;
              let indexNewLine = (checkboxOptions[j]).indexOf("\r");
              let optionText = checkboxOptions[j];
              optionText = optionText.substr(0, indexNewLine);
              if(indexNewLine > -1){
                tempActualResponseList.push(optionText);
              }else{
                tempActualResponseList.push(checkboxOptions[j]);
              }
              checklistQuestionResponseList[pos].actualResponseList = tempActualResponseList;
            }else{
              let questionResponseItem = {};
              questionResponseItem.questionResponseId = checkboxes[i].getAttribute("data-name");
              let tempActualResponseList = [];
              let indexNewLine = (checkboxOptions[j]).indexOf("\r");
              let optionText = checkboxOptions[j];
              optionText = optionText.substr(0, indexNewLine);
              if(indexNewLine > -1){
                tempActualResponseList.push(optionText);
              }else{
                tempActualResponseList.push(checkboxOptions[j]);
              }
              questionResponseItem.actualResponseList = tempActualResponseList;
              checklistQuestionResponseList.push(questionResponseItem);
            }  
          }
          
        }
        //2.Get radio
        let radioButtons = this.template.querySelectorAll('[data-type="radio"]');
        for (i = 0; i < radioButtons.length; i++) {
          if(radioButtons[i].value != null && radioButtons[i].value != 'undefined' && radioButtons[i].value != ''){
            let questionResponseItem = {};
            questionResponseItem.questionResponseId = radioButtons[i].getAttribute("data-name");
            let tempActualResponseList = [];
            let indexNewLine = (radioButtons[i].value).indexOf("\r");
            let optionText = radioButtons[i].value;
            optionText = optionText.substr(0, indexNewLine);
            if(indexNewLine > -1){
              tempActualResponseList.push(optionText);
            }else{
              tempActualResponseList.push(radioButtons[i].value);
            }
            tempActualResponseList.push(optionText);
            questionResponseItem.actualResponseList = tempActualResponseList;
            checklistQuestionResponseList.push(questionResponseItem);  
          }          
      }
      

        //3.Get inout text
        let inputsText = this.template.querySelectorAll('[data-type="text"]'); 
        if(inputsText != 'undefined'){
          for (i = 0; i < inputsText.length; i++) {
            if (inputsText[i].value != null && inputsText[i].value != 'undefined' && inputsText[i].value != '') {
              let questionResponseItem = {};
              questionResponseItem.questionResponseId = inputsText[i].getAttribute("data-name");
              let tempActualResponseList = [];
              tempActualResponseList.push(inputsText[i].value);
              questionResponseItem.actualResponseList = tempActualResponseList;
              checklistQuestionResponseList.push(questionResponseItem);            
            }
          }
        }


        //4.Get input number
        let inputsNumber = this.template.querySelectorAll('[data-type="number"]'); 
        if(inputsNumber != 'undefined'){
          for (i = 0; i < inputsNumber.length; i++) {
            if (inputsNumber[i].value != null && inputsNumber[i].value != 'undefined' && inputsNumber[i].value != '') {
              let questionResponseItem = {};
              questionResponseItem.questionResponseId = inputsNumber[i].getAttribute("data-name");
              let tempActualResponseList = [];
              tempActualResponseList.push(inputsNumber[i].value);
              questionResponseItem.actualResponseList = tempActualResponseList;
              checklistQuestionResponseList.push(questionResponseItem);            
            }
          }
        }

        //5.Get drop-down
        let dropdowns = this.template.querySelectorAll('[data-type="dropdown"]');  
        for (i = 0; i < dropdowns.length; i++) {
          let dropdownOptions = dropdowns[i];
          let selectedValue = dropdownOptions.value;
          if(selectedValue != null && selectedValue != 'undefined' && selectedValue != ''){
            let questionResponseItem = {};
            questionResponseItem.questionResponseId = dropdowns[i].getAttribute("data-name");
            let tempActualResponseList = [];
            tempActualResponseList.push(selectedValue);
            questionResponseItem.actualResponseList = tempActualResponseList;
            checklistQuestionResponseList.push(questionResponseItem);    
          }
        }

        //6.Call apex method to save
        saveChecklistQuestionResponses({jsonActualAnswers: JSON.stringify(checklistQuestionResponseList), visitReportId: this.visitreportid, checklistId: checklistId})
        .then(result => {
          this.dispatchEvent(new ShowToastEvent({
            title: this.successTitleLabel,
            variant: 'success',
            message: this.successBodyLabel
          }));
        }).catch(error => {
            console.log('Error when saving checklist answers: ' + JSON.stringify(error));
        });

    }

    findElementInList(array, attr, value) {
      for(var i = 0; i < array.length; i += 1) {
          if(array[i][attr] === value) {
              return i;
          }
      }
      return -1;
    }
    handleRemoveButton(event){
      this.showRemoveMessage = true;

      let checklistIdParam = event.target.dataset.id;
      this.checklistId = checklistIdParam;
      let checklistNameParam;
      let visitReportNameParam;
      let customLabelMessageParam = ManageChecklistRemovePopup.split(';')[1];
    
      getChecklistNameById({checklistId: checklistIdParam})
      .then(result => {
        checklistNameParam = result;

        getVisitReportNameById({visitReportId:this.visitreportid})
        .then(result => {
          visitReportNameParam = result;

          getRemoveChecklistPopupMessage({checklistName: checklistNameParam, visitReportName: visitReportNameParam, customLabelMessage: customLabelMessageParam})
          .then(result => {
              this.removeChecklistPopupMessageLabel = result;
          })
          .catch(error => {
              this.clickCount = 0;
              console.log('Error while fetching the remove message label  is ' + JSON.stringify(error));
          });
        })
        .catch(error => {
          console.log('Error while fetching the visit report name is ' + JSON.stringify(error));
        });
      })
      .catch(error => {
        console.log('Error while fetching the checklist name is ' + JSON.stringify(error));
      });

      
    }

    handleNoButton(){
      this.showRemoveMessage = false;
    }

    handleYesButton(){

      deleteChecklistQuestionResponses({visitReportId: this.visitreportid, checklistId: this.checklistId})
      .then(result => {
        this.dispatchEvent(new ShowToastEvent({
          title: this.removeChecklistSuccesToastTileLabel,
          variant: 'success',
          message: this.removeChecklistSuccesToastMessageLabel
        }));

        const refreshAddChecklistsEvent = new CustomEvent('refreshparentcomponent');
        this.dispatchEvent(refreshAddChecklistsEvent);
      })
      .catch(error => {
        console.log('Error when deleteing the checklist responses is' + JSON.stringify(error));
      });

      this.showRemoveMessage = false;
    }
}