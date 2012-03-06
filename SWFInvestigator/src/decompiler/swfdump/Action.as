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
	import decompiler.swfdump.SWFFormatError;
	import decompiler.swfdump.ActionConstants;
	import decompiler.swfdump.ActionHandler;
	
	import flash.utils.getQualifiedClassName;
	
	public class Action
	{
		public var code:int;
		
		public function Action(code:int)
		{
			this.code = code;
		}
		
		/**
		 * Subclasses implement this method to callback one of the methods in ActionHandler...
		 * @param h
		 */
		public function visit(h:ActionHandler):void
		{
			switch (this.code)
			{
				case (ActionConstants.sactionNextFrame): h.nextFrame(this); break;
				case (ActionConstants.sactionPrevFrame): h.prevFrame(this); break;
				case (ActionConstants.sactionPlay): h.play(this); break;
				case (ActionConstants.sactionStop): h.stop(this); break;
				case (ActionConstants.sactionToggleQuality): h.toggleQuality(this); break;
				case (ActionConstants.sactionStopSounds): h.stopSounds(this); break;
				case (ActionConstants.sactionAdd): h.add(this); break;
				case (ActionConstants.sactionSubtract): h.subtract(this); break;
				case (ActionConstants.sactionMultiply): h.multiply(this); break;
				case (ActionConstants.sactionDivide): h.divide(this); break;
				case (ActionConstants.sactionEquals): h.equalsAction(this); break;
				case (ActionConstants.sactionLess): h.less(this); break;
				case (ActionConstants.sactionAnd): h.and(this); break;
				case (ActionConstants.sactionOr): h.or(this); break;
				case (ActionConstants.sactionNot): h.not(this); break;
				case (ActionConstants.sactionStringEquals): h.stringEquals(this); break;
				case (ActionConstants.sactionStringLength): h.stringLength(this); break;
				case (ActionConstants.sactionStringExtract): h.stringExtract(this); break;
				case (ActionConstants.sactionPop): h.pop(this); break;
				case (ActionConstants.sactionToInteger): h.toInteger(this); break;
				case (ActionConstants.sactionGetVariable): h.getVariable(this); break;
				case (ActionConstants.sactionSetVariable): h.setVariable(this); break;
				case (ActionConstants.sactionSetTarget2): h.setTarget2(this); break;
				case (ActionConstants.sactionStringAdd): h.stringAdd(this); break;
				case (ActionConstants.sactionGetProperty): h.getProperty(this); break;
				case (ActionConstants.sactionSetProperty): h.setProperty(this); break;
				case (ActionConstants.sactionCloneSprite): h.cloneSprite(this); break;
				case (ActionConstants.sactionRemoveSprite): h.removeSprite(this); break;
				case (ActionConstants.sactionTrace): h.trace(this); break;
				case (ActionConstants.sactionStartDrag): h.startDrag(this); break;
				case (ActionConstants.sactionEndDrag): h.endDrag(this); break;
				case (ActionConstants.sactionStringLess): h.stringLess(this); break;
				case (ActionConstants.sactionThrow): h.throwAction(this); break;
				case (ActionConstants.sactionCastOp): h.castOp(this); break;
				case (ActionConstants.sactionImplementsOp): h.implementsOp(this); break;
				case (ActionConstants.sactionRandomNumber): h.randomNumber(this); break;
				case (ActionConstants.sactionMBStringLength): h.mbStringLength(this); break;
				case (ActionConstants.sactionCharToAscii): h.charToASCII(this); break;
				case (ActionConstants.sactionAsciiToChar): h.asciiToChar(this); break;
				case (ActionConstants.sactionGetTime): h.getTime(this); break;
				case (ActionConstants.sactionMBStringExtract): h.mbStringExtract(this); break;
				case (ActionConstants.sactionMBCharToAscii): h.mbCharToASCII(this); break;
				case (ActionConstants.sactionMBAsciiToChar): h.mbASCIIToChar(this); break;
				case (ActionConstants.sactionDelete): h.deleteAction(this); break;
				case (ActionConstants.sactionDelete2): h.delete2(this); break;
				case (ActionConstants.sactionDefineLocal): h.defineLocal(this); break;
				case (ActionConstants.sactionCallFunction): h.callFunction(this); break;
				case (ActionConstants.sactionReturn): h.returnAction(this); break;
				case (ActionConstants.sactionModulo): h.modulo(this); break;
				case (ActionConstants.sactionNewObject): h.newObject(this); break;
				case (ActionConstants.sactionDefineLocal2): h.defineLocal2(this); break;
				case (ActionConstants.sactionInitArray): h.initArray(this); break;
				case (ActionConstants.sactionInitObject): h.initObject(this); break;
				case (ActionConstants.sactionTypeOf): h.typeOf(this); break;
				case (ActionConstants.sactionTargetPath): h.targetPath(this); break;
				case (ActionConstants.sactionEnumerate): h.enumerate(this); break;
				case (ActionConstants.sactionAdd2): h.add2(this); break;
				case (ActionConstants.sactionLess2): h.less2(this); break;
				case (ActionConstants.sactionEquals2): h.equals2(this); break;
				case (ActionConstants.sactionToNumber): h.toNumber(this); break;
				case (ActionConstants.sactionToString): h.toStringAction(this); break;
				case (ActionConstants.sactionPushDuplicate): h.pushDuplicate(this); break;
				case (ActionConstants.sactionStackSwap): h.stackSwap(this); break;
				case (ActionConstants.sactionGetMember): h.getMember(this); break;
				case (ActionConstants.sactionSetMember): h.setMember(this); break;
				case (ActionConstants.sactionIncrement): h.increment(this); break;
				case (ActionConstants.sactionDecrement): h.decrement(this); break;
				case (ActionConstants.sactionCallMethod): h.callMethod(this); break;
				case (ActionConstants.sactionNewMethod): h.newMethod(this); break;
				case (ActionConstants.sactionInstanceOf): h.instanceOf(this); break;
				case (ActionConstants.sactionEnumerate2): h.enumerate2(this); break;
				case (ActionConstants.sactionBitAnd): h.bitAnd(this); break;
				case (ActionConstants.sactionBitOr): h.bitOr(this); break;
				case (ActionConstants.sactionBitXor): h.bitXor(this); break;
				case (ActionConstants.sactionBitLShift): h.bitLShift(this); break;
				case (ActionConstants.sactionBitRShift): h.bitRShift(this); break;
				case (ActionConstants.sactionBitURShift): h.bitURShift(this); break;
				case (ActionConstants.sactionStrictEquals): h.strictEquals(this); break;
				case (ActionConstants.sactionGreater): h.greater(this); break;
				case (ActionConstants.sactionStringGreater): h.stringGreater(this); break;
				case (ActionConstants.sactionCall): h.call(this); break;
				case (ActionConstants.sactionQuickTime): h.quickTime(this); break;
				case (ActionConstants.sactionExtends): h.extendsOp(this); break;
				case (ActionConstants.sactionNop): h.nop(this); break;
				case (ActionConstants.sactionHalt): h.halt(this); break;
				default:
					throw new SWFFormatError("unexpected action "+code);
					//assert false : ("unexpected action "+code);// should not get here
			}
		}
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is Action)
			{
				var action:Action = object as Action;
				
				if (action.code == this.code)
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
		public function objectEquals(a:*, b:*):Boolean
		{
			return a == b || a != null && a.equals(b);
		}
		
		public function hashCode():int
		{
			return this.code;
		}
		
		public function objectHashCode():int
		{
			return super.hashCode();
		}
		
		public function toString():String
		{
			return (getQualifiedClassName(this) + "[ code = " + this.code + " ]");
		}
		
	}
}