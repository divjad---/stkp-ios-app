//
//  LocationViewModel.swift
//  STKP
//
//  Created by David Trafela on 10/02/2021.
//

import MapKit
import CoreLocation
import Combine

class LocationViewModel: NSObject, ObservableObject {
    let parser = Parser()
    var coordinates = [Point]()
    var points = [Point]()
    
    @Published var locations = [Int : [CLLocationCoordinate2D]]()
    
    var etape = [Etapa]()
    var kontrolneTocke = [KontrolnaTocka]()
    
    private let locationManager = CLLocationManager()
    
    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }
    
    var lastLocation: CLLocation?
    
    func load() {
        fetchLocations()
        getPoints()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        objectWillChange.send()
    }
    
    func loadSpecificEtapa(etapa: String){
        fetchSpecificLocations(etapa: etapa)
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        objectWillChange.send()
    }
    
    private func fetchSpecificLocations(etapa: String){
        let fileManager = FileManager.default
        
        var documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        documents.appendPathComponent("files")
        
        let fileName = etapa + ".gpx"
        
        if let numberRange = fileName.range(of: #"[0-9]+"#, options: .regularExpression){
            let number = Int(String(fileName[numberRange])) ?? 0
            
            print("Number: \(String(describing: number))")
            
            let etFile = documents.appendingPathComponent(fileName)
            
            if(fileManager.fileExists(atPath: etFile.relativePath)){
                locations[number] = [CLLocationCoordinate2D]()
                coordinates = parser.parseCoordinates(fromGpxFile: etFile.relativePath) ?? []
                
                coordinates = coordinates.drop(percentageToKeep: 75)
                coordinates.forEach{ point in
                    locations[number]?.append(point.coordinate)
                }
            }
        }
        
        do{
            let etJsonFile = documents.appendingPathComponent("etape.json")
            let etJsonData = try Data.init(contentsOf: etJsonFile)
            
            etape = try! JSONDecoder().decode([Etapa].self, from: etJsonData)
            print("Stevilo etap: \(etape.count)") // Prints: 3
            
            var etapeCopy = [Etapa]()
            for (index, var etapa) in etape.enumerated() {
                etapa.id = index+1
                
                etapeCopy.append(etapa)
            }
            
            etape.removeAll()
            etape.append(contentsOf: etapeCopy)
            etape = etape.sorted(by: { $0.id ?? 1 < $1.id ?? 1 })
        }catch{
            print(error.localizedDescription)
        }
    }
    
    private func fetchLocations() {
        let fileManager = FileManager.default
        
        var documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        documents.appendPathComponent("files")
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documents, includingPropertiesForKeys: nil)
            // process files
            
            for path in fileURLs {
                //print("Path: \(path)")
                
                if let range = path.absoluteString.range(of: #"\bEtapa_[0-9]+.gpx"#,
                                                         options: .regularExpression) {
                    let fileName = String(path.absoluteString[range])
                    print("File name: \(fileName)")
                    
                    if let numberRange = fileName.range(of: #"[0-9]+"#, options: .regularExpression){
                        let number = Int(String(fileName[numberRange])) ?? 0
                        
                        print("Number: \(String(describing: number))")
                        
                        let etFile = documents.appendingPathComponent(fileName)
                        
                        if(fileManager.fileExists(atPath: etFile.relativePath)){
                            locations[number] = [CLLocationCoordinate2D]()
                            coordinates = parser.parseCoordinates(fromGpxFile: etFile.relativePath) ?? []
                            
                            coordinates = coordinates.drop(percentageToKeep: 75)
                            coordinates.forEach{ point in
                                locations[number]?.append(point.coordinate)
                            }
                        }
                    }
                } else {
                    print("Still waiting for an invitation to play Cluedo.")
                }
            }
        } catch {
            print("Error while enumerating files \(documents.path): \(error.localizedDescription)")
        }
        
        do{
            let etJsonFile = documents.appendingPathComponent("etape.json")
            let etJsonData = try Data.init(contentsOf: etJsonFile)
            
            etape = try! JSONDecoder().decode([Etapa].self, from: etJsonData)
            print("Stevilo etap: \(etape.count)") // Prints: 3
            
            var etapeCopy = [Etapa]()
            for (index, var etapa) in etape.enumerated() {
                etapa.id = index+1
                
                etapeCopy.append(etapa)
            }
            
            etape.removeAll()
            etape.append(contentsOf: etapeCopy)
            etape = etape.sorted(by: { $0.id ?? 1 < $1.id ?? 1 })
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func getPoints(){
        let fileManager = FileManager.default
        
        var documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        documents.appendPathComponent("files")
        
        let ktFile = documents.appendingPathComponent("KT.gpx")
        
        if(fileManager.fileExists(atPath: ktFile.relativePath)){
            points = parser.parseCoordinates(fromGpxFile: ktFile.relativePath)!
        }
        
        do{
            let ktJsonFile = documents.appendingPathComponent("kt.json")
            let ktJsonData = try Data.init(contentsOf: ktJsonFile)
            
            kontrolneTocke = try! JSONDecoder().decode([KontrolnaTocka].self, from: ktJsonData)
            print("Stevilo kontrolnih tock: \(kontrolneTocke.count)") // Prints: 3
        }catch{
            print(error.localizedDescription)
        }
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }
    
    let objectWillChange = PassthroughSubject<Void, Never>()
}

extension LocationViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
        print(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        //print(#function, location)
    }
    
}

extension Array {
    
    /// Returns a new array with a percentage of the original array kept.
    /// Retained entries are spaced evenly throughout the original array.
    func drop(percentageToKeep: Int) -> [Element] {
        guard percentageToKeep > 0 && percentageToKeep <= 100 else {
            fatalError("percentageToKeep must be between 1 and 100")
        }
        
        var filtered = [Element]()
        for index in self.indices {
            if index % (100 / percentageToKeep) == 0 {
                filtered.append(self[index])
            }
        }
        return filtered
    }
}
