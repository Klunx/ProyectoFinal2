//
//  QRReaderVC.swift
//  ProyectoFinalv2
//
//  Created by Fernando Renteria Correa on 18/07/2016.
//  Copyright © 2016 Fernando Renteria Correa. All rights reserved.
//

import UIKit
import AVFoundation

class QRReaderVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // Iniciar Camara.
    var sesion : AVCaptureSession?
    // Capturar lo que esta viendo la camara.
    var capa : AVCaptureVideoPreviewLayer?
    // Enmarcar codigo QR.
    var marcoQR : UIView?
    // Almancenar codigo codigo QR.
    var urls : String?
    // Ruta.
    var ruta: Ruta?
    
    override func viewWillAppear(animated: Bool) {
        sesion?.startRunning()
        marcoQR?.frame = CGRectZero
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Capturar QR"
        // Dispositivo de entrada.
        let dispositivo = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            let entrada = try AVCaptureDeviceInput(device: dispositivo)
            sesion = AVCaptureSession()
            sesion?.addInput(entrada)
            let metaDatos = AVCaptureMetadataOutput()
            sesion?.addOutput(metaDatos)
            metaDatos.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            metaDatos.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            capa = AVCaptureVideoPreviewLayer(session: sesion!)
            capa?.videoGravity = AVLayerVideoGravityResizeAspectFill
            capa?.frame = view.layer.bounds
            view.layer.addSublayer(capa!)
            marcoQR = UIView()
            marcoQR?.layer.borderWidth = 3
            marcoQR?.layer.borderColor = UIColor.redColor().CGColor
            view.addSubview(marcoQR!)
            sesion?.startRunning()
        }
        catch {
            
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        marcoQR?.frame = CGRectZero
        if (metadataObjects == nil || metadataObjects.count == 0) {
            return
        }
        
        let objMetaDato = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if (objMetaDato.type == AVMetadataObjectTypeQRCode) {
            let objBordes = capa?.transformedMetadataObjectForMetadataObject(objMetaDato as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            marcoQR?.frame = objBordes.bounds
            if (objMetaDato.stringValue != nil) {
                self.urls = objMetaDato.stringValue
                let navc = self.navigationController
                navc?.performSegueWithIdentifier("detalle", sender: self)
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "regresarMapa" {
            let mapLocator = segue.destinationViewController as! MapLocatorVC
            mapLocator.ruta = self.ruta
        }
    }
 

}
