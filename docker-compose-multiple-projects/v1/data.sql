USE LOCAL_DB;

DROP TABLE IF EXISTS USER;

CREATE TABLE USER (
  id int primary key auto_increment,
  name varchar(255) not null,
  email varchar(255) not null,
  created_at datetime default NOW() not null,
  updated_at datetime null,
  deleted_at datetime null
);

INSERT INTO USER
  (name, email)
VALUES
  ('USER1', 'user1@test.com'),
  ('USER2', 'user2@test.com'),
  ('USER3', 'user3@test.com')
;
