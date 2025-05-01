const {create,getById,getAll,update,deleteProd,getByCategory,getByKeyword,getName} = require('../models/productModel');
const db = require('../config/db'); 

const createProduct = async (req, res) => {
  try {
    const product =  req.body ;
    const result = await create(product);
    if (!result) {
        return res.status(400).json({ message: "Product failed to upload" });
    }
    res.status(201).json({ message: 'Product created', id: result.insertId });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const getAllProducts = async (req, res) => {
  try {
    // const products = await getAll();
    // res.json(products);
    const id = req.query.id; 
    if (!id) {
      return res.status(400).json({ error: 'Product ID is required' });
    }

    // await getAll(id);
    // res.status(200).json({ message: 'Products fetched' });
    const products = await getAll(id); 
    const [reviews] = await db.execute('SELECT * FROM reviews');

    // 3. Attach reviews to their corresponding products
    const productsWithRatings = products.map(product => {
      const productRatings = reviews
        .filter(review => review.product_id === product.id) // match by product id
        .map(review => ({
          id: review.id,
          customerId: review.customer_id,
          productId: review.product_id,
          rating: parseFloat(review.rating), // important to ensure rating is float
          comment: review.comment,
          createdAt: review.created_at
        }));

      return {
        ...product,
        rating: productRatings
      };
    });

    res.status(200).json(productsWithRatings);
    //res.status(200).json(products); 
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const getAllProductsBySearch = async (req, res) => {
    try {
      // const products = await getAll();
      // res.json(products);
      const keyword = req.query.keyword; 
      if (!keyword) {
        return res.status(400).json({ error: 'No search criteria provided' });
      }
  
      // await getAll(id);
      // res.status(200).json({ message: 'Products fetched' });
      const products = await getByKeyword(keyword); 

      const [reviews] = await db.execute('SELECT * FROM reviews');

    // 3. Attach reviews to their corresponding products
    const productsWithRatings = products.map(product => {
      const productRatings = reviews
        .filter(review => review.product_id === product.id) // match by product id
        .map(review => ({
          id: review.id,
          customerId: review.customer_id,
          productId: review.product_id,
          rating: parseFloat(review.rating), // important to ensure rating is float
          comment: review.comment,
          createdAt: review.created_at
        }));

      return {
        ...product,
        rating: productRatings
      };
    });

    res.status(200).json(productsWithRatings);

      //res.status(200).json(products); 
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  };

const getAllProductsByCategory = async (req, res) => {
    try {
      // const products = await getAll();
      // res.json(products);
      const category=req.query.category; 
      if (!category) {
        return res.status(400).json({ error: 'Product category is required' });
      }
  
      // await getAll(id);
      // res.status(200).json({ message: 'Products fetched' });
      const products = await getByCategory(category); 
      const [reviews] = await db.execute('SELECT * FROM reviews');

    // 3. Attach reviews to their corresponding products
    const productsWithRatings = products.map(product => {
      const productRatings = reviews
        .filter(review => review.product_id === product.id) // match by product id
        .map(review => ({
          id: review.id,
          customerId: review.customer_id,
          productId: review.product_id,
          rating: parseFloat(review.rating), // important to ensure rating is float
          comment: review.comment,
          createdAt: review.created_at
        }));

      return {
        ...product,
        rating: productRatings
      };
    });

    res.status(200).json(productsWithRatings);
      //res.status(200).json(products); 
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  };

const getProductById = async (req, res) => {
  try {
    const product = await getById(req.query.id);
    if (!product) return res.status(404).json({ message: 'Product not found' });
    const [reviews] = await db.execute('SELECT * FROM reviews');

    const productRatings = reviews
      .filter(review => review.product_id === product.id) 
      .map(review => ({
        id: review.id,
        customerId: review.customer_id,
        productId: review.product_id,
        rating: parseFloat(review.rating),
        comment: review.comment,
        createdAt: review.created_at
      }));

    res.status(200).json({
      ...product,
      rating: productRatings 
    });
    //res.json(product);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const updateProduct = async (req, res) => {
  try {
    const result = await update(req.params.id, req.body);
    res.json({ message: 'Product updated' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const deleteProduct = async (req, res) => {
  try {
    // await deleteProd(req.params.id);
    const id = req.query.id; 
    if (!id) {
      return res.status(400).json({ error: 'Product ID is required' });
    }

    await deleteProd(id);
    res.status(200).json({ message: 'Product deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const getProductStoreName = async (req, res) => {
    try {
        const id=req.query.id;
        //console.log(id);
        if (!id) {
            return res.status(400).json({ error: 'Product ID is required' });
          }
      const storeName = await getName(id);
      if (!storeName) return res.status(404).json({ message: 'Store not found' });
      res.status(200).json(storeName);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  };

  const getDealOfTheday = async (req, res) => {
    try {
      //const products = await getByCategory(category); 
      
      const [products] = await db.execute('SELECT * FROM products');
      const [reviews] = await db.execute('SELECT * FROM reviews');

    // 3. Attach reviews to their corresponding products
    const productsWithRatings = products.map(product => {
      const productRatings = reviews
        .filter(review => review.product_id === product.id) // match by product id
        .map(review => ({
          id: review.id,
          customerId: review.customer_id,
          productId: review.product_id,
          rating: parseFloat(review.rating), // important to ensure rating is float
          comment: review.comment,
          createdAt: review.created_at
        }));

      return {
        ...product,
        rating: productRatings
      };
    });
    
    // for (let i = 0; i < productsWithRatings.length; i++) {
    //     const element = productsWithRatings[i];
    //     for (let j = 0; j < element.rating[j]; j++) {
            
            
    //     }
    // }

    res.status(200).json(productsWithRatings);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  };

module.exports={createProduct,getAllProducts,getProductById,updateProduct,deleteProduct,getAllProductsByCategory,getAllProductsBySearch,getProductStoreName};
