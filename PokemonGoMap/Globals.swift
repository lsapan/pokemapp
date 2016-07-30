//
//  Globals.swift
//  PokemonGoMap
//
//  Created by Luke Sapan on 7/29/16.
//  Copyright © 2016 Coadstal. All rights reserved.
//

import Foundation


enum Event: String {
    case ServerLocationUpdated = "SERVER_LOCATION_UPDATED"
    case DataUpdated = "DATA_UPDATED"
    case MapPokemonAdded = "MAP_POKEMON_ADDED"
    case MapPokemonExpired = "MAP_POKEMON_EXPIRED"
    case LastScanLocationUpdated = "LAST_SCAN_LOCATION_UPDATED"
    case ShowPokemon = "SHOW_POKEMON"
    case Tick = "TICK"
}

func postEvent(event: Event) {
    postEvent(event, data: nil)
}

func postEvent(event: Event, data: [String: AnyObject]?) {
    NSNotificationCenter.defaultCenter().postNotificationName(event.rawValue, object: nil, userInfo: data)
}

func addEventObserver(event: Event, observer: AnyObject, selector: Selector) {
    NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: event.rawValue, object: nil)
}
