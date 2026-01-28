const express = require('express');
const { body } = require('express-validator');
const transactionController = require('../controllers/transaction.controller');
const { authenticate } = require('../middleware/auth.middleware');

const router = express.Router();

// Validation rules
const transferValidation = [
  body('from_account_id').isInt(),
  body('to_account_id').isInt(),
  body('amount').isFloat({ min: 0.01 }),
  body('description').optional().trim(),
];

const paymentValidation = [
  body('account_id').isInt(),
  body('amount').isFloat({ min: 0.01 }),
  body('recipient').notEmpty(),
  body('description').optional().trim(),
];

// All routes require authentication
router.use(authenticate);

// Routes
router.post('/transfer', transferValidation, transactionController.transfer);
router.post('/payment', paymentValidation, transactionController.payment);
router.get('/', transactionController.getTransactions);
router.get('/:transactionId', transactionController.getTransactionById);
router.get('/account/:accountId', transactionController.getAccountTransactions);

module.exports = router;
