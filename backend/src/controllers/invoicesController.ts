// src/controllers/invoicesController.ts
import { Request, Response } from 'express';
import { getAllInvoices, insertInvoice } from '../db/invoices';
import { sendSuccess, sendError } from '../utils/responses';

export async function getInvoicesHandler(req: Request, res: Response) {
  try {
    const data = await getAllInvoices();
    return sendSuccess(res, data);
  } catch (err) {
    console.error('GET /invoices failed:', err);
    return sendError(res, 'Failed to fetch invoices');
  }
}

export async function createInvoiceHandler(req: Request, res: Response) {
  const { invoice_number, invoice_date, status } = req.body;

  try {
    const newInvoice = await insertInvoice({ invoice_number, invoice_date, status });
    return sendSuccess(res, newInvoice, 201);
  } catch (err) {
    console.error('POST /invoices failed:', err);
    return sendError(res, 'Failed to create invoice');
  }
}
