//
//  MapViewController.swift
//  PokemonGoMap
//
//  Created by Luke Sapan on 7/25/16.
//  Copyright © 2016 Coadstal. All rights reserved.
//

import UIKit
import MapKit

class MapPokemonAnnotation: MKPointAnnotation {
    var encounterId: String!
    
    convenience init(mapPokemon: MapPokemon) {
        self.init()
        self.encounterId = mapPokemon.encounterId
        self.coordinate = mapPokemon.location
        self.title = mapPokemon.pokemon.name
        self.subtitle = mapPokemon.expirationTime()
    }
}

class ServerLocationAnnotation: MKPointAnnotation {
    
}

class ScanLocationAnnotation: MKPointAnnotation {
    
}

class MapViewController: UIViewController, MKMapViewDelegate, PokeDataDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var followMeButton: UIBarButtonItem!
    
    var serverLocationAnnotation: ServerLocationAnnotation?
    var serverLocationAnnotationView: MKPinAnnotationView?
    var scanLocationAnnotation: ScanLocationAnnotation?
    var pokemonAnnotations: Dictionary<String, MapPokemonAnnotation> = [:]
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        PokeData.sharedInstance.delegate = self
        mapView.showsUserLocation = true
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(changeServerLocation))
        mapView.addGestureRecognizer(lpgr)
        
        followMeButton.tintColor = UIColor.darkGrayColor()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        } else if annotation.isKindOfClass(ServerLocationAnnotation) {
            let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
            serverLocationAnnotationView = view
            serverLocationAnnotationView!.hidden = (followMeButton.tintColor == nil)
            return view
        } else if annotation.isKindOfClass(ScanLocationAnnotation) {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            annotationView.image = UIImage(named: "search")!
            
            let animation = CABasicAnimation(keyPath: "transform.rotation.z")
            animation.fromValue = 0
            animation.toValue = 2 * M_PI
            animation.duration = 2
            animation.repeatCount = Float.infinity
            annotationView.layer.addAnimation(animation, forKey: "SpinAnimation")
            
            return annotationView
        } else {
            let pokemonAnnotation = annotation as! MapPokemonAnnotation
            let mapPokemon = PokeData.sharedInstance.pokemonList[pokemonAnnotation.encounterId]
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            annotationView.image = UIImage(named: "\(mapPokemon!.pokemon.id).png")!
            annotationView.canShowCallout = true
            return annotationView
        }
    }
    
    func changeServerLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            disableFollowMe()
            let touchPoint = gestureRecognizer.locationInView(mapView)
            PokeData.sharedInstance.setServerLocation(mapView.convertPoint(touchPoint, toCoordinateFromView: mapView))
        }
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D, animated: Bool) {
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: animated)
    }

    func didLoadServerLocation(location: CLLocationCoordinate2D) {
        if (serverLocationAnnotation == nil) {
            centerMapOnLocation(location, animated: false)
        } else {
            mapView.removeAnnotation(serverLocationAnnotation!)
        }
        serverLocationAnnotation = ServerLocationAnnotation()
        serverLocationAnnotation!.coordinate = location
        mapView.addAnnotation(serverLocationAnnotation!)
    }
    
    func failedToLoadServerLocation() {
        
    }
    
    func didLoadData(pokemonList: Dictionary<String, MapPokemon>, scans: Dictionary<String, Scan>) {
        
    }
    
    func failedToLoadData() {
        
    }

    func didAddMapPokemon(mapPokemon: MapPokemon) {
        print("[Map] Adding \(mapPokemon.pokemon.id) (\(mapPokemon.pokemon.name))")
        let annotation = MapPokemonAnnotation(mapPokemon: mapPokemon)
        pokemonAnnotations[mapPokemon.encounterId] = annotation
        mapView.addAnnotation(annotation)
    }
    
    func willExpireMapPokemon(mapPokemon: MapPokemon) {
        print("[Map] Removing \(mapPokemon.pokemon.id) (\(mapPokemon.pokemon.name))")
        mapView.removeAnnotation(pokemonAnnotations[mapPokemon.encounterId]!)
        pokemonAnnotations.removeValueForKey(mapPokemon.encounterId)
    }
    
    func didGetScan(scan: Scan) {
        if scanLocationAnnotation == nil {
            scanLocationAnnotation = ScanLocationAnnotation()
            scanLocationAnnotation!.coordinate = scan.location
            mapView.addAnnotation(scanLocationAnnotation!)
        } else {
            UIView.animateWithDuration(1, animations: {
                self.scanLocationAnnotation!.coordinate = scan.location
            })
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(textField.text!, completionHandler: {(placemarks, error) -> Void in
            if let placemark = placemarks?.first {
                let coordinate = placemark.location!.coordinate
                self.centerMapOnLocation(coordinate, animated: true)
            } else {
                let alertController = UIAlertController(title: "No Match Found", message:
                    "We couldn't find a location matching that address.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Darn", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        })
        textField.resignFirstResponder()
        textField.text = ""
        return true
    }
    
    @IBAction func toggleFollowMe() {
        if followMeButton.tintColor == UIColor.darkGrayColor() {
            enableFollowMe()
        } else {
            disableFollowMe()
        }
    }
    
    func enableFollowMe() {
        followMeButton.tintColor = nil
        followMeButton.image = UIImage(named: "location_on")
        if currentLocation != nil {
            followMeLocationChanged(currentLocation!)
        }
        serverLocationAnnotationView?.hidden = (followMeButton.tintColor == nil)
    }
    
    func disableFollowMe() {
        followMeButton.tintColor = UIColor.darkGrayColor()
        followMeButton.image = UIImage(named: "location_off")
        serverLocationAnnotationView?.hidden = (followMeButton.tintColor == nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        if currentLocation == nil || currentLocation!.distanceFromLocation(newLocation) > 20 {
            currentLocation = newLocation
            if followMeButton.tintColor == nil {
                followMeLocationChanged(newLocation)
            }
        }
    }
    
    func followMeLocationChanged(location: CLLocation) {
        let coordinate = location.coordinate
        mapView.setCenterCoordinate(coordinate, animated: true)
        PokeData.sharedInstance.setServerLocation(coordinate)
    }

}

