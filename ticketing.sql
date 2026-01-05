DROP TABLE IF EXISTS history;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS schedules;
DROP TABLE IF EXISTS movie_actors;
DROP TABLE IF EXISTS movie_genres;
DROP TABLE IF EXISTS seats;
DROP TABLE IF EXISTS cinemas;
DROP TABLE IF EXISTS payment_methods;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS actors;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS directors;

--MASTER TABLES
CREATE TABLE directors (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100)
);

CREATE TABLE movies (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  movie_title VARCHAR(255),
  movie_duration INT,
  movie_rating FLOAT,
  movie_release TIMESTAMP,
  director_id INT,
    FOREIGN KEY (director_id) REFERENCES directors(id)
);

CREATE TABLE genres (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  genre_name VARCHAR(100)
);

CREATE TABLE actors (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100)
);

CREATE TABLE cinemas (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  cinema_name VARCHAR(255)
);

CREATE TABLE seats (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  seat_code VARCHAR(10)
);

CREATE TABLE users (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  foto_profile VARCHAR(255),
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  email VARCHAR(255) UNIQUE,
  password TEXT,
  created_at TIMESTAMP,
  update_at TIMESTAMP
);

CREATE TABLE payment_methods (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  payment_name VARCHAR(100),
  created_at TIMESTAMP,
  update_at TIMESTAMP
);

-- RELATION TABLES

CREATE TABLE movie_genres (
  movie_id INT,
  genre_id INT,
  FOREIGN KEY (movie_id) REFERENCES movies(id),
  FOREIGN KEY (genre_id) REFERENCES genres(id)
);


CREATE TABLE movie_actors (
  movie_id INT,
  actor_id INT,
  FOREIGN KEY (movie_id) REFERENCES movies(id),
  FOREIGN KEY (actor_id) REFERENCES actors(id)
);

-- TRANSACTION TABLES
CREATE TABLE schedules (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  movie_id INT,
  cinema_id INT,
  created_at TIMESTAMP,
  update_at TIMESTAMP,
  FOREIGN KEY (movie_id) REFERENCES movies(id),
  FOREIGN KEY (cinema_id) REFERENCES cinemas(id)
);

CREATE TABLE orders (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id INT,
  schedule_id INT,
  seat_id INT,
  payment_method_id INT,
  total_payment NUMERIC(10,2),
  status VARCHAR(100) NOT NULL default 'panding' CHECK (status in ('paid', 'panding', 'canceled')),
  created_at TIMESTAMP,
  update_at TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (schedule_id) REFERENCES schedules(id),
  FOREIGN KEY (seat_id) REFERENCES seats(id),
  FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id)
);

CREATE TABLE history (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id INT,
  status VARCHAR(100) not NULL DEFAULT 'panding' CHECK(status in ('paid', 'panding', 'canceled')),
  created_at TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id)
);
