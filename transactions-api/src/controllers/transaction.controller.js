const { validationResult } = require('express-validator');
const { pool } = require('../config/database');
const axios = require('axios');

const ACCOUNTS_API_URL = process.env.ACCOUNTS_API_URL || 'http://localhost:3002';

// Generate unique transaction ID
const generateTransactionId = () => {
  return 'TXN' + Date.now() + Math.floor(Math.random() * 10000);
};

const transfer = async (req, res) => {
  const client = await pool.connect();
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { from_account_id, to_account_id, amount, description } = req.body;
    const user_id = req.user.userId;
    const transaction_id = generateTransactionId();
    const authHeader = req.headers.authorization;

    if (from_account_id === to_account_id) {
      return res.status(400).json({ error: 'Cannot transfer to the same account' });
    }

    // Start transaction
    await client.query('BEGIN');

    // Verify source account ownership and withdraw
    const withdrawResponse = await axios.post(
      `${ACCOUNTS_API_URL}/api/accounts/${from_account_id}/withdraw`,
      { amount },
      { headers: { Authorization: authHeader } }
    ).catch(err => {
      throw new Error(err.response?.data?.error || 'Withdrawal failed');
    });

    // Deposit to destination account
    await axios.post(
      `${ACCOUNTS_API_URL}/api/accounts/${to_account_id}/deposit`,
      { amount },
      { headers: { Authorization: authHeader } }
    ).catch(async err => {
      // Rollback withdrawal
      await axios.post(
        `${ACCOUNTS_API_URL}/api/accounts/${from_account_id}/deposit`,
        { amount },
        { headers: { Authorization: authHeader } }
      );
      throw new Error(err.response?.data?.error || 'Deposit failed');
    });

    // Record transaction
    const result = await client.query(
      `INSERT INTO transactions 
       (transaction_id, user_id, from_account_id, to_account_id, transaction_type, amount, status, description, completed_at) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, CURRENT_TIMESTAMP) 
       RETURNING *`,
      [transaction_id, user_id, from_account_id, to_account_id, 'transfer', amount, 'completed', description]
    );

    await client.query('COMMIT');

    res.status(201).json({
      message: 'Transfer completed successfully',
      transaction: result.rows[0],
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Transfer error:', error);
    res.status(500).json({ error: error.message || 'Transfer failed' });
  } finally {
    client.release();
  }
};

const payment = async (req, res) => {
  const client = await pool.connect();
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { account_id, amount, recipient, description } = req.body;
    const user_id = req.user.userId;
    const transaction_id = generateTransactionId();
    const authHeader = req.headers.authorization;

    // Start transaction
    await client.query('BEGIN');

    // Withdraw from account
    await axios.post(
      `${ACCOUNTS_API_URL}/api/accounts/${account_id}/withdraw`,
      { amount },
      { headers: { Authorization: authHeader } }
    ).catch(err => {
      throw new Error(err.response?.data?.error || 'Payment failed');
    });

    // Record transaction
    const result = await client.query(
      `INSERT INTO transactions 
       (transaction_id, user_id, from_account_id, transaction_type, amount, status, description, completed_at) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP) 
       RETURNING *`,
      [transaction_id, user_id, account_id, 'payment', amount, 'completed', `Payment to ${recipient}: ${description || ''}`]
    );

    await client.query('COMMIT');

    res.status(201).json({
      message: 'Payment completed successfully',
      transaction: result.rows[0],
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Payment error:', error);
    res.status(500).json({ error: error.message || 'Payment failed' });
  } finally {
    client.release();
  }
};

const getTransactions = async (req, res) => {
  try {
    const user_id = req.user.userId;
    const { limit = 50, offset = 0 } = req.query;

    const result = await pool.query(
      'SELECT * FROM transactions WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3',
      [user_id, limit, offset]
    );

    res.json({ transactions: result.rows });
  } catch (error) {
    console.error('Get transactions error:', error);
    res.status(500).json({ error: 'Failed to retrieve transactions' });
  }
};

const getTransactionById = async (req, res) => {
  try {
    const { transactionId } = req.params;
    const user_id = req.user.userId;

    const result = await pool.query(
      'SELECT * FROM transactions WHERE transaction_id = $1 AND user_id = $2',
      [transactionId, user_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Transaction not found' });
    }

    res.json({ transaction: result.rows[0] });
  } catch (error) {
    console.error('Get transaction error:', error);
    res.status(500).json({ error: 'Failed to retrieve transaction' });
  }
};

const getAccountTransactions = async (req, res) => {
  try {
    const { accountId } = req.params;
    const user_id = req.user.userId;
    const { limit = 50, offset = 0 } = req.query;

    const result = await pool.query(
      `SELECT * FROM transactions 
       WHERE user_id = $1 
       AND (from_account_id = $2 OR to_account_id = $2)
       ORDER BY created_at DESC 
       LIMIT $3 OFFSET $4`,
      [user_id, accountId, limit, offset]
    );

    res.json({ transactions: result.rows });
  } catch (error) {
    console.error('Get account transactions error:', error);
    res.status(500).json({ error: 'Failed to retrieve transactions' });
  }
};

module.exports = {
  transfer,
  payment,
  getTransactions,
  getTransactionById,
  getAccountTransactions,
};
