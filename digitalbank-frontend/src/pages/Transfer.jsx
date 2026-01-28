import { useState, useEffect } from 'react'
import axios from 'axios'
import { useAuth } from '../contexts/AuthContext'
import Navigation from '../components/Navigation'

const Transfer = () => {
  const [accounts, setAccounts] = useState([])
  const [formData, setFormData] = useState({
    from_account_id: '',
    to_account_id: '',
    amount: '',
    description: ''
  })
  const [message, setMessage] = useState('')
  const [loading, setLoading] = useState(false)
  const { token } = useAuth()

  const ACCOUNTS_API = import.meta.env.VITE_ACCOUNTS_API_URL || 'http://localhost:3002'
  const TRANSACTIONS_API = import.meta.env.VITE_TRANSACTIONS_API_URL || 'http://localhost:3003'

  useEffect(() => {
    fetchAccounts()
  }, [])

  const fetchAccounts = async () => {
    try {
      const response = await axios.get(`${ACCOUNTS_API}/api/accounts`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      setAccounts(response.data.accounts.filter(acc => acc.status === 'active'))
    } catch (error) {
      console.error('Error fetching accounts:', error)
    }
  }

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value })
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setMessage('')
    setLoading(true)

    try {
      await axios.post(
        `${TRANSACTIONS_API}/api/transactions/transfer`,
        {
          from_account_id: parseInt(formData.from_account_id),
          to_account_id: parseInt(formData.to_account_id),
          amount: parseFloat(formData.amount),
          description: formData.description
        },
        { headers: { Authorization: `Bearer ${token}` } }
      )
      setMessage('Transfer completed successfully!')
      setFormData({ from_account_id: '', to_account_id: '', amount: '', description: '' })
      fetchAccounts()
    } catch (error) {
      setMessage(error.response?.data?.error || 'Transfer failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="container">
      <Navigation />
      <h1 style={{ color: 'white', marginBottom: '24px' }}>Transfer Money</h1>

      <div className="card" style={{ maxWidth: '600px', margin: '0 auto' }}>
        {message && (
          <div className={message.includes('success') ? 'success' : 'error'} style={{ marginBottom: '20px' }}>
            {message}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>From Account</label>
            <select
              name="from_account_id"
              value={formData.from_account_id}
              onChange={handleChange}
              required
            >
              <option value="">Select account</option>
              {accounts.map(acc => (
                <option key={acc.id} value={acc.id}>
                  {acc.account_type.toUpperCase()} - {acc.account_number} (Balance: ${parseFloat(acc.balance).toFixed(2)})
                </option>
              ))}
            </select>
          </div>

          <div className="form-group">
            <label>To Account</label>
            <select
              name="to_account_id"
              value={formData.to_account_id}
              onChange={handleChange}
              required
            >
              <option value="">Select account</option>
              {accounts.map(acc => (
                <option key={acc.id} value={acc.id}>
                  {acc.account_type.toUpperCase()} - {acc.account_number}
                </option>
              ))}
            </select>
          </div>

          <div className="form-group">
            <label>Amount</label>
            <input
              type="number"
              name="amount"
              value={formData.amount}
              onChange={handleChange}
              min="0.01"
              step="0.01"
              required
            />
          </div>

          <div className="form-group">
            <label>Description (Optional)</label>
            <textarea
              name="description"
              value={formData.description}
              onChange={handleChange}
              rows="3"
            />
          </div>

          <button type="submit" className="btn btn-primary" style={{ width: '100%' }} disabled={loading}>
            {loading ? 'Processing...' : 'Transfer'}
          </button>
        </form>
      </div>
    </div>
  )
}

export default Transfer
