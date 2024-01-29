/****************************************************************************
* Name: TriggerHandlerTest
* Author: Priyanka Kumari
* Created Date: 19/08/2022
* Description: Test class for TriggerHandler class
*****************************************************************************
* Modification log
* Name		Date	           		Description
* Developer Name	Date of Modification	Modification Description  
****************************************************************************/
@isTest
private class TriggerHandlerTest {

  private static final String TRIGGER_CONTEXT_ERROR = 'Trigger handler called outside of Trigger execution';
  private static String lastMethodCalled;
  private static String objectName; 
  private static integer maxCount;
  private static TriggerHandlerTest.TestHandler handler;
  static {
    handler = new TriggerHandlerTest.TestHandler();
    handler.isTriggerExecuting = true;
    objectName = 'Account';
    maxCount = 1;
  }
 	
  /***************************************
   * unit tests
   ***************************************/
  @isTest
  static void testBeforeInsert() {
    beforeInsertMode();
    handler.run(objectName);
    System.assertEquals('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
  }

  @isTest
  static void testBeforeUpdate() {
    beforeUpdateMode();
    handler.run(objectName);
    System.assertEquals('beforeUpdate', lastMethodCalled, 'last method should be beforeUpdate');
  }

  @isTest
  static void testBeforeDelete() {
    beforeDeleteMode();
    handler.run(objectName);
    System.assertEquals('beforeDelete', lastMethodCalled, 'last method should be beforeDelete');
  }

  @isTest
  static void testAfterInsert() {
    afterInsertMode();
    handler.run(objectName);
    System.assertEquals('afterInsert', lastMethodCalled, 'last method should be afterInsert');
  }

  @isTest
  static void testAfterUpdate() {
    afterUpdateMode();
    handler.run(objectName);
    System.assertEquals('afterUpdate', lastMethodCalled, 'last method should be afterUpdate');
  }

  @isTest
  static void testAfterDelete() {
    afterDeleteMode();
    handler.run(objectName);
    System.assertEquals(null, lastMethodCalled, 'last method should be null');
  }

  @isTest
  static void testAfterUndelete() {
    afterUndeleteMode();
    handler.run(objectName);
    System.assertEquals(null, lastMethodCalled, 'last method should be null');
  }

  @isTest 
  static void testNonTriggerContext() {
    try{
      handler.run(objectName);
      System.assert(false, 'the handler ran but should have thrown');
    } catch(TriggerHandler.TriggerHandlerException te) {
      System.assertEquals(TRIGGER_CONTEXT_ERROR, te.getMessage(), 'the exception message should match');
    } catch(Exception e) {
      System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
    }
  }

  @isTest
  static void testLoopCount() {
  	beforeInsertMode();
    handler.setMaxLoopCount(maxCount,objectName);
	handler.run(objectName);
    resetTest();
	try {
      handler.run(objectName);
    } catch(TriggerHandler.TriggerHandlerException te) {
      System.assertEquals(null, lastMethodCalled, 'last method should be null');
    } catch(Exception e) {  
      System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
    }
	resetTest();
	}

  @isTest
  static void testLoopCountClass() {
    TriggerHandler.LoopCount lc = new TriggerHandler.LoopCount();
    System.assertEquals(5, lc.getMax(), 'max should be one on init');
    System.assertEquals(0, lc.getCount(), 'count should be zero on init');

    lc.increment();
    System.assertEquals(1, lc.getCount(), 'count should be 1');
    System.assertEquals(false, lc.exceeded(), 'should not be exceeded with count of 1');

    lc.increment();
    lc.increment();
    lc.increment();
    lc.increment();
    System.assertEquals(5, lc.getCount(), 'count should be 5');
    System.assertEquals(false, lc.exceeded(), 'should not be exceeded with count of 5');

    lc.increment();
    System.assertEquals(6, lc.getCount(), 'count should be 6');
    System.assertEquals(true, lc.exceeded(), 'should not be exceeded with count of 6');
  }
  /***************************************
   * testing utilities
   ***************************************/

  private static void resetTest() {
    lastMethodCalled = null;
  }
    
  private static void beforeInsertMode() {
    handler.setTriggerContext('before insert', true);
  }

  private static void beforeUpdateMode() {
    handler.setTriggerContext('before update', true);
  }

  private static void beforeDeleteMode() {
    handler.setTriggerContext('before delete', true);
  }

  private static void afterInsertMode() {
    handler.setTriggerContext('after insert', true);
  }

  private static void afterUpdateMode() {
    handler.setTriggerContext('after update', true);
  }

  private static void afterDeleteMode() {
    handler.setTriggerContext('after delete', true);
  }

  private static void afterUndeleteMode() {
    handler.setTriggerContext('after undelete', true);
  }

  private class TestHandler extends TriggerHandler {

    public override void beforeInsert() {
      TriggerHandlerTest.lastMethodCalled = 'beforeInsert';
    }

    public override void  beforeUpdate() {
      TriggerHandlerTest.lastMethodCalled = 'beforeUpdate';
    }

    public override void beforeDelete() {
      TriggerHandlerTest.lastMethodCalled = 'beforeDelete';
    }

    public override void afterInsert() {
      TriggerHandlerTest.lastMethodCalled = 'afterInsert';
    }

    public override void afterUpdate() {
      TriggerHandlerTest.lastMethodCalled = 'afterUpdate';
    }

    public override void afterDelete() {
      TriggerHandlerTest.lastMethodCalled = 'afterDelete';
    }

    public override void afterUndelete() {
      TriggerHandlerTest.lastMethodCalled = 'afterUndelete';
    }
  }	
}
