import { LightningElement,api,track,wire,} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ProductionKey from '@salesforce/label/c.ProductionKey';
import SaveButton from '@salesforce/label/c.SaveButton';
import ProductionKeyScreenSuccess from '@salesforce/label/c.ProductionKeyScreenSuccess';
import ProductionKeyScreenFail from '@salesforce/label/c.ProductionKeyScreenFail';
import SAGMarketingProfile from '@salesforce/label/c.SAGMarketingProfile';
import getPosition from '@salesforce/apex/ProductionKeyInput.getPosition';
import saveProductionKey from '@salesforce/apex/ProductionKeyInput.saveProductionKey';
import getProfile from '@salesforce/apex/ProductionKeyInput.getProfile';
import None from '@salesforce/label/c.None';
import ErrorForProductionKeyScreenOnSave from '@salesforce/label/c.ErrorForProductionKeyScreenOnSave';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import ErrormessageforsavingProductionKey from '@salesforce/label/c.ErrormessageforsavingProductionKey';

export default class ProductionKeyScreen extends LightningElement {

    label = {
        ProductionKey,
        SaveButton,
        None,
        SAGMarketingProfile,
        ErrorForProductionKeyScreenOnSave,
        ProductionKeyScreenSuccess,
        ProductionKeyScreenFail
    };
    
    error;
    //@api number;
    @api recordId;
    @track positions = [];
    @track positions1 = [];
    @track positions2 = [];
    @track requiredPositions = [];
    @track requiredPositions1 = [];
    @track disabled=true;
    @track isSave = false;
    @track isdisabled = false;
    @track isLoading = false;
    @track isValidProfile= false;
    @track fieldValues = [];
    @track successmsg = ProductionKeyScreenSuccess;
    @track errorMsgForInactiveFmn = ErrormessageforsavingProductionKey
    @track ErrorForProductionKeyScreenOnSave = ErrorForProductionKeyScreenOnSave;
    @track SAGMarketingProfile = SAGMarketingProfile;
    @track resForDefault = [];
    @track res;
    currentUserProfile;
    
    @wire(getRecord, { recordId: USER_ID , fields: [PROFILE_NAME_FIELD]}) 
    userDetails({error, data}) {
        if (data) {
            this.currentUserProfile = data.fields.Profile.value.fields.Name.value;
        } else if (error) {
            this.error = error ;
        }
    }
    connectedCallback(){
        this.getProfile();
        this.getPosition(); 
        if(this.currentUserProfile  == this.SAGMarketingProfile)
           this.isdisabled = true;
    }
    
    handleSelect(event){
        let obj = {};
        obj[event.target.name] = event.target.value;
        this.fieldValues.push(obj);
        if(this.fieldValues)
            this.disabled = false;
    }

    getProfile(){
        getProfile()
            .then(result => {
                this.isValidProfile = result;
            })
            .catch(error => {
                this.error = error;
                console.log('Error', this.error);
            }).finally(()=>{
            this.handleIsLoading(false);
        });
    }

    getPosition(){
        this.handleIsLoading(true);
        getPosition({ recordId: this.recordId })
            .then(result => {
                this.positions = result;
                for (let i = 0; i < this.positions.length; i++) {
                    if(this.positions[i].isRequired == true && (this.positions[i].valueToBeDefaulted == '' || this.positions[i].valueToBeDefaulted == undefined))
                      this.requiredPositions.push(this.positions[i].posLabel);
                    if(i<(this.positions.length/2)){                      
                        this.positions1.push(this.positions[i]);
                    }
                    else{
                        this.positions2.push(this.positions[i]);
                    }
                }
            })
            .catch(error => {
                this.error = error;
            }).finally(()=>{
            this.handleIsLoading(false);
        });
    }
    handleSaveValues(){
        var counter=0;
        this.fieldValues.forEach(fieldValue =>{
            for (var key in fieldValue) {  
                if (this.requiredPositions.includes(key) && fieldValue[key]!=null && fieldValue[key]!=''){
                    counter =counter+1;
                }
            }
            
        });
        
        if(this.requiredPositions.length == counter && this.fieldValues.length>=this.requiredPositions.length)
                { 
                    this.isSave= true;
                }
        if(this.isSave){
          this.handleIsLoading(true);
          saveProductionKey({ resultFromLWC:this.fieldValues , recordId: this.recordId })
            .then(result => {
                if(result == 'true'){ 
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: this.successmsg,
                        variant: 'Success'
                    });
                    this.dispatchEvent(evt);
                }
                else if(result == 'Inactive'){
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: this.errorMsgForInactiveFmn,
                        variant: 'Error'
                    });
                    this.dispatchEvent(evt);
                }
                else{
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
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Getting Error '+JSON.stringify(this.error),
                            variant: 'Error'
                        })
                    );
            }).finally(()=>{
            this.handleIsLoading(false);
        });
    }
     else{
        const evt = new ShowToastEvent({
            title: 'Error',
            message: ErrorForProductionKeyScreenOnSave,
            variant: 'Error'
        });
        this.dispatchEvent(evt);
        this.handleIsLoading(false);
      }
    }

    handleIsLoading(isLoading) {
        this.isLoading = isLoading;
    }
}