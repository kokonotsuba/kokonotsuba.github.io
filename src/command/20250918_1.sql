CREATE TABLE deleted_posts (
	id INT AUTO_INCREMENT PRIMARY KEY,
	post_uid INT NOT NULL,          -- FK to posts(id)
	board_uid INT NOT NULL,         -- FK to boards(id) (copied from post at delete time)
	deleted_by INT NULL,            -- FK to users(id)
	deleted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	file_only TINYINT(1) DEFAULT 0,
	by_proxy TINYINT(1) DEFAULT 0,

	note TEXT NULL,                 -- optional moderator note

	-- restore fields (NULL until restored)
	restored_at TIMESTAMP NULL,
	restored_by INT NULL,           -- FK to users(id)

	-- generated flag: 1 when open (restored_at IS NULL), 0 otherwise
	open_flag TINYINT(1) AS (IF(restored_at IS NULL, 1, 0)) STORED,
	
	
	-- helper column for uniqueness: only filled when open
	open_post_uid INT AS (CASE WHEN restored_at IS NULL THEN post_uid ELSE NULL END) STORED,

	-- FKs (adjust ON DELETE as you prefer)
	CONSTRAINT fk_dp_post FOREIGN KEY (post_uid) REFERENCES posts(post_uid) ON DELETE CASCADE,
	CONSTRAINT fk_dp_board FOREIGN KEY (board_uid) REFERENCES boards(board_uid) ON DELETE CASCADE,

	-- Handy indexes
	KEY idx_post_uid (post_uid),
	KEY idx_board_deleted_at (board_uid, deleted_at),
	KEY idx_deleted_by_deleted_at (deleted_by, deleted_at),
	KEY idx_restored_at (restored_at),

	-- Enforce: at most one open row per post_uid
	UNIQUE KEY uq_open_post_uid (open_post_uid)
) ENGINE=InnoDB;
