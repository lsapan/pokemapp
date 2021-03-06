//
//  ListViewController.swift
//  PokemonGoMap
//
//  Created by Luke Sapan on 7/25/16.
//  Copyright © 2016 Coadstal. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    @IBOutlet var sortControl: UISegmentedControl!
    
    var pokemonList: [MapPokemon] = []
    var sortFunc: ((MapPokemon, MapPokemon) -> Bool)!
    
    override func viewDidLoad() {
        // Set the initial sortFunc and build initial data
        setSortFunc(nil)
        
        // Register for notifications
        addEventObserver(.MapPokemonAdded, observer: self, selector: #selector(pokemonAdded))
        addEventObserver(.MapPokemonExpired, observer: self, selector: #selector(pokemonRemoved))
    }
    
    @IBAction func setSortFunc(sender: UISegmentedControl?) {
        if sortControl.selectedSegmentIndex == 0 {
            sortFunc = { (p1, p2) -> Bool in
                if p1.pokemon.id != p2.pokemon.id {
                    return p1.pokemon.id > p2.pokemon.id
                } else {
                    return p1.distanceKm < p2.distanceKm
                }
            }
        } else if sortControl.selectedSegmentIndex == 1 {
            sortFunc = { (p1, p2) -> Bool in
                return p1.distanceKm < p2.distanceKm
            }
        } else {
            sortFunc = { (p1, p2) -> Bool in
                return p1.disappearTime.timeIntervalSince1970 < p2.disappearTime.timeIntervalSince1970
            }
        }
        buildPokemonList()
    }
    
    func buildPokemonList() {
        pokemonList = []
        for pokemon in PokeData.sharedInstance.pokemonList.values {
            if PokeData.sharedInstance.visiblePokemon.indexOf(pokemon.pokemon.id) != nil {
                pokemonList.append(pokemon)
            }
        }
        pokemonList = pokemonList.sort(sortFunc)
        tableView.reloadData()
    }
    
    func pokemonAdded(notification: NSNotification) {
        let pokemon = notification.userInfo!["pokemon"] as! MapPokemon
        if PokeData.sharedInstance.visiblePokemon.indexOf(pokemon.pokemon.id) != nil {
            for (idx, p) in pokemonList.enumerate() {
                if sortFunc(pokemon, p) {
                    pokemonList.insert(pokemon, atIndex: idx)
                    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: idx, inSection: 0)], withRowAnimation: .Automatic)
                    return
                }
            }
            pokemonList.append(pokemon)
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: pokemonList.count - 1, inSection: 0)], withRowAnimation: .Automatic)
        }
    }
    
    func pokemonRemoved(notification: NSNotification) {
        let pokemon = notification.userInfo!["pokemon"] as! MapPokemon
        for (idx, p) in pokemonList.enumerate() {
            if p.encounterId == pokemon.encounterId {
                pokemonList.removeAtIndex(idx)
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: idx, inSection: 0)], withRowAnimation: .Automatic)
                return
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemonList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pokecell") as! PokemonViewCell
        let pokemon = pokemonList[indexPath.row]
        cell.renderPokemon(pokemon)
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        tabBarController!.selectedIndex = 0
        let pokemon = pokemonList[indexPath.row]
        postEvent(.ShowPokemon, data: ["pokemon": pokemon])
        return nil
    }

}
