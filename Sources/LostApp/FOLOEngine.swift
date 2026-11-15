import Foundation

public class FOLOEngine {
    public static let shared = FOLOEngine()
    
    public func organizeArchive(baseLocation: URL) {
        let fileManager = FileManager.default
        let inbox = baseLocation.appendingPathComponent("INBOX")
        let cleanArchive = baseLocation.appendingPathComponent("CLEAN_ARCHIVE")
        let trash = baseLocation.appendingPathComponent("DUPLICATES_TRASH")
        
        try? fileManager.createDirectory(at: inbox, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: cleanArchive, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: trash, withIntermediateDirectories: true)
        
        guard let files = try? fileManager.contentsOfDirectory(at: inbox, includingPropertiesForKeys: nil) else { return }
        
        for fileURL in files {
            let filename = fileURL.lastPathComponent
            if filename.hasPrefix(".") { continue }
            
            let parts = filename.split(separator: "_")
            let prefix = parts.first.map(String.init) ?? "UNKNOWN"
            
            var targetFolder = cleanArchive
            
            if prefix.lowercased().hasSuffix("s") && prefix.count == 5 {
                // Decade folder (e.g. 1980s)
                targetFolder = cleanArchive.appendingPathComponent(prefix.lowercased()).appendingPathComponent("Undated")
            } else if prefix.count >= 4 && prefix.prefix(4).allSatisfy({ $0.isNumber }) {
                // Year / Date folder (e.g. 1940 or 1940-01-05)
                let year = String(prefix.prefix(4))
                let decade = String(year.prefix(3)) + "0s"
                targetFolder = cleanArchive.appendingPathComponent(decade).appendingPathComponent(year)
            } else {
                // Unknown
                targetFolder = cleanArchive.appendingPathComponent("Undated")
            }
            
            try? fileManager.createDirectory(at: targetFolder, withIntermediateDirectories: true)
            let destinationURL = targetFolder.appendingPathComponent(filename)
            
            if fileManager.fileExists(atPath: destinationURL.path) {
                try? fileManager.removeItem(at: destinationURL)
            }
            try? fileManager.moveItem(at: fileURL, to: destinationURL)
        }
    }
}