package io.calq.tests
{
	import io.calq.CalqClient;
	import io.calq.util.GUID;
	
	import org.flexunit.Assert;

	public class CalqClientTest
	{
		protected var writeKey:String;

		[Before]
		public function setUp() : void 
		{  
			writeKey = "55ebeaebfcd351e0b69e6cc99dbb081d";
		}  
		
		[After] 
		public function tearDown() : void
		{  
			
		}
		
		/**
		 * Tests creating CalqClient instances and that the singleton is populated correctly.
		 */
		[Test] 
		public function testClientSharedInstance() : void
		{
			var calq:CalqClient = new CalqClient(writeKey);
			
			Assert.assertNotNull("Shared instance did not match local", CalqClient.getInstance());
		}

		/**
		 * Tests that identify is updating the instance.
		 */
		[Test] 
		public function testIdentifyUpdatesInstance() : void
		{
			var identity:String = (new GUID()).toString();
			
			var calq:CalqClient = new CalqClient(writeKey);
			calq.identify(identity);
			
			Assert.assertEquals("Actor was not updated after calling identity", identity, calq.actor);
		}
		
		/**
		 * Tests that calling identify twice doesn't update the 2nd time
		 */
		[Test]
		public function testIdentifyFailsOnMultipleCalls() : void
		{
			var calq:CalqClient = new CalqClient(writeKey, { 'ignoreState' : true });
			
			var identity:String = (new GUID()).toString();
			calq.identify(identity);
			
			var again:String = (new GUID()).toString();
			calq.identify(again);
			
			Assert.assertEquals("Actor was same after calling identity twice", identity, calq.actor);
		}
		
		/**
		 * Tests that state is saved and loaded between different instances.
		 */
		[Test]
		public function testStatePersistence() : void
		{
			var first:CalqClient = new CalqClient(writeKey, { 'ignoreState' : true });
			first.identify((new GUID()).toString());
			
			var second:CalqClient = new CalqClient(writeKey);
			
			Assert.assertFalse("CalqClient instances were the same", first == second);
			
			Assert.assertEquals("Actors were not the same between saved sessions", first.actor, second.actor);
		}
		
		/**
		 * Does a full test from raising an event and sending it to Calq. This test requires a valid
		 * Calq writeKey or it will not be able to send data.
		 */
		[Test]
		public function testEndToEndApiCalls() : void
		{
			var calq:CalqClient = new CalqClient(writeKey, { 'ignoreState' : true });
			
			calq.track("AS3 Test Action (Anon)");
			
			calq.identify((new GUID()).toString());
			
			calq.track("AS3 Test Action", { 'Test Value' : 'Test Property' });
			
			calq.trackSale("AS3 Test Sale", null, "USD", 9.99);
			
			calq.profile({ '$email' : "test@notarealemail.com", '$full_name' : calq.actor });
		}
	}
}