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
    var delegate: PokeDataDelegate? = nil
    
    init() {
        loadServerLocation()
        loadData()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(expireMapPokemon), userInfo: nil, repeats: true)
    }
    
    func loadServerLocation() {
        Alamofire.request(.GET, "\(ServerEndpoint)/loc")
            .responseJSON { response in
                if let json = response.result.value {
                    self.serverLocation = CLLocationCoordinate2D(latitude: json["lat"] as! Double, longitude: json["lng"] as! Double)
                    self.delegate?.didLoadServerLocation(self.serverLocation!)
                } else {
                    self.delegate?.failedToLoadServerLocation()
                }
        }
    }
    
    func setServerLocation(location: CLLocationCoordinate2D) {
        let oldServerLocation = serverLocation
        serverLocation = location
        delegate?.didLoadServerLocation(serverLocation!)
        Alamofire.request(.POST, "\(ServerEndpoint)/next_loc?lat=\(location.latitude)&lon=\(location.longitude)")
            .responseString { response in
                if response.result.value == nil || response.result.value! != "ok" {
                    self.serverLocation = oldServerLocation
                    self.delegate?.didLoadServerLocation(self.serverLocation!)
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
                            self.delegate?.didAddMapPokemon(pokemon)
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
                        self.delegate?.didGetScan(Scan(json: lastScanData))
                    }

                    print("[PokeData] Loaded data!")
                    self.delegate?.didLoadData(self.pokemonList, scans: self.scans)
                } else {
                    print("[PokeData] Failed to load data!")
                    self.delegate?.failedToLoadData()
                }
                NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(self.loadData), userInfo: nil, repeats: false)
        }
    }
    
    @objc func expireMapPokemon() {
        let now = NSDate().timeIntervalSince1970
        for (_, mapPokemon) in pokemonList {
            if mapPokemon.disappearTime.timeIntervalSince1970 < now {
                self.delegate?.willExpireMapPokemon(mapPokemon)
                pokemonList.removeValueForKey(mapPokemon.encounterId)
            }
        }
    }
}