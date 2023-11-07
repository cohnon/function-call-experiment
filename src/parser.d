import main;
import lexer;
import ast;

import std.stdio;
import std.array: array, insertInPlace, join;


class Parser {
public:
    Stmt parse(string source) {
        lexer = new Lexer(source);
        return parse_statement;
    }

private:
    Stmt parse_statement() {
        if (lexer.current.kind == TokenKind.unknown) { return null; }

        Stmt statement = new Stmt();

        if (lexer.current.kind == TokenKind.let) {
            // eat 'let'
            lexer.consume;

            statement.kind = parse_def;
            return statement;
        }

        Expr expression = parse_expr(0);
        if (expression is null) { return null; }

        // top level expression should exhaust tokens
        if (lexer.current.kind != TokenKind.unknown) { return null; }

        statement.kind = expression;

        return statement;
    }

    FnDef parse_def() {
        Token ident = lexer.consume;
        if (ident.kind != TokenKind.ident) {
            writef("missing identifier\n");
            return null;
        }

        FnDef definition = new FnDef(ident.span);

        while (lexer.current.kind == TokenKind.ident) {
            definition.param_names.insertInPlace(
                definition.param_names.length,
                lexer.consume.span
            );

            if (lexer.current.kind != TokenKind.comma) { break; }
            lexer.consume;
        }

        if (lexer.current.kind != TokenKind.equal) {
            return null;
        }

        lexer.consume;
       
        definition.body = parse_expr(0);

        return definition;
    }

    Expr parse_expr(int prec) {
        Expr left = parse_expr_primary;
        if (left is null) { return null; }

        for (;;) {

            int op_prec;
            switch(lexer.current.kind) {
                case TokenKind.plus: case TokenKind.dash:
                    op_prec = 1;
                    break;

                case TokenKind.star: case TokenKind.slash:
                    op_prec = 2;
                    break;

                default:
                    op_prec = -1;
                    break;
            }

            if (op_prec == -1) { break; }
            if (prec >= op_prec) { break; }

            Expr operator = new Expr();
            BinOp bin_op;
            switch (lexer.consume.kind) {
                case TokenKind.plus: bin_op = new BinOp(BinOpKind.add); break;
                case TokenKind.dash: bin_op = new BinOp(BinOpKind.sub); break;
                case TokenKind.star: bin_op = new BinOp(BinOpKind.mul); break;
                case TokenKind.slash: bin_op = new BinOp(BinOpKind.div); break;
                default: break;
            }

            Expr right = parse_expr(op_prec);
            if (right is null) { return null; }

            bin_op.left = left;
            bin_op.right = right;
            operator.kind = bin_op;

            left = operator;
        }

        return left;
    }

    Expr parse_expr_primary() {
        Token token = lexer.current;
        switch (token.kind) {
            case TokenKind.num:
                Expr num = new Expr();
                num.kind = new Num(lexer.consume.value);
                return num;
            case TokenKind.ident: return parse_ident;
            case TokenKind.dash: return parse_negate;
            case TokenKind.lparen:
                lexer.consume;
                Expr expression = parse_expr(0);
                if (lexer.current.kind != TokenKind.rparen) { writef("expected closing paren\n"); return null; }
                lexer.consume;
                return expression;
            default: writef("expected expression\n"); return null;
        }
    }

    Expr parse_ident() {
        Token ident = lexer.consume;
        Expr expr = new Expr();
        FnCall fn_call = new FnCall(ident.span);

        if (lexer.current.kind != TokenKind.colon) {
            expr.kind = fn_call;
            return expr;
        }
       
        // consume ':'
        lexer.consume;

        for (;;) {
            fn_call.args.insertInPlace(fn_call.args.length, parse_expr(0));
            if (lexer.current.kind != TokenKind.comma) { break; }
            lexer.consume;
        }

        expr.kind = fn_call;

        return expr;
    }

    Expr parse_negate() {
        lexer.consume;
        Expr expr = new Expr();
        Neg negate = new Neg(parse_expr_primary);
        if (negate is null) { writef("negate on non expression\n"); return null; }

        expr.kind = negate;

        return expr;
    }

private:
    Lexer lexer;
}

