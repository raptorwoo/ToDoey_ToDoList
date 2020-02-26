//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigaton Controller does not exist")}
        
        if let colorHex = selectedCategory?.colorHexString {
            navBar.backgroundColor = UIColor(hexString: colorHex)
            title = selectedCategory!.name
            
            if let navBarColor = UIColor(hexString: colorHex) {
               
                navBar.barTintColor = navBarColor

                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
                
                searchBar.barTintColor = navBarColor
            }
            
        }
        
    }
    

    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = todoItems?[indexPath.row].title
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            //Checkmark 기능
            cell.accessoryType = item.done ? .checkmark : .none
            
            //Color 배정 기능
            let percentage = CGFloat(indexPath.row) / CGFloat(todoItems!.count)
            if let color = UIColor(hexString: selectedCategory!.colorHexString)?.darken(byPercentage: percentage) {
                
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        
        
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let item = todoItems?[indexPath.row] {
            
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error.localizedDescription)")
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    
    //MARK: - Add new Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user cliks the Add Item Button on our UIAlert
            
            if let currentCategory = self.selectedCategory {
                
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new itmes, \(error)")
                }
                
                self.tableView.reloadData()
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            
            //textField.text property를 연동시키면 안됨
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    

    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    
    //MARK: - Delete action
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error \(error.localizedDescription)")
            }
        }
    }
}

//MARK: - Search Bar methods
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //query database and sort
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
    }



    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {

            DispatchQueue.main.async {
                searchBar.resignFirstResponder() //no longer have cursor, and keyboard should go away
            }
            loadItems()
        }
    }
}





