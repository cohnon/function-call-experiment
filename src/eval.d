import ast;
import parser;

import std.stdio;
import std.sumtype;


class Eval {
public:
    this() {
        arg_stack = [];
    }

    void add_definition(string name, FnDef definition) {
        definitions[name] = definition;
    }

    double evaluate(Expr expr) {
        return expr.kind.match!(
            (Num num) => num.value,

            (BinOp bin_op) {
                final switch (bin_op.kind) {
                    case BinOpKind.add: return evaluate(bin_op.left) + evaluate(bin_op.right);
                    case BinOpKind.sub: return evaluate(bin_op.left) - evaluate(bin_op.right);
                    case BinOpKind.mul: return evaluate(bin_op.left) * evaluate(bin_op.right);
                    case BinOpKind.div: return evaluate(bin_op.left) / evaluate(bin_op.right);
                }
            },

            (Neg negate) => -evaluate(negate.child),

            (FnCall fn_call) {
                if (arg_stack.length > 0 && (fn_call.name in arg_stack[arg_stack.length - 1]) != null) {
                    return arg_stack[arg_stack.length - 1][fn_call.name];
                }

                if ((fn_call.name in definitions) is null) {
                    writef("call to undefined variable\n");
                    return 0.0;
                }

                FnDef def = definitions[fn_call.name];

                if (def.param_names.length != fn_call.args.length) {
                    writef("mismatched arguments %d %d\n", fn_call.args.length, def.param_names.length);
                    return 0.0f;
                }

                arg_stack.length += 1;
                for (size_t i = 0; i < def.param_names.length; i += 1) {
                    arg_stack[arg_stack.length - 1][def.param_names[i]] = evaluate(fn_call.args[i]);
                }

                double result = evaluate(def.body);
                arg_stack.length -= 1;
                return result;
            }
        );
    }

public:
    FnDef[string] definitions;
    double[string][] arg_stack;
    Parser parser;
}
