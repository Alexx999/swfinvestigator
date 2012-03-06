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
	import decompiler.tamarin.abcdump.Tag;
	
	import mx.collections.XMLListCollection;
	
	/**
	 * This manages the XML representation of the SWF for AS3Navigator
	 */
	public class TagXML
	{
		[Bindable]
		public var tagXML:XML;
		
		[Bindable]
		public var tagData:XMLListCollection;
				
		/**
		 * Constructor -- Create the default tagXML definition
		 * 			  <tag name="end"/>
		 */
		public function TagXML()
		{
			//this.tDecoder = t;
			
			this.tagXML =
			<list>
			</list>;
			      
		}
		
		/**
		 * Used by the Navigator to get the name for a particular item.
		 * 
		 * @param item The Object sent by the Tree label function to be cast as XML
		 * @return A string representing the node's name.
		 */
		public function tagTreeLabel(item:Object):String {
			var node:XML = XML(item);
			return node.@name;
		}
		
		
		/**
		 * Add a Field to the specified tag
		 * 
		 * @param tagName The string containing the tag that will be updated
		 * @param fieldName The string containing the name of the new class
		 * @param fieldData The string containing the decompiled code for the class
		 */
		/**
		 * Currently not used.
		public function addField(tagPosition:uint):void {
			var newNode:XML = <field/>;
			newNode.@name = "flags";
			newNode.@position = tagPosition;
			newNode.@data = "";
			var tags:XMLList = this.tagXML.tag.(@position == tagPosition);
			if (tags.length() > 0) {
				tags[0].appendChild(newNode);
			}
		}
		 */
		
		/**
		 * Add a tag level element to the tree
		 * 
		 * @param tagName The string containing the tag name.
		 */
		public function addTag(tagNode:Tag):void {
			var tags:XMLList = this.tagXML.tag.(@position == tagNode.position);
			if (tags.length() > 0) {
				return;
			}
			var newNode:XML = <tag icon="TagIcon"/>
			newNode.@name = tagNode.tName;
			newNode.@position = tagNode.position;
			newNode.@length = tagNode.size;
			newNode.@type = tagNode.type;
			if (tagNode.longRecordHeader) {
				newNode.@header = "long";
			} else {
				newNode.@header = "short";
			}
			if (tagNode.SIErrorMessage != null && tagNode.SIErrorMessage.length > 0) {
				newNode.@SIErrorMessage = tagNode.SIErrorMessage;
				newNode.@icon = "ErrorIcon";
			}
			
			if (tagNode.theTag != null && tagNode.theTag.SIErrorMessage != null && tagNode.theTag.SIErrorMessage.length > 0) {
				newNode.@SIErrorMessage = tagNode.theTag.SIErrorMessage;
				newNode.@icon = "ErrorIcon";
			}
			this.tagXML.appendChild(newNode);
		}
		
		/**
		 * Create an XMLListCollection to host the Tag data
		 */
		public function createCollection():void {
			this.tagData = new XMLListCollection(this.tagXML.tag)
		}

	}
}