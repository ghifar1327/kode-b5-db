-- 1. LOGIN
-- Mengambil data user berdasarkan email untuk proses login
SELECT id, foto_profile, first_name, last_name, email, password
FROM users
WHERE email = 'posharry0@youtube.com' AND password = '$2a$04$L1Bm7Uo0ajjz6NUElT0X6eiK9OYm3AYPLsbfJp9nBQAmxC5esWi/G'

-- 2. REGISTER
-- Menambahkan user baru ke database
INSERT INTO users (foto_profile, first_name, last_name, email, password, created_at, update_at)
VALUES ('default1.jpg', 'John1', 'Doe1', '1john@example.com', 'h1ashed_password', NOW(), NOW())
RETURNING id, first_name, last_name, email;

-- 3. GET UPCOMING MOVIE
-- Mengambil film yang akan tayang (belum release)
SELECT m.id, m.movie_title, m.movie_duration, m.movie_rating, m.movie_release,
       d.first_name || ' ' || d.last_name AS director_name
FROM movies m
JOIN directors d ON m.director_id = d.id
WHERE m.movie_release > NOW()
ORDER BY m.movie_release ASC;

-- 4. GET POPULAR MOVIE
-- Mengambil film populer berdasarkan rating tertinggi
SELECT m.id, m.movie_title, m.movie_duration, m.movie_rating, m.movie_release,
       d.first_name || ' ' || d.last_name AS director_name
FROM movies m
JOIN directors d ON m.director_id = d.id
WHERE m.movie_release <= NOW()
ORDER BY m.movie_rating DESC
LIMIT 10;

-- 5. GET MOVIE WITH PAGINATION
-- Mengambil semua film dengan sistem pagination
SELECT m.id, m.movie_title, m.movie_duration, m.movie_rating, m.movie_release,
       d.first_name || ' ' || d.last_name AS director_name
FROM movies m
JOIN directors d ON m.director_id = d.id
ORDER BY m.id
LIMIT 10 OFFSET 0;

-- 6. FILTER MOVIE BY NAME AND GENRE WITH PAGINATION
-- Mencari film berdasarkan nama dan genre
SELECT m.id, m.movie_title,
g.genre_name, 
m.movie_duration, m.movie_rating, m.movie_release,
       d.first_name || ' ' || d.last_name AS director_name
FROM movies m
JOIN directors d ON m.director_id = d.id
JOIN movie_genres mg ON m.id = mg.movie_id
JOIN genres g ON mg.genre_id = g.id
WHERE m.movie_title ILIKE 'a%'
  AND (g.genre_name ILIKE 'horror' OR g.id IS NULL)
ORDER BY m.id;

-- 7. GET SCHEDULE
-- Mengambil jadwal tayang berdasarkan film
SELECT s.id, s.created_at, s.update_at,
       m.movie_title,
       c.cinema_name
FROM schedules s
JOIN movies m ON s.movie_id = m.id
JOIN cinemas c ON s.cinema_id = c.id
WHERE s.movie_id = 1
ORDER BY s.created_at;

-- 8. GET SEAT SOLD/AVAILABLE
-- Mengambil status kursi (tersedia atau terjual) untuk jadwal tertentu
SELECT s.id, s.seat_code,
       CASE 
         WHEN o.id IS NOT NULL THEN 'sold'
         ELSE 'available'
       END AS status
FROM seats s
LEFT JOIN orders o ON s.id = o.seat_id 
  AND o.schedule_id = 1 
  AND o.status != 'canceled'
ORDER BY s.seat_code;

-- 9. GET MOVIE DETAIL
-- Mengambil detail lengkap sebuah film termasuk genre dan aktor
SELECT m.id, m.movie_title, m.movie_duration, m.movie_rating, m.movie_release,
       d.first_name || ' ' || d.last_name AS director_name,
       STRING_AGG(DISTINCT g.genre_name, ', ') AS genres,
       STRING_AGG(DISTINCT a.first_name || ' ' || a.last_name, ', ') AS actors
FROM movies m
JOIN directors d ON m.director_id = d.id
LEFT JOIN movie_genres mg ON m.id = mg.movie_id
LEFT JOIN genres g ON mg.genre_id = g.id
LEFT JOIN movie_actors ma ON m.id = ma.movie_id
LEFT JOIN actors a ON ma.actor_id = a.id
WHERE m.id = 1
GROUP BY m.id, m.movie_title, m.movie_duration, m.movie_rating, m.movie_release, d.first_name, d.last_name;

-- 10. CREATE ORDER
-- Membuat order/transaksi baru
INSERT INTO orders (user_id, schedule_id, seat_id, payment_method_id, total_payment, status, created_at, update_at)
VALUES (1, 1, 5, 1, 10.0, 'panding', NOW(), NOW())

-- 11. INSERT HISTORY AFTER CREATE ORDER
-- Mencatat history setelah order dibuat
INSERT INTO history (order_id, status, created_at)
VALUES (1, 'panding', NOW());

-- 12. GET PROFILE
-- Mengambil data profil user
SELECT id, foto_profile, first_name, last_name, email, created_at, update_at
FROM users
WHERE id = 1;

-- 13. GET HISTORY
-- Mengambil riwayat transaksi user
SELECT h.id, h.status, h.created_at,
       o.total_payment,
       m.movie_title,
       c.cinema_name,
       s.seat_code,
       sch.created_at AS schedule_time
FROM history h
JOIN orders o ON h.order_id = o.id
JOIN schedules sch ON o.schedule_id = sch.id
JOIN movies m ON sch.movie_id = m.id
JOIN cinemas c ON sch.cinema_id = c.id
JOIN seats s ON o.seat_id = s.id
WHERE o.user_id = 1
ORDER BY h.created_at DESC;

-- 14. EDIT PROFILE
-- Mengupdate data profil user
UPDATE users
SET foto_profile = 'new_photo.jpg',
    first_name = 'Jane',
    last_name = 'Doe',
    update_at = NOW()
WHERE id = 1
RETURNING id, foto_profile, first_name, last_name, email;

-- 15. GET ALL MOVIE (ADMIN)
-- Mengambil semua film untuk admin
SELECT m.id, m.movie_title, m.movie_duration, m.movie_rating, m.movie_release,
       d.first_name || ' ' || d.last_name AS director_name,
       COUNT(DISTINCT o.id) AS total_orders
FROM movies m
JOIN directors d ON m.director_id = d.id
LEFT JOIN schedules s ON m.id = s.movie_id
LEFT JOIN orders o ON s.id = o.schedule_id
GROUP BY m.id, m.movie_title, m.movie_duration, m.movie_rating, m.movie_release, d.first_name, d.last_name
ORDER BY m.id;

-- 16. DELETE MOVIE (ADMIN)
-- Menghapus film (soft delete recommended)
DELETE FROM movies
WHERE id = 1;

-- 17. EDIT MOVIE (ADMIN)
-- Mengupdate data film
UPDATE movies
SET movie_title = 'Updated Title',
    movie_duration = 120,
    movie_rating = 8.5,
    movie_release = '2026-02-01 00:00:00',
    director_id = 2
WHERE id = 1
RETURNING id, movie_title, movie_duration, movie_rating, movie_release;
