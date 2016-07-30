//
//  PokeData.swift
//  PokemonGoMap
//
//  Created by Luke Sapan on 7/25/16.
//  Copyright © 2016 Coadstal. All rights reserved.
//

import Foundation
import MapKit
import Alamofire


struct Pokemon {
    let id: Int
    let name: String
}

class MapPokemon {
    let disappearTime: NSDate
    let encounterId: String
    let location: CLLocationCoordinate2D
    let pokemon: Pokemon
    let spawnpointId: String
    
    init(json: AnyObject) {
        pokemon = Pokemon(id: json["pokemon_id"] as! Int, name: json["pokemon_name"] as! String)
        disappearTime = NSDate(timeIntervalSince1970: Double((json["disappear_time"] as! Int) / 1000))
        encounterId = json["encounter_id"] as! String
        location = CLLocationCoordinate2D(latitude: json["latitude"] as! Double, longitude: json["longitude"] as! Double)
        spawnpointId = json["spawnpoint_id"] as! String
    }
    
    func expirationTime() -> String {
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = "hh:mm:ss a"
        dayTimePeriodFormatter.locale = NSLocale(localeIdentifier: NSLocale.currentLocale().localeIdentifier)
        return dayTimePeriodFormatter.stringFromDate(disappearTime)
    }
    
    func image() -> UIImage {
        return UIImage(named: "\(pokemon.id).png")!
    }
    
    func timeLeft() -> String {
        let timeLeft: NSTimeInterval = calculateTimeLeft()
        if (timeLeft <= 0){
            return "Disappearing..."
        }
        return timeLeftToString(timeLeft) + " remaining"
    }
    
    private func calculateTimeLeft() -> NSTimeInterval {
        return disappearTime.timeIntervalSince1970 - NSDate().timeIntervalSince1970
    }
    
    private func timeLeftToString(timeLeft: NSTimeInterval) -> String {
        let _seconds = Int(timeLeft % 60)
        let _minutes = Int((timeLeft / 60) % 60)
        let _hours = Int(timeLeft / 3600)
        let hours: String = _hours > 0 ? "\(_hours):" : ""
        let mins: String = _minutes < 10 ? "0\(_minutes):" : "\(_minutes):"
        let secs: String = _seconds < 10 ? "0\(_seconds)" : "\(_seconds)"
        return hours + mins + secs
    }
}

class Scan {
    let id: String
    let location: CLLocationCoordinate2D
    var lastModified: Int
    
    init(json: AnyObject) {
        id = json["scanned_id"] as! String
        location = CLLocationCoordinate2D(latitude: json["latitude"] as! Double, longitude: json["longitude"] as! Double)
        lastModified = json["last_modified"] as! Int
    }
    
    func update(json: AnyObject) {
        lastModified = json["last_modified"] as! Int
    }
}


class PokeData {
    static let sharedInstance = PokeData()
    
    var serverLocation: CLLocationCoordinate2D? = nil
    var pokemonList: Dictionary<String, MapPokemon> = [:]
    var scans: Dictionary<String, Scan> = [:]
    
    init() {
        loadServerLocation()
        loadData()
        addEventObserver(.Tick, observer: self, selector: #selector(expireMapPokemon))
    }
    
    @objc func loadServerLocation() {
        Alamofire.request(.GET, "\(ServerEndpoint)/loc")
            .responseJSON { response in
                if let json = response.result.value {
                    self.serverLocation = CLLocationCoordinate2D(latitude: json["lat"] as! Double, longitude: json["lng"] as! Double)
                    postEvent(.ServerLocationUpdated)
                    print("[PokeData] Update server location.")
                } else {
                    print("[PokeData] Failed to update server location!")
                }
                NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: #selector(self.loadServerLocation), userInfo: nil, repeats: false)
        }
    }
    
    func setServerLocation(location: CLLocationCoordinate2D) {
        let oldServerLocation = serverLocation
        serverLocation = location
        postEvent(.ServerLocationUpdated)
        Alamofire.request(.POST, "\(ServerEndpoint)/next_loc?lat=\(location.latitude)&lon=\(location.longitude)")
            .responseString { response in
                if response.result.value == nil || response.result.value! != "ok" {
                    self.serverLocation = oldServerLocation
                    postEvent(.ServerLocationUpdated)
                }
        }
    }
    
    @objc func loadData() {
        print("[PokeData] Loading data...")
        Alamofire.request(.GET, "\(ServerEndpoint)/raw_data?pokemon=true&scanned=true&gyms=false&pokestops=false&swLat=-100&swLng=-100&neLat=100&neLng=100")
            .responseJSON { response in
                if let json = response.result.value {
                    
                    for pokemonData in json["pokemons"] as! [AnyObject] {
                        let encounterId = pokemonData["encounter_id"] as! String
                        if (self.pokemonList[encounterId] == nil) {
                            let pokemon = MapPokemon(json: pokemonData)
                            self.pokemonList[pokemon.encounterId] = pokemon
                            postEvent(.MapPokemonAdded, data: ["pokemon": pokemon])
                        }
                    }
                    
                    let allScanData = json["scanned"] as! [AnyObject]
                    for scanData in allScanData {
                        let scanId = scanData["scanned_id"] as! String
                        if let scan = self.scans[scanId] {
                            scan.update(scanData)
                        } else {
                            let scan = Scan(json: scanData)
                            self.scans[scan.id] = scan
                        }
                    }
                    
                    if let lastScanData = allScanData.last {
                        postEvent(.LastScanLocationUpdated, data: ["scan": Scan(json: lastScanData)])
                    }

                    print("[PokeData] Loaded data!")
                    postEvent(.DataUpdated)
                } else {
                    print("[PokeData] Failed to load data!")
                }
                NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(self.loadData), userInfo: nil, repeats: false)
        }
    }
    
    @objc func expireMapPokemon() {
        let now = NSDate().timeIntervalSince1970
        for (_, mapPokemon) in pokemonList {
            if mapPokemon.disappearTime.timeIntervalSince1970 < now {
                pokemonList.removeValueForKey(mapPokemon.encounterId)
                postEvent(.MapPokemonExpired, data: ["pokemon": mapPokemon])
            }
        }
    }
}