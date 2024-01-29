/****************************************************************************
* Name: FinishedGoodsController
* Author: Harshitha Udaykumar
* Created Date: 17/01/2023
* Description: Controller class for Material Search on OLI.
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
****************************************************************************/
public with sharing class FinishedGoodsController {
/****************************************************************************
* Author Name: Harshitha Udaykumar
* Description: to Fecth the list of FG records based on the search criteria entered in UI.
* Created Date: 17/01/2023
* Last Modified Date: 
****************************************************************************/
    @AuraEnabled
    public static List<FinishedGoods__c> getFinishedGoods(String FGName, String FGProduct, String FGSteelGrade, Integer FGDimensionA, Integer FGDimensionB, String OLIID){
        List<FinishedGoods__c > FinsihedGoodslst = new List<FinishedGoods__c >();
        String query ;
        if(FGName != null || FGProduct != null || FGSteelGrade != null || FGDimensionA != null || FGDimensionB != null ){
            query = 'SELECT Name, Product__c, SteelGradeLookup__c, Product__r.Name, SteelGradeLookup__r.Name, DimensionA__c, DimensionB__c from FinishedGoods__c WHERE ';
        }
        if (FGName != null) {
            query += 'Name  = :FGName AND ';
        }
        
        if (FGProduct != null) {
            query += 'Product__c   = :FGProduct AND ';
        }
        
        if (FGSteelGrade != null) {
            query += 'SteelGradeLookup__c   = :FGSteelGrade AND ';
        }
        
        if (FGDimensionA != null) {
            query += 'DimensionA__c   = :FGDimensionA AND ';
        }
        
        if (FGDimensionB != null) {
            query += 'DimensionB__c   = :FGDimensionB';
        }
        if(query != null){
            if (query.endsWith('AND ')) {     
                query = query.substring(0, query.length() - 4); 
            }
            String strEsc = String.escapeSingleQuotes(query); 
            FinsihedGoodslst = Database.query(strEsc);
        }
        return FinsihedGoodslst;
    }

}