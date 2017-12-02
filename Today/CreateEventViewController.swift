//
//  CreateEventViewController.swift
//  Today
//
//  Created by James Harquail on 2017-11-22.
//  Copyright © 2017 Ragnar Development. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class CreateEventViewController: UIViewController {
    
    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .save,
                                     target: self,
                                     action: #selector(saveButtonTapped))
        return button
    }()
    
    private lazy var entryView: NewEntryParserView = {
        let entryView = NewEntryParserView()
//        entryView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return entryView
    }()
    
    private let coreDataManager: CoreDataManager
    
    required init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        entryView.frame = self.view.safeAreaLayoutGuide.layoutFrame
    }
    
    override func loadView() {
        super.loadView()
        
        edgesForExtendedLayout = []
        
        navigationItem.rightBarButtonItem = saveButton
        
        view.backgroundColor = .gray
        
        view.addSubview(entryView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    @objc func saveButtonTapped() {
    }
    
    private func updateParsedEventData(from string: String) {
        
        let types: NSTextCheckingResult.CheckingType = [.date, .address]
        let detector = try? NSDataDetector.init(types: types.rawValue)
        let matches = detector?.matches(in: string,
                                        options: .reportProgress,
                                        range: NSRange(location: 0, length: string.count))
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 25)],
                                       range: NSRange(location: 0, length: attributedString.string.count))
        
        for match in matches ?? [] {
            if match.resultType == .date, let _ = match.date {
                attributedString.addAttributes([.foregroundColor : UIColor.blue], range: match.range)
            }
            
            if match.resultType == .address, let addressString = stringFrom(address: match.components) {
                attributedString.addAttributes([.foregroundColor: UIColor.green], range: match.range)
                
                let request = MKLocalSearchRequest()
                request.naturalLanguageQuery = addressString
                //        request.region = mapView.region
                let search = MKLocalSearch(request: request)
                search.start { response, error in
                    guard error == nil, let mapItem = response?.mapItems.first else {
                        return
                    }
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = mapItem.placemark.coordinate
                }
            }
        }
        
        // user attr string
    }
    
    private func stringFrom(address components: [NSTextCheckingKey : String]?) -> String? {
        guard let components = components else {
            return nil
        }
        
        var addressComponents = [String]()
        
        if let street = components[.street] {
            addressComponents.append(street)
        }
        
        if let city = components[.city] {
            addressComponents.append(city)
        }
        
        if let state = components[.state] {
            addressComponents.append(state)
        }
        
        if let zip = components[.zip] {
            addressComponents.append(zip)
        }
        
        if let country = components[.country] {
            addressComponents.append(country)
        }
        
        return addressComponents.joined(separator: " ")
    }
}

extension CreateEventViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        updateParsedEventData(from: textView.text)
    }
}
