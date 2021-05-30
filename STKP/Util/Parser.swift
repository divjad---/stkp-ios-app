//
//  Parser.swift
//  STKP
//
//  Created by David Trafela on 10/02/2021.
//

import Foundation
import CoreLocation

class Parser {
    private let coordinateParser = CoordinatesParser()
    
    func parseCoordinates(fromGpxFile filePath: String) -> [Point]? {
        guard let data = FileManager.default.contents(atPath: filePath) else { return nil }
        
        coordinateParser.prepare()
        
        let parser = XMLParser(data: data)
        parser.delegate = coordinateParser
        
        let success = parser.parse()
        
        guard success else { return nil }
        print(coordinateParser.coordinates.count)
        return coordinateParser.coordinates
    }
}

class CoordinatesParser: NSObject, XMLParserDelegate  {
    private(set) var coordinates = [Point]()
    
    var latF = Double()
    var lonF = Double()
    var name = String()
    var elementName = String()
    
    func prepare() {
        coordinates = [Point]()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "wpt" || elementName == "trkpt"{
            latF = Double()
            lonF = Double()
            name = String()
        }
        
        self.elementName = elementName
        
        guard elementName == "trkpt" || elementName == "wpt" else { return }
        guard let latString = attributeDict["lat"], let lonString = attributeDict["lon"] else { return }
        guard let lat = Double(latString), let lon = Double(lonString) else { return }
        guard let _ = CLLocationDegrees(exactly: lat), let _ = CLLocationDegrees(exactly: lon) else { return }
        
        latF = lat;
        lonF = lon;
        
        //coordinates.append(CLLocationCoordinate2D(latitude: latDegrees, longitude: lonDegrees))
        //coordinates.append(Point(name: String("david"), latitude: latDegrees, longitude: lonDegrees))
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if(elementName == "wpt" || elementName == "trkpt"){
            let point = Point(name: self.name, latitude: CLLocationDegrees(exactly: self.latF)!, longitude: CLLocationDegrees(exactly: self.lonF)!)
            coordinates.append(point)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (!data.isEmpty) {
            if self.elementName == "name" {
                name += data
            }
        }
    }
}
