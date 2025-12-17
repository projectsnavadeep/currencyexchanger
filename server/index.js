const express = require('express');
const cors = require('cors');
const axios = require('axios');
const app = express();
const PORT = 5000;

app.use(cors());
app.use(express.json());

app.get('/api/currencies', async (req, res) => {
    try {
        const response = await axios.get('https://api.frankfurter.app/currencies');
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: "Failed to fetch currencies" });
    }
});

app.get('/api/convert', async (req, res) => {
    const { from, to, amount } = req.query;
    if (!from || !to || !amount) return res.status(400).json({ error: "Missing params" });
    try {
        const response = await axios.get(`https://api.frankfurter.app/latest`, { params: { amount, from, to } });
        const converted = response.data.rates[to];
        res.json({ amount: converted, rate: converted / amount });
    } catch (error) {
        res.status(500).json({ error: "Conversion failed" });
    }
});

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
