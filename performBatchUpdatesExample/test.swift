//
//  ViewController.swift
//  performBatchUpdatesExample
//
//  Created by 松岡 利人 on 2019/09/11.
//  Copyright © 2019 rihitenLab. All rights reserved.
//

import UIKit

struct testSection {
    let title: String?
    let students: [testStudent]
}

struct testStudent {
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

class test: UIViewController {
    
    let students: [testStudent] = [
        testStudent(id: 1, name: "あいうえお", birthday: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, height: 194),
        testStudent(id: 1, name: "かきくけこ", birthday: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, height: 194),
        testStudent(id: 1, name: "さしすせそ", birthday: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, height: 194),
        testStudent(id: 1, name: "たちつてと", birthday: Calendar.current.date(byAdding: .day, value: -91, to: Date())!, height: 194),
        testStudent(id: 2, name: "なにぬねの", birthday: Calendar.current.date(byAdding: .day, value: -91, to: Date())!, height: 194),
        testStudent(id: 2, name: "はひふへほ", birthday: Calendar.current.date(byAdding: .day, value: -151, to: Date())!, height: 194),
        testStudent(id: 2, name: "まみむめも", birthday: Calendar.current.date(byAdding: .day, value: -151, to: Date())!, height: 177),
        testStudent(id: 3, name: "やいゆえよ", birthday: Calendar.current.date(byAdding: .day, value: -151, to: Date())!, height: 169),
        testStudent(id: 3, name: "らりるれろ", birthday: Calendar.current.date(byAdding: .day, value: -151, to: Date())!, height: 169),
        testStudent(id: 3, name: "わいうえを", birthday: Calendar.current.date(byAdding: .day, value: -151, to: Date())!, height: 169),
    ]
    
    enum Order: Int {
        case id
        case birthday
        case height
    }
    
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var order: ViewController.Order = .id
    var sections: [testSection]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        sections = getNewSections()
    }
    
    @IBAction func selectedSegment(_ sender: UISegmentedControl) {
        order = ViewController.Order(rawValue: sender.selectedSegmentIndex) ?? .id
        let newSections = getNewSections()
        
//        UIView.performWithoutAnimation {
//            collectionView.performBatchUpdates({
//                self.collectionView.reloadSections(IndexSet(integersIn: 0..<3))
//            }, completion: nil)
//        }
        
        collectionView.performBatchUpdates({
            for oldSectionIndex in 0..<(sections?.count ?? 1) {
                for oldStudentIndex in 0..<(sections?[oldSectionIndex].students.count ?? 0) {
                    let movedSectionIndex = newSections.firstIndex { $0.title == sections?[oldSectionIndex].students[oldStudentIndex].getTitle(order: order) }
                    let movedItemIndex = newSections[movedSectionIndex ?? 0].students.firstIndex { $0.name == sections?[oldSectionIndex].students[oldStudentIndex].name }
                    let movedIndexPath = IndexPath(item: movedItemIndex ?? 0, section: movedSectionIndex ?? 0)
                    collectionView.moveItem(at: IndexPath(item: oldStudentIndex, section: oldSectionIndex), to: movedIndexPath)
                }
            }
            self.sections = newSections
        }, completion: { success in
            self.collectionView.reloadSections(IndexSet(integersIn: 0..<3))
        })
    }
    
    func getNewSections() -> [testSection] {
        switch order {
        case .id:
            let sections = Dictionary(grouping: students, by: { $0.getTitle(order: order) })
            var newSections = [testSection]()
            
            sections.forEach { section in
                newSections.append(testSection(title: section.key, students: section.value.sorted { $0.id < $1.id }))
            }
            if newSections.count < 3 {
                for _ in 0..<(3 - newSections.count) {
                    newSections.append(testSection(title: nil, students: []))
                }
            }
            return newSections.sorted { $0.title ?? "" > $1.title ?? "" }
        case .birthday:
            let sections = Dictionary(grouping: students, by: { $0.getTitle(order: order) })
            var newSections = [testSection]()
            
            sections.forEach { section in
                newSections.append(testSection(title: section.key, students: section.value.sorted { $0.birthday < $1.birthday }))
            }
            if newSections.count < 3 {
                for _ in 0..<(3 - newSections.count) {
                    newSections.append(testSection(title: nil, students: []))
                }
            }
            return newSections.sorted { $0.title ?? "" > $1.title ?? "" }
        case .height:
            let sections = Dictionary(grouping: students, by: { $0.getTitle(order: order) })
            var newSections = [testSection]()
            
            sections.forEach { section in
                newSections.append(testSection(title: section.key, students: section.value.sorted { $0.height < $1.height }))
            }
            if newSections.count < 3 {
                for _ in 0..<(3 - newSections.count) {
                    newSections.append(testSection(title: nil, students: []))
                }
            }
            return newSections.sorted { $0.title ?? "" > $1.title ?? "" }
        }
    }
}

extension test: UICollectionViewDataSource {
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

extension test: UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
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

extension test: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.bounds.width - 30) / 2
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard order != .id else { return CGSize.zero }
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}
