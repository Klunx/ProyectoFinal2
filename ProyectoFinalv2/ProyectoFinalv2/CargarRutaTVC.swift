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

class CargarRutaTVC: UITableViewController {
    
    private var rutas = [NSManagedObject]()
    var contexto: NSManagedObjectContext? = nil
   
    func cargarRutas() {
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Ruta")
        
        //3
        do {
            let results = try contexto!.executeFetchRequest(fetchRequest)
            rutas = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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