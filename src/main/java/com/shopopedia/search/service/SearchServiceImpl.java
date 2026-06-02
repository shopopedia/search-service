package com.shopopedia.search.service;

import com.shopopedia.search.dto.SearchProductRequest;
import com.shopopedia.search.dto.SearchProductResponse;
import com.shopopedia.search.entity.SearchProduct;
import com.shopopedia.search.exception.SearchProductAlreadyExistsException;
import com.shopopedia.search.repository.SearchProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SearchServiceImpl implements SearchService {

    private final SearchProductRepository searchProductRepository;

    @Override
    public SearchProductResponse indexProduct(SearchProductRequest request) {

        if (searchProductRepository.existsByProductId(request.productId())) {
            throw new SearchProductAlreadyExistsException(
                    "Product already indexed with productId: " + request.productId()
            );
        }

        SearchProduct product = SearchProduct.builder()
                .productId(request.productId())
                .name(request.name())
                .description(request.description())
                .category(request.category())
                .price(request.price())
                .stock(request.stock())
                .build();

        SearchProduct savedProduct = searchProductRepository.save(product);

        return mapToResponse(savedProduct);
    }

    @Override
    public List<SearchProductResponse> searchProducts(String keyword, String category) {

        List<SearchProduct> products;

        if (keyword != null && !keyword.isBlank()) {
            products = searchProductRepository
                    .findByNameContainingIgnoreCaseOrDescriptionContainingIgnoreCase(keyword, keyword);
        } else if (category != null && !category.isBlank()) {
            products = searchProductRepository.findByCategoryIgnoreCase(category);
        } else {
            products = searchProductRepository.findAll();
        }

        return products.stream()
                .map(this::mapToResponse)
                .toList();
    }

    @Override
    public List<SearchProductResponse> getAllIndexedProducts() {

        return searchProductRepository.findAll()
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    private SearchProductResponse mapToResponse(SearchProduct product) {
        return new SearchProductResponse(
                product.getId(),
                product.getProductId(),
                product.getName(),
                product.getDescription(),
                product.getCategory(),
                product.getPrice(),
                product.getStock()
        );
    }
}