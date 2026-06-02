package com.shopopedia.search.controller;

import com.shopopedia.search.dto.ApiResponse;
import com.shopopedia.search.dto.SearchProductRequest;
import com.shopopedia.search.dto.SearchProductResponse;
import com.shopopedia.search.service.SearchService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/search")
@RequiredArgsConstructor
public class SearchController {

    private final SearchService searchService;

    @PostMapping("/products/index")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<SearchProductResponse> indexProduct(
            @Valid @RequestBody SearchProductRequest request) {

        SearchProductResponse response = searchService.indexProduct(request);

        return ApiResponse.success(
                HttpStatus.CREATED.value(),
                "Product indexed successfully",
                response
        );
    }

    @GetMapping("/products")
    public ApiResponse<List<SearchProductResponse>> searchProducts(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String category) {

        List<SearchProductResponse> response = searchService.searchProducts(keyword, category);

        return ApiResponse.success(
                HttpStatus.OK.value(),
                "Products fetched successfully",
                response
        );
    }

    @GetMapping("/products/all")
    public ApiResponse<List<SearchProductResponse>> getAllIndexedProducts() {

        List<SearchProductResponse> response = searchService.getAllIndexedProducts();

        return ApiResponse.success(
                HttpStatus.OK.value(),
                "Indexed products fetched successfully",
                response
        );
    }
}