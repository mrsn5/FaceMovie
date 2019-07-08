//
//  ViewController.swift
//  FaceMovie
//
//  Created by San Byn Nguyen on 6/22/19.
//  Copyright © 2019 San Byn Nguyen. All rights reserved.
//

import UIKit
import CoreData

class MyCollectionVC: UIViewController {

    var masks: [NSManagedObject] = []
    
    @IBOutlet weak var masksCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        masksCollectionView.delegate = self
        masksCollectionView.dataSource = self
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Mask")
        do {
            masks = try managedContext.fetch(fetchRequest)
            masksCollectionView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        masksCollectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ARCameraVC, let id = sender as? String {
            controller.id = id
        }
        
        if let controller = segue.destination as? QRScanVC {
            controller.masks = masks
            controller.collection = self
            print("QRSCAN")
        }
    }

    @IBAction func addPressed(_ sender: Any) {
        performSegue(withIdentifier: "QRScan", sender: nil)
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Mask")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedContext.execute(batchDeleteRequest)
            masks.removeAll()
        } catch {
            // Error Handling
        }
        
        masksCollectionView.reloadData()
    }
}

extension MyCollectionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return masks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaskCell", for: indexPath) as? MaskCell {
            
            let id = masks[indexPath.row].value(forKeyPath: "id") as! String
            cell.configure(id: id)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width * 0.3 , height: view.frame.size.width * 0.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = masks[indexPath.row].value(forKeyPath: "id")
        performSegue(withIdentifier: "ARCameraVC", sender: id)
    }
}

