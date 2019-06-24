//
//  ViewController.swift
//  JFCore
//
//  Created by Javier Fuchs on 08/28/2016.
//  Copyright © 2016 Mobile Patagonia. All rights reserved.
//

import UIKit
import CoreLocation
import JFCore

class ViewController: BaseViewController {

    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var placemark: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var button: UIButton!
    var currentLocation : CLLocation?
    var placemarks : [CLPlacemark]?
    
    override func viewDidLoad() {
        self.title = "test"
        super.viewDidLoad()

        if let img = UIImage.init(named: "background") {
            self.view.backgroundColor = img.patternColor(customSize: UIScreen.main.bounds.size)
            let topImage = UIImage.init(named: "bird")
            let mergedImage = img.combineImages(topImage: topImage!)
            image.image = mergedImage
        }
        
        self.navigationItem.setAccessHeader(string: "This is the header")
        
        self.location.setAccessLabel()
        self.placemark.setAccessLabel()
        self.button.setAccessButton(string: "This is the button")
        self.image.setAccessImage(string: "This is the image")
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.observeLocationServices()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unobserveLocationServices()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(function: #function, line: #line)
    }

    fileprivate func observeLocationServices()
    {
        self.unobserveLocationServices()
        
        let queue = OperationQueue.main
        let nc = NotificationCenter.default
        nc.addObserver(forName: NSNotification.Name(rawValue: JFCore.Constants.Notification.locationUpdated), object: nil, queue: queue) {
                [weak self] (NSNotification) in
                guard let locs = LocationManager.instance.locations,
                    let f = locs.first,
                    let strong = self else {
                        return
                }
                strong.location.text = strong.locationDescription(f)
                strong.currentLocation = f
                strong.location.setAccessLabel()
                strong.reverseLocation(f)
        }
        
        nc.addObserver(forName: NSNotification.Name(rawValue: JFCore.Constants.Notification.locationError), object: nil, queue: queue) {
                [weak self]
                note in
                if let _: Error = note.object as? Error,
                   let strong = self {
                    strong.locationRestart()
                }
        }
        
        nc.addObserver(forName: NSNotification.Name(rawValue: JFCore.Constants.Notification.locationAuthorized), object: nil, queue: queue) {
                (NSNotification) in
                if !JFCore.LocationManager.instance.isAuthorized() {
                    // do nothing
                }
        }
    }
    
    func locationTitle(_ currentLocation : CLLocation) -> String {
        return currentLocation.title()
    }

    func locationDescription(_ currentLocation : CLLocation) -> String {
        return currentLocation.longDescription()
    }
    
    
    func placemarkDescription(_ placemark : CLPlacemark) -> String {
        return placemark.longDescription()
    }

    
    fileprivate func locationRestart() {
        JFCore.Common.synchronized(syncBlock: {
            LocationManager.instance.stop()
            LocationManager.instance.start()
        })
    }
    
    fileprivate func unobserveLocationServices()
    {
        for notification in [JFCore.Constants.Notification.locationUpdated,
                             JFCore.Constants.Notification.locationError,
                             JFCore.Constants.Notification.locationAuthorized] {
                                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notification), object: nil);
        }
    }

    
    func reverseLocation(_ location : CLLocation) {
        
        LocationManager.instance.reverseLocation(location: location, didFailWithError: { (jferror) in
            Analytics.logFatal(error:jferror)
            jferror.fatal()
        }) { [weak self] (placemarks) in
            guard let strong = self else { return }
            Analytics.logFunction(function: #function, parameters: ["location" : "\(placemarks.count)" as AnyObject])
            if let f = placemarks.first {
                strong.placemark.text = strong.placemarkDescription(f)
            }
            strong.placemark.setAccessLabel()
            strong.placemarks = placemarks
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "list" {
            let vc:ListViewController = segue.destination as! ListViewController
            guard let ps = self.placemarks,
                      let currentLocation = self.currentLocation else {
                        return
            }
            vc.placemarks = ps
            vc.title = self.locationTitle(currentLocation)
        }
    }
    
}

