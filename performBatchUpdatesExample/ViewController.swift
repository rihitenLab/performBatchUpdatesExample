//
//  ViewController.swift
//  performBatchUpdatesExample
//
//  Created by 松岡 利人 on 2019/09/11.
//  Copyright © 2019 rihitenLab. All rights reserved.
//

import UIKit

class StudentCollectionViewHeader: UICollectionReusableView {
    @IBOutlet private weak var titleLabel: UILabel!
    
    var title: String? {
        didSet {
            titleLabel.text = self.title ?? ""
        }
    }
}

class StudentCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var birthdayLabel: UILabel!
    @IBOutlet private weak var heightLabel: UILabel!
    
    var id: Int? {
        didSet {
            idLabel.text = self.id?.description ?? ""
        }
    }
    
    var name :String? {
        didSet {
            nameLabel.text = self.name ?? ""
        }
    }
    
    var birthday: Date? {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = ""
            birthdayLabel.text = dateFormatter.string(from: self.birthday ?? Date())
        }
    }
    
    var height: Int? {
        didSet {
            heightLabel.text = self.height?.description ?? ""
        }
    }
}

struct Section {
    let title: String?
    let students: [Student]
}

struct Student {
    let id: Int
    let name: String
    let birthday: Date
    let height: Int
    
    func getTitle(order: ViewController.Order) -> String {
        switch order {
        case .id:
            return ""
        case .birthday:
            return birthday.startOfMonth.toString(format: "yyyy/MM")
        case .height:
            return (height / 10 * 10).description
        }
    }
}

class ViewController: UIViewController {
    
    let students: [Student] = [
        Student(id: 1, name: "あいうえお", birthday: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, height: 194),
        Student(id: 2, name: "かきくけこ", birthday: Calendar.current.date(byAdding: .day, value: -31, to: Date())!, height: 156),
        Student(id: 3, name: "さしすせそ", birthday: Calendar.current.date(byAdding: .day, value: -61, to: Date())!, height: 172),
        Student(id: 4, name: "たちつてと", birthday: Calendar.current.date(byAdding: .day, value: -91, to: Date())!, height: 163),
        Student(id: 5, name: "なにぬねの", birthday: Calendar.current.date(byAdding: .day, value: -121, to: Date())!, height: 189),
        Student(id: 6, name: "はひふへほ", birthday: Calendar.current.date(byAdding: .day, value: -151, to: Date())!, height: 181),
        Student(id: 7, name: "まみむめも", birthday: Calendar.current.date(byAdding: .day, value: -181, to: Date())!, height: 177),
        Student(id: 8, name: "やいゆえよ", birthday: Calendar.current.date(byAdding: .day, value: -211, to: Date())!, height: 169),
        Student(id: 9, name: "らりるれろ", birthday: Calendar.current.date(byAdding: .day, value: -241, to: Date())!, height: 154),
        Student(id: 10, name: "わいうえを", birthday: Calendar.current.date(byAdding: .day, value: -271, to: Date())!, height: 149),
    ]
    
    enum Order: Int {
        case id
        case birthday
        case height
    }
    
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var order: Order = .id
    var sections: [Section]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        sections = getNewSections()
    }
    
    @IBAction func selectedSegment(_ sender: UISegmentedControl) {
        order = Order(rawValue: sender.selectedSegmentIndex) ?? .id
        let newSections = getNewSections()
        
        collectionView.performBatchUpdates({
            if newSections.count - (sections?.count ?? 0) > 0 {
                collectionView.insertSections(IndexSet(integersIn: (sections?.count ?? 0)..<newSections.count))
            }
            
            for oldSectionIndex in 0..<(sections?.count ?? 1) {
                for oldStudentIndex in 0..<(sections?[oldSectionIndex].students.count ?? 0) {
                    let movedSectionIndex = newSections.firstIndex { $0.title == sections?[oldSectionIndex].students[oldStudentIndex].getTitle(order: order) }
                    let movedItemIndex = newSections[movedSectionIndex ?? 0].students.firstIndex { $0.id == sections?[oldSectionIndex].students[oldStudentIndex].id }
                    let movedIndexPath = IndexPath(item: movedItemIndex ?? 0, section: movedSectionIndex ?? 0)
                    collectionView.moveItem(at: IndexPath(item: oldStudentIndex, section: oldSectionIndex), to: movedIndexPath)
                }
            }
            
            if (sections?.count ?? 0) - newSections.count > 0 {
                collectionView.deleteSections(IndexSet(integersIn: newSections.count..<(sections?.count ?? 0)))
            }
            self.sections = newSections
        }, completion: nil)
    }
    
    func getNewSections() -> [Section] {
        switch order {
        case .id:
            return [Section(title: nil, students: students.sorted{ $0.id < $1.id })]
        case .birthday:
            let sections = Dictionary(grouping: students, by: { $0.getTitle(order: order) })
            var newSections = [Section]()
            
            sections.forEach { section in
                newSections.append(Section(title: section.key, students: section.value.sorted { $0.birthday < $1.birthday }))
            }
            return newSections.sorted { $0.title ?? "" > $1.title ?? "" }
        case .height:
            let sections = Dictionary(grouping: students, by: { $0.getTitle(order: order) })
            var newSections = [Section]()
            
            sections.forEach { section in
                newSections.append(Section(title: section.key, students: section.value.sorted { $0.height < $1.height }))
            }
            return newSections.sorted { $0.title ?? "" > $1.title ?? "" }
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections?[section].students.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "student", for: indexPath) as! StudentCollectionViewCell
        let student = sections?[indexPath.section].students[indexPath.item]
        cell.id = student?.id
        cell.name = student?.name
        cell.birthday = student?.birthday
        cell.height = student?.height
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                           withReuseIdentifier: "header", for: indexPath) as? StudentCollectionViewHeader else {
            fatalError("Could not find proper header")
        }
        
        if kind == UICollectionView.elementKindSectionHeader {
            header.title = sections?[indexPath.section].title ?? ""
            return header
        }
        
        return UICollectionReusableView()
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.bounds.width - 30) / 2
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let _ = sections?.first?.title else { return CGSize.zero }
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}
