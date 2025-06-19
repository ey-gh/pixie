// src/index.ts
import express from 'express';
import dotenv from 'dotenv';
import clientRoutes from './routes/clients';

dotenv.config();

const app = express();
const port = process.env.PORT || 4000;

app.use(express.json());

// Placeholder test route
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});

app.use('/clients', clientRoutes);