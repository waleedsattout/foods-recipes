CREATE TABLE IF NOT exists
  categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
  );

CREATE TABLE IF NOT exists
  images (
    id INT PRIMARY KEY AUTO_INCREMENT,
    imageUrl VARCHAR(255) NOT NULL
  );

CREATE TABLE IF NOT exists
  ingredients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    categoryId INT NOT NULL,
    FOREIGN KEY (categoryId) REFERENCES categories (id)
  );

CREATE TABLE IF NOT exists
  measurements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
  );

CREATE TABLE IF NOT exists
  recipe_ingredients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    recipeId INT NOT NULL,
    ingredientId INT NOT NULL,
    quantity INT NOT NULL,
    unitId INT NOT NULL,
    FOREIGN KEY (recipeId) REFERENCES recipes (id),
    FOREIGN KEY (ingredientId) REFERENCES ingredients (id),
    FOREIGN KEY (unitId) REFERENCES measurements (id)
  );

CREATE TABLE IF NOT exists
  recipes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    season VARCHAR(255),
    imageUrl VARCHAR(255),
    rating DOUBLE,
    JSON steps JSON DEFAULT (NULL)
  );