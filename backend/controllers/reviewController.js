const Review = require('../models/reviewModel');

const rateProduct = async (req, res) => {
  try {
    const { customer_id, product_id, rating, comment } = req.body;

    if (!customer_id || !product_id || !rating) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const existingReview = await Review.findReview(customer_id, product_id);

    if (existingReview) {
    //   // If already reviewed, update
    //   await Review.updateReview(customer_id, product_id, rating, comment);
      res.status(400).json({ message: 'Already Reviewed' });
    } else {
      await Review.createReview(customer_id, product_id, rating, comment);
      res.status(201).json({ message: 'Review added successfully' });
    }
  } catch (error) {
    console.error('Error rating product:', error);
    res.status(500).json({ error: error.message });
  }
};

module.exports = {
  rateProduct,
};
