// src/routes/invoices.ts
import { Router } from 'express';
import { getInvoicesHandler, createInvoiceHandler } from '../controllers/invoicesController';

const router = Router();

router.get('/', getInvoicesHandler);
router.post('/', createInvoiceHandler);

export default router;
