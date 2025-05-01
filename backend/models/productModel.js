const db = require('../config/db'); 

  const create= async (product) => {
    console.log(product);
    const [result] = await db.execute(
      `INSERT INTO products (name, description, quantity, images, category, price, user_id)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        product.name,
        product.description,
        product.quantity,
        JSON.stringify(product.images),
        product.category,
        product.price,
        product.sellerId
      ]
    );
    return result;
  }
  
  const getAll= async (id) => {
    const [rows] = await db.execute('SELECT * FROM products where user_id=?',[id]);
    return rows;
  }

  const getById= async (id) => {
    const [rows] = await db.execute('SELECT * FROM products WHERE id = ?', [id]);
    return rows[0];
  }

  const getByKeyword=async (keyword) => {
    const [rows]= await db.query(
        `SELECT *, MATCH(name, description) AGAINST(? IN NATURAL LANGUAGE MODE) AS relevance
         FROM products
         HAVING relevance > 0
         ORDER BY relevance DESC`,
        [keyword]
      );
      return rows;
  }

  const getByCategory= async (category) => {
    const [rows] = await db.execute('SELECT * FROM products WHERE category=?', [category]);
    return rows;
  }

  const update= async (id, product) => {
    const [result] = await db.execute(
      `UPDATE products SET name = ?, description = ?, quantity = ?, images = ?, category = ?, price = ?, userId = ? WHERE id = ?`,
      [
        product.name,
        product.description,
        product.quantity,
        JSON.stringify(product.images),
        product.category,
        product.price,
        product.userId,
        id
      ]
    );
    return result;
  }

  const deleteProd= async (id) => {
    const [result] = await db.execute('DELETE FROM products WHERE id = ?', [id]);
    return result;
  }

  const getName = async (id) => {
    const [rows] = await db.execute(
      'SELECT S.store_name FROM products P, seller_stores S WHERE P.user_id = S.seller_id AND P.id = ?',
      [id]
    );
    return rows[0];
  }
  

module.exports = {create,getAll,getById,update,deleteProd,getByCategory,getByKeyword,getName};
 
