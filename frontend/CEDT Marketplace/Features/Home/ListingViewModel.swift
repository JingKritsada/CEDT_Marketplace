//
//  ListingViewModel.swift
//  CEDT MarketPlace
//
//  Created by Phachara Charoenkitkul on 18/4/2569 BE.
//

import Foundation
import Combine

@MainActor
class ListingViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var categories: [Category] = []
    @Published var selectedCategoryId: String? = nil
    @Published var isLoading = false
    @Published var pickupLocations: [PickupLocation] = []
    
    func fetchCategories() async {
            do {
                self.categories = try await APIClient.shared.request(path: "/categories")
            } catch {
                print("Categories Error: \(error)")
            }
        }
    func fetchListings() async {
            isLoading = true
            var path = "/listings"
            
            if let categoryId = selectedCategoryId {
                path += "?categoryId=\(categoryId)"
            }
            
            do {
                self.listings = try await APIClient.shared.request(path: path)
            } catch {
                print("Listings Error: \(error)")
            }
            isLoading = false
        }
    
    func selectCategory(_ categoryId: String?) async {
            selectedCategoryId = categoryId
            await fetchListings()
        }
    
    func fetchPickupLocations() async {
        do {
            self.pickupLocations = try await APIClient.shared.request(path: "/pickup-locations")
        } catch {
            print("Pickup Error: \(error)")
        }
    }
    
    func fetchAllData() async {
        self.isLoading = true
        async let categoriesTask = fetchCategories()
        async let listingsTask = fetchListings()
        
        _ = await [categoriesTask, listingsTask]
        self.isLoading = false
    }
    
    func fetchListingDetail(id: String) async -> Listing? {
        do {
            let detailedListing: Listing = try await APIClient.shared.request(path: "/listings/\(id)")
            return detailedListing
        } catch {
            print("Fetch Detail Error: \(error)")
            return nil
        }
    }
    func searchListings(query: String? = nil, options: FilterOptions) async {
        self.isLoading = true
        do {
            var params: [String: String] = [:]
            params["status"] = "AVAILABLE"
            
            if let query = query, !query.isEmpty { params["search"] = query }
            if let categoryId = options.selectedCategory { params["categoryId"] = categoryId }
            
            if options.listingType == .free {
                params["isFree"] = "true"
                params["minPrice"] = "0"
                params["maxPrice"] = "0"
            } else {
                if options.listingType == .sell { params["isFree"] = "false" }
                params["minPrice"] = String(Int(options.minPrice))
                params["maxPrice"] = String(Int(options.maxPrice))
            }

            let results: [Listing] = try await APIClient.shared.request(path: "/listings/search", queryParams: params)
            
            DispatchQueue.main.async {
                self.listings = results
            }
        } catch {
            print("Search API Error: \(error)")
        }
        self.isLoading = false
    }
}
