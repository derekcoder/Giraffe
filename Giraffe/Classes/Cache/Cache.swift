//
//  Cache.swift
//  Giraffe
//
//  Created by Derek on 12/12/18.
//

import Foundation

extension Date {
    var fileAttributeDate: Date {
        return Date(timeIntervalSince1970: ceil(timeIntervalSince1970))
    }
}

public enum CacheMode {
    case onlyReload
    case onlyCache
    case cacheThenReload
}

final public class Cache {
    let cacheDirectoryURL: URL
    
    init() throws {
        let url = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let cacheName = "com.derekcoder.Giraffe"
        self.cacheDirectoryURL = url.appendingPathComponent(cacheName, isDirectory: true)
        
        prepareDirectory()
    }
    
    func prepareDirectory() {
        let path = cacheDirectoryURL.path
        guard !FileManager.default.fileExists(atPath: path) else { return }
        try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }
    
    func store(data: Data, forKey key: String) {
        let fileURL = cacheFileURL(forKey: key)
        
        let now = Date()
        let attributes: [FileAttributeKey: Any] = [.creationDate: now.fileAttributeDate]
        
        FileManager.default.createFile(atPath: fileURL.path, contents: data, attributes: attributes)
    }
    
    func data(forKey key: String) -> Data? {
        let fileURL = cacheFileURL(forKey: key)
        let filePath = fileURL.path
        guard FileManager.default.fileExists(atPath: filePath) else { return nil }
        
        let data = try? Data(contentsOf: fileURL)
        return data
    }
    
    func isCached(forKey key: String) -> Bool {
        guard let _ = data(forKey: key) else { return false }
        return true
    }
    
    func remove(forKey key: String) {
        let fileURL = cacheFileURL(forKey: key)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    func removeAll() {
        try? FileManager.default.removeItem(at: cacheDirectoryURL)
        prepareDirectory()
    }
    
    func cacheFileURL(forKey key: String) -> URL {
        let fileName = "\(key.md5).data"
        return cacheDirectoryURL.appendingPathComponent(fileName)
    }
}
