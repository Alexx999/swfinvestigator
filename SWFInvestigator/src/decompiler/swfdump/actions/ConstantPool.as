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

package decompiler.swfdump.actions
{
	import decompiler.swfdump.Action;
	import decompiler.swfdump.ActionConstants;
	import decompiler.swfdump.ActionHandler;

	public class ConstantPool extends Action
	{
		public var pool:Vector.<String>;
		
		public function ConstantPool(poolData:Vector.<String> = null) {
			super(ActionConstants.sactionConstantPool);
			if (poolData != null) {
				pool = poolData;
			} else {
				pool = new Vector.<String>();
			}
		}
		
		public override function visit (h:ActionHandler):void {
			h.constantPool(this);
		}
		
		public override function equals(object:*):Boolean {
			
			if (super.equals(object) && (object is ConstantPool)) {
				var constantPool:ConstantPool = object as ConstantPool;
				
				if (constantPool.pool.length != this.pool.length) {
					return (false);
				}
				
				for (var i:int = 0; i <this.pool.length; i++) {
					if (this.pool[i] != constantPool.pool[i]) {
						return (false);
					}
				}
				
				return (true)
			}
			
			return (false);
		}
		
		public override function toString():String {
			var sb:String = "";
			sb += "ConstantPool[ pool = { ";
			for (var i:int = 0; i < pool.length; i++) {
				sb += pool[i];
				sb += ", ";
			}
			sb += "} ]";
			return (sb);
		}
	}
}