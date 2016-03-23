/*
*  Copyright 2014 Calq.io
*
*  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in 
*  compliance with the License. You may obtain a copy of the License at
*
*   http://www.apache.org/licenses/LICENSE-2.0
*
*  Unless required by applicable law or agreed to in writing, software distributed under the License is 
*  distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
*  implied. See the License for the specific language governing permissions and limitations under the 
*  License.
*  
*/

package io.calq.analytics
{
	import io.calq.ReservedApiProperties;
	
	public class AbstractAnalyticsApiCall
	{
		/**
		 * The write key to use for this API call.
		 */
		protected var _writeKey:String;
		
		/**
		 * The unique Id of the actor referenced by this API call.
		 */
		protected var _actor:String;
		
		/**
		 * @param actor			The actor referenced by this API call.
		 * @param writeKey		The write key to use for this API call.
		 */
		public function AbstractAnalyticsApiCall(actor:String, writeKey:String)
		{
			_actor = actor;
			_writeKey = writeKey;
		}
		
		/**
		 * Gets the name of the API endpoint that should be called (such as Track).
		 * @return the name of the endpoint to call.
		 */
		public function get apiEndpoint() : String
		{
			// Abstract
			throw(new Error("apiEndpoint() must be overidden by child classes"));
		}
		
		/**
		 * Builds a JSON payload describing this API call. This is what will ultimately be passed
		 * to the API server for this call.
		 * 
		 * @return a JSON payload to pass to the API server.
		 */
		protected function buildJSONPayload() : Object
		{
			var jsonObject:Object = new Object();
			jsonObject[ReservedApiProperties.ACTOR] = _actor;
			jsonObject[ReservedApiProperties.WRITE_KEY] = _writeKey;
			return jsonObject;
		}
		
		/**
		 * Returns a JSON payload in string form to be sent to the API server for this call.
		 */
		public function get payload() : String 
		{
			return JSON.stringify(this.payloadAsJson);
		}
		
		/**
		 * Returns an object ready to be encoded to JSON.
		 */
		public function get payloadAsJson() : Object 
		{
			return buildJSONPayload();
		}
		
		/**
		 * Returns the write key used by this call.
		 */
		public function get writeKey() : String { return _writeKey; }

	}
}