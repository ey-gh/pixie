// src/routes/remittances.ts
import { Router } from 'express';
import { getRemittancesHandler, createRemittanceHandler } from '../controllers/remittancesController';

const router = Router();

router.get('/', getRemittancesHandler);
router.post('/', createRemittanceHandler);

export default router;
