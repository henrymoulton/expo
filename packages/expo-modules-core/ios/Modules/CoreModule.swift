// The core module that describes the `global.expo` object.
internal final class CoreModule: Module {
  internal func definition() -> ModuleDefinition {
    // Expose some common classes and maybe even the `modules` host object in the future.
    Function("uuidv4") { () -> String in
      return UUID().uuidString.lowercased()
    }

    Function("uuidv5") { (name: String, namespace: String) -> String in
      guard let namespaceUuid = UUID(uuidString: namespace) else {
        throw InvalidNamespaceException(namespace)
      }

      return uuidv5(name: name, namespace: namespaceUuid).uuidString.lowercased()
    }

    // TextEncoder API
    // https://encoding.spec.whatwg.org/#textencoder
    Class("TextEncoder") {
      // TODO: This throws:  ERROR  Error: NativePropertyUnavailableException: Native property 'encoding' 
      // is no longer available in memory (at ExpoModulesCore/PropertyComponent.swift:142)
      Property("encoding") {
        return "utf-8"
      }

      // https://developer.mozilla.org/en-US/docs/Web/API/TextEncoder/encodeInto
      Function("encodeInto") { (source: String, destination: Uint8Array) -> TextEncoderEncodeIntoResult in
        let bytes = Array(source.utf8)
        let count = min(bytes.count, destination.length)
          
        for i in 0..<count {
            destination[i] = bytes[i]
        }

        return TextEncoderEncodeIntoResult(read: source.count, written: count)
      }

      Function("encode") { (input: String) -> [UInt8] in
        // TODO: Return Uint8Array directly
        return Array(input.utf8)
      }
    }

    // https://encoding.spec.whatwg.org/#textdecoder
    Class("TextDecoder") {
        var _options: TextDecoderOptions = TextDecoderOptions()
        var _encoding: String = "utf-8"
        
        Constructor { (label: String?, options: TextDecoderOptions?) in
            if let label = label {
                _encoding = normalizeEncoding(input: label)
            }
            if let options = options {
                _options = options
            }
        }
        
        Property("encoding") {
            return _encoding
        }
        Property("fatal") {
            return _options.fatal
        }
        Property("ignoreBOM") {
            return _options.ignoreBOM
        }
        
        Function("decode") { (input: Uint8Array, options: TextDecodeOptions?) -> String? in
            let nativeEncoding = setEncoding(enc: _encoding)
            
            // TODO: Support all the options, and _options.
            // TODO: Support all input types: Uint8Array | Int8Array | Uint16Array | Int16Array | Int32Array
            return String(bytes: input.buffer, encoding: nativeEncoding)
        }
    }
  }
}

// https://encoding.spec.whatwg.org/encodings.json
let ENCODING_MAP: [String: Set<String>] = [
    "utf-8":["unicode-1-1-utf-8","unicode11utf8","unicode20utf8","utf-8","utf8","x-unicode20utf8"],
    "ibm866":["866","cp866","csibm866","ibm866"],
    "iso-8859-2":["csisolatin2","iso-8859-2","iso-ir-101","iso8859-2","iso88592","iso_8859-2","iso_8859-2:1987","l2","latin2"],
    "iso-8859-3":["csisolatin3","iso-8859-3","iso-ir-109","iso8859-3","iso88593","iso_8859-3","iso_8859-3:1988","l3","latin3"],
    "iso-8859-4":["csisolatin4","iso-8859-4","iso-ir-110","iso8859-4","iso88594","iso_8859-4","iso_8859-4:1988","l4","latin4"],
    "iso-8859-5":["csisolatincyrillic","cyrillic","iso-8859-5","iso-ir-144","iso8859-5","iso88595","iso_8859-5","iso_8859-5:1988"],
    "iso-8859-6":["arabic","asmo-708","csiso88596e","csiso88596i","csisolatinarabic","ecma-114","iso-8859-6","iso-8859-6-e","iso-8859-6-i","iso-ir-127","iso8859-6","iso88596","iso_8859-6","iso_8859-6:1987"],
    "iso-8859-7":["csisolatingreek","ecma-118","elot_928","greek","greek8","iso-8859-7","iso-ir-126","iso8859-7","iso88597","iso_8859-7","iso_8859-7:1987","sun_eu_greek"],
    "iso-8859-8":["csiso88598e","csisolatinhebrew","hebrew","iso-8859-8","iso-8859-8-e","iso-ir-138","iso8859-8","iso88598","iso_8859-8","iso_8859-8:1988","visual"],
    "iso-8859-8-i":["csiso88598i","iso-8859-8-i","logical"],"iso-8859-10":["csisolatin6","iso-8859-10","iso-ir-157","iso8859-10","iso885910","l6","latin6"],
    "iso-8859-13":["iso-8859-13","iso8859-13","iso885913"],"iso-8859-14":["iso-8859-14","iso8859-14","iso885914"],
    "iso-8859-15":["csisolatin9","iso-8859-15","iso8859-15","iso885915","iso_8859-15","l9"],
    "iso-8859-16":["iso-8859-16"],
    "koi8-r":["cskoi8r","koi","koi8","koi8-r","koi8_r"],
    "koi8-u":["koi8-ru","koi8-u"],
    "macintosh":["csmacintosh","mac","macintosh","x-mac-roman"],
    "windows-874":["dos-874","iso-8859-11","iso8859-11","iso885911","tis-620","windows-874"],
    "windows-1250":["cp1250","windows-1250","x-cp1250"],
    "windows-1251":["cp1251","windows-1251","x-cp1251"],
    "windows-1252":["ansi_x3.4-1968","ascii","cp1252","cp819","csisolatin1","ibm819","iso-8859-1","iso-ir-100","iso8859-1","iso88591","iso_8859-1","iso_8859-1:1987","l1","latin1","us-ascii","windows-1252","x-cp1252"],"windows-1253":["cp1253","windows-1253","x-cp1253"],
    "windows-1254":["cp1254","csisolatin5","iso-8859-9","iso-ir-148","iso8859-9","iso88599","iso_8859-9","iso_8859-9:1989","l5","latin5","windows-1254","x-cp1254"],"windows-1255":["cp1255","windows-1255","x-cp1255"],"windows-1256":["cp1256","windows-1256","x-cp1256"],
    "windows-1257":["cp1257","windows-1257","x-cp1257"],"windows-1258":["cp1258","windows-1258","x-cp1258"],
    "x-mac-cyrillic":["x-mac-cyrillic","x-mac-ukrainian"],"gbk":["chinese","csgb2312","csiso58gb231280","gb2312","gb_2312","gb_2312-80","gbk","iso-ir-58","x-gbk"],
    "gb18030":["gb18030"],"big5":["big5","big5-hkscs","cn-big5","csbig5","x-x-big5"],"euc-jp":["cseucpkdfmtjapanese","euc-jp","x-euc-jp"],
    "iso-2022-jp":["csiso2022jp","iso-2022-jp"],"shift_jis":["csshiftjis","ms932","ms_kanji","shift-jis","shift_jis","sjis","windows-31j","x-sjis"],
    "euc-kr":["cseuckr","csksc56011987","euc-kr","iso-ir-149","korean","ks_c_5601-1987","ks_c_5601-1989","ksc5601","ksc_5601","windows-949"],
    "utf-16be":["unicodefffe","utf-16be"],
    "utf-16le":["csunicode","iso-10646-ucs-2","ucs-2","unicode","unicodefeff","utf-16","utf-16le"]
]

func normalizeEncoding(input: String) -> String {
    for (key, values) in ENCODING_MAP {
        if values.contains(input) {
            return key
        }
    }
    return "utf-8"
}


func setEncoding(enc: String) -> String.Encoding {
    let encodings: [String: String.Encoding] = [
        "iso-2022-jp":  .iso2022JP,
        "euc-jp":       .japaneseEUC,
        "macintosh":    .macOSRoman,
        "iso-8859-2":   .isoLatin2,
        "utf-16be":     .utf16BigEndian,
        "utf-16le":     .utf16LittleEndian,
        "utf-16":       .utf16LittleEndian,
        "windows-1250": .windowsCP1250,
        "windows-1251": .windowsCP1251,
        "windows-1252": .windowsCP1252,
        "windows-1253": .windowsCP1253,
        "windows-1254": .windowsCP1254,
    ]
    
    return encodings[enc] ?? .utf8
}

// https://encoding.spec.whatwg.org/#textdecoderoptions
struct TextDecoderOptions: Record {
    @Field
    var fatal: Bool = false
    @Field
    var ignoreBOM: Bool = false
}

struct TextDecodeOptions: Record {
    @Field
    var stream: Bool = false
}

struct TextEncoderEncodeIntoResult: Record {
    @Field
    var read: Int = 0
    
    @Field
    var written: Int = 0
}
