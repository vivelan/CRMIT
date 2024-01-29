/****************************************************************************
* Name: ProcessException
* Author: Harshitha U
* Test Class: ProcessExceptionHandlerTest
* Created Date: 22/08/2022
* Description: Trigger on Platform event(Exception Log) to create a exception record.
*****************************************************************************/
trigger ProcessException on ExceptionLog__e (after insert) {
    ProcessExceptionHandler processExcpHandler = new ProcessExceptionHandler();
    processExcpHandler.createException(trigger.new);
}