import { LightningElement, api, track , wire} from 'lwc';
import sendprakulaIds from '@salesforce/apex/PrakulaDeliveryInstructionsController.sendprakulaIds';
import CancelAbbrechenSearch from '@salesforce/label/c.CancelAbbrechenSearch';
import SearchPrakulaScreenLabel from '@salesforce/label/c.SearchPrakulaScreenLabel';
import BackZurack from '@salesforce/label/c.BackZurack';
import NewPrakulaNeuesPrakula from '@salesforce/label/c.NewPrakulaNeuesPrakula';
import ProceedWeiter from '@salesforce/label/c.ProceedWeiter';
import DeliveryInstructionCriteria from '@salesforce/label/c.DeliveryInstructionCriteria';
import FoundPrakulaandrelatedDeliveryInstructions from '@salesforce/label/c.FoundPrakulaandrelatedDeliveryInstructions';
import RelatedLVPositions from '@salesforce/label/c.RelatedLVPositions';
import FoundPrakulaHelpText from '@salesforce/label/c.FoundPrakulaHelpText';
import RelatedLVPositionsHelpText from '@salesforce/label/c.RelatedLVPositionsHelpText';
import DeliveryInstructionCriteriaHelpText from '@salesforce/label/c.DeliveryInstructionCriteriaHelpText';
import {FlowNavigationBackEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';
import getDeliveryInstructionId from '@salesforce/apex/PrakulaDeliveryInstructionsController.getDeliveryInstructionId';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';


const FIELDS = ['OpportunityLineItem.Prakula__c', 'OpportunityLineItem.LVPosition__c' , 'OpportunityLineItem.Opportunity.Account.Name'];
export default class PrakulaDeliveryInstructionsScreen extends NavigationMixin(LightningElement) {
    @api DeliveryInstructionsID;
    @api OLIID ;
    @api buttonId;
    @api name; // not using
    @api label;
    @api selectedButtonId;
    @track prakulamap;
    @track prakulalist;
    @api prakulaId;
    @api lvpositionId;
    @track lvpositionlst = [];
    @api lvscreen = false;
    @api dIscreen = false;
    @api prakulaOnOLI;
    @api availableActions = [];
    @track showHelpText = false;
    @track disabledBtn = true;
    @api deliveryInsType;
    @api deliveryInsPublisher;
    @api deliveryInsRevision;
    @api deliveryInsTitle;
    @api deliveryInsDateOfIssue;
    label = {
        CancelAbbrechenSearch,
        BackZurack,
        NewPrakulaNeuesPrakula,
        ProceedWeiter,
        FoundPrakulaandrelatedDeliveryInstructions,
        DeliveryInstructionCriteria,
        RelatedLVPositions,
        FoundPrakulaHelpText,
        RelatedLVPositionsHelpText,
        DeliveryInstructionCriteriaHelpText,
        SearchPrakulaScreenLabel
    }
    DIType = SearchPrakulaScreenLabel.split(";")[0];
    DITitle = SearchPrakulaScreenLabel.split(";")[1];
    DIDateOfIssue = SearchPrakulaScreenLabel.split(";")[2];
    DIPublisher = SearchPrakulaScreenLabel.split(";")[3];
    HeatTreament = SearchPrakulaScreenLabel.split(";")[4];
    DimensionFrom = SearchPrakulaScreenLabel.split(";")[5];
    DimensionTo = SearchPrakulaScreenLabel.split(";")[6];
    Select = SearchPrakulaScreenLabel.split(";")[7];
    connectedCallback(){
        this.getDeliveryInstructionId();
        if(this.prakulaOnOLI){
           this.prakulaId = this.prakulaOnOLI;
           this.sendprakulaIds();
        }
     }
     @wire(getRecord, { recordId: '$OLIID', fields: FIELDS })
     record;
 
     get prakulaValue() {
         return this.record.data ? getFieldValue(this.record.data, 'OpportunityLineItem.Prakula__c') : '';
     }
 
     get lvpositionValue() {
         return this.record.data ? getFieldValue(this.record.data, 'OpportunityLineItem.LVPosition__c') : '';
     }
    getDeliveryInstructionId(){
        getDeliveryInstructionId({ deliveryInsType : this.deliveryInsType, deliveryInsPublisher : this.deliveryInsPublisher, deliveryInsRevision : this.deliveryInsRevision, deliveryInsTitle : this.deliveryInsTitle, deliveryInsDateOfIssue : this.deliveryInsDateOfIssue, OLIID : this.OLIID })
        .then(data => {
            console.log(data);
            if(data){
             this.prakulamap = data;
          let groupedDataMap = new Map();
          this.prakulamap.forEach(prakulaDI => {
                  if (groupedDataMap.has(prakulaDI.Praekula__c)) {
                      groupedDataMap.get(prakulaDI.Praekula__c).deliveryInstructions.push(prakulaDI);
                  } else {
                      let newprakulaDI = {};
                      newprakulaDI.Praekula = prakulaDI.Praekula__c;
                      newprakulaDI.PraekulaName = prakulaDI.Praekula__r.Name;
                      newprakulaDI.deliveryInstructions = [prakulaDI];
                      groupedDataMap.set(prakulaDI.Praekula__c, newprakulaDI);
                  }
              });
              let itr = groupedDataMap.values();
              let prakulaArray = [];
              let result = itr.next();
              while (!result.done) {
                  result.value.rowspan = result.value.deliveryInstructions.length + 1;
                  prakulaArray.push(result.value);
                  result = itr.next();
              }
          this.prakulalist = prakulaArray;
            }
        })
        .catch(error => {
            this.error = error;
            console.log('Error'+JSON.stringify(this.error));
        }) 
   }

    showHelpText() {
        this.showHelpText = true;
    }
    hideHelpText() {
        this.showHelpText = false;
    }
    handlePrakulaSelection(event){
        this.disabledBtn = false;
         this.prakulaId = event.target.value;
    }
    handleLVScreen(event){
       this.lvscreen = event.detail;
       this.lvpositionlst = event.lvpositionlst;
    }
   handleBack(){
        if (this.availableActions.find((action) => action === "BACK")) {
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
          }
    }

    handleCancel(){
        if(this.prakulaValue == null){
            if (this.availableActions.find((action) => action === "BACK")) {
                const navigateBackEvent = new FlowNavigationBackEvent();
                this.dispatchEvent(navigateBackEvent);
            }
        }
        if(this.lvpositionValue!= null && this.prakulaValue!= null){
            if (this.availableActions.find((action) => action === "BACK")) {
                const navigateBackEvent = new FlowNavigationBackEvent();
                this.dispatchEvent(navigateBackEvent);
            }
        }
        if(this.prakulaValue != null){
            this.lvscreen = true;
            this.dIscreen = false;
        }
        //window.history.back();
    }
    handleBackButton(){
        if(this.lvpositionValue!= null && this.prakulaValue!= null){
            if (this.availableActions.find((action) => action === "BACK")) {
                const navigateBackEvent = new FlowNavigationBackEvent();
                this.dispatchEvent(navigateBackEvent);
            }
        }
        if(this.prakulaValue == null){
            this.lvscreen = false;
            this.dIscreen = false;
        }
        if(this.prakulaValue != null){
            this.prakulalist = [];
            this.lvscreen = false;
            this.dIscreen = false;
        }
        
    }
    sendprakulaIds(){
        sendprakulaIds({ prakulaId : this.prakulaId , OLIID : this.OLIID})
        .then(result => {
            console.log(result);
            if(result){
                this.lvpositionlst = result;
            }
        })
        .catch(error => {
            this.error = error;
            console.log('Error'+JSON.stringify(this.error));
        }) 
   }
   handlePrakulaProceed(){
        if( this.prakulaId != null){
            this.lvscreen = true;
            this.sendprakulaIds();
        }else{
            
        }
        
    }
    handleNewPrakula() {
        this.selectedButtonId = this.buttonId;
        if(this.selectedButtonId === 'newPrakula'){
            if (this.availableActions.find(action => action === 'NEXT')) {
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            }
        }
    }
    handleLVSelection(event){
        this.lvpositionId = event.target.value;
    }
    handleLVScreenProceed(){
        if (this.availableActions.find(action => action === 'NEXT')) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }

    }
}