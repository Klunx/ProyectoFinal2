//
//  Punto.swift
//  ProyectoFinalv2
//
//  Created by Fernando Renteria Correa on 18/07/2016.
//  Copyright © 2016 Fernando Renteria Correa. All rights reserved.
//

import Foundation
import MapKit

class Punto {
    
    var anotacion : CLLocationCoordinate2D!
    var image: UIImage?
    var titulo: String = ""
    
    init () {}
    
    init (anotacion : CLLocationCoordinate2D, titulo : String) {
        self.anotacion = anotacion
        self.titulo = titulo
    }
    
}