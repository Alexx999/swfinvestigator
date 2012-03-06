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
	import decompiler.swfdump.types.ActionList;
	
	public class DefineFunction extends Action
	{
		public static var kPreloadThis:int		= 0x0001;
		public static var kSuppressThis:int		= 0x0002;
		public static var kPreloadArguments:int	= 0x0004;
		public static var kSuppressArguments:int	= 0x0008;
		public static var kPreloadSuper:int		= 0x0010;
		public static var kSuppressSuper:int		= 0x0020;
		public static var kPreloadRoot:int		= 0x0040;
		public static var kPreloadParent:int		= 0x0080;
		public static var kPreloadGlobal:int		= 0x0100;
		
		public var name:String;
		public var params:Vector.<String>;
		public var actionList:ActionList;
		
		//defineFunction2 only
		public var paramReg:Vector.<int>;
		public var regCount:int;
		public var flags:int;
		
		public var codeSize:int;
		
		public function DefineFunction(code:int)
		{
			super(code);
		}
		
		public override function visit(h:ActionHandler):void {
			if (code == ActionConstants.sactionDefineFunction) {
				h.defineFunction(this);
			} else {
				h.defineFunction2(this);
			}
		}
		
		public override function equals(object:*):Boolean {
			
			if (super.equals(object) && object is DefineFunction) {
				var defineFunction:DefineFunction = object as DefineFunction;
				
				if (defineFunction.name != this.name) {
					return (false);
				}
				if (defineFunction.regCount != this.regCount) {
					return (false);
				}
				if (this.params.length != defineFunction.params.length
					|| this.paramReg.length != defineFunction.paramReg.length) {
					return (false);
				}
				
				var i:int;
				for (i = 0; i < this.params.length; i++) {
					if (this.params[i] != defineFunction.params[i]) {
						return (false);
					}
				}
				
				for (i=0; i < this.paramReg.length; i++) {
					if (this.paramReg[i] != defineFunction.paramReg[i]) {
						return (false);
					}
				}
				
				if (super.objectEquals(defineFunction.actionList, this.actionList) != true) {
					return (false);
				}
				
				return (true);
			}
			
			return (false);
		}
	}
}