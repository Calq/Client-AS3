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

package io.calq.util
{
	import flash.system.Capabilities;
	
	public class Device
	{	
		/** @private	 Did we already check the device system? */
		protected static var _systemChecked:Boolean = false;
		/** @private */
		protected static var _isIOS:Boolean = false;
		/** @private */
		protected static var _isAndroid:Boolean = false;
		/** @private */
		protected static var _isIphone:Boolean = false;
		/** @private */
		protected static var _isIpod:Boolean = false;
		/** @private */
		protected static var _isIpad:Boolean = false;
		/** @private */
		protected static var _osShort:String;
		/** @private */
		protected static var _deviceGeneration:int = 0;
		
		/**
		 * Gets if this device is an Android device.
		 */
		public static function get isAndroid() : Boolean 
		{ 
			_systemCheck();
			return _isAndroid;
		}
		
		/**
		 * Gets if this device is an iPod device.
		 */
		public static function get isIpod() : Boolean 
		{
			_systemCheck();
			return _isIpod;
		}
		
		public static function get isIpad() : Boolean
		{
			_systemCheck();
			return _isIpad;
		}
		
		public static function get isIphone() : Boolean
		{
			_systemCheck();
			return _isIphone;
		}
		
		/** On iOS gets the device generation. */
		public static function get deviceGeneration() : int 
		{
			_systemCheck();
			return _deviceGeneration;
		}
		
		/**
		 * Gets if this device is an iOS device.
		 */
		public static function get isIOS():Boolean
		{
			_systemCheck();
			return _isIOS;
		}
		
		/**
		 * Gets if this device is a Desktop computer.
		 */
		public static function get isDesktop():Boolean
		{
			return (!_isIOS && !_isAndroid);
		}
		
		/**
		 * Gets short name for this OS.
		 */
		public static function get osShort():String
		{
			_systemCheck();
			return _osShort;
		}
		
		/** 
		 * @private 
		 * Checks the device system
		 */
		protected static function _systemCheck():void
		{
			if( _systemChecked ) return;
			_systemChecked = true;
			
			var os:String = Capabilities.os;
			
			// check devices
			var r:RegExp = /(iPod|iPad|iPhone)([0-9]+)/;
			var matches:Object = os.match( r );
			if( matches != null && matches["2"] != undefined )
			{
				_isIOS = true;
				_isIphone = Boolean(matches["1"] == "iPhone");
				_isIpad = Boolean(matches["1"] == "iPad");
				_isIpod = Boolean(matches["1"] == "iPod");
				_deviceGeneration = int( matches["2"] );
			}			
			_isAndroid = Boolean( Capabilities.os.indexOf("Linux") >= 0 || Capabilities.os.indexOf("Android") >= 0 );
			
			if(_isIOS)
			{
				_osShort = "iOS";
			}
			else if(_isAndroid)
			{
				_osShort = "Android";
			}
			else
			{
				_osShort = Capabilities.os;
			}
		}
	}
}