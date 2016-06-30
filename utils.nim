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

proc copyToBuff*(str: string; output: ptr TCHAR; len: int) =
  when defined(winUniCode):
    let x = newWideCString(str)
    let length = min(len-1, x.len) + 1
  else:
    let x = str.cstring
    let length = min(len-1, str.len) + 1

  copyMem(output, cast[ptr TCHAR](x), sizeof(TCHAR) * length)
