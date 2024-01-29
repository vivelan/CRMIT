/****************************************************************************
* Name: ScheduleUsernameUpdate
* Author: Naina B
* Created Date: 22/12/2023
* Description: The automation needs to be a scheduled class (in every 5 minutes) and collects such portal users from SF, where the username mismatches. 
*****************************************************************************
* Modification log
* Name      Date                    Description
* Developer Name    Date of Modification    Modification Description  
****************************************************************************/
global with sharing class ScheduleUsernameUpdate implements Schedulable {
    private final String JOB_NAME = 'ScheduleUsernameUpdate';
    private final Integer DURATION = 5;
    
    public void execute(SchedulableContext cont)
    {
        new RepeatingSchedulerDHUserUpdate().updateUserName();
        findAndAbortJob(cont);
    }
    
    private void findAndAbortJob(SchedulableContext cont)
    {
        if (cont == null)
        {
            return;
        }
        
        //Need to query CronJobDetail to find our currently active scheduled job
        List<CronJobDetail> cronDetail = [SELECT Id FROM CronJobDetail WHERE Name= :JOB_NAME LIMIT 1];
        
        if (cronDetail.isEmpty())
        {
            return;
        }
        
        //Need to find the corresponding cron trigger to be able to abort the scheduled job
        List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE CronJobDetailId = :cronDetail[0].Id];
        
        if(cronTriggers.isEmpty())
        {
            return;
        }
        
        try
        {
            //Aborts the job current setup for this scheduled class
            System.abortJob(cronTriggers[0].Id);
            rescheduleJob();
        }
        catch (Exception e)
        {
            String exdetails = e.getCause() + ' ; '+ e.getLineNumber() + ' ; ' + e.getMessage() + ' ; ' + e.getStackTraceString()
                + ' ; ' + e.getTypeName() ;
            ExceptionUtilClass.logException(ConstantClass.USER_OBJECT, ConstantClass.SCHEDULEUSERNAMECLASS, '', exdetails, ConstantClass.APEX_CLASS);
        }
    }
    
    private void rescheduleJob()
    {
        Datetime sysTime = System.now().addMinutes(DURATION);
        String cronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule(JOB_NAME, cronExpression, new ScheduleUsernameUpdate());
    }
    
}