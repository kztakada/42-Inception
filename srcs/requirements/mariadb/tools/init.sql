SELECT 'Initializing database...' AS message;

-- データベースの作成(絵文字OK/ユニコードに基づく文字比較ルール＆大文字小文字の区別なし)
CREATE DATABASE IF NOT EXISTS `__PLACEHOLDER_DB__` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- ユーザーの作成(%で全てのホストにアクセス許可＆パスワード設定)
CREATE USER IF NOT EXISTS '__PLACEHOLDER_USER__'@'%' IDENTIFIED BY '__PLACEHOLDER_PASSWORD__';
-- 作成したデータベースに対する全権限を付与
GRANT ALL PRIVILEGES ON `__PLACEHOLDER_DB__`.* TO '__PLACEHOLDER_USER__'@'%';
-- rootユーザーのパスワードを設定
ALTER USER 'root'@'localhost' IDENTIFIED BY '__PLACEHOLDER_ROOT_PASSWORD__';
-- 権限の変更を即時反映
FLUSH PRIVILEGES;

SELECT 'Database initialized.' AS message;