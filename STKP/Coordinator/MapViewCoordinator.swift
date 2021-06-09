//
//  MapViewCoordinator.swift
//  STKP
//
//  Created by David Trafela on 10/02/2021.
//

import MapKit

final class MapViewCoordinator: NSObject, MKMapViewDelegate {
    private let map: MapView
    public var mkMapView: MKMapView!
    
    private var etapa = false
    
    init(_ control: MapView) {
        self.map = control
    }
    
    init(_ control: MapView, etapa: Bool) {
        self.map = control
        self.etapa = etapa
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if let annotationView = views.first, let annotation = annotationView.annotation {
            if annotation is MKUserLocation && !etapa {
                let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
                mapView.setRegion(region, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .blue
        renderer.lineWidth = 3.0
        return renderer
    }
    
    func setMkMapView(mkMapView: MKMapView){
        self.mkMapView = mkMapView
        
        let mapTap = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        self.mkMapView.addGestureRecognizer(mapTap)
    }
    
    @objc func mapTapped(_ tap: UITapGestureRecognizer) {
        if tap.state == .recognized {
            // Get map coordinate from touch point
            let touchPt: CGPoint = tap.location(in: mkMapView)
            let coord: CLLocationCoordinate2D = mkMapView.convert(touchPt, toCoordinateFrom: mkMapView)
            let maxMeters: Double = meters(fromPixel: 22, at: touchPt)
            var nearestDistance: Float = MAXFLOAT
            var nearestPoly: MKPolyline? = nil
            // for every overlay ...
            for overlay: MKOverlay in mkMapView.overlays {
                // .. if MKPolyline ...
                if (overlay is MKPolyline) {
                    // ... get the distance ...
                    let distance: Float = Float(distanceOf(pt: MKMapPoint(coord), toPoly: overlay as! MKPolyline))
                    // ... and find the nearest one
                    if distance < nearestDistance {
                        nearestDistance = distance
                        nearestPoly = overlay as? MKPolyline
                    }
                }
            }
            
            if Double(nearestDistance) <= maxMeters {
                print("Touched poly: \(String(describing: nearestPoly?.title)) distance: \(nearestDistance)")
                
                let alertController = UIAlertController(title: nearestPoly!.title, message: nearestPoly!.subtitle, preferredStyle: .actionSheet)
                alertController.addAction(
                    UIAlertAction(title: "OK", style: .default, handler: nil)
                )
                
                if let controller = topMostViewController() {
                    controller.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func distanceOf(pt: MKMapPoint, toPoly poly: MKPolyline) -> Double {
        var distance: Double = Double(MAXFLOAT)
        for n in 0..<poly.pointCount - 1 {
            let ptA = poly.points()[n]
            let ptB = poly.points()[n + 1]
            let xDelta: Double = ptB.x - ptA.x
            let yDelta: Double = ptB.y - ptA.y
            if xDelta == 0.0 && yDelta == 0.0 {
                // Points must not be equal
                continue
            }
            let u: Double = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta)
            var ptClosest: MKMapPoint
            if u < 0.0 {
                ptClosest = ptA
            }
            else if u > 1.0 {
                ptClosest = ptB
            }
            else {
                ptClosest = MKMapPoint(x: ptA.x + u * xDelta, y: ptA.y + u * yDelta)
            }
            
            distance = min(distance, ptClosest.distance(to: pt))
        }
        return distance
    }
    
    private func meters(fromPixel px: Int, at pt: CGPoint) -> Double {
        let ptB = CGPoint(x: pt.x + CGFloat(px), y: pt.y)
        let coordA: CLLocationCoordinate2D = mkMapView.convert(pt, toCoordinateFrom: mkMapView)
        let coordB: CLLocationCoordinate2D = mkMapView.convert(ptB, toCoordinateFrom: mkMapView)
        return MKMapPoint(coordA).distance(to: MKMapPoint(coordB))
    }
    
    private func topMostViewController() -> UIViewController? {
        guard let rootController = keyWindow()?.rootViewController else {
            return nil
        }
        return topMostViewController(for: rootController)
    }
    
    private func keyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter {$0.activationState == .foregroundActive}
            .compactMap {$0 as? UIWindowScene}
            .first?.windows.filter {$0.isKeyWindow}.first
    }
    
    private func topMostViewController(for controller: UIViewController) -> UIViewController {
        if let presentedController = controller.presentedViewController {
            return topMostViewController(for: presentedController)
        } else if let navigationController = controller as? UINavigationController {
            guard let topController = navigationController.topViewController else {
                return navigationController
            }
            return topMostViewController(for: topController)
        } else if let tabController = controller as? UITabBarController {
            guard let topController = tabController.selectedViewController else {
                return tabController
            }
            return topMostViewController(for: topController)
        }
        return controller
    }
}
