//
//  ViewController.swift
//  Clase3
//
//  Created by Alumno on 13/02/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ViewController2Delegate {

    

    @IBOutlet weak var actionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func showAlert(_ sender: UIButton) {
        let alert = UIAlertController(title: "Título del alert", message: "Contenido del alert", preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default) { (alert) in
            self.actionLabel.text = "Se ha finalizado un alert. (Okey)"
        }
        let actionCancel = UIAlertAction(title: "Cancelar", style: .cancel) { (alert) in
            self.actionLabel.text = "Se ha finalizado un alert. (Cancelled)"
        }
        alert.addAction(actionOk)
        alert.addAction(actionCancel)
        self.present(alert, animated: true){
            
        }
    }
    
    @IBAction func showActionSheet(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Título del alert", message: "Contenido del alert", preferredStyle: .actionSheet)
        let actionOk = UIAlertAction(title: "Ok", style: .default) { (actionSheet) in
            self.actionLabel.text = "Se ha finalizado un actionSheet. (Okey)"
        }
        actionSheet.addAction(actionOk)
        //en los iPads no se muestra el cancelar, son especiales
        if UIDevice.current.userInterfaceIdiom != .pad {
            let actionCancel = UIAlertAction(title: "Cancelar", style: .cancel) { (actionSheet) in
                self.actionLabel.text = "Se ha finalizado un actionSheet. (Cancelled)"
            }
            actionSheet.addAction(actionCancel)
        }
        //en los iPads no se muestran las cosas en forma de actionsheet, sino como popover. Tenemos que crear un controlador de popover para ello.
        if let popOverController = actionSheet.popoverPresentationController {
            
            //sobre qué view mostramos el popover en forma de un rectángulo que aparece en el centro de la pantalla y que se adapte al tamaño (0,0)
            popOverController.sourceView = self.view
            popOverController.sourceRect = CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: 0, height: 0)
        }
        self.present(actionSheet, animated: true){}
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    //es una funcion que se usa para pasar información entre ventanas cuando vamos a una ventana. Solo se puede tener uno por controlador. Si tenemos varias conexiones tendríamos que identificar quién ha hecho cada conexión
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ViewController2
        destination.newValue = "Valor puesto desde otra ventana"
        destination.delegate = self
    }
    /*
    //es una funcion que se usa para pasar información cuando VOLVEMOS de una pantalla hacia otra. Es en el sentido contrario al segue
    @IBAction func unwind(for unwindSegue: UIStoryboardSegue) {
        let source = unwindSegue.source as! ViewController2
        actionLabel.text = source.newValue
        
    }
    */
    //esto se ha puesto para implementar la interfaz de viewController2Delegate
    func endAndReturn(_ result: String, controller: ViewController2) {
        actionLabel.text = result
        controller.dismiss(animated: true, completion: nil)
    }
    
}

