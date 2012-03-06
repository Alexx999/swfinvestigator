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
	import decompiler.Swf;
	import decompiler.swfdump.Action;
	import decompiler.swfdump.SWFFormatError;
	import decompiler.swfdump.actions.Branch;
	import decompiler.swfdump.actions.ConstantPool;
	import decompiler.swfdump.actions.DefineFunction;
	import decompiler.swfdump.actions.GetURL;
	import decompiler.swfdump.actions.GetURL2;
	import decompiler.swfdump.actions.GotoFrame;
	import decompiler.swfdump.actions.GotoFrame2;
	import decompiler.swfdump.actions.GotoLabel;
	import decompiler.swfdump.actions.Push;
	import decompiler.swfdump.actions.SetTarget;
	import decompiler.swfdump.actions.StoreRegister;
	import decompiler.swfdump.actions.StrictMode;
	import decompiler.swfdump.actions.Try;
	import decompiler.swfdump.actions.Unknown;
	import decompiler.swfdump.actions.WaitForFrame;
	import decompiler.swfdump.actions.With;
	import decompiler.swfdump.debug.DebugTable;
	import decompiler.swfdump.debug.LineRecord;
	import decompiler.swfdump.debug.RegisterRecord;
	import decompiler.swfdump.types.ActionList;
	import decompiler.swfdump.types.ClipActionRecord;
	import decompiler.swfdump.types.ClipActions;
	import decompiler.swfdump.types.PushNum;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class ActionDecoder
		extends ActionConstants
	{
		//private var reader:SwfDecoder;
		private var reader:Swf;
		private var debug:DebugTable;
		private var keepOffsets:Boolean;
		private var actionCount:int;
		
		
		public function ActionDecoder(reader:Swf, debug:DebugTable = null)
		{
			this.reader = reader;
			this.debug = debug;
		}
		
		public function setKeepOffsets(b:Boolean):void
		{
			keepOffsets = b;
		}
		
		
		/**
		 * consume actions until length bytes are used up
		 * @param length
		 * @param throwExceptions - if false exceptions will NOT be thrown. This is 
		 * used for decoding a series of opcodes which may not be complete on their own.
		 * //@throws IOException
		 * @throws SWFFormatError, Error
		 */
		public function decode(length:int, throwExceptions:Boolean = true):ActionList
		{
			var startOffset:int = reader.getOffset();
			var end:int = startOffset+length;
			var ending:Boolean = false;
			
			var factory:ActionFactory = new ActionFactory(length, startOffset, actionCount);
			try
			{
				for (var offset:int = startOffset; offset < end; offset = reader.getOffset())
				{
					var opcode:int = reader.readUI8();
					
					if (opcode > 0)
					{
						if (ending) {
							//throw new SwfFormatException("unexpected bytes after sactionEnd: " + opcode);
							throw new SWFFormatError("unexpected bytes after sactionEnd: " + opcode + " Position: " + offset);
						}
						factory.setActionOffset(actionCount, offset);
						decodeAction(opcode, offset, factory);
						actionCount++;
					}
					else if (opcode == 0)
					{
						ending = true;
					}
					else
					{
						break;
					}
				}
				// keep track of the end too
				factory.setActionOffset(actionCount, reader.getOffset());
			} catch (swf:SWFFormatError) {
				if (throwExceptions) {
					swf.aList = factory.createActionList(keepOffsets);
					throw swf;
				}
			} catch (e:Error) {
				if (throwExceptions) {
					var swf:SWFFormatError = new SWFFormatError(e.message, 3);
					swf.aList = factory.createActionList(keepOffsets);
					throw swf;
				}
			}

			/**
			catch(ArrayIndexOutOfBoundsException aio) 
			{
				if (throwExceptions)
					throw aio;
			}
			catch(SwfFormatException swf) 
			{
				if (throwExceptions)
					throw swf;
			}
			 */
			
			return factory.createActionList(keepOffsets);
		}
		
		public function decodeClipActions(length:int):ClipActions
		{
			if (length < 0) {
				throw new SWFFormatError("Negative length for ClipActions at " + reader.data.position);
			}
			
			var a:ClipActions = new ClipActions();
			reader.readUI16(); // must be 0
			a.allEventFlags = decodeClipEventFlags(reader);
			
			//revisit
			var list:Vector.<ClipActionRecord> = new Vector.<ClipActionRecord>();
			
			var record:ClipActionRecord = decodeClipActionRecord();
			while (record != null)
			{
				list.push(record);
				record = decodeClipActionRecord();
			}
			
			a.clipActionRecords = list;
			
			return a;
		}
		
		private function decodeClipActionRecord():ClipActionRecord
		{
			var flags:int = decodeClipEventFlags(reader);
			if (flags != 0)
			{
				var c:ClipActionRecord = new ClipActionRecord();
				
				c.eventFlags = flags;
				
				// this tells us how big the action block is
				var size:uint = reader.readUI32();
				
				if ((flags & ClipActionRecord.keyPress) != 0)
				{
					size--;
					c.keyCode = reader.readUI8();
				}
				
				c.actionList = decode(size);
				
				return c;
			}
			else
			{
				return null;
			}
		}
		
		private function decodeClipEventFlags(r:Swf):int
		{
			var flags:int;
			if (r.version >= 6)
				flags = int(r.readUI32());
			else
			flags = r.readUI16();
			return flags;
		}
		
		private function decodeAction(opcode:int, offset:int, factory:ActionFactory):void
		{
			var line:LineRecord = debug != null ? debug.getLine(offset) : null;
			if (line != null)
			{
				factory.setLine(offset, line);
			}
			
			// interleave register records in the action list
			var record:RegisterRecord = (debug != null) ? debug.getRegisters(offset) : null;
			if (record != null)
			{
				factory.setRegister(offset, record);
			}
			
			var a:Action;
			if (opcode < 0x80)
			{
				a = ActionFactory.createAction(opcode);
				factory.setAction(offset, a);
				return;
			}
			
			var len:int = reader.readUI16();
			var pos:int = offset+3;
			
			switch (opcode)
			{
				case sactionDefineFunction:
					a = decodeDefineFunction(pos, len);
					factory.setAction(offset, a);
					return;
					
				case sactionDefineFunction2:
					a = decodeDefineFunction2(pos, len);
					factory.setAction(offset, a);
					return;
					
				case sactionWith:
					a = decodeWith(factory);
					break;
				
				case sactionTry:
					a = decodeTry(factory);
					break;
				
				case sactionPush:
					var p:Push = decodePush(offset, pos+len, factory);
					checkConsumed(pos, len, p);
					return;
					
				case sactionStrictMode:
					a = decodeStrictMode();
					break;
				
				case sactionCall:
					// this actions opcode has the high bit set, but there is no length.  considered a permanent bug.
					a = ActionFactory.createCall();
					break;
				
				case sactionGotoFrame:
					a = decodeGotoFrame();
					break;
				
				case sactionGetURL:
					a = decodeGetURL();
					break;
				
				case sactionStoreRegister:
					a = decodeStoreRegister();
					break;
				
				case sactionConstantPool:
					a = decodeConstantPool();
					break;
				
				case sactionWaitForFrame:
					a = decodeWaitForFrame(opcode, factory);
					break;
				
				case sactionSetTarget:
					a = decodeSetTarget();
					break;
				
				case sactionGotoLabel:
					a = decodeGotoLabel();
					break;
				
				case sactionWaitForFrame2:
					a = decodeWaitForFrame(opcode, factory);
					break;
				
				case sactionGetURL2:
					a = decodeGetURL2();
					break;
				
				case sactionJump:
				case sactionIf:
					a = decodeBranch(opcode, factory);
					break;
				
				case sactionGotoFrame2:
					a = decodeGotoFrame2();
					break;
				
				default:
					a = decodeUnknown(opcode, len);
					break;
			}
			checkConsumed(pos, len, a);
			factory.setAction(offset, a);
		}
		
		private function decodeTry(factory:ActionFactory):Try
		{
			var a:Try = new Try();
			
			a.flags = reader.readUI8();
			var trySize:int = reader.readUI16();
			var catchSize:int = reader.readUI16();
			var finallySize:int = reader.readUI16();
			
			if (a.hasRegister())
				a.catchReg = reader.readUI8();
			else
				a.catchName = reader.readString();
			
			// we have now consumed the try action.  what follows is label mgmt
			
			var tryEnd:int = reader.getOffset() + trySize;
			a.endTry = factory.getLabel(tryEnd);
			
			// place the catchLabel to mark the end point of the catch handler
			if (a.hasCatch())
				a.endCatch = factory.getLabel(tryEnd + catchSize);
			
			// place the finallyLabel to mark the end point of the finally handler
			if (a.hasFinally())
				a.endFinally = factory.getLabel(tryEnd + finallySize + (a.hasCatch() ? catchSize : 0));
			
			return a;
		}
		
		private function decodeGotoFrame2():GotoFrame2
		{
			var a:GotoFrame2 = new GotoFrame2();
			a.playFlag = reader.readUI8();
			return a;
		}
		
		private function decodeBranch(code:int, factory:ActionFactory):Branch
		{
			var a:Branch = new Branch(code);
			var offset:int = reader.readSI16();
			var target:int = offset + reader.getOffset();
			a.target = factory.getLabel(target);
			return a;
		}
		
		private function decodeWaitForFrame(opcode:int, factory:ActionFactory):WaitForFrame
		{
			var a:WaitForFrame = new WaitForFrame(opcode);
			if (opcode == sactionWaitForFrame)
				a.frame = reader.readUI16();
			var skipCount:int = reader.readUI8();
			var skipTarget:int = actionCount+1 + skipCount;
			factory.addSkipEntry(a, skipTarget);
			return a;
		}
		
		private function decodeGetURL2():GetURL2
		{
			var a:GetURL2 = new GetURL2();
			a.method = reader.readUI8();
			return a;
		}
		
		private function decodeGotoLabel():GotoLabel
		{
			var a:GotoLabel = new GotoLabel();
			a.label = reader.readString();
			return a;
		}
		
		private function decodeSetTarget():SetTarget
		{
			var a:SetTarget = new SetTarget();
			a.targetName = reader.readString();
			return a;
		}
		
		private function decodeConstantPool():ConstantPool
		{
			var cpool:ConstantPool = new ConstantPool();
			var count:int = reader.readUI16();
			cpool.pool = new Vector.<String>(count);
			for (var i:int = 0; i < count; i++)
			{
				cpool.pool[i] = reader.readString();
			}
			return cpool;
		}
		
		private function decodeStoreRegister():StoreRegister
		{
			var register:int = reader.readUI8();
			return ActionFactory.createStoreRegister(register);
		}
		
		private function decodeGetURL():GetURL
		{
			var a:GetURL = new GetURL();
			a.url = reader.readString();
			a.target = reader.readString();
			return a;
		}
		
		private function decodeGotoFrame():GotoFrame
		{
			var a:GotoFrame = new GotoFrame();
			a.frame = reader.readUI16();
			return a;
		}
		
		private function decodeUnknown(opcode:int, length:int):Unknown
		{
			var a:Unknown = new Unknown(opcode);
			a.data = new ByteArray();
			a.data.length = length;
			reader.readFully(a.data);
			return a;
		}
		
		private function decodeStrictMode():StrictMode
		{
			var mode:Boolean = reader.readUI8() != 0;
			return ActionFactory.createStrictMode(mode);
		}
		
		private function decodePush(offset:int, end:int, factory:ActionFactory):Push
		{
			var p:Push;
			do
			{
				var pushType:int = reader.readUI8();
				var pNum:PushNum = new PushNum("",0);
				switch (pushType)
				{
					case ActionConstants.kPushStringType: // string
						p = ActionFactory.createPushString(reader.readString());
						break;
					case ActionConstants.kPushFloatType: // float
						//float fvalue = Float.intBitsToFloat((int) reader.readUI32());
						pNum.type == "Float";
						pNum.num = reader.readUI32();
						p = ActionFactory.createPushFloat(pNum); // value
						break;
					case ActionConstants.kPushNullType: // null
						p = ActionFactory.createPushNull();
						break;
					case ActionConstants.kPushUndefinedType: // undefined
						p = ActionFactory.createPushUndefined();
						break;
					case ActionConstants.kPushRegisterType: // register
						p = ActionFactory.createPushRegister(reader.readUI8());
						break;
					case ActionConstants.kPushBooleanType: // boolean
						p = ActionFactory.createPushBoolean(reader.readUI8() != 0);
						break;
					case ActionConstants.kPushDoubleType: // double
						// read two 32 bit little-endian values in big-endian order.  weird.
						/**
						long hx:Number = reader.readUI32();
						long lx:Number = reader.readUI32();
						p = ActionFactory.createPush(Double.longBitsToDouble((hx << 32) | (lx & 0xFFFFFFFFL)));
						 */
						var temp:ByteArray = new ByteArray();
						temp.endian = Endian.LITTLE_ENDIAN;
						var hx:uint = reader.readUI32();
						var lx:uint = reader.readUI32();
						temp.writeUnsignedInt(lx);
						temp.writeUnsignedInt(hx);
						temp.position = 0;
						p = ActionFactory.createPushDouble(new PushNum("Double", temp.readDouble()));
						break;
					case ActionConstants.kPushIntegerType: // integer
						p = ActionFactory.createPushInt(int(reader.readUI32()));
						break;
					case ActionConstants.kPushConstant8Type: // 8-bit cpool reference
						p = ActionFactory.createPushCpool(reader.readUI8());
						break;
					case ActionConstants.kPushConstant16Type: // 16-bit cpool reference
						p = ActionFactory.createPushCpool(reader.readUI16());
						break;
					default:
						throw new SWFFormatError("Unknown push data type "+pushType + " at offset: " + offset);
					//throw new SwfFormatException("Unknown push data type "+pushType);
				}
				factory.setAction(offset, p);
				offset = reader.getOffset();
			} while (offset < end);
			return p;
		}
		
		private function decodeDefineFunction(pos:int, len:int):DefineFunction
		{
			var a:DefineFunction = new DefineFunction(ActionConstants.sactionDefineFunction);
			a.name = reader.readString();
			var number:int = reader.readUI16();
			a.params = new Vector.<String>(number);
			
			for (var i:int = 0; i < number; i++)
			{
				a.params[i] = reader.readString();
			}
			
			a.codeSize = reader.readUI16();
			
			checkConsumed(pos, len, a);
			
			a.actionList = decode(a.codeSize);
			
			return a;
		}
		
		private function decodeDefineFunction2(pos:int, len:int):DefineFunction
		{
			var a:DefineFunction = new DefineFunction(ActionConstants.sactionDefineFunction2);
			a.name = reader.readString();
			var number:int = reader.readUI16();
			a.params = new Vector.<String>(number);
			a.paramReg = new Vector.<int>(number);
			
			a.regCount = reader.readUI8();
			a.flags = reader.readUI16();
			
			for (var i:int = 0; i < number; i++)
			{
				a.paramReg[i] = reader.readUI8();
				a.params[i] = reader.readString();
			}
			
			a.codeSize = reader.readUI16();
			
			checkConsumed(pos, len, a);
			
			a.actionList = decode(a.codeSize);
			
			return a;
		}
		
		private function checkConsumed(pos:int, len:int, a:Action):void
		{
			var consumed:int = reader.getOffset() - pos;
			if (consumed != len)
			{
				throw new SWFFormatError(a.toString() + ": " + consumed + " was read. " + len + " was required.");
				//throw new SwfFormatException(a.getClass().getName() + ": " + consumed + " was read. " + len + " was required.");
			}
		}
		
		private function decodeWith(factory:ActionFactory):With
		{
			var a:With = new With();
			var size:int = reader.readUI16();
			var target:int = size + reader.getOffset();
			a.endWith = factory.getLabel(target);
			return a;
		}
	}
}