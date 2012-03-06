/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package Fuzzer
{
	import mx.collections.XMLListCollection;

	
	public class FuzzerLogger
	{
		[Bindable]
		public var logXML:XML;
		
		[Bindable]
		public var logData:XMLListCollection;
		
		public function FuzzerLogger()
		{
			this.logXML = 
				<list>
				  <slot name="baseline" type="slot"/>
				</list>;
			
		}
		
		/**
		 * Used by the Navigator to get the name for a particular item.
		 * 
		 * @param item The Object sent by the Tree label function to be cast as XML
		 * @return A string representing the node's name.
		 */
		public function logTreeLabel(item:Object):String {
			var node:XML = XML(item);
			return node.@name;
		}
		
		
		/**
		 * Add a result to the specified package
		 * 
		 * @param slotName The string containing the slot that will be updated
		 * @param varValue The string containing the name of the fuzzed result
		 * @param resultData The string containing the decompiled code for the attempt
		 * @param iconName The name of for the iconField in the Tree
		 */
		public function addResult(slotName:String,varName:String,resultData:String,iconName:String = ""):void {
			var newNode:XML = <result type="result"/>;

			//In case the fuzz value is ridiculously long
			if (varName.length > 4000) {
				varName = varName.substr(0,4000);
		    }
			newNode.@name = varName;
			newNode.@data = resultData;
			if (iconName.length > 0) {
				newNode.@icon = iconName;
			}
			var slot:XMLList = this.logXML.slot.(@name == slotName);
			if (slot.length() > 0) {
				slot[0].appendChild(newNode);
			}
		}
		
		/**
		 * Add a slot level element to the tree
		 * 
		 * @param slotName The string containing the slot that was fuzzed .
		 */
		public function addSlotEntry(slotName:String, slotType:String):void {
			var slot:XMLList = this.logXML.slot.(@name == slotName);
			if (slot.length() > 0) {
				return;
			}
			var newNode:XML = <slot type="slot"/>
			newNode.@name = slotName;
			newNode.@type = slotType;
			this.logXML.appendChild(newNode);
		}
		
		/**
		 * Create an XMLListCollection to host the log data
		 */
		public function createCollection():void {
			this.logData = new XMLListCollection(this.logXML.slot)
		}
	}
}