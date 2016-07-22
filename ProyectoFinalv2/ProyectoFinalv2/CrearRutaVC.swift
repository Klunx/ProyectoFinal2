//
//  CrearRutaVC.swift
//  ProyectoFinalv2
//
//  Created by Fernando Renteria Correa on 18/07/2016.
//  Copyright © 2016 Fernando Renteria Correa. All rights reserved.
//

import UIKit
import CoreData

class CrearRutaVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var txtTitulo: UITextField!
    @IBOutlet weak var txtDesc: UITextView!
    @IBOutlet weak var btnAgregarFoto: UIButton!
    @IBOutlet weak var imgFotoVista: UIImageView!
    
    var contexto: NSManagedObjectContext? = nil
    
    private let myPicker = UIImagePickerController()
    var ruta :Ruta = Ruta()
    
    @IBAction func tomarFoto() {
        myPicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(myPicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            btnAgregarFoto.hidden = true
        }
        
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        myPicker.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imgFotoVista.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        var validationFlag : Bool = true
        let tituloTmp : String = self.txtTitulo.text!
        let descTemp : String = self.txtDesc.text!
        
        if (tituloTmp == "") {
            alertaValidacion("Favor de ingresar titulo.")
            validationFlag = false
        }
        if (descTemp == "") {
            alertaValidacion("Favor de ingresar descripcion.")
            validationFlag = false
        }
        
        let rutaEntidad = NSEntityDescription.entityForName("Ruta", inManagedObjectContext: self.contexto!)
        let peticion = rutaEntidad?.managedObjectModel.fetchRequestFromTemplateWithName("obtenerRuta", substitutionVariables: ["titulo": tituloTmp])
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "crearRuta" {
            let nuevaRutaEntidad = NSEntityDescription.insertNewObjectForEntityForName("Ruta", inManagedObjectContext: self.contexto!)
            
            self.ruta.titulo = self.txtTitulo.text!
            self.ruta.descripcion = self.txtDesc.text!
            
            nuevaRutaEntidad.setValue(self.ruta.titulo, forKey: "titulo")
            nuevaRutaEntidad.setValue(self.ruta.descripcion, forKey: "descripcion")
            
            if (self.imgFotoVista.image != nil) {
                UIImageWriteToSavedPhotosAlbum(self.imgFotoVista.image!, nil, nil, nil)
                nuevaRutaEntidad.setValue(UIImagePNGRepresentation(self.imgFotoVista.image!), forKey: "imagen")
            }
            
            do {
                try self.contexto?.save()
            }
            catch {
            
            }
            
            let crearRutaView = segue.destinationViewController as! MapLocatorVC
            crearRutaView.ruta = self.ruta
        }
    }

}
