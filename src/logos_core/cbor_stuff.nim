import std/strutils, stew/byteutils,
  cbor_serialization, cbor_serialization/std/tables, cbor_serialization/pkg/results

export cbor_serialization, tables, results

## ============================================================================
## Deterministic CBOR Validation (per LOGOS-MODULE-TRANSPORT §2.3)
## ============================================================================
## P0: Envelope validation (message kind, required fields) — implemented above
## P1/P2: Full canonicalization (sorted keys, shortest integers, no tags)
##         deferred until commitment-model spec is finalized.
## ===========================================================================

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
    var res = "[\n"
    for i, item in val.arrayVal:
      res.add(nextPad & formatCborValue(item, indent + 2))
      if i < val.arrayVal.len - 1:
        res.add(",")
      res.add("\n")
    res.add(pad & "]")
    res
  of CborValueKind.Object:
    if val.objVal.len == 0:
      return "{}"
    var res = "{\n"
    var i = 0
    for key, value in val.objVal.pairs:
      res.add(nextPad & "\"" & key & "\": " & formatCborValue(value, indent + 2))
      if i < val.objVal.len - 1:
        res.add(",")
      res.add("\n")
      i += 1
    res.add(pad & "}")
    res
  of CborValueKind.Tag:
    "tag(" & $val.tagVal.tag & ": " & formatCborValue(val.tagVal.val, indent) & ")"
