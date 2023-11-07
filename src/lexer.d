import std.array: array, insertInPlace, join;
import std.conv;


enum TokenKind { num, comma, equal, plus, dash, slash, star, let, ident, lparen, rparen, colon, unknown }

class Token {
public:
    this(TokenKind kind) {
        this.kind = kind;
    }

    this(TokenKind kind, string span) {
        this.kind = kind;
        this.span = span;
    }

    this(TokenKind kind, double value) {
        this.kind = kind;
        this.value = value;
    }

public:
    TokenKind kind;
    union {
        string span;
        double value;
    }
}


class Lexer {
public:
    this(string source) {
        offset = 0;
        tokens = [];
        for (size_t i; i < source.length; i += 1) {

            // symbols
            switch (source[i]) {
                case ' ': continue;
                case '=': tokens.insertInPlace(tokens.length, new Token(TokenKind.equal)); continue;
                case ',': tokens.insertInPlace(tokens.length, new Token(TokenKind.comma)); continue;
                case '+': tokens.insertInPlace(tokens.length, new Token(TokenKind.plus)); continue;
                case '-': tokens.insertInPlace(tokens.length, new Token(TokenKind.dash)); continue;
                case '/': tokens.insertInPlace(tokens.length, new Token(TokenKind.slash)); continue;
                case '*': tokens.insertInPlace(tokens.length, new Token(TokenKind.star)); continue;
                case '(': tokens.insertInPlace(tokens.length, new Token(TokenKind.lparen)); continue;
                case ')': tokens.insertInPlace(tokens.length, new Token(TokenKind.rparen)); continue;
                case ':': tokens.insertInPlace(tokens.length, new Token(TokenKind.colon)); continue;
                default: break;
            }

            // number literals
            if ('0' <= source[i] && source[i] <= '9') {
                size_t start = i;
                while ('0' <= source[i] && source[i] <= '9' || source[i] == '.') { i += 1; }

                tokens.insertInPlace(tokens.length, new Token(TokenKind.num, source[start..i].to!double));
                i -= 1;

                continue;
            }

            // identifiers
            if ('a' <= source[i] && source[i] <= 'z') {

                // keyword 'let'
                if (i + 3 < source.length && source[i..i+3] == "let") {
                    tokens.insertInPlace(tokens.length, new Token(TokenKind.let, source[i..i+3]));
                    i += 2;
                    continue;
                }

                size_t start = i;
                while ('a' <= source[i] && source[i] <= 'z') { i += 1; }

                tokens.insertInPlace(tokens.length, new Token(TokenKind.ident, source[start..i]));
                i -= 1;
            }
        }

        tokens.insertInPlace(tokens.length, new Token(TokenKind.unknown));
    }

    Token current() { 
        return tokens[offset];
    }

    Token consume() {
        Token token = tokens[offset];
        offset += 1;
        return token;
    }

public:
    Token[] tokens;
    int offset;
}

