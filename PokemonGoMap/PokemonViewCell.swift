//
//  PokemonViewCell.swift
//  PokemonGoMap
//
//  Created by Luke Sapan on 7/29/16.
//  Copyright © 2016 Coadstal. All rights reserved.
//

import UIKit

class PokemonViewCell: UITableViewCell {
    
    var pokemon: MapPokemon!
    
    func renderPokemon(pokemon: MapPokemon){
        //Set Pokemon data
        self.pokemon = pokemon
        
        textLabel!.text = pokemon.pokemon.name
        imageView!.image = pokemon.image()
        
        updateTime(nil)
        
        //Register for update commands
        addEventObserver(.Tick, observer: self, selector: #selector(updateTime))
    }
    
    func updateTime(notification: NSNotification?){
        detailTextLabel!.text = "\(pokemon.timeLeft()) - \(pokemon.distance())"
    }
    
    override func prepareForReuse() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
