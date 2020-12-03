//
//  ViewController.swift
//  InnofiedAssingment
//
//  Created by krishna gunjal on 02/11/20.
//  Copyright © 2020 krishna gunjal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    
    let viewModel = ViewModel()
    
    var albumData = [Album]()
    var estimateWidth = 160.0
    var cellPaddingSize = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.dataViewModelDelegate = self
        viewModel.getDataList()
        collectionView.register(UINib(nibName: "DataCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: reuseIdentifiers.dataCell)
        registerRefreshControl()
        self.collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupGridView()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func setupGridView() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellPaddingSize)
        flow.minimumLineSpacing = CGFloat(self.cellPaddingSize)
    }
    
    private func registerRefreshControl() {
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: Selector(("refreshStream")), for: .allEvents)
        refreshControl = refresher
        collectionView!.addSubview(refreshControl)
    }
    
    @objc func refreshStream() {
        self.collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
}

extension ViewController: DataViewModelDelegate {
    func dataFetchError(error: DataError) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error!", message: "Something went wrong", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func dataRefreshSuccess() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.albumData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifiers.dataCell, for: indexPath) as! DataCollectionViewCell
        let dataModel = viewModel.albumData[indexPath.row]
        let image = dataModel.thumbnailUrl
        
        cell.title.text = dataModel.title
        
        cell.imageView.loadImage(url: dataModel.thumbnailUrl ?? "", placeholder: UIImage(named: Constants.placeholderImage))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWidth()
        return CGSize(width: width, height: width)
    }
    
    func calculateWidth() -> CGFloat {
        let estimatedWidth = CGFloat(estimateWidth)
        let noOfCells = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellPaddingSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellPaddingSize) * (noOfCells - 1) - margin) / noOfCells
        
        return width
    }
    
}

