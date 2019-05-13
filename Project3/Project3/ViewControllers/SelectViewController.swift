//
//  SelectViewController.swift
//  Project2
//
//  Created by Alumno on 20/03/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import UIKit
import CoreData

class SelectViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var context: NSManagedObjectContext? = nil
    
    var entitySelected: String = "Customer"
    var entityID: Int = -1
    
    var customerSelected: CustomerModel? = nil
    var productSelected: ProductModel? = nil
    
    var customerResults: [CustomerModel] = []
    var productResults: [ProductModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customerResults = CustomerQueryService.staticCustomers
        productResults = ProductQueryService.staticProducts
        
    }
    
    //MARK: select the row of the object selected by the user or the order if none is selected for default
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(entityID != -1 && entitySelected == "Customer"){
            if(entityID == customerResults[indexPath.row].IDCustomer){
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.top)
            }
        } else if(entityID != -1 && entitySelected == "Product"){
            if(entityID == productResults[indexPath.row].IDProduct){
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.top)
            }
        }
    }
    
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        if(tableView.indexPathForSelectedRow == nil){
            let alert = UIAlertController(title: "Select a customer/product first", message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            return
        }
        if(entitySelected == "Customer"){
            customerSelected = customerResults[tableView.indexPathForSelectedRow!.row]
        }else{
            productSelected = productResults[tableView.indexPathForSelectedRow!.row]
        }
        performSegue(withIdentifier: "unwindToOrderDetails", sender: self)
    }
    
    // MARK: Set some properties of the controller and the object we have to query
    func setFetch(entity: String){
        if(entity == "Customer"){
            entitySelected = "Customer"
        } else {
            entitySelected = "Product"
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(entitySelected == "Customer"){
            return customerResults.count
        }
        else{
            return productResults.count
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //since we are not grouping customers we are grouping them in only 1 group
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath)

        // Configure the cell...
        if(entitySelected == "Customer"){
            cell.textLabel?.text = customerResults[indexPath.row].name
        }
        else{
            cell.textLabel?.text = productResults[indexPath.row].name
        }
        return cell
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)

        coder.encode(entitySelected, forKey: "ENTITY")
        
        let indexPath = tableView.indexPathForSelectedRow
        if let index = indexPath {
            if entitySelected == "Customer" {
                print(customerResults[index.row].IDCustomer)
                coder.encode(customerResults[index.row].IDCustomer, forKey: "ENTITY_ID")
            } else if entitySelected == "Product" {
                coder.encode(productResults[index.row].IDProduct, forKey: "ENTITY_ID")
            }
        }
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        entitySelected = coder.decodeObject(forKey: "ENTITY") as! String
        entityID = coder.decodeInteger(forKey: "ENTITY_ID")
        print("Decode done")
    }
}
