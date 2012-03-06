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

package decompiler.swfdump.debug
{
	import decompiler.swfdump.Action;
	import decompiler.swfdump.ActionHandler;
	import decompiler.swfdump.types.ActionList;
	
	public class RegisterRecord extends Action
	{
		public function RegisterRecord(offset:int, numRegisters:int)
		{
			super(ActionList.sactionRegisterRecord);
			var size:int = numRegisters;
			registerNumbers = new Vector.<int>(size);
			variableNames = new Vector.<String>(size);
			this.offset = offset;
			next = 0;
		}
		
		public var registerNumbers:Vector.<int>;
		public var variableNames:Vector.<String>;
		public var offset:int;
		
		// internal use for addRegister()
		private var next:int;
		
		/**
		 * Used to add a register entry into this record
		 */
		public function addRegister(regNbr:int, variableName:String):void
		{
			registerNumbers[next] = regNbr;
			variableNames[next] = variableName;
			next++;
		}
		
		public function indexOf(regNbr:int):int
		{
			/* var at:int = -1;
			for(var i:int=0; at<0 && i<registerNumbers.length; i++)
			{
				if (registerNumbers[i] == regNbr)
					at = i;
			}
			*/
			var at:int = registerNumbers.indexOf(regNbr,0);
			return at;
		}
		
		public override function visit(h:ActionHandler):void
		{
			h.registerRecord(this);
		}
		
		public override function toString():String
		{
			var sb:String = new String();
			sb += offset + " ";
			for(var i:int=0; i<registerNumbers.length; i++)
				sb += "$"+registerNumbers[i]+"='"+variableNames[i]+"' ";
			return ( sb ); 
		}
		
		public override function equals(object:*):Boolean
		{
			var isIt:Boolean = (object is RegisterRecord); 
			if (isIt)
			{
				var other:RegisterRecord = object as RegisterRecord;
				isIt = super.equals(other);
				for(var i:int=0; isIt && i<registerNumbers.length; i++)
				{
					isIt = ( (other.registerNumbers[i] == this.registerNumbers[i]) &&
						(other.variableNames[i] == this.variableNames[i]) ) ? isIt : false;
				}
			}
			return (isIt);
		}
	}
}