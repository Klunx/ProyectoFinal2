//
//  CargarRutaTVC.swift
//  ProyectoFinalv2
//
//  Created by Fernando Renteria Correa on 25/07/2016.
//  Copyright © 2016 Fernando Renteria Correa. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CargarRutaTVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var rutas = [NSManagedObject]()
    var contexto: NSManagedObjectContext? = nil
    var rutaTitulo : String = ""
    var rutaDesc : String = ""
    var rutaImage : UIImage? = nil
    private let myPicker = UIImagePickerController()

    @IBAction func agregarRuta(sender: AnyObject) {
        agregarNombre()
    }
    
    func agregarNombre() {
        let alert = UIAlertController(title: "Nueva Ruta", message: "Nombra la ruta", preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .Default, handler: { (action:UIAlertAction) -> Void in
            let textField = alert.textFields!.first
            if (textField!.text! == "") {
                self.alertaValidacion("Favor de ingresar titulo.")
            } else {
                self.rutaTitulo = textField!.text!
                self.agregarDescripcion()
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func agregarDescripcion() {
        let alert = UIAlertController(title: "Nueva Ruta", message: "Describe tu ruta", preferredStyle: .Alert)
        let saveAction = UIAlertAction(title: "Save", style: .Default, handler: { (action:UIAlertAction) -> Void in
            let textField = alert.textFields!.first
            if (textField!.text! == "") {
                self.alertaValidacion("Favor de ingresar una descripcion.")
            } else {
                self.rutaDesc = textField!.text!
                if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
                    self.salvarRuta()
                } else {
                    self.agregarFoto()
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func agregarFoto() {
        let alertaFotografia = UIAlertController(title: "Fuente", message: "Elige", preferredStyle: UIAlertControllerStyle.Alert);
        alertaFotografia.addAction(UIAlertAction(title: "Camara", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
            self.obtenerFotografiaCamara()
            
        }));
        alertaFotografia.addAction(UIAlertAction(title: "Album", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
            self.obtenerFotografiaCarrete()
            
        }));
        
        presentViewController(alertaFotografia, animated: true, completion: nil)
    
    }
    
    func obtenerFotografiaCamara() {
        myPicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(myPicker, animated: true, completion: nil)
    }
    
    func obtenerFotografiaCarrete() {
        myPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(myPicker, animated: true, completion: nil)
    }
    
    func salvarRuta() {
        
        if (validarRuta()){
            let nuevaRutaEntidad = NSEntityDescription.insertNewObjectForEntityForName("Ruta", inManagedObjectContext: self.contexto!)
            
            nuevaRutaEntidad.setValue(self.rutaTitulo, forKey: "titulo")
            nuevaRutaEntidad.setValue(self.rutaDesc, forKey: "descripcion")
            
            if (self.rutaImage != nil) {
                UIImageWriteToSavedPhotosAlbum(self.rutaImage!, nil, nil, nil)
                nuevaRutaEntidad.setValue(UIImagePNGRepresentation(self.rutaImage!), forKey: "imagen")
            }
            
            do {
                rutas.append(nuevaRutaEntidad)
                try self.contexto?.save()
                self.tableView.reloadData()
            }
            catch {
                
            }

        
        }
    
    }
    
    func validarRuta()->Bool {
        var validationFlag : Bool = true
        let rutaEntidad = NSEntityDescription.entityForName("Ruta", inManagedObjectContext: self.contexto!)
        let peticion = rutaEntidad?.managedObjectModel.fetchRequestFromTemplateWithName("obtenerRuta", substitutionVariables: ["titulo": self.rutaTitulo])
        do {
            let rutaEntidad2 = try self.contexto?.executeFetchRequest(peticion!)
            if (rutaEntidad2?.count > 0) {
                alertaValidacion("Una ruta con este titulo ya existe.")
                validationFlag = false
            }
        }
            
        catch {
            
        }
        
        return validationFlag
    }
    
    func alertaValidacion(mensaje : String) {
        let alerta = UIAlertController(title: "Error", message: mensaje, preferredStyle: .Alert)
        let accionOk = UIAlertAction(title: "Ok", style: .Default, handler: {accion in } )
        alerta.addAction(accionOk)
        self.presentViewController(alerta, animated: true, completion: nil)
        
    }
    
    func cargarRutas() {
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Ruta")
        
        do {
            let results = try contexto!.executeFetchRequest(fetchRequest)
            rutas = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myPicker.delegate = self
        cargarRutas()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        rutaImage = image
        self.salvarRuta()
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rutas.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Celda", forIndexPath: indexPath)

        let ruta = rutas[indexPath.row]
        
        cell.textLabel!.text = ruta.valueForKey("titulo") as? String

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let mapLocation = segue.destinationViewController as! MapLocatorVC
        let indexPath = self.tableView.indexPathForSelectedRow
        let rutaCargada = self.rutas[indexPath!.row]
        let titulo = rutaCargada.valueForKey("titulo") as? String!
        let desc = rutaCargada.valueForKey("descripcion") as? String!

        let ruta = Ruta(titulo: titulo!, descripcion: desc!)
        
        let puntosCargados = rutaCargada.valueForKey("tiene") as? Set<NSObject>
        for puntoCargado in puntosCargados! {
            let puntoCoor = CLLocationCoordinate2D(latitude: (puntoCargado.valueForKey("latitud") as? Double)!, longitude: (puntoCargado.valueForKey("longitud") as? Double)!)
            let puntoTitulo = puntoCargado.valueForKey("titulo") as? String!
            let punto = Punto(anotacion: puntoCoor, titulo: puntoTitulo!)
            ruta.puntosEnLaRuta.append(punto)
        }
        
        mapLocation.ruta = ruta
    }

}
