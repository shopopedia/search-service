package com.shopopedia.search.dto;

import java.time.LocalDateTime;

public record ApiResponse<T>(
        LocalDateTime timestamp,
        int status,
        String message,
        T data
) {
    public static <T> ApiResponse<T> success(int status, String message, T data) {
        return new ApiResponse<>(LocalDateTime.now(), status, message, data);
    }

    public static <T> ApiResponse<T> error(int status, String message, T data) {
        return new ApiResponse<>(LocalDateTime.now(), status, message, data);
    }
}