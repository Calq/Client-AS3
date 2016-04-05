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
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	
	import io.calq.analytics.ActionApiCall;
	import io.calq.analytics.ApiDispatcher;
	import io.calq.analytics.ProfileApiCall;
	import io.calq.analytics.TransferApiCall;
	import io.calq.util.Device;
	import io.calq.util.GUID;
	import io.calq.util.Util;

	public class CalqClient
	{
		/**
		 * The actor this client is for.
		 */
		protected var _actor:String;
		
		/**
		 * If this client is anonymous or not.
		 */
		protected var _isAnon:Boolean;
		
		/**
		 * If this client has sent an action before.
		 */
		protected var _hasTracked:Boolean;
		
		/**
		 * Map of global properties for this session.
		 */
		protected var _globalProperties:Object;
		
		/**
		 * The write key in use by this client.
		 */
		protected var _writeKey:String;
		
		/**
		 * Shared object used to write local state.
		 */
		protected var _storage:SharedObject;
		
		/**
		 * Dispatcher that actually sends API calls to the server.
		 */
		protected var _dispatcher:ApiDispatcher;
		
		/**
		 * Singleton instance to make it easier to use this around the code base for
		 * devs that don't want to pass the CalqClient reference around manually.
		 */
		private static var singleton:CalqClient;
		
		/**
		 * Creates a new CalqClient instance.
		 * 
		 * @param writeKey	The write key this instance will use for communication.
		 * @param options	Object used to pass advanced options.
		 */
		public function CalqClient(writeKey:String, options:Object = null)
		{
			if(writeKey == null || writeKey.length < 32)
			{
				throw(new Error("A valid writeKey must be speficied when creating CalqClient instances."));
			}
			_writeKey = writeKey;
			
			_actor = CalqClient.generateAnonymousId();
			_isAnon = true;
			_hasTracked = false;
			_globalProperties = {};
			
			_storage = openStorage(_writeKey);
			_dispatcher = new ApiDispatcher();
			
			// Will overwrite state if we have previous
			if(options == null || options.ignoreState !== true)
			{
				loadState();
			}
			
			// Overwrite device properties each time
			populateDeviceProperties();
			
			if(CalqClient.singleton == null)
			{
				CalqClient.singleton = this;
			}
			else
			{
				trace("[CalqClient] Warning: Mutliple CalqClient instances have been created.");
			}
			
			// Custom options
			if(options != null)
			{
				if(options.dispatcher != null)	// Custom dispatch class (maybe want to redirect to msg store etc)
				{
					_dispatcher = options.dispatcher;
				}
			}
		}
		
		/**
		 * Gets a previously created CalqClient instance.
		 */
		public static function getInstance() : CalqClient
		{
			if(CalqClient.singleton == null)
			{
				// Better to throw. Likely to get NREs if we warn & return null
				throw(new Error("Cant use getInstance() before a CalqClient has been created"));
			}
			return CalqClient.singleton;
		}
		
		// State persistence
		
		/**
		 * Loads any state from a previous session.
		 */
		public function loadState() : void
		{
			if(_storage != null)
			{
				if(_storage.data.actor != null)
				{
					_actor = _storage.data.actor || _actor;
					_isAnon = _storage.data.isAnon || _isAnon;
					_hasTracked = _storage.data.hasTracked || _hasTracked;
					_globalProperties = _storage.data.globalProperties || _globalProperties;
				}
			}
		}
		
		/**
		 * Saves the current CalqClient state to persistent storage.
		 */
		protected function saveState() : void 
		{
			if(_storage != null)
			{
				_storage.data.actor = _actor;
				_storage.data.isAnon = _isAnon;
				_storage.data.hasTracked = _hasTracked;
				_storage.data.globalProperties = _globalProperties;
				
				_storage.flush();
			}
		}
		
		/**
		 * Attempts to open local storage.
		 */
		private function openStorage(writeKey:String) : SharedObject
		{
			var so:SharedObject = null;
			try 
			{
				so = SharedObject.getLocal("calq/" + writeKey, "/");
			}
			catch (e:Error)
			{
				trace("[CalqClient] Unable to open local storage. State will not persist!");
				return null;
			}
			return so;
		}
		
		// Public API methods
		
		/**
		 * Tracks the given action.
		 *
		 * <p>Calq performs analytics based on actions that you send it, and any custom data
		 * associated with that action. This call is the core of the analytics platform.
		 *
		 * <p>All actions have an action name, and some optional data to send along with it.
		 *
		 * <p>This method will pass data to a background worker and continue ASAP. It will not
		 * block whilst API calls to Calq servers are made.
		 *
		 * @param action        The name of the action to track.
		 * @param properties    Any properties to include along with this action. Can be nil.
		 */
		public function track(action:String, properties:Object = null) : void
		{
			if(action == null || action.length == 0)
			{
				trace("[CalqClient] An empty action was given to track(...)");
				return;
			}
			
			if(properties == null)
			{
				properties = {};
			}
			
			var mergedProperties:Object = Util.extend({}, _globalProperties, properties);
			
			_dispatcher.enqueue(new ActionApiCall(_actor, action, mergedProperties, _writeKey));
			
			if(!_hasTracked)
			{
				_hasTracked = true;
				saveState();
			}
		}
		
		/**
		 * Tracks the given action which has associated revenue.
		 *
		 * @param action        The name of the action to track.
		 * @param properties    Any optional properties to include along with this action.
		 * @param currency      The 3 letter currency code for this sale (can be fictional).
		 * @param amount        The amount this sale is worth (can be negative for refunds).
		 */
		public function trackSale(action:String, properties:Object, currency:String, value:Number) : void
		{
			if (currency == null || currency.length != 3)
			{
				trace("[CalqClient] When calling trackSale the 'currency' parameter must be a 3 letter currency code (fictional or otherwise)."); 
				return;
			}
			
			var mergedProperties:Object = Util.extend({}, properties); // Copy so we don't mutate input
			mergedProperties[ReservedActionProperties.SALE_CURRENCY] = currency;
			mergedProperties[ReservedActionProperties.SALE_VALUE] = value;
			
			track(action, properties);
		}
		
		/**
		 * Sets a global property to be sent with all future actions when using track(...)
		 * Will be persisted to client for future. If a value has been already set then it will be overwritten.
		 * Passing null as the value will delete the property if previously set.
		 *
		 * @param name          The name of the property to set.
		 * @param value         The value of the new global property.
		 */
		public function setGlobalProperty(name:String, value:*) : void
		{
			if(name == null || name.length == 0)
			{
				trace("[CalqClient] 'name' parameter can not be null or empty when calling setGlobalProperty.");
				return;
			}
			
			if(value == null)
			{
				delete _globalProperties[name];
			}
			else
			{
				_globalProperties[name] = value;
			}
			
			saveState();
		}
		
		/**
		 * Sets the ID of this client to something else. This should be called if you register or
		 * sign-in a user and want to associate previously anonymous actions with this new identity.
		 *
		 * <p>This should only be called once for a given user. Calling identify again with a
		 * different Id for the same user will result in an exception being thrown.
		 *
		 * @param actor         The new unique actor Id.
		 */
		public function identify(actor:String) : void
		{
			if(actor != _actor)
			{
				if(!_isAnon)
				{
					trace("[CalqClient] identify(...) has already been called for this client.");
					return;
				}
				
				var oldActor:String = _actor;
				_actor = actor;
				
				if(_hasTracked)
				{
					_dispatcher.enqueue(new TransferApiCall(oldActor, _actor, _writeKey));
				}
				
				_isAnon = false;
				_hasTracked = false;
				
				saveState();
			}
		}
		
		/**
		 * Sets profile properties for the current user. These are not the same as global properties.
		 * A user MUST be identified before calling profile else an exception will be thrown.
		 *
		 * @param properties	The custom properties to set for this user. If a property with the
		 * 		same name already exists then it will be overwritten.
		 */
		public function profile(properties:Object) : void
		{
			if(properties == null)
			{
				trace("[CalqClient] You must pass some properties when calling profile(...)");
				return;
			}
			if(_isAnon)
			{
				trace("A client must be identified (call identify) before calling profile.");
				return;
			}
			
			_dispatcher.enqueue(new ProfileApiCall(_actor, properties, _writeKey));
		}
		
		/**
		 * Clears the current session and resets to being an anonymous user.
		 * You should generally call this if a user logs out of your application.
		 */
		public function clear() : void
		{
			_actor = CalqClient.generateAnonymousId();
			_hasTracked = false;
			_isAnon = true;
			_globalProperties = {};
			
			saveState();
		}
		
		// Internal API methods
		
		/**
		 * Populates the sessions global properties with device specific properties
		 * for the current device.
		 */
		protected function populateDeviceProperties() : void
		{	
			setGlobalProperty(ReservedActionProperties.DEVICE_RESOLUTION, 
				Capabilities.screenResolutionX.toString() + "x" + Capabilities.screenResolutionY.toString());
			
			setGlobalProperty(ReservedActionProperties.DEVICE_OS, Device.osShort);

			setGlobalProperty(ReservedActionProperties.DEVICE_MOBILE, Device.isAndroid || Device.isIOS);
			
			setGlobalProperty(ReservedActionProperties.DEVICE_AGENT,
				Capabilities.os + ", " + Capabilities.version);
		}
		
		// Util
		
		private static function generateAnonymousId() : String
		{
			return (new GUID()).toString();
		}
		
		// Properties
		
		/**
		 * Gets the actor represented by this client instance.
		 */
		public function get actor() : String { return _actor; }
	}
}