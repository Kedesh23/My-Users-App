CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    firstname TEXT NOT NULL,
    lastname TEXT NOT NULL,
    age INTEGER,
    password TEXT NOT NULL,
    email TEXT NOT NULL
);
