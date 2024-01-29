/****************************************************************************
* Name: PWResetForClientFlowController
* Author: Naina Butle
* Created Date: 04/10/2023
* Description: Controller class for DH | Session set up / PW reset for client portal users flow
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
****************************************************************************/
public with Sharing class PWResetForClientFlowController {
    @InvocableMethod(label='Send rest Password mail' description='Returns the list of account' category='User')
    public static void sendRestMail(List<ID> ids) {
        for(Id userId : ids){
           System.resetPassword(userId, true);  
        }
    }
}