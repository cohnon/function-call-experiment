app: src/main.d src/ast.d src/lexer.d src/parser.d src/eval.d
	dmd $^ -of=$@
