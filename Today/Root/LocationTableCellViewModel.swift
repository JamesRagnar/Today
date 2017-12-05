//
//  LocationTableCellViewModel.swift
//  Today
//
//  Created by James Harquail on 2017-12-04.
//  Copyright © 2017 Ragnar Development. All rights reserved.
//

import Foundation

class LocationTableCellViewModel: RootViewModel {
    
    public let event: Event
    
    init(event: Event) {
        self.event = event
    }
}
