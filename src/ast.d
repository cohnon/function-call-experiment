import std.array: array, insertInPlace, join;
import std.sumtype;



// ========== //
// expression //
// ========== //
enum BinOpKind { add, sub, mul, div }
class BinOp {
    this(BinOpKind kind) { this.kind = kind; }

    BinOpKind kind;
    Expr left;
    Expr right;
}

class FnCall {
    this(string name) {
        this.name = name;
        args = [];
    }

    string name;
    Expr[] args;
}

// unary '-'
class Neg {
    this(Expr child) { this.child = child; }

    Expr child;
}

class Num {
    this(double value) { this.value = value; }

    double value;
}

alias ExprKind = SumType!( BinOp, FnCall, Neg, Num );
class Expr {
    ExprKind kind;
}



// =================== //
// function definition //
// =================== //

// HACK: plain variables are technically functions with no parameters
class FnDef {
    this(string name) { this.name = name; }

    string name;
    // ordered list or parameter names
    string[] param_names;
    Expr body;
}



// ========= //
// statement //
// ========= //
alias StmtKind = SumType!( FnDef, Expr );
class Stmt {
    StmtKind kind;
}

