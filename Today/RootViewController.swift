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

class RootViewController: UIViewController {
    
    private lazy var timeViewModel: TimeViewModelType = TimeViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .gray
        return tableView
    }()
    
    private lazy var timeHeaderView: TimeHeaderView = TimeHeaderView()
    
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
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Event> = {
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.coreDataManager.persistentContainer.viewContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(tableView)
        view.addSubview(addEventButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerTableViews()
        
        addEventButton
            .rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                guard let coreDataManager = self?.coreDataManager else { return }
                self?.navigationController?.pushViewController(CreateEventViewController(coreDataManager: coreDataManager), animated: true)
            }).disposed(by: disposeBag)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    private func registerTableViews() {
        tableView.register(TimeHeaderView.self, forHeaderFooterViewReuseIdentifier: TimeHeaderView.reuseIdentifier)
        
        tableView.register(EventTableViewCell.self, forCellReuseIdentifier: EventTableViewCell.reuseIdentifier)
        tableView.register(ErrorTableViewCell.self, forCellReuseIdentifier: ErrorTableViewCell.reuseIdentifier)
    }
}

extension RootViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let sections = fetchedResultsController.sections,
            let events = sections.first?.objects as? [Event],
            let cell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.reuseIdentifier) as? EventTableViewCell else {
                return ErrorTableViewCell()
        }
        
        let event = events[indexPath.row]
        cell.loadData(from: event)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TimeHeaderView.reuseIdentifier) as? TimeHeaderView
        header?.inject(model: timeViewModel)
        return header
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard
            let sections = fetchedResultsController.sections,
            sections.count > 0,
            let events = sections.first else {
                return 0
        }
        
        return events.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard
            let sections = fetchedResultsController.sections,
            let events = sections.first?.objects as? [Event] else {
                return 40
        }
        let event = events[indexPath.row]
        return EventTableViewCell.desiredHeight(for: event)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 90
    }
}

extension RootViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        case .move:
            if let oldIndex = indexPath, let newIndex = newIndexPath {
                tableView.moveRow(at: oldIndex, to: newIndex)
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
