import Foundation

extension Data {
    var mimeType: String {
        var buffer = UInt8(0)
        copyBytes(to: &buffer, count: 1)
        
        switch buffer {
        case 0xFF: return "image/jpeg"
        case 0x89: return "image/png"
        case 0x47: return "image/gif"
        case 0x49, 0x4D: return "image/tiff"
        case 0x25: return "application/pdf"
        case 0xD0: return "application/vnd"
        case 0x46: return "text/plain"
        default: return "application/octet-stream"
        }
    }
    
    var jsonString: String? {
        if let jsonObject = try? JSONSerialization.jsonObject(with: self),
            let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]) {
            return String(data: data, encoding: .utf8)
        }
        return String(data: self, encoding: .utf8)
    }
    
    var json: [String: Any]? {
        guard let jsonObject = ((try? JSONSerialization.jsonObject(with: self, options: []) as? [String: Any]) as [String : Any]??)
        else { return nil }
        
        return jsonObject
    }

}
