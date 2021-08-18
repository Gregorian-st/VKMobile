//
//  NewsVKClass.swift
//  VKMobile
//
//  Created by Grigory on 30.11.2020.
//

import UIKit

class NewsVK: Decodable {
    
    private let shortCut = 100
    var sourceId: Int = 0
    var type: String = ""
    var publisherAvatar: String = ""
    var publisherFullName: String = ""
    var date: TimeInterval = 0
    var dateStr: String = ""
    var textFull: String = ""
    var textShort: String = ""
    var likeCount: Int = 0
    var liked: Bool = false
    var images: [String] = []
    var viewCount: Int = 0
    var repostCount: Int = 0
    var commentCount: Int = 0
    var fullTextView: Bool = false
    var desiredTextHeight: CGFloat = 0
    
    enum MainCodingKeys: String, CodingKey {
        case sourceId = "source_id"
        case type
        case date
        case text
        case comments
        case likes
        case reposts
        case views
        case photos
        case attachments
    }
    
    enum CountCodingKeys: String, CodingKey {
        case count
    }
    
    enum LikesCodingKeys: String, CodingKey {
        case liked = "user_likes"
        case likeCount = "count"
    }
    
    enum PhotosCodingKeys: String, CodingKey {
        case count
        case items
    }
    
    enum MainSizesCodingKeys: String, CodingKey {
        case sizes
    }
    
    enum SizesCodingKeys: String, CodingKey {
        case photoName = "url"
        case type
    }
    
    enum AttachmentsCodingKeys: String, CodingKey {
        case type
        case photo
    }
    
    enum NewsType {
        case mix
        case post
        case photo
    }
    
    var postType: NewsType = .mix
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: MainCodingKeys.self)
        
        self.sourceId = try container.decode(Int.self, forKey: .sourceId)
        self.type = try container.decode(String.self, forKey: .type)
        let intPostDate: Int = try container.decode(Int.self, forKey: .date)
        self.date = TimeInterval(intPostDate)
        self.dateStr = intToStrDate(intPostDate)
        
        if type == "post" {
            self.postType = .post
            
            self.textFull = try container.decode(String.self, forKey: .text)
            self.textShort = getShortText(fullText: self.textFull)
            
            let commentsContainer = try container.nestedContainer(keyedBy: CountCodingKeys.self, forKey: .comments)
            self.commentCount = try commentsContainer.decode(Int.self, forKey: .count)
            
            let likesContainer = try container.nestedContainer(keyedBy: LikesCodingKeys.self, forKey: .likes)
            self.likeCount = try likesContainer.decode(Int.self, forKey: .likeCount)
            let intLiked = try likesContainer.decode(Int.self, forKey: .liked)
            self.liked = intLiked == 1
            
            let repostsContainer = try container.nestedContainer(keyedBy: CountCodingKeys.self, forKey: .reposts)
            self.repostCount = try repostsContainer.decode(Int.self, forKey: .count)
            
            do {
                let viewsContainer = try container.nestedContainer(keyedBy: CountCodingKeys.self, forKey: .views)
                self.viewCount = try viewsContainer.decodeIfPresent(Int.self, forKey: .count) ?? 0
            } catch {
                self.viewCount = 0
            }
            
            var count: Int
            do {
                var attachmentsArrayContainer = try container.nestedUnkeyedContainer(forKey: .attachments)
                count = attachmentsArrayContainer.count ?? 0
                if count > 0 {
                    for _ in (0...count-1) {
                        let attachmentContainer = try attachmentsArrayContainer.nestedContainer(keyedBy: AttachmentsCodingKeys.self)
                        let attachmentType = try attachmentContainer.decode(String.self, forKey: .type)
                        if attachmentType == "photo" {
                            do {
                                let attachmentPhotoContainer = try attachmentContainer.nestedContainer(keyedBy: MainSizesCodingKeys.self, forKey: .photo)
                                var sizesArrayContainer = try attachmentPhotoContainer.nestedUnkeyedContainer(forKey: .sizes)
                                let countSizes = sizesArrayContainer.count ?? 0
                                if countSizes > 0 {
                                    for _ in (0...countSizes - 1) {
                                        let sizesContainer = try sizesArrayContainer.nestedContainer(keyedBy: SizesCodingKeys.self)
                                        let type: String = try sizesContainer.decode(String.self, forKey: .type)
                                        if type == "x" {
                                            let imageName = try sizesContainer.decode(String.self, forKey: .photoName)
                                            self.images.append(imageName)
                                            break
                                        }
                                    }
                                }
                            } catch {
                                continue
                            }
                        }
                    }
                }
            } catch {
                count = 0
            }

            return
        }
        
        if type == "wall_photo" {
            self.postType = .photo
            
            let photosContainer = try container.nestedContainer(keyedBy: PhotosCodingKeys.self, forKey: .photos)
            var count = try photosContainer.decode(Int.self, forKey: .count)
            count = VKAPIServiceConst.newsPhotoMax < count ? VKAPIServiceConst.newsPhotoMax : count
            if count > 0 {
                var photosArrayContainer = try photosContainer.nestedUnkeyedContainer(forKey: .items)
                for _ in (0...count-1) {
                    do {
                        let sizesMainContainer = try photosArrayContainer.nestedContainer(keyedBy: MainSizesCodingKeys.self)
                        var sizesArrayContainer = try sizesMainContainer.nestedUnkeyedContainer(forKey: .sizes)
                        let countSizes = sizesArrayContainer.count ?? 0
                        if countSizes > 0 {
                            for _ in (0...countSizes - 1) {
                                let sizesContainer = try sizesArrayContainer.nestedContainer(keyedBy: SizesCodingKeys.self)
                                let type: String = try sizesContainer.decode(String.self, forKey: .type)
                                if type == "x" {
                                    let imageName = try sizesContainer.decode(String.self, forKey: .photoName)
                                    self.images.append(imageName)
                                    break
                                }
                            }
                        }
                    } catch {
                        continue
                    }
                }
            }
            
            return
        }
    }
    
    convenience init(publisherAvatar: String, publisherFullName: String, dateStr: String, textFull: String) {
        self.init()
        self.publisherAvatar = publisherAvatar
        self.publisherFullName = publisherFullName
        self.dateStr = dateStr
        self.textFull = textFull
        self.textShort = getShortText(fullText: self.textFull)
    }
    
    func getShortText(fullText: String) -> String {
        let firstIndex = fullText.startIndex
        let length = fullText.distance(from: firstIndex, to: fullText.endIndex)
        var lastIndex: String.Index
        if length > shortCut {
            lastIndex = fullText.index(firstIndex, offsetBy: shortCut)
            return String(fullText[firstIndex...lastIndex]) + "..."
        } else {
            return fullText
        }
    }
    
    func intToStrDate(_ intDate: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy.MM.dd HH:mm:ss")
        let postDate = Date(timeIntervalSince1970: TimeInterval(intDate))
        return dateFormatter.string(from: postDate)
    }
    
}
