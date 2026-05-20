import std/[strutils, tables], results, stew/byteutils, ./cbor_stuff

type
  ParamType* = enum
    ptUnknown
    ptString
    ptBytes
    ptBool
    ptFloat64
    ptUint8
    ptUint16
    ptUint32
    ptUint64
    ptInt8
    ptInt16
    ptInt32
    ptInt64

  MethodParam* = object
    name*: string
    kind*: ParamType
    typeName*: string
    isOptional*: bool
    value*: string

proc parseParamType*(typeExpr: string): ParamType =
  let clean = typeExpr.strip()
  if clean.len == 0:
    return ptUnknown
  let base = clean.splitWhitespace()[0].split(".")[0]
  case base
  of "tstr": ptString
  of "bstr": ptBytes
  of "bool": ptBool
  of "float64": ptFloat64
  of "uint8": ptUint8
  of "uint16": ptUint16
  of "uint32": ptUint32
  of "uint64": ptUint64
  of "int8": ptInt8
  of "int16": ptInt16
  of "int32": ptInt32
  of "int64": ptInt64
  else: ptUnknown

proc paramTypeToCborKind*(kind: ParamType): CborValueKind =
  case kind
  of ptString, ptUnknown: CborValueKind.String
  of ptBytes: CborValueKind.Bytes
  of ptBool: CborValueKind.Bool
  of ptFloat64: CborValueKind.Float
  of ptUint8, ptUint16, ptUint32, ptUint64: CborValueKind.Unsigned
  of ptInt8, ptInt16, ptInt32, ptInt64: CborValueKind.Unsigned

proc extractMethodsFromSchema*(schema: string): seq[string] =
  ## Extract method names from CDDL schema
  ## Methods are defined as: <module>.<method>-request = {...}
  var methods: seq[string] = @[]
  for line in schema.splitLines():
    if line.contains("-request") and line.contains("="):
      # Extract the method name from "module.method-request ="
      let parts = line.split("=")
      if parts.len > 0:
        let namePart = parts[0].strip()
        if namePart.endsWith("-request"):
          let methodFull = namePart[0 ..< namePart.len - 8] # Remove "-request"
          let methodParts = methodFull.split(".")
          if methodParts.len > 1:
            let methodName = methodParts[^1] # Get the last part after the dot
            if methodName notin methods:
              methods.add(methodName)
  methods

proc extractMethodParams*(schema: string, methodName: string): seq[MethodParam] =
  ## Extract parameter names and primitive types from a method's request definition
  ## Looking for the pattern: <module>.<method>-request = { param: type, ... }
  var params: seq[MethodParam] = @[]
  var inMethod = false
  var braceCount = 0
  var paramStr = ""

  for line in schema.splitLines():
    if line.contains(methodName & "-request") and line.contains("="):
      inMethod = true

    if inMethod:
      paramStr.add(line & "\n")
      braceCount += line.count('{') - line.count('}')

      if braceCount == 0 and inMethod and line.contains('}'):
        # Found the complete method definition
        let startIdx = paramStr.find('{')
        let endIdx = paramStr.rfind('}')
        if startIdx >= 0 and endIdx > startIdx:
          let innerContent = paramStr[startIdx + 1 ..< endIdx]
          # Parse parameters
          for part in innerContent.split(","):
            let stripped = part.strip()
            if stripped.len == 0 or stripped.startsWith(";"):
              continue
            let cleaned = stripped.split(";")[0].strip()
            let colonIdx = cleaned.find(':')
            if colonIdx > 0:
              var paramName = cleaned[0 ..< colonIdx].strip()
              var isOptional = false
              if paramName.startsWith("?"):
                isOptional = true
                paramName = paramName[1 ..^ 1].strip()
              let rawType = cleaned[colonIdx + 1 ..^ 1].strip()
              if paramName.len > 0:
                let pType = parseParamType(rawType)
                params.add(
                  MethodParam(
                    name: paramName,
                    kind: pType,
                    typeName:
                      if pType == ptUnknown:
                        rawType
                      else:
                        rawType.splitWhitespace()[0].split(".")[0],
                    isOptional: isOptional,
                    value: "",
                  )
                )
        break
  params

proc paramValueToCbor*(param: MethodParam): Result[CborValueRef, string] =
  if param.value.len == 0:
    if param.isOptional:
      return ok(nil)
    elif param.kind == ptString or param.kind == ptUnknown:
      return ok(CborValueRef(kind: CborValueKind.String, strVal: ""))
    else:
      return ok(CborValueRef(kind: param.kind.paramTypeToCborKind))
      # return err("Missing value for parameter '" & param.name & "'")

  ok case param.kind
  of ptString, ptUnknown:
    CborValueRef(kind: CborValueKind.String, strVal: param.value)
  of ptBytes:
    try:
      CborValueRef(kind: CborValueKind.Bytes, bytesVal: hexToSeqByte(param.value))
    except ValueError as ex:
      return err("Invalid hex for parameter '" & param.name & "': " & ex.msg)
  of ptBool:
    let lower = param.value.strip().toLowerAscii
    if lower == "true" or lower == "1":
      CborValueRef(kind: CborValueKind.Bool, boolVal: true)
    elif lower == "false" or lower == "0":
      CborValueRef(kind: CborValueKind.Bool, boolVal: false)
    else:
      return err("Invalid bool for parameter '" & param.name & "'; expected true/false")
  of ptFloat64:
    try:
      CborValueRef(kind: CborValueKind.Float, floatVal: parseFloat(param.value))
    except ValueError as ex:
      return err("Invalid float64 for parameter '" & param.name & "': " & ex.msg)
  of ptUint8, ptUint16, ptUint32, ptUint64:
    try:
      let n = parseBiggestUInt(param.value)
      let maxValue =
        case param.kind
        of ptUint8:
          uint64(high(uint8))
        of ptUint16:
          uint64(high(uint16))
        of ptUint32:
          uint64(high(uint32))
        else:
          uint64(high(uint64))
      if n > maxValue:
        return err("Value for parameter '" & param.name & "' exceeds " & $maxValue)
      CborValueRef(
        kind: CborValueKind.Unsigned,
        numVal: CborNumber(sign: CborSign.None, integer: n),
      )
    except ValueError as ex:
      return
        err("Invalid unsigned integer for parameter '" & param.name & "': " & ex.msg)
  of ptInt8, ptInt16, ptInt32, ptInt64:
    try:
      let n = parseBiggestInt(param.value)
      let (minValue, maxValue) =
        case param.kind
        of ptInt8:
          (int64(low(int8)), int64(high(int8)))
        of ptInt16:
          (int64(low(int16)), int64(high(int16)))
        of ptInt32:
          (int64(low(int32)), int64(high(int32)))
        else:
          (int64(low(int64)), int64(high(int64)))
      if n < minValue or n > maxValue:
        return err("Value for parameter '" & param.name & "' out of range")
      if n < 0:
        CborValueRef(
          kind: CborValueKind.Negative,
          numVal: CborNumber(sign: CborSign.Neg, integer: uint64(-n - 1)),
        )
      else:
        CborValueRef(
          kind: CborValueKind.Unsigned,
          numVal: CborNumber(sign: CborSign.None, integer: uint64(n)),
        )
    except ValueError as ex:
      return err("Invalid integer for parameter '" & param.name & "': " & ex.msg)
  else:
    CborValueRef(kind: CborValueKind.String, strVal: param.value)

proc buildCborParams*(params: seq[MethodParam]): Result[seq[byte], string] =
  var paramMap: OrderedTable[string, CborValueRef] =
    initOrderedTable[string, CborValueRef]()
  for param in params:
    let parsed = paramValueToCbor(param)
    if parsed.isErr:
      return err(parsed.error)
    let cborVal = parsed.get
    if cborVal.isNil:
      continue
    paramMap[param.name] = cborVal
  try:
    ok(Cbor.encode(paramMap))
  except CatchableError as ex:
    err("CBOR encoding failed: " & ex.msg)
