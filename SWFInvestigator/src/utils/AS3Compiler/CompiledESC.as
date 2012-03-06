package utils.AS3Compiler
{
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	
	/**
	 * Imports Tamarin esc files as compiled binaries.
	 * At the time of this writing, none of these files have changed much since August 2008
	 * SWF Investigator updated EvalES4UI code to work with recent (Nov, 2011) builds of Tamarin-redux.
	 */
	public class CompiledESC
	{
		private static var done:Boolean = false;
		public function CompiledESC() {
			if (!done) {
				loadESC();
				done = true;
			}	
		}
		
		[Embed(source="abc/debug.es.abc",mimeType="application/octet-stream")]
		private var debug_abc:Class;
		[Embed(source="abc/util.es.abc",mimeType="application/octet-stream")]
		private var util_abc:Class;
		[Embed(source="abc/bytes-tamarin.es.abc",mimeType="application/octet-stream")]
		private var bytes_tamarin_abc:Class;
		[Embed(source="abc/util-tamarin.es.abc",mimeType="application/octet-stream")]
		private var util_tamarin_abc:Class;
		[Embed(source="abc/lex-char.es.abc",mimeType="application/octet-stream")]
		private var lex_char_abc:Class;
		[Embed(source="abc/lex-scan.es.abc",mimeType="application/octet-stream")]
		private var lex_scan_abc:Class;
		[Embed(source="abc/lex-token.es.abc",mimeType="application/octet-stream")]
		private var lex_token_abc:Class;
		[Embed(source="abc/ast.es.abc",mimeType="application/octet-stream")]
		private var ast_abc:Class;
		[Embed(source="abc/parse.es.abc",mimeType="application/octet-stream")]
		private var parse_abc:Class;
		[Embed(source="abc/asm.es.abc",mimeType="application/octet-stream")]
		private var asm_abc:Class;
		[Embed(source="abc/abc.es.abc",mimeType="application/octet-stream")]
		private var abc_abc:Class;
		[Embed(source="abc/emit.es.abc",mimeType="application/octet-stream")]
		private var emit_abc:Class;
		[Embed(source="abc/cogen.es.abc",mimeType="application/octet-stream")]
		private var cogen_abc:Class;
		[Embed(source="abc/cogen-stmt.es.abc",mimeType="application/octet-stream")]
		private var cogen_stmt_abc:Class;
		[Embed(source="abc/cogen-expr.es.abc",mimeType="application/octet-stream")]
		private var cogen_expr_abc:Class;
		[Embed(source="abc/esc-core.es.abc",mimeType="application/octet-stream")]
		private var esc_core_abc:Class;
		[Embed(source="abc/eval-support.es.abc",mimeType="application/octet-stream")]
		private var eval_support_abc:Class;
		[Embed(source="abc/esc-env.es.abc",mimeType="application/octet-stream")]
		private var esc_env_abc:Class;
		[Embed(source="abc/define.es.abc",mimeType="application/octet-stream")]
		private var define_abc:Class;
		
		private function loadESC():void {
			var a:Array = [
				new debug_abc as ByteArray,
				new util_abc as ByteArray,
				new bytes_tamarin_abc as ByteArray,
				new util_tamarin_abc as ByteArray,
				new lex_char_abc as ByteArray,
				new lex_scan_abc as ByteArray,
				new lex_token_abc as ByteArray,
				new ast_abc as ByteArray,
				new parse_abc as ByteArray,
				new asm_abc as ByteArray,
				new abc_abc as ByteArray,
				new emit_abc as ByteArray,
				new cogen_abc as ByteArray,
				new cogen_stmt_abc as ByteArray,
				new cogen_expr_abc as ByteArray,
				new esc_core_abc as ByteArray,
				new eval_support_abc as ByteArray,
				new esc_env_abc as ByteArray,
				new define_abc as ByteArray,
			]
			ABCLoader.loadBytes(a, true);
		}
		
		public function eval(str:String):ByteArray {
			try {
				var compile:Function = getDefinitionByName("ESC::compileStringToBytes") as Function;
			} catch (e:Error) {
				trace("Unable to get defintion ESC::compile in eval: "+e);
				return null;
			}
			var array:ByteArray;
			//array = compile( function():String { return str; },
			//function(abc:*):void { array = abc.getBytes() },
			array = compile (str,
				"test", 1 );
			array.position = 0;
			return array;
		}
		
	}
}