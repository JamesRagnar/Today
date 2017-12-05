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
    var tableSections: Observable<[SectionDataModel]> { get }
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
    
    fileprivate let sectionData = Variable<[SectionDataModel]>([])
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        super.init()
        startFetch()
    }
    
    private func startFetch() {
        do {
            try fetchedResultsController.performFetch()
            parseResults()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    private func parseResults() {
        guard let events = fetchedResultsController.sections?.first?.objects as? [Event] else { return }
        var sectionDataModels = [SectionDataModel]()
        for event in events {
            let newSection = SectionDataModel(event: event)
            sectionDataModels.append(newSection)
        }
        sectionData.value = sectionDataModels
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
                let newSection = SectionDataModel(event: event)
                sectionData.value.insert(newSection, at: row)
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
    
    var tableSections: Observable<[SectionDataModel]> {
        return sectionData.asObservable()
    }
    
    var timeHeaderViewModel: TimeViewModelType {
        return timeViewModel
    }
}

class SectionDataModel {
    
    public let event: Event
    
    public let rowDataModels: [RootViewModel]
    
    init(event: Event) {
        self.event = event
        
        var dataModels: [RootViewModel] = [EventTableCellViewModel(event: event)]
        if event.hasLocationData() {
            dataModels.append(LocationTableCellViewModel(event: event))
        }
        rowDataModels = dataModels
    }
}
