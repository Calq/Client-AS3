package io.calq.analytics
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.Timer;

	public class ApiDispatcher
	{
		/**
		 * Queue of API calls to make (in case signal is lost).
		 */
		protected var _queue:Vector.<AbstractAnalyticsApiCall>;
		
		/**
		 * The API call currently being dispatched.
		 */
		protected var activeCall:AbstractAnalyticsApiCall;
		
		/**
		 * Timer for attempting retries on API failures.
		 */
		protected var retryTimer:Timer;
		
		/**
		 * API server to call.
		 */
		protected static const API_ROOT:String = "http://api.calq.io/";
		
		public function ApiDispatcher()
		{
			_queue = new Vector.<AbstractAnalyticsApiCall>();
			
			retryTimer = new Timer(60 * 1000, 1);	// Retry after 60s
			retryTimer.addEventListener(TimerEvent.TIMER, onRetryTimer);
		}
		
		/**
		 * Adds the given API call to the dispatcher. Will be sent to Calq's API servers ASAP.
		 * If there is currento no signal (mobile) then the action will be retried.
		 */
		public function enqueue(apiCall:AbstractAnalyticsApiCall) : void
		{
			_queue.push(apiCall);
			
			dispatchNext();
		}
		
		/**
		 * Dispatches the next API call in the queue (unless empty, or one in progress).
		 */
		protected function dispatchNext() : void
		{
			if(activeCall == null && _queue.length > 0)
			{
				activeCall = _queue.shift();
				dispatch(activeCall);
			}
		}
		
		/**
		 * Dispatches the given API call and processes the result.
		 */
		protected function dispatch(apiCall:AbstractAnalyticsApiCall) : void
		{
			var request:URLRequest = new URLRequest(apiRoot + apiCall.apiEndpoint);
			request.method = URLRequestMethod.POST;
			request.requestHeaders.push(new URLRequestHeader("Content-Type", "application/json"));
			request.data = apiCall.payload;
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			
			loader.addEventListener(Event.COMPLETE, onApiCallComplete);
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onHttpStatus);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onApiCallIoError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onApiCallSecurityError);
			
			loader.load(request);
		}
		
		/**
		 * Handles when an API call has been made successfully.
		 */
		protected function onApiCallComplete(e:Event) : void
		{
			// Check wasn't handled by status
			if(activeCall != null)
			{
				var loader:URLLoader = URLLoader(e.target);
				if(loader.data != null && loader.data.hasOwnProperty("error"))
				{
					// API error - can't retry this
					trace("[CalqClient] API error occured. API call will be skipped.", loader.data.error);
				}
				
				// Either way continue onwards
				activeCall = null;
				dispatchNext();
			}
		}
		
		/**
		 * Handles when we know the HTTP status of an api call we made.
		 */
		protected function onHttpStatus(e:HTTPStatusEvent) : void
		{
			if(e.status == 500)
			{
				// Internal server error. Can be replayed later
				onApiCallIoError(null);
			}
			// Other states are handled by reading their content
		}
		
		/**
		 * Handles when an API call has failed due to an IO error.
		 */
		protected function onApiCallIoError(e:IOErrorEvent) : void
		{
			trace("[CalqClient] IO error during API call. The call will be retried.", e);
			
			// Need to put back on queue so it can be retried
			_queue.unshift(activeCall);
			activeCall = null;
			// IO Error. Retry the call again later
			retryTimer.reset();
			retryTimer.start();
		}
		
		/**
		 * Handles when an API call has failed due to a security error.
		 */
		protected function onApiCallSecurityError(e:SecurityErrorEvent) : void
		{
			// Can't retry these
			trace("[CalqClient] Security error during API call. The API call has been skipped.", e);
			// Might still be more
			activeCall = null;
			dispatchNext();
		}
		
		/**
		 * Handles when it is time to retry the dispatch queue after a failure.
		 */
		protected function onRetryTimer(e:TimerEvent) : void
		{
			dispatchNext();
		}
		
		/**
		 * Base url for API server. Guaranteed to end with a "/"
		 */
		protected function get apiRoot() : String
		{
			return API_ROOT.charAt(API_ROOT.length - 1) == "/" ? API_ROOT : API_ROOT + "/";
		}
	}
}