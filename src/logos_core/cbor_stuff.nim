import std/strutils,stew/byteutils,
  cbor_serialization, cbor_serialization/std/tables

export cbor_serialization, tables

func formatCborValue(val: CborValueRef, indent: int = 0): string
func `$`*(v: CborValueRef): string =
  formatCborValue(v, 0)

func formatCborValue(val: CborValueRef, indent: int = 0): string =
  if val.isNil:
    return "null"
  let pad = repeat(" ", indent)
  let nextPad = repeat(" ", indent + 2)
  case val.kind
  of CborValueKind.Bytes:
    val.bytesVal.toHex()
  of CborValueKind.String:
    "\"" & val.strVal.escape() & "\""
  of CborValueKind.Unsigned:
    $val.numVal.integer
  of CborValueKind.Negative:
    "-" & $(val.numVal.integer + 1)
  of CborValueKind.Float:
    $val.floatVal
  of CborValueKind.Bool:
    if val.boolVal: "true" else: "false"
  of CborValueKind.Null:
    "null"
  of CborValueKind.Undefined:
    "undefined"
  of CborValueKind.Simple:
    "simple(" & $val.simpleVal.uint8 & ")"
  of CborValueKind.Array:
    if val.arrayVal.len == 0:
      return "[]"
    var result = "[\n"
    for i, item in val.arrayVal:
      result.add(nextPad & formatCborValue(item, indent + 2))
      if i < val.arrayVal.len - 1:
        result.add(",")
      result.add("\n")
    result.add(pad & "]")
    result
  of CborValueKind.Object:
    if val.objVal.len == 0:
      return "{}"
    var result = "{\n"
    var i = 0
    for key, value in val.objVal.pairs:
      result.add(nextPad & "\"" & key & "\": " & formatCborValue(value, indent + 2))
      if i < val.objVal.len - 1:
        result.add(",")
      result.add("\n")
      i += 1
    result.add(pad & "}")
    result
  of CborValueKind.Tag:
    "tag(" & $val.tagVal.tag & ": " & formatCborValue(val.tagVal.val, indent) & ")"
