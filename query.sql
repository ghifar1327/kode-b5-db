-- 1. LOGIN
SELECT 
    id, 
    foto_profile, 
    first_name, 
    last_name, 
    email, 
    password
FROM users
WHERE email = 'user@example.com' AND password 'Abc12345';

-- 2. REGISTER

INSERT INTO users (
    foto_profile, 
    first_name, 
    last_name, 
    email, 
    password, 
    created_at, 
    update_at
)
VALUES (
    'img.jpg', 
    'ghifar', 
    'ramdhani', 
    'givartorreto@example.com', 
    'Abc12345', 
    NOW(), 
    NOW()
)

-- 3. GET UPCOMING MOVIE
SELECT 
    m.id, 
    m.movie_title, 
    m.movie_duration, 
    m.movie_rating, 
    m.movie_release,
    d.first_name || ' ' || d.last_name AS director_name
FROM movies m
JOIN directors d ON m.director_id = d.id
WHERE m.movie_release > NOW()
ORDER BY m.movie_release ASC;

-- 4. GET POPULAR MOVIE
SELECT 
    m.id, 
    m.movie_title, 
    m.movie_duration, 
    m.movie_rating, 
    m.movie_release,
    d.first_name || ' ' || d.last_name AS director_name
FROM movies m
JOIN directors d ON m.director_id = d.id
WHERE m.movie_release <= NOW()
ORDER BY m.movie_rating DESC
LIMIT 10;

-- 5. GET MOVIE WITH PAGINATION

SELECT 
    m.id, 
    m.movie_title, 
    m.movie_duration, 
    m.movie_rating, 
    m.movie_release,
    d.first_name || ' ' || d.last_name AS director_name
FROM movies m
JOIN directors d ON m.director_id = d.id
ORDER BY m.id
LIMIT 10 OFFSET 0;
SELECT COUNT(*) AS total 
FROM movies;


-- 6. FILTER MOVIE BY NAME AND GENRE
SELECT DISTINCT 
    m.id, 
    m.movie_title, 
    m.movie_duration, 
    m.movie_rating, 
    m.movie_release,
    d.first_name || ' ' || d.last_name AS director_name,
    STRING_AGG(DISTINCT g.genre_name, ', ') AS genres
FROM movies m
JOIN directors d ON m.director_id = d.id
INNER JOIN movie_genres mg ON m.id = mg.movie_id
INNER JOIN genres g ON mg.genre_id = g.id
WHERE m.movie_title ILIKE '%a'
  AND g.genre_name ILIKE 'action'
GROUP BY m.id, m.movie_title, m.movie_duration, m.movie_rating, 
         m.movie_release, d.first_name, d.last_name
ORDER BY m.id

-- 7. GET SCHEDULE
SELECT 
    s.id AS schedule_id, 
    s.created_at AS schedule_time,
    m.id AS movie_id,
    m.movie_title,
    c.id AS cinema_id,
    c.cinema_name
FROM schedules s
JOIN movies m ON s.movie_id = m.id
JOIN cinemas c ON s.cinema_id = c.id
WHERE s.movie_id = 1
ORDER BY s.created_at;

-- 8. GET SEAT SOLD/AVAILABLE

SELECT 
    s.id AS seat_id, 
    s.seat_code,
    CASE 
        WHEN o.id IS NOT NULL AND o.status = 'paid' THEN 'sold'
        WHEN o.id IS NOT NULL AND o.status = 'panding' THEN 'pending'
        ELSE 'available'
    END AS seat_status
FROM seats s
LEFT JOIN orders o ON s.id = o.seat_id 
    AND o.schedule_id = 1 
    AND o.status IN ('paid', 'panding')
ORDER BY s.seat_code;

-- 9. GET MOVIE DETAIL

SELECT 
    m.id, 
    m.movie_title, 
    m.movie_duration, 
    m.movie_rating, 
    m.movie_release,
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
GROUP BY m.id, m.movie_title, m.movie_duration, m.movie_rating, 
         m.movie_release, d.first_name, d.last_name;

-- 10. CREATE ORDER
INSERT INTO orders (
    user_id, 
    schedule_id, 
    seat_id, 
    payment_method_id, 
    total_payment, 
    status, 
    created_at, 
    update_at
)
VALUES (
    1, 
    5, 
    10, 
    2, 
    50.0, 
    'panding', 
    NOW(), 
    NOW()
)
RETURNING id, user_id, schedule_id, seat_id, total_payment, status;

-- 11. GET PROFILE

SELECT 
    id, 
    foto_profile, 
    first_name, 
    last_name, 
    email, 
    created_at, 
    update_at
FROM users
WHERE id = 1;

-- 12. GET HISTORY

SELECT 
    h.id AS history_id,
    h.status AS transaction_status,
    h.created_at AS transaction_date,
    o.id AS order_id,
    o.total_payment,
    m.movie_title,
    c.cinema_name,
    s.seat_code,
    sch.created_at AS show_time
FROM history h
JOIN orders o ON h.order_id = o.id
JOIN schedules sch ON o.schedule_id = sch.id
JOIN movies m ON sch.movie_id = m.id
JOIN cinemas c ON sch.cinema_id = c.id
JOIN seats s ON o.seat_id = s.id
WHERE o.user_id = 1
ORDER BY h.created_at DESC;

-- 13. EDIT PROFILE

UPDATE users
SET 
    foto_profile = COALESCE(NULLIF('', ''), foto_profile),
    first_name = COALESCE(NULLIF('Jane', ''), first_name),
    last_name = COALESCE(NULLIF('Smith', ''), last_name),
    update_at = NOW()
WHERE id = 1
RETURNING id, foto_profile, first_name, last_name, email;
-- COALESCE: jika value kosong/NULL, pakai nilai lama

-- 14. GET ALL MOVIE (ADMIN)

SELECT 
    m.id, 
    m.movie_title, 
    m.movie_duration, 
    m.movie_rating, 
    m.movie_release,
    d.first_name || ' ' || d.last_name AS director_name,
    COUNT(DISTINCT o.id) AS total_bookings
FROM movies m
JOIN directors d ON m.director_id = d.id
LEFT JOIN schedules s ON m.id = s.movie_id
LEFT JOIN orders o ON s.id = o.schedule_id AND o.status = 'paid'
GROUP BY m.id, m.movie_title, m.movie_duration, m.movie_rating, 
         m.movie_release, d.first_name, d.last_name
ORDER BY m.id;

-- 15. DELETE MOVIE (ADMIN)

DELETE FROM movies
WHERE id = 1

-- 16. EDIT MOVIE (ADMIN)

UPDATE movies
SET 
    movie_title = COALESCE(NULLIF('Avengers: Endgame', ''), movie_title),
    movie_duration = COALESCE(NULLIF(180, 0), movie_duration),
    movie_rating = COALESCE(NULLIF(8.5, 0), movie_rating),
    movie_release = COALESCE(NULLIF('2026-06-01 19:00:00', ''), movie_release),
    director_id = COALESCE(NULLIF(2, 0), director_id)
WHERE id = 1
