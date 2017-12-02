//
//  RootViewController.swift
//  Today
//
//  Created by James Harquail on 2017-11-22.
//  Copyright © 2017 Ragnar Development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreData

class RootViewController: UICollectionViewController {

    private lazy var timeViewModel: TimeViewModelType = TimeViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var addEventButton: UIButton = {
        let button = UIButton()
        button.frame.size = CGSize(width: 200, height: 50)
        button.center.x = view.center.x
        button.frame.origin.y = view.frame.height - 70
        button.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        button.setTitle("+ Add Event", for: .normal)
        button.backgroundColor = UIColor(red: 119.0 / 255.0, green: 158.0 / 255.0, blue: 203.0 / 255.0, alpha: 1)
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let coreDataManager: CoreDataManager

    private var events = [Event]()
        
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        collectionView?.backgroundColor = .gray
        
        view.addSubview(addEventButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCollectionViewCells()
        
        addEventButton
            .rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                guard let coreDataManager = self?.coreDataManager else { return }
                self?.navigationController?.pushViewController(CreateEventViewController(coreDataManager: coreDataManager), animated: true)
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        
        let viewContext = coreDataManager.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        
        events = []
        do {
            events = try viewContext.fetch(request) as? [Event] ?? []
        } catch {
            print("Failed")
        }
        
        collectionView?.reloadData()
    }

    private func registerCollectionViewCells() {
        collectionView?.register(TimeCollectionViewCell.self, forCellWithReuseIdentifier: TimeCollectionViewCell.reuseIdentifier)
        collectionView?.register(EventCollectionViewCell.self, forCellWithReuseIdentifier: EventCollectionViewCell.reuseIdentifier)
    }
    
//    MARK: UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeCollectionViewCell.reuseIdentifier, for: indexPath) as! TimeCollectionViewCell
            cell.inject(model: timeViewModel)
            return cell
        }
        
        let event = events[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCollectionViewCell.reuseIdentifier, for: indexPath) as! EventCollectionViewCell
        cell.loadData(from: event)
        
        return cell
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return events.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return .zero
        } else {
            return UIEdgeInsets(top: 20, left: 0, bottom: 90, right: 0)
        }
    }
}

extension RootViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: view.bounds.width, height: 150)
        } else {
            let event = events[indexPath.row]
            return CGSize(width: view.bounds.width - 20, height: EventCollectionViewCell.desiredHeight(for: event))
        }
    }
}
