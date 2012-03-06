/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package osUtils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import osUtils.WebServerEvent;
	
	/**
	 * Dispatched when the user chooses 
	 * 
	 * @eventType WebServerEvent.generalError
	 */
	[Event(name="generalError", type="osUtils.WebServerEvent")]
	
	public class WebServer extends EventDispatcher
	{
		
		/**
		 * @private
		 * The current ServerSocket instance
		 */
		private var serverSocket:ServerSocket;
		
		/**
		 * @private
		 * A list of mime types that the server supports
		 */
		private var mimeTypes:Object = new Object();
		
		/**
		 * @private
		 * The document root for the web server
		 */
		private var docRoot:File;
		
		/**
		 * Create the web server instance but do not bind yet.
		 * 
		 * @param docPath The path to the document root of the server
		 */
		public function WebServer(docPath:String)
		{	
			// The mime types supported by this mini web server
			mimeTypes[".css"]   = "text/css";
			mimeTypes[".gif"]   = "image/gif";
			mimeTypes[".htm"]   = "text/html";
			mimeTypes[".html"]  = "text/html";
			mimeTypes[".ico"]   = "image/x-icon";
			mimeTypes[".jpg"]   = "image/jpeg";
			mimeTypes[".js"]    = "application/x-javascript";
			mimeTypes[".png"]   = "image/png";
			mimeTypes[".swf"]	= "application/x-shockwave-flash";
			mimeTypes[".pdf"]	= "application/pdf";
			mimeTypes[".doc"]	= "application/msword";
			mimeTypes[".docx"]	= "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
			mimeTypes[".xls"]	= "application/vnd.ms-excel";
			mimeTypes[".xlsx"]	= "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
			mimeTypes[".xml"]	= "application/xml";
			
			// Initialize the web server directory (in applicationStorageDirectory) with sample files
			this.docRoot = new File(docPath);
			if (!this.docRoot.exists)
			{
				throw new Error("Document path does not exist");
			}
		}
		
		/**
		 * @public
		 * Whether the web server is listening
		 * 
		 * @return Boolean Whether the server is listening
		 */
		public function get listening():Boolean {
			if (this.serverSocket == null) {
				return false;
			}
			return this.serverSocket.listening;
		}
		
		/**
		 * @public
		 * Try to bind to the port and start listening
		 * 
		 * @param ipAddress The IP Address for binding the socket. Default is localhost.
		 * @param listenPort The port number (int) the server will listen on.
		 */
		public function listen(ipAddress:String = "127.0.0.1", listenPort:int = 9081):void
		{
			try
			{
				serverSocket = new ServerSocket();
				serverSocket.addEventListener(Event.CONNECT, socketConnectHandler);
				serverSocket.bind(listenPort,ipAddress);
				serverSocket.listen();
			}
			catch (error:Error)
			{
				throw new Error(error.message);
			}
		}
		
		/**
		 * @public
		 * If the server is running, stop listening and close the port
		 */
		public function close():void {
			if (serverSocket != null && serverSocket.listening) {
				serverSocket.close();
			}
		}
		
		/**
		 * @private
		 * The handler for Event.Connect for the serverSocket
		 * It creates the socket instance for this connection.
		 * 
		 * @param event The ServerSocketConnectEvent
		 */
		private function socketConnectHandler(event:ServerSocketConnectEvent):void
		{
			var socket:Socket = event.socket;
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
		}
		
		/**
		 * @private
		 * The data handler for the socket created within the socketConnectHandler
		 * 
		 * @param event The ProgressEvent for the socket
		 */
		private function socketDataHandler(event:ProgressEvent):void
		{
			try
			{
				var socket:Socket = event.target as Socket;
				var bytes:ByteArray = new ByteArray();
				socket.readBytes(bytes);
				var request:String = "" + bytes;
				
				var filePath:String = request.substring(4, request.indexOf("HTTP/") - 1);
				
				if (filePath.indexOf("?") > 0) {
					filePath = filePath.substring(0,filePath.indexOf("?"));
				}
				
				if (filePath.indexOf("#") > 0) {
					filePath = filePath.substring(0,filePath.indexOf("#"));
				}
				
				var file:File = new File(this.docRoot.url + filePath);
				if (file.exists && !file.isDirectory)
				{
					var stream:FileStream = new FileStream();
					stream.open( file, FileMode.READ );
					var content:ByteArray = new ByteArray();
					stream.readBytes(content);
					stream.close();
					socket.writeUTFBytes("HTTP/1.1 200 OK\n");
					socket.writeUTFBytes("Content-Length: " + content.length + "\n");
					socket.writeUTFBytes("Content-Type: " + getMimeType(filePath) + "\n\n");
					socket.writeBytes(content);
				}
				else
				{
					socket.writeUTFBytes("HTTP/1.1 404 Not Found\n");
					socket.writeUTFBytes("Content-Type: text/html\n\n");
					socket.writeUTFBytes("<html><body><h2>Page Not Found</h2></body></html>");
				}
				socket.flush();
				socket.close();
			}
			catch (error:Error)
			{
				dispatchEvent(new WebServerEvent(WebServerEvent.GENERAL_ERROR, error.message));
			}
		}
		
		/**
		 * @private
		 * Try to determine the mime type from the file extension. This is very basic and just checks for the
		 * last index of "." in the path.
		 * 
		 * @param path The path to the file
		 * @return The string representing the mime type
		 */
		private function getMimeType(path:String):String
		{
			var mimeType:String;
			var index:int = path.lastIndexOf(".");
			if (index > -1)
			{
				mimeType = mimeTypes[path.substring(index)];
			}
			
			// default to text/plain for unknown mime types
			return mimeType == null ? "text/plain" : mimeType; 
		}
	}
}