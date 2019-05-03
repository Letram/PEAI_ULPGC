import UIKit
import CoreData

class OrderListViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBAction func editBtnTapped(_ sender: UIBarButtonItem) {
        if(self.tableView.isEditing){
            self.tableView.setEditing(false, animated:true)
            editBtn.title = "Edit"
        }else{
            self.tableView.setEditing(true, animated:true)
            editBtn.title = "Done"
        }
    }
    var context: NSManagedObjectContext? = nil
    
    let orderService = OrderQueryService()
    var queryResults: [CustomerOrders] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAll()
        
    }
    
    //MARK: - Consultas
    func getAll(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        orderService.getAll(){ results, errorMsg in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.refreshProducts(newOrders: results as! [CustomerOrders])
            if !errorMsg.isEmpty { print("Search error: " + errorMsg) }
            
        }
    }
    
    func insert(description: String, name: String, price: Float) {
        
        var params: [String: Any] = [:]
        
        params["description"] = description
        params["name"] = name
        params["price"] = price
        
        orderService.insert(params: params){ results, errorMsg in
            self.refreshProducts(newOrders: results as! [CustomerOrders])
        }
    }
    
    func update(name: String, description: String, idProduct: Int, price: Float){
        var params: [String: Any] = [:]
        
        params["name"] = name
        params["description"] = description
        params["IDProduct"] = idProduct
        params["price"] = price
        
        orderService.update(params: params){ results, errorMsg in
            self.refreshProducts(newOrders: results as! [CustomerOrders])
        }
    }
    
    func delete(IDProduct: Int){
        let params = ["IDProduct" : IDProduct]
        
        orderService.delete(params: params) { results, errorMsg in
            self.refreshProducts(newOrders: results as! [CustomerOrders])
        }
    }
    
    func refreshProducts(newOrders: [CustomerOrders]){
        self.queryResults = newOrders
        self.tableView.reloadData()
        self.tableView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    /*
    func insert(code: String, customer: Customer, product: Product, price: Decimal, quantity: Int16, date: Date) {
        
        let order = Order(context: fetched.managedObjectContext)
        order.code = code
        order.customer = customer
        order.product = product
        order.total = price as NSDecimalNumber
        order.quantity = quantity
        order.date = date
        
        context?.insert(order)
        do{
            try context?.save()
        } catch {
            print("Insert error")
            //Algo fue mal
        }
    }
    
    func update(order: Order, code: String, customer: Customer, product: Product, price: Decimal, quantity: Int16, date: Date){
        order.code = code
        order.customer = customer
        order.product = product
        order.total = price as NSDecimalNumber
        order.quantity = quantity
        order.date = date
        do{
            try context?.save()
        } catch{
            print("Update error")
        }
    }
    
    func delete(order: Order){
        context?.delete(order)
        do{
            try context?.save()
        }catch{
            print("Delete error")
        }
    }
    */
    //MARK: - Operaciones relacionadas con la delegación de de las consultas
    var fetched: NSFetchedResultsController<Order> {
        if _fetched == nil{
            let request: NSFetchRequest<Order> = Order.fetchRequest()
            
            //Anotamos cómo queremos que se ordenen los campos de la tabla
            let orderByCode = NSSortDescriptor(key: "code", ascending: true)
            let orderByCustomerName = NSSortDescriptor(key: "customer.name", ascending: true)
            //Se los añadimos a la req en el orden que queramos. Primero se ordenarán por año y luego por nombre.
            request.sortDescriptors = [orderByCustomerName, orderByCode]
            
            //Le podemos aplicamos a la req un filtro. El %@ es un parámetro que se sustituye por lo que pogamos en el segundo parámentro. Tomaría en cuenta solo los campos de la tabla que cumplan con el formato que le pasamos en el predicado.
            //request.predicate = NSPredicate(format: "name = %@", [])
            
            //Este es el encargado de hacer la consulta a la base de datos. Nos da los resultados ya de tal manera que fácil poder tratarlos como una tabla. Es mucho mejor que hacer un request.perform() o parecido que me devolvería un array plano. Fetched y _fetched tienen las mismas características (uno está dentro del otro)
            _fetched = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context!,
                sectionNameKeyPath: "customer.name",
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
    
    var _fetched: NSFetchedResultsController<Order>? = nil
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //since we are not grouping customers we are grouping them in only 1 group
        return queryResults.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queryResults[section].customerOrders.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath)

        // Configure the cell...
        
        //TODO: Rebuild this not to get an error
        print("row: \(indexPath.row) - item: \(indexPath.item)")
        cell.textLabel!.text = queryResults[indexPath.row].customerOrders[indexPath.item].code
        cell.detailTextLabel?.text = queryResults[indexPath.row].customerOrders[indexPath.item].product.name
        
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return queryResults[section].customerName
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //delete(order: fetched.object(at: indexPath))
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as! OrderDetailsViewController
        if(segue.identifier == "create" || segue.identifier == "edit"){
            vc.context = context
            if(segue.identifier == "edit"){
                let currentOrder: Order = fetched.object(at: tableView.indexPathForSelectedRow!)
                vc.code = currentOrder.code!
                vc.date = currentOrder.date
                vc.quantity = currentOrder.quantity
                vc.totalPrice = currentOrder.total! as Decimal
                vc.customer = currentOrder.customer
                vc.product = currentOrder.product
                vc.order = currentOrder
                vc.isForUpdate = true
            }
        }
    }

    @IBAction func unwindToOrderList(segue: UIStoryboardSegue){
        let vc = segue.source as! OrderDetailsViewController
        if(!vc.isForUpdate){
            //insert(code: vc.code, customer: vc.customer!, product: vc.product!, price: vc.totalPrice, quantity: vc.quantity, date: vc.date!)
        } else {
            //update(order: vc.order!, code: vc.code, customer: vc.customer!, product: vc.product!, price: vc.totalPrice, quantity: vc.quantity, date: vc.date!)
            vc.isForUpdate = false
        }
    }

}
