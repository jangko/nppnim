# Copyright (c) 2016 Andri Lim
#
# Distributed under the MIT license
# (See accompanying file LICENSE.txt)
#
#-----------------------------------------
import sets, winapi, scintilla

const
  nbChar = 64

type
  NppData* {.pure, final.} = object
    nppHandle*: HWND
    sciMainHandle*: HWND
    sciSecondHandle*: HWND

  NppDataCopy* {.bycopy.} = NppData

  PFUNCPLUGINCMD* = proc() {.cdecl.}

  ShortcutKey* {.pure, final.} = object
    isCtrl*: bool
    isAlt*: bool
    isShift*: bool
    key*: UCHAR

  FuncItem* {.pure, final.} = object
    itemName*: array[nbChar, TCHAR]
    pFunc*: PFUNCPLUGINCMD
    cmdID*: cint
    init2Check*: bool
    pShKey*: ptr ShortcutKey

const
  #IDocument version
  dvOriginal* = 0
  dvLineEnd*  = 1
  dvRelease4* = 2

  #ILexer version
  lvOriginal*  = 0
  lvSubStyles* = 1
  lvRelease4*  = 2
  lvRelease5*  = 3

# Nim ver 0.13.0 use const, but 0.15.0 regression
# force me to use let
let
  NimKeywords* = [
    "addr",
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
    "unsafeaddr",
    "unowned",
    "var",
    "when",
    "while",
    "with",
    "without",
    "xor",
    "yield"].toHashSet()

  NimTypes* = [
    "byte",
    "bool",
    "int",
    "uint",
    "char",
    "string",
    "seq",
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
    "openarray",
    "set",
    "varargs"
  ].toHashSet()

  NimCTypes* = [
    "csize",
    "cfloat",
    "cdouble",
    "clong",
    "culong",
    "clonglong",
    "culonglong",
    "cshort",
    "cushort",
    "cschar",
    "cchar",
    "cuchar",
    "cint",
    "cuint",
    "cstring",
    "cstringarray"
  ].toHashSet()

  NimMagic* = [
    "defined",
    "declared",
    "declaredinscope",
    "definedinscope",
    "new",
    "high",
    "low"
  ].toHashSet()

type
  WordType* = enum
    WT_KEYWORD, WT_TYPE, WT_IDENT, WT_MAGIC, WT_CTYPE

  VTABLE* = array[0..30, pointer]

  IDocument* {.pure, final.} = ptr object
    vTable: ptr VTABLE

  IDocumentWithLineEnd* {.pure, final.} = ptr object
    vTable: ptr VTABLE

  ILexer* {.pure, final.} = object
    vTable*: ptr VTABLE

  Lexer* = ptr ILexer

  LexerFactoryProc* = proc(): ptr ILexer {.stdcall.}

proc nvVersion*(dv: IDocument): int =
  type dvt = proc(x: IDocument): cint {.stdcall.}
  result = cast[dvt](dv.vTable[0])(dv)

proc nvSetErrorStatus*(dv: IDocument, status: int) =
  type dvt = proc(x: IDocument, status: cint) {.stdcall.}
  cast[dvt](dv.vTable[1])(dv, status.cint)

proc nvLength*(dv: IDocument): int =
  type dvt = proc(x: IDocument): Sci_Position {.stdcall.}
  result = cast[dvt](dv.vTable[2])(dv)

proc nvGetCharRange*(dv: IDocument, buf: cstring, pos, len: int) =
  type dvt = proc(x: IDocument, buf: cstring, pos, len: Sci_Position) {.stdcall.}
  cast[dvt](dv.vTable[3])(dv, buf, pos.Sci_Position, len.Sci_Position)

proc nvStyleAt*(dv: IDocument, pos: int): char =
  type dvt = proc(x: IDocument, pos: Sci_Position): char {.stdcall.}
  result = cast[dvt](dv.vTable[4])(dv, pos.Sci_Position)

proc nvLineFromPosition*(dv: IDocument, pos: int): int =
  type dvt = proc(x: IDocument, pos: Sci_Position): Sci_Position {.stdcall.}
  result = cast[dvt](dv.vTable[5])(dv, pos.Sci_Position).int

proc nvLineStart*(dv: IDocument, line: int): int =
  type dvt = proc(x: IDocument, line: Sci_Position): Sci_Position {.stdcall.}
  result = cast[dvt](dv.vTable[6])(dv, line.Sci_Position).int

proc nvGetLevel*(dv: IDocument, line: int): int =
  type dvt = proc(x: IDocument, line: Sci_Position): cint {.stdcall.}
  result = cast[dvt](dv.vTable[7])(dv, line.Sci_Position).int

proc nvSetLevel*(dv: IDocument, line, level: int): int =
  type dvt = proc(x: IDocument, line: Sci_Position, level: cint): cint {.stdcall.}
  result = cast[dvt](dv.vTable[8])(dv, line.Sci_Position, level.cint).int

proc nvGetLineState*(dv: IDocument, line: int): int =
  type dvt = proc(x: IDocument, line: Sci_Position): cint {.stdcall.}
  result = cast[dvt](dv.vTable[9])(dv, line.Sci_Position).int

proc nvSetLineState*(dv: IDocument, line: int, state: int): int =
  type dvt = proc(x: IDocument, line: Sci_Position, state: cint): cint {.stdcall.}
  result = cast[dvt](dv.vTable[10])(dv, line.Sci_Position, state.cint).int

proc nvStartStyling*(dv: IDocument, pos: int) =
  type dvt = proc(x: IDocument, pos: Sci_Position) {.stdcall.}
  cast[dvt](dv.vTable[11])(dv, pos.Sci_Position)

proc nvSetStyleFor*(dv: IDocument, len: int, style: char): bool =
  type dvt = proc(x: IDocument, len: Sci_Position, style: char): bool {.stdcall.}
  result = cast[dvt](dv.vTable[12])(dv, len.Sci_Position, style)

proc nvSetStyles*(dv: IDocument, len: int, styles: cstring): bool =
  type dvt = proc(x: IDocument, len: Sci_Position, styles: cstring): bool {.stdcall.}
  result = cast[dvt](dv.vTable[13])(dv, len.Sci_Position, styles)

proc nvDecorationSetCurrentIndicator*(dv: IDocument, indicator: int) =
  type dvt = proc(x: IDocument, indicator: cint) {.stdcall.}
  cast[dvt](dv.vTable[14])(dv, indicator.cint)

proc nvDecorationFillRange*(dv: IDocument, pos, value, fillLength: int) =
  type dvt = proc(x: IDocument, pos: Sci_Position, value: cint, fillLength: Sci_Position) {.stdcall.}
  cast[dvt](dv.vTable[15])(dv, pos.Sci_Position, value.cint, fillLength.Sci_Position)

proc nvChangeLexerState*(dv: IDocument, start, stop: int) =
  type dvt = proc(x: IDocument, start, stop: Sci_Position) {.stdcall.}
  cast[dvt](dv.vTable[16])(dv, start.Sci_Position, stop.Sci_Position)

proc nvCodePage*(dv: IDocument): int =
  type dvt = proc(x: IDocument): cint {.stdcall.}
  result = cast[dvt](dv.vTable[17])(dv).int

proc nvIsDBCSLeadByte*(dv: IDocument, ch: char): bool =
  type dvt = proc(x: IDocument, ch: char): bool {.stdcall.}
  result = cast[dvt](dv.vTable[18])(dv, ch)

proc nvBufferPointer*(dv: IDocument): cstring =
  type dvt = proc(x: IDocument): cstring {.stdcall.}
  result = cast[dvt](dv.vTable[19])(dv)

proc nvGetLineIndentation*(dv: IDocument, line: int): int =
  type dvt = proc(x: IDocument, line: Sci_Position): cint {.stdcall.}
  result = cast[dvt](dv.vTable[20])(dv, line.Sci_Position)

proc nvLineEnd*(dv: IDocumentWithLineEnd, line: int): int =
  type dvt = proc(x: IDocumentWithLineEnd, line: Sci_Position): Sci_Position {.stdcall.}
  result = cast[dvt](dv.vTable[21])(dv, line.Sci_Position)

proc nvGetRelativePosition*(dv: IDocumentWithLineEnd, pos, characterOffset: int): int =
  type dvt = proc(x: IDocumentWithLineEnd, pos, characterOffset: Sci_Position): Sci_Position {.stdcall.}
  result = cast[dvt](dv.vTable[22])(dv, pos.Sci_Position, characterOffset.Sci_Position)

proc nvGetCharacterAndWidth*(dv: IDocumentWithLineEnd, pos: int, pWidth: var Sci_Position): int =
  type dvt = proc(x: IDocumentWithLineEnd, pos: Sci_Position, pWidth: var Sci_Position): cint {.stdcall.}
  result = cast[dvt](dv.vTable[23])(dv, pos.Sci_Position, pWidth)
