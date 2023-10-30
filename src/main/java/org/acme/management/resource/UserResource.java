package org.acme.management.resource;

import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.sql.Array;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.ResultSet;
import java.sql.Struct;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.stream.Collectors;

import javax.sql.DataSource;

import org.acme.management.exception.GenericException;
import org.acme.management.model.User;

import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.Response.Status;
import oracle.jdbc.OracleTypes;

@Path("/users")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class UserResource {

    private final static Map<String, String> USER_ATTRS = new LinkedHashMap<String, String>();

    {
        USER_ATTRS.put("id", "id");
        USER_ATTRS.put("name", "name");
        USER_ATTRS.put("dateOfBirth", "date_of_birth");
        USER_ATTRS.put("email", "email");
        USER_ATTRS.put("ssn", "ssn");
    };

    @Inject
    private DataSource datasource;

    @GET
    @Path("/{id}")
    public Response get(@PathParam("id") BigDecimal id) throws Exception {
        try (
            Connection conn = this.datasource.getConnection();
            CallableStatement stmt = conn.prepareCall("{ call manager.users_package.get_user(?, ?, ?) }");
        ) {
            stmt.setObject("pr_id", id, OracleTypes.NUMBER);
            stmt.registerOutParameter("pr_user", OracleTypes.STRUCT, "MANAGER.T_USER");
            stmt.registerOutParameter("pr_message", OracleTypes.VARCHAR);

            stmt.execute();

            User user = null;
            String message = (String) stmt.getObject("pr_message");

            if (message != null) {
                Status status = message.contains("01403") ? Status.NOT_FOUND : Status.BAD_REQUEST;
                throw new GenericException(status, message);
            } else {
                user = (User) this.convert((Struct) stmt.getObject("pr_user"), User.class);
                return Response.status(Status.OK).entity(user).build();
            }
        }
    }

    @GET
    @Path("/")
    public Response getAll() throws Exception {
        try (
            Connection conn = this.datasource.getConnection();
            CallableStatement stmt = conn.prepareCall("{ call manager.users_package.get_users(?) }");
        ) {
            stmt.registerOutParameter("pr_cursor", OracleTypes.CURSOR);
            stmt.execute();

            List<User> users = new ArrayList<User>();

            ResultSet cursor = (ResultSet) stmt.getObject("pr_cursor", ResultSet.class);

            if (cursor != null) {
                while (cursor.next()) {
                    User user = (User) this.convert(cursor, User.class);
                    users.add(user);
                }
            }

            return Response.ok(users).status(Status.OK).build();
        }
    }

    @POST
    @Path("/")
    public Response insert(@Valid User user) throws Exception {
        try (
            Connection conn = this.datasource.getConnection();
            CallableStatement stmt = conn.prepareCall("{ call manager.users_package.insert_user(?, ?) }");
        ) {
            Object userAttrs[] = {
                user.getId(),
                user.getName(),
                new Date(user.getDateOfBirth().getTime()),
                user.getEmail(),
                user.getSsn()
            };

            Struct struct = conn.createStruct("MANAGER.T_USER", userAttrs);

            stmt.setObject("pr_user", struct, OracleTypes.STRUCT);
            stmt.registerOutParameter("pr_user", OracleTypes.STRUCT, "MANAGER.T_USER");
            stmt.registerOutParameter("pr_message", OracleTypes.VARCHAR);

            stmt.execute();

            String message = (String) stmt.getObject("pr_message");

            if (message != null) {
                throw new GenericException(Status.BAD_REQUEST, message);
            } else {
                user = (User) this.convert((Struct) stmt.getObject("pr_user"), User.class);
                return Response.status(Status.CREATED).entity(user).build();
            }
        }
    }

    @POST
    @Path("/bulk")
    public Response insert(List<@Valid User> users) throws Exception {
        try (
            Connection conn = this.datasource.getConnection();
            CallableStatement stmt = conn.prepareCall("{ call manager.users_package.insert_users(?, ?) }");
        ) {
            Struct[] structs = new Struct[users.size()];

            for (int i = 0; i < structs.length; i++) {
                Object attrs[] = {
                    users.get(i).getId(),
                    users.get(i).getName(),
                    new Date(users.get(i).getDateOfBirth().getTime()),
                    users.get(i).getEmail(),
                    users.get(i).getSsn()
                };

                structs[i] = conn.createStruct("MANAGER.T_USER", attrs);
            }

            oracle.jdbc.OracleConnection oracleConnection = conn.unwrap(oracle.jdbc.OracleConnection.class);
            Array array = oracleConnection.createOracleArray("MANAGER.T_USERS", structs);

            stmt.setObject("pr_users", array, OracleTypes.ARRAY);
            stmt.registerOutParameter("pr_users", OracleTypes.ARRAY, "MANAGER.T_USERS");
            stmt.registerOutParameter("pr_messages", OracleTypes.ARRAY, "SYS.ODCIVARCHAR2LIST");

            stmt.execute();

            Array messages = (Array) stmt.getObject("pr_messages");

            if (messages != null) {
                Object[] items = (Object[]) messages.getArray();

                throw new GenericException(
                    Status.BAD_REQUEST,
                    Arrays.asList(items).stream().map(item -> (String) item).collect(Collectors.toList())
                );
            } else {
                users = new ArrayList<User>();
                array = (Array) stmt.getObject("pr_users");

                Object[] items = (Object[]) array.getArray();

                for (int i = 0; i < items.length; i++) {
                    User user = (User) this.convert((Struct) items[i], User.class);
                    users.add(user);
                }

                return Response.ok(users).status(Status.OK).build();
            }
        }
    }

    @PUT
    @Path("/{id}")
    public Response update(@PathParam("id") BigDecimal id, @Valid User user) throws Exception {
        try (
            Connection conn = this.datasource.getConnection();
            CallableStatement stmt = conn.prepareCall("{ call manager.users_package.update_user(?, ?, ?) }");
        ) {
            Object userAttrs[] = {
                user.getId(),
                user.getName(),
                new Date(user.getDateOfBirth().getTime()),
                user.getEmail(),
                user.getSsn()
            };

            Struct struct = conn.createStruct("MANAGER.T_USER", userAttrs);

            stmt.setObject("pr_id", id, OracleTypes.NUMBER);
            stmt.setObject("pr_user", struct, OracleTypes.STRUCT);
            stmt.registerOutParameter("pr_user", OracleTypes.STRUCT, "MANAGER.T_USER");
            stmt.registerOutParameter("pr_message", OracleTypes.VARCHAR);

            stmt.execute();

            String message = (String) stmt.getString("pr_message");

            if (message != null) {
                Status status = message.contains("01403") ? Status.NOT_FOUND : Status.BAD_REQUEST;
                throw new GenericException(status, message);
            } else {
                user = (User) this.convert((Struct) stmt.getObject("pr_user"), User.class);
                return Response.status(Status.CREATED).entity(user).build();
            }
        }
    }

    @DELETE
    @Path("/{id}")
    public Response delete(@PathParam("id") BigDecimal id) throws Exception {
        try (
            Connection conn = this.datasource.getConnection();
            CallableStatement stmt = conn.prepareCall("{ call manager.users_package.delete_user(?, ?) }");
        ) {
            stmt.setObject("pr_id", id, OracleTypes.NUMBER);
            stmt.registerOutParameter("pr_message", OracleTypes.VARCHAR);

            stmt.execute();

            String message = (String) stmt.getString("pr_message");

            if (message != null) {
                Status status = message.contains("01403") ? Status.NOT_FOUND : Status.BAD_REQUEST;
                throw new GenericException(status, message);
            }

            return Response.status(Status.NO_CONTENT).build();
        }
    }

    private Object convert(ResultSet cursor, Class<?> clazz) throws Exception {
        Object object = clazz.getConstructor().newInstance();

        for (Field field : object.getClass().getDeclaredFields()) {
            if (USER_ATTRS.containsKey(field.getName())) {
                field.setAccessible(true);
                field.set(object, cursor.getObject(USER_ATTRS.get(field.getName()), field.getType()));
            }
        }

        return object;
    }

    private Object convert(Struct struct, Class<?> clazz) throws Exception {
        Object object = clazz.getConstructor().newInstance();
        List<String> attrs = new ArrayList<String>(USER_ATTRS.keySet());

        for (int i = 0; i < attrs.size(); i++) {
            Field field = object.getClass().getDeclaredField(attrs.get(i));
            field.setAccessible(true);
            field.set(object, struct.getAttributes()[i]);
        }

        return object;
    }

}
