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
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        super.init()
    }
    
    func startFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
}

extension DashboardViewModel: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        switch type {
//        case .insert:
//            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
//        case .delete:
//            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
//        case .move:
//            break
//        case .update:
//            break
//        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            if let indexPath = newIndexPath {
//                tableView.insertRows(at: [indexPath], with: .fade)
//            }
//        case .delete:
//            if let indexPath = indexPath {
//                tableView.deleteRows(at: [indexPath], with: .fade)
//            }
//        case .update:
//            if let indexPath = indexPath {
//                tableView.reloadRows(at: [indexPath], with: .fade)
//            }
//        case .move:
//            if let oldIndex = indexPath, let newIndex = newIndexPath {
//                tableView.moveRow(at: oldIndex, to: newIndex)
//            }
//        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
    }
}

extension DashboardViewModel: DashboardViewModelType {
    
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
