/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 *  Copyright 2012 Adobe Systems Incorporated and it’s licensors
 *  All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package decompiler
{
	import mx.collections.XMLListCollection;
	
	/**
	 * This manages the XML representation of the SWF for AS3Navigator
	 */
	public class ABCXML
	{
		[Bindable]
		public var abcXML:XML;
		
		[Bindable]
		public var abcData:XMLListCollection;
		
		/**
		 * Constructor -- Create the default abcXML definition
		 */
		public function ABCXML()
		{
			this.abcXML =
			<list>
			  <pckg name="(default)" type="pckg"/>
			</list>;
			      
		}
		
		/**
		 * Used by the Navigator to get the name for a particular item.
		 * 
		 * @param item The Object sent by the Tree label function to be cast as XML
		 * @return A string representing the node's name.
		 */
		public function abcTreeLabel(item:Object):String {
			var node:XML = XML(item);
			return node.@name;
		}
		
		
		/**
		 * Add a Class to the specified package
		 * 
		 * @param packageName The string containing the package that will be updated
		 * @param className The string containing the name of the new class
		 * @param classData The string containing the decompiled code for the class
		 */
		public function addClass(packageName:String,className:String,classData:String):void {
			var newNode:XML = <class type="class"/>;
			newNode.@name = className;
			newNode.@data = classData;
			var pckg:XMLList = this.abcXML.pckg.(@name == packageName);
			if (pckg.length() > 0) {
				pckg[0].appendChild(newNode);
			}
		}
		
		/**
		 * Add a package level element to the tree
		 * 
		 * @param packageName The string containing the package name.
		 */
		public function addPackage(packageName:String):void {
			var pckg:XMLList = this.abcXML.pckg.(@name == packageName);
			if (pckg.length() > 0) {
				return;
			}
			var newNode:XML = <pckg type="pckg"/>
			newNode.@name = packageName;
			this.abcXML.appendChild(newNode);
		}
		
		/**
		 * Create an XMLListCollection to host the ABC data
		 */
		public function createCollection():void {
			this.abcData = new XMLListCollection(this.abcXML.pckg)
		}

	}
}