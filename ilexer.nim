import scintilla

type
  IDocument* {.pure.} = object of RootObj
    version*: proc(): int {.stdcall.}
    setErrorStatus*: proc(status: int) {.stdcall.}
    length*: proc(): int {.stdcall.}
    getCharRange*: proc(buffer: cstring; pos, lengthRetrieve: int) {.stdcall.}
    styleAt*: proc(pos: int): char {.stdcall.}
    lineFromPosition*: proc(pos: int): int {.stdcall.}
    lineStart*: proc(line: int): int {.stdcall.}
    getLevel*: proc(line: int): int {.stdcall.}
    setLevel*: proc(line: int, level: int): int {.stdcall.}
    getLineState*: proc(line: int): int {.stdcall.}
    setLineState*: proc(line: int, state: int): int {.stdcall.}
    startStyling*: proc(pos: int, mask: char) {.stdcall.}
    setStyleFor*: proc(len: int, style: char): bool {.stdcall.}
    setStyles*: proc(len: int, styles: cstring): bool {.stdcall.}
    decorationSetCurrentIndicator*: proc(indicator: int) {.stdcall.}
    decorationFillRange*: proc(pos: int, value: int, fillLen: int) {.stdcall.}
    changeLexerState*: proc(start, stop: int) {.stdcall.}
    codePage*: proc(): int {.stdcall.}
    isDBCSLeadByte*: proc(ch: char): bool {.stdcall.}
    bufferPointer*: proc(): cstring {.stdcall.}
    getLineIndentation*: proc(line: int): int {.stdcall.}

  ILexer* {.pure.} = object of RootObj
    version*: proc(): int {.stdcall.}
    release*: proc() {.stdcall.}
    propNames*: proc(): cstring {.stdcall.}
    propType*: proc(name: cstring): int {.stdcall.}
    descProp*: proc(name: cstring): cstring {.stdcall.}
    propSet*: proc(key, val: cstring): int {.stdcall.}
    descWordListSets*: proc(): cstring {.stdcall.}
    wordListSet*: proc(n: int, wl: cstring): int {.stdcall.}
    lex*: proc(startPos, lengthDoc: int, initStyle: int, pAccess: ptr IDocument) {.stdcall.}
    fold*: proc(startPos, lengthDoc: int, initStyle: int, pAccess: ptr IDocument) {.stdcall.}
    privateCall*: proc(operation: int, ud: pointer): pointer {.stdcall.}

  IDocumentWithLineEnd* = object of IDocument
    lineEnd*: proc(line: int): int {.stdcall.}
    getRelativePosition*: proc(start, offset: int): int {.stdcall.}
    getCharacterAndWidth*: proc(pos: int, pWidth: var int): int {.stdcall.}

  ILexerWithSubStyles* = object of ILexer
    lineEndTypesSupported*: proc(): int {.stdcall.}
    allocateSubStyles*: proc(styleBase, numberStyles: int): int {.stdcall.}
    subStylesStart*: proc(styleBase: int): int {.stdcall.}
    subStylesLength*: proc(styleBase: int): int {.stdcall.}
    styleFromSubStyle*: proc(subStyle: int): int {.stdcall.}
    primaryStyleFromStyle*: proc(style: int): int {.stdcall.}
    freeSubStyles*: proc() {.stdcall.}
    setIdentifiers*: proc(style: int, identifiers: cstring) {.stdcall.}
    distanceToSecondaryStyles*: proc(): int {.stdcall.}
    getSubStyleBases*: proc(): cstring {.stdcall.}

  LexerFactoryProc* = proc(): ptr ILexer {.stdcall.}

const
  #IDocument version
  dvOriginal* = 0
  dvLineEnd* = 1

  #ILexer version
  lvOriginal* = 0
  lvSubStyles* = 1