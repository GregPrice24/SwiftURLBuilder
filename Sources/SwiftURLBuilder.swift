//
//  SwiftURLBuilder.swift
//  SwiftURLBuilder
//
//  Created by Gregory Price on 9/26/15.
//  Copyright © 2015 Gregory Price. All rights reserved.
//

import Foundation

public struct URLContainer {
    public var stringValue: String?
}

public enum URLBuildError: Error {
    case noHostProvided(description: String)
    case multipleHostsProvided(description: String)
    case invalidBuildComponent(description: String)
    var localizedDescription: String {
        switch self {
        case .noHostProvided(let desc):
            return desc
        case .multipleHostsProvided(let desc):
            return desc
        case .invalidBuildComponent(let desc):
            return desc
        }
    }
}

public final class URLBuilder {
    private var components: [URLComponent]
    public var urlContainer: URLContainer?
    
    public init(components: [URLComponent]) {
        self.components = components.sorted(by: <)
    }
    
    public func remove(_ component: URLComponent)  {
        components = components.filter { $0 != component }
        components = components.sorted(by: <)
        do {
            try build()
        } catch let error as URLBuildError {
            debugPrint(error.localizedDescription)
        } catch {
            debugPrint("Unknown error occured, method: \(#function)")
        }
    }
    
    public func add(_ component: URLComponent) {
        components.append(component)
        components = components.sorted(by: <)
        do {
            try build()
        } catch let error as URLBuildError {
            debugPrint(error.localizedDescription)
        } catch {
            debugPrint("Unknown error occured, method: \(#function)")
        }
    }
    
    @discardableResult public func build() throws -> Self {
        let root = components.filter { $0.type == .Host }
        if urlContainer == nil {
            urlContainer = URLContainer()
        }
        
        if root.count == 1 {
            let stack = Stack<URLComponent>()
            let s = ""
            urlContainer?.stringValue = components.reduce(s, {
                var current = $0
                if let c = stack.peek() {
                    if c.type == .Host && $1.type == .Path {
                        current += "/"
                    } else if (c.type == .Host || c.type == .Path) && $1.type == .QueryParameter {
                        current += "?"
                    }
                    stack.pop()
                }
                
                stack.push($1)
                return current + ($1.rawValue ?? "")
            })
        } else if root.count > 1 {
            throw URLBuildError.multipleHostsProvided(description: "Invalid URL specified. The URL must contain only one host.")
        } else {
            throw URLBuildError.noHostProvided(description:
                "Invalid URL specified. The URL must contain a host.")
        }
        
        return self
    }
}

public enum URLComponentType {
    case Path
    case Host
    case QueryParameter
    case NotAType
}

open class URLComponent {
    
    open var key:String?
    open var satellite:String?
    open var type: URLComponentType = .NotAType
    public var rawValue:String? {
        guard let localSatellite = satellite else {
            return nil
        }
        
        let s = ""
        var result:String?
        
        switch type {
        case .Host:
            let stack = Stack<String>()
            var isHTTP = false
            result = localSatellite.reduce(s, {
                if $1 == "/" {
                    let pos = stack.count
                    if let front = stack.pop(), let back = stack.peek() {
                        if pos >= 5 && pos < 8 {
                            if front == ":" {
                                stack.push(front)
                                stack.push("\($1)")
                                return $0 + "\($1)"
                            } else if back == ":" && front == "/" {
                                isHTTP = true
                                stack.push(front)
                                stack.push("\($1)")
                                return $0 + "\($1)"
                            }
                        }
                    }
                }
                
                if !isHTTP {
                    stack.push("\($1)")
                } else {
                    stack.pop()
                }
                
                if "\($1)".rangeOfCharacter(from: CharacterSet.urlHostAllowed.inverted) == nil {
                    return $0 + "\($1)"
                }
                
                stack.pop()
                return $0
            })
        case .Path:
            let len = localSatellite.count - 1
            var idx = 0
            result = localSatellite.reduce(s, {
                if "\($1)".rangeOfCharacter(from: CharacterSet.urlPathAllowed.inverted) == nil {
                    if !($1 == "/" && (idx == 0 || idx == len)) {
                        idx += 1
                        return $0 + "\($1)"
                    }
                }
                idx += 1
                return $0
            })
        case .QueryParameter:
            guard let _ = key else {
                debugPrint("URL query parameter requires a key to be set.")
                return nil
            }
            
            result = localSatellite.reduce(key!.reduce(s, {
                "\($1)".rangeOfCharacter(from: CharacterSet.urlQueryAllowed.inverted) == nil ? $0 + "\($1)" : $0
            }) + "=", {
                "\($1)".rangeOfCharacter(from: CharacterSet.urlQueryAllowed.inverted) == nil ? $0 + "\($1)" : $0
            })
        case .NotAType:
            break
        }
        
        return result
    }
    
    public convenience init(key: String, satellite: String, type: URLComponentType) {
        self.init()
        self.key = key
        self.satellite = satellite
        self.type = type
    }
    
    public convenience init(satellite: String, type: URLComponentType) {
        self.init()
        self.satellite = satellite
        self.type = type
    }
}

extension URLComponent: Equatable {
    public static func == (lhs: URLComponent, rhs: URLComponent) -> Bool {
        return lhs.type == rhs.type && lhs.key == rhs.key &&
            lhs.satellite == rhs.satellite
    }
}

extension URLComponent: Comparable {
    public static func > (lhs: URLComponent, rhs: URLComponent) -> Bool {
        return (lhs.type == .QueryParameter && (rhs.type == .Path || rhs.type == .Host || rhs.type == .NotAType))
            || lhs.type == .Path && (rhs.type == .Host || rhs.type == .NotAType)
            || lhs.type == .Host && rhs.type == .NotAType
    }
    
    public static func <= (lhs: URLComponent, rhs: URLComponent) -> Bool {
        return (lhs.type == .Host && (rhs.type == .Path || rhs.type == .QueryParameter))
            || (lhs.type == .Path && rhs.type == .QueryParameter) || lhs == rhs
    }
    
    public static func < (lhs: URLComponent, rhs: URLComponent) -> Bool {
        return (lhs.type == .Host && (rhs.type == .Path || rhs.type == .QueryParameter))
            || lhs.type == .Path && rhs.type == .QueryParameter
    }
}

fileprivate class Stack<T> {
    public var count: Int = 0
    private var objects: [T]
    
    init() {
        objects = [T]()
    }
    
    @discardableResult func pop() -> T? {
        guard count > 0 else {
            return nil
        }
        
        count -= 1
        return objects.removeLast()
    }
    
    func push(_ obj: T) {
        objects.append(obj)
        count += 1
    }
    
    func peek() -> T? {
        guard count > 0 else {
            return nil
        }
        return objects[count - 1]
    }
}
