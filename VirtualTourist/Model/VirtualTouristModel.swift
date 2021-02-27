//
//  VirtualTouristModel.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 14/02/21.
//

import Foundation
import Combine
import OAuthSwift
import UIKit
import CryptoKit
import CoreData
import SwiftUI

// MARK: - VirtualTouristModel
class VirtualTouristModel: ObservableObject {
    // MARK: - Public Properties
    @Published var travelLocationModel = TravelLocationsModel()
    @Published var isAuthenticated = false
    @Published var isLoggingIn = false

    // MARK: - Private properties
    private var oauthswift: OAuthSwift?
    private var credentials: FlickrOAuth?
    private var flickrApi: FlickrApi?
    private static var credentialsFile = FileManager.documentsDirectory.appendingPathComponent("authentication.json")

    private var getPhotosCancellable: AnyCancellable?

    // MARK: - Public Methods
    init() {

        loadSecrets()

        if !FileManager.default.fileExists(atPath: Self.credentialsFile.path) {
            defaultLog.notice("Credentials file does not exist yet. User need to log in.")
            return
        }

        do {
            let credentials = try FileManager.read(Self.credentialsFile) as FlickrOAuth
            self.credentials = credentials
            self.isAuthenticated = true
            defaultLog.notice("Authenticated from file with username \(self.credentials!.username, privacy: .private(mask: .hash))")
        } catch {
            defaultLog.error("\(error.localizedDescription)")
        }
    }


}

// MARK: - Flickr Authentication
extension VirtualTouristModel {

    /// Initialize Flickr OAuth Process
    public func login() {
        guard let flickrApi = flickrApi else {
            defaultLog.error("FlickrApi is null; can't proceed with login")
            fatalError()
        }
        doOAuthFlickr(flickrApi)
    }

    /// Deletes authentication files, returning user to the login screen
    public func logout() {
        // Some APIs have an endpoint to invalidate the credential on the server; however, flickr does not seem to have one, so we just delete the credentials locally for logout
        isAuthenticated = false
        do {
            defaultLog.notice("Logging out user \(self.credentials!.username, privacy: .private(mask: .hash))")
            try FileManager().removeItem(at: Self.credentialsFile)

        } catch {
            defaultLog.error("\(error.localizedDescription)")
        }
    }

    // MARK: - Private Methods
    private func loadSecrets() {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "json") else {
            fatalError("Secrets.json couldn't be found.")
        }
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let appSecrets = try? decoder.decode(AppSecrets.self, from: data) else {
            fatalError("Could not decode secrets file")
        }

        self.flickrApi = appSecrets.flickrApi

    }
    private func doOAuthFlickr(_ flickrApi: FlickrApi) {
        isLoggingIn = true

        let oauthswift = OAuth1Swift(
            consumerKey:    flickrApi.key,
            consumerSecret: flickrApi.secret,
            requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
            authorizeUrl:    "https://www.flickr.com/services/oauth/authorize",
            accessTokenUrl:  "https://www.flickr.com/services/oauth/access_token"
        )
        self.oauthswift = oauthswift
        oauthswift.authorizeURLHandler = OAuthSwiftOpenURLExternally.sharedInstance
        let _ = oauthswift.authorize(withCallbackURL: URL(string: "virtualtourist:///authenticate")!) { [self] result in
            self.isLoggingIn = false
            switch result {
            case .success(let (credential,_, parameters)):
                save(flickrOauth: credential, parameters: parameters)
                self.isAuthenticated = true
                defaultLog.info("Authenticated with username \(self.credentials!.username, privacy: .private(mask: .hash))")
            case .failure(let error):
                defaultLog.error("\(error.localizedDescription)")
            }
        }
    }

    private func save(flickrOauth: OAuthSwiftCredential, parameters: [String: Any]) {
        let credentials = FlickrOAuth(
            id: (parameters["user_nsid"] as! String).removingPercentEncoding!,
            username: parameters["username"] as! String,
            fullName: (parameters["fullname"] as! String).removingPercentEncoding!,
            token: flickrOauth.oauthToken,
            tokenSecret: flickrOauth.oauthTokenSecret
        )
        do {
            try FileManager.save(credentials, to: Self.credentialsFile)
            self.credentials = credentials
        } catch {
            defaultLog.error("\(error.localizedDescription)")
            fatalError(error.localizedDescription)
        }
    }

}


// MARK: - Photos
extension VirtualTouristModel {
    // TODO write docs saying onPhotoCompletion may be called multiple times
    func getPhotos(for location: TravelLocation, onPhotoCompletion: @escaping ([UIImage]) -> Void) {
        guard let pin = travelLocationModel.fetchedResultsController.fetchedObjects!.first(where: { $0.id == location.id }) else {
            defaultLog.debug("No pin available in store for given location: \(location)")
            onPhotoCompletion([])
            return
        }
        let pinId = pin.objectID
        // TODO fetch photos from core data; background thread
        Persistency.backgroundContext.perform {
            let ctx = Persistency.backgroundContext!
            let pin = ctx.object(with: pinId) as! Pin
            let photos = pin.photos!

            if photos.count == 0 {
                self.downloadPhotos(for: location, onPhotoCompletion: onPhotoCompletion)
            } else {
                let images =
                    photos
                        .map { $0 as! Photo }
                        .sorted(by: {
                            $0.id > $1.id
                        })
                        .map { (photo: Photo) -> UIImage in
                            let image = UIImage(data: photo.image!)
                            return image!
                        }
                DispatchQueue.main.async {
                    onPhotoCompletion(images)
                }
                defaultLog.debug("Total images for \(location): \(images.count)")
            }
        }
    }

    /// Deletes previously saved photos from store and downloads new ones
    func downloadPhotos(for location: TravelLocation, onPhotoCompletion: @escaping ([UIImage]) -> Void, onError: ((Error) -> Void)? = nil) {

        guard let flickrApi = flickrApi,
              let credentials = credentials
        else {
            defaultLog.warning("Skipping photo request; missing credentials")
            onPhotoCompletion([])
            return
        }

        let pin = travelLocationModel.fetchedResultsController.fetchedObjects!.first { $0.id == location.id }!
        let pinId = pin.objectID
        pin.lastPage += 1
        Persistency.saveContext()

        // Delete previous photos
        Persistency.backgroundContext.perform {
            let ctx = Persistency.backgroundContext!
            let pin = ctx.object(with: pinId) as! Pin
            let photos = pin.photos!
            for photo in photos {
                ctx.delete(photo as! Photo)
            }
            do {
                try ctx.save()
            } catch {
                defaultLog.error("\(error as NSObject)")
            }
        }

        let request = Flickr.Requests.PhotoSearch(location: location, accuracy: nil, page: Int(pin.lastPage))
            .urlRequest(flickrApi: flickrApi, credentials: credentials)

        getPhotosCancellable = URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: Flickr.PhotosResponse.self, decoder: JSONDecoder())
            .flatMap { $0.photos.photos.publisher }
            .flatMap { (photo:Flickr.Photo) in
                URLSession
                    .shared
                    .dataTaskPublisher(for: photo.url)
                        .mapError { error -> URLError in
                            return URLError(URLError.Code(rawValue: 404))
                        }
                    .map {
                        return (photo, $0.data)
                    }
            }
            .map { ($0, UIImage(data: $1)) }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    switch result {
                    case .failure(let error):
                        print("Error when running \(#function): \(error)")
                        onError?(error)
                    case .finished:
                        print("Finished \(#function) successfully")
                    }
                },
                receiveValue: { (photo: Flickr.Photo, image: UIImage?) in
                    onPhotoCompletion([image!])
                    Persistency.backgroundContext.perform {
                        let ctx = Persistency.backgroundContext!
                        let pin = ctx.object(with: pinId) as! Pin
                        let _ = Photo(context: ctx, photo: photo, image: image!, pin: pin)
                        do {
                            try ctx.save()
                        } catch {
                            defaultLog.error("\(error as NSObject)")
                        }
                    }
                }
            )
    }
}

// MARK: - CryptoKit
extension AES.GCM.Nonce: CustomStringConvertible {
    public var description: String {
        makeIterator().map { "\($0)" }.joined()
    }
}

/// Secrets that are part of the API bundle like api keys
internal struct AppSecrets: Decodable {
    let flickrApi: FlickrApi
}

internal struct FlickrApi: Decodable {
    let key: String
    let secret: String
}

internal struct FlickrOAuth: Codable {
    /// The flickr user nsid
    let id: String
    let username: String
    let fullName: String
    let token: String
    let tokenSecret: String
}


// MARK: Flickr.Requests
extension Flickr {
    enum Requests<T: Location> {
        case PhotoSearch(location: T, accuracy: Int? ,page: Int)

        func urlRequest(flickrApi: FlickrApi, credentials: FlickrOAuth) -> URLRequest {
            let baseURL = URL(string: "https://www.flickr.com/services/rest/")!
            var request: Flickr.Request
            switch self {
            case let .PhotoSearch(location: location, accuracy, page: page):
                var queryItems = [
                    ("method", "flickr.photos.search"),
                    ("lat", "\(location.latitude)"),
                    ("lat", "\(location.longitude)")
                ]
                if let accuracy = accuracy {
                    queryItems.append(("accuracy", "\(accuracy)"))
                }
                queryItems.append(contentsOf: jsonQueryItems(page: page))
                queryItems.append(contentsOf: oauthQueryItems(flickrApi: flickrApi, credentials: credentials))
                request = Flickr.Request(verb: .GET, baseURL: baseURL, queryItems: queryItems)
            }

            return request.signedRequestWith(consumerSecret: flickrApi.secret, tokenSecret: credentials.tokenSecret)
        }

        private func jsonQueryItems(page: Int) -> [(key: String, value: String )] {
            return [
                ("format", "json"),
                ("nojsoncallback", "1"),
                ("per_page", "20"),
                ("page", "\(page)")
            ]
        }

        private func oauthQueryItems(flickrApi: FlickrApi, credentials: FlickrOAuth) -> [(key: String, value: String )] {
            let nonce = AES.GCM.Nonce()
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            let timestamp = formatter.string(from: NSNumber(value: CFAbsoluteTimeGetCurrent() * 1e6))!

            return [
                ("oauth_consumer_key", flickrApi.key),
                ("oauth_signature_method", "HMAC-SHA1"),
                ("oauth_version", "1.0"),
                ("oauth_token", credentials.token),
                ("oauth_timestamp", "\(timestamp)"),
                ("oauth_nonce", "\(nonce)"),
            ]
        }
    }

}

// MARK: - TravelLocationsModel
class TravelLocationsModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {

    // MARK: Properties
    private var _locations: [TravelLocation] {
        willSet {
            objectWillChange.send()
        }
    }

    var fetchRequest: NSFetchRequest<Pin>
    var fetchedResultsController: NSFetchedResultsController<Pin>

    var locations: [TravelLocation] {
        get { _locations }
    }

    // MARK: Methods
    override init() {
        _locations = []
        fetchRequest = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: Persistency.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        super.init()

        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be executed: \(error.localizedDescription)")
        }

        _locations = fetchedResultsController.fetchedObjects!.map {
            try! JSONDecoder().decode(TravelLocation.self, from: $0.travelLocation!)
        }
    }

    func add(location: TravelLocation) {
        let pin = Pin(context: Persistency.persistentContainer.viewContext)
        pin.id = location.id
        pin.travelLocation = location.encoded()
        pin.createdAt = Date()
        pin.updatedAt = Date()
        Persistency.saveContext()
    }

    /// Deletes a location from CoreData given the TravelLocation
    ///
    /// One of my decisions for this project was trying to “isolate” the “TravelLocation” struct from the
    /// actual object I would store in CoreData. In other words: use CoreData in the model file, but use
    /// TravelLocation elsewhere in the project.
    ///
    /// The add and delete location methods then accept “TravelLocation” instead of “Pin” which is the
    /// CoreData entity. Adding is easy enough, and deleting can also be easy, but I am not happy with
    /// the solution. Here I look at my in-memory objects to find the one with the given id, instead of telling
    /// CoreData directly to delete the one with the given id. The `first` method is `O(n)`, so this delete
    /// method is also `O(n)`
    ///
    /// I decided to keep this as it was my original intention and I was curious to see how to do it, but I am
    /// not sure if I would follow this in a future project. Maybe just using the CoreData model directly throughout
    /// the app could be more efficient.
    ///
    /// - Complexity
    /// `O(n)`
    func delete(location: TravelLocation) {
        let pin = fetchedResultsController.fetchedObjects!.first { $0.id! == location.id }!
        Persistency.viewContext.delete(pin)
        Persistency.saveContext()
    }

    func edit(location: TravelLocation) {
        fatalError("TODO")
    }

    // MARK: NSFetchResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // TODO this object is not necessary if we are talking simply about updates to the locations array
        // however, it might be needed if we want to watch notifications in the "photos" array, which is not part of the travel location at the moment... should it be? if yes then we remove this later
        objectWillChange.send()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let pin = anObject as! Pin
            _locations.append(pin.unwrappedTravelLocation)
        case .delete:
            // TODO need to validate this works!
            let pin = anObject as! Pin
            let location = pin.unwrappedTravelLocation
            let index = _locations.firstIndex(where: { location.id == $0.id })!
            self._locations.remove(at: index)
        default:
            break
        }
    }
}

extension Pin {
    var unwrappedTravelLocation: TravelLocation {
        try! JSONDecoder().decode(TravelLocation.self, from: self.travelLocation!)
    }
}
