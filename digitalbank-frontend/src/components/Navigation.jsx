import { Link } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

const Navigation = () => {
  const { user, logout } = useAuth()

  return (
    <nav className="nav">
      <div className="nav-links">
        <Link to="/dashboard">Dashboard</Link>
        <Link to="/accounts">Accounts</Link>
        <Link to="/transactions">Transactions</Link>
        <Link to="/transfer">Transfer</Link>
      </div>
      <div>
        <span style={{ marginRight: '20px', color: '#667eea' }}>
          Welcome, {user?.email}
        </span>
        <button className="btn btn-secondary" onClick={logout}>
          Logout
        </button>
      </div>
    </nav>
  )
}

export default Navigation
