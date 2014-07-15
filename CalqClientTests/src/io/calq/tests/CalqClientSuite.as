package io.calq.tests
{
	import io.calq.tests.analytics.*;
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]  
	public class CalqClientSuite
	{
		public var analyticsActionApiCall:ActionApiCallTest;
		
		public var calqClient:CalqClientTest;
	}
}
