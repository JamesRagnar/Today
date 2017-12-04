//
//  LocationTableViewCell.swift
//  Today
//
//  Created by James Harquail on 2017-12-04.
//  Copyright © 2017 Ragnar Development. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LocationTableViewCell: UITableViewCell {
    
    static var reuseIdentifier: String {
        return "\(self)"
    }
    
    static func desiredHeight() -> CGFloat {
        return 40
    }
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.frame = contentView.bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isUserInteractionEnabled = false
        return mapView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(mapView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        mapView.removeAnnotations(mapView.annotations)
    }
    
    public func loadData(from event: Event) {
        let latitude = event.latitude
        let longitude = event.longitude
        
        if latitude == 0 && longitude == 0 {
            return
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: false)
    }
}
