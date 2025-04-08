//
//  parser.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 25.03.2025.
//

import Foundation

func getSwiftFiles(in directory: String) -> [String] {
    let fileManager = FileManager.default
    var swiftFiles: [String] = []

    if let enumerator = fileManager.enumerator(atPath: directory) {
        for case let file as String in enumerator {
            if file.hasSuffix(".swift") {
                swiftFiles.append((directory as NSString).appendingPathComponent(file))
            }
        }
    }

    return swiftFiles
}

enum ASTNode {
    case `class`(name: String, inherits: [String], members: [ASTNode])
    case `struct`(name: String, members: [ASTNode])
    case `enum`(name: String, cases: [String])
    case `protocol`(name: String, inherits: [String])
    case property(name: String, type: String)
    case function(name: String, returnType: String, parameters: [(String, String)])
}

func parseSwiftFile(_ code: String) -> [ASTNode] {
    var nodes: [ASTNode] = []

    let classPattern = "class\\s+(\\w+)(?::\\s*([\\w, ]+))?\\s*\\{"
    let structPattern = "struct\\s+(\\w+)\\s*\\{"
    let protocolPattern = "protocol\\s+(\\w+)(?::\\s*([\\w, ]+))?"
    let enumPattern = "enum\\s+(\\w+)\\s*\\{"
    let propertyPattern = "(let|var)\\s+(\\w+)\\s*:\\s*([\\w<>, ]+)"
    let functionPattern = "func\\s+(\\w+)\\s*\\(([^)]*)\\)\\s*(?:->\\s*([\\w<>, ]+))?"

    let nsCode = code as NSString
    let fullRange = NSRange(location: 0, length: nsCode.length)

    func extractMembers(from body: String) -> [ASTNode] {
        var members: [ASTNode] = []
        let nsBody = body as NSString
        let bodyRange = NSRange(location: 0, length: nsBody.length)

        // Properties
        let propRegex = try! NSRegularExpression(pattern: propertyPattern)
        for match in propRegex.matches(in: body, range: bodyRange) {
            let name = nsBody.substring(with: match.range(at: 2))
            let type = nsBody.substring(with: match.range(at: 3))
            members.append(.property(name: name, type: type))
        }

        // Functions
        let funcRegex = try! NSRegularExpression(pattern: functionPattern)
        for match in funcRegex.matches(in: body, range: bodyRange) {
            let name = nsBody.substring(with: match.range(at: 1))
            let paramsString = nsBody.substring(with: match.range(at: 2))
            let returnType = match.range(at: 3).location != NSNotFound ? nsBody.substring(with: match.range(at: 3)) : "Void"

            let params: [(String, String)] = paramsString.split(separator: ",").compactMap {
                let parts = $0.split(separator: ":").map { $0.trimmingCharacters(in: .whitespaces) }
                return parts.count == 2 ? (parts[0], parts[1]) : nil
            }

            members.append(.function(name: name, returnType: returnType, parameters: params))
        }

        return members
    }

    // Classes
    let classRegex = try! NSRegularExpression(pattern: classPattern)
    for match in classRegex.matches(in: code, range: fullRange) {
        let name = nsCode.substring(with: match.range(at: 1))
        let inherits = match.range(at: 2).location != NSNotFound ? nsCode.substring(with: match.range(at: 2)).components(separatedBy: ", ") : []
        let bodyStart = match.range.location + match.range.length
        let body = extractBody(from: code, startingAt: bodyStart)
        nodes.append(.class(name: name, inherits: inherits, members: extractMembers(from: body)))
    }

    // Structs
    let structRegex = try! NSRegularExpression(pattern: structPattern)
    for match in structRegex.matches(in: code, range: fullRange) {
        let name = nsCode.substring(with: match.range(at: 1))
        let bodyStart = match.range.location + match.range.length
        let body = extractBody(from: code, startingAt: bodyStart)
        nodes.append(.struct(name: name, members: extractMembers(from: body)))
    }

    // Enums
    let enumRegex = try! NSRegularExpression(pattern: enumPattern)
    for match in enumRegex.matches(in: code, range: fullRange) {
        let name = nsCode.substring(with: match.range(at: 1))
        let bodyStart = match.range.location + match.range.length
        let body = extractBody(from: code, startingAt: bodyStart)
        let cases = body.components(separatedBy: .newlines).compactMap { line -> String? in
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("case ") {
                return line.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "case ", with: "")
            }
            return nil
        }
        nodes.append(.enum(name: name, cases: cases))
    }

    // Protocols
    let protocolRegex = try! NSRegularExpression(pattern: protocolPattern)
    for match in protocolRegex.matches(in: code, range: fullRange) {
        let name = nsCode.substring(with: match.range(at: 1))
        let inherits = match.range(at: 2).location != NSNotFound ? nsCode.substring(with: match.range(at: 2)).components(separatedBy: ", ") : []
        nodes.append(.protocol(name: name, inherits: inherits))
    }

    return nodes
}

private func extractBody(from code: String, startingAt index: Int) -> String {
    var depth = 1
    var body = ""
    let lowerBound = code.index(code.startIndex, offsetBy: index)
    let chars = Array(code[lowerBound..<code.endIndex])

    for c in chars {
        if c == "{" { depth += 1 }
        else if c == "}" { depth -= 1 }

        if depth == 0 { break }
        body.append(c)
    }

    return body
}
