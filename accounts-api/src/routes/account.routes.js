const express = require('express');
const { body } = require('express-validator');
const accountController = require('../controllers/account.controller');
const { authenticate } = require('../middleware/auth.middleware');

const router = express.Router();

// Validation rules
const createAccountValidation = [
  body('account_type').isIn(['checking', 'savings', 'investment']),
  body('currency').optional().isLength({ min: 3, max: 3 }),
];

const depositValidation = [
  body('amount').isFloat({ min: 0.01 }),
];

// All routes require authentication
router.use(authenticate);

// Routes
router.post('/', createAccountValidation, accountController.createAccount);
router.get('/', accountController.getAccounts);
router.get('/:accountId', accountController.getAccountById);
router.post('/:accountId/deposit', depositValidation, accountController.deposit);
router.post('/:accountId/withdraw', depositValidation, accountController.withdraw);
router.get('/:accountId/balance', accountController.getBalance);
router.patch('/:accountId/status', accountController.updateStatus);

module.exports = router;
