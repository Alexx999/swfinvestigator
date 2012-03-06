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

package decompiler.swfdump
{
	import decompiler.swfdump.Action;
	import decompiler.swfdump.actions.Label;
	import decompiler.swfdump.actions.Push;
	import decompiler.swfdump.actions.StoreRegister;
	import decompiler.swfdump.actions.StrictMode;
	import decompiler.swfdump.actions.WaitForFrame;
	import decompiler.swfdump.debug.LineRecord;
	import decompiler.swfdump.debug.RegisterRecord;
	import decompiler.swfdump.types.ActionList;
	import decompiler.swfdump.types.PushNum;
	
	final public class ActionFactory
	{
		public static const UNDEFINED:String = "undefined";
		
		public static const STACKTOP:String = "stack";

		
		/** flyweight action objects for 1-byte opcodes 0..7F */
		private static var actionFlyweights:Vector.<Action> = new Vector.<Action>(0x80);
		private static var pushCpoolFlyweights:Vector.<Push> = new Vector.<Push>(256);
		private static var pushRegisterFlyweights:Vector.<Push> = new Vector.<Push>(256);
		private static var storeRegisterFlyweights:Vector.<StoreRegister> = new Vector.<StoreRegister>(256);
		private static var pushTrueFlyweight:Push = new Push( new Boolean(true));
		private static var pushFalseFlyweight:Push = new Push(new Boolean(false));
		private static var pushUndefinedFlyweight:Push = new Push(UNDEFINED);
		private static var pushNullFlyweight:Push = new Push(null);
		private static var pushFloat0Flyweight:Push = new Push(new PushNum("Float", 0));
		private static var pushInteger0Flyweight:Push = new Push(0);
		private static var pushDouble0Flyweight:Push = new Push(new PushNum("Double",0));
		private static var callFlyweight:Action = new Action(ActionConstants.sactionCall);
		private static var strictTrueFlyweight:StrictMode = new StrictMode(true);
		private static var strictFalseFlyweight:StrictMode = new StrictMode(false);
		
		public static function createAction(code:int):Action
		{
			return actionFlyweights[code];
		}
		
		public static function createPushCpool(index:int):Push
		{
			return (index < pushCpoolFlyweights.length)
			? pushCpoolFlyweights[index]
				: new Push(new PushNum("Short", index));
		}
		
		public static function createPushString(s:String):Push
		{
			return new Push(s);
		}
		
		public static function createPushFloat(fvalue:PushNum):Push
		{
			return fvalue.num == 0
				? pushFloat0Flyweight
				: new Push(new PushNum("Float",fvalue.num));
		}
		
		public static function createPushNull():Push
		{
			return pushNullFlyweight;
		}
		
		public static function createPushUndefined():Push
		{
			return pushUndefinedFlyweight;
		}
		
		public static function createPushRegister(regno:int):Push
		{
			return pushRegisterFlyweights[regno];
		}
		
		public static function createPushBoolean(b:Boolean):Push
		{
			return (b ? pushTrueFlyweight : pushFalseFlyweight);
		}
		
		public static function createPushDouble(dvalue:PushNum):Push
		{
			return dvalue.num == 0
				? pushDouble0Flyweight
				: new Push(new PushNum("Double", dvalue.num));
		}
		
		public static function createPushInt(ivalue:int):Push
		{
			return ivalue == 0
				? pushInteger0Flyweight
				: new Push(ivalue);
		}
		
		public static function createStoreRegister(register:int):StoreRegister
		{
			return storeRegisterFlyweights[register];
		}
		
		public static function createCall():Action
		{
			return callFlyweight;
		}
		
		public static function createStrictMode(mode:Boolean):StrictMode
		{
			return mode ? strictTrueFlyweight : strictFalseFlyweight;
		}
		
		private var startOffset:int;
		private var startCount:int;
		private var actions:Vector.<Action>;
		private var labels:Vector.<Label>;
		private var lines:Vector.<LineRecord>;
		private var registers:Vector.<RegisterRecord>;
		private var actionOffsets:Vector.<int>;
		private var count:int;
		private var skipRecords:Vector.<SkipEntry>;
		
		public function ActionFactory(length:int, startOffset:int, startCount:int)
		{
			this.startOffset = startOffset;
			this.startCount = startCount;
			
			labels = new Vector.<Label>(length+1);  // length+1 to handle labels after last action
			lines = new Vector.<LineRecord>(length);
			registers = new Vector.<RegisterRecord>(length);
			actions = new Vector.<Action>(length);
			actionOffsets = new Vector.<int>(length+1);
			skipRecords = new Vector.<SkipEntry>();
			
			var i:int;
			for (i=0; i < 0x80; i++)
			{
				ActionFactory.actionFlyweights[i] = new Action(i);
			}
			
			for (i=0; i < 256; i++)
			{
				ActionFactory.pushRegisterFlyweights[i] = new Push(new PushNum("Byte",i));
				ActionFactory.pushCpoolFlyweights[i] = new Push(new PushNum("Short", i));
				ActionFactory.storeRegisterFlyweights[i] = new StoreRegister(i);
			}
		}
		
		public function setLine(offset:int, line:LineRecord):void
		{
			var i:int = offset-startOffset;
			if (lines[i] == null)
				count++;
			lines[i] = line;
		}
		
		public function setRegister(offset:int, record:RegisterRecord):void
		{
			var i:int = offset-startOffset;
			if (registers[i] == null)
				count++;
			registers[i] = record;
		}
		
		public function setAction(offset:int, a:Action):void
		{
			var i:int = offset-startOffset;
			if (actions[i] == null)
				count++;
			actions[i] = a;
		}
		
		public function getLabel(target:int):Label
		{
			var i:int = target-startOffset;
			var label:Label = labels[i];
			
			if (label == null)
			{
				labels[i] = label = new Label();
				count++;
			}
			return label;
		}
		
		public function setActionOffset(actionCount:int, offset:int):void
		{
			actionOffsets[actionCount-startCount] = offset;
		}
		
		/**
		 * now that everything has been decoded, build a single actionlist
		 * with the labels and jump targets merged in.
		 * @param keepOffsets
		 * @return
		 */
		public function createActionList(keepOffsets:Boolean):ActionList
		{
			processSkipEntries();
			
			var list:ActionList = new ActionList(keepOffsets);
			list.grow(count);
			var a:Action;
			var length:int = actions.length;
			var i:int;
			if (keepOffsets)
			{
				for (i=0; i < length; i++)
				{
					var offset:int = startOffset+i;
					if ((a=actions[i]) != null)
						list.insert(offset, a);
					if ((a=lines[i]) != null)
						list.insert(offset, a);
					if ((a=registers[i]) != null)
						list.insert(offset, a);
					if ((a=labels[i]) != null)
						list.insert(offset, a);
				}
				if ((a=labels[length]) != null)
					list.insert(startOffset+length, a);
			}
			else
			{
				for (i=0; i < length; i++)
				{
					if ((a=labels[i]) != null)
						list.append(a);
					if ((a=lines[i]) != null)
						list.append(a);
					if ((a=registers[i]) != null)
						list.append(a);
					if ((a=actions[i]) != null)
						list.append(a);
				}
				if ((a=labels[length]) != null)
					list.append(a);
			}
			return list;
		}
		
		/**
		 * postprocess skip records now that we now the offset of each encoded action
		 */
		private function processSkipEntries():void
		{
			var i:int;
			for (i = 0; i < skipRecords.length; i++)
			{
				var skipRecord:SkipEntry = skipRecords[i];
				var labelOffset:int = actionOffsets[skipRecord.skipTarget-startCount];
				skipRecord.action.skipTarget = getLabel(labelOffset);
			}
		}
		
		public function addSkipEntry(a:WaitForFrame, sTarget:int):void
		{
			skipRecords.push(new SkipEntry(a, sTarget));
		}
		
		
	}
}