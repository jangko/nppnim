import winapi

proc lstrcpy*(a: var openArray[TCHAR], b: string) =
  when defined(winUniCode):
    let x = newWideCString(b)
  else:
    let x = b.cstring

  var i = 0
  while x[i].int != 0:
    a[i] = TCHAR(x[i])
    inc i

  a[i] = TCHAR(0)
  
proc copyToBuff*(str: string; buff: ptr TCHAR; len: int) =
  var
    buflen = min(str.len, len-1)
    b = str.substr(0, buflen)

  when defined(winUniCode): 
    let src = newWideCString(b)
  else: 
    let src = b.cstring

  if buflen > 0:
    inc buflen
    copyMem(buff, src.unsafeAddr, sizeof(TCHAR) * buflen)
   
