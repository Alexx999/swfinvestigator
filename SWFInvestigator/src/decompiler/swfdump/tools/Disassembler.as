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

package decompiler.swfdump.tools
{
	import decompiler.Logging.ILog;
	import decompiler.swfdump.Action;
	import decompiler.swfdump.ActionConstants;
	import decompiler.swfdump.ActionHandler;
	import decompiler.swfdump.actions.Branch;
	import decompiler.swfdump.actions.ConstantPool;
	import decompiler.swfdump.actions.DefineFunction;
	import decompiler.swfdump.actions.GetURL;
	import decompiler.swfdump.actions.GetURL2;
	import decompiler.swfdump.actions.GotoFrame;
	import decompiler.swfdump.actions.GotoFrame2;
	import decompiler.swfdump.actions.GotoLabel;
	import decompiler.swfdump.actions.Label;
	import decompiler.swfdump.actions.Push;
	import decompiler.swfdump.actions.SetTarget;
	import decompiler.swfdump.actions.StoreRegister;
	import decompiler.swfdump.actions.StrictMode;
	import decompiler.swfdump.actions.Try;
	import decompiler.swfdump.actions.Unknown;
	import decompiler.swfdump.actions.WaitForFrame;
	import decompiler.swfdump.actions.With;
	import decompiler.swfdump.debug.DebugModule;
	import decompiler.swfdump.debug.LineRecord;
	import decompiler.swfdump.debug.RegisterRecord;
	import decompiler.swfdump.tools.LabelEntry;
	import decompiler.swfdump.tools.LabelMap;
	import decompiler.swfdump.types.ActionList;
	import decompiler.swfdump.types.PushNum;
	import decompiler.swfdump.util.FieldFormat;
	
	/**
	 * This utility supports printing AS2 byte codes.
	 *
	 * @author Edwin Smith
	 */
	
	public class Disassembler extends ActionHandler
	{
		protected var cpool:ConstantPool;
		protected var startPos:int;
		protected var offset:int;
		private var out:ILog;
		private var showOffset:Boolean = false;
		private var showDebugSource:Boolean = false;
		private var showLineRecord:Boolean = true;
		private var rRecord:RegisterRecord = null;
		private var indent:int;
		private var initialIndent:int;
		private var comment:String;
		private var format:String;
		
		private var labels:LabelMap = new LabelMap();
		public var labelCount:int = 0;
		
		public function Disassembler(log:ILog, cp:ConstantPool = null, cmnt:String = "", showOffset:Boolean = false, ind:int = 0)
		{
			this.out = log;
			this.cpool = cp;
			this.showOffset = showOffset;
			this.indent = ind;
			this.initialIndent = ind;
			this.comment = cmnt;
			
			//this.actionNames = new Vector.<String>;
			//initActionNames();
		}
		
		public function setComment(cmnt:String):void
		{
			this.comment = cmnt;
		}
		
		public function setFormat(fmt:String):void
		{
			this.format = fmt;
		}
		
		public function setShowDebugSource(b:Boolean):void
		{
			this.showDebugSource = b;
		}
		
		public function setShowLineRecord(b:Boolean):void
		{
			this.showLineRecord = b;
		}
		
		public function disassemble(list:ActionList, pool:ConstantPool, startIndex:int, endIndex:int, out:ILog):void
		{
			var d:Disassembler = new Disassembler(out, pool, "    ");
			d.setFormat("    0x%08O  %a"); 
			d.setShowLineRecord(false);
			
			// probe backward for a register record if any to set up register to variable name mapping
			var at:int = list.lastIndexOf(ActionList.sactionRegisterRecord, startIndex);
			if (at > -1)
				d.rRecord = list.getAction(at) as RegisterRecord;
			
			// now dump the contents of our request
			list.visit(d, startIndex, endIndex);
			//out.flush();
		}
		
		protected function print(action:Action):void
		{
			start(action);
			this.out.print("\r");
		}
		
		public override function setActionOffset(offset:int, a:Action):void
		{
			if (this.offset == 0)
			{
				this.startPos = offset;
			}
			this.offset = offset;
		}
		
		protected function doIndent():void
		{
			var i:int;
			for (i=0; i < this.initialIndent; i++)
				out.print("  ");
			out.print(comment);
			for (i=this.initialIndent; i < this.indent; i++)
				out.print("  ");
		}
		
		public override function registerRecord(record:RegisterRecord):void
		{
			// set the active record
			this.rRecord = record;
		}
		
		protected function variableNameForRegister(regNbr:int):String
		{
			var at:int = (this.rRecord == null) ? -1 : this.rRecord.indexOf(regNbr);
			if (at > -1)
				return this.rRecord.variableNames[at];
			else
				return null;
		}
		
		public override function lineRecord(line:LineRecord):void
		{
			if (!showLineRecord)
				return;
			else if (showDebugSource)
			{
				printLines(line, out);
			}
			else
			{
				start(line);
				out.print(" "+line.module.name +":"+line.lineno + "\r");
			}
		}
		
		public function printLines(lr:LineRecord, out:ILog):void
		{
			var script:DebugModule = lr.module;
			
			if (script != null)
			{
				var lineno:int = lr.lineno;
				if (lineno > 0)
				{
					while (lineno-1 > 0 && script.offsets[lineno-1] == 0)
					{
						lineno--;
					}
					if (lineno == 1)
					{
						doIndent();
						out.print(script.name + "/r");
					}
					var off:int = script.index[lineno-1];
					var len:int = script.index[lr.lineno] - off;
					//Fix? was out.write
					out.print(script.text, off, len);
				}
			}
		}
		
		protected function start(action:Action):void
		{
			var actionName:String;
			if ((action.code < 0) || (action.code > actionNames.length))
			{
				actionName = "Unknown";
			}
			else
			{
				actionName = actionNames[action.code];
			}
			
			if (showOffset)
			{
				doIndent();
				//out.print("absolute=" + offset + ",relative=" + (offset-this.startPos) +
				//	",code=" + action.code + "\t" + actionName);
				out.print(actionName);
			}
			else
			{
				if (format == null)
				{
					doIndent();
					out.print(actionName);
				}
				else 
				{
					startFormatted(actionName);
				}
			}
		}
		
		//revisit
		protected function startFormatted(action:String):void
		{
			var sb:String = new String();
			var leadingZeros:Boolean = false;
			var width:int = -1;
			
			for(var i:int=0; i<format.length; i++)
			{
				var c:String = format.charAt(i);
				if (c == '%')
				{
					c = format.charAt(++i);
					var cNum:Number = parseInt(c); 
					if (!isNaN(cNum) && cNum >=0 && cNum <= 9)
					{
						// absorb a leading zero, if any
						if (c == '0')
						{
							leadingZeros = true;
							c = format.charAt(++i);
						}
						
						var number:String = new String();
						cNum = parseInt(c);
						while(!isNaN(cNum) && cNum >= 0 && cNum <= 9)
						{
							number += c;
							c = format.charAt(++i);
							cNum = parseInt(c);
						}
						var temp:Number = parseInt(number);
						if (!isNaN(temp)) { 
							width = int(temp);
						} else {
							width = -1;
						}
					}
					
					if (c == 'O')
					{
						FieldFormat.formatLongToHex(sb, offset, width, leadingZeros);
					}
					else if (c == 'o')
					{
						FieldFormat.formatLong(sb, offset, width, leadingZeros);
					}
					else if (c == 'a')
					{
						sb += action.toString();
					}
				}
				else
					sb += c;
			}
			out.print( sb );
		}
		
		public override function nextFrame(action:Action):void
		{
			print(action);
		}
		
		public override function prevFrame(action:Action):void
		{
			print(action);
		}
		
		public override function play(action:Action):void
		{
			print(action);
		}
		
		public override function stop(action:Action):void
		{
			print(action);
		}
		
		public override function toggleQuality(action:Action):void
		{
			print(action);
		}
		
		public override function stopSounds(action:Action):void
		{
			print(action);
		}
		
		public override function add(action:Action):void
		{
			print(action);
		}
		
		public override function subtract(action:Action):void
		{
			print(action);
		}
		
		public override function multiply(action:Action):void
		{
			print(action);
		}
		
		public override function divide(action:Action):void
		{
			print(action);
		}
		
		public override function equalsAction(action:Action):void
		{
			print(action);
		}
		
		public override function less(action:Action):void
		{
			print(action);
		}
		
		public override function and(action:Action):void
		{
			print(action);
		}
		
		public override function or(action:Action):void
		{
			print(action);
		}
		
		public override function not(action:Action):void
		{
			print(action);
		}
		
		public override function stringEquals(action:Action):void
		{
			print(action);
		}
		
		public override function stringLength(action:Action):void
		{
			print(action);
		}
		
		public override function stringExtract(action:Action):void
		{
			print(action);
		}
		
		public override function pop(action:Action):void
		{
			print(action);
		}
		
		public override function toInteger(action:Action):void
		{
			print(action);
		}
		
		public override function getVariable(action:Action):void
		{
			print(action);
		}
		
		public override function setVariable(action:Action):void
		{
			print(action);
		}
		
		public override function setTarget2(action:Action):void
		{
			print(action);
		}
		
		public override function stringAdd(action:Action):void
		{
			print(action);
		}
		
		public override function getProperty(action:Action):void
		{
			print(action);
		}
		
		public override function setProperty(action:Action):void
		{
			print(action);
		}
		
		public override function cloneSprite(action:Action):void
		{
			print(action);
		}
		
		public override function removeSprite(action:Action):void
		{
			print(action);
		}
		
		//revisit
		public override function trace(action:Action):void
		{
			print(action);
		}
		
		public override function startDrag(action:Action):void
		{
			print(action);
		}
		
		public override function endDrag(action:Action):void
		{
			print(action);
		}
		
		public override function stringLess(action:Action):void
		{
			print(action);
		}
		
		public override function randomNumber(action:Action):void
		{
			print(action);
		}
		
		public override function mbStringLength(action:Action):void
		{
			print(action);
		}
		
		public override function charToASCII(action:Action):void
		{
			print(action);
		}
		
		public override function asciiToChar(action:Action):void
		{
			print(action);
		}
		
		public override function getTime(action:Action):void
		{
			print(action);
		}
		
		public override function mbStringExtract(action:Action):void
		{
			print(action);
		}
		
		public override function mbCharToASCII(action:Action):void
		{
			print(action);
		}
		
		public override function mbASCIIToChar(action:Action):void
		{
			print(action);
		}
		
		//revisit
		public override function deleteAction(action:Action):void
		{
			print(action);
		}
		
		public override function delete2(action:Action):void
		{
			print(action);
		}
		
		public override function defineLocal(action:Action):void
		{
			print(action);
		}
		
		public override function callFunction(action:Action):void
		{
			print(action);
		}
		
		public override function returnAction(action:Action):void
		{
			print(action);
		}
		
		public override function modulo(action:Action):void
		{
			print(action);
		}
		
		public override function newObject(action:Action):void
		{
			print(action);
		}
		
		public override function defineLocal2(action:Action):void
		{
			print(action);
		}
		
		public override function initArray(action:Action):void
		{
			print(action);
		}
		
		public override function initObject(action:Action):void
		{
			print(action);
		}
		
		public override function typeOf(action:Action):void
		{
			print(action);
		}
		
		public override function targetPath(action:Action):void
		{
			print(action);
		}
		
		public override function enumerate(action:Action):void
		{
			print(action);
		}
		
		public override function add2(action:Action):void
		{
			print(action);
		}
		
		public override function less2(action:Action):void
		{
			print(action);
		}
		
		public override function equals2(action:Action):void
		{
			print(action);
		}
		
		public override function toNumber(action:Action):void
		{
			print(action);
		}
		
		public override function toStringAction(action:Action):void
		{
			print(action);
		}
		
		public override function pushDuplicate(action:Action):void
		{
			print(action);
		}
		
		public override function stackSwap(action:Action):void
		{
			print(action);
		}
		
		public override function getMember(action:Action):void
		{
			print(action);
		}
		
		public override function setMember(action:Action):void
		{
			print(action);
		}
		
		public override function increment(action:Action):void
		{
			print(action);
		}
		
		public override function decrement(action:Action):void
		{
			print(action);
		}
		
		public override function callMethod(action:Action):void
		{
			print(action);
		}
		
		public override function newMethod(action:Action):void
		{
			print(action);
		}
		
		public override function instanceOf(action:Action):void
		{
			print(action);
		} // only if object model enabled
		
		public override function enumerate2(action:Action):void
		{
			print(action);
		}
		
		public override function bitAnd(action:Action):void
		{
			print(action);
		}
		
		public override function bitOr(action:Action):void
		{
			print(action);
		}
		
		public override function bitXor(action:Action):void
		{
			print(action);
		}
		
		public override function bitLShift(action:Action):void
		{
			print(action);
		}
		
		public override function bitRShift(action:Action):void
		{
			print(action);
		}
		
		public override function bitURShift(action:Action):void
		{
			print(action);
		}
		
		public override function strictEquals(action:Action):void
		{
			print(action);
		}
		
		public override function greater(action:Action):void
		{
			print(action);
		}
		
		public override function stringGreater(action:Action):void
		{
			print(action);
		}
		
		public override function gotoFrame(action:GotoFrame):void
		{
			start(action);
			out.print(" " + action.frame + "\r");
		}
		
		public override function getURL(action:GetURL):void
		{
			start(action);
			out.print(" " + action.url + " " + action.target + "\r");
		}
		
		public override function storeRegister(action:StoreRegister):void
		{
			start(action);
			var variableName:String = variableNameForRegister(action.register);
			out.print(" $" + action.register + ((variableName == null) ? "" : "   \t\t; "+variableName) + "\r");
		}
		
		public override function constantPool(action:ConstantPool):void
		{
			cpool = action;
			start(action);
			out.print(" [" + action.pool.length +"]\r");
			for (var i:int = 0; i < action.pool.length; i++) {
				out.print("    " + i + ": " + action.pool[i] + "\r");
			}
			out.print("\r");
		}
		
		public override function strictMode(action:StrictMode):void
		{
			print(action);
		}
		
		public override function waitForFrame(action:WaitForFrame):void
		{
			start(action);
			out.print(" " + action.frame + " {\r");
			this.indent++;
			labels.getLabelEntry(action.skipTarget).source = action;
		}
		
		public override function setTarget(action:SetTarget):void
		{
			start(action);
			out.print(" " + action.targetName + "\r");
		}
		
		public override function gotoLabel(action:GotoLabel):void
		{
			start(action);
			out.print(" " + action.label + "\r");
		}
		
		public override function waitForFrame2(action:WaitForFrame):void
		{
			start(action);
			out.print(" {\r");
			this.indent++;
			labels.getLabelEntry(action.skipTarget).source = action;
		}
		
		//revisit
		public override function WithAction(action:With):void
		{
			start(action);
			out.print(" {\r");
			this.indent++;
			labels.getLabelEntry(action.endWith).source = action;
		}
		
		public override function tryAction(action:Try):void
		{
			start(action);
			out.print(" {\r");
			this.indent++;
			
			labels.getLabelEntry(action.endTry).source = action;
			if (action.hasCatch())
				labels.getLabelEntry(action.endCatch).source = action;
			if (action.hasFinally())
				labels.getLabelEntry(action.endFinally).source = action;
		}
		
		public override function throwAction(action:Action):void
		{
			print(action);
		}
		
		public override function castOp(action:Action):void
		{
			print(action);
		}
		
		public override function implementsOp(action:Action):void
		{
			print(action);
		}
		
		public override function extendsOp(action:Action):void
		{
			print(action);
		}
		
		public override function nop(action:Action):void
		{
			print(action);
		}
		
		public override function halt(action:Action):void
		{
			print(action);
		}
		
		//revisit
		public override function push(action:Push):void
		{
			start(action);
			out.print(" ");
			var value:* = action.value;
			var type:int = Push.getTypeCode(value);
			var valAsInt:uint;
			if (value is PushNum) {
				valAsInt = uint(value.num);
			} else {
				valAsInt = uint(value as Number);
			}
			switch (type)
			{
				case ActionConstants.kPushStringType:
					out.print(quoteString(value.toString(),'"'));
					break;
				case ActionConstants.kPushNullType:
					out.print("null");
					break;
				case ActionConstants.kPushUndefinedType:
					out.print("undefined");
					break;
				case ActionConstants.kPushRegisterType:
					var variableName:String = variableNameForRegister( (valAsInt &0xFF) );
					out.print("$" + (valAsInt&0xFF) + ((variableName == null) ? "" : "   \t\t; "+variableName) );
					break;
				case ActionConstants.kPushConstant8Type:
				case ActionConstants.kPushConstant16Type:
					var index:int = int(value.num) &0xFFFF;
					out.print( ((cpool == null || (cpool!=null && index > cpool.pool.length)) ? index.toString() : quoteString(cpool.pool[index],'\'')) );
					break;
				case ActionConstants.kPushFloatType:
					out.print(value + "F");
					break;
				case ActionConstants.kPushDoubleType:
					out.print(value.num.toString());
					break;
				case ActionConstants.kPushBooleanType:
				case ActionConstants.kPushIntegerType:
					out.print(value.toString());
					break;
				default:
				//assert (false);
			}
			out.print("\r");
		}
		
		public override function getURL2(action:GetURL2):void
		{
			start(action);
			out.print(" " + action.method + "\r");
		}
		
		public override function defineFunction(action:DefineFunction):void
		{
			start(action);
			out.print(" " + action.name + "(");
			for (var i:int = 0; i < action.params.length; i++)
			{
				out.print(action.params[i]);
				if (i + 1 < action.params.length)
				{
					out.print(", ");
				}
			}
			out.print(") {\r");
			this.indent++;
			action.actionList.visitAll(this);
			this.indent--;
			doIndent();
			out.print("} //end " + action.name + "\r");
		}
		
		public override function defineFunction2(action:DefineFunction):void
		{
			start(action);
			out.print(" " + action.name + "(");
			for (var i:int = 0; i < action.params.length; i++)
			{
				out.print("$"+action.paramReg[i]+"="+action.params[i]);
				if (i + 1 < action.params.length)
				{
					out.print(", ");
				}
			}
			out.print(")");
			var regno:int = 1;
			if ((action.flags & DefineFunction.kPreloadThis) != 0)
				out.print(" $"+(regno++)+"=this");
			if ((action.flags & DefineFunction.kPreloadArguments) != 0)
				out.print(" $"+(regno++)+"=arguments");
			if ((action.flags & DefineFunction.kPreloadSuper) != 0)
				out.print(" $"+(regno++)+"=super");
			if ((action.flags & DefineFunction.kPreloadRoot) != 0)
				out.print(" $"+(regno++)+"=_root");
			if ((action.flags & DefineFunction.kPreloadParent) != 0)
				out.print(" $"+(regno++)+"=_parent");
			if ((action.flags & DefineFunction.kPreloadGlobal) != 0)
				out.print(" $"+(regno)+"=_global");
			out.print(" {\r");
			this.indent+=2;
			action.actionList.visitAll(this);
			this.indent-=2;
			doIndent();
			out.print("} " + action.name + "\r\r");
		}
		
		public override function ifAction(action:Branch):void
		{
			printBranch(action);
		}
		
		public override function jump(action:Branch):void
		{
			printBranch(action);
		}
		
		protected function printBranch(action:Branch):void
		{
			start(action);
			var entry:LabelEntry = labels.getLabelEntry(action.target);
			if (entry.name == null) {
				labelCount++;
				entry.name = "L"+ labelCount.toString();
			}
			entry.source = action;
			out.print(" " + entry.name + "\r");
		}
		
		public override function label(l:Label):void
		{
			var entry:LabelEntry = labels.getLabelEntry(l);
			if (entry.source == null)
			{
				// have not seen any actions that target this label yet, and that
				// means the source can only be a backwards branch
				labelCount++;
				entry.name = "L"+labelCount.toString();
				doIndent();
				out.print(entry.name + ":\r");
			}
			else
			{
				switch (entry.source.code)
				{
					case ActionConstants.sactionTry:
						var t:Try = entry.source as Try;
						this.indent--;
						doIndent();
						out.print("}\r");
						doIndent();
						if (l == t.endTry && t.hasCatch())
						{
							out.print("catch("+
								(t.hasRegister()?"$"+t.catchReg:t.catchName) +
								") {\r");
							this.indent++;
						}
						else if ((l == t.endTry || l == t.endCatch) && t.hasFinally())
						{
							out.print("finally {\r");
							this.indent++;
						}
						break;
					case ActionConstants.sactionWaitForFrame:
					case ActionConstants.sactionWaitForFrame2:
					case ActionConstants.sactionWith:
						// end of block
						this.indent--;
						doIndent();
						out.print("}\r");
						break;
					case ActionConstants.sactionIf:
					case ActionConstants.sactionJump:
						doIndent();
						out.print(entry.name + ":" + "\r");
						break;
					default:
						//assert (false);
						break;
				}
			}
		}
		
		public override function call(action:Action):void
		{
			print(action);
		}
		
		public override function gotoFrame2(action:GotoFrame2):void
		{
			start(action);
			out.print(" " + action.playFlag + "\r");
		}
		
		public override function quickTime(action:Action):void
		{
			print(action);
		}
		
		public override function unknown(action:Unknown):void
		{
			print(action);
		}
		
		
		public static function quoteString(s:String, qc:String):String
		{
			var b:String = new String();
			
			b += qc;
			for (var i:int=0; i < s.length; i++)
			{
				var c:String = s.charAt(i);
				switch (c)
				{
					case 8: b += "\\v"; break;
					case '\f' : b += "\\f"; break;
					case '\r' : b += "\\r"; break;
					case '\t' : b += "\\t"; break;
					case '\n' : b += "\\n"; break;
					case '"' : b += "\\\""; break;
					case '\'' : b += "\\'"; break;
					default: b += c; break;
				}
			}
			b += qc;
			return (b);
		}
		
		
//		private function initActionNames():void {
//		  this.actionNames.push(
		public var actionNames:Vector.<String> = new <String>["0x00",
			"0x01",
			"0x02",
			"0x03",
			"nextFrame", // sactionNextFrame
			"prevFrame", // sactionPrevFrame
			"play", // sactionPlay
			"stop", // sactionStop
			"toggleQuality", // sactionToggleQuality
			"stopSounds", // sactionStopSounds
			"add", // sactionAdd
			"sub", // sactionSubtract
			"mul", // sactionMultiply
			"div", // sactionDivide
			"eq",  // sactionEquals
			"lt",  // sactionLess
			"and",  // sactionAnd
			"or",   // sactionOr
			"not",  // sactionNot
			"stringEquals",  // sactionStringEquals
			"stringLen", // sactionStringLength
			"substr", // sactionStringExtract
			"0x16",
			"pop",  // sactionPop
			"toInt", // sactionToInteger
			"0x19",
			"0x1A",
			"0x1B",
			"getVariable", // sactionGetVariable
			"setVariable", // sactionGetVariable
			"0x1E",
			"0x1F",
			"settarget2", //sactionSetTarget2
			"stringAdd",     // sactionStringAdd
			"getProp",     // sactionGetProperty
			"setProp",     // sactoinSetProperty
			"cloneSprite",  // sactionCloneSprite
			"removeSprite",  // sactionRemoveSprite
			"trace",    // sactionTrace
			"startDrag",    // sactionStartDrag
			"endDrag",    // sactionEndDragg
			"stringlt",      // sactionStringLess
			"0x2A",
			"0x2B",
			"0x2C",
			"0x2D",
			"0x2E",
			"0x2F",
			"randomNumber", // sactionRandomNumber
			"wslen", // sactionMbStringLength
			"char2ascii",  // sactionCharToAscii
			"ascii2char",  // sactionAscii2Char
			"time",  // sactionGetTime
			"wsubstr",  // sactionMBStringExtract
			"wc2a",   // sactionMbCharToAscii
			"wa2c",  // sactionMbAsciiToChar
			"0x38",
			"0x39",
			"del",   // sactionDelete
			"del2",   // sactionDelete2
			"defineLocal",  // sactionDefineLoc
			"callFunction",  // sactionCallFunction
			"return",  // sactionReturn
			"mod",   // sactionMod
			"newobj",    // sactionNewObject
			"defineLocal2",   // sactionDefineLocal2
			"initarr",     // sactionInitArray
			"initobj",    // sactionInitObject
			"typeof",   // sactionTypeOf
			"targetPath",    // sactionTargetPath
			"enum",     // sactionEnumerate
			"add2",     // sactionAdd2
			"lt2",      // sactionLess2
			"eq2",      // sactionEquals2
			"toNumber",    // sactionToNumber
			"toString",    // sactionToString
			"pushDuplicate",      // sactionPushDuplicate
			"stackSwap",     // sactionStackSwap
			"getMember",     // sactionGetMember
			"setMember",     // sactionSetMember
			"increment",      // sactionIncrement
			"decrement",      // sactionDecrement
			"callMethod",    // sactionCallMethod
			"newMethod",     // sactionNewMethod
			"instanceof",   // sactionInstanceOf
			"enum2",    // sactionEnumerate2
			"0x56",
			"0x57",
			"0x58",
			"0x59",
			"0x5A",
			"0x5B",
			"0x5C",
			"0x5D",
			"0x5E",
			"halt",     // sactionHalt
			"bitAnd",     // sactionBitAnd
			"bitOr",      // sactionBitOr
			"bitXor",     // sactionBitXor
			"bitLShift",      // sactionBitLShift
			"bitRShift",      // sactionBitRShift
			"bitURShift",     // sactionBitURShift
			"strictEquals",      // sactionStrictEquals
			"gt",       // sactionGreater
			"stringgt",      // sactionStringGreater
			"extends",  // sactionExtends
			"0x6A",
			"0x6B",
			"0x6C",
			"0x6D",
			"0x6E",
			"0x6F",
			"0x70",
			"0x71",
			"0x72",
			"0x73",
			"0x74",
			"0x75",
			"0x76",
			"nop",      // sactionNop
			"0x78",
			"0x79",
			"0x7A",
			"0x7B",
			"0x7C",
			"0x7D",
			"0x7E",
			"0x7F",
			"0x80",
			"gotoframe",    // sactionGotoFrame
			"0x82",
			"geturl",   // sactionGetUrl
			"0x84",
			"0x85",
			"0x86",
			"store",    // sactionStoreRegister
			"cpool",    // sactionConstantPool
			"strict",   // sactionStrictMode
			"waitForFrame",     // sactionWaitForFrame
			"setTarget",     // sactionSetTarget
			"goToLabel",    // sactoinGotoLabel
			"waitForFrame2",    // sactionWaitForFrame2
			"function2",    // sactionDefineFunction2
			"try",		// sactionTry
			"0x90",
			"0x91",
			"0x92",
			"0x93",
			"with",     // sactionWith
			"0x95",
			"push",     // sactionPush
			"0x97",
			"0x98",
			"jump",     // sactionJump
			"geturl2",  // sactionGetUrl2
			"defineFunction",     // sactionDefineFunction
			"0x9C",
			"if",       // sactionIf
			"call",     // sactionCall
			"gotoFrame2",   // sactionGotoFrame2
			"0xA0",
			"0xA1",
			"0xA2",
			"0xA3",
			"0xA4",
			"0xA5",
			"0xA6",
			"0xA7",
			"0xA8",
			"0xA9",
			"quicktime",       // sactionQuickTime
			"0xAB",
			"0xAC",
			"0xAD",
			"0xAE",
			"0xAF",
			"0xB0",
			"0xB1",
			"0xB2",
			"0xB3",
			"0xB4",
			"0xB5",
			"0xB6",
			"0xB7",
			"0xB8",
			"0xB9",
			"0xBA",
			"0xBB",
			"0xBC",
			"0xBD",
			"0xBE",
			"0xBF",
			"0xC0",
			"0xC1",
			"0xC2",
			"0xC3",
			"0xC4",
			"0xC5",
			"0xC6",
			"0xC7",
			"0xC8",
			"0xC9",
			"0xCA",
			"0xCB",
			"0xCC",
			"0xCD",
			"0xCE",
			"0xCF",
			"0xD0",
			"0xD1",
			"0xD2",
			"0xD3",
			"0xD4",
			"0xD5",
			"0xD6",
			"0xD7",
			"0xD8",
			"0xD9",
			"0xDA",
			"0xDB",
			"0xDC",
			"0xDD",
			"0xDE",
			"0xDF",
			"0xE0",
			"0xE1",
			"0xE2",
			"0xE3",
			"0xE4",
			"0xE5",
			"0xE6",
			"0xE7",
			"0xE8",
			"0xE9",
			"0xEA",
			"0xEB",
			"0xEC",
			"0xED",
			"0xEE",
			"0xEF",
			"0xF0",
			"0xF1",
			"0xF2",
			"0xF3",
			"0xF4",
			"0xF5",
			"0xF6",
			"0xF7",
			"0xF8",
			"0xF9",
			"0xFA",
			"0xFB",
			"0xFC",
			"0xFD",
			"0xFE",
			"0xFF",
			"label",
			"line"];
		//}
	}
}