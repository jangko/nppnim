import scintilla

type
  IDocument* {.pure.} = object of RootObj
    version*: proc(): int {.stdcall.}
    setErrorStatus*: proc(status: int) {.stdcall.}
    length*: proc(): Sci_Position {.stdcall.}
    getCharRange*: proc(buffer: cstring; pos, lengthRetrieve: Sci_Position) {.stdcall.}
    styleAt*: proc(pos: Sci_Position): char {.stdcall.}
    lineFromPosition*: proc(pos: Sci_Position): Sci_Position {.stdcall.}
    lineStart*: proc(line: Sci_Position): Sci_Position {.stdcall.}
    getLevel*: proc(line: Sci_Position): int {.stdcall.}
    setLevel*: proc(line: Sci_Position, level: int): int {.stdcall.}
    getLineState*: proc(line: Sci_Position): int {.stdcall.}
    setLineState*: proc(line: Sci_Position, state: int): int {.stdcall.}
    startStyling*: proc(pos: Sci_Position, mask: char) {.stdcall.}
    setStyleFor*: proc(len: Sci_Position, style: char): bool {.stdcall.}
    setStyles*: proc(len: Sci_Position, styles: cstring): bool {.stdcall.}
    decorationSetCurrentIndicator*: proc(indicator: int) {.stdcall.}
    decorationFillRange*: proc(pos: Sci_Position, value: int, fillLen: Sci_Position) {.stdcall.}
    changeLexerState*: proc(start, stop: Sci_Position) {.stdcall.}
    codePage*: proc(): int {.stdcall.}
    isDBCSLeadByte*: proc(ch: char): bool {.stdcall.}
    bufferPointer*: proc(): cstring {.stdcall.}
    getLineIndentation*: proc(line: Sci_Position): int {.stdcall.}

  ILexer* {.pure.} = object of RootObj
    version*: proc(): int {.stdcall.}
    release*: proc() {.stdcall.}
    propNames*: proc(): cstring {.stdcall.}
    propType*: proc(name: cstring): int {.stdcall.}
    descProp*: proc(name: cstring): cstring {.stdcall.}
    propSet*: proc(key, val: cstring): Sci_Position {.stdcall.}
    descWordListSets*: proc(): cstring {.stdcall.}
    wordListSet*: proc(n: int, wl: cstring): Sci_Position {.stdcall.}
    lex*: proc(startPos, lengthDoc: Sci_PositionU, initStyle: int, pAccess: ptr IDocument) {.stdcall.}
    fold*: proc(startPos, lengthDoc: Sci_PositionU, initStyle: int, pAccess: ptr IDocument) {.stdcall.}
    privateCall*: proc(operation: int, ud: pointer): pointer {.stdcall.}

  IDocumentWithLineEnd* = object of IDocument
    lineEnd*: proc(line: Sci_Position): Sci_Position {.stdcall.}
    getRelativePosition*: proc(start, offset: Sci_Position): Sci_Position {.stdcall.}
    getCharacterAndWidth*: proc(pos: Sci_Position, pWidth: var Sci_Position): int {.stdcall.}

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