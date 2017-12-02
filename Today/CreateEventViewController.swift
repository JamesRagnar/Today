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
import RxSwift

class CreateEventViewController: UIViewController {
    
    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .save,
                                     target: self,
                                     action: #selector(saveButtonTapped))
        return button
    }()
    
    private lazy var entryView: NewEntryParserView = {
        let entryView = NewEntryParserView()
        entryView.textView.delegate = self
        return entryView
    }()
    
    private let coreDataManager: CoreDataManager
    private lazy var disposeBag = DisposeBag()
    
    private var parsedTitle: String?
    private var parsedDate: Date?
    private var parsedAddress: String?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter
            .default
            .rx
            .notification(NSNotification.Name.UIKeyboardWillChangeFrame)
            .map { notification -> CGFloat in
                (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
            }.subscribe(onNext: { [weak self] (keyboardHeight) in
                guard let this = self else { return }
                var frameSize = this.view.bounds
                frameSize.size.height -= keyboardHeight
                this.entryView.frame = frameSize.insetBy(dx: 10, dy: 10)
            }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    @objc func saveButtonTapped() {    
        guard let newEvent = NSEntityDescription.insertNewObject(forEntityName: "Event",
                                                                 into: coreDataManager.persistentContainer.viewContext) as? Event else  {
            return
        }
        
        newEvent.title = parsedTitle
        newEvent.date = parsedDate
        newEvent.address = parsedAddress
        
        coreDataManager.saveContext()
        
        navigationController?.popViewController(animated: true)
    }
    
    private func updateParsedEventData(from string: String) {
        
        parsedTitle = string
        parsedDate = nil
        parsedAddress = nil
        
        let types: NSTextCheckingResult.CheckingType = [.date, .address]
        let detector = try? NSDataDetector.init(types: types.rawValue)
        let matches = detector?.matches(in: string,
                                        options: .reportProgress,
                                        range: NSRange(location: 0, length: string.count))
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 25)],
                                       range: NSRange(location: 0, length: attributedString.string.count))
        
        for match in matches ?? [] {
            if match.resultType == .date, let matchDate = match.date {
                parsedDate = matchDate
                attributedString.addAttributes([.foregroundColor : UIColor.blue], range: match.range)
            }
            
            if match.resultType == .address, let matchAddress = stringFrom(address: match.components) {
                parsedAddress = matchAddress
                attributedString.addAttributes([.foregroundColor: UIColor.green], range: match.range)
            }
        }
        
        entryView.textView.attributedText = attributedString
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
