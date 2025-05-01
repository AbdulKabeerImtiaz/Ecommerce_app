const express = require('express');
require('dotenv').config();
const cors = require('cors');
const bodyParser = require('body-parser');

const userRoutes = require('./routes/userRoutes');
const sellerRoutes=require('./routes/sellerRoutes');
const productRoutes=require('./routes/productRoutes');
const reviewRoutes = require('./routes/reviewRoutes');
const cartRoutes=require('./routes/cartRoutes');
const orderRoutes=require('./routes/orderRoutes');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(bodyParser.json());

app.use('/users', userRoutes);
app.use('/sellers',sellerRoutes);
app.use('/products', productRoutes);
app.use('/reviews', reviewRoutes);
app.use('/cart',cartRoutes);
app.use('/order',orderRoutes);

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

