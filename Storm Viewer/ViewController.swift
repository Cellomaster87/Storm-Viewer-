//
//  ViewController.swift
//  Storm Viewer
//
//  Created by Michele Galvagno on 16/02/2019.
//  Copyright © 2019 Michele Galvagno. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var pictures = [String]()
    var pictDict = [String: Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(suggest))
        
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: "pictDict") as? Data,
            let savedPictures = defaults.object(forKey: "pictures") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                pictDict = try jsonDecoder.decode([String: Int].self, from: savedData)
                pictures = try jsonDecoder.decode([String].self, from: savedPictures)
            } catch {
                print("Failed to load saved data")
            }
        } else {
            performSelector(inBackground: #selector(loadPictures), with: nil)
        }
        
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    // How many rows should appear in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    // What each row should look like
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        let picture = pictures[indexPath.row]
        cell.textLabel?.text = picture
        cell.detailTextLabel?.text = "Viewed \(pictDict[picture]!) times."
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = pictures[indexPath.row]
            vc.title = "Picture \(indexPath.row + 1) of \(pictures.count)"
            navigationController?.pushViewController(vc, animated: true)
        }
        
        let picture = pictures[indexPath.row]
        pictDict[picture]! += 1
        save()
        tableView.reloadData()
    }
    
    @objc func loadPictures() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                pictures.append(item)
                pictDict[item] = 0
            }
        }
        pictures.sort()
    }
    
    @objc func suggest() {
        let shareLink = "Try it: https://github.com/Cellomaster87/Storm-Viewer-"
        
        let vc = UIActivityViewController(activityItems: [shareLink], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(pictDict),
            let savedPictures = try? jsonEncoder.encode(pictures) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "pictDict")
            defaults.set(savedPictures, forKey: "pictures")
        } else {
            print("Failed to save data.")
        }
    }
}

