//
//  AgregarLibroTVC.swift
//  ProyectoFinalv2
//
//  Created by Fernando Renteria Correa on 31/07/2016.
//  Copyright © 2016 Fernando Renteria Correa. All rights reserved.
//

import UIKit

class AgregarLibroTVC: UITableViewController {

    var libros = [Libro]()
    
    @IBOutlet weak var isbnTxt: UITextField!
    
    @IBAction func agregarLibro(sender: UIBarButtonItem) {
        let isbnStr = isbnTxt.text!
        if isbnStr == "" {
            alertaError("Agrega un isbn por favor.")
        } else if (encontrarISBN(isbnStr)) {
            alertaError("Ese libro ya esta registrado.")
        }
        else {
            agregarLibros(isbnStr)
            self.tableView.reloadData()
        }
        isbnTxt.text = ""
    
    }
    
    func encontrarISBN (isbn: String) -> Bool {
        var libroFlag : Bool = false
        for libro in self.libros {
            if libro.isbn == isbn {
                libroFlag = true
            }
        }
        return libroFlag
    }
    
    func alertaError(mensaje : String) {
        let alerta = UIAlertController(title: "Error", message: mensaje, preferredStyle: UIAlertControllerStyle.Alert)
        alerta.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(alerta, animated: true, completion: nil)
        
    }
    
    func agregarLibros(isbn: String) {
        
        var tmpAutores: [String] = []
        var tmpPortada : String = ""
        
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + isbn
        let mainObject : String = "ISBN:" + isbn
        let url = NSURL(string: urls)
        let JSONData : NSData? = NSData(contentsOfURL: url!)
        if (JSONData == nil) {
            alertaError("Recurso no accesible.")
        }
        else {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(JSONData!, options:NSJSONReadingOptions.MutableLeaves)
                //let diccionario = json[mainObject] as! NSDictionary
                guard let diccionario :NSDictionary = json[mainObject] as? NSDictionary else {
                    alertaError("Recurso no accesible.")
                    // put in function
                    return
                }
                let titulo = diccionario["title"] as! NSString as String
                //let publishers = diccionario["publishers"] as! NSArray
                let autores = diccionario["authors"] as! NSArray
                for autor in autores {
                    let tmpAutor : String = autor["name"] as! NSString as String
                    tmpAutores.append(tmpAutor)
                }
                if diccionario["cover"] != nil {
                    let img = diccionario["cover"] as! NSDictionary
                    tmpPortada = img["medium"] as! NSString as String
                }
                
                libros.append(Libro(titulo: titulo, isbn: isbn, autores: tmpAutores, portada: tmpPortada))
                
                
            }
            catch let JSONError as NSError {
                let errorString : String = "\(JSONError)"
                alertaError(errorString)
                
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        return libros.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CeldaLibro", forIndexPath: indexPath)

        // Configure the cell...
        // Configure the cell...
        cell.textLabel?.text = libros[indexPath.row].titulo
        
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
        if segue.identifier == "show" {
            let ctrl = segue.destinationViewController as! DetailLibroVC
            let indexPath = tableView.indexPathForSelectedRow
            let libro = libros[indexPath!.row]
            
            ctrl.libroDetail = libro
        }
    }
 

}
