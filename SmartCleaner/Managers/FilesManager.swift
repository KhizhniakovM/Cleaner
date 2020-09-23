//
//  FilesManager.swift
//  SmartCleaner
//
//  Created by Luchik on 09.06.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit

public class FilesManager {
    // MARK: - Errors
    enum Error: Swift.Error {
        case fileAlreadyExists, invalidDirectory, writtingFailed
    }
    
    // MARK: - Properties
    let fileManager: FileManager
    
    // MARK: - Initializer
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    // MARK: - Methods
    func checkIfFileExists(_ fileName: String) -> Bool{
        guard let url = makeURL(forFileNamed: fileName) else {
            return false
        }
        return fileManager.fileExists(atPath: url.path)
        
    }
    func save(fileNamed: String, data: Data, _ handler: ((_ url: URL) -> ())) throws {
        guard let url = makeURL(forFileNamed: fileNamed) else {
            throw Error.invalidDirectory
        }
        if fileManager.fileExists(atPath: url.path) {
            throw Error.fileAlreadyExists
        }
        do {
            try data.write(to: url)
            handler(url)
            print("File saved! \(url.absoluteString)")
        } catch {
            debugPrint(error)
            throw Error.writtingFailed
        }
    }
    func rename(_ url: URL, newName: String) throws -> URL{
        guard let newUrl = makeURL(forFileNamed: newName) else {
            throw Error.invalidDirectory
        }
        try fileManager.moveItem(at: url, to: newUrl)
        return newUrl
    }
    func delete(_ url: URL) throws{
        try fileManager.removeItem(at: url)
    }
    public func makeURL(forFileNamed fileName: String) -> URL? {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(fileName)
    }
    
    public func loadImage(fileName: String) -> UIImage? {
        guard let url = makeURL(forFileNamed: fileName) else {
            return nil
        }
        do {
            let imageData = try Data(contentsOf: url)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
}
