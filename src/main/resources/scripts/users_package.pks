CREATE OR REPLACE PACKAGE users_package AS

TYPE r_user IS RECORD (
    id               NUMBER,
    name             VARCHAR2(250),
    date_of_birth    DATE,
    email            VARCHAR2(250),
    ssn              VARCHAR2(12)
);

PROCEDURE get_user (
    pr_id        IN   tb_users.id%TYPE,
    pr_user      OUT  t_user,
    pr_message   OUT  VARCHAR2
);

PROCEDURE get_users (
    pr_cursor    OUT  SYS_REFCURSOR
);

PROCEDURE insert_user (
    pr_user       IN OUT  t_user,
    pr_message    OUT     VARCHAR2
);

PROCEDURE insert_users (
    pr_users       IN OUT  t_users,
    pr_messages    OUT     SYS.ODCIVARCHAR2LIST
);

PROCEDURE update_user (
    pr_id         IN      tb_users.id%TYPE,
    pr_user       IN OUT  t_user,
    pr_message    OUT     VARCHAR2
);

PROCEDURE delete_user (
    pr_id         IN   tb_users.id%TYPE,
    pr_message    OUT  VARCHAR2
);

FUNCTION get_user (
    pr_id        IN   tb_users.id%TYPE
) RETURN t_user;

FUNCTION to_object (
    pr_user       IN  r_user
) RETURN t_user;

FUNCTION to_record (
    pr_user    IN  t_user
) RETURN r_user;

END users_package;