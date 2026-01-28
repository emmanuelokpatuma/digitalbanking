const { validationResult } = require('express-validator');
const { pool } = require('../config/database');

// Generate unique account number
const generateAccountNumber = () => {
  return 'ACC' + Date.now() + Math.floor(Math.random() * 1000);
};

const createAccount = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { account_type, currency = 'USD' } = req.body;
    const user_id = req.user.userId;
    const account_number = generateAccountNumber();

    const result = await pool.query(
      'INSERT INTO accounts (user_id, account_number, account_type, currency) VALUES ($1, $2, $3, $4) RETURNING *',
      [user_id, account_number, account_type, currency]
    );

    res.status(201).json({
      message: 'Account created successfully',
      account: result.rows[0],
    });
  } catch (error) {
    console.error('Create account error:', error);
    res.status(500).json({ error: 'Failed to create account' });
  }
};

const getAccounts = async (req, res) => {
  try {
    const user_id = req.user.userId;
    const result = await pool.query(
      'SELECT * FROM accounts WHERE user_id = $1 ORDER BY created_at DESC',
      [user_id]
    );

    res.json({ accounts: result.rows });
  } catch (error) {
    console.error('Get accounts error:', error);
    res.status(500).json({ error: 'Failed to retrieve accounts' });
  }
};

const getAccountById = async (req, res) => {
  try {
    const { accountId } = req.params;
    const user_id = req.user.userId;

    const result = await pool.query(
      'SELECT * FROM accounts WHERE id = $1 AND user_id = $2',
      [accountId, user_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Account not found' });
    }

    res.json({ account: result.rows[0] });
  } catch (error) {
    console.error('Get account error:', error);
    res.status(500).json({ error: 'Failed to retrieve account' });
  }
};

const deposit = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { accountId } = req.params;
    const { amount } = req.body;

    // Allow deposits to any active account (for transfers)
    const result = await pool.query(
      'UPDATE accounts SET balance = balance + $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 AND status = $3 RETURNING *',
      [amount, accountId, 'active']
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Account not found or inactive' });
    }

    res.json({
      message: 'Deposit successful',
      account: result.rows[0],
    });
  } catch (error) {
    console.error('Deposit error:', error);
    res.status(500).json({ error: 'Deposit failed' });
  }
};

const withdraw = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { accountId } = req.params;
    const { amount } = req.body;
    const user_id = req.user.userId;

    // Check balance first
    const accountCheck = await pool.query(
      'SELECT balance FROM accounts WHERE id = $1 AND user_id = $2 AND status = $3',
      [accountId, user_id, 'active']
    );

    if (accountCheck.rows.length === 0) {
      return res.status(404).json({ error: 'Account not found or inactive' });
    }

    if (parseFloat(accountCheck.rows[0].balance) < amount) {
      return res.status(400).json({ error: 'Insufficient funds' });
    }

    const result = await pool.query(
      'UPDATE accounts SET balance = balance - $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 AND user_id = $3 RETURNING *',
      [amount, accountId, user_id]
    );

    res.json({
      message: 'Withdrawal successful',
      account: result.rows[0],
    });
  } catch (error) {
    console.error('Withdraw error:', error);
    res.status(500).json({ error: 'Withdrawal failed' });
  }
};

const getBalance = async (req, res) => {
  try {
    const { accountId } = req.params;
    const user_id = req.user.userId;

    const result = await pool.query(
      'SELECT balance, currency FROM accounts WHERE id = $1 AND user_id = $2',
      [accountId, user_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Account not found' });
    }

    res.json({ balance: result.rows[0].balance, currency: result.rows[0].currency });
  } catch (error) {
    console.error('Get balance error:', error);
    res.status(500).json({ error: 'Failed to retrieve balance' });
  }
};

const updateStatus = async (req, res) => {
  try {
    const { accountId } = req.params;
    const { status } = req.body;
    const user_id = req.user.userId;

    if (!['active', 'suspended', 'closed'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const result = await pool.query(
      'UPDATE accounts SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 AND user_id = $3 RETURNING *',
      [status, accountId, user_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Account not found' });
    }

    res.json({
      message: 'Status updated successfully',
      account: result.rows[0],
    });
  } catch (error) {
    console.error('Update status error:', error);
    res.status(500).json({ error: 'Failed to update status' });
  }
};

module.exports = {
  createAccount,
  getAccounts,
  getAccountById,
  deposit,
  withdraw,
  getBalance,
  updateStatus,
};
