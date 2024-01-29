/****************************************************************************
* Name: StringToListUtilTest
* Author:Naina Butle
* Created Date: 12/11/2023
* Description: Test class for StringToListUtil class.
*****************************************************************************/
@isTest
public with sharing class StringToListUtilTest {
    @isTest
    public static void testConvertStringToListUtilMethod() {
        String str = 'abc@gmail.com; bcd@gmail.com';
        List<List<String>> res = StringToListUtil.convertStringToList(new List<String>{str});
        system.assertNotEquals(res.size(), 0,'List should not be empty');
    }
    
    @isTest
    public static void testConvertStringToListUtilMethod1() {
        String str = 'abc@gmail.com';
        List<List<String>> res = StringToListUtil.convertStringToList(new List<String>{str});
        system.assertNotEquals(res.size(), 0,'List should not be empty');
    }
    
    @isTest
    public static void testConvertStringToListUtilMethod2() {
        String str = 'abc@gmail.com, bcd@gmail.com';
        List<List<String>> res = StringToListUtil.convertStringToList(new List<String>{str});
        system.assertNotEquals(res.size(), 0,'List should not be empty');
    }
}