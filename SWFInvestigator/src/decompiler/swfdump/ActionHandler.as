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
//Copied from http://opensource.adobe.com/svn/opensource/flex/sdk/trunk/modules/swfutils/src/java/flash/swf/ActionHandler.java

package decompiler.swfdump {
	
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
	import decompiler.swfdump.debug.LineRecord;
	import decompiler.swfdump.debug.RegisterRecord;
	
	/**
	 * Defines the AS2 visitor API.
	 *
	 * @author Clement Wong
	 */
	public class ActionHandler
	{
		/**
		 * called before visiting each action, to indicate the offset of this
		 * action from the start of the SWF file.
		 * @param offset
		 */
		public function setActionOffset(offset:int, a:Action):void
		{
		}
		
		public function nextFrame(action:Action):void
		{
		}
		
		public function prevFrame(action:Action):void
		{
		}
		
		public function play(action:Action):void
		{
		}
		
		public function stop(action:Action):void
		{
		}
		
		public function toggleQuality(action:Action):void
		{
		}
		
		public function stopSounds(action:Action):void
		{
		}
		
		public function add(action:Action):void
		{
		}
		
		public function subtract(action:Action):void
		{
		}
		
		public function multiply(action:Action):void
		{
		}
		
		public function divide(action:Action):void
		{
		}
		
		//Changed by SWF Investigator
		public function equalsAction(action:Action):void
		{
		}
		
		public function less(action:Action):void
		{
		}
		
		public function and(action:Action):void
		{
		}
		
		public function or(action:Action):void
		{
		}
		
		public function not(action:Action):void
		{
		}
		
		public function stringEquals(action:Action):void
		{
		}
		
		public function stringLength(action:Action):void
		{
		}
		
		public function stringExtract(action:Action):void
		{
		}
		
		public function pop(action:Action):void
		{
		}
		
		public function toInteger(action:Action):void
		{
		}
		
		public function getVariable(action:Action):void
		{
		}
		
		public function setVariable(action:Action):void
		{
		}
		
		public function setTarget2(action:Action):void
		{
		}
		
		public function stringAdd(action:Action):void
		{
		}
		
		public function getProperty(action:Action):void
		{
		}
		
		public function setProperty(action:Action):void
		{
		}
		
		public function cloneSprite(action:Action):void
		{
		}
		
		public function removeSprite(action:Action):void
		{
		}
		
		public function trace(action:Action):void
		{
		}
		
		public function startDrag(action:Action):void
		{
		}
		
		public function endDrag(action:Action):void
		{
		}
		
		public function stringLess(action:Action):void
		{
		}
		
		public function randomNumber(action:Action):void
		{
		}
		
		public function mbStringLength(action:Action):void
		{
		}
		
		public function charToASCII(action:Action):void
		{
		}
		
		public function asciiToChar(action:Action):void
		{
		}
		
		public function getTime(action:Action):void
		{
		}
		
		public function mbStringExtract(action:Action):void
		{
		}
		
		public function mbCharToASCII(action:Action):void
		{
		}
		
		public function mbASCIIToChar(action:Action):void
		{
		}
		
		//Changed bySWF Investigator
		public function deleteAction(action:Action):void
		{
		}
		
		public function delete2(action:Action):void
		{
		}
		
		public function defineLocal(action:Action):void
		{
		}
		
		public function callFunction(action:Action):void
		{
		}
		
		public function returnAction(action:Action):void
		{
		}
		
		public function modulo(action:Action):void
		{
		}
		
		public function newObject(action:Action):void
		{
		}
		
		public function defineLocal2(action:Action):void
		{
		}
		
		public function initArray(action:Action):void
		{
		}
		
		public function initObject(action:Action):void
		{
		}
		
		public function typeOf(action:Action):void
		{
		}
		
		public function targetPath(action:Action):void
		{
		}
		
		public function enumerate(action:Action):void
		{
		}
		
		public function add2(action:Action):void
		{
		}
		
		public function less2(action:Action):void
		{
		}
		
		public function equals2(action:Action):void
		{
		}
		
		public function toNumber(action:Action):void
		{
		}
		
		//Changed by SWF Investigator
		public function toStringAction(action:Action):void
		{
		}
		
		public function pushDuplicate(action:Action):void
		{
		}
		
		public function stackSwap(action:Action):void
		{
		}
		
		public function getMember(action:Action):void
		{
		}
		
		public function setMember(action:Action):void
		{
		}
		
		public function increment(action:Action):void
		{
		}
		
		public function decrement(action:Action):void
		{
		}
		
		public function callMethod(action:Action):void
		{
		}
		
		public function newMethod(action:Action):void
		{
		}
		
		public function instanceOf(action:Action):void
		{
		}
		
		public function enumerate2(action:Action):void
		{
		}
		
		public function bitAnd(action:Action):void
		{
		}
		
		public function bitOr(action:Action):void
		{
		}
		
		public function bitXor(action:Action):void
		{
		}
		
		public function bitLShift(action:Action):void
		{
		}
		
		public function bitRShift(action:Action):void
		{
		}
		
		public function bitURShift(action:Action):void
		{
		}
		
		public function strictEquals(action:Action):void
		{
		}
		
		public function greater(action:Action):void
		{
		}
		
		public function stringGreater(action:Action):void
		{
		}
		
		public function gotoFrame(action:GotoFrame):void
		{
		}
		
		public function getURL(action:GetURL):void
		{
		}
		
		public function storeRegister(action:StoreRegister):void
		{
		}
		
		public function constantPool(action:ConstantPool):void
		{
		}
		
		public function strictMode(action:StrictMode):void
		{
		}
		
		public function waitForFrame(action:WaitForFrame):void
		{
		}
		
		public function setTarget(action:SetTarget):void
		{
		}
		
		public function gotoLabel(action:GotoLabel):void
		{
		}
		
		public function waitForFrame2(action:WaitForFrame):void
		{
		}
		
		//Changed by SWF Investigator
		public function WithAction(action:With):void
		{
		}
		
		public function push(action:Push):void
		{
		}
		
		public function jump(action:Branch):void
		{
		}
		
		public function getURL2(action:GetURL2):void
		{
		}
		
		public function defineFunction(action:DefineFunction):void
		{
		}
		
		public function defineFunction2(action:DefineFunction):void
		{
		}
		
		public function ifAction(action:Branch):void
		{
		}
		
		public function label(label:Label):void
		{
		}
		
		public function call(action:Action):void
		{
		}
		
		public function gotoFrame2(action:GotoFrame2):void
		{
		}
		
		public function quickTime(action:Action):void
		{
		}
		
		public function unknown(action:Unknown):void
		{
		}
		
		public function tryAction(aTry:Try):void
		{
		}
		
		public function throwAction(aThrow:Action):void
		{
		}
		
		public function castOp(action:Action):void
		{
		}
		
		public function implementsOp(action:Action):void
		{
		}
		
		
		public function lineRecord(line:LineRecord):void
		{
		}
		
		public function registerRecord(line:RegisterRecord):void
		{
		}
		
		
		public function extendsOp(action:Action):void
		{
		}
		
		public function nop(action:Action):void
		{
		}
		
		public function halt(action:Action):void
		{
		}
	
	}
}