//
//  ViewController.swift
//  asm4
//
//  Created by Guest User on 8/8/21.
//  Copyright © 2021 Guest. All rights reserved.
//

import UIKit

final class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    private static let CELL_IDENTIFIER: String = "cell"
    private static let IMMUTABLE_CALORIES_COLLECTION: Dictionary<String, String> = ViewController.readPropertyList()
    private static let SORTED_KEY = Array(ViewController.IMMUTABLE_CALORIES_COLLECTION.keys).sorted()
    
    private var filteredCaloriesCollection: Dictionary<String, String> = ViewController.IMMUTABLE_CALORIES_COLLECTION
    
    @IBOutlet weak var calorySearchBar: UISearchBar!
    @IBOutlet weak var caloryTable: UITableView!
    @IBOutlet weak var caloryLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.caloryTable.dataSource = self
        self.caloryTable.delegate = self
        self.calorySearchBar.delegate = self
        self.caloryTable.register(UITableViewCell.self, forCellReuseIdentifier: ViewController.CELL_IDENTIFIER)
        
        self.caloryLabel.textAlignment = .center
        self.caloryLabel.text = "Chosen fruit/vegetable"
    }
    
    private static func readPropertyList() -> Dictionary<String, String> {
        if let filePath = Bundle.main.path(forResource: "caloriesInfo", ofType: "plist") {
            if let plistData = FileManager.default.contents( atPath: filePath) {
                do {
                    let plistObject = try PropertyListSerialization.propertyList(from: plistData, options: PropertyListSerialization.ReadOptions(), format: nil)
                    let caloriesDict = plistObject as? Dictionary<String, String>
                    return caloriesDict!
                } catch {
                    print("Error serializing data from property list")
                }
            } else {
                print("Error reading data from property list file")
            }
        } else {
            print("Property list file does not exist")
        }
        return [String: String]()
    }
    
    private func getLabelTextTuple(index: Int) -> (String, String) {
        let key = ViewController.SORTED_KEY[index]
        let value = self.filteredCaloriesCollection[key]! + " / 100g"
        return (key, value)
    }
    

    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredCaloriesCollection.count
    }
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tuple = self.getLabelTextTuple(index: indexPath.row)
        let text = tuple.0
        let subtitle = tuple.1
        
        let newCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: ViewController.CELL_IDENTIFIER)
        newCell.textLabel!.text = text
        newCell.detailTextLabel!.text = subtitle
    
        return newCell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tuple = self.getLabelTextTuple(index: indexPath.row)
        let text = tuple.0
        let subtitle = tuple.1
        
        self.caloryLabel.text = "You search for \(text) with calories \(subtitle)"
    }

    private func getFilteredCaloriesCollection(lowerCasedSearchText: String) -> Dictionary<String, String> {
        return ViewController.IMMUTABLE_CALORIES_COLLECTION.filter { (fruits) -> Bool in
                String(fruits.0).lowercased().contains(lowerCasedSearchText)
            }
    }
    
    internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            self.filteredCaloriesCollection = self.getFilteredCaloriesCollection(lowerCasedSearchText: searchText.lowercased())
        }
        else {
            self.filteredCaloriesCollection = ViewController.IMMUTABLE_CALORIES_COLLECTION
        }
        self.caloryTable.reloadData()
    }
    
    internal func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
