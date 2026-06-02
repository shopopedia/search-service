package com.shopopedia.search.repository;

import com.shopopedia.search.entity.SearchProduct;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SearchProductRepository extends JpaRepository<SearchProduct, Long> {

    List<SearchProduct> findByNameContainingIgnoreCase(String keyword);

    List<SearchProduct> findByCategoryIgnoreCase(String category);

    List<SearchProduct> findByNameContainingIgnoreCaseOrDescriptionContainingIgnoreCase(
            String nameKeyword,
            String descriptionKeyword
    );

    boolean existsByProductId(Long productId);
}