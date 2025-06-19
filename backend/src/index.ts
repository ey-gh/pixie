// src/index.ts
import express from 'express';
import dotenv from 'dotenv';
import { errorHandler } from './middleware/errorHandler';
import clientRoutes from './routes/clients';
import locationsRoutes from './routes/locations';
import authorizationsRoutes from './routes/authorizations';
import attendanceRoutes from './routes/attendance';
import claimsRoutes from './routes/claims';
import invoicesRoutes from './routes/invoices';
import remittancesRoutes from './routes/remittances';

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

app.use(errorHandler);
app.use('/clients', clientRoutes);
app.use('/locations', locationsRoutes);
app.use('/authorizations', authorizationsRoutes);
app.use('/attendance', attendanceRoutes);
app.use('/claims', claimsRoutes);
app.use('/invoices', invoicesRoutes);
app.use('/remittances', remittancesRoutes);