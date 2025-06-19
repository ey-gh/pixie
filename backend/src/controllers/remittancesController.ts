// src/controllers/remittancesController.ts
import { Request, Response } from 'express';
import { getAllRemittances, insertRemittance } from '../db/remittances';
import { sendSuccess, sendError } from '../utils/responses';

export async function getRemittancesHandler(req: Request, res: Response) {
  try {
    const data = await getAllRemittances();
    return sendSuccess(res, data);
  } catch (err) {
    console.error('GET /remittances failed:', err);
    return sendError(res, 'Failed to fetch remittances');
  }
}

export async function createRemittanceHandler(req: Request, res: Response) {
  const {
    remittance_date,
    payer_id,
    payment_reference,
    payment_amount,
    method,
    status,
    notes
  } = req.body;

  try {
    const remittance = await insertRemittance({
      remittance_date,
      payer_id,
      payment_reference,
      payment_amount,
      method,
      status,
      notes
    });

    return sendSuccess(res, remittance, 201);
  } catch (err) {
    console.error('POST /remittances failed:', err);
    return sendError(res, 'Failed to create remittance');
  }
}
