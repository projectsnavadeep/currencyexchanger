$content = @'
import { useState, useEffect, useCallback } from 'react'
import './index.css'

function App() {
  const [currencies, setCurrencies] = useState({});
  const [from, setFrom] = useState('USD');
  const [to, setTo] = useState('EUR');
  const [amount, setAmount] = useState(1);
  const [converted, setConverted] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  
  // DIRECT API URL for Client-Only Mode
  const API_BASE = 'https://api.frankfurter.app';

  useEffect(() => {
    fetch(`${API_BASE}/currencies`)
      .then(res => res.json())
      .then(data => {
         setCurrencies(data);
         if (data && !Object.keys(data).includes(from)) setFrom('USD');
      })
      .catch(err => console.error(err));
  }, []);

  const handleConvert = useCallback(async () => {
    if (!amount) {
        setConverted(null);
        return;
    }
    setLoading(true); setError(null);
    try {
      // Direct Frankfurter API call: /latest?amount=10&from=USD&to=EUR
      const res = await fetch(`${API_BASE}/latest?amount=${amount}&from=${from}&to=${to}`);
      if (!res.ok) throw new Error('Conversion failed');
      
      const data = await res.json();
      // data.rates is { EUR: 9.something }
      setConverted(data.rates[to]);
    } catch (err) {
      setError("Failed to fetch rates. Check connection.");
      setConverted(null);
    } finally {
      setLoading(false);
    }
  }, [amount, from, to]);

  // Live conversion with debounce
  useEffect(() => {
      const timeoutId = setTimeout(() => {
          handleConvert();
      }, 500); 
      
      return () => clearTimeout(timeoutId);
  }, [handleConvert]);

  return (
    <div className="container">
      <div className="card">
        <h1>Currency Exchanger</h1>
        
        <div className="form-group">
            <label>Amount</label>
            <input 
                type="number" 
                value={amount} 
                onChange={e => setAmount(e.target.value)} 
                placeholder="Enter amount"
                className="amount-input"
            />
        </div>

        <div className="row">
            <div className="form-group">
                <label>From</label>
                <select value={from} onChange={e => setFrom(e.target.value)}>
                    {Object.keys(currencies).map(c => <option key={c} value={c}>{c}</option>)}
                </select>
            </div>
            
            <div className="arrow">to</div>
            
            <div className="form-group">
                <label>To</label>
                <select value={to} onChange={e => setTo(e.target.value)}>
                    {Object.keys(currencies).map(c => <option key={c} value={c}>{c}</option>)}
                </select>
            </div>
        </div>

        <div className="result-container">
            {loading ? (
                <div className="loading">Converting...</div>
            ) : error ? (
                <div className="error">{error}</div>
            ) : converted !== null ? (
                <div className="result">
                    <span className="result-val">{Number(converted).toFixed(2)}</span> <span className="result-unit">{to}</span>
                </div>
            ) : null}
        </div>
      </div>
    </div>
  )
}

export default App
'@
Set-Content -Path "client\src\App.jsx" -Value $content -Encoding UTF8
Write-Host "App.jsx updated for Client-Only mode"
