//
//  ProductListViewController.swift
//  Project2
//
//  Created by Alumno on 20/03/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import UIKit
import CoreData

class ProductListViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var context: NSManagedObjectContext? = nil

    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBAction func editBtnTapped(_ sender: Any) {
        if(self.tableView.isEditing){
            self.tableView.setEditing(false, animated:true)
            editBtn.title = "Edit"
        }else{
            self.tableView.setEditing(true, animated:true)
            editBtn.title = "Done"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    //MARK: - Consultas
    func insert(name: String, description: String, price: Decimal) {
        
        let product = Product(context: fetched.managedObjectContext)
        product.name = name
        product.productDescription = description
        product.price = price as NSDecimalNumber
        //customer.orders = NSOrderedSet(array: [])
        
        context?.insert(product)
        do{
            try context?.save()
        } catch {
            print("Insert error")
            //Algo fue mal
        }
    }
    
    func update(product: Product, name: String, description: String, price: Decimal){
        product.name = name
        product.productDescription = description
        product.price = price as NSDecimalNumber
        do{
            try context?.save()
        } catch{
            print("Update error")
        }
    }
    
    func delete(product: Product){
        context?.delete(product)
        do{
            try context?.save()
        }catch{
            print("Delete error")
        }
    }
    //MARK: - Operaciones relacionadas con la delegación de de las consultas
    var fetched: NSFetchedResultsController<Product> {
        if _fetched == nil{
            let request: NSFetchRequest<Product> = Product.fetchRequest()
            
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
    
    var _fetched: NSFetchedResultsController<Product>? = nil
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetched.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetched.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = fetched.object(at: indexPath).name
        cell.detailTextLabel?.text = fetched.object(at: indexPath).price?.description
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(product: fetched.object(at: indexPath))
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as? ProductDetailsViewController
        switch segue.identifier {
        case "edit":
            let tableIndex = tableView.indexPathForSelectedRow
            vc?.productNameText = fetched.object(at: tableIndex!).name!
            vc?.productDescriptionText = fetched.object(at: tableIndex!).productDescription!
            vc?.productPriceText = (fetched.object(at: tableIndex!).price?.description)!
            vc?.isForUpdate = true
            break
        default:
            break
        }

    }
    
    
    @IBAction func unwindToProductList(source: UIStoryboardSegue){
        let vc = source.source as! ProductDetailsViewController
        if(vc.isForUpdate){
            let aux = fetched.object(at: tableView.indexPathForSelectedRow!)
            update(product: aux, name: vc.productNameText, description: vc.productDescriptionText, price: Decimal(string: vc.productPriceText)!)
            vc.isForUpdate = false
        }else{
            insert(name: vc.productNameText, description: vc.productDescriptionText, price: Decimal(string: vc.productPriceText)!)
            vc.isForUpdate = false
        }
    }

}
