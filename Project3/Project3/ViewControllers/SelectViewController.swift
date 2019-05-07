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
    
    //para un fetched de tipo genérico
    //var cosa: NSFetchedResultsController<NSFetchRequestResult>? = nil
    //uiapplication.share.delegate as! appdelegate -> persistentStore.context
    override func viewDidLoad() {
        super.viewDidLoad()

        customerResults = CustomerQueryService.staticCustomers
        productResults = ProductQueryService.staticProducts
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    /*
    override func viewDidAppear(_ animated: Bool) {
        if(customerSelected != nil){
            let indexPath = lookForCustomer(customer: customerSelected!)
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.top)
        } else if (productSelected != nil){
            let indexPath = lookForProduct(product: productSelected!)
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.top)
        }
    }
 */
    func lookForCustomer(customer: CustomerModel) -> IndexPath{
        var indexPath = NSIndexPath()
        for section in 0..<self.tableView.numberOfSections{
            
            for row in 0..<tableView.numberOfRows(inSection: section) {
                
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
            
            for row in 0..<tableView.numberOfRows(inSection: section) {
                
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
