// ./src/db/authorizations.ts
import { db } from '../config/db';

export async function getAllAuthorizations() {
  const result = await db.query(`
    SELECT * FROM authorizations
    ORDER BY created_at DESC
    LIMIT 100
  `);
  return result.rows;
}

export async function insertAuthorization(data: {
  client_id: string;
  insurance_provider_id: string;
  payer_id?: string;
  authorization_number?: string;
  start_date: string;
  end_date: string;
  status?: string;
  notes?: string;
}) {
  const {
    client_id,
    insurance_provider_id,
    payer_id,
    authorization_number,
    start_date,
    end_date,
    status = 'pending',
    notes,
  } = data;

  const result = await db.query(
    `INSERT INTO authorizations (
      client_id, insurance_provider_id, payer_id,
      authorization_number, start_date, end_date, status, notes
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    RETURNING *`,
    [
      client_id,
      insurance_provider_id,
      payer_id ?? null,
      authorization_number,
      start_date,
      end_date,
      status,
      notes,
    ]
  );

  return result.rows[0];
}
