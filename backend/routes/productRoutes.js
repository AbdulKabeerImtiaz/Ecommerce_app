const express = require('express');
const router = express.Router();
const {createProduct,getAllProducts,getProductById,updateProduct,deleteProduct, getAllProductsByCategory, getAllProductsBySearch,getProductStoreName} = require('../controllers/productController');
const verifySeller = require('../middleware/roleMiddleware');

router.post('/createProduct',verifySeller, createProduct);
router.get('/getAllProducts',verifySeller, getAllProducts);
router.get('/getAllProductsByCategory',getAllProductsByCategory);
router.get('/getAllProductsBySearch',getAllProductsBySearch);
router.get('/getProductById',getProductById);
router.get('/getProductStoreName',getProductStoreName);
router.get('/:id', getProductById);
router.put('/:id', updateProduct);
router.delete('/deleteProduct',verifySeller, deleteProduct);

module.exports = router;

