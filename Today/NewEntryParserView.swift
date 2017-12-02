//
//  NewEntryParserView.swift
//  Today
//
//  Created by James Harquail on 2017-11-30.
//  Copyright © 2017 Ragnar Development. All rights reserved.
//

import Foundation
import UIKit

class NewEntryParserView: UIView {
    
    public lazy var textView: UITextView = {
        let textView = UITextView()
        return textView
    }()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        addSubview(textView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textView.frame = bounds
    }
}
