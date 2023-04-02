//
//  TableVC.swift
//  Simple To_Do List
//
//  Copyright (c) 2023 oasis444. All right reserved.
//

import UIKit

class TableVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var editButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!
    var addButton: UIBarButtonItem!
    var tasks: [Task] = [] {
        didSet { // tasks의 값이 변경된 직후에 호출
            self.saveTasks()
        }
    }
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configBarButtonItems()
        configure()
        loadTasks()
    }
    
    private func configBarButtonItems() {
        editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editAction))
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction))
        navigationItem.rightBarButtonItems = [addButton, editButton]
    }
    
    private func configure() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func saveTasks() {
        let data: [[String: Any]] = tasks.map {
            ["title": $0.title, "done": $0.done]
        }
        userDefault.set(data, forKey: "tasks")
    }
    
    private func loadTasks() {
        guard let data = userDefault.object(forKey: "tasks") as? [[String: Any]] else { return }
        tasks = data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let done = $0["done"] as? Bool else { return nil }
            return Task(title: title, done: done)
        }
    }
    
    @objc func editAction() {
        guard !tasks.isEmpty else { return }
        navigationItem.rightBarButtonItems = [addButton, doneButton]
        tableView.setEditing(true, animated: true) // 편집모드
    }
    
    @objc func doneAction() {
        navigationItem.rightBarButtonItems = [addButton, editButton]
        tableView.setEditing(false, animated: true)
    }
    
    @objc func addAction() {
        let alert = UIAlertController(title: "할 일 등록", message: nil, preferredStyle: .alert)
        let register = UIAlertAction(title: "등록", style: .default) { [weak self] _ in // 클로저의 프로퍼티에 접근하게 되면 강한 순환 참조가 발생해 메모리 누수 발생 할 수 있음. 따라서 weak, unknown으로 정의해야 한다.
            guard let title = alert.textFields?[0].text else { return } // 현재는 textField가 1개 이므로 첫번째 textField에 입력된 text를 가져온다.
            let task = Task(title: title, done: false)
            self?.tasks.append(task)
            self?.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(cancel)
        alert.addAction(register)
        alert.addTextField { textField in
            textField.placeholder = "할 일을 입력해주세요."
        }
        self.present(alert, animated: true)
    }
}

extension TableVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        let task = tasks[indexPath.item]
        cell.textLabel?.text = task.title
        if task.done {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    // 편집 모드에서 삭제 버튼을 눌렀을 때 어떤 셀인지 알려주는 메서드
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // case 1
        tasks.remove(at: indexPath.item)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        if tasks.isEmpty {
            doneAction()
        }
        
        // case 2
//        if editingStyle == .delete {
//            tasks.remove(at: indexPath.item)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//            if tasks.isEmpty {
//                doneAction()
//            }
//        }
    }
    
    // 행이 다른 위치로 이동하면 이동 전, 후 위치를 알려주는 메서드
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let task = tasks[sourceIndexPath.item]
        tasks.remove(at: sourceIndexPath.item)
        tasks.insert(task, at: destinationIndexPath.item)
    }
}

extension TableVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = tasks[indexPath.item]
        task.done = !task.done
        tasks[indexPath.item] = task
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
