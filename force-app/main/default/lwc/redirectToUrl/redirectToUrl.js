import { LightningElement } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import CLOSE from '@salesforce/label/c.Close';


export default class RedirectToUrl extends NavigationMixin(LightningElement){
    
    label ={
        CLOSE
      }
      handleClose() {
       
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'login'
            }
        });
      }
            
} 
