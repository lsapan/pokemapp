//
//  VisiblePokemonViewController.swift
//  PokemonGoMap
//
//  Created by Luke Sapan on 7/29/16.
//  Copyright © 2016 Coadstal. All rights reserved.
//

import UIKit

class VisiblePokemonViewController: UITableViewController {
    
    override func viewDidLoad() {
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPokemon.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pokecell")!
        let pokemon = allPokemon[indexPath.row]
        cell.textLabel!.text = pokemon.name
        cell.imageView!.image = UIImage(named: "\(pokemon.id).png")!
        if PokeData.sharedInstance.visiblePokemon.indexOf(pokemon.id) != nil {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let pokemon = allPokemon[indexPath.row]
        if let idx = PokeData.sharedInstance.visiblePokemon.indexOf(pokemon.id) {
            PokeData.sharedInstance.visiblePokemon.removeAtIndex(idx)
        } else {
            PokeData.sharedInstance.visiblePokemon.append(pokemon.id)
        }
        NSUserDefaults.standardUserDefaults().setValue(PokeData.sharedInstance.visiblePokemon, forKey: "visiblePokemon")
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
