////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package decompiler.swfdump.tags
{
	import decompiler.swfdump.TagHandler;
	import decompiler.tamarin.abcdump.Tag;
	
	import flash.utils.ByteArray;
	
	/**
	 * Represents a DefineSceneAndFrameLabelData SWF tag.
	 */
	public class DefineSceneAndFrameLabelData extends Tag
	{
		public function DefineSceneAndFrameLabelData()
		{
			super( stagDefineSceneAndFrameLabelData );
		}
		
		public var sceneCount:uint;
		public var frameLabelCount:uint;
		public var sceneInfo:Vector.<Object>;
		public var frameInfo:Vector.<Object>;
		
		public override function visit( h:TagHandler ):void
		{
			h.defineSceneAndFrameLabelData( this );
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineSceneAndFrameLabelData))
			{
				if (object.sceneCount == this.sceneCount &&
					object.frameLabelCount == this.frameLabelCount) {
					isEqual = true;
				}
				
				var i:int = 0;
				if (object.sceneInfo != null && this.frameInfo != null &&
					object.sceneInfo.length == this.sceneInfo.length) {
					for (i = 0; i < object.sceneInfo.length; i++) {
						if (object.sceneInfo[i] != this.sceneInfo[i]) {
							return (false);
						}
					}
				} else if (object.sceneInfo != null || this.sceneInfo != null) {
					return (false);
				}
				
				if (object.frameInfo != null && this.frameInfo != null &&
					object.frameInfo.length == this.frameInfo.length) {
					for (i = 0; i < object.frameInfo.length; i++) {
						if (object.frameInfo[i] != this.frameInfo[i]) {
							return (false);
						}
					}
				} else if (object.frameInfo != null || this.frameInfo != null) {
					return (false);
				}
				
				/**
				if (object.data.length == this.data.length) {
					isEqual = true;
					for (var i:int = 0; i < this.data.length; i++) {
						if (object.data[i] != this.data[i]) {
							isEqual = false;
						}
					}
				}
				 */
				//isEqual = equals(((DefineSceneAndFrameLabelData)object).data, this.data);
			}
			return isEqual;
		}
		
		/**
		public function hashCode():int
		{
			return data.hashCode();
		}
		 */
		// todo: once we care about this tag, break out the fields
		// for now, just allow round-tripping
		public var data:ByteArray;
		
	}
}