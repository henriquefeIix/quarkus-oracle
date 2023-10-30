CREATE OR REPLACE PACKAGE BODY users_package AS

PROCEDURE get_user (
    pr_id        IN   tb_users.id%TYPE,
    pr_user      OUT  t_user,
    pr_message   OUT  VARCHAR2
) IS
    user_id_exception    EXCEPTION;
    PRAGMA exception_init(user_id_exception, -20111);    
BEGIN
    IF pr_id IS NULL THEN
        raise_application_error(-20111, 'user id missing');
    END IF;
        
    pr_user := users_package.get_user(pr_id);
EXCEPTION
  WHEN OTHERS THEN
    pr_message := SQLERRM(SQLCODE);
END get_user;


PROCEDURE get_users (
    pr_cursor    OUT  SYS_REFCURSOR
) IS
BEGIN
    OPEN pr_cursor FOR
        SELECT id, name, date_of_birth, email, ssn
        FROM tb_users
        ORDER BY id;
END get_users;


PROCEDURE insert_user (
    pr_user       IN OUT  t_user,
    pr_message    OUT     VARCHAR2
) IS
    v_id              tb_users.id%TYPE;
    v_user            r_user;

    user_exception    EXCEPTION;
    PRAGMA exception_init(user_exception, -20112);
BEGIN
    IF pr_user IS NULL THEN
        raise_application_error(-20112, 'user data missing');
    END IF;

    v_user := users_package.to_record(pr_user);
    
    INSERT INTO tb_users 
    VALUES v_user RETURNING id INTO v_id;

    pr_user := users_package.get_user(v_id);
EXCEPTION
    WHEN OTHERS THEN
        pr_message := SQLERRM(SQLCODE);
END insert_user;


PROCEDURE insert_users (
    pr_users       IN OUT  t_users,
    pr_messages    OUT     SYS.ODCIVARCHAR2LIST
) IS
    dml_exception        EXCEPTION; 
	PRAGMA exception_init(dml_exception, -24381);
    vr_ids               SYS.ODCINUMBERLIST;
    
    user_exception       EXCEPTION;
    PRAGMA exception_init(user_exception, -20112);
BEGIN
    IF pr_users IS EMPTY THEN
        raise_application_error(-20112, 'users data missing');
    END IF;

   FORALL i IN 1 .. pr_users.last SAVE EXCEPTIONS
        INSERT INTO tb_users (name, date_of_birth, email, ssn)
        VALUES (pr_users(i).name, pr_users(i).date_of_birth, pr_users(i).email, pr_users(i).ssn)
        RETURNING id BULK COLLECT INTO vr_ids;

        SELECT t_user(id, name, date_of_birth, email, ssn) BULK COLLECT INTO pr_users
        FROM tb_users
        WHERE id IN (SELECT column_value FROM TABLE(vr_ids));
EXCEPTION
    WHEN dml_exception THEN       
        pr_messages :=  SYS.ODCIVARCHAR2LIST();

        FOR i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT 
        LOOP
            pr_messages.EXTEND;
            pr_messages(i) := SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE) || ' at index ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;
        END LOOP; 
    WHEN OTHERS THEN
        pr_messages :=  SYS.ODCIVARCHAR2LIST();
        pr_messages.EXTEND;
        pr_messages(1) := SQLERRM(SQLCODE);
END insert_users;


PROCEDURE update_user (
    pr_id         IN      tb_users.id%TYPE,
    pr_user       IN OUT  t_user,
    pr_message    OUT     VARCHAR2
) IS
    v_id                 tb_users.id%TYPE;
    v_user               r_user;

    user_id_exception    EXCEPTION;
    PRAGMA exception_init(user_id_exception, -20111);

    user_exception       EXCEPTION;
    PRAGMA exception_init(user_exception, -20112);
BEGIN
    IF pr_id IS NULL THEN
        raise_application_error(-20111, 'user id missing');
    END IF;

    IF pr_user IS NULL THEN
        raise_application_error(-20112, 'user data missing');
    END IF;

    SELECT id, name, date_of_birth, email, ssn INTO v_user 
    FROM tb_users 
    WHERE id = pr_id;

    IF v_user.id IS NULL THEN
        RAISE NO_DATA_FOUND;
    END IF;

    v_user.name           := pr_user.name;
    v_user.date_of_birth  := pr_user.date_of_birth;
    v_user.email          := pr_user.email;
    v_user.ssn            := pr_user.ssn;
    
    UPDATE tb_users SET ROW = v_user 
    WHERE id = v_user.id 
    RETURNING id INTO v_id;
    
   pr_user := users_package.get_user(v_user.id);
EXCEPTION
    WHEN OTHERS THEN
        pr_message := SQLERRM(SQLCODE);
END update_user;


PROCEDURE delete_user (
    pr_id         IN   tb_users.id%TYPE,
    pr_message    OUT  VARCHAR2
) IS
    v_id                 tb_users.id%TYPE;
    user_id_exception    EXCEPTION;
    PRAGMA exception_init(user_id_exception, -20111);
BEGIN
    IF pr_id IS NULL THEN
        raise_application_error(-20111, 'user id missing');
    END IF;

    SELECT id INTO v_id 
    FROM tb_users WHERE id = pr_id;

    IF v_id IS NULL THEN
        RAISE NO_DATA_FOUND;
    END IF;

    DELETE FROM tb_users WHERE id = pr_id;
EXCEPTION
    WHEN OTHERS THEN
        pr_message := SQLERRM(SQLCODE);
END delete_user;


FUNCTION get_user (
    pr_id        IN   tb_users.id%TYPE
) RETURN t_user
IS
    v_user    t_user;
BEGIN
    SELECT t_user(id, name, date_of_birth, email, ssn) INTO v_user
    FROM tb_users
    WHERE id = pr_id;
    
    return v_user;
END get_user;


FUNCTION to_object (
    pr_user       IN  r_user
) RETURN t_user
IS
BEGIN
    return t_user(
        id             => pr_user.id, 
        name           => pr_user.name,
        date_of_birth  => pr_user.date_of_birth,
        email          => pr_user.email,
        ssn            => pr_user.ssn
    );
END to_object;


FUNCTION to_record (
    pr_user    IN  t_user
) RETURN r_user
IS
BEGIN
    return r_user(
        id             => pr_user.id,
        name           => pr_user.name,
        date_of_birth  => pr_user.date_of_birth,
        email          => pr_user.email,
        ssn            => pr_user.ssn
    );
END to_record;

END users_package;