# Copyright (c) 2016 Andri Lim
#
# Distributed under the MIT license
# (See accompanying file LICENSE.txt)
#
#-----------------------------------------
import sets, winapi

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
    "cstringArray"
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
    WT_KEYWORD, WT_TYPE, WT_IDENT, WT_MAGIC, WT_CTYPE

  VTABLE* = array[0..25, pointer]

  IDocument* {.pure, final.} = ptr object
    vTable: ptr VTABLE

  IDocumentWithLineEnd* {.pure, final.} = ptr object
    vTable: ptr VTABLE

  ILexer* {.pure, final.} = object
    vTable*: ptr VTABLE

  LexerFactoryProc* = proc(): ptr ILexer {.stdcall.}

proc nvVersion*(dv: IDocument): int =
  type dvt = proc(x: IDocument): int {.stdcall.}
  result = cast[dvt](dv.vTable[0])(dv)

proc nvSetErrorStatus*(dv: IDocument, status: int) =
  type dvt = proc(x: IDocument, status: int) {.stdcall.}
  cast[dvt](dv.vTable[1])(dv, status)

proc nvLength*(dv: IDocument): int =
  type dvt = proc(x: IDocument): int {.stdcall.}
  result = cast[dvt](dv.vTable[2])(dv)

proc nvGetCharRange*(dv: IDocument, buf: cstring, pos, len: int) =
  type dvt = proc(x: IDocument, buf: cstring, pos, len: int) {.stdcall.}
  cast[dvt](dv.vTable[3])(dv, buf, pos, len)

proc nvStyleAt*(dv: IDocument, pos: int): char =
  type dvt = proc(x: IDocument, pos: int): char {.stdcall.}
  result = cast[dvt](dv.vTable[4])(dv, pos)

proc nvLineFromPosition*(dv: IDocument, pos: int): int =
  type dvt = proc(x: IDocument, pos: int): int {.stdcall.}
  result = cast[dvt](dv.vTable[5])(dv, pos)

proc nvLineStart*(dv: IDocument, line: int): int =
  type dvt = proc(x: IDocument, line: int): int {.stdcall.}
  result = cast[dvt](dv.vTable[6])(dv, line)

proc nvGetLevel*(dv: IDocument, line: int): int =
  type dvt = proc(x: IDocument, line: int): int {.stdcall.}
  result = cast[dvt](dv.vTable[7])(dv, line)

proc nvSetLevel*(dv: IDocument, line, level: int): int =
  type dvt = proc(x: IDocument, line, level: int): int {.stdcall.}
  result = cast[dvt](dv.vTable[8])(dv, line, level)

proc nvGetLineState*(dv: IDocument, line: int): int =
  type dvt = proc(x: IDocument, line: int): int {.stdcall.}
  result = cast[dvt](dv.vTable[9])(dv, line)

proc nvSetLineState*(dv: IDocument, line: int, state: int): int =
  type dvt = proc(x: IDocument, line, state: int): int {.stdcall.}
  result = cast[dvt](dv.vTable[10])(dv, line, state)

proc nvStartStyling*(dv: IDocument, pos: int, mask: char) =
  type dvt = proc(x: IDocument, pos: int, mask: char) {.stdcall.}
  cast[dvt](dv.vTable[11])(dv, pos, mask)

proc nvSetStyleFor*(dv: IDocument, len: int, style: char): bool =
  type dvt = proc(x: IDocument, len: int, style: char): bool {.stdcall.}
  result = cast[dvt](dv.vTable[12])(dv, len, style)

proc nvSetStyles*(dv: IDocument, len: int, styles: cstring): bool =
  type dvt = proc(x: IDocument, len: int, styles: cstring): bool {.stdcall.}
  result = cast[dvt](dv.vTable[13])(dv, len, styles)

proc nvDecorationSetCurrentIndicator*(dv: IDocument, indicator: int) =
  type dvt = proc(x: IDocument, indicator: int) {.stdcall.}
  cast[dvt](dv.vTable[14])(dv, indicator)

proc nvDecorationFillRange*(dv: IDocument, pos, value, fillLength: int) =
  type dvt = proc(x: IDocument, pos, value, fillLength: int) {.stdcall.}
  cast[dvt](dv.vTable[15])(dv, pos, value, fillLength)

proc nvChangeLexerState*(dv: IDocument, start, stop: int) =
  type dvt = proc(x: IDocument, start, stop: int) {.stdcall.}
  cast[dvt](dv.vTable[16])(dv, start, stop)

proc nvCodePage*(dv: IDocument): int =
  type dvt = proc(x: IDocument): int {.stdcall.}
  result = cast[dvt](dv.vTable[17])(dv)

proc nvIsDBCSLeadByte*(dv: IDocument, ch: char): bool =
  type dvt = proc(x: IDocument, ch: char): bool {.stdcall.}
  result = cast[dvt](dv.vTable[18])(dv, ch)

proc nvBufferPointer*(dv: IDocument): cstring =
  type dvt = proc(x: IDocument): cstring {.stdcall.}
  result = cast[dvt](dv.vTable[19])(dv)

proc nvGetLineIndentation*(dv: IDocument, line: int): int =
  type dvt = proc(x: IDocument, line: int): int {.stdcall.}
  result = cast[dvt](dv.vTable[20])(dv, line)

proc nvLineEnd*(dv: IDocumentWithLineEnd, line: int): int =
  type dvt = proc(x: IDocumentWithLineEnd, line: int): int {.stdcall.}
  result = cast[dvt](dv.vTable[21])(dv, line)

proc nvGetRelativePosition*(dv: IDocumentWithLineEnd, pos, characterOffset: int): int =
  type dvt = proc(x: IDocumentWithLineEnd, pos, characterOffset: int): int {.stdcall.}
  result = cast[dvt](dv.vTable[22])(dv, pos, characterOffset)

proc nvGetCharacterAndWidth*(dv: IDocumentWithLineEnd, pos: int, pWidth: var int): int =
  type dvt = proc(x: IDocumentWithLineEnd, pos: int, pWidth: var int): int {.stdcall.}
  result = cast[dvt](dv.vTable[23])(dv, pos, pWidth)