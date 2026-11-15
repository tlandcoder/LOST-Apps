import Foundation

public class SMAREngine {
    public static let shared = SMAREngine()
    
    private var counterFile: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("smar_counter.json")
    }
    
    public func getNextCounter() -> String {
        var count = 1
        if let data = try? Data(contentsOf: counterFile),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Int],
           let savedCount = json["count"] {
            count = savedCount
        }
        
        let newCount = count + 1
        let json: [String: Int] = ["count": newCount]
        if let data = try? JSONSerialization.data(withJSONObject: json) {
            try? data.write(to: counterFile)
        }
        
        return String(format: "%04d", count)
    }
    
    public func extractDateInfo(filename: String) -> String {
        // 1. Full YYYY-MM-DD pattern
        let fullDateRegex = #"(\b(1[5-9]\d{2}|20\d{2})[-/.](0[1-9]|1[0-2])[-/.](0[1-9]|[12]\d|3[01])\b)"#
        if let match = filename.range(of: fullDateRegex, options: .regularExpression) {
            let matchedStr = String(filename[match])
            return matchedStr.replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: ".", with: "-")
        }
        
        // 2. Standalone year -> YYYY-00-00
        let allYears = matches(for: #"\b(1[5-9]\d{2}|20\d{2})\b"#, in: filename)
        if allYears.count == 1 {
            return "\(allYears[0])-00-00"
        }
        
        // 3. Decade check -> 1980s
        let decadeRegex = #"\b(1[5-9]\d{2}s|20\d{2}s)\b"#
        if let match = filename.range(of: decadeRegex, options: [.regularExpression, .caseInsensitive]) {
            return String(filename[match]).lowercased()
        }
        
        return "UNKNOWN"
    }
    
    private func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range) }
        } catch {
            return []
        }
    }
    
    public func smartRename(fileURL: URL) -> URL? {
        let filename = fileURL.lastPathComponent
        let ext = fileURL.pathExtension
        let directory = fileURL.deletingLastPathComponent()
        
        let dateInfo = extractDateInfo(filename: filename)
        let uniqueID = getNextCounter()
        
        let newFilename = "\(dateInfo)_\(uniqueID).\(ext)"
        let newURL = directory.appendingPathComponent(newFilename)
        
        do {
            try FileManager.default.moveItem(at: fileURL, to: newURL)
            return newURL
        } catch {
            return nil
        }
    }
}