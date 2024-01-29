@isTest
public class GetOrgBaseUrl_Test {
    
    @testSetup
    static void setup() {
        
        // Create a test account
    Account a = new Account(Name='Test Account');
        insert a;    
        }
    
    @isTest
    static void stripHtmlTags() {
        
        // Access the opportunity that was just created.
        Account account = [SELECT Id, Name FROM Account LIMIT 1];
		List<GetOrgBaseUrl.Results> resultList = GetOrgBaseUrl.getBaseUrl(new List<sObject> {account});
        System.assertEquals(resultList.size(), 1, 'Incorrect output');
    }
}