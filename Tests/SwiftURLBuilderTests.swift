import XCTest
@testable import SwiftURLBuilder

class SwiftURLBuilderTests: XCTestCase {
    func testRawHostRepresentation()  {
        let hostComponent = URLComponent(satellite: "http://www.espn.com/", type: .Host)
        if let raw = hostComponent.rawValue {
            assert(raw == "http://www.espn.com", "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        } else {
            assert(false, "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        }
        
        hostComponent.satellite = "www.espn.com$#@"
        if let raw = hostComponent.rawValue {
            assert(raw == "www.espn.com$", "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        } else {
            assert(false, "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        }
        
        hostComponent.satellite = "www.espn.com$#@/"
        if let raw = hostComponent.rawValue {
            assert(raw == "www.espn.com$", "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        } else {
            assert(false, "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        }
        
        hostComponent.satellite = "www.espn.com"
        if let raw = hostComponent.rawValue {
            assert(raw == "www.espn.com", "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        } else {
            assert(false, "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        }
        
        hostComponent.satellite = "////https://www.espn.com/"
        if let raw = hostComponent.rawValue {
            assert(raw == "https://www.espn.com", "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        } else {
            assert(false, "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        }
        
        hostComponent.satellite = "////https://www//.e//sp/n//.co/m/"
        if let raw = hostComponent.rawValue {
            assert(raw == "https://www.espn.com", "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        } else {
            assert(false, "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        }
        
        hostComponent.satellite = "////http:///www//.e//sp/n//.co/m/"
        if let raw = hostComponent.rawValue {
            assert(raw == "http://www.espn.com", "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        } else {
            assert(false, "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        }
    }
    
    func testRawPathRepresentation() {
        let pathComponent = URLComponent(satellite: "nba", type: .Path)
        if let raw = pathComponent.rawValue {
            assert(raw == "nba", "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        } else {
            assert(false, "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        }
        
        pathComponent.satellite = "nba??"
        if let raw = pathComponent.rawValue {
            assert(raw == "nba", "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        } else {
            assert(false, "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        }
        
        pathComponent.satellite = "nba/"
        if let raw = pathComponent.rawValue {
            assert(raw == "nba", "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        } else {
            assert(false, "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        }
        
        pathComponent.satellite = "/nba/"
        if let raw = pathComponent.rawValue {
            assert(raw == "nba", "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        } else {
            assert(false, "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        }
    }
    
    func testRawQueryRepresentation() {
        let queryComponent = URLComponent(key: "ls", satellite: "9393#", type: .QueryParameter)
        if let raw = queryComponent.rawValue {
            assert(raw == "ls=9393", "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        } else {
            assert(false, "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        }
        
        queryComponent.key = "##ls###"
        if let raw = queryComponent.rawValue {
            assert(raw == "ls=9393", "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        } else {
            assert(false, "Test failed at file: \(#file) method: \(#function), line: \(#line)")
        }
    }
    
    func testURLCreate() {
        do {
            let url = try URLBuilder(components: [URLComponent(satellite: "http://www.espn.com/", type: .Host), URLComponent(satellite: "nba", type: .Path), URLComponent(key: "ls", satellite: "9393#", type: .QueryParameter)]).build().urlContainer!
            assert(url.stringValue == "http://www.espn.com/nba?ls=9393")
        } catch let error as URLBuildError {
            debugPrint(error.localizedDescription + " Location: file: \(#file) method: \(#function), line: \(#line)")
            assert(false)
        } catch {
            debugPrint("Unknown error occured at file: \(#file) method: \(#function), line: \(#line)")
            assert(false)
        }
    }
    
    func testURLBuild() {
        let queryComponent = URLComponent(key: "ls", satellite: "9393#", type: .QueryParameter)
        let pathComponent = URLComponent(satellite: "nba", type: .Path)
        let hostComponent = URLComponent(satellite: "http://www.espn.com/", type: .Host)
        
        let builder:URLBuilder = URLBuilder(components: [hostComponent, pathComponent, queryComponent])
        do {
            let url = try builder.build().urlContainer!
            assert(url.stringValue == "http://www.espn.com/nba?ls=9393")
        } catch let error as URLBuildError {
            debugPrint(error.localizedDescription + " Location: file: \(#file) method: \(#function), line: \(#line)")
            assert(false)
        } catch {
            debugPrint("Unknown error occured at file: \(#file) method: \(#function), line: \(#line)")
            assert(false)
        }
        
        builder.remove(queryComponent)
        queryComponent.satellite = "8789"
        builder.add(queryComponent)
        do {
            let url = try builder.build().urlContainer!
            assert(url.stringValue == "http://www.espn.com/nba?ls=8789")
        } catch let error as URLBuildError {
            debugPrint(error.localizedDescription + " Location: file: \(#file) method: \(#function), line: \(#line)")
            assert(false)
        } catch {
            debugPrint("Unknown error occured at file: \(#file) method: \(#function), line: \(#line)")
            assert(false)
        }
        
        builder.remove(pathComponent)
        pathComponent.satellite = "ncaab"
        builder.add(pathComponent)
        do {
            let url = try builder.build().urlContainer!
            assert(url.stringValue == "http://www.espn.com/ncaab?ls=8789")
        } catch let error as URLBuildError {
            debugPrint(error.localizedDescription + " Location: file: \(#file) method: \(#function), line: \(#line)")
            assert(false)
        } catch {
            debugPrint("Unknown error occured at file: \(#file) method: \(#function), line: \(#line)")
            assert(false)
        }
        
        builder.remove(hostComponent)
        do {
            try builder.build()
        } catch _ as URLBuildError {
            assert(true)
        } catch {
            assert(false)
        }
        
        builder.add(hostComponent)
        builder.add(hostComponent)
        do {
            try builder.build()
        } catch _ as URLBuildError {
            assert(true)
        } catch {
            assert(false)
        }
    }
    
    static var allTests = [
        ("testRawHostRepresentation", testRawHostRepresentation),
        ("testRawPathRepresentation", testRawPathRepresentation),
        ("testRawQueryRepresentation", testRawQueryRepresentation),
        ("testURLCreate", testURLCreate),
        ("testURLBuild", testURLBuild),
    ]
}
