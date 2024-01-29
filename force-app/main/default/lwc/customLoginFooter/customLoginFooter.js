import { LightningElement, track } from 'lwc';
import DH_LOGO from "@salesforce/contentAssetUrl/DHlogo";
import ContactDHLabel from '@salesforce/label/c.ContactDHLabel';
import CustomLoginFooter1 from '@salesforce/label/c.CustomLoginFooter1';
import CustomLoginFooter2 from '@salesforce/label/c.CustomLoginFooter2';
import CustomLoginFooter3 from '@salesforce/label/c.CustomLoginFooter3';
import CustomLoginFooter4 from '@salesforce/label/c.CustomLoginFooter4';
import CustomLoginFooter5 from '@salesforce/label/c.CustomLoginFooter5';
import CustomLoginFooter6 from '@salesforce/label/c.CustomLoginFooter6';
import CustomLoginFooter7 from '@salesforce/label/c.CustomLoginFooter7';
import Address1 from '@salesforce/label/c.Address1';
import Address2 from '@salesforce/label/c.Address2';
import Address3 from '@salesforce/label/c.Address3';
import Address4 from '@salesforce/label/c.Address4';
import Address5 from '@salesforce/label/c.Address5';
import Address6 from '@salesforce/label/c.Address6';
import Address7 from '@salesforce/label/c.Address7';
import customWebLink1 from '@salesforce/label/c.customWebLink1';
export default class CustomLoginFooter extends LightningElement {
    label = {
        ContactDHLabel,
        CustomLoginFooter1,
        CustomLoginFooter2,
        CustomLoginFooter3,
        CustomLoginFooter4,
        CustomLoginFooter5,
        CustomLoginFooter6,
        CustomLoginFooter7,
        Address1,
        Address2,
        Address3,
        Address4,
        Address5,
        Address6,
        Address7,
        customWebLink1

    }
    @track DHLogoUrl = DH_LOGO; // Replace with actual data retrieval logic
    customLink1 = customWebLink1.split(';')[0];
    customLink2 = customWebLink1.split(';')[1];
    customLink3 = customWebLink1.split(';')[2];
    
}