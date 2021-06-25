//
//  ViewController.swift
//  SimpleDownloadTasks
//
//  Created by user200328 on 6/23/21.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var startButton: UIBarButtonItem!
    
    // MARK: - Variables
    var downloadTasks = [DownloadTask]() {
        didSet {
            print("we are here to reload data")
            downloadsTableView.reloadData()
        }
    }
    var completedTasks = [DownloadTask]() {
        didSet {
            completedTableView.reloadData()
        }
    }
    
    var option: SimulationOption!
    
    // MARK: - IBOutlets
    @IBOutlet weak var downloadsTableView: UITableView!
    @IBOutlet weak var completedTableView: UITableView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        option = SimulationOption(jobCount: 10, maxAsyncTasks: 2, isRandomizedTime: true)
        configTableViews()
    }
    
    // MARK: - Task Starter
    @IBAction func startTasks(_ sender: UIButton) {
        
        startButton.isEnabled = false
        downloadTasks = []
        completedTasks = []
        
    // მოახდინეთ DispatchQueue, DispatchGroup და DispatchSemaphore-ის ინიციალიზაცია
        let dispatchQueue = DispatchQueue(label: "dispatch", attributes: .concurrent)
        let dispatchGroup = DispatchGroup()
        let semaphore = DispatchSemaphore(value: 1)
        
    // შეავსეთ  მასივ(ებ)ი ტასკების სტატუსების მიხედვით
        //var tempArray: [DownloadTask] = []
        for a in 0..<option.jobCount {
            let task = DownloadTask(identifier: "\(a)") { [weak self] task2 in
                guard let self = self else { return }
                switch task2.state {
                case .inProgess:
                    DispatchQueue.main.async {
                        self.downloadsTableView.reloadData()
                    }
                case .pending:
                    DispatchQueue.main.async {
                        self.downloadsTableView.reloadData()
                    }
                case .completed:
                    DispatchQueue.main.async {
                        self.downloadTasks.remove(at: self.downloadTasks.indexOfTaskWith(identifier: task2.identifier)!)
                        self.completedTasks.append(task2)
                        self.downloadsTableView.reloadData()
                        self.completedTableView.reloadData()
                    }
                }
            }
            downloadTasks.append(task)
        }
        //downloadTasks = tempArray

    // დაიწყეთ ჩამოტვირთვა ტასკების
        //print(downloadTasks)
        print(downloadTasks.map { $0.state })
        for a in downloadTasks {
            a.startTask(queue: dispatchQueue,
                        group: dispatchGroup,
                        semaphore: semaphore,
                        randomizeTime: option.isRandomizedTime)
        }
        
    // აქ აჩვენეთ ალერტი, რომ ყველა ტასკი დასრულებულია
        dispatchGroup.notify(queue: dispatchQueue) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.presentAlertWith(title: "Info", message: "Tasks Completed")
                self.startButton.isEnabled = true
            }
        }
    }
    
    private func presentAlertWith(title: String , message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true)
    }
    
    func configTableViews() {
        downloadsTableView.dataSource = self
        downloadsTableView.delegate = self
        
        completedTableView.dataSource = self
        completedTableView.delegate = self

        let nib = UINib(nibName: "ProgressCell", bundle: nil)
        downloadsTableView.register(nib, forCellReuseIdentifier: "ProgressCell")
        completedTableView.register(nib, forCellReuseIdentifier: "ProgressCell")
    
    }
}

// MARK: - UITableView Data Source

// იმპლემენტაცია ამ დელეგატის
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            //print("here1")
            return downloadTasks.count
        case 1:
            //print("here2")
            return completedTasks.count
        default:
            //print("here 0")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.deque(ProgressCell.self, for: indexPath)
        
        switch tableView.tag {
        case 0:
            //print("here1")
            let item = downloadTasks[indexPath.row]
            print(item.identifier)
            print(item.state)
            cell.item = item
            return cell
        case 1:
            cell.configure(with: completedTasks[indexPath.row])
            return cell
        default:
            return UITableViewCell()
        }
    }
}
