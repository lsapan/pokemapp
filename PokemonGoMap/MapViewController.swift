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

class MapViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var followMeButton: UIBarButtonItem!
    
    var serverLocationAnnotation: ServerLocationAnnotation?
    var serverLocationAnnotationView: MKPinAnnotationView?
    var scanLocationAnnotation: ScanLocationAnnotation?
    var pokemonAnnotations: Dictionary<String, MapPokemonAnnotation> = [:]
    var currentLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Display the user's location on the map
        mapView.showsUserLocation = true
        currentLocation = appDelegate.currentLocation
        
        // Detect long presses to change the server location
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(changeServerLocation))
        mapView.addGestureRecognizer(lpgr)
        
        // Set the initial tint color for "Follow Me"
        followMeButton.tintColor = UIColor.darkGrayColor()
        
        // Register for notifications
        addEventObserver(.ServerLocationUpdated, observer: self, selector: #selector(didLoadServerLocation))
        addEventObserver(.MapPokemonAdded, observer: self, selector: #selector(didAddMapPokemon))
        addEventObserver(.MapPokemonExpired, observer: self, selector: #selector(willExpireMapPokemon))
        addEventObserver(.LastScanLocationUpdated, observer: self, selector: #selector(didGetScan))
        addEventObserver(.ShowPokemon, observer: self, selector: #selector(showPokemon))
        addEventObserver(.UserLocationUpdated, observer: self, selector: #selector(userLocationUpdated))
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
            annotationView.image = mapPokemon!.image()
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
    
    // Events
    @objc func didLoadServerLocation() {
        let location = PokeData.sharedInstance.serverLocation!
        if (serverLocationAnnotation == nil) {
            centerMapOnLocation(location, animated: false)
        } else {
            mapView.removeAnnotation(serverLocationAnnotation!)
        }
        serverLocationAnnotation = ServerLocationAnnotation()
        serverLocationAnnotation!.coordinate = location
        mapView.addAnnotation(serverLocationAnnotation!)
    }

    @objc func didAddMapPokemon(notification: NSNotification) {
        let mapPokemon = notification.userInfo!["pokemon"] as! MapPokemon
        print("[Map] Adding \(mapPokemon.pokemon.id) (\(mapPokemon.pokemon.name))")
        let annotation = MapPokemonAnnotation(mapPokemon: mapPokemon)
        pokemonAnnotations[mapPokemon.encounterId] = annotation
        mapView.addAnnotation(annotation)
    }
    
    @objc func willExpireMapPokemon(notification: NSNotification) {
        let mapPokemon = notification.userInfo!["pokemon"] as! MapPokemon
        print("[Map] Removing \(mapPokemon.pokemon.id) (\(mapPokemon.pokemon.name))")
        mapView.removeAnnotation(pokemonAnnotations[mapPokemon.encounterId]!)
        pokemonAnnotations.removeValueForKey(mapPokemon.encounterId)
    }
    
    @objc func didGetScan(notification: NSNotification) {
        let scan = notification.userInfo!["scan"] as! Scan
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
    
    @objc func showPokemon(notification: NSNotification) {
        let mapPokemon = notification.userInfo!["pokemon"] as! MapPokemon
        let region = MKCoordinateRegion(center: mapPokemon.location, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        mapView.setRegion(region, animated: true)
    }
    
    // Search
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
    
    // Follow Me
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
    
    func userLocationUpdated(notification: NSNotification) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let newLocation = appDelegate.currentLocation!
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

