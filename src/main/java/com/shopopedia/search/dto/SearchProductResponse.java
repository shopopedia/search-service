package com.shopopedia.search.dto;

public record SearchProductResponse(
        Long id,
        Long productId,
        String name,
        String description,
        String category,
        Double price,
        Integer stock
) {
}