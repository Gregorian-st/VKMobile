//
//  PhotoChacheService.swift
//  VKMobile
//
//  Created by Grigory on 22.01.2021.
//

import Foundation
import Alamofire

class PhotoCacheService {
    
    private let cacheLifeTime: TimeInterval = 30 * 24 * 60 * 60
    private var placeholderImage: UIImage? = UIImage(systemName: "photo")
    private var images: [String: UIImage] = [:]
    private lazy var fileManager = FileManager.default
    
    private func getCacheFolderURL(directory: String) -> URL? {
        guard
            let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        else { return nil }
        
        var dir: String = directory
        if directory == "" {
            dir = "images"
        }
        let url = cachesDirectory.appendingPathComponent(dir, isDirectory: true)
        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
                return nil
            }
        }
        
        return url
    }
    
    private func getImagePath(url: String, directory: String) -> String? {
        guard
            let folderURL = getCacheFolderURL(directory: directory)
        else { return nil }
        
        let fileName = url.split(separator: "/").last ?? "default"
        return folderURL.appendingPathComponent(String(fileName)).path
    }
    
    private func getImageFromDisk(url: String, directory: String) -> UIImage? {
        guard
            let fileName = getImagePath(url: url, directory: directory),
            let info = try? fileManager.attributesOfItem(atPath: fileName),
            let modificationDate = info[FileAttributeKey.modificationDate] as? Date
        else { return nil }
        
        let lifeTime = Date().timeIntervalSince(modificationDate)
        guard
            lifeTime <= cacheLifeTime,
            let image = UIImage(contentsOfFile: fileName)
        else { return nil }
        
        DispatchQueue.main.async {
            self.images[url] = image
        }
        return image
    }
    
    private func saveImageToDisk(url: String, image: UIImage, directory: String) {
        guard let fileName = getImagePath(url: url, directory: directory),
              let data = image.pngData()
        else { return }
        
        fileManager.createFile(atPath: fileName, contents: data, attributes: nil)
    }
    
    private func loadImageFromNet(at indexPath: IndexPath, byUrl url: URL, directory: String) {
        let cleanPath = getPathFromURL(url)
        
        AF.request(url).responseData(queue: DispatchQueue.global()) { [weak self] response in
            guard
                let data = response.data,
                let image = UIImage(data: data)
            else { return }
            
            DispatchQueue.main.async {
                self?.images[cleanPath] = image
            }
            
            self?.saveImageToDisk(url: cleanPath, image: image, directory: directory)
            
            DispatchQueue.main.async {
                self?.container.reloadRow(at: indexPath)
            }
        }
    }
    
    func getPhoto(at indexPath: IndexPath, byUrl url: URL, cacheSubDir directory: String?) -> UIImage? {
        let dir: String = directory ?? "images"
        let cleanPath = getPathFromURL(url)
        if let image = images[cleanPath] {
            return image
        } else if let image = getImageFromDisk(url: cleanPath, directory: dir) {
            return image
        } else {
            loadImageFromNet(at: indexPath, byUrl: url, directory: dir)
            return placeholderImage
        }
    }
    
    private func getPathFromURL(_ url: URL) -> String {
        return "\(url.scheme ?? "http")://\(url.host ?? "")\(url.path)"
    }
    
    private let container: DataReloadable
    
    init(container: UITableView) {
        self.container = Table(table: container)
    }
    
    init(container: UICollectionView) {
        self.container = Collection(collection: container)
    }
}

fileprivate protocol DataReloadable {
    func reloadRow(at indexPath: IndexPath)
}

extension PhotoCacheService {
    
    private class Table: DataReloadable {
        let table: UITableView
        
        init(table: UITableView) {
            self.table = table
        }
        
        func reloadRow(at indexPath: IndexPath) {
            table.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    private class Collection: DataReloadable {
        let collection: UICollectionView
        
        init(collection: UICollectionView) {
            self.collection = collection
        }
        
        func reloadRow(at indexPath: IndexPath) {
            collection.reloadItems(at: [indexPath])
        }
    }
    
}
