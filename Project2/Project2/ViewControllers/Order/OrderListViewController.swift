//
//  OrderListViewController.swift
//  Project2
//
//  Created by Alumno on 20/03/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import UIKit
import CoreData

class OrderListViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var context: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    /*
    //MARK: - Operaciones relacionadas con la delegación de de las consultas
    var fetched: NSFetchedResultsController<Customer> {
        if _fetched == nil{
            let request: NSFetchRequest<Customer> = Customer.fetchRequest()
            
            //Anotamos cómo queremos que se ordenen los campos de la tabla
            let nameOrder = NSSortDescriptor(key: "name", ascending: true)
            
            //Se los añadimos a la req en el orden que queramos. Primero se ordenarán por año y luego por nombre.
            request.sortDescriptors = [nameOrder]
            
            //Le podemos aplicamos a la req un filtro. El %@ es un parámetro que se sustituye por lo que pogamos en el segundo parámentro. Tomaría en cuenta solo los campos de la tabla que cumplan con el formato que le pasamos en el predicado.
            //request.predicate = NSPredicate(format: "name = %@", [])
            
            //Este es el encargado de hacer la consulta a la base de datos. Nos da los resultados ya de tal manera que fácil poder tratarlos como una tabla. Es mucho mejor que hacer un request.perform() o parecido que me devolvería un array plano. Fetched y _fetched tienen las mismas características (uno está dentro del otro)
            _fetched = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context!,
                sectionNameKeyPath: "",
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
    */
    var _fetched: NSFetchedResultsController<Order>? = nil
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //since we are not grouping customers we are grouping them in only 1 group
        return 1
    }
/*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetched.sections?[section].numberOfObjects ?? 0
    }
*/
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
