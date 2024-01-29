import { LightningElement, api} from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import SearchFinishedGoods from '@salesforce/label/c.SearchFinishedGoods';


export default class CancelButtonLwc extends LightningElement {
  label ={
    SearchFinishedGoods
  }
    @api availableActions = [];
    handleSearch() {
      if (this.availableActions.find((action) => action === "NEXT")) {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
      }
    }
}