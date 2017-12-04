//
//  Event+Today.swift
//  Today
//
//  Created by James Harquail on 2017-12-04.
//  Copyright © 2017 Ragnar Development. All rights reserved.
//

import Foundation

extension Event {
    
    func hasLocationData() -> Bool {
        return latitude != 0 && longitude != 0
    }
}
