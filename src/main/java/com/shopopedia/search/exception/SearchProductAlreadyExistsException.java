package com.shopopedia.search.exception;

public class SearchProductAlreadyExistsException extends RuntimeException {

    public SearchProductAlreadyExistsException(String message) {
        super(message);
    }
}