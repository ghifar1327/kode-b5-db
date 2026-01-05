DROP TABLE IF EXISTS detail_order;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS seats;
DROP TABLE IF EXISTS schedule;
DROP TABLE IF EXISTS cinemas;
DROP TABLE IF EXISTS payment_methods;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS movie_actor;
DROP TABLE IF EXISTS movie_genre;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS actors;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS directors;

DROP TYPE IF EXISTS user_role;
DROP TYPE IF EXISTS order_status;

CREATE TYPE user_role AS ENUM ('admin', 'user');
CREATE TYPE order_status AS ENUM ('pending', 'paid', 'canceled');

-- MASTER TABLE ----------------------------------------------------------------------------------------

CREATE TABLE directors (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100)
);

CREATE TABLE genres (
  id SERIAL PRIMARY KEY,
  genre_name VARCHAR(100) NOT NULL
);

CREATE TABLE actors (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100)
);

CREATE TABLE movies (
  id SERIAL PRIMARY KEY,
  movie_poster TEXT,
  movie_backdrop TEXT,
  movie_title VARCHAR(255) NOT NULL,
  movie_duration INT,
  movie_rating INT,
  movie_release_date DATE,
  director_id INT REFERENCES directors(id),
  created_at DATE DEFAULT CURRENT_DATE,
  updated_at DATE DEFAULT CURRENT_DATE
);

-- USERS & PAYMENT ------------------------------------------------------------------------------------------------

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  profile_picture TEXT,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  email VARCHAR(150) UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role user_role DEFAULT 'user',
  created_at DATE DEFAULT CURRENT_DATE,
  updated_at DATE DEFAULT CURRENT_DATE
);

CREATE TABLE payment_methods (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

-- CINEMA & SCHEDULE -------------------------------------------------------------------------------------------------

CREATE TABLE cinemas (
  id SERIAL PRIMARY KEY,
  cinema_name VARCHAR(150),
  location TEXT,
  city VARCHAR(100)
);

CREATE TABLE schedule (
  id SERIAL PRIMARY KEY,
  cinema_id INT REFERENCES cinemas(id),
  movie_id INT REFERENCES movies(id),
  price FLOAT,
  time_date TIMESTAMP
);

-- SEATS & ORDERS --------------------------------------------------------------------------------------------------

CREATE TABLE seats (
  id SERIAL PRIMARY KEY,
  seat_code VARCHAR(10),
  seat_type BOOLEAN
);

CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  time_date TIMESTAMP,
  user_id INT REFERENCES users(id),
  subtotal FLOAT,
  schedule_id INT REFERENCES schedule(id),
  status_order order_status DEFAULT 'pending',
  payment_method_id INT REFERENCES payment_methods(id),
  created_at DATE DEFAULT CURRENT_DATE,
  updated_at DATE DEFAULT CURRENT_DATE
);

-- RELATION TABLE --------------------------------------------------------------------------------------------------

CREATE TABLE movie_genre (
  movie_id INT REFERENCES movies(id) ON DELETE CASCADE,
  genre_id INT REFERENCES genres(id) ON DELETE CASCADE,
);

CREATE TABLE movie_actor (
  movie_id INT REFERENCES movies(id) ON DELETE CASCADE,
  actor_id INT REFERENCES actors(id) ON DELETE CASCADE,
  role VARCHAR(100),
);

CREATE TABLE detail_order (
  orders_id INT REFERENCES orders(id) ON DELETE CASCADE,
  seats_id INT REFERENCES seats(id)
);
