CREATE DATABASE IF NOT EXISTS twitter_pro_9000 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE twitter_pro_9000;

CREATE TABLE IF NOT EXISTS usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  senha VARCHAR(255) NOT NULL,
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS postagens (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  texto TEXT NOT NULL,
  foto VARCHAR(255) NULL,
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS curtidas (
  usuario_id INT NOT NULL,
  postagem_id INT NOT NULL,
  PRIMARY KEY (usuario_id, postagem_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  FOREIGN KEY (postagem_id) REFERENCES postagens(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS comentarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  postagem_id INT NOT NULL,
  usuario_id INT NOT NULL,
  texto TEXT NOT NULL,
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (postagem_id) REFERENCES postagens(id) ON DELETE CASCADE,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS amizades (
  id INT AUTO_INCREMENT PRIMARY KEY,
  solicitante_id INT NOT NULL,
  destinatario_id INT NOT NULL,
  status ENUM('pendente', 'aceita', 'recusada') NOT NULL DEFAULT 'pendente',
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY par (solicitante_id, destinatario_id),
  FOREIGN KEY (solicitante_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  FOREIGN KEY (destinatario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);
