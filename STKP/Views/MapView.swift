//
//  ContentView.swift
//  STKP
//
//  Created by David Trafela on 10/02/2021.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    @ObservedObject var locationViewModel: LocationViewModel
    
    @State private var showingImagePicker = false
    
    private let mapZoomEdgeInsets = UIEdgeInsets(top: 30.0, left: 30.0, bottom: 30.0, right: 30.0)
    
    private var etapa: String? = nil
    
    init(_ locationViewModel: LocationViewModel) {
        //locationViewModel.load()
        self.locationViewModel = locationViewModel
    }
    
    init(_ locationViewModel: LocationViewModel, etapa: String) {
        //locationViewModel.load()
        self.locationViewModel = locationViewModel
        
        self.etapa = etapa
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        if etapa != nil {
            return MapViewCoordinator(self, etapa: true)
        }else{
            return MapViewCoordinator(self)
        }
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        
        context.coordinator.setMkMapView(mkMapView: mapView)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        print("Update")
        updateOverlays(from: uiView)
        
        uiView.removeAnnotations(uiView.annotations)
        
        locationViewModel.points.forEach{ point in
            let annotation = MKPointAnnotation()
            annotation.coordinate = point.coordinate
            annotation.subtitle = "Test"
            annotation.title = point.name
            
            uiView.addAnnotation(annotation)
        }
    }
    
    private func updateOverlays(from mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        
        if(!locationViewModel.locations.isEmpty){
            for key in locationViewModel.locations.keys {
                if(locationViewModel.locations[key] != nil){
                    let polyline = MKPolyline(coordinates: locationViewModel.locations[key]!, count: locationViewModel.locations[key]!.count)
                    
                    polyline.title = "Etapa " + String(key)
                    polyline.subtitle = locationViewModel.etape[key-1].name
                    
                    mapView.addOverlay(polyline)
                }
            }
            
            if let first = mapView.overlays.first {
                let rect = mapView.overlays.reduce(first.boundingMapRect, {$0.union($1.boundingMapRect)})
                mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
            }
        }
    }
    
    private func setMapZoomArea(map: MKMapView, polyline: MKPolyline, edgeInsets: UIEdgeInsets, animated: Bool = false) {
        map.setVisibleMapRect(polyline.boundingMapRect, edgePadding: edgeInsets, animated: animated)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(LocationViewModel())
    }
}
