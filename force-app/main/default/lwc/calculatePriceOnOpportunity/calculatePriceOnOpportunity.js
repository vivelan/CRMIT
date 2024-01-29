import { LightningElement, api,wire, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getOLIRecord from '@salesforce/apex/CalculatePriceOnOpportunity.getOLIRecord';
import { CurrentPageReference } from 'lightning/navigation';
//import OLIRecordCreated from '@salesforce/label/c.Success_Message_OLI';
import OppCloseDateError from '@salesforce/label/c.OppCloseDateError';
import AppointedDayMissingError from '@salesforce/label/c.AppointedDayMissingError';
import PricePointNotAllowed from '@salesforce/label/c.PricePointNotAllowed';
import updateOLIProductFinderStatus from '@salesforce/apex/OLIProductfinder.updateOLIProductFinderStatus';
import upadateBulkCOP from '@salesforce/apex/PricingToolController.upadateBulkCOP';

export default class CalculatePriceOnOpportunity extends LightningElement {
   @api recordId;
   @track listofOLI;
   label = {
    OppCloseDateError,
    AppointedDayMissingError,
    PricePointNotAllowed
   };

   @wire(CurrentPageReference)
   getStateParameters(currentPageReference) {
     if (currentPageReference) {
         this.recordId = currentPageReference.state.recordId;
     }
   }

   connectedCallback(){
    getOLIRecord({ recordId: this.recordId})
    .then(result => {
         this.listofOLI = result;
         if(result)
         {
            this.updateproductfinderstatus();
         }
    })
    .catch(error => {
        this.error = error;
        console.log('Error'+JSON.stringify(this.error));
      }) 
   }
   updateproductfinderstatus(){
   updateOLIProductFinderStatus({ OLIRecordIDlst : this.listofOLI })
   .then(result => {  
       console.log('result in oli' + result);                 
      return upadateBulkCOP({ oppRecordIds: this.listofOLI });
   })
   .then(result => {
       if (result == 'true') {
           console.log('result in pricing' + result);
           this.dispatchEvent(new CloseActionScreenEvent());
           this.dispatchEvent(
               new ShowToastEvent({
                   title: 'Success',
                   message: 'Cost of Production has been updated',
                   variant: 'success'
               })
           );
       } else if (result == OppCloseDateError) {
           this.dispatchEvent(new CloseActionScreenEvent());
           this.dispatchEvent(
               new ShowToastEvent({
                   title: 'Error',
                   message: OppCloseDateError,
                   variant: 'error'
               })
           );
       } else if (result == AppointedDayMissingError) {
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: AppointedDayMissingError,
                variant: 'error'
            })
        );
    } else if (result == PricePointNotAllowed) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: PricePointNotAllowed,
                variant: 'error'
            })
        );
    }else {
           this.dispatchEvent(new CloseActionScreenEvent());
           this.dispatchEvent(
               new ShowToastEvent({
                   title: 'Error',
                   message: 'Getting Error',
                   variant: 'error'
               })
           );
       }
   })
   .catch(error => {
       this.error = error;
       console.error("error: ", JSON.stringify(this.error));
       this.dispatchEvent(new CloseActionScreenEvent());
       this.dispatchEvent(
           new ShowToastEvent({
               title: 'Error',
               message: 'Getting Error ' + JSON.stringify(this.error),
               variant: 'error'
           })
       );
   }) 
}
}