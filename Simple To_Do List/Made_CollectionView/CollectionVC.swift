//
//  CollectionVC.swift
//  Simple To_Do List
//
//  Copyright (c) 2023 oasis444. All right reserved.
//

import UIKit

class CollectionVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var editButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!
    var addButton: UIBarButtonItem!
    var tasks: [Task] = [] {
        didSet { // tasks의 값이 변경된 직후에 호출
            applyItems()
            saveTasks()
        }
    }
    
    let userDefault = UserDefaults.standard
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    typealias Item = Task
    enum Section {
        case main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configBarButtonItems()
        loadTasks()
        configure()
    }
    
    private func configBarButtonItems() {
        editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editAction))
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction))
        navigationItem.rightBarButtonItems = [addButton, editButton]
    }

    private func configure() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionTaskCell", for: indexPath) as? collectionTaskCell else { return nil }
            cell.configure(info: itemIdentifier)
            return cell
        })
        
        collectionView.collectionViewLayout = layout()
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(tasks)
        dataSource.apply(snapshot)
        
        collectionView.delegate = self
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .sidebar)
        listConfiguration.showsSeparators = false
        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        listConfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func applyItems() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(tasks)
        dataSource?.apply(snapshot)
    }
}

extension CollectionVC {
    private func loadTasks() {
        guard let data = userDefault.object(forKey: "tasks") as? [[String: Any]] else { return }
        // compactMap : 1차원 배열에서 nil을 제거하고 옵셔널 바인딩을 하는 경우 사용
        tasks = data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let done = $0["done"] as? Bool else { return nil }
            return Task(title: title, done: done)
        }
    }
    
    private func saveTasks() {
        let data: [[String : Any]] = tasks.map {
            ["title": $0.title, "done": $0.done]
        }
        userDefault.set(data, forKey: "tasks")
    }
    
    @objc func editAction() {
        guard !tasks.isEmpty else { return }
        collectionView.inputViewController?.setEditing(true, animated: true)
        navigationItem.rightBarButtonItems = [addButton, doneButton]
    }
    
    @objc func doneAction() {
        collectionView.inputViewController?.setEditing(false, animated: true)
        navigationItem.rightBarButtonItems = [addButton, editButton]
    }
    
    @objc func addAction() {
        let alert = UIAlertController(title: "할 일 등록", message: nil, preferredStyle: .alert)
        let register = UIAlertAction(title: "등록", style: .default) { [weak self] _ in // 클로저의 프로퍼티에 접근하게 되면 강한 순환 참조가 발생해 메모리 누수 발생 할 수 있음. 따라서 weak, unknown으로 정의해야 한다.
            guard let title = alert.textFields?[0].text else { return } // 현재는 textField가 1개 이므로 첫번째 textField에 입력된 text를 가져온다.
            let task = Task(title: title, done: false)
            self?.tasks.append(task)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(cancel)
        alert.addAction(register)
        alert.addTextField { textField in
            textField.placeholder = "할 일을 입력해주세요."
        }
        self.present(alert, animated: true)
    }
    
    private func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath else { return nil }
        let deleteActionTitle = NSLocalizedString("Delete", comment: "Delete action title")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteActionTitle) { [weak self] _, _, completion in
            self?.tasks.remove(at: indexPath.item)
            self?.applyItems()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension CollectionVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var task = tasks[indexPath.item]
        task.done = !task.done
        tasks[indexPath.item] = task
    }
}
