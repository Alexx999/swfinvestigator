/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package popUps
{
	import popUps.PopUpReturnEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.Panel;
	import spark.components.TextInput;
	import spark.components.VGroup;
	import spark.layouts.HorizontalLayout;

	/**
	 * Dispatched when the user chooses to Open the selected URL
	 * 
	 * @eventType PopUp.PopUpReturnEvent.PARAMS_RETURNED
	 */
	[Event(name="urlReturned", type="popUps.PopUpReturnEvent")]
	
	
	/**
	 * The GetSWFUrl class creates a PopUp to obtain the URL of the SWF from the URL.
	 * 
	 * GetSWFUrl will dispatch an event when the user has completed entering in the data.
	 */
	public class GetSWFUrl extends Sprite
	{

			/**
			 * @private
			 * A pointer to the PopUp panel
			 */
            private var panel:Panel;
            
            /**
             * The default URL for the text box
             */
            public var historyUrl:String = "http://";
            
            /**
             * @private
             * The TextInput box containing the URL
             */
            private var textInput:TextInput = new TextInput();

            public function GetSWFUrl() {
                var vb:VGroup = new VGroup();
                var label:Label = new Label();
                
                var b1:Button = new Button();
                var b2:Button = new Button();

				//Create buttons
                b1.label = "Fetch";
                b1.addEventListener(MouseEvent.CLICK, closeAndSave);
                b2.label = "Cancel";
                b2.addEventListener(MouseEvent.CLICK, closePopUp);

				//Add to the Control Bar for the bottom
				var cb:Array = new Array();
				cb.push(b1);
				cb.push(b2);

				//Create the URL Entry panel
                label.text = "Please enter the URL:";
                this.textInput.text = this.historyUrl;
                this.textInput.percentWidth = 100;

                vb.percentWidth = 100;
                vb.paddingBottom = 5;
                vb.paddingLeft = 5;
                vb.paddingRight = 5;
                vb.paddingTop = 5;
                vb.addElement(label);
                vb.addElement(this.textInput);

                this.panel = new Panel();
                this.panel.title = "Open URL";
                this.panel.width = 340;
                this.panel.height = 140;
                this.panel.addElement(vb);
				this.panel.controlBarContent = cb;
				var hAlign:HorizontalLayout = new HorizontalLayout;
				hAlign.horizontalAlign = "right";
				hAlign.paddingLeft = 5;
				hAlign.paddingRight = 5;
				hAlign.paddingTop = 5;
				hAlign.paddingBottom = 5;
				this.panel.controlBarLayout = hAlign;
		}
		
		/**
		 * @private
		 * Close the panel and return the PopUpReturnEvent
		 * 
		 * @param evt The click event from the Fetch Button
		 */ 
		private function closeAndSave(evt:Event):void {
			this.historyUrl = this.textInput.text;
			PopUpManager.removePopUp(panel);
			
			var newEvent:PopUpReturnEvent = new PopUpReturnEvent(PopUpReturnEvent.URL_RETURNED, true);
			dispatchEvent(newEvent);
		}

		/**
		 * @private
		 * Close the PopUp because the user clicked cancel.
		 */
		private function closePopUp(evt:Event):void {
			PopUpManager.removePopUp(panel);
		}

		/**
		 * Create the PopUp panel and center it.
		 * 
		 * @param myD The DisplayObject to display the PopUp within
		 */
		public function createPopUp(myD:DisplayObject):void {
			PopUpManager.addPopUp(this.panel, myD, true);
			PopUpManager.centerPopUp(this.panel);
        }


	}
}