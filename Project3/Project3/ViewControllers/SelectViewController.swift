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
    var customerSelected: CustomerModel? = nil
    var productSelected: ProductModel? = nil
    
    var customerResults: [CustomerModel] = []
    var productResults: [ProductModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customerResults = CustomerQueryService.staticCustomers
        productResults = ProductQueryService.staticProducts
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if(customerSelected != nil){
            let indexPath = lookForCustomer(customer: customerSelected!)
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.top)
        } else if (productSelected != nil){
            let indexPath = lookForProduct(product: productSelected!)
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.top)
        }
    }
 
    func lookForCustomer(customer: CustomerModel) -> IndexPath{
        var indexPath = NSIndexPath()
        for section in 0..<self.tableView.numberOfSections{
            
            for row in 0..<self.tableView.numberOfRows(inSection: section) {
                
                let indexPathAux = NSIndexPath(row: row, section: section)
                if(customerResults[indexPathAux.row].IDCustomer == customer.IDCustomer){
                    indexPath = indexPathAux
                }
                
            }
            
        }
        return indexPath as IndexPath
    }
    
    func lookForProduct(product: ProductModel) -> IndexPath{
        var indexPath = NSIndexPath()
        for section in 0..<self.tableView.numberOfSections{
            
            for row in 0..<self.tableView.numberOfRows(inSection: section) {
                
                let indexPathAux = NSIndexPath(row: row, section: section)
                if(productResults[indexPathAux.row].IDProduct == product.IDProduct){
                    indexPath = indexPathAux
                }
            }
        }
        return indexPath as IndexPath
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
    
    func setFetch(entity: String){
        if(entity == "Customer"){
            entitySelected = "Customer"
        } else {
            entitySelected = "Product"
        }
    }
    
    func setCustomer(entity: CustomerModel?){
        customerSelected = entity
    }
    
    func setProduct(entity: ProductModel?){
        productSelected = entity
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
        
        let jsonEncoder = JSONEncoder()
        
        do{
            if(customerSelected != nil){
                try? encodeCustom(modelObject: customerSelected!, jsonEncoder: jsonEncoder, coder: coder, key: "SELECT_CUSTOMER")
            }
            
            if(productSelected != nil){
                try? encodeCustom(modelObject: productSelected!, jsonEncoder: jsonEncoder, coder: coder, key: "SELECT_PRODUCT")
            }
        }
        coder.encode(entitySelected, forKey: "ENTITY")
        
    }
    
    func encodeCustom(modelObject: Any, jsonEncoder: JSONEncoder, coder: NSCoder, key: String) throws{
        var jsonData: Data? = nil
        var jsonString: String? = nil
        
        if (key == "SELECT_CUSTOMER") {
            jsonData = try jsonEncoder.encode(modelObject as! CustomerModel)
        } else if (key == "SELECT_PRODUCT") {
            jsonData = try jsonEncoder.encode(modelObject as! ProductModel)
        }
        jsonString = String(data: jsonData!, encoding: .utf8)!
        
        print("Encoded \(key): \(jsonString ?? "hola")")
        
        coder.encode(jsonString, forKey: key)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        entitySelected = coder.decodeObject(forKey: "ENTITY") as! String
        
        let jsonDecoder = JSONDecoder()
        do {
            try decodeCustom(jsonDecoder: jsonDecoder, coder: coder, key: "SELECT_CUSTOMER")
            try decodeCustom(jsonDecoder: jsonDecoder, coder: coder, key: "SELECT_PRODUCT")
            
        } catch let parseError as NSError {
            print("JSONSerialization error: \(parseError.localizedDescription)\n")
        }
    }
    
    func decodeCustom(jsonDecoder: JSONDecoder, coder: NSCoder, key: String) throws {
        let coderData = coder.decodeObject(forKey: key)
        if(coderData != nil){
            print("\(key) found...\n")
            let jsonString = coderData as! String
            let jsonData = jsonString.data(using: .utf8)
            
            if(key == "CUSTOMER_ORDER") {
                self.customerSelected = try jsonDecoder.decode(CustomerModel.self, from: jsonData!)
                print("Customer decoded")
            } else if (key == "PRODUCT_ORDER") {
                self.productSelected = try jsonDecoder.decode(ProductModel.self, from: jsonData!)
                print("Product decoded")
            }
        }
    }
}
