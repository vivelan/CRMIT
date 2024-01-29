
import { LightningElement } from 'lwc';
import BusinessAreaproductgroupSalesPlanningLabel from '@salesforce/label/c.BusinessAreaproductgroupSalesPlanningLabel';
import AccountSalesPlanningTab from '@salesforce/label/c.AccountSalesPlanningTab';
export default class SalesForecastingLWC extends LightningElement {

    activetabContent = '';
  label = {
  BusinessAreaproductgroupSalesPlanningLabel,
  AccountSalesPlanningTab
}
    tabChangeHandler(event) {
       this.activetabContent  = event.target.value;
    }
   
    handleTabLabelChange(event) {
        event.target.closest('lightning-tab').label = event.detail.label
      }
      handleTabLabelChange1(event) {
        event.target.closest('lightning-tab').label = event.detail.label
      }



}