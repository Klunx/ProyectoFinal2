//
//  DetailLibroVC.swift
//  ProyectoFinalv2
//
//  Created by Fernando Renteria Correa on 31/07/2016.
//  Copyright © 2016 Fernando Renteria Correa. All rights reserved.
//

import UIKit

class DetailLibroVC: UIViewController {

    var libroDetail = Libro()

    @IBOutlet weak var isbnLbl: UILabel!
    @IBOutlet weak var portadaContainer: UIImageView!
    
    @IBOutlet weak var autorLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        autorLbl.text = ""
        if libroDetail.titulo != "" {
            isbnLbl.text = libroDetail.titulo
            autorLbl.text = ""
            for autor in libroDetail.autores {
                autorLbl.text = autorLbl.text! + "\(autor)\n"
            }
            let urlImg = NSURL(string: libroDetail.portada)
            let imagenData = NSData(contentsOfURL: urlImg!)
            portadaContainer.image = UIImage(data: imagenData!)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
