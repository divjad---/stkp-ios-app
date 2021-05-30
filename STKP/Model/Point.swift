//
//  Points.swift
//  STKP
//
//  Created by David Trafela on 10/02/2021.
//
import MapKit

struct Point: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
