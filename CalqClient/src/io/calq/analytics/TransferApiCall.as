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
	
	public class TransferApiCall extends AbstractAnalyticsApiCall
	{
		/**
		 * The new actor name.
		 */
		protected var _newActor:String;
		
		/**
		 * Creates a new TransferApiCall describing an id change. This will be passed to the
		 * /transfer/ API endpoint.
		 * 
		 * @param oldActor			The former actor name.
		 * @param newActor			The new actor name
		 * @param writeKey			The write key to use for this API call.
		 */
		public function TransferApiCall(oldActor:String, newActor:String, writeKey:String)
		{
			super(oldActor, writeKey);
			_newActor = newActor; 
		}

		/**
		 * {@inheritDoc}
		 */
		public override function get apiEndpoint() : String { return "Transfer"; }
		
		/**
		 * {@inheritDoc}
		 */
		protected override function buildJSONPayload() : Object 
		{
			var jsonObject:Object = super.buildJSONPayload();
			jsonObject[ReservedApiProperties.OLD_ACTOR] = _actor;
			jsonObject[ReservedApiProperties.NEW_ACTOR] = _newActor;
			return jsonObject;
		}

	}
}