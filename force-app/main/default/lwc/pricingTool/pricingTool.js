import {LightningElement,api,track,wire } from 'lwc';
    import CostOfProduction from '@salesforce/label/c.CostOfProduction';
    import ProductName from '@salesforce/label/c.ProductName';
    import PriceLevel from '@salesforce/label/c.PriceLevel';
    
    import PriceLevel2CustomerProduct from '@salesforce/label/c.PriceLevel2CustomerProduct';
    import ERROR_PRICING_TOOL_DEACTIVATED from '@salesforce/label/c.Error_Pricing_Tool_Deactivated';
    import Euro from '@salesforce/label/c.Euro';
    import PriceLevel3Region from '@salesforce/label/c.PriceLevel3Region';
    import PriceLevel4Leveling from '@salesforce/label/c.PriceLevel4Leveling';
    import PriceLevel5CompetitiveEnvironment from '@salesforce/label/c.PriceLevel5CompetitiveEnvironment';
    import OrientationPrice from '@salesforce/label/c.OrientationPrice';
    import FinalPrice from '@salesforce/label/c.FinalPrice';
    import LastRefreshedDate from '@salesforce/label/c.LastRefreshedDate'; //#US-1073
    import LastSavedFinalPriceDate from '@salesforce/label/c.LastSavedFinalPriceDate'; //#US-1073
    import MarginLevel from '@salesforce/label/c.MarginLevel';
    import FinalMarginPrice from '@salesforce/label/c.FinalMarginPrice';
    import CalculatePrice from '@salesforce/label/c.CalculatePrice';
    import SaveFinalPrice from '@salesforce/label/c.SaveFinalPrice';
    import ReRunProductFinder from '@salesforce/label/c.ReRunProductFinder';
    import getOpportunityLineItem from '@salesforce/apex/PricingToolController.getOpportunityLineItem';
    import getMarginPriceDetails from '@salesforce/apex/PricingToolController.getMarginPriceDetails';
    import updateOLIProductFinderStatus from '@salesforce/apex/OLIProductfinder.updateOLIProductFinderStatus';
    import upadateBulkCOP from '@salesforce/apex/PricingToolController.upadateBulkCOP';
    import ReRunProductFindermethod from '@salesforce/apex/PricingToolController.ReRunProductFinder';
    import saveFinalPrice from '@salesforce/apex/PricingToolController.saveFinalPrice';
    import getPublicGroupUsers from '@salesforce/apex/PricingToolController.getPublicGroupUsers';
    import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    import { getRecord } from 'lightning/uiRecordApi';
    import USER_ID from '@salesforce/user/Id';
    import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
    import LOCALE from '@salesforce/i18n/locale';
    import AppointedDayError from '@salesforce/label/c.AppointedDayError';
    import AppointedDayMissingError from '@salesforce/label/c.AppointedDayMissingError';
    import OppCloseDateError from '@salesforce/label/c.OppCloseDateError';
    import PricePointNotAllowed from '@salesforce/label/c.PricePointNotAllowed';
    export default class PricingTool extends LightningElement {
        currentUserProfileId;
        currentUserProfileName;
        LastRefreshedDateVar;
        LastSavedFinalPriceDateVar;
        Oppstage;
        error;
        usePricingTool;

        
        label = {
            ERROR_PRICING_TOOL_DEACTIVATED,
            CostOfProduction,
            ProductName,
            PriceLevel,
            PriceLevel2CustomerProduct,
            PriceLevel3Region,
            PriceLevel4Leveling,
            PriceLevel5CompetitiveEnvironment,
            OrientationPrice,
            FinalPrice,
            LastRefreshedDate,
            LastSavedFinalPriceDate,
            MarginLevel,
            Euro,
            FinalMarginPrice,
            SaveFinalPrice,
            CalculatePrice,
            ReRunProductFinder,
            OppCloseDateError,
            AppointedDayMissingError,
            AppointedDayError,
            PricePointNotAllowed
        };
        @api recordId;
        //data = [];
        margindata = [];
        @track FinalPrice;
        @track styleforfirstdiv;
        @track isLoading = false;
        @track disabled=true;
        @track ismemberofGroup= false;
        @track Buttontrue=false;
        @track ButtonReRundisable = true;
        @track lastUpdateDate;
        connectedCallback(){
        this.getOpportunityLineItem();
        this.getMarginPriceDetails();
        getPublicGroupUsers()
                .then(result => {
                    if(result){
                    this.ismemberofGroup = result;
                    
                    }
                    else{
                        console.log('Error');
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.log('Error'+this.error);
                })
    }
    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD]}) 
    userDetails({error, data}) {
        if (data) {
            this.getOpportunityLineItem();
            console.log('Oppstage1==>',this.Oppstage);
            this.currentUserProfileName = data.fields.Profile.value.fields.Name.value; 
           if (this.currentUserProfileName != 'SAG Quality Profile'  ){
            this.ButtonReRundisable = false;
           }
          
        } else if (error) {
            this.error = error ;
        }
    } 
    getOpportunityLineItem(){
            this.handleIsLoading(true);
            getOpportunityLineItem({OLIRecordID : this.recordId})
                .then(result => {
                    this.data = result;
                    this.usePricingTool = result[0].usePricingTool;
                    this.FinalPrice = result[0].finalPrice;
                    this.Oppstage = result[0].stageName;
                    if (this.Oppstage == 'Closed lost after sending quote' || this.Oppstage == 'Closed lost before sending quote' || this.Oppstage == 'Closed' || this.Oppstage == 'Closed Won' ){
                        this.ButtonReRundisable = true;
                        console.log('ButtonReRundisable==>',this.ButtonReRundisable);
                       }
                    if(result[0].stageName == 'Negotiation' || result[0].stageName == 'Closed Won' || result[0].stageName == 'Closed Lost'){
                       this.Buttontrue=true;
                       console.log('Buttontrue==>',Buttontrue);
                    }
                                    })
                .catch(error => {
                    this.error = error;
                }).finally(()=>{
                this.handleIsLoading(false);
            });
    }
        getMarginPriceDetails(){
        console.log('this.recordId',this.recordId);
            this.handleIsLoading(true);
            getMarginPriceDetails({OLIRecordID : this.recordId})
                .then(result => {
                    this.margindata = result;
                                        this.LastRefreshedDateVar = this.margindata[0].LastRefreshedDate;
                    this.LastSavedFinalPriceDateVar = this.margindata[0].LastFinalPrice;
                })
                .catch(error => {
                    this.error = error;
                }).finally(()=>{
                this.handleIsLoading(false);
            });
    }
    //US# 191 Start Added by Naina
    handleCalculatePrice(){
            this.handleIsLoading(true);
            var listofOLI = [];
            var listofOLIids = [];
            listofOLI.push(this.recordId);
            updateOLIProductFinderStatus({ OLIRecordIDlst : listofOLI })
                .then(result => {
                    listofOLIids.push(result);
                    console.log('result in oli' + listofOLIids);
                   return upadateBulkCOP({ oppRecordIds: listofOLI });
                })
                .then(result => {
                    if (result == 'true') {
                        this.getOpportunityLineItem();
                        this.getMarginPriceDetails();
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Cost of Production has been updated',
                                variant: 'success'
                            })
                        );
                    } else if (result == OppCloseDateError) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: OppCloseDateError,
                                variant: 'error'
                            })
                        );
                    } else if (result == AppointedDayMissingError) {
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
                    }
                     else {
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
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Getting Error ' + JSON.stringify(this.error),
                            variant: 'error'
                        })
                    );
                })
                .finally(() => {
                    this.handleIsLoading(false);
                });    
    }
        //US# 413 Start Added by Gunjan Saxena
        handleReRunProductFinder(){
        console.log('this.lastupdated'+this.lastUpdateDate);
        this.handleIsLoading(true);
        ReRunProductFindermethod({ recordId: this.recordId})
        .then(result => { 
            console.log('result in rerun ',result);
            const olilst = result;
            if(olilst[0].Opportunity.AppointedDayCalculation__c < this.lastUpdateDate)
            {
                console.log('Test 1');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: AppointedDayError,
                        variant: 'Error'
                    })
                );
            }
            else if(olilst[0].Opportunity.AppointedDayCalculation__c == null)
            {
                console.log('Test 2');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: AppointedDayMissingError,
                        variant: 'Error'
                    })
                );
            }
            else
            {    var listofOLI = [];
                 var listofOLIids = [];
                 listofOLI.push(this.recordId);
                updateOLIProductFinderStatus({ OLIRecordIDlst : listofOLI })
                .then(result => {  
                    listofOLIids.push(result);
                    console.log('result in oli' + listofOLIids);                 
                   return upadateBulkCOP({ oppRecordIds: listofOLI });
                })
                .then(result => {
                    if (result == 'true') {
                        console.log('result in pricing' + result);
                        this.getOpportunityLineItem();
                        this.getMarginPriceDetails();
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Cost of Production has been updated',
                                variant: 'success'
                            })
                        );
                    } else if (result == OppCloseDateError) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: OppCloseDateError,
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
                    } else {
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
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Getting Error ' + JSON.stringify(this.error),
                            variant: 'error'
                        })
                    );
                })
                .finally(() => {
                    this.handleIsLoading(false);
                }); 
            }
        /*if(result == OppCloseDateError){
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: OppCloseDateError,
                    variant: 'Error'
                })
            );
        }*/

        }).catch(error => { 
            debugger;
            console.log('error',error);
            debugger;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Getting Error ',
                    variant: 'Error'
                })
            );
        }).finally(()=>{
            this.handleIsLoading(false);
        });
    }
    //show/hide spinner
    handleIsLoading(isLoading) {
            this.isLoading = isLoading;
    }
    
    //US# 191 End Added by Naina
    handleInputChange(event){
        this.FinalPrice = event.target.value;
        if(this.FinalPrice)
        this.disabled = false;
    }
    handleClickOnSave()
    {
        if(this.FinalPrice)
        { 
         saveFinalPrice({FinalPrice : this.FinalPrice,
                         RecordID : this.recordId})
            .then(result => {
                if(result){
                    this.FinalPrice = result;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Final Price Has Been Updated',
                                variant: 'Success',
                                mode : 'dismissible'
                            })
                        );
                   this.getMarginPriceDetails();
                   this.disabled = true;
                }
                else{
                    this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error Occured While Saving The Final Price',
                        variant: 'Error',
                        mode : 'dismissible'
                    })
                );
                }
            })
            .catch(error => {
                this.error = error;
                console.log('Error'+this.error);
            })
        }
            
    }
}