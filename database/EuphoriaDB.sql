CREATE DATABASE EuphoriaDB;
GO

USE EuphoriaDB;
GO


CREATE TABLE users (
	id INT PRIMARY KEY IDENTITY(1,1),
	username VARCHAR(50) NOT NULL UNIQUE,
	password_hash VARCHAR(255) NOT NULL ,
	email VARCHAR(100) NOT NULL UNIQUE,
	role VARCHAR(20) NOT NULL DEFAULT 'USER',
	profile_img_url VARCHAR(255),
	created_at DATETIME2 DEFAULT GETDATE()
)

UPDATE users SET role = 'ADMIN' WHERE email = 'hasnainaijaz123@gmail.com';

CREATE TABLE artists (
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(50) NOT NULL UNIQUE,
	bio VARCHAR(1000),
	img_url VARCHAR(255)
)



CREATE TABLE albums (
	id INT PRIMARY KEY IDENTITY(1,1),
	artist_id INT NOT NULL,
	title VARCHAR(100) NOT NULL,
	cover_img_url VARCHAR(255),
	release_date DATETIME2,
	CONSTRAINT FK_albums_artist
	FOREIGN KEY (artist_id) 
	REFERENCES artists(id) 
	ON DELETE CASCADE
)

CREATE TABLE songs (
    id INT PRIMARY KEY IDENTITY(1,1),

    album_id INT,

    artist_id INT NOT NULL,

    title VARCHAR(150) NOT NULL,

    genre VARCHAR(50),

    duration_seconds INT NOT NULL,

    audio_url VARCHAR(500) NOT NULL,

    thumbnail_url VARCHAR(500),

    play_count INT DEFAULT 0,

    uploaded_at DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_songs_album
    FOREIGN KEY (album_id)
    REFERENCES albums(id),

    CONSTRAINT FK_songs_artist
    FOREIGN KEY (artist_id)
    REFERENCES artists(id)
);

CREATE TABLE playlists (
    id INT PRIMARY KEY IDENTITY(1,1),

    user_id INT NOT NULL,

    playlist_name VARCHAR(100) NOT NULL,

    description VARCHAR(255),

    created_at DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_playlists_user
    FOREIGN KEY (user_id)
    REFERENCES users(id)
);



CREATE TABLE playlist_songs (
    playlist_id INT NOT NULL,

    song_id INT NOT NULL,

    added_at DATETIME2 DEFAULT GETDATE(),

    PRIMARY KEY (playlist_id, song_id),

    CONSTRAINT FK_playlistSongs_playlist
    FOREIGN KEY (playlist_id)
    REFERENCES playlists(id)
    ON DELETE CASCADE,

    CONSTRAINT FK_playlistSongs_song
    FOREIGN KEY (song_id)
    REFERENCES songs(id)
    ON DELETE CASCADE
);



CREATE TABLE liked_songs (
    user_id INT NOT NULL,

    song_id INT NOT NULL,

    liked_at DATETIME2 DEFAULT GETDATE(),

    PRIMARY KEY (user_id, song_id),

    CONSTRAINT FK_likedSongs_user
    FOREIGN KEY (user_id)
    REFERENCES users(id)
    ON DELETE CASCADE,

    CONSTRAINT FK_likedSongs_song
    FOREIGN KEY (song_id)
    REFERENCES songs(id)
    ON DELETE CASCADE
);





CREATE TABLE listening_history (
    id INT PRIMARY KEY IDENTITY(1,1),

    user_id INT NOT NULL,

    song_id INT NOT NULL,

    played_at DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_history_user
    FOREIGN KEY (user_id)
    REFERENCES users(id)
    ON DELETE CASCADE,

    CONSTRAINT FK_history_song
    FOREIGN KEY (song_id)
    REFERENCES songs(id)
    ON DELETE CASCADE
);