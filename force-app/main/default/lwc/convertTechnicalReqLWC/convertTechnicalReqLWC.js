import { LightningElement, api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import createOLIRecord from '@salesforce/apex/ConvertTechnicalReqController.createOLIRecord';
import { CurrentPageReference } from 'lightning/navigation';
import OLIRecordCreated from '@salesforce/label/c.Success_Message_OLI';

export default class ConvertTechnicalReqLWC extends LightningElement {
   @api recordId;
  
  @wire(CurrentPageReference)
 getStateParameters(currentPageReference) {
     if (currentPageReference) {
         this.recordId = currentPageReference.state.recordId;
     }
 }

   connectedCallback(){
        createOLIRecord({ recordId: this.recordId})
    .then(result => {
        if(result == OLIRecordCreated){
            this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: OLIRecordCreated,
                    variant: 'Success'
                })
            );
            this.updateRecordView(); //US-2755 Start
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
    })
    .catch(error => {
        this.error = error;
        console.log('Error'+JSON.stringify(this.error));
      }) 
   }

   //US-2755 Start
   updateRecordView() {
    setTimeout(() => {
         eval("$A.get('e.force:refreshView').fire();");
    }, 500); 
 }
  //US-2755 end
}