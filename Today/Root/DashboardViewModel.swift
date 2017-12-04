//
//  DashboardViewModel.swift
//  Today
//
//  Created by James Harquail on 2017-12-04.
//  Copyright © 2017 Ragnar Development. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

protocol DashboardViewModelType {
    var tableRows: Observable<[Event]> { get }
    var timeHeaderViewModel: TimeViewModelType { get }
}

class DashboardViewModel: RootViewModel {
    
    fileprivate lazy var timeViewModel: TimeViewModelType = TimeViewModel()
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
    
    fileprivate let events = Variable<[Event]>([])
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        super.init()
        startFetch()
    }
    
    private func startFetch() {
        do {
            try fetchedResultsController.performFetch()
            events.value = fetchedResultsController.sections?.first?.objects as? [Event] ?? []
            print("Ping")
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
}

extension DashboardViewModel: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let event = anObject as? Event else { return }
        switch type {
        case .insert:
            if let row = newIndexPath?.row {
                events.value.insert(event, at: row)
            }
        case .delete:
            // todo
            break
        case .update:
            // tell the tableview to reload only?
            break
        case .move:
            // Noop
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

    }
}

extension DashboardViewModel: DashboardViewModelType {
    
    var tableRows: Observable<[Event]> {
        return events.asObservable()
    }
    
    var timeHeaderViewModel: TimeViewModelType {
        return timeViewModel
    }
}

class SectionDataModel {
    
    private let event: Event
    
    public var rows = Variable<[RowDataModel]>([])
    
    init(event: Event) {
        self.event = event
    }
    
    func update() {
        if event.hasLocationData() {
            
        }
    }
}
