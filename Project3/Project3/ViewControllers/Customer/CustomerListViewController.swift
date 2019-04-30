//
//  CustomerListViewController.swift
//  Project2
//
//  Created by Alumno on 20/03/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import UIKit
import CoreData

class CustomerListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBAction func editBtnTapped(_ sender: Any) {
        if(self.tableView.isEditing){
            self.tableView.setEditing(false, animated:true)
            editButton.title = "Edit"
        }else{
            self.tableView.setEditing(true, animated:true)
            editButton.title = "Done"
        }
    }
    
    var context: NSManagedObjectContext? = nil
    
    let customerService = CustomerQueryService()
    var queryResults: [CustomerModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        
        customerService.delegate = self
        getAll()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    //MARK: - Consultas
    func getAll(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        customerService.getAll(){ results, errorMsg in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.queryResults = results
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPoint.zero, animated: false)
            if !errorMsg.isEmpty { print("Search error: " + errorMsg) }
            
        }
    }
    
    func insert(address: String, name: String) {
        
        var params: [String: Any] = [:]
        
        params["address"] = address
        params["name"] = name
        
        customerService.insert(params: params){ insertedID, errorMsg in
            self.getAll()
        }
    }
    
    func update(name: String, address: String, idCustomer: Int){
        var params: [String: Any] = [:]
        
        params["name"] = name
        params["address"] = address
        params["IDCustomer"] = idCustomer
        
        customerService.update(params: params){ updateResult, errorMsg in
            if updateResult {
                self.getAll()
            }
        }
    }

    func delete(IDCustomer: Int){
        let params = ["IDCustomer" : IDCustomer]
        
        customerService.delete(params: params) { deleteResult, errorMsg in
            print(deleteResult)
            if deleteResult {
                self.getAll()
            }
        }
    }
    
    //MARK: - Operaciones relacionadas con la delegación de de las consultas
    var fetched: NSFetchedResultsController<Customer> {
        if _fetched == nil{
            let request: NSFetchRequest<Customer> = Customer.fetchRequest()
            //Anotamos cómo queremos que se ordenen los campos de la tabla
            let name = NSSortDescriptor(key: "name", ascending: true)
            
            //Se los añadimos a la req en el orden que queramos. Primero se ordenarán por año y luego por nombre.
            request.sortDescriptors = [name]
            
            //Le podemos aplicamos a la req un filtro. El %@ es un parámetro que se sustituye por lo que pogamos en el segundo parámentro. Tomaría en cuenta solo los campos de la tabla que cumplan con el formato que le pasamos en el predicado.
            //request.predicate = NSPredicate(format: "name = %@", [])
            
            //Este es el encargado de hacer la consulta a la base de datos. Nos da los resultados ya de tal manera que fácil poder tratarlos como una tabla. Es mucho mejor que hacer un request.perform() o parecido que me devolvería un array plano. Fetched y _fetched tienen las mismas características (uno está dentro del otro)
            _fetched = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context!,
                sectionNameKeyPath: nil,
                cacheName: "cache")
            //El delegado de la consulta (encargado de hacer las operaciones cuando las consultas se llevan a cabo) dijimos que era esta propia clase (con el fetchedResultControllerDelegate)
            _fetched?.delegate = self
            do{
                //Llevamos a cabo la operación
                try _fetched?.performFetch()
            } catch {
                //Hay algún problema en el fetch
            }
        }
        return _fetched!
    }
    
    var _fetched: NSFetchedResultsController<Customer>? = nil
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return queryResults.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerCell", for: indexPath)
        // Configure the cell...
        cell.textLabel?.text = queryResults[indexPath.row].name
        cell.detailTextLabel?.text = queryResults[indexPath.row].address
        return cell
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let aux = queryResults[indexPath.row].IDCustomer
            delete(IDCustomer: aux)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as? CustomerDetailsViewController
        switch segue.identifier {
        case "edit":
            let tableIndex = tableView.indexPathForSelectedRow
            vc?.customerNameText = queryResults[(tableIndex?.row)!].name
            vc?.customerAddressText = queryResults[(tableIndex?.row)!].address
            vc?.IDCustomer = queryResults[(tableIndex?.row)!].IDCustomer
            vc?.isForUpdate = true
            break
        default:
            break
        }
    }
    
    @IBAction func unwindInsert(segue: UIStoryboardSegue){
        let vc = segue.source as? CustomerDetailsViewController
        if (vc?.isForUpdate ?? false){
            update(name: (vc?.customerNameText)!, address: (vc?.customerAddressText)!, idCustomer: (vc?.IDCustomer)!)
            vc?.isForUpdate = false
        }else{
            insert(address: (vc?.customerAddressText)!, name: (vc?.customerNameText)!)
        }
    }

}
