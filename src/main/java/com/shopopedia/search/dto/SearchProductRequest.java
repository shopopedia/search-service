package com.shopopedia.search.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record SearchProductRequest(

        @NotNull(message = "Product id is required")
        Long productId,

        @NotBlank(message = "Product name is required")
        String name,

        String description,

        @NotBlank(message = "Category is required")
        String category,

        Double price,

        Integer stock
) {
}