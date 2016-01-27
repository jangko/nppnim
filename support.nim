# Copyright (c) 2016 Andri Lim
#
# Distributed under the MIT license
# (See accompanying file LICENSE.txt)
#
#-----------------------------------------
import sets

const
  #IDocument version
  dvOriginal* = 0
  dvLineEnd* = 1

  #ILexer version
  lvOriginal* = 0
  lvSubStyles* = 1

  NimKeywords* = ["addr",
    "and",
    "as",
    "asm",
    "atomic",
    "bind",
    "block",
    "break",
    "case",
    "cast",
    "concept",
    "const",
    "continue",
    "converter",
    "defer",
    "discard",
    "distinct",
    "div",
    "do",
    "elif",
    "else",
    "end",
    "enum",
    "except",
    "export",
    "finally",
    "for",
    "from",
    "func",
    "generic",
    "if",
    "import",
    "in",
    "include",
    "interface",
    "is",
    "isnot",
    "iterator",
    "let",
    "macro",
    "method",
    "mixin",
    "mod",
    "nil",
    "not",
    "notin",
    "object",
    "of",
    "or",
    "out",
    "proc",
    "ptr",
    "raise",
    "ref",
    "return",
    "shl",
    "shr",
    "static",
    "template",
    "try",
    "tuple",
    "type",
    "using",
    "unsafeAddr",
    "var",
    "when",
    "while",
    "with",
    "without",
    "xor",
    "yield"].toSet()
    
  NimTypes* = [
    "bool",
    "int",
    "uint",
    "char",
    "string",
    "seq",
    "cstring",
    "int8",
    "int16",
    "int32",
    "int64",
    "uint8",
    "uint16",
    "uint32",
    "uint64",
    "float",
    "float32",
    "float64",
    "pointer",
    "void",
    "expr",
    "stmt",
    "typedesc",
    "auto",
    "any",
    "typed",
    "untyped",
    "range",
    "array",
    "openArray",
    "set",
    "varargs"
  ].toSet()
  
  NimMagic* = [
    "defined",
    "declared",
    "declaredInScope",
    "definedInScope",
    "new",
    "high",
    "low"
  ].toSet()
  
type
  WordType* = enum
    WT_KEYWORD, WT_TYPE, WT_IDENT, WT_MAGIC
    
  IDocument* = distinct pointer
  IDocumentWithLineEnd* = distinct pointer
  
{.compile: "scidoc.cpp".}

proc nvVersion*(dv: IDocument): int {.cdecl, importc.}
proc nvSetErrorStatus*(dv: IDocument, status: int) {.cdecl, importc.}
proc nvLength*(dv: IDocument): int {.cdecl, importc.}
proc nvGetCharRange*(dv: IDocument, buf: cstring, pos, len: int) {.cdecl, importc.}
proc nvStyleAt*(dv: IDocument, pos: int): char {.cdecl, importc.}
proc nvLineFromPosition*(dv: IDocument, pos: int): int {.cdecl, importc.}
proc nvLineStart*(dv: IDocument, line: int): int {.cdecl, importc.}
proc nvGetLevel*(dv: IDocument, line: int): int {.cdecl, importc.}
proc nvSetLevel*(dv: IDocument, line: int, level: int): int {.cdecl, importc.}
proc nvGetLineState*(dv: IDocument, line: int): int {.cdecl, importc.}
proc nvSetLineState*(dv: IDocument, line: int, state: int): int {.cdecl, importc.}
proc nvStartStyling*(dv: IDocument, pos: int, mask: char) {.cdecl, importc.}
proc nvSetStyleFor*(dv: IDocument, len: int, style: char): bool {.cdecl, importc.}
proc nvSetStyles*(dv: IDocument, len: int, styles: cstring): bool {.cdecl, importc.}
proc nvDecorationSetCurrentIndicator*(dv: IDocument, indicator: int) {.cdecl, importc.}
proc nvDecorationFillRange*(dv: IDocument, pos, value, fillLength: int) {.cdecl, importc.}
proc nvChangeLexerState*(dv: IDocument, start, stop: int) {.cdecl, importc.}
proc nvCodePage*(dv: IDocument): int {.cdecl, importc.}
proc nvIsDBCSLeadByte*(dv: IDocument, ch: char): bool {.cdecl, importc.}
proc nvBufferPointer*(dv: IDocument): cstring {.cdecl, importc.}
proc nvGetLineIndentation*(dv: IDocument, line: int): int {.cdecl, importc.}
proc nvLineEnd*(dv: IDocumentWithLineEnd, line: int): int {.cdecl, importc.}
proc nvGetRelativePosition*(dv: IDocumentWithLineEnd, pos, characterOffset: int): int {.cdecl, importc.}
proc nvGetCharacterAndWidth*(dv: IDocumentWithLineEnd, pos: int, pWidth: var int): int {.cdecl, importc.}
