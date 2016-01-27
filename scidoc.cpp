#include "ILexer.h"

extern "C" {

int nvVersion(IDocument* nv) {
  return nv->Version();
}

void nvSetErrorStatus(IDocument* nv, int status) {
  nv->SetErrorStatus(status);
}

int nvLength(IDocument* nv) {
  return nv->Length();
}

void nvGetCharRange(IDocument* nv, char *buffer, Sci_Position position, Sci_Position lengthRetrieve) {
  nv->GetCharRange(buffer, position, lengthRetrieve);
}

char nvStyleAt(IDocument* nv, Sci_Position position) {
  return nv->StyleAt(position);
}

Sci_Position nvLineFromPosition(IDocument* nv, Sci_Position position) {
  return nv->LineFromPosition(position);
}

Sci_Position nvLineStart(IDocument* nv, Sci_Position line) {
  return nv->LineStart(line);
}

int nvGetLevel(IDocument* nv, Sci_Position line) {
  return nv->GetLevel(line);
}

int nvSetLevel(IDocument* nv, Sci_Position line, int level) {
  return nv->SetLevel(line, level);
}

int nvGetLineState(IDocument* nv, Sci_Position line) {
  return nv->GetLineState(line);
}

int nvSetLineState(IDocument* nv, Sci_Position line, int state) {
  return nv->SetLineState(line, state);
}

void nvStartStyling(IDocument* nv, Sci_Position position, char mask) {
  nv->StartStyling(position, mask);
}

bool nvSetStyleFor(IDocument* nv, Sci_Position length, char style) {
  return nv->SetStyleFor(length, style);
}

bool nvSetStyles(IDocument* nv, Sci_Position length, const char *styles) {
  return nv->SetStyles(length, styles);
}

void nvDecorationSetCurrentIndicator(IDocument* nv, int indicator) {
  nv->DecorationSetCurrentIndicator(indicator);
}

void nvDecorationFillRange(IDocument* nv, Sci_Position position, int value, Sci_Position fillLength) {
  nv->DecorationFillRange(position, value, fillLength);
}

void nvChangeLexerState(IDocument* nv, Sci_Position start, Sci_Position end) {
  nv->ChangeLexerState(start, end);
}

int nvCodePage(IDocument* nv) {
  return nv->CodePage();
}

bool nvIsDBCSLeadByte(IDocument* nv, char ch) {
  return nv->IsDBCSLeadByte(ch);
}

const char * nvBufferPointer(IDocument* nv) {
  return nv->BufferPointer();
}

int nvGetLineIndentation(IDocument* nv, Sci_Position line) {
  return nv->GetLineIndentation(line);
}

Sci_Position nvLineEnd(IDocumentWithLineEnd* nv, Sci_Position line) {
  return nv->LineEnd(line);
}

Sci_Position nvGetRelativePosition(IDocumentWithLineEnd* nv, Sci_Position positionStart, Sci_Position characterOffset) {
  return nv->GetRelativePosition(positionStart, characterOffset);
}

int nvGetCharacterAndWidth(IDocumentWithLineEnd* nv, Sci_Position position, Sci_Position *pWidth) {
  return nv->GetCharacterAndWidth(position, pWidth);
}

}