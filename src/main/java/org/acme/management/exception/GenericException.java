package org.acme.management.exception;

import java.util.Arrays;
import java.util.List;

import jakarta.ws.rs.core.Response.Status;
import lombok.Getter;

public class GenericException extends Exception {

    @Getter
    private Status status;

    @Getter
    private List<String> messages;

    public GenericException(Status status, List<String> messages) {
        this.status = status;
        this.messages = messages;
    }

    public GenericException(Status status, String message) {
        this.status = status;
        this.messages = Arrays.asList(message);
    }

}
