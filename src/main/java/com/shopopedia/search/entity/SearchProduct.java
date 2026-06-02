package com.shopopedia.search.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "search_products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SearchProduct {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long productId;

    @Column(nullable = false)
    private String name;

    @Column(length = 1000)
    private String description;

    private String category;

    private Double price;

    private Integer stock;

    private LocalDateTime indexedAt;

    @PrePersist
    public void prePersist() {
        this.indexedAt = LocalDateTime.now();
    }
}