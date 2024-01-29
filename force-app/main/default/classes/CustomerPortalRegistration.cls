/****************************************************************************
* Name: CustomerPortalRegistration
* Author: Priyanka Kumari
* Created Date: 05/09/2023
* Description: Apex class invoved by a screen flow to send a confirmation 
  email to the users who registers on DH customer portal
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
****************************************************************************/
public without sharing class CustomerPortalRegistration {
    
    @InvocableMethod(label = 'Customer Portal Registration Email'
        description = 'Send a confirmation email to the users who registers on DH customer portal')
    public static List<String> sendEmail(List<String> recordId){
        List<String> result = new List<String>();
        List<Case> cases = new List<Case>();
        cases.add([SELECT Id, CaseNumber, SuppliedEmail, SuppliedName, SuppliedLastName__c, SuppliedCompany, SuppliedCustomerNumber__c,
                   SuppliedStreet__c, SuppliedZipCode__c, SuppliedCity__c, DillingerSalesDepartment__c, SuppliedOrderNo__c
                   FROM Case WHERE Id =: recordId LIMIT 1]);
        
        String emailBody = System.Label.RegistrationEmailBody +'<br/><br/>';
        emailBody += System.Label.FirstName+ ': ' +cases[0].SuppliedName + '<br/>';
        emailBody += System.Label.LastName+ ': ' +cases[0].SuppliedLastName__c + '<br/>';
        emailBody += System.Label.EMail+ ': ' +cases[0].SuppliedEmail + '<br/>';
        emailBody += System.Label.Nameofyourcompany+ ': ' +cases[0].SuppliedCompany + '<br/>';
        emailBody += System.Label.CustomerNo+ ': ' +cases[0].SuppliedCustomerNumber__c + '<br/>';
        emailBody += System.Label.Street+ ': ' +cases[0].SuppliedStreet__c + '<br/>';
        emailBody += System.Label.Zipcode+ ': ' +cases[0].SuppliedZipCode__c + '<br/>';
        emailBody += System.Label.City+ ': ' +cases[0].SuppliedCity__c + '<br/>';
        emailBody += System.Label.Dillingersalesdepartment+ ': ' +cases[0].DillingerSalesDepartment__c + '<br/>';
        emailBody += System.Label.OrderNo+ ': ' +cases[0].SuppliedOrderNo__c + '<br/>';
        emailBody += '<br/><br/>' + System.Label.RegistrationEmailRegards + '<br/>';
	 	
        List<OrgWideEmailAddress> owea= [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='no-reply@crm.stahl-holding-saar.de'];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if (owea != null) {
            email.setOrgWideEmailAddressId(owea[0].id);
        }
        email.setToAddresses(new String[] {cases[0].SuppliedEmail});
        email.setSubject(System.Label.RegistrationEmailSubject);
        email.setHtmlBody(emailBody);
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        emailList.add(email);
        Messaging.SendEmailResult[] sendResult = Messaging.sendEmail(emailList);
        if (sendResult[0].isSuccess()) {
            result.add('true');            
        } else {
            result.add('false');
        }
        return result;
    }
}
