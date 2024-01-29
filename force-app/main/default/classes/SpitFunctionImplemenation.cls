global with sharing class SpitFunctionImplemenation implements Callable{
    
    public Object call(String action, Map<String, Object> args){
        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');
        
        return invokeMethod(action, input, output, options);
    }
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options){
        String recId;
        if(methodName == 'split'){
            List<object> arguments = (List<object>)inputs.get('arguments');
            output.put('result', split(arguments));
        }
        if(methodName == 'picklistLable'){
            If((JSON.serialize(inputs)).substring(2,10)=='argument'){
                recId=(JSON.serialize(inputs.get('arguments'))).substring(2,20); 
            }else{  
                recId=(String)inputs.get('recordId');
            }
            List<QUOTE> Ac = [SELECT ID, toLabel(Opportunity.DateOf_Payment__c) FROM QUOTE WHERE Id=:recId];
            output.put('result', Ac[0].Opportunity.DateOf_Payment__c);
        }
         if (methodName == 'dateConversion')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            output.put('result', replace(arguments));
        }
        
        return true;
    }
    
    Map<String, String> split(List<object> arguments){
        Map<String, String> result = new Map<String, String>();
        String toSplit = (String)arguments[0];
        String splitter = (String)arguments[1];
        List<String> splitList = toSplit.split(splitter);
        for(Integer i = 0 ; i < splitList.size(); i++){
            if(arguments.size() > i +2){
                result.put((String)arguments[i+2], splitList[i]);
            }else{
                result.put('Split'+i, splitList[i]);
            }
        }
        return result;
    }
    String replace(List<Object> arguments){
       String str = String.valueOf(arguments[0]);
        // Convert the month abbreviation to a standard format
        Map<String, String> monthAbbreviations = new Map<String, String>{
            'Jan' => '01', 'Feb' => '02', 'Mar' => '03', 'Apr' => '04',
            'May' => '05', 'Jun' => '06', 'Jul' => '07', 'Aug' => '08',
            'Sep' => '09', 'Oct' => '10', 'Nov' => '11', 'Dec' => '12'
        };

        String[] parts = str.split(' ');
        String formattedDateStr = parts[5] + '-' + monthAbbreviations.get(parts[1]) + '-' + parts[2] + ' ' + parts[3];

        // Parse the modified date string into a DateTime object
        DateTime parsedDateTime = DateTime.valueOfGmt(formattedDateStr);

        // Format the DateTime object into the desired output string
        String outputString = parsedDateTime.format('dd.MM.yyyy');
        return outputString;
    } 
}