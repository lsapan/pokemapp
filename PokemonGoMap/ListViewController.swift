//
//  ListViewController.swift
//  PokemonGoMap
//
//  Created by Luke Sapan on 7/25/16.
//  Copyright © 2016 Coadstal. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    var pokemonList: [MapPokemon] = []
    
    override func viewDidLoad() {
        buildPokemonList()
    }
    
    func buildPokemonList() {
        pokemonList = Array(PokeData.sharedInstance.pokemonList.values)
        pokemonList = pokemonList.sort({ (p1, p2) -> Bool in
            return p1.pokemon.id > p2.pokemon.id
        })
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemonList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pokecell")!
        let pokemon = pokemonList[indexPath.row]
        
        cell.textLabel!.text = pokemon.pokemon.name
        cell.detailTextLabel!.text = pokemon.expirationTime()
        cell.imageView!.image = pokemon.image()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        tabBarController!.selectedIndex = 0
        let pokemon = pokemonList[indexPath.row]
        postEvent(.ShowPokemon, data: ["pokemon": pokemon])
        return nil
    }

}
