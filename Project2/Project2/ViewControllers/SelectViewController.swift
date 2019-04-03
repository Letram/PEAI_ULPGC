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
    var customerSelected: Customer? = nil
    var productSelected: Product? = nil
    
    //para un fetched de tipo genérico
    //var cosa: NSFetchedResultsController<NSFetchRequestResult>? = nil
    //uiapplication.share.delegate as! appdelegate -> persistentStore.context
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
    func lookForCustomer(customer: Customer) -> IndexPath{
        var indexPath = NSIndexPath()
        for section in 0..<self.tableView.numberOfSections{
            
            for row in 0..<tableView.numberOfRows(inSection: section) {
                
                let indexPathAux = NSIndexPath(row: row, section: section)
                if(customerFetched.object(at: indexPathAux as IndexPath) == customer){
                    indexPath = indexPathAux
                }
            }
        }
        return indexPath as IndexPath
    }
    
    func lookForProduct(product: Product) -> IndexPath{
        var indexPath = NSIndexPath()
        for section in 0..<self.tableView.numberOfSections{
            
            for row in 0..<tableView.numberOfRows(inSection: section) {
                
                let indexPathAux = NSIndexPath(row: row, section: section)
                if(productFetched.object(at: indexPathAux as IndexPath) == product){
                    indexPath = indexPathAux
                }
            }
        }
        return indexPath as IndexPath
    }
    
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        if(entitySelected == "Customer"){
            customerSelected = customerFetched.object(at: tableView.indexPathForSelectedRow!)
        }else{
            productSelected = productFetched.object(at: tableView.indexPathForSelectedRow!)
        }
        performSegue(withIdentifier: "unwindToOrderDetails", sender: self)
    }
    //MARK: - Operaciones relacionadas con la delegación de de las consultas
    var customerFetched: NSFetchedResultsController<Customer> {
        if _customerFetched == nil{
            let request: NSFetchRequest<Customer> = Customer.fetchRequest()
            
            //Anotamos cómo queremos que se ordenen los campos de la tabla
            let name = NSSortDescriptor(key: "name", ascending: true)
            
            //Se los añadimos a la req en el orden que queramos. Primero se ordenarán por año y luego por nombre.
            request.sortDescriptors = [name]
            
            //Le podemos aplicamos a la req un filtro. El %@ es un parámetro que se sustituye por lo que pogamos en el segundo parámentro. Tomaría en cuenta solo los campos de la tabla que cumplan con el formato que le pasamos en el predicado.
            //request.predicate = NSPredicate(format: "name = %@", [])
            
            //Este es el encargado de hacer la consulta a la base de datos. Nos da los resultados ya de tal manera que fácil poder tratarlos como una tabla. Es mucho mejor que hacer un request.perform() o parecido que me devolvería un array plano. Fetched y _fetched tienen las mismas características (uno está dentro del otro)
            _customerFetched = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context!,
                sectionNameKeyPath: nil,
                cacheName: "cache") as? NSFetchedResultsController<NSFetchRequestResult>
            
            //El delegado de la consulta (encargado de hacer las operaciones cuando las consultas se llevan a cabo) dijimos que era esta propia clase (con el fetchedResultControllerDelegate)
            _customerFetched?.delegate = self
            
            do{
                //Llevamos a cabo la operación
                try _customerFetched?.performFetch()
            } catch {
                //Hay algún problema en el fetch
            }
        }
        return _customerFetched! as! NSFetchedResultsController<Customer>
    }
    
    var productFetched: NSFetchedResultsController<Product> {
        if _productFetched == nil{
            let request: NSFetchRequest<Product> = Product.fetchRequest()
            
            //Anotamos cómo queremos que se ordenen los campos de la tabla
            let name = NSSortDescriptor(key: "name", ascending: true)
            
            //Se los añadimos a la req en el orden que queramos. Primero se ordenarán por año y luego por nombre.
            request.sortDescriptors = [name]
            
            //Le podemos aplicamos a la req un filtro. El %@ es un parámetro que se sustituye por lo que pogamos en el segundo parámentro. Tomaría en cuenta solo los campos de la tabla que cumplan con el formato que le pasamos en el predicado.
            //request.predicate = NSPredicate(format: "name = %@", [])
            
            //Este es el encargado de hacer la consulta a la base de datos. Nos da los resultados ya de tal manera que fácil poder tratarlos como una tabla. Es mucho mejor que hacer un request.perform() o parecido que me devolvería un array plano. Fetched y _fetched tienen las mismas características (uno está dentro del otro)
            _productFetched = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context!,
                sectionNameKeyPath: nil,
                cacheName: "cache") as? NSFetchedResultsController<NSFetchRequestResult>
            
            //El delegado de la consulta (encargado de hacer las operaciones cuando las consultas se llevan a cabo) dijimos que era esta propia clase (con el fetchedResultControllerDelegate)
            _productFetched?.delegate = self
            
            do{
                //Llevamos a cabo la operación
                try _productFetched?.performFetch()
            } catch {
                //Hay algún problema en el fetch
            }
        }
        return _productFetched! as! NSFetchedResultsController<Product>
    }
    
    var _customerFetched: NSFetchedResultsController<NSFetchRequestResult>? = nil
    var _productFetched: NSFetchedResultsController<NSFetchRequestResult>? = nil
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    func setFetch(entity: String){
        if(entity == "Customer"){
            entitySelected = "Customer"
        } else {
            entitySelected = "Product"
        }
    }
    
    func setCustomer(entity: Customer?){
        customerSelected = entity
    }
    
    func setProduct(entity: Product?){
        productSelected = entity
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if(entitySelected == "Customer"){
            return customerFetched.sections?.count ?? 0
        }
        else{
            return productFetched.sections?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(entitySelected == "Customer"){
            return customerFetched.sections?[section].numberOfObjects ?? 0
        }
        else{
            return productFetched.sections?[section].numberOfObjects ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath)

        // Configure the cell...
        if(entitySelected == "Customer"){
            cell.textLabel?.text = customerFetched.object(at: indexPath).name
        }
        else{
            cell.textLabel?.text = productFetched.object(at: indexPath).name
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
