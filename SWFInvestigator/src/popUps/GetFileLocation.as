/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

/**
 * This is currently dead code. Native browse dialogues via FileActions are now used in most cases.
 */

package popUps
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.Panel;
	import spark.components.VGroup;
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.TextInput;
	import spark.layouts.HorizontalLayout;

	import mx.events.FileEvent;
	import mx.managers.PopUpManager;
	import mx.controls.FileSystemTree;


	/**
	 * Dispatched when the user chooses to Open the selected URL
	 * 
	 * @eventType PopUp.PopUpReturnEvent.PARAMS_RETURNED
	 */
	[Event(name="fileReturned", type="popUps.PopUpReturnEvent")]
	
	
	/**
	 * The GetSWFUrl class creates a PopUp to obtain the URL of the SWF from the user.
	 * 
	 * GetSWFUrl will dispatch an event when the user has completed entering in the data.
	 */
	public class GetFileLocation extends Sprite
	{

			/**
			 * @private
			 * A pointer to the PopUp panel
			 */
            private var panel:Panel;
            
            /**
             * The default fileLocation for the text box
             */
            public var fileLocation:String = "";
            
            /**
             * @private
             * The TextInput box containing the fileLocation
             */
            private var textInput:TextInput = new TextInput();
            
            /**
             * @private
             * The FileSystemTree navigator
             */
            private var fileSysTree:FileSystemTree = new FileSystemTree();

            public function GetFileLocation(extArray:Array) {
                var vb:VGroup = new VGroup();
                var label:Label = new Label();

                var b1:Button = new Button();
                var b2:Button = new Button();

				//Create buttons
                b1.label = "Select";
                b1.addEventListener(MouseEvent.CLICK, closeAndSave);
                b2.label = "Cancel";
                b2.addEventListener(MouseEvent.CLICK, closePopUp);

				//Add to the Control Bar for the bottom
				var cb:Array = new Array();
				cb.push(b1);
				cb.push(b2);

				//Create the File Entry panel
                label.text = "Please double-click the file to open:";
                this.textInput.text = this.fileLocation;
                this.textInput.percentWidth = 100;

                vb.percentWidth = 100;
                vb.paddingBottom = 5;
                vb.paddingLeft = 5;
                vb.paddingRight = 5;
                vb.paddingTop = 5;
                vb.addElement(label);
                vb.addElement(this.textInput);
                
                this.fileSysTree.extensions = extArray;
                this.fileSysTree.showExtensions = true;
                this.fileSysTree.showIcons = true;
                this.fileSysTree.showHidden = false;
                this.fileSysTree.height = 200;
                this.fileSysTree.percentWidth = 100;
                this.fileSysTree.addEventListener(FileEvent.FILE_CHOOSE,fileChoosen);
                vb.addElement(this.fileSysTree);

                this.panel = new Panel();
                this.panel.title = "Open File";
                this.panel.width = 400;
                this.panel.height = 340;
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
		 * Update the text field to represent the selected file
		 * 
		 * @param evt The FILE_CHOOSE event from the file system tree
		 */
		private function fileChoosen(evt:FileEvent):void {
			this.fileLocation = evt.file.nativePath;
			this.textInput.text = this.fileLocation;
			closeAndSave(null);
		}
		
		/**
		 * @private
		 * Close the panel and return the PopUpReturnEvent
		 * 
		 * @param evt The click event from the Fetch Button
		 */ 
		private function closeAndSave(evt:Event):void {
			this.fileLocation = this.textInput.text;
			PopUpManager.removePopUp(panel);
			
			var newEvent:PopUpReturnEvent = new PopUpReturnEvent(PopUpReturnEvent.FILE_RETURNED,true);
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