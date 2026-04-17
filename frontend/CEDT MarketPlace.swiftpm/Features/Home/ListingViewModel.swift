//
//  ListingViewModel.swift
//  CEDT MarketPlace
//
//  Created by Phachara Charoenkitkul on 18/4/2569 BE.
//

import Foundation

@MainActor
class ListingViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var categories: [Category] = []
    @Published var selectedCategoryId: String? = nil
    @Published var isLoading = false
    
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
    
    func fetchAllData() async {
        self.isLoading = true
        async let categoriesTask = fetchCategories()
        async let listingsTask = fetchListings()
        
        _ = await [categoriesTask, listingsTask]
        self.isLoading = false
    }
    
}
