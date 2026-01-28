import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import axios from 'axios'
import { useAuth } from '../contexts/AuthContext'
import Navigation from '../components/Navigation'

const Dashboard = () => {
  const [accounts, setAccounts] = useState([])
  const [transactions, setTransactions] = useState([])
  const [loading, setLoading] = useState(true)
  const { token } = useAuth()

  const ACCOUNTS_API = import.meta.env.VITE_ACCOUNTS_API_URL || 'http://localhost:3002'
  const TRANSACTIONS_API = import.meta.env.VITE_TRANSACTIONS_API_URL || 'http://localhost:3003'

  useEffect(() => {
    fetchData()
  }, [])

  const fetchData = async () => {
    try {
      const [accountsRes, transactionsRes] = await Promise.all([
        axios.get(`${ACCOUNTS_API}/api/accounts`, {
          headers: { Authorization: `Bearer ${token}` }
        }),
        axios.get(`${TRANSACTIONS_API}/api/transactions?limit=5`, {
          headers: { Authorization: `Bearer ${token}` }
        })
      ])
      setAccounts(accountsRes.data.accounts)
      setTransactions(transactionsRes.data.transactions)
    } catch (error) {
      console.error('Error fetching data:', error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return <div className="loading">Loading...</div>
  }

  const totalBalance = accounts.reduce((sum, acc) => sum + parseFloat(acc.balance), 0)

  return (
    <div className="container">
      <Navigation />
      <h1 style={{ color: 'white', marginBottom: '24px' }}>Dashboard</h1>
      
      <div className="card">
        <h2>Total Balance</h2>
        <div style={{ fontSize: '48px', fontWeight: 'bold', color: '#667eea', margin: '20px 0' }}>
          ${totalBalance.toFixed(2)}
        </div>
        <p style={{ color: '#6c757d' }}>Across {accounts.length} account(s)</p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '20px' }}>
        <div className="card">
          <h3>Quick Actions</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginTop: '16px' }}>
            <Link to="/accounts" className="btn btn-primary" style={{ textDecoration: 'none', textAlign: 'center' }}>
              View Accounts
            </Link>
            <Link to="/transfer" className="btn btn-primary" style={{ textDecoration: 'none', textAlign: 'center' }}>
              Make Transfer
            </Link>
            <Link to="/transactions" className="btn btn-secondary" style={{ textDecoration: 'none', textAlign: 'center' }}>
              View All Transactions
            </Link>
          </div>
        </div>

        <div className="card">
          <h3>Recent Transactions</h3>
          {transactions.length === 0 ? (
            <p style={{ color: '#6c757d', marginTop: '16px' }}>No transactions yet</p>
          ) : (
            <ul className="transaction-list">
              {transactions.slice(0, 3).map(tx => (
                <li key={tx.id} className="transaction-item">
                  <div>
                    <div style={{ fontWeight: '600' }}>{tx.transaction_type}</div>
                    <div style={{ fontSize: '14px', color: '#6c757d' }}>
                      {new Date(tx.created_at).toLocaleDateString()}
                    </div>
                  </div>
                  <div style={{ fontWeight: 'bold', color: '#667eea' }}>
                    ${parseFloat(tx.amount).toFixed(2)}
                  </div>
                </li>
              ))}
            </ul>
          )}
        </div>
      </div>
    </div>
  )
}

export default Dashboard
