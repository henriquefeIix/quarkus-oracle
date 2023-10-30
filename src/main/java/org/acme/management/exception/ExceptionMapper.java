package org.acme.management.exception;

import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.Response.Status;
import jakarta.ws.rs.ext.Provider;

@Provider
public class ExceptionMapper implements jakarta.ws.rs.ext.ExceptionMapper<Exception> {

    @Override
    public Response toResponse(Exception ex) {
        GenericException exception = null;

        if (ex instanceof GenericException) {
            exception = (GenericException) ex;
        } else {
            exception = new GenericException(Status.INTERNAL_SERVER_ERROR, ex.getMessage());
        }

        return Response.status(exception.getStatus()).entity(exception).build();
    }

}
