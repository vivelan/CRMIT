import { LightningElement, api} from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import CancelAbbrechenSearch from '@salesforce/label/c.CancelAbbrechenSearch';
import SearchPrakulaPrakulasuchen from '@salesforce/label/c.SearchPrakulaPrakulasuchen';


export default class CancelButtonLwc extends LightningElement {
  label ={
    CancelAbbrechenSearch,
    SearchPrakulaPrakulasuchen
  }
    @api availableActions = [];
    handleSearch() {
      if (this.availableActions.find((action) => action === "NEXT")) {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
      }
    }
    handleCancel() {
      window.history.back();
    }
}