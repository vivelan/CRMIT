/****************************************************************************
* Name: StringToListUtil
* Author: Naina Butle
* Test Class: StringToListUtilTest
* Created Date: 12/11/2023
* Description: Convert String to List
*****************************************************************************/
public with sharing class StringToListUtil {
    @InvocableMethod(label='Convert String to List')
    public static List<List<String>> convertStringToList(List<String> inputParamStrings) { 
        
        List<List<String>> resultList = new List<List<String>>();
        
        for(String inputParamString : inputParamStrings){
            if(String.isBlank(inputParamString)) continue;
            
            List<String> innerResultList = new List<String>();
            if(inputParamString.Contains(';')){
                for(String str : inputParamString.split(';')){
                    if(String.isBlank(str)) continue;
                    innerResultList.add(str.trim());
                }
                resultList.add(new List<String>(innerResultList));
            }else if(inputParamString.Contains(',')){
                for(String str : inputParamString.split(',')){
                    if(String.isBlank(str)) continue;
                    innerResultList.add(str.trim());
                }
                resultList.add(new List<String>(innerResultList));
            }else{
                innerResultList.add(inputParamString);
                resultList.add(new List<String>(innerResultList));
            }
        }
        return resultList;
    }
}