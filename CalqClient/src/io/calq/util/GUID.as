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
	/**
	 * Class for GUID.
	 */
	public class GUID extends Object
	{	
		protected var uid:Array;		// The array that makes up the guid
		
		// The valid chars to generate from
		protected static const chars:Array = new Array( 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70 );
		// The separator between entries
		protected static const separator:uint = 45;
		// The format template
		protected static const template:Array = new Array( 8, 4, 4, 4, 12 );
		
		/**
		 * Creates a new GUID.
		 */
		public function GUID()
		{
			uid = new Array();
			generateSoft();
		}
		
		/**
		 * Generates a GUID in a "soft" manner (pure random, not date, mac etc).
		 */
		protected function generateSoft() : void
		{
			for ( var a:uint = 0; a < template.length; a++ )
			{
				for ( var b:uint = 0; b < template[a]; b++ )
				{
					uid.push( chars[ Math.floor( Math.random() *  chars. length ) ] );
				}
				if ( a < template.length - 1 ) 
				{
					uid.push( separator ); 
				}
			}
		}
		
		/**
		 * Returns this GUID as a string.
		 */
		public function toString() : String { return String.fromCharCode.apply(null, uid); }
	
	}
}