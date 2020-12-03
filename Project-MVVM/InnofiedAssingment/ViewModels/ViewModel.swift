//
//  ViewModel.swift
//  InnofiedAssingment
//
//  Created by krishna gunjal on 03/11/20.
//  Copyright © 2020 krishna gunjal. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol DataViewModelDelegate {
    func dataRefreshSuccess()
    func dataFetchError(error: DataError)
}

class ViewModel: NSObject {
    let persistentContainer = NSPersistentContainer(name: "InnofiedModel")
    let context = ((UIApplication.shared.delegate) as!  AppDelegate).persistentContainer.viewContext
    private var apiServices: APIService!
    var dataViewModelDelegate: DataViewModelDelegate?
    var albumData = [Album]()
    
    private var persistantDataList = [Album]() {
        didSet {
            setData()
        }
    }
    
    fileprivate func setData() {
        self.albumData = persistantDataList
        self.dataViewModelDelegate?.dataRefreshSuccess()
    }
    
    public func getDataList() -> Void {
       APIService().getData { (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                self.dataViewModelDelegate?.dataFetchError(error: error)
                
            case .success(let dataList):
                self.persistantDataList = dataList
                try? self.saveData(data: dataList)
                self.dataViewModelDelegate?.dataRefreshSuccess()
            }
        }
    }
    
    private func saveData(data: [Album]) throws {
        let album = AlbumDatabase(context: self.context)
        for item in data {
            album.albumTitle = item.title
            album.albumThumbnail = item.thumbnailUrl
            album.albumId = item.albumId!
            album.id = item.id!
            album.imageUrl = item.url
            
            self.context.insert(album)
            try self.context.save()
        }
    }
    
}


