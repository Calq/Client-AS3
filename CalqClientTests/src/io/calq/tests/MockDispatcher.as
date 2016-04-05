package io.calq.tests
{
	import io.calq.analytics.AbstractAnalyticsApiCall;
	import io.calq.analytics.ApiDispatcher;
	
	/**
	 * Mock dispatcher we use to actually not dispatch API calls for the tests when needed.
	 */
	public class MockDispatcher extends ApiDispatcher
	{
		/**
		 * API calls which have been dispatched.
		 */
		protected var _dispatched:Vector.<AbstractAnalyticsApiCall>;		
		
		public function MockDispatcher()
		{
			super();
			
			_dispatched = new Vector.<AbstractAnalyticsApiCall>();
		}
		
		/**
		 * Dispatches the given API call and processes the result.
		 */
		protected override function dispatch(apiCall:AbstractAnalyticsApiCall) : void
		{
			// Just mark this call as having been dispatched
			_dispatched.push(apiCall);
			
			// Normally called via success, but we don't really make the call
			dispatchNext();
		}
		
		/**
		 * Gets the api calls dispatched by this instance.
		 */
		public function get dispatched() : Vector.<AbstractAnalyticsApiCall> { return _dispatched; }
	}
}