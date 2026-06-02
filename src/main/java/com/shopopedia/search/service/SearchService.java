package com.shopopedia.search.service;

import com.shopopedia.search.dto.SearchProductRequest;
import com.shopopedia.search.dto.SearchProductResponse;

import java.util.List;

public interface SearchService {

    SearchProductResponse indexProduct(SearchProductRequest request);

    List<SearchProductResponse> searchProducts(String keyword, String category);

    List<SearchProductResponse> getAllIndexedProducts();
}