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

package io.calq
{
	public class ReservedApiProperties
	{
		/**
		 * The name of a new action.
		 */
		public static const ACTION_NAME:String = "action_name";
		
		/**
		 * The unique actor of an event (e.g. a user id, server name, etc).
		 */
		public static const ACTOR:String = "actor";
		
		/**
		 * The source ip address for this action.
		 */
		public static const IP_ADDRESS:String = "ip_address";
		
		/**
		 * The previous unique id of an actor when transferring.
		 */
		public static const OLD_ACTOR:String = "old_actor";
		
		/**
		 * The new unique id of an actor when transferring.
		 */
		public static const NEW_ACTOR:String = "new_actor";
		
		/**
		 * Properties node giving user provided custom information.
		 */
		public static const USER_PROPERTIES:String = "properties";
		
		/**
		 * The timestamp of a new event.
		 */
		public static const TIMESTAMP:String = "timestamp";
		
		/**
		 * The timestamp this device thinks is the current UTC timestamp.
		 */
		public static const UTC_NOW:String = "utc_now";
		
		/**
		 * The unique key to identify this project when writing.
		 */
		public static const WRITE_KEY:String = "write_key";
	}
}