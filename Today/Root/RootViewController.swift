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
    
    private lazy var timeHeaderView: TimeHeaderView = {
        let view = TimeHeaderView()
        view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 150)
        view.autoresizingMask = [.flexibleWidth]
        view.inject(model: viewModel.timeHeaderViewModel)
        return view
    }()
    
    private lazy var addEventButton: UIButton = {
        let button = UIButton()
        button.frame.size = CGSize(width: 200, height: 50)
        button.center.x = view.center.x
        button.frame.origin.y = view.frame.height - 70 - self.view.safeAreaInsets.bottom
        button.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        button.setTitle("+ Add Event", for: .normal)
        button.backgroundColor = UIColor(red: 119.0 / 255.0, green: 158.0 / 255.0, blue: 203.0 / 255.0, alpha: 1)
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let viewModel: DashboardViewModelType
    
    init(viewModel: DashboardViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(tableView)
        view.addSubview(addEventButton)
        
        tableView.tableHeaderView = timeHeaderView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerTableViews()
        
//        addEventButton
//            .rx
//            .tap
//            .subscribe(onNext: { [weak self] _ in
//                guard let coreDataManager = self?.coreDataManager else { return }
//                self?.navigationController?.pushViewController(CreateEventViewController(coreDataManager: coreDataManager), animated: true)
//            }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    private func registerTableViews() {
        tableView.register(EventTableViewCell.self, forCellReuseIdentifier: EventTableViewCell.reuseIdentifier)
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.reuseIdentifier)
        tableView.register(ErrorTableViewCell.self, forCellReuseIdentifier: ErrorTableViewCell.reuseIdentifier)
    }
}

extension RootViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return ErrorTableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return EventTableViewCell.desiredHeight()
    }
}
