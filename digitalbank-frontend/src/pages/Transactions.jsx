import { useState, useEffect } from 'react'
import axios from 'axios'
import { useAuth } from '../contexts/AuthContext'
import Navigation from '../components/Navigation'

const Transactions = () => {
  const [transactions, setTransactions] = useState([])
  const [loading, setLoading] = useState(true)
  const { token } = useAuth()

  const API_URL = import.meta.env.VITE_TRANSACTIONS_API_URL || 'http://localhost:3003'

  useEffect(() => {
    fetchTransactions()
  }, [])

  const fetchTransactions = async () => {
    try {
      const response = await axios.get(`${API_URL}/api/transactions?limit=100`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      setTransactions(response.data.transactions)
    } catch (error) {
      console.error('Error fetching transactions:', error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return <div className="loading">Loading...</div>
  }

  return (
    <div className="container">
      <Navigation />
      <h1 style={{ color: 'white', marginBottom: '24px' }}>Transaction History</h1>

      <div className="card">
        {transactions.length === 0 ? (
          <p style={{ textAlign: 'center', color: '#6c757d' }}>No transactions yet</p>
        ) : (
          <ul className="transaction-list">
            {transactions.map(tx => (
              <li key={tx.id} className="transaction-item">
                <div style={{ flex: 1 }}>
                  <div style={{ fontWeight: '600', textTransform: 'capitalize' }}>
                    {tx.transaction_type}
                  </div>
                  <div style={{ fontSize: '14px', color: '#6c757d', marginTop: '4px' }}>
                    Transaction ID: {tx.transaction_id}
                  </div>
                  {tx.description && (
                    <div style={{ fontSize: '14px', color: '#6c757d', marginTop: '4px' }}>
                      {tx.description}
                    </div>
                  )}
                  <div style={{ fontSize: '12px', color: '#999', marginTop: '4px' }}>
                    {new Date(tx.created_at).toLocaleString()}
                  </div>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <div style={{ fontSize: '20px', fontWeight: 'bold', color: '#667eea' }}>
                    ${parseFloat(tx.amount).toFixed(2)}
                  </div>
                  <div style={{ 
                    fontSize: '12px', 
                    marginTop: '4px',
                    color: tx.status === 'completed' ? '#28a745' : '#ffc107',
                    textTransform: 'capitalize'
                  }}>
                    {tx.status}
                  </div>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  )
}

export default Transactions
