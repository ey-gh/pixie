// src/db/remittances.ts
import { db } from '../config/db';

export async function getAllRemittances() {
  const result = await db.query(`
    SELECT * FROM remittances
    ORDER BY remittance_date DESC NULLS LAST, created_at DESC
    LIMIT 100
  `);
  return result.rows;
}

export async function insertRemittance(data: {
  remittance_date?: string;
  payer_id?: string;
  payment_reference?: string;
  payment_amount?: number;
  method?: string;
  status?: string;
  notes?: string;
}) {
  const {
    remittance_date = new Date().toISOString().split('T')[0],
    payer_id,
    payment_reference,
    payment_amount = 0,
    method,
    status = 'received',
    notes
  } = data;

  const result = await db.query(
    `INSERT INTO remittances (
      remittance_date, payer_id, payment_reference,
      payment_amount, method, status, notes
    ) VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING *`,
    [
      remittance_date,
      payer_id ?? null,
      payment_reference ?? null,
      payment_amount,
      method ?? null,
      status,
      notes ?? null
    ]
  );

  return result.rows[0];
}
