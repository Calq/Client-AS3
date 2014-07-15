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
	
	public class ActionApiCall extends AbstractAnalyticsApiCall
	{
		/**
		 * The date time of when this call was created (wrapped as UTC unix epoch offset).
		 */
		protected var createdAt:Date;
		
		/**
		 * The action being performed.
		 */
		protected var action:String
		
		/**
		 * The custom properties sent with this action.
		 */
		protected var properties:Object;

		
		public function ActionApiCall(actor:String, action:String, properties:Object, writeKey:String)
		{
			super(actor, writeKey);
			
			if(properties == null)
			{
				// OK to throw for this. This is a Calq dev error if it happened
				throw(new Error("A properties value must be passed to the ActionApiCall ctor. Can be empty."));
			}
			this.properties = properties;
			this.action = action;
			
			createdAt = new Date();
		}
		
		/**
		 * {@inheritDoc}
		 */
		public override function get apiEndpoint() : String { return "Track"; }
		
		/**
		 * {@inheritDoc}
		 */
		protected override function buildJSONPayload() : Object 
		{
			var jsonObject:Object = super.buildJSONPayload();
			jsonObject[ReservedApiProperties.TIMESTAMP] = createdAt;
			jsonObject[ReservedApiProperties.ACTION_NAME] = action;
			jsonObject[ReservedApiProperties.USER_PROPERTIES] = properties;
			return jsonObject;
		}

	}
}