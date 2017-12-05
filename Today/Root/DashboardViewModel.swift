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
    var tableLock: Observable<Bool> { get }
    var reloadSection: Observable<Int?> { get }
}

class DashboardViewModel: RootViewModel {
    
    fileprivate lazy var timeViewModel: TimeViewModelType = TimeViewModel()
    public let coreDataManager: CoreDataManager
    
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
    fileprivate var updateLock = Variable<Bool>(false)
    fileprivate var reloadSectionSubject = BehaviorSubject<Int?>(value: nil)
    
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
        updateLock.value = true
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
            if let row = newIndexPath?.row {
                let sectionModel = sectionData.value[row]
                sectionModel.updateData()
                reloadSectionSubject.on(.next(row))
            }
            break
        case .move:
            // Noop
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateLock.value = false
    }
}

extension DashboardViewModel: DashboardViewModelType {
    
    var tableSections: Observable<[SectionDataModel]> {
        return sectionData.asObservable()
    }
    
    var timeHeaderViewModel: TimeViewModelType {
        return timeViewModel
    }
    
    var tableLock: Observable<Bool> {
        return updateLock.asObservable()
    }
    
    var reloadSection: Observable<Int?> {
        return reloadSectionSubject.asObservable()
    }
}

class SectionDataModel {
    
    public let event: Event
    
    public var rowDataModels = [RootViewModel]()
    
    private lazy var eventViewModel = EventTableCellViewModel(event: event)
    private lazy var locationViewModel = LocationTableCellViewModel(event: event)
    
    init(event: Event) {
        self.event = event
        updateData()
    }
    
    func updateData() {
        var dataModels: [RootViewModel] = [eventViewModel]
        if event.hasLocationData() {
            dataModels.append(locationViewModel)
        }
        rowDataModels = dataModels
    }
}
