//
//  PokeDataDelegate.swift
//  PokemonGoMap
//
//  Created by Luke Sapan on 7/25/16.
//  Copyright © 2016 Coadstal. All rights reserved.
//

import Foundation
import MapKit


protocol PokeDataDelegate {
    func didLoadServerLocation(location: CLLocationCoordinate2D)
    func failedToLoadServerLocation()
    
    func didLoadData(pokemonList: Dictionary<String, MapPokemon>, scans: Dictionary<String, Scan>)
    func failedToLoadData()
    
    func didAddMapPokemon(mapPokemon: MapPokemon)
    func willExpireMapPokemon(mapPokemon: MapPokemon)
    
    func didGetScan(scan: Scan)
}
