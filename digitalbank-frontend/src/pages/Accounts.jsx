import { useState, useEffect } from 'react'
import axios from 'axios'
import { useAuth } from '../contexts/AuthContext'
import Navigation from '../components/Navigation'

const Accounts = () => {
  const [accounts, setAccounts] = useState([])
  const [loading, setLoading] = useState(true)
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [accountType, setAccountType] = useState('checking')
  const [message, setMessage] = useState('')
  const [showDepositForm, setShowDepositForm] = useState(null)
  const [showWithdrawForm, setShowWithdrawForm] = useState(null)
  const [amount, setAmount] = useState('')
  const { token } = useAuth()

  const API_URL = import.meta.env.VITE_ACCOUNTS_API_URL || 'http://localhost:3002'

  useEffect(() => {
    fetchAccounts()
  }, [])

  const fetchAccounts = async () => {
    try {
      const response = await axios.get(`${API_URL}/api/accounts`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      setAccounts(response.data.accounts)
    } catch (error) {
      console.error('Error fetching accounts:', error)
    } finally {
      setLoading(false)
    }
  }

  const createAccount = async (e) => {
    e.preventDefault()
    try {
      await axios.post(
        `${API_URL}/api/accounts`,
        { account_type: accountType },
        { headers: { Authorization: `Bearer ${token}` } }
      )
      setMessage('Account created successfully!')
      setShowCreateForm(false)
      fetchAccounts()
      setTimeout(() => setMessage(''), 3000)
    } catch (error) {
      setMessage(error.response?.data?.error || 'Failed to create account')
    }
  }

  const handleDeposit = async (accountId) => {
    try {
      await axios.post(
        `${API_URL}/api/accounts/${accountId}/deposit`,
        { amount: parseFloat(amount) },
        { headers: { Authorization: `Bearer ${token}` } }
      )
      setMessage('Deposit successful!')
      setShowDepositForm(null)
      setAmount('')
      fetchAccounts()
      setTimeout(() => setMessage(''), 3000)
    } catch (error) {
      setMessage(error.response?.data?.error || 'Failed to deposit')
    }
  }

  const handleWithdraw = async (accountId) => {
    try {
      await axios.post(
        `${API_URL}/api/accounts/${accountId}/withdraw`,
        { amount: parseFloat(amount) },
        { headers: { Authorization: `Bearer ${token}` } }
      )
      setMessage('Withdrawal successful!')
      setShowWithdrawForm(null)
      setAmount('')
      fetchAccounts()
      setTimeout(() => setMessage(''), 3000)
    } catch (error) {
      setMessage(error.response?.data?.error || 'Failed to withdraw')
    }
  }

  if (loading) {
    return <div className="loading">Loading...</div>
  }

  return (
    <div className="container">
      <Navigation />
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <h1 style={{ color: 'white' }}>My Accounts</h1>
        <button className="btn btn-primary" onClick={() => setShowCreateForm(!showCreateForm)}>
          {showCreateForm ? 'Cancel' : '+ New Account'}
        </button>
      </div>

      {message && (
        <div className={`card ${message.includes('success') ? 'success' : 'error'}`}>
          {message}
        </div>
      )}

      {showCreateForm && (
        <div className="card">
          <h3>Create New Account</h3>
          <form onSubmit={createAccount}>
            <div className="form-group">
              <label>Account Type</label>
              <select value={accountType} onChange={(e) => setAccountType(e.target.value)}>
                <option value="checking">Checking</option>
                <option value="savings">Savings</option>
                <option value="investment">Investment</option>
              </select>
            </div>
            <button type="submit" className="btn btn-primary">Create Account</button>
          </form>
        </div>
      )}

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(350px, 1fr))', gap: '20px' }}>
        {accounts.map(account => (
          <div key={account.id} className="account-card">
            <h3>{account.account_type.toUpperCase()} ACCOUNT</h3>
            <p>Account Number: {account.account_number}</p>
            <div className="balance">${parseFloat(account.balance).toFixed(2)}</div>
            <p>Currency: {account.currency}</p>
            <p>Status: <span style={{ textTransform: 'capitalize' }}>{account.status}</span></p>
            <p style={{ fontSize: '14px', opacity: 0.8 }}>
              Created: {new Date(account.created_at).toLocaleDateString()}
            </p>
            
            <div style={{ marginTop: '16px', display: 'flex', gap: '8px', flexDirection: 'column' }}>
              {showDepositForm === account.id ? (
                <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                  <input
                    type="number"
                    step="0.01"
                    placeholder="Amount"
                    value={amount}
                    onChange={(e) => setAmount(e.target.value)}
                    style={{ flex: 1, padding: '8px', borderRadius: '4px', border: '1px solid #ddd' }}
                  />
                  <button 
                    onClick={() => handleDeposit(account.id)}
                    className="btn btn-primary"
                    style={{ padding: '8px 12px' }}
                  >
                    Confirm
                  </button>
                  <button 
                    onClick={() => { setShowDepositForm(null); setAmount('') }}
                    className="btn btn-secondary"
                    style={{ padding: '8px 12px' }}
                  >
                    Cancel
                  </button>
                </div>
              ) : showWithdrawForm === account.id ? (
                <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                  <input
                    type="number"
                    step="0.01"
                    placeholder="Amount"
                    value={amount}
                    onChange={(e) => setAmount(e.target.value)}
                    style={{ flex: 1, padding: '8px', borderRadius: '4px', border: '1px solid #ddd' }}
                  />
                  <button 
                    onClick={() => handleWithdraw(account.id)}
                    className="btn btn-primary"
                    style={{ padding: '8px 12px' }}
                  >
                    Confirm
                  </button>
                  <button 
                    onClick={() => { setShowWithdrawForm(null); setAmount('') }}
                    className="btn btn-secondary"
                    style={{ padding: '8px 12px' }}
                  >
                    Cancel
                  </button>
                </div>
              ) : (
                <div style={{ display: 'flex', gap: '8px' }}>
                  <button 
                    onClick={() => { setShowDepositForm(account.id); setShowWithdrawForm(null); setAmount('') }}
                    className="btn btn-primary"
                    style={{ flex: 1 }}
                  >
                    💵 Deposit
                  </button>
                  <button 
                    onClick={() => { setShowWithdrawForm(account.id); setShowDepositForm(null); setAmount('') }}
                    className="btn btn-secondary"
                    style={{ flex: 1 }}
                  >
                    💸 Withdraw
                  </button>
                </div>
              )}
            </div>
          </div>
        ))}
      </div>

      {accounts.length === 0 && (
        <div className="card">
          <p style={{ textAlign: 'center', color: '#6c757d' }}>
            No accounts yet. Create your first account to get started!
          </p>
        </div>
      )}
    </div>
  )
}

export default Accounts
