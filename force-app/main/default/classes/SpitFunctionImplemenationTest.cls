@isTest
public class SpitFunctionImplemenationTest {
    @isTest
    static void testSplitMethod() {
        SpitFunctionImplemenation splitter = new SpitFunctionImplemenation();
        // Test case 1
        List<Object> arguments1 = new List<Object>{'Hello,World', ','};
            Map<String, Object> input1 = new Map<String, Object>{'arguments' => arguments1};
                Map<String, Object> output1 = new Map<String, Object>();
        Map<String, Object> options1 = new Map<String, Object>();
        splitter.invokeMethod('split', input1, output1, options1);
        
        Map<String, String> expectedResult1 = new Map<String, String>{'Split0' => 'Hello', 'Split1' => 'World'};
        System.assertEquals(expectedResult1, (Map<String, String>)output1.get('result'), 'Split0 => Hello , Split1 => World');
        
        // Test case 2
        List<Object> arguments2 = new List<Object>{'Apple,Orange,Grapes', ','};
            Map<String, Object> input2 = new Map<String, Object>{'arguments' => arguments2};
                Map<String, Object> output2 = new Map<String, Object>();
        Map<String, Object> options2 = new Map<String, Object>();
        splitter.invokeMethod('split', input2, output2, options2);
        
        Map<String, String> expectedResult2 = new Map<String, String>{'Split0' => 'Apple', 'Split1' => 'Orange', 'Split2' => 'Grapes'};
        System.assertEquals(expectedResult2, (Map<String, String>)output2.get('result'),'Split0 => Apple , Split1 => Orange , Split2 => Grapes');
    }
    
    @isTest
    static void testCallMethod() {
        SpitFunctionImplemenation splitter = new SpitFunctionImplemenation();
        
        // Test case 1
        Map<String, Object> args1 = new Map<String, Object>{
            'input' => new Map<String, Object>{'arguments' => new List<Object>{'Hello,World', ','}},
                'output' => new Map<String, Object>(),
                'options' => new Map<String, Object>()
                };
                    Object result1 = splitter.call('split', args1);
        System.assertEquals(true, result1, 'result should be true');
        
        // Test case 2
        Map<String, Object> args2 = new Map<String, Object>{
            'input' => new Map<String, Object>{'arguments' => new List<Object>{'Apple,Orange,Grapes', ','}},
                'output' => new Map<String, Object>(),
                'options' => new Map<String, Object>()
                };
                    
                    Object result2 = splitter.call('split', args2);
        System.assertEquals(true, result2,'result should be true');
        
        // Test case 3
        Map<String, Object> args3 = new Map<String, Object>{
            'input' => new Map<String, Object>{'arguments' => new List<Object>{'Sat Dec 09 00:00:00 GMT 2023'}},
                'output' => new Map<String, Object>(),
                'options' => new Map<String, Object>()
                };
                    
                    Object result3 = splitter.call('dateConversion', args3);
        System.assertEquals(true, result3,'result should be true');
    }
}