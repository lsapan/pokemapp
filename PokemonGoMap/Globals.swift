//
//  Globals.swift
//  PokemonGoMap
//
//  Created by Luke Sapan on 7/29/16.
//  Copyright © 2016 Coadstal. All rights reserved.
//

import Foundation


enum Event: String {
    case UserLocationUpdated = "USER_LOCATION_UPDATED"
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


let allPokemon: [Pokemon] = [
    Pokemon(id: 1, name: "Bulbasaur"),
    Pokemon(id: 2, name: "Ivysaur"),
    Pokemon(id: 3, name: "Venusaur"),
    Pokemon(id: 4, name: "Charmander"),
    Pokemon(id: 5, name: "Charmeleon"),
    Pokemon(id: 6, name: "Charizard"),
    Pokemon(id: 7, name: "Squirtle"),
    Pokemon(id: 8, name: "Wartortle"),
    Pokemon(id: 9, name: "Blastoise"),
    Pokemon(id: 10, name: "Caterpie"),
    Pokemon(id: 11, name: "Metapod"),
    Pokemon(id: 12, name: "Butterfree"),
    Pokemon(id: 13, name: "Weedle"),
    Pokemon(id: 14, name: "Kakuna"),
    Pokemon(id: 15, name: "Beedrill"),
    Pokemon(id: 16, name: "Pidgey"),
    Pokemon(id: 17, name: "Pidgeotto"),
    Pokemon(id: 18, name: "Pidgeot"),
    Pokemon(id: 19, name: "Rattata"),
    Pokemon(id: 20, name: "Raticate"),
    Pokemon(id: 21, name: "Spearow"),
    Pokemon(id: 22, name: "Fearow"),
    Pokemon(id: 23, name: "Ekans"),
    Pokemon(id: 24, name: "Arbok"),
    Pokemon(id: 25, name: "Pikachu"),
    Pokemon(id: 26, name: "Raichu"),
    Pokemon(id: 27, name: "Sandshrew"),
    Pokemon(id: 28, name: "Sandslash"),
    Pokemon(id: 29, name: "Nidoran♀"),
    Pokemon(id: 30, name: "Nidorina"),
    Pokemon(id: 31, name: "Nidoqueen"),
    Pokemon(id: 32, name: "Nidoran♂"),
    Pokemon(id: 33, name: "Nidorino"),
    Pokemon(id: 34, name: "Nidoking"),
    Pokemon(id: 35, name: "Clefairy"),
    Pokemon(id: 36, name: "Clefable"),
    Pokemon(id: 37, name: "Vulpix"),
    Pokemon(id: 38, name: "Ninetales"),
    Pokemon(id: 39, name: "Jigglypuff"),
    Pokemon(id: 40, name: "Wigglytuff"),
    Pokemon(id: 41, name: "Zubat"),
    Pokemon(id: 42, name: "Golbat"),
    Pokemon(id: 43, name: "Oddish"),
    Pokemon(id: 44, name: "Gloom"),
    Pokemon(id: 45, name: "Vileplume"),
    Pokemon(id: 46, name: "Paras"),
    Pokemon(id: 47, name: "Parasect"),
    Pokemon(id: 48, name: "Venonat"),
    Pokemon(id: 49, name: "Venomoth"),
    Pokemon(id: 50, name: "Diglett"),
    Pokemon(id: 51, name: "Dugtrio"),
    Pokemon(id: 52, name: "Meowth"),
    Pokemon(id: 53, name: "Persian"),
    Pokemon(id: 54, name: "Psyduck"),
    Pokemon(id: 55, name: "Golduck"),
    Pokemon(id: 56, name: "Mankey"),
    Pokemon(id: 57, name: "Primeape"),
    Pokemon(id: 58, name: "Growlithe"),
    Pokemon(id: 59, name: "Arcanine"),
    Pokemon(id: 60, name: "Poliwag"),
    Pokemon(id: 61, name: "Poliwhirl"),
    Pokemon(id: 62, name: "Poliwrath"),
    Pokemon(id: 63, name: "Abra"),
    Pokemon(id: 64, name: "Kadabra"),
    Pokemon(id: 65, name: "Alakazam"),
    Pokemon(id: 66, name: "Machop"),
    Pokemon(id: 67, name: "Machoke"),
    Pokemon(id: 68, name: "Machamp"),
    Pokemon(id: 69, name: "Bellsprout"),
    Pokemon(id: 70, name: "Weepinbell"),
    Pokemon(id: 71, name: "Victreebel"),
    Pokemon(id: 72, name: "Tentacool"),
    Pokemon(id: 73, name: "Tentacruel"),
    Pokemon(id: 74, name: "Geodude"),
    Pokemon(id: 75, name: "Graveler"),
    Pokemon(id: 76, name: "Golem"),
    Pokemon(id: 77, name: "Ponyta"),
    Pokemon(id: 78, name: "Rapidash"),
    Pokemon(id: 79, name: "Slowpoke"),
    Pokemon(id: 80, name: "Slowbro"),
    Pokemon(id: 81, name: "Magnemite"),
    Pokemon(id: 82, name: "Magneton"),
    Pokemon(id: 83, name: "Farfetch'd"),
    Pokemon(id: 84, name: "Doduo"),
    Pokemon(id: 85, name: "Dodrio"),
    Pokemon(id: 86, name: "Seel"),
    Pokemon(id: 87, name: "Dewgong"),
    Pokemon(id: 88, name: "Grimer"),
    Pokemon(id: 89, name: "Muk"),
    Pokemon(id: 90, name: "Shellder"),
    Pokemon(id: 91, name: "Cloyster"),
    Pokemon(id: 92, name: "Gastly"),
    Pokemon(id: 93, name: "Haunter"),
    Pokemon(id: 94, name: "Gengar"),
    Pokemon(id: 95, name: "Onix"),
    Pokemon(id: 96, name: "Drowzee"),
    Pokemon(id: 97, name: "Hypno"),
    Pokemon(id: 98, name: "Krabby"),
    Pokemon(id: 99, name: "Kingler"),
    Pokemon(id: 100, name: "Voltorb"),
    Pokemon(id: 101, name: "Electrode"),
    Pokemon(id: 102, name: "Exeggcute"),
    Pokemon(id: 103, name: "Exeggutor"),
    Pokemon(id: 104, name: "Cubone"),
    Pokemon(id: 105, name: "Marowak"),
    Pokemon(id: 106, name: "Hitmonlee"),
    Pokemon(id: 107, name: "Hitmonchan"),
    Pokemon(id: 108, name: "Lickitung"),
    Pokemon(id: 109, name: "Koffing"),
    Pokemon(id: 110, name: "Weezing"),
    Pokemon(id: 111, name: "Rhyhorn"),
    Pokemon(id: 112, name: "Rhydon"),
    Pokemon(id: 113, name: "Chansey"),
    Pokemon(id: 114, name: "Tangela"),
    Pokemon(id: 115, name: "Kangaskhan"),
    Pokemon(id: 116, name: "Horsea"),
    Pokemon(id: 117, name: "Seadra"),
    Pokemon(id: 118, name: "Goldeen"),
    Pokemon(id: 119, name: "Seaking"),
    Pokemon(id: 120, name: "Staryu"),
    Pokemon(id: 121, name: "Starmie"),
    Pokemon(id: 122, name: "Mr. Mime"),
    Pokemon(id: 123, name: "Scyther"),
    Pokemon(id: 124, name: "Jynx"),
    Pokemon(id: 125, name: "Electabuzz"),
    Pokemon(id: 126, name: "Magmar"),
    Pokemon(id: 127, name: "Pinsir"),
    Pokemon(id: 128, name: "Tauros"),
    Pokemon(id: 129, name: "Magikarp"),
    Pokemon(id: 130, name: "Gyarados"),
    Pokemon(id: 131, name: "Lapras"),
    Pokemon(id: 132, name: "Ditto"),
    Pokemon(id: 133, name: "Eevee"),
    Pokemon(id: 134, name: "Vaporeon"),
    Pokemon(id: 135, name: "Jolteon"),
    Pokemon(id: 136, name: "Flareon"),
    Pokemon(id: 137, name: "Porygon"),
    Pokemon(id: 138, name: "Omanyte"),
    Pokemon(id: 139, name: "Omastar"),
    Pokemon(id: 140, name: "Kabuto"),
    Pokemon(id: 141, name: "Kabutops"),
    Pokemon(id: 142, name: "Aerodactyl"),
    Pokemon(id: 143, name: "Snorlax"),
    Pokemon(id: 144, name: "Articuno"),
    Pokemon(id: 145, name: "Zapdos"),
    Pokemon(id: 146, name: "Moltres"),
    Pokemon(id: 147, name: "Dratini"),
    Pokemon(id: 148, name: "Dragonair"),
    Pokemon(id: 149, name: "Dragonite"),
    Pokemon(id: 150, name: "Mewtwo"),
    Pokemon(id: 151, name: "Mew")
]
