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
	import decompiler.tamarin.abcdump.Tag;
	import decompiler.swfdump.TagHandler;
	
	/**
	 * The FrameLabel tag gives the specified Name to the current
	 * frame. This name is used by ActionGoToLabel to identify the frame.
	 * <p>
	 * Any frame can have a FrameLabel tag but only the main timeline may
	 * have bookmark labels.  bookmark labels on sprite timelines are
	 * ignored by the player.
	 *
	 * @author Clement Wong
	 * @since SWF3
	 */
	public class FrameLabel extends Tag
	{
		public function FrameLabel()
		{
			super(stagFrameLabel);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.frameLabel(this);
		}
		
		/**
		 * label for the current frame
		 */
		public var label:String;
		
		/**
		 * named anchor flag.  labels this frame for seeking using HTML anchor syntax.
		 * @since SWF6
		 */
		public var anchor:Boolean;
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is FrameLabel))
			{
				var frameLabel:FrameLabel = object as FrameLabel;
				
				if ( frameLabel.label == this.label &&
					(frameLabel.anchor == this.anchor) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}
}