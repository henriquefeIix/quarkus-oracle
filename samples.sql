SET SERVEROUTPUT ON;

DECLARE
    pr_user       t_user;
    pr_message    VARCHAR2(500);
BEGIN
    users_package.get_user(20, pr_user, pr_message);

    IF pr_message IS NOT NULL THEN
        dbms_output.put_line(pr_message);
    ELSE
        dbms_output.put_line(pr_user.id || ' - ' || pr_user.name);
    END IF;
END;


DECLARE
    pr_cursor    SYS_REFCURSOR;
BEGIN
    users_package.get_users(pr_cursor);
    dbms_sql.return_result(pr_cursor);
END;


DECLARE
    pr_user       t_user;
    pr_message    VARCHAR2(500);
BEGIN
    pr_user := t_user(
        id             => null,
        name           => 'Giacomo Jeger',
        date_of_birth  => TO_DATE('1992-01-20', 'YYYY-MM-DD'),
        email          => 'gjeger0@tinypic.com',
        ssn            => '525-40-5511'
    );

    users_package.insert_user(pr_user, pr_message);

    IF pr_message IS NOT NULL THEN
        dbms_output.put_line(pr_message);
    ELSE
        dbms_output.put_line(pr_user.id || ' - ' || pr_user.name);
    END IF;
END;


DECLARE
    pr_users      t_users := t_users();
    pr_messages   SYS.ODCIVARCHAR2LIST;
BEGIN
    pr_users.EXTEND(2);
    
    pr_users(1) := t_user(
        id             => null,
        name           => 'Tris Yeaman',
        date_of_birth  => TO_DATE('1988-02-27', 'YYYY-MM-DD'),
        email          => 'tyeaman0@ovh.net',
        ssn            => '328-56-5999'
    );

    pr_users(2) := t_user(
        id             => null,
        name           => 'Silvester Nesterov',
        date_of_birth  => TO_DATE('1989-12-29', 'YYYY-MM-DD'),
        email          => 'snesterov2@cam.ac.uk',
        ssn            => '732-76-3588'
    );

    users_package.insert_users(pr_users, pr_messages);

    IF pr_messages IS NOT NULL THEN
        FOR i IN 1 .. pr_messages.LAST
        LOOP
            dbms_output.put_line(pr_messages(i));
        END LOOP;
    ELSE
        FOR i IN 1 .. pr_users.LAST
        LOOP
            dbms_output.put_line(pr_users(i).id || ' - ' || pr_users(i).name);
        END LOOP;
    END IF;
END;


DECLARE
    pr_id         tb_users.id%TYPE := 2;
    pr_user       t_user;
    pr_message    VARCHAR2(500);
BEGIN
    SELECT t_user(id, name, date_of_birth, email, ssn) INTO pr_user
    FROM tb_users
    WHERE id = pr_id;
    
    pr_user.name           := 'Salli Bison';
    pr_user.date_of_birth  := TO_DATE('1999-05-29', 'YYYY-MM-DD');
    pr_user.email          := 'sbison1@ca.gov';
    pr_user.ssn            := '364-66-9919';
    
    users_package.update_user(pr_id, pr_user, pr_message);
   
    IF pr_message IS NOT NULL THEN
        dbms_output.put_line(pr_message);
    ELSE
        dbms_output.put_line(pr_user.id || ' - ' || pr_user.name);
    END IF;
END;


DECLARE
    pr_id         tb_users.id%TYPE := 2;
    pr_message    VARCHAR2(500);
BEGIN
    users_package.delete_user(pr_id, pr_message);

    IF pr_message IS NOT NULL THEN
        dbms_output.put_line(pr_message);
    END IF;
END;
