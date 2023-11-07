import std.stdio;
import std.conv;
import std.sumtype;

import eval;
import parser;
import ast;


void main(string[] args) {
    Eval eval = new Eval();
    Parser parser = new Parser();


    writef("\033[31mstarting... do <ctrl>-c to quit\033[0m\n");

    for (;;) {
        writef("\033[0m"); // reset
        writef("%% ");
        string line = readln();

        writef("\033[32m"); // green

        Stmt statement = parser.parse(line);
        if (statement is null) {
            continue;
        }

        statement.kind.match!(
            (FnDef definition) => eval.add_definition(definition.name, definition),

            (Expr expression) {
                double result = eval.evaluate(expression);
                writef("= %f\n", result);
            }
        );
    }
}
