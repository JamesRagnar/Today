//
//  EventTableViewCell.swift
//  Today
//
//  Created by James Harquail on 2017-11-22.
//  Copyright © 2017 Ragnar Development. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import MapKit

class EventTableViewCell: UITableViewCell {
    
    static var reuseIdentifier: String {
        return "\(self)"
    }
    
    static func desiredHeight(for event: Event) -> CGFloat {
        return event.address == nil ? 40 : 200
    }
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-UltraLight", size: 25)
        label.backgroundColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-UltraLight", size: 25)
        label.backgroundColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.isUserInteractionEnabled = false
        return mapView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.backgroundColor = .white
        
        contentView.addSubview(mapView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cellWidth = contentView.bounds.width
        let timeLabelWidth: CGFloat = 60
        let labelHeight: CGFloat = 40
        timeLabel.frame = CGRect(x: 0, y: 0, width: timeLabelWidth, height: labelHeight)
        titleLabel.frame = CGRect(x: timeLabelWidth, y: 0, width: cellWidth - timeLabelWidth, height: labelHeight)
        mapView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.height)
    }
    
    public func loadData(from event: Event) {
        timeLabel.text = ""
        titleLabel.text = event.title
        
        guard let address = event.address else {
            mapView.alpha = 0
            return
        }
        
        mapView.alpha = 1
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = address
        //        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard error == nil, let mapItem = response?.mapItems.first else {
                return
            }
            let annotation = MKPointAnnotation()
            annotation.coordinate = mapItem.placemark.coordinate
            self?.mapView.addAnnotation(annotation)
            self?.mapView.showAnnotations([annotation], animated: false)
        }
    }
}
