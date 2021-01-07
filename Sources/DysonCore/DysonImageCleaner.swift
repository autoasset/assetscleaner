//
//  DysonTool.swift
//  Dyson
//
//  Created by nxf on 2021/1/5.
//

import Foundation
import Files
import ArgumentParser

public struct DysonImageCleaner: ParsableCommand {
    @Flag(name: .shortAndLong, help: "Show detail progress.")
    var verbose = false
    
    @Option(name: .shortAndLong, help: "A group of folders to scan.")
    var scanFolders: [String] = []
    
    @Argument(help: "The path of autoAssets file.")
    var autoAssetsFile: String
    
    public init() {
    }
    
    mutating public func run() throws {
        let autoAssetsFile = URL(fileURLWithPath: self.autoAssetsFile)
        let scanFolders = self.scanFolders.compactMap { try? Folder(path: $0) }
        
        guard let assetsData = try? Data(contentsOf: autoAssetsFile),
              let expression = try? NSRegularExpression(pattern: "static var ([_1-9a-zA-Z]+)[^\"]+\"([^\"]+)", options: NSRegularExpression.Options(rawValue: 0)),
              let assetsString = String(data: assetsData, encoding: .utf8) as NSString? else {
            return
        }
        
        let matches  = expression.matches(in: assetsString as String,
                                          options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                          range: NSRange(location: 0, length: assetsString.length))
        var matchExpressions = matches.compactMap { match -> NSRegularExpression? in
            let assetVarName = assetsString.substring(with: match.range(at: 1))
            let assetFileName = assetsString.substring(with: match.range(at: 2))
            
            return try? NSRegularExpression(pattern: "\(assetVarName)|\(assetFileName)",
                                            options: NSRegularExpression.Options(rawValue: 0))
        }
        
        for folder in scanFolders where !matchExpressions.isEmpty {
            if verbose {
                print("scanning folder \(folder.path)")
            }
            
            for file in Array(folder.files.recursive) where !matchExpressions.isEmpty {
                if verbose {
                    print("scanning file \(file.path)")
                }
                
                autoreleasepool {
                    if let content = try? file.readAsString() {
                        let range = NSRange(location: 0, length: (content as NSString).length)
                        
                        for (index, expression) in matchExpressions.enumerated().reversed() {
                            if expression.firstMatch(in: content, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: range) != nil {
                                matchExpressions.remove(at: index)
                            }
                        }
                    }
                }
            }
        }
        
        print("$$$")
        for expression in matchExpressions {
            print("\(expression.pattern)")
        }
        print("$$$ total assets: \(matches.count)")
        print("$$$ unused assets: \(matchExpressions.count)")
    }
}
