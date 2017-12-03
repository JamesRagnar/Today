//
//  EventFactory.swift
//  Today
//
//  Created by James Harquail on 2017-12-03.
//  Copyright © 2017 Ragnar Development. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class EventFactory {
    
    static func createEvent(_ coreDataManager: CoreDataManager, title: String?, date: Date?, address: String?) {
        
        let context = coreDataManager.persistentContainer.viewContext
        
        guard let newEvent = NSEntityDescription.insertNewObject(forEntityName: "Event",
                                                                 into: context) as? Event else  {
                                                                    return
        }
        
        newEvent.title = title
        newEvent.date = date
        newEvent.address = address
        
        coreDataManager.saveContext()
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = address
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard error == nil, let mapItem = response?.mapItems.first else {
                return
            }
            newEvent.latitude = mapItem.placemark.coordinate.latitude
            newEvent.longitude = mapItem.placemark.coordinate.longitude
            coreDataManager.saveContext()
        }
    }
}
