// src/db/invoices.ts
import { db } from '../config/db';

export async function getAllInvoices() {
  const result = await db.query(`
    SELECT * FROM invoices
    ORDER BY invoice_date DESC
    LIMIT 100
  `);
  return result.rows;
}

export async function insertInvoice(data: {
  invoice_number?: string;
  invoice_date?: string;
  status?: string;
}) {
  const {
    invoice_number,
    invoice_date = new Date().toISOString().split('T')[0],
    status = 'open'
  } = data;

  const result = await db.query(
    `INSERT INTO invoices (invoice_number, invoice_date, status)
     VALUES ($1, $2, $3)
     RETURNING *`,
    [invoice_number ?? null, invoice_date, status]
  );

  return result.rows[0];
}
