package io.calq.tests.analytics
{
	import io.calq.analytics.ActionApiCall;
	import io.calq.ReservedApiProperties;
	
	import org.flexunit.Assert;
	
	public class ActionApiCallTest
	{
		protected var apiCall:ActionApiCall;
		
		protected var actor:String;
		protected var action:String;
		protected var properties:Object;
		protected var writeKey:String;

		
		[Before]
		public function setUp() : void 
		{  
			actor = "TestActor";
			action = "TestAction";
			writeKey = "dummykey_00000000000000000000000";
			properties = { 'Test Property' : 'Test Value' };
			
			apiCall = new ActionApiCall(actor, action, properties, writeKey);
		}  
		
		[After] 
		public function tearDown() : void
		{  
			
		}
		
		/**
		 * Tests that the end point for action calls is set.
		 */
		[Test] 
		public function testHasEnpoint() : void
		{
			Assert.assertNotNull("apiEndpoint was null", apiCall.apiEndpoint);
		}
		
		/**
		 * Tests that the api has a payload.
		 */
		[Test] 
		public function testHasPayload() : void
		{
			Assert.assertNotNull("payload was null", apiCall.payload);
		}
		
		/**
		 * Tests that the data in matches the data out.
		 */
		[Test] 
		public function testPayloadMatchesInput() : void
		{	
			var decoded:Object = JSON.parse(apiCall.payload);
			Assert.assertNotNull("Unable to decode JSON payload", decoded);
			
			Assert.assertEquals("Payload did not match input for actor", decoded[ReservedApiProperties.ACTOR], actor);
			Assert.assertEquals("Payload did not match input for action", decoded[ReservedApiProperties.ACTION_NAME], action);
			Assert.assertEquals("Payload did not match input for writeKey", decoded[ReservedApiProperties.WRITE_KEY], writeKey);
			
			Assert.assertNotNull("Payload had missing properties node", decoded[ReservedApiProperties.USER_PROPERTIES]);
			Assert.assertEquals("Payload properties did not match input", decoded[ReservedApiProperties.USER_PROPERTIES]['Test Property'], 'Test Value');
		}
		
		/**
		 * Tests that if we have an empty properites object we get an empty object in JSON ({})
		 */
		[Test] 
		public function testEmptyPropertiesNodeNotNull() : void
		{
			apiCall = new ActionApiCall(actor, action, {}, writeKey);
			Assert.assertTrue("Unable to find empty node", apiCall.payload.indexOf("\"" + ReservedApiProperties.USER_PROPERTIES + "\":{}") > 0);			
		}
	}
}