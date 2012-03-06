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

package decompiler.swfdump.types
{
	import decompiler.swfdump.Action;
	import decompiler.swfdump.ActionHandler;
	
	public class ActionList extends ActionHandler
	{
		// start numbering internal opcodes at 256 to make sure we wont
		// collide with a real player opcode.  player opcodes are 8-bit.
		public static const sactionLabel:int = 256;
		public static const sactionLineRecord:int = 257;
		public static const sactionRegisterRecord:int = 258
			
		private var offsets:Vector.<int>;
		private var actions:Vector.<Action>;
		private var listSize:int;

		
		public function ActionList(keepOffsets:Boolean = false, capacity:int = 10) {
			if (keepOffsets) {
				this.offsets = new Vector.<int>(capacity);
			}
			
			this.actions = new Vector.<Action>(capacity);
			this.listSize = 0;
		}
		
		public function equals(object:*):Boolean {
			if (object is ActionList) {
				var actionList:ActionList = object as ActionList;
				
				if (this.actions.length != actionList.actions.length) {
					return (false);
				}
				
				for (var i:int = 0; i < this.actions.length; i++) {
					if (this.actions[i].equals(actionList.actions[i]) != true) {
						return (false);
					}
				}
				
				return (true);
			}
			
			return (false);
		}
		
		public function visitAll(handler:ActionHandler):void {
			visit (handler, 0, this.listSize -1);
		}
		
		public function visit(handler:ActionHandler, startIndex:int, endIndex:int):void {
			endIndex = (endIndex < 0) ? this.listSize-1: endIndex;
			
			for (var j:int = startIndex; j <= endIndex; j++) {
				var a:Action = this.actions[j];
				
				if (a.code != ActionList.sactionLabel && a.code != ActionList.sactionLineRecord) {
					if (offsets != null) {
						handler.setActionOffset(offsets[j],a);
					} else {
						handler.setActionOffset(j,a);
					}
				}
				
				a.visit(handler);
			}
		}
		
		public override function setActionOffset(offset:int, a:Action):void {
			insert(offset,a);
		}
		
		public function grow (capacity:int):void {
			if (this.offsets != null) {
				var newoffsets:Vector.<int> = new Vector.<int>(capacity);
				this.offsets = newoffsets.concat(offsets);
			}
			
			var newactions:Vector.<Action> = new Vector.<Action>(capacity);
			this.actions = newactions.concat(this.actions);	
		}
		
		public function size():int {
			return (this.listSize);
		}
		
		public function getAction(i:int):Action {
			return (this.actions[i]);
		}
		
		public function getOffset(i:int):int {
			return (this.offsets[i]);
		}
		
		public function remove (i:int):void {
			if (this.offsets != null) {
				this.offsets.splice (i,1);
				this.actions.splice (i,1);
				this.listSize --;
			}
		}
		
		/**
		 * perform a binary search to find the requested offset.
		 * @param k
		 * @return the index where that offset is found, or -(ins+1) if
		 * the key is not found, and ins is the insertion index.
		 *
		 */
		private function find(k:int):int
		{
			if (offsets != null)
			{
				var lo:int = 0;
				var hi:int = this.listSize-1;
				
				while (lo <= hi)
				{
					var i:int = (lo + hi)/2;
					var m:int = offsets[i];
					if (k > m)
						lo = i + 1;
					else if (k < m)
						hi = i - 1;
					else
						return i; // key found
				}
				return -(lo + 1);  // key not found, lo is the insertion point
			}
			else
			{
				return k;
			}
		}
		
		public function insert(offset:int, a:Action):void 
		{
			if (this.listSize==this.actions.length)
				grow(this.listSize*2);
			var i:int;
			
			if (this.listSize == 0 || offsets == null && offset == this.listSize || offsets != null && offset > offsets[this.listSize-1])
			{
				// appending.
				i = this.listSize;
			}
			else
			{
				i = find(offset);
				if (i < 0)
				{
					// offset not used yet.  compute insertion point
					i = -i - 1;
				}
				else
				{
					// offset already used.  if we are inserting a real action, make it be last
					if (a.code < 256)
					{
						// this is a real action, we want it to be last at this offset
						while (i < this.listSize && offsets[i] == offset)
							i++;
					}
				}
				var j:int;
				
				if (offsets != null) {
					for (j = this.offsets.length -1; j > i; j--) {
						this.offsets[j] = this.offsets[j-1];
					} 
				}
				
				for (j= this.actions.length-1; j>i; j--) {
					this.actions[j] = this.actions[j-1];
				}
			}
			if (offsets != null)
				offsets[i] = offset;
			actions[i] = a;
			this.listSize++;
		}

		
		public function append(a:Action):void 
		{
			var i:int=this.listSize;
			if (i == this.actions.length)
				grow(this.listSize*2);
			this.actions[i] = a;
			this.listSize = i+1;
		}
		
		public function toString():String
		{
			var stringBuffer:String = new String();
			
			stringBuffer += "ActionList: count = " + actions.length;
			stringBuffer += ", actions = ";
			
			for (var i:int = 0; i < this.listSize; i++)
			{
				stringBuffer += actions[i].toString();
			}
			
			return (stringBuffer);
		}
		
		/**
		 * Return the index within this action list of the first
		 * occurence of the specified actionCode, searching foward
		 * starting at the given index
		 */
		public function indexOf(actionCode:int, startAt:int = 0):int
		{
			var at:int = -1;
			for(var i:int=startAt; at<0 && i<this.actions.length; i++)
			{
				var a:Action = getAction(i);
				if (a != null && a.code == actionCode) {
					at = i;
				}
			}
			return at;
		}
		
		/**
		 * Return the index within this action list of the first
		 * occurence of the specified actionCode, searching backward
		 * starting at the given index
		 */
		public function lastIndexOf(actionCode:int, startAt:int = -1):int
		{
			if (startAt == -1) {
				startAt = this.actions.length-1;
			} 
			var at:int = -1;
			for(var i:int=startAt; at<0 && i>=0; i--)
			{
				var a:Action = getAction(i);
				if (a != null && a.code == actionCode)
					at = i;
			}
			return at;
		}
		
		
		public function setAction (i:int, action:Action):void {
			this.actions[i] = action;
		}
	}
}