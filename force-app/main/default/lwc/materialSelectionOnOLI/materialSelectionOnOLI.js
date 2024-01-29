import { LightningElement , api , track } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import CancelAbbrechenSearch from '@salesforce/label/c.CancelAbbrechenSearch';
import BackZurack from '@salesforce/label/c.BackZurack';
import FinishedGoodsHeader from '@salesforce/label/c.FinishedGoodsHeader';
import FinishedGoodsScreen1HelpText from '@salesforce/label/c.FinishedGoodsScreen1HelpText';
import FinsihedGoodsScreen2HelpText from '@salesforce/label/c.FinsihedGoodsScreen2HelpText';
import FoundFinishedGoods from '@salesforce/label/c.FoundFinishedGoods';
import FinishedMaterialCriteria from '@salesforce/label/c.FinishedMaterialCriteria';
import getFinishedGoods from '@salesforce/apex/FinishedGoodsController.getFinishedGoods';
import SelectFinishedGoods from '@salesforce/label/c.SelectFinishedGoods';

export default class FinishedGoodsScreen extends LightningElement {
    @api SearchScreen = false;
    @api OLIID;
    @api FGName;
    @track FGList;
    @api FGProduct;
    @api FGSteelGrade;
    @api FGDimensionA;
    @api FGDimensionB;
    @track SelectionSreen = false;
    @track disabledBtn = true;
    @api selectedFG = 'false';
    @api FGId;
    label = {
        CancelAbbrechenSearch,
        BackZurack,
        FinishedGoodsHeader,
        FinishedGoodsScreen1HelpText,
        FinsihedGoodsScreen2HelpText,
        FinishedMaterialCriteria,
        FoundFinishedGoods,
        SelectFinishedGoods
    }
    FGSName = FinishedGoodsHeader.split(";")[0];
    FGSProduct = FinishedGoodsHeader.split(";")[1];
    FGSSteelGrade = FinishedGoodsHeader.split(";")[2];
    FGSDimensionA = FinishedGoodsHeader.split(";")[3];
    FGSDimensionB = FinishedGoodsHeader.split(";")[4];
    Select = FinishedGoodsHeader.split(";")[5];
    connectedCallback(){
        this.getFinishedGoods();
     }
     getFinishedGoods(){
        getFinishedGoods({ FGName : this.FGName, FGProduct : this.FGProduct, FGSteelGrade : this.FGSteelGrade, FGDimensionA : this.FGDimensionA, FGDimensionB : this.FGDimensionB, OLIID : this.OLIID })
        .then(data => {
            this.FGList = data;            
        })
        .catch(error => {
            this.error = error;
            console.log('Error'+JSON.stringify(this.error));
        }) 
   }
   @api availableActions = [];
   handleFinsihedGoodsSelection(event){
     this.disabledBtn = false;
     this.FGId = event.target.value;
   }
   handleFGSelectionID(){
    this.selectedFG = 'true';
    if (this.availableActions.find(action => action === 'NEXT')) {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
   }
   handleCancel(){
    this.SearchScreen = true;
    if (this.availableActions.find(action => action === 'BACK')) {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
   }
   handleBack(){
    this.SearchScreen = true;
    if (this.availableActions.find(action => action === 'BACK')) {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
   }

}